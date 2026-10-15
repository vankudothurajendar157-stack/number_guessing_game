/// Represents the difficulty levels for the System Number Guessing Game.
enum DifficultyLevel {
  easy(
    name: 'Easy',
    min: 1,
    max: 20,
    rangeLabel: '1 – 20',
    description: 'Quick game. Ideal for a fast warm-up.',
    maxTheoreticalGuesses: 5, // ceil(log2(20)) = 5
  ),
  medium(
    name: 'Medium',
    min: 1,
    max: 50,
    rangeLabel: '1 – 50',
    description: 'Balanced challenge. Perfect for sharp minds.',
    maxTheoreticalGuesses: 6, // ceil(log2(50)) = 6
  ),
  hard(
    name: 'Hard',
    min: 1,
    max: 100,
    rangeLabel: '1 – 100',
    description: 'Maximum range. Test the AI algorithm thoroughly.',
    maxTheoreticalGuesses: 7, // ceil(log2(100)) = 7
  );

  final String name;
  final int min;
  final int max;
  final String rangeLabel;
  final String description;
  final int maxTheoreticalGuesses;

  const DifficultyLevel({
    required this.name,
    required this.min,
    required this.max,
    required this.rangeLabel,
    required this.description,
    required this.maxTheoreticalGuesses,
  });
}
