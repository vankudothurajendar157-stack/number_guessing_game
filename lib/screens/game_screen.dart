import 'dart:async';
import 'package:flutter/material.dart';
import '../logic/guessing_game_engine.dart';
import '../models/difficulty_level.dart';
import '../models/guess_entry.dart';

class GameScreen extends StatefulWidget {
  final DifficultyLevel initialLevel;
  final int? initialSecretNumber;

  const GameScreen({
    super.key,
    required this.initialLevel,
    this.initialSecretNumber,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GuessingGameEngine _engine;
  bool _isProcessingTap = false;
  bool _isAutoPlaying = false;
  bool _showSecret = true;

  @override
  void initState() {
    super.initState();
    _engine = GuessingGameEngine(
      level: widget.initialLevel,
      selectedSecretNumber: widget.initialSecretNumber,
    );
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
    super.dispose();
  }

  void _handleTooLow() {
    if (_isProcessingTap || _engine.gameOver || _engine.isContradiction) return;
    setState(() {
      _isProcessingTap = true;
      _engine.processTooLow();
    });
    _releaseTapLock();
  }

  void _handleTooHigh() {
    if (_isProcessingTap || _engine.gameOver || _engine.isContradiction) return;
    setState(() {
      _isProcessingTap = true;
      _engine.processTooHigh();
    });
    _releaseTapLock();
  }

  void _handleCorrect() {
    if (_isProcessingTap || _engine.gameOver || _engine.isContradiction) return;
    setState(() {
      _isProcessingTap = true;
      _engine.processCorrect();
    });
    _releaseTapLock();
  }

  void _handleAutoStep() {
    if (_isProcessingTap || _engine.gameOver || _engine.isContradiction) return;

    if (_engine.selectedSecretNumber == null) {
      _promptSelectSecretNumber();
      return;
    }

    setState(() {
      _isProcessingTap = true;
      _engine.autoStep();
    });
    _releaseTapLock();
  }

  Future<void> _toggleAutoPlay() async {
    if (_isAutoPlaying) {
      setState(() => _isAutoPlaying = false);
      return;
    }

    if (_engine.selectedSecretNumber == null) {
      _promptSelectSecretNumber();
      return;
    }

    setState(() => _isAutoPlaying = true);

    while (_isAutoPlaying && !_engine.gameOver && !_engine.isContradiction && mounted) {
      setState(() {
        _engine.autoStep();
      });
      if (_engine.gameOver || _engine.isContradiction) break;
      await Future.delayed(const Duration(milliseconds: 850));
    }

    if (mounted) {
      setState(() => _isAutoPlaying = false);
    }
  }

  void _releaseTapLock() {
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _isProcessingTap = false;
        });
      }
    });
  }

  void _restartRound() {
    setState(() {
      _isAutoPlaying = false;
      _engine.reset();
      _isProcessingTap = false;
    });
  }

  void _changeDifficulty(DifficultyLevel newLevel) {
    setState(() {
      _isAutoPlaying = false;
      _engine.setDifficulty(newLevel);
      _isProcessingTap = false;
    });
  }

  void _recoverContradiction() {
    setState(() {
      _isAutoPlaying = false;
      _engine.recoverFromContradiction();
    });
  }

  void _undoStep() {
    if (!_engine.canUndo) return;
    setState(() {
      _isAutoPlaying = false;
      _engine.undoLastStep();
    });
  }

  void _promptSelectSecretNumber() {
    int current = _engine.selectedSecretNumber ??
        ((_engine.level.min + _engine.level.max) ~/ 2);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text('Select Secret Number (${_engine.level.rangeLabel})'),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$current',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: current.toDouble(),
                      min: _engine.level.min.toDouble(),
                      max: _engine.level.max.toDouble(),
                      divisions: _engine.level.max - _engine.level.min,
                      label: '$current',
                      onChanged: (val) {
                        setDialogState(() {
                          current = val.round();
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    setState(() {
                      _engine.setSecretNumber(null);
                    });
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Clear (Keep in Mind)'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(dialogCtx).pop();
                    setState(() {
                      _engine.setSecretNumber(current);
                    });
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Set & Restart'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text('${_engine.level.name} Mode (${_engine.level.rangeLabel})'),
        ),
        centerTitle: false,
        actions: [
          if (_engine.canUndo)
            IconButton(
              tooltip: 'Undo last response',
              icon: const Icon(Icons.undo_rounded),
              onPressed: _undoStep,
            ),
          IconButton(
            tooltip: 'Restart this level',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _restartRound,
          ),
          PopupMenuButton<DifficultyLevel>(
            tooltip: 'Change level',
            icon: const Icon(Icons.tune_rounded),
            onSelected: _changeDifficulty,
            itemBuilder: (context) => DifficultyLevel.values.map((lvl) {
              return PopupMenuItem(
                value: lvl,
                child: Row(
                  children: [
                    if (lvl == _engine.level)
                      Icon(Icons.check, size: 18, color: theme.colorScheme.primary)
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text('${lvl.name} (${lvl.rangeLabel})'),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Secret Reminder Banner / Selected Secret Badge
              _buildSecretStatusBanner(theme),

              const SizedBox(height: 12),

              // Game Status Badges: Current Guess Count & Remaining Bounds
              _buildStatusRow(theme),

              const SizedBox(height: 12),

              // AI Reasoning Thought Bubble
              _buildAiReasoningCard(theme),

              const SizedBox(height: 12),

              // Contradiction Card OR Victory Card OR Active Guess Card
              if (_engine.isContradiction)
                _buildContradictionCard(theme)
              else if (_engine.gameOver && _engine.isSuccess)
                _buildVictoryCard(theme)
              else
                _buildActiveGuessCard(theme),

              const SizedBox(height: 14),

              // AI Step / Auto Play Action Row (When playing with a selected number)
              if (!_engine.gameOver && !_engine.isContradiction)
                _buildAiControlsRow(theme),

              const SizedBox(height: 12),

              // Three Feedback Buttons (Active during gameplay)
              if (!_engine.gameOver && !_engine.isContradiction)
                _buildFeedbackButtons(theme),

              const SizedBox(height: 20),

              // Guess History Section
              _buildHistoryCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecretStatusBanner(ThemeData theme) {
    final secret = _engine.selectedSecretNumber;

    if (secret != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.stars_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Your Secret Number: ',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _showSecret ? '$secret' : '•••',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: _showSecret ? 'Hide number' : 'Show number',
              icon: Icon(
                _showSecret ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              onPressed: () => setState(() => _showSecret = !_showSecret),
            ),
            IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              tooltip: 'Change secret number',
              icon: const Icon(Icons.edit_rounded, size: 20),
              onPressed: _promptSelectSecretNumber,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lock_rounded,
            color: theme.colorScheme.onPrimaryContainer,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Think of a number between ${_engine.level.min} and ${_engine.level.max}. Keep it secret in your mind!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: _promptSelectSecretNumber,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(40, 32),
            ),
            child: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text('Pick Number', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiReasoningCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD1C4E9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2.0),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 18,
              color: Color(0xFF5E35B1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Brain Reasoning:',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5E35B1),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _engine.aiReasoning,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF311B92),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(ThemeData theme) {
    final int remainingCount = (_engine.high - _engine.low + 1).clamp(0, 100);

    return Row(
      children: [
        Expanded(
          child: _buildInfoPill(
            icon: Icons.pin_drop_rounded,
            label: 'Guess #${_engine.guessCount}',
            color: theme.colorScheme.primary,
            bgColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildInfoPill(
            icon: Icons.unfold_more_rounded,
            label: 'Range: ${_engine.low} – ${_engine.high}',
            color: const Color(0xFF5E35B1),
            bgColor: const Color(0xFF5E35B1).withValues(alpha: 0.1),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(14),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '$remainingCount left',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPill({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveGuessCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shadowColor: theme.colorScheme.primary.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22.0, horizontal: 20.0),
        child: Column(
          children: [
            // AI Brain Avatar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.psychology_rounded,
                size: 38,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'My guess is...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            // Large Guess Display
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '${_engine.currentGuess}',
                style: TextStyle(
                  fontSize: 68,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                  letterSpacing: -1,
                ),
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Is your secret number lower, higher, or exactly ${_engine.currentGuess}?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: theme.colorScheme.onSurface,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiControlsRow(ThemeData theme) {
    return Row(
      children: [
        // AI Step Button
        Expanded(
          child: SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: _isProcessingTap || _isAutoPlaying ? null : _handleAutoStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 18),
              label: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'AI AUTO-STEP',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Auto Play / Pause Button
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _isProcessingTap ? null : _toggleAutoPlay,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF673AB7),
                side: const BorderSide(color: Color(0xFF673AB7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                _isAutoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 20,
              ),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _isAutoPlaying ? 'PAUSE' : 'AUTO-SOLVE',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackButtons(ThemeData theme) {
    return Column(
      children: [
        // Top Row: TOO LOW & TOO HIGH
        Row(
          children: [
            // TOO LOW: Secret number is HIGHER than guess
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessingTap || _isAutoPlaying ? null : _handleTooLow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF57C00), // Amber/Orange
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_upward_rounded, size: 22),
                  label: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'TOO LOW',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Secret is higher',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            // TOO HIGH: Secret number is SMALLER than guess
            Expanded(
              child: SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isProcessingTap || _isAutoPlaying ? null : _handleTooHigh,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2), // Blue
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_downward_rounded, size: 22),
                  label: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'TOO HIGH',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Secret is lower',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Bottom Row: CORRECT
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _isProcessingTap || _isAutoPlaying ? null : _handleCorrect,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E7D32), // Emerald Green
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(Icons.check_circle_rounded, size: 24),
            label: const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'CORRECT! That is my number',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContradictionCard(ThemeData theme) {
    return Card(
      elevation: 4,
      color: const Color(0xFFFFF3E0), // Soft warning amber
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFFFB74D), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFE0B2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE65100),
                size: 40,
              ),
            ),
            const SizedBox(height: 14),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Contradiction Detected!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB71C1C),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _engine.contradictionMessage ??
                  'The feedback provided contradicts earlier answers. The possible range has become empty!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: Color(0xFF4E342E),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _recoverContradiction,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE65100),
                      side: const BorderSide(color: Color(0xFFE65100)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.undo_rounded, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'RECOVER',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _restartRound,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'RESTART',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryCard(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(22.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 48,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 14),
            const FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Aha! I Found It! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Your secret number was ${_engine.currentGuess}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Found in ${_engine.guessCount} ${_engine.guessCount == 1 ? "guess" : "guesses"}! (Optimal ceiling for ${_engine.level.name}: ≤ ${_engine.level.maxTheoreticalGuesses})',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),

            // Continuous Replay: Play Again button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _promptSelectSecretNumber,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'PLAY AGAIN — CHOOSE A NEW NUMBER',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _restartRound,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.replay_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'SAME NUMBER',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.primary,
                        side: BorderSide(color: theme.colorScheme.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'CHANGE LEVEL',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(ThemeData theme) {
    final history = _engine.history;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Guess History (${history.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (history.isNotEmpty)
                  Text(
                    'Step-by-step log',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14.0),
                child: Center(
                  child: Text(
                    'No responses yet. Give feedback or tap AI Auto-Step!',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (context, index) => const Divider(height: 12),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryRow(theme, item);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryRow(ThemeData theme, GuessHistoryEntry item) {
    Color chipBg;
    Color chipText;
    IconData chipIcon;

    switch (item.feedback) {
      case GuessFeedback.tooLow:
        chipBg = const Color(0xFFFFF3E0);
        chipText = const Color(0xFFE65100);
        chipIcon = Icons.arrow_upward_rounded;
        break;
      case GuessFeedback.tooHigh:
        chipBg = const Color(0xFFE3F2FD);
        chipText = const Color(0xFF1565C0);
        chipIcon = Icons.arrow_downward_rounded;
        break;
      case GuessFeedback.correct:
        chipBg = const Color(0xFFE8F5E9);
        chipText = const Color(0xFF2E7D32);
        chipIcon = Icons.check_circle_rounded;
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '#${item.step}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Guess: ${item.guess}',
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: chipBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chipIcon, size: 14, color: chipText),
                const SizedBox(width: 4),
                Text(
                  item.feedback.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: chipText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
