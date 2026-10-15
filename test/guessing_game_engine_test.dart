import 'package:flutter_test/flutter_test.dart';
import 'package:system_number_guessing_game/logic/guessing_game_engine.dart';
import 'package:system_number_guessing_game/models/difficulty_level.dart';
import 'package:system_number_guessing_game/models/guess_entry.dart';

void main() {
  group('GuessingGameEngine - Range Initialization', () {
    test('Easy mode initializes with range 1 to 20 and correct first guess', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      expect(engine.low, 1);
      expect(engine.high, 20);
      expect(engine.currentGuess, 1 + ((20 - 1) ~/ 2)); // 10
      expect(engine.guessCount, 1);
      expect(engine.gameOver, false);
      expect(engine.isContradiction, false);
      expect(engine.history, isEmpty);
    });

    test('Medium mode initializes with range 1 to 50 and correct first guess', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.medium);
      expect(engine.low, 1);
      expect(engine.high, 50);
      expect(engine.currentGuess, 1 + ((50 - 1) ~/ 2)); // 25
      expect(engine.guessCount, 1);
    });

    test('Hard mode initializes with range 1 to 100 and correct first guess', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.hard);
      expect(engine.low, 1);
      expect(engine.high, 100);
      expect(engine.currentGuess, 1 + ((100 - 1) ~/ 2)); // 50
      expect(engine.guessCount, 1);
    });
  });

  group('GuessingGameEngine - Step Transitions', () {
    test('processTooLow updates lower bound to currentGuess + 1 and increments guessCount', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      // Initial: low=1, high=20, guess=10
      final success = engine.processTooLow();
      expect(success, true);
      expect(engine.low, 11);
      expect(engine.high, 20);
      expect(engine.currentGuess, 11 + ((20 - 11) ~/ 2)); // 15
      expect(engine.guessCount, 2);
      expect(engine.history.length, 1);
      expect(engine.history.first.guess, 10);
      expect(engine.history.first.feedback, GuessFeedback.tooLow);
    });

    test('processTooHigh updates upper bound to currentGuess - 1 and increments guessCount', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      // Initial: low=1, high=20, guess=10
      final success = engine.processTooHigh();
      expect(success, true);
      expect(engine.low, 1);
      expect(engine.high, 9);
      expect(engine.currentGuess, 1 + ((9 - 1) ~/ 2)); // 5
      expect(engine.guessCount, 2);
      expect(engine.history.length, 1);
      expect(engine.history.first.guess, 10);
      expect(engine.history.first.feedback, GuessFeedback.tooHigh);
    });

    test('processCorrect sets gameOver and isSuccess without changing guess', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      final initialGuess = engine.currentGuess;
      final success = engine.processCorrect();
      expect(success, true);
      expect(engine.gameOver, true);
      expect(engine.isSuccess, true);
      expect(engine.currentGuess, initialGuess);
      expect(engine.history.length, 1);
      expect(engine.history.first.feedback, GuessFeedback.correct);

      // Subsequent actions must be blocked
      expect(engine.processTooLow(), false);
      expect(engine.processTooHigh(), false);
      expect(engine.processCorrect(), false);
    });
  });

  group('GuessingGameEngine - Continuous Replay & Multiple Rounds', () {
    test('Consecutive rounds reset all bounds, history, guess count, and state cleanly', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.hard);

      // --- Round 1: Target is 73 ---
      while (!engine.gameOver) {
        if (engine.currentGuess == 73) {
          engine.processCorrect();
        } else if (engine.currentGuess < 73) {
          engine.processTooLow();
        } else {
          engine.processTooHigh();
        }
      }

      expect(engine.gameOver, true);
      expect(engine.isSuccess, true);
      expect(engine.currentGuess, 73);
      expect(engine.history.isNotEmpty, true);

      // --- Trigger Continuous Replay Reset ---
      engine.reset();

      // Verify complete clean state
      expect(engine.low, 1);
      expect(engine.high, 100);
      expect(engine.currentGuess, 50); // Fresh midpoint
      expect(engine.guessCount, 1);
      expect(engine.history, isEmpty);
      expect(engine.gameOver, false);
      expect(engine.isSuccess, false);
      expect(engine.isContradiction, false);
      expect(engine.contradictionMessage, isNull);

      // --- Round 2: Target is 12 ---
      while (!engine.gameOver) {
        if (engine.currentGuess == 12) {
          engine.processCorrect();
        } else if (engine.currentGuess < 12) {
          engine.processTooLow();
        } else {
          engine.processTooHigh();
        }
      }

      expect(engine.gameOver, true);
      expect(engine.isSuccess, true);
      expect(engine.currentGuess, 12);
      expect(engine.guessCount, lessThanOrEqualTo(7));

      // --- Trigger Another Replay Reset ---
      engine.reset();
      expect(engine.low, 1);
      expect(engine.high, 100);
      expect(engine.currentGuess, 50);
      expect(engine.guessCount, 1);
      expect(engine.history, isEmpty);
    });
  });

  group('GuessingGameEngine - Contradiction Detection & Recovery', () {
    test('Detects contradiction when user says Too Low at maximum bound', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      engine.processTooLow(); // 15
      engine.processTooLow(); // 18
      engine.processTooLow(); // 19
      engine.processTooLow(); // 20
      expect(engine.low, 20);
      expect(engine.high, 20);
      expect(engine.currentGuess, 20);

      // Saying Too Low when computer is already at max bound 20
      final result = engine.processTooLow();
      expect(result, false);
      expect(engine.isContradiction, true);
      expect(engine.contradictionMessage, contains('Contradiction detected'));

      // Recover clears contradiction flag
      engine.recoverFromContradiction();
      expect(engine.isContradiction, false);
      expect(engine.contradictionMessage, isNull);

      // Now player can tap Correct
      expect(engine.processCorrect(), true);
      expect(engine.isSuccess, true);
    });

    test('Detects contradiction when user says Too High at minimum bound', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      engine.processTooHigh(); // 5
      engine.processTooHigh(); // 2
      engine.processTooHigh(); // 1
      expect(engine.low, 1);
      expect(engine.high, 1);
      expect(engine.currentGuess, 1);

      // Saying Too High when at minimum 1 is impossible
      final result = engine.processTooHigh();
      expect(result, false);
      expect(engine.isContradiction, true);
      expect(engine.contradictionMessage, contains('Contradiction detected'));
    });

    test('Undo reverts previous state and history cleanly', () {
      final engine = GuessingGameEngine(level: DifficultyLevel.easy);
      expect(engine.canUndo, false);

      engine.processTooLow(); // guess was 10, becomes 15
      expect(engine.canUndo, true);
      expect(engine.low, 11);
      expect(engine.guessCount, 2);

      final undone = engine.undoLastStep();
      expect(undone, true);
      expect(engine.low, 1);
      expect(engine.high, 20);
      expect(engine.currentGuess, 10);
      expect(engine.guessCount, 1);
      expect(engine.history, isEmpty);
    });
  });
}
