// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/common_widgets.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tamamlanma dinleyicisi
      ref.listenManual(gameProvider, (_, next) {
        if (next?.isComplete == true) _onComplete();
      });
      // Ekrana girilince timer başlat
      final state = ref.read(gameProvider);
      if (state != null && state.isPaused) {
        ref.read(gameProvider.notifier).togglePause();
      }
    });
  }

  @override
  void dispose() {
    final state = ref.read(gameProvider);
    if (state != null && !state.isPaused && !state.isComplete) {
      ref.read(gameProvider.notifier).togglePause();
    }
    super.dispose();
  }

void _onComplete() async {
  await ref.read(gameProvider.notifier).saveCompletion();
  ref.invalidate(profileProvider);
  ref.invalidate(completionStatsProvider);  // bu satırı ekle
  if (!mounted) return;
  _showCompleteDialog();
}

  void _showCompleteDialog() {
  final state = ref.read(gameProvider);
  if (state == null) return;
  final isDaily  = state.puzzle.dailyId != null;
  final diamonds = isDaily
      ? AppConstants.diamondsDaily
      : state.puzzle.difficulty.diamonds;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: _CompleteModal(
        diamonds: diamonds,
        time: state.elapsedFormatted,
        mistakes: state.mistakeCount,
        difficulty: state.puzzle.difficulty,
        onContinue: () {
          Navigator.pop(context);
          context.pop();
        },
        onPlayAgain: () {
          Navigator.pop(context);
          context.pop();
        },
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: ZennColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // ── Top Bar ───────────────────────────────────────────
              _TopBar(state: state),
              const SizedBox(height: 16),
              // ── Timer + Mistakes + Diamond ─────────────────────
              _StatsRow(state: state),
              const SizedBox(height: 20),
              // ── Board ─────────────────────────────────────────────
              Stack(
                children: [
                  const SudokuGrid(),
                  if (state.isPaused)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: ZennColors.primary.withOpacity(1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.pause_circle_outline_rounded,
                                  size: 56, color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                'Oyun Duraklatıldı',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Devam etmek için ▶ tuşuna bas',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              

              const SizedBox(height: 24),
              // ── Numpad ────────────────────────────────────────────
              const NumberPad(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends ConsumerWidget {
  final GameState state;
  const _TopBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ZennColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: ZennColors.textDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.puzzle.dailyId != null
                    ? 'Günün Sudokusu'
                    : '${state.puzzle.difficulty.label} Sudoku',
                style: ZennTextStyles.headline3,
              ),
            ],
          ),
        ),
        // Pause button
        GestureDetector(
          onTap: () => ref.read(gameProvider.notifier).togglePause(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: ZennColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 22, color: ZennColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final GameState state;
  const _StatsRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Timer
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ZennColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_outlined,
                  size: 16, color: ZennColors.textSoft),
              const SizedBox(width: 5),
              Text(
                state.elapsedFormatted,
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 14,
                  fontWeight: FontWeight.w600, color: ZennColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Mistakes
        MistakeIndicator(mistakes: state.mistakeCount),
        const Spacer(),
        // Diamond reward
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ZennColors.cardLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(size: const Size(13, 13),
                  painter: _GreenDiamond()),
              const SizedBox(width: 5),
              Text(
                '+${state.puzzle.dailyId != null
                    ? AppConstants.diamondsDaily
                    : state.puzzle.difficulty.diamonds}',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w700, color: ZennColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GreenDiamond extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = ZennColors.primary..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .5, 0)
      ..lineTo(size.width,       size.height * .4)
      ..lineTo(size.width * .5,  size.height)
      ..lineTo(0,                size.height * .4)
      ..close();
    canvas.drawPath(path, p);
  }
  @override bool shouldRepaint(_) => false;
}

// ─── Complete Modal ───────────────────────────────────────────────────────────

class _CompleteModal extends StatefulWidget {
  final int diamonds;
  final String time;
  final int mistakes;
  final Difficulty difficulty;
  final VoidCallback onContinue;
  final VoidCallback onPlayAgain;

  const _CompleteModal({
    required this.diamonds,
    required this.time,
    required this.mistakes,
    required this.difficulty,
    required this.onContinue,
    required this.onPlayAgain,
  });

  @override
  State<_CompleteModal> createState() => _CompleteModalState();
}

class _CompleteModalState extends State<_CompleteModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: ScaleTransition(
          scale: _scale,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trophy
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: ZennColors.cardGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      size: 50, color: ZennColors.primary),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Tebrikler! 🎉',
                  style: ZennTextStyles.headline1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sudokuyu tamamladın!',
                  style: ZennTextStyles.body,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ZennColors.background,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultStat(label: 'Süre', value: widget.time),
                      _ResultStat(label: 'Hata', value: '${widget.mistakes}/3'),
                      _ResultStat(
                        label: 'Elmas',
                        value: '+${widget.diamonds}',
                        highlight: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ZennButton(label: 'Ana Sayfaya Dön', onTap: widget.onContinue),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: widget.onPlayAgain,
                  child: const Text('Tekrar Oyna'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _ResultStat({
      required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
            color: highlight ? ZennColors.primary : ZennColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: ZennTextStyles.caption),
      ],
    );
  }
}
