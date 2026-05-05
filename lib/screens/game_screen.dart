// lib/screens/game_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  // Hata yapıldığında mistake indicator'ı sallayan animasyon
  late AnimationController _mistakeShakeCtrl;
  late Animation<double> _mistakeShakeAnim;

  @override
  void initState() {
    super.initState();

    _mistakeShakeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _mistakeShakeAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_mistakeShakeCtrl);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Tamamlanma + hata dinleyicisi
      ref.listenManual(gameProvider, (prev, next) {
        if (next?.isComplete == true) _onComplete();

        // Yeni hata yapıldıysa salla + titreşim
        if (prev != null &&
            next != null &&
            next.mistakeCount > prev.mistakeCount) {
          _mistakeShakeCtrl.forward(from: 0);
          if (ref.read(hapticEnabledProvider)) HapticFeedback.mediumImpact();
        }
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
    _mistakeShakeCtrl.dispose();
    final state = ref.read(gameProvider);
    if (state != null && !state.isPaused && !state.isComplete) {
      ref.read(gameProvider.notifier).togglePause();
    }
    super.dispose();
  }

  void _onComplete() async {
    if (ref.read(hapticEnabledProvider)) HapticFeedback.heavyImpact();
    await ref.read(gameProvider.notifier).saveCompletion();
    ref.invalidate(profileProvider);
    ref.invalidate(completionStatsProvider);
    if (!mounted) return;
    _showCompleteDialog();
  }

  void _showCompleteDialog() {
    final state = ref.read(gameProvider);
    if (state == null) return;
    final isDaily = state.puzzle.dailyId != null;
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
              // ── Üst bar ──────────────────────────────────────────────────
              _TopBar(state: state),
              const SizedBox(height: 16),
              // ── İstatistik satırı (süre + hatalar + elmas) ───────────────
              _StatsRow(
                  state: state, mistakeShakeAnim: _mistakeShakeAnim),
              const SizedBox(height: 20),
              // ── Sudoku grid (duraklatılınca üstü kapanır) ────────────────
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
              const SizedBox(height: 20),
              // ── Numpad ────────────────────────────────────────────────────
              const NumberPad(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Üst Bar ─────────────────────────────────────────────────────────────────

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
            width: 40,
            height: 40,
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
          child: Text(
            state.puzzle.dailyId != null
                ? 'Günün Sudokusu'
                : '${state.puzzle.difficulty.label} Sudoku',
            style: ZennTextStyles.headline3,
          ),
        ),
        // Durdur / Devam et butonu
        GestureDetector(
          onTap: () {
            if (ref.read(hapticEnabledProvider)) HapticFeedback.lightImpact();
            ref.read(gameProvider.notifier).togglePause();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZennColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              state.isPaused
                  ? Icons.play_arrow_rounded
                  : Icons.pause_rounded,
              size: 22,
              color: ZennColors.textDark,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── İstatistik Satırı ────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final GameState state;
  final Animation<double> mistakeShakeAnim;
  const _StatsRow(
      {required this.state, required this.mistakeShakeAnim});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Süre
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ZennColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Hata göstergesi — hata yapılınca sağa-sola sallanır
        AnimatedBuilder(
          animation: mistakeShakeAnim,
          builder: (_, child) {
            final offset =
                math.sin(mistakeShakeAnim.value * math.pi * 5) * 5.0;
            return Transform.translate(
                offset: Offset(offset, 0), child: child);
          },
          child: _MistakeRow(mistakes: state.mistakeCount),
        ),
        const Spacer(),
        // Kazanılacak elmas
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: ZennColors.cardLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomPaint(
                  size: const Size(13, 13),
                  painter: _GreenDiamondPainter()),
              const SizedBox(width: 5),
              Text(
                '+${state.puzzle.dailyId != null ? AppConstants.diamondsDaily : state.puzzle.difficulty.diamonds}',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: ZennColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Hata Satırı (animasyonlu ikonlar) ───────────────────────────────────────

class _MistakeRow extends StatelessWidget {
  final int mistakes;
  const _MistakeRow({required this.mistakes});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(AppConstants.maxMistakes, (i) {
        final active = i < mistakes;
        return Padding(
          padding: const EdgeInsets.only(right: 5),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: active ? 24 : 22,
            height: active ? 24 : 22,
            decoration: BoxDecoration(
              color: active
                  ? ZennColors.errorLight
                  : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? ZennColors.error
                    : ZennColors.gridLine,
                width: active ? 0 : 1.5,
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              size: active ? 14 : 13,
              color: active
                  ? ZennColors.error
                  : ZennColors.gridLine,
            ),
          ),
        );
      }),
    );
  }
}

class _GreenDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = ZennColors.primary
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(size.width * .5, 0)
      ..lineTo(size.width, size.height * .4)
      ..lineTo(size.width * .5, size.height)
      ..lineTo(0, size.height * .4)
      ..close();
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Tamamlama Modalı ─────────────────────────────────────────────────────────

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
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _diamondCtrl;

  late Animation<double> _scale;
  late Animation<double> _fade;
  late Animation<int> _diamondCount;

  late List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    // Konfeti partikülleri (sabit seed → tutarlı pattern)
    final rng = math.Random(42);
    const celebrationColors = [
      ZennColors.primary,
      ZennColors.primaryMid,
      Color(0xFFFFD700),
      Color(0xFFFF6B6B),
      Color(0xFF4ECDC4),
      Color(0xFFFFB347),
      Color(0xFFB19CD9),
    ];
    _particles = List.generate(40, (_) => _Particle(
      startX: rng.nextDouble() * 340,
      startY: -(rng.nextDouble() * 80 + 10),
      speedFactor: 0.25 + rng.nextDouble() * 0.5,
      size: 5.0 + rng.nextDouble() * 8,
      color: celebrationColors[rng.nextInt(celebrationColors.length)],
      isCircle: rng.nextBool(),
      oscFreq: 0.5 + rng.nextDouble() * 2.5,
      oscPhase: rng.nextDouble() * math.pi * 2,
      rotSpeed: 0.5 + rng.nextDouble() * 3,
    ));

    // Giriş animasyonu (scale + fade)
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween<double>(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(_entryCtrl);

    // Konfeti (3.5s sonra durur)
    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3500))
      ..forward();

    // Elmas sayım animasyonu (giriş bittikten sonra başlar)
    _diamondCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _diamondCount = IntTween(begin: 0, end: widget.diamonds).animate(
        CurvedAnimation(parent: _diamondCtrl, curve: Curves.easeOut));

    _entryCtrl.forward().then((_) => _diamondCtrl.forward());
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _confettiCtrl.dispose();
    _diamondCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // ── Konfeti katmanı ──────────────────────────────────────
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _confettiCtrl,
                    builder: (_, __) => CustomPaint(
                      painter: _ConfettiPainter(
                        progress: _confettiCtrl.value,
                        particles: _particles,
                      ),
                    ),
                  ),
                ),
                // ── Modal içeriği ────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Kupa ikonu
                      Container(
                        width: 90,
                        height: 90,
                        decoration: const BoxDecoration(
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
                      // Sonuç satırı (süre | hata | elmas sayımı)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: ZennColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _ResultStat(
                                label: 'Süre', value: widget.time),
                            _ResultStat(
                                label: 'Hata',
                                value: '${widget.mistakes}/3'),
                            // Elmas 0'dan kazanılan değere doğru sayar
                            AnimatedBuilder(
                              animation: _diamondCount,
                              builder: (_, __) => _ResultStat(
                                label: 'Elmas',
                                value: '+${_diamondCount.value}',
                                highlight: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ZennButton(
                          label: 'Ana Sayfaya Dön',
                          onTap: widget.onContinue),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: widget.onPlayAgain,
                        child: const Text('Tekrar Oyna'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Konfeti Partikülü Modeli ─────────────────────────────────────────────────

class _Particle {
  final double startX;
  final double startY;
  final double speedFactor;
  final double size;
  final Color color;
  final bool isCircle;
  final double oscFreq;
  final double oscPhase;
  final double rotSpeed;

  const _Particle({
    required this.startX,
    required this.startY,
    required this.speedFactor,
    required this.size,
    required this.color,
    required this.isCircle,
    required this.oscFreq,
    required this.oscPhase,
    required this.rotSpeed,
  });
}

// ─── Konfeti Painter ──────────────────────────────────────────────────────────

class _ConfettiPainter extends CustomPainter {
  final double progress;   // 0.0 → 1.0
  final List<_Particle> particles;

  const _ConfettiPainter(
      {required this.progress, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress * (1.0 + p.speedFactor)).clamp(0.0, 1.0);
      final y = p.startY + t * size.height * 1.4;
      if (y > size.height || y < -p.size) continue;

      final x = p.startX +
          math.sin(progress * math.pi * 2 * p.oscFreq + p.oscPhase) * 24;

      final opacity = (1.0 - progress * 0.55).clamp(0.0, 1.0);
      final paint = Paint()..color = p.color.withOpacity(opacity);

      if (p.isCircle) {
        canvas.drawCircle(Offset(x, y), p.size / 2, paint);
      } else {
        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(progress * math.pi * 2 * p.rotSpeed);
        canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.6),
          paint,
        );
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

// ─── Sonuç İstatistiği ────────────────────────────────────────────────────────

class _ResultStat extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _ResultStat(
      {required this.label,
      required this.value,
      this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color:
                highlight ? ZennColors.primary : ZennColors.textDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: ZennTextStyles.caption),
      ],
    );
  }
}