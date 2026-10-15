import 'dart:math';
import 'package:flutter/material.dart';
import '../models/difficulty_level.dart';
import 'game_screen.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});

  void _showSecretNumberPicker(BuildContext context, DifficultyLevel level) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _SecretNumberPickerSheet(level: level);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('System Number Guessing Game'),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24.0),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology_alt_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'AI Mind Guesser',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Think of a secret number mentally or pick it upfront. The AI will deduce it using binary search intelligence!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Select Difficulty Level',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 14),

              // Difficulty Cards
              _buildDifficultyCard(
                context: context,
                level: DifficultyLevel.easy,
                accentColor: const Color(0xFF2E7D32), // Green accent
                icon: Icons.bolt_rounded,
              ),

              const SizedBox(height: 14),

              _buildDifficultyCard(
                context: context,
                level: DifficultyLevel.medium,
                accentColor: const Color(0xFFE65100), // Amber/Orange accent
                icon: Icons.speed_rounded,
              ),

              const SizedBox(height: 14),

              _buildDifficultyCard(
                context: context,
                level: DifficultyLevel.hard,
                accentColor: const Color(0xFFC2185B), // Deep pink / magenta
                icon: Icons.military_tech_rounded,
              ),

              const SizedBox(height: 24),

              // How It Works Expander
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                elevation: 0,
                color: theme.colorScheme.surface,
                child: Theme(
                  data: theme.copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Icon(
                      Icons.help_outline_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    title: const Text(
                      'How to Play',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    children: [
                      _buildRuleItem(
                        icon: Icons.looks_one_rounded,
                        text: 'Choose a level and pick your secret number. You can also keep it secret in your mind.',
                      ),
                      const SizedBox(height: 10),
                      _buildRuleItem(
                        icon: Icons.looks_two_rounded,
                        text: 'The computer starts guessing at the midpoint of the range using binary search.',
                      ),
                      const SizedBox(height: 10),
                      _buildRuleItem(
                        icon: Icons.looks_3_rounded,
                        text: 'Either tap feedback buttons yourself, or tap "AI Auto-Step" / "Auto-Solve" to watch the AI deduce automatically!',
                      ),
                      const SizedBox(height: 10),
                      _buildRuleItem(
                        icon: Icons.auto_awesome_rounded,
                        text: 'The AI guarantees finding your number in <= 5 (Easy), <= 6 (Medium), or <= 7 (Hard) guesses!',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyCard({
    required BuildContext context,
    required DifficultyLevel level,
    required Color accentColor,
    required IconData icon,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showSecretNumberPicker(context, level),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accentColor, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            level.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            level.rangeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.speed,
                          size: 14,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Guaranteed in ≤ ${level.maxTheoreticalGuesses} guesses',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF5E35B1)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, height: 1.35),
          ),
        ),
      ],
    );
  }
}

/// Interactive modal sheet to select secret number upfront.
class _SecretNumberPickerSheet extends StatefulWidget {
  final DifficultyLevel level;

  const _SecretNumberPickerSheet({required this.level});

  @override
  State<_SecretNumberPickerSheet> createState() => _SecretNumberPickerSheetState();
}

class _SecretNumberPickerSheetState extends State<_SecretNumberPickerSheet> {
  late int _chosenNumber;
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _chosenNumber = widget.level.min +
        ((widget.level.max - widget.level.min) * 0.73).round().clamp(0, widget.level.max - widget.level.min);
  }

  void _randomize() {
    setState(() {
      _chosenNumber = widget.level.min + _rng.nextInt(widget.level.max - widget.level.min + 1);
    });
  }

  void _startGame({bool keepSecretInMind = false}) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GameScreen(
          initialLevel: widget.level,
          initialSecretNumber: keepSecretInMind ? null : _chosenNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Select Your Number',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.level.name} (${widget.level.rangeLabel})',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Choose the number you want the AI to guess:',
            style: TextStyle(
              fontSize: 13.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),

          // Large Number Hero Display
          Center(
            child: Container(
              width: 100,
              height: 100,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$_chosenNumber',
                  style: const TextStyle(
                    fontSize: 46,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Slider & Stepper Controls
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: 'Decrease by 1',
                onPressed: _chosenNumber > widget.level.min
                    ? () => setState(() => _chosenNumber--)
                    : null,
                icon: const Icon(Icons.remove),
              ),
              Expanded(
                child: Slider(
                  value: _chosenNumber.toDouble(),
                  min: widget.level.min.toDouble(),
                  max: widget.level.max.toDouble(),
                  divisions: widget.level.max - widget.level.min,
                  label: '$_chosenNumber',
                  onChanged: (val) {
                    setState(() {
                      _chosenNumber = val.round();
                    });
                  },
                ),
              ),
              IconButton.filledTonal(
                tooltip: 'Increase by 1',
                onPressed: _chosenNumber < widget.level.max
                    ? () => setState(() => _chosenNumber++)
                    : null,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Quick Presets using Wrap to avoid overflow
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              ActionChip(
                label: Text('Min (${widget.level.min})'),
                onPressed: () => setState(() => _chosenNumber = widget.level.min),
              ),
              ActionChip(
                label: Text('Mid (${(widget.level.min + widget.level.max) ~/ 2})'),
                onPressed: () => setState(() =>
                    _chosenNumber = (widget.level.min + widget.level.max) ~/ 2),
              ),
              ActionChip(
                label: Text('Max (${widget.level.max})'),
                onPressed: () => setState(() => _chosenNumber = widget.level.max),
              ),
              ActionChip(
                avatar: const Icon(Icons.casino_rounded, size: 16),
                label: const Text('Random'),
                onPressed: _randomize,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Start Button with selected number
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () => _startGame(keepSecretInMind: false),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'START WITH NUMBER $_chosenNumber',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Alternative: Secret in Mind option
          TextButton.icon(
            onPressed: () => _startGame(keepSecretInMind: true),
            icon: const Icon(Icons.psychology_outlined, size: 18),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Or keep number secret in my head (Classic Mode)',
                style: TextStyle(fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
