/// Types of feedback the player can give the computer.
enum GuessFeedback {
  tooLow(
    label: 'Too Low',
    shortCode: 'LOW',
    meaning: 'Secret number is HIGHER than this guess',
  ),
  tooHigh(
    label: 'Too High',
    shortCode: 'HIGH',
    meaning: 'Secret number is LOWER than this guess',
  ),
  correct(
    label: 'Correct',
    shortCode: 'CORRECT',
    meaning: 'Found the exact secret number',
  );

  final String label;
  final String shortCode;
  final String meaning;

  const GuessFeedback({
    required this.label,
    required this.shortCode,
    required this.meaning,
  });
}

/// A single step in the computer's guess history.
class GuessHistoryEntry {
  final int step;
  final int guess;
  final GuessFeedback feedback;
  final int lowBefore;
  final int highBefore;
  final int? lowAfter;
  final int? highAfter;

  const GuessHistoryEntry({
    required this.step,
    required this.guess,
    required this.feedback,
    required this.lowBefore,
    required this.highBefore,
    this.lowAfter,
    this.highAfter,
  });

  String get summary => '$guess — ${feedback.label}';
}
