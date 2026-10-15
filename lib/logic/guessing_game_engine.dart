import '../models/difficulty_level.dart';
import '../models/guess_entry.dart';

/// Internal snapshot used for rollback/recovery if contradictory feedback
/// or accidental mis-clicks occur.
class _EngineSnapshot {
  final int low;
  final int high;
  final int currentGuess;
  final int guessCount;
  final String aiReasoning;
  final List<GuessHistoryEntry> history;

  _EngineSnapshot({
    required this.low,
    required this.high,
    required this.currentGuess,
    required this.guessCount,
    required this.aiReasoning,
    required List<GuessHistoryEntry> history,
  }) : history = List.unmodifiable(history);
}

/// The core deterministic game engine implementing the binary-search
/// algorithm, contradiction detection, and AI step reasoning.
class GuessingGameEngine {
  DifficultyLevel _level;
  int? _selectedSecretNumber;
  late int _low;
  late int _high;
  late int _currentGuess;
  late int _guessCount;
  bool _gameOver = false;
  bool _isSuccess = false;
  bool _isContradiction = false;
  String? _contradictionMessage;
  String _aiReasoning = '';
  final List<GuessHistoryEntry> _history = [];
  final List<_EngineSnapshot> _snapshots = [];

  GuessingGameEngine({
    required DifficultyLevel level,
    int? selectedSecretNumber,
  })  : _level = level,
        _selectedSecretNumber = selectedSecretNumber {
    reset();
  }

  // --- Getters ---
  DifficultyLevel get level => _level;
  int? get selectedSecretNumber => _selectedSecretNumber;
  int get low => _low;
  int get high => _high;
  int get currentGuess => _currentGuess;
  int get guessCount => _guessCount;
  bool get gameOver => _gameOver;
  bool get isSuccess => _isSuccess;
  bool get isContradiction => _isContradiction;
  String? get contradictionMessage => _contradictionMessage;
  String get aiReasoning => _aiReasoning;
  List<GuessHistoryEntry> get history => List.unmodifiable(_history);
  bool get canUndo => _snapshots.isNotEmpty && !_gameOver;

  /// Updates or sets the secret number.
  void setSecretNumber(int? number) {
    _selectedSecretNumber = number;
    reset();
  }

  /// Resets the engine to a clean state for a new round.
  void reset() {
    _low = _level.min;
    _high = _level.max;
    _guessCount = 1;
    _gameOver = false;
    _isSuccess = false;
    _isContradiction = false;
    _contradictionMessage = null;
    _history.clear();
    _snapshots.clear();
    _currentGuess = _calculateMidpoint(_low, _high);

    if (_selectedSecretNumber != null) {
      _aiReasoning =
          'Searching for secret number $_selectedSecretNumber in [$_low, $_high]. '
          'First guess at midpoint is $_currentGuess.';
    } else {
      _aiReasoning =
          'Searching in [$_low, $_high]. First guess at midpoint is $_currentGuess.';
    }
  }

  /// Changes the difficulty level and starts a fresh round.
  void setDifficulty(DifficultyLevel newLevel, {int? newSecretNumber}) {
    _level = newLevel;
    if (newSecretNumber != null) {
      _selectedSecretNumber = newSecretNumber;
    } else if (_selectedSecretNumber != null) {
      // Clamp or reset if out of bounds of new level
      if (_selectedSecretNumber! < newLevel.min ||
          _selectedSecretNumber! > newLevel.max) {
        _selectedSecretNumber = (newLevel.min + newLevel.max) ~/ 2;
      }
    }
    reset();
  }

  /// Calculates the midpoint using integer arithmetic: low + ((high - low) ~/ 2)
  static int _calculateMidpoint(int min, int max) {
    return min + ((max - min) ~/ 2);
  }

  /// Saves current state to snapshot stack before a transition.
  void _saveSnapshot() {
    _snapshots.add(
      _EngineSnapshot(
        low: _low,
        high: _high,
        currentGuess: _currentGuess,
        guessCount: _guessCount,
        aiReasoning: _aiReasoning,
        history: _history,
      ),
    );
  }

  /// Handles "TOO LOW" feedback from player.
  /// Meaning: Secret number is GREATER than [_currentGuess].
  /// New possible range becomes: [_currentGuess + 1, _high].
  bool processTooLow() {
    if (_gameOver || _isContradiction) return false;

    final int oldLow = _low;
    final int oldHigh = _high;
    final int guessed = _currentGuess;

    // Secret number validation check (if user selected their number upfront)
    if (_selectedSecretNumber != null && _selectedSecretNumber! <= guessed) {
      _isContradiction = true;
      _contradictionMessage =
          'Validation alert: Your secret number is $_selectedSecretNumber, which '
          'is not greater than $guessed. "Too Low" is incorrect here.';
      return false;
    }

    // Mathematical range contradiction check:
    if (guessed >= oldHigh || (guessed + 1) > oldHigh) {
      _isContradiction = true;
      _contradictionMessage =
          'Contradiction detected! You indicated that the secret number is '
          'greater than $guessed, but the highest possible number in this '
          'range is $oldHigh. There are no integers left in this range.';
      return false;
    }

    _saveSnapshot();

    final int newLow = guessed + 1;
    final int nextGuess = _calculateMidpoint(newLow, oldHigh);

    _history.add(
      GuessHistoryEntry(
        step: _guessCount,
        guess: guessed,
        feedback: GuessFeedback.tooLow,
        lowBefore: oldLow,
        highBefore: oldHigh,
        lowAfter: newLow,
        highAfter: oldHigh,
      ),
    );

    _low = newLow;
    _currentGuess = nextGuess;
    _guessCount++;
    _aiReasoning =
        'Secret is > $guessed. Eliminated [$oldLow, $guessed]. '
        'Remaining range is [$newLow, $oldHigh] with new midpoint $nextGuess.';
    return true;
  }

  /// Handles "TOO HIGH" feedback from player.
  /// Meaning: Secret number is SMALLER than [_currentGuess].
  /// New possible range becomes: [_low, _currentGuess - 1].
  bool processTooHigh() {
    if (_gameOver || _isContradiction) return false;

    final int oldLow = _low;
    final int oldHigh = _high;
    final int guessed = _currentGuess;

    // Secret number validation check (if user selected their number upfront)
    if (_selectedSecretNumber != null && _selectedSecretNumber! >= guessed) {
      _isContradiction = true;
      _contradictionMessage =
          'Validation alert: Your secret number is $_selectedSecretNumber, which '
          'is not smaller than $guessed. "Too High" is incorrect here.';
      return false;
    }

    // Mathematical range contradiction check:
    if (guessed <= oldLow || (guessed - 1) < oldLow) {
      _isContradiction = true;
      _contradictionMessage =
          'Contradiction detected! You indicated that the secret number is '
          'smaller than $guessed, but the lowest possible number in this '
          'range is $oldLow. There are no integers left in this range.';
      return false;
    }

    _saveSnapshot();

    final int newHigh = guessed - 1;
    final int nextGuess = _calculateMidpoint(oldLow, newHigh);

    _history.add(
      GuessHistoryEntry(
        step: _guessCount,
        guess: guessed,
        feedback: GuessFeedback.tooHigh,
        lowBefore: oldLow,
        highBefore: oldHigh,
        lowAfter: oldLow,
        highAfter: newHigh,
      ),
    );

    _high = newHigh;
    _currentGuess = nextGuess;
    _guessCount++;
    _aiReasoning =
        'Secret is < $guessed. Eliminated [$guessed, $oldHigh]. '
        'Remaining range is [$oldLow, $newHigh] with new midpoint $nextGuess.';
    return true;
  }

  /// Handles "CORRECT" feedback from player.
  bool processCorrect() {
    if (_gameOver || _isContradiction) return false;

    // Secret number validation check (if user selected their number upfront)
    if (_selectedSecretNumber != null && _selectedSecretNumber! != _currentGuess) {
      _isContradiction = true;
      _contradictionMessage =
          'Validation alert: Your secret number is $_selectedSecretNumber, but '
          'the current guess is $_currentGuess. They do not match!';
      return false;
    }

    _saveSnapshot();

    _history.add(
      GuessHistoryEntry(
        step: _guessCount,
        guess: _currentGuess,
        feedback: GuessFeedback.correct,
        lowBefore: _low,
        highBefore: _high,
        lowAfter: _low,
        highAfter: _high,
      ),
    );

    _gameOver = true;
    _isSuccess = true;
    _aiReasoning =
        'Target found! The number is $_currentGuess. Found in $_guessCount guess(es).';
    return true;
  }

  /// Automatically performs one step of AI reasoning based on the
  /// selected secret number. Returns true if a step was taken.
  bool autoStep() {
    if (_gameOver || _isContradiction || _selectedSecretNumber == null) {
      return false;
    }

    final int target = _selectedSecretNumber!;
    if (_currentGuess == target) {
      return processCorrect();
    } else if (_currentGuess < target) {
      return processTooLow();
    } else {
      return processTooHigh();
    }
  }

  /// Recovers from an active contradiction by clearing the contradiction
  /// state and allowing the user to select the correct feedback.
  void recoverFromContradiction() {
    if (!_isContradiction) return;
    _isContradiction = false;
    _contradictionMessage = null;
  }

  /// Undoes the last feedback step, restoring previous range, guess, and reasoning.
  bool undoLastStep() {
    if (_snapshots.isEmpty) return false;

    final snapshot = _snapshots.removeLast();
    _low = snapshot.low;
    _high = snapshot.high;
    _currentGuess = snapshot.currentGuess;
    _guessCount = snapshot.guessCount;
    _aiReasoning = snapshot.aiReasoning;
    _history.clear();
    _history.addAll(snapshot.history);

    _gameOver = false;
    _isSuccess = false;
    _isContradiction = false;
    _contradictionMessage = null;

    return true;
  }
}
