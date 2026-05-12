// lib/screens/game_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/l10n.dart';
import '../providers/game_provider.dart';
import '../widgets/sudoku_grid.dart';
import '../widgets/number_pad.dart';
import '../widgets/common_widgets.dart';
import '../services/ad_service.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});
  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _mistakeShakeCtrl;
  late Animation<double>   _mistakeShakeAnim;
  final _bannerKey = UniqueKey();
  bool _isBannerLoaded = false;

  @override
  void initState() {
    super.initState();

    _mistakeShakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _mistakeShakeAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_mistakeShakeCtrl);

    AdService.instance.loadBanner(
      onLoaded: () {
        if (mounted) setState(() => _isBannerLoaded = true);
      },
    );
    _loadRewarded();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(gameProvider, (prev, next) {
        if (prev?.isComplete == false && next?.isComplete == true) {
          _onComplete();
        }
        if (prev != null && next != null &&
            next.mistakeCount > prev.mistakeCount) {
          _mistakeShakeCtrl.forward(from: 0);
          if (ref.read(hapticEnabledProvider)) HapticFeedback.mediumImpact();

          // 3 hata → Kolay dışında oyun biter
          final difficulty = next.puzzle.difficulty;
          final isDaily    = next.puzzle.dailyId != null;
          final isEasy     = difficulty == Difficulty.easy && !isDaily;
          if (!isEasy && next.mistakeCount >= AppConstants.maxMistakes) {
            _showGameOverDialog();
          }
        }
      });
      final state = ref.read(gameProvider);
      if (state != null && state.isPaused) {
        ref.read(gameProvider.notifier).togglePause();
      }
    });
  }

  Future<void> _loadRewarded() async {
    await AdService.instance.loadRewarded();
  }

  @override
  void dispose() {
    _mistakeShakeCtrl.dispose();
    AdService.instance.dispose();
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

  void _showGameOverDialog() {
    final s = strings(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Text('❌', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Text(s.gameOverTitle,
              style: const TextStyle(
                  fontFamily: 'Inter', fontWeight: FontWeight.w700)),
        ]),
        content: Text(s.gameOverBody,
            style: const TextStyle(fontFamily: 'Inter', fontSize: 14, height: 1.5)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppConstants.routeHome);
            },
            child: Text(s.gameCompleteGoHome,
                style: const TextStyle(color: ZennColors.textSoft)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ZennColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Aynı bulmacayı sıfırla
              final state = ref.read(gameProvider);
              if (state != null) {
                ref.read(gameProvider.notifier).restartGame();
              }
            },
            child: Text(s.gameOverTryAgain,
                style: const TextStyle(
                    fontFamily: 'Inter', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
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
          diamonds:    diamonds,
          time:        state.elapsedFormatted,
          mistakes:    state.mistakeCount,
          difficulty:  state.puzzle.difficulty,
          onContinue:  () { Navigator.pop(context); context.go(AppConstants.routeHome); },
          onPlayAgain: () { Navigator.pop(context); context.go(AppConstants.routeHome); },
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
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              _TopBar(state: state),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: _mistakeShakeAnim,
                builder: (_, child) {
                  final offset =
                      math.sin(_mistakeShakeAnim.value * math.pi * 5) * 5.0;
                  return Transform.translate(
                      offset: Offset(offset, 0), child: child);
                },
                child: _StatsRow(state: state),
              ),
              const SizedBox(height: 20),
              Stack(
                children: [
                  const SudokuGrid(),
                  if (state.isPaused && !state.isComplete)
                    Positioned.fill(child: _PauseOverlay()),
                  if (state.isComplete)
                    Positioned.fill(
                      child: _CompletedOverlay(
                        diamonds: state.puzzle.dailyId != null
                            ? AppConstants.diamondsDaily
                            : state.puzzle.difficulty.diamonds,
                        onNewGame: () => context.go(AppConstants.routeHome),
                      ),
                    ),
                ],
              ),
              const NumberPad(),
              const Spacer(),
              SafeArea(
                top: false,
                child: _BannerAdWidget(key: _bannerKey, isLoaded: _isBannerLoaded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Banner Ad ────────────────────────────────────────────────────────────────

class _BannerAdWidget extends StatelessWidget {
  final bool isLoaded;
  const _BannerAdWidget({super.key, required this.isLoaded});

  @override
  Widget build(BuildContext context) {
    if (!isLoaded || AdService.instance.bannerAd == null) {
      return const SizedBox(height: 70);
    }
    return SizedBox(
      width:  AdService.instance.bannerAd!.size.width.toDouble(),
      height: AdService.instance.bannerAd!.size.height.toDouble(),
      child:  AdWidget(ad: AdService.instance.bannerAd!),
    );
  }
}

// ─── Pause Overlay ────────────────────────────────────────────────────────────

class _PauseOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return Container(
      decoration: BoxDecoration(
        color: ZennColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_outline_rounded,
                size: 56, color: Colors.white),
            const SizedBox(height: 12),
            Text(s.gamePaused,
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 20,
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 6),
            Text(s.gamePausedHint,
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 13, color: Colors.white70)),
          ],
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
    final s = strings(context);

    final title = state.puzzle.dailyId != null
        ? s.dailyTitle
        : '${_diffLabel(state.puzzle.difficulty, s)} Sudoku';

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: ZennColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: ZennColors.textDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: ZennTextStyles.headline3)),
        GestureDetector(
          onTap: () {
            if (ref.read(hapticEnabledProvider)) HapticFeedback.lightImpact();
            ref.read(gameProvider.notifier).togglePause();
          },
          child: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
                color: ZennColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(
              state.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              size: 22, color: ZennColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  String _diffLabel(Difficulty d, AppStrings s) {
    switch (d) {
      case Difficulty.easy:   return s.diffEasy;
      case Difficulty.medium: return s.diffMedium;
      case Difficulty.hard:   return s.diffHard;
    }
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
        // Süre
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ZennColors.border),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.timer_outlined,
                size: 16, color: ZennColors.textSoft),
            const SizedBox(width: 5),
            Text(state.elapsedFormatted,
                style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 14,
                    fontWeight: FontWeight.w600, color: ZennColors.textDark)),
          ]),
        ),
        const SizedBox(width: 10),
        // Hata göstergesi — seviyeye göre farklı
        _MistakeIndicator(
          mistakes:   state.mistakeCount,
          difficulty: state.puzzle.difficulty,
          isDaily:    state.puzzle.dailyId != null,
        ),
        const Spacer(),
        // Elmas ödülü
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: ZennColors.cardLight,
              borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('💎', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              '+${state.puzzle.dailyId != null ? AppConstants.diamondsDaily : state.puzzle.difficulty.diamonds}',
              style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w700, color: ZennColors.primary),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─── Hata Göstergesi ─────────────────────────────────────────────────────────

class _MistakeIndicator extends StatelessWidget {
  final int mistakes;
  final Difficulty difficulty;
  final bool isDaily;
  const _MistakeIndicator({
    required this.mistakes,
    required this.difficulty,
    required this.isDaily,
  });

  @override
  Widget build(BuildContext context) {
    // Kolay seviyede (günlük hariç): sınırsız hata, sadece sayaç
    final isEasy = difficulty == Difficulty.easy && !isDaily;

    if (isEasy) {
      // Kalem ikonu + hata sayısı
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: mistakes > 0 ? ZennColors.errorLight : ZennColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: mistakes > 0 ? ZennColors.error.withOpacity(0.3) : ZennColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.edit_outlined,
              size: 15,
              color: mistakes > 0 ? ZennColors.error : ZennColors.textSoft),
          const SizedBox(width: 5),
          Text(
            '$mistakes',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: mistakes > 0 ? ZennColors.error : ZennColors.textDark),
          ),
        ]),
      );
    }

    // Orta / Zor / Günlük: 3 X ikonu (mevcut davranış)
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
              color: active ? ZennColors.errorLight : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: active ? ZennColors.error : ZennColors.gridLine,
                  width: active ? 0 : 1.5),
            ),
            child: Icon(Icons.close_rounded,
                size: active ? 14 : 13,
                color: active ? ZennColors.error : ZennColors.gridLine),
          ),
        );
      }),
    );
  }
}

// ─── Completed Overlay ────────────────────────────────────────────────────────

class _CompletedOverlay extends StatefulWidget {
  final int diamonds;
  final VoidCallback onNewGame;
  const _CompletedOverlay({required this.diamonds, required this.onNewGame});

  @override
  State<_CompletedOverlay> createState() => _CompletedOverlayState();
}

class _CompletedOverlayState extends State<_CompletedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _fade  = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _slide = Tween<double>(begin: 20.0, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(0, _slide.value),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 44)),
                    const SizedBox(height: 10),
                    Text(s.gameCompleteTitle,
                        style: ZennTextStyles.headline2,
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      s.gameCompletedBody
                          .replaceFirst('{n}', '${widget.diamonds}'),
                      style: ZennTextStyles.body.copyWith(height: 1.6),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: widget.onNewGame,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 28, vertical: 12),
                        decoration: BoxDecoration(
                            color: ZennColors.primary,
                            borderRadius: BorderRadius.circular(12)),
                        child: Text(s.gameStartNew,
                            style: const TextStyle(
                                fontFamily: 'Inter', fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
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
    required this.diamonds, required this.time, required this.mistakes,
    required this.difficulty, required this.onContinue, required this.onPlayAgain,
  });

  @override
  State<_CompleteModal> createState() => _CompleteModalState();
}

class _CompleteModalState extends State<_CompleteModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _scale = Tween(begin: 0.8, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade  = Tween(begin: 0.0, end: 1.0).animate(_ctrl);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: ScaleTransition(
          scale: _scale,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                      color: ZennColors.cardGreen, shape: BoxShape.circle),
                  child: const Icon(Icons.workspace_premium_rounded,
                      size: 50, color: ZennColors.primary),
                ),
                const SizedBox(height: 20),
                Text(s.gameCompleteTitle,
                    style: ZennTextStyles.headline1,
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(s.gameCompleteSubtitle,
                    style: ZennTextStyles.body, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: ZennColors.background,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ResultStat(label: s.gameCompleteTime,      value: widget.time),
                      _ResultStat(label: s.gameCompleteMistakes,  value: '${widget.mistakes}/3'),
                      _ResultStat(label: s.gameCompleteDiamonds,  value: '+${widget.diamonds}', highlight: true),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ZennButton(label: s.gameCompleteGoHome, onTap: widget.onContinue),
                const SizedBox(height: 10),
                TextButton(
                    onPressed: widget.onPlayAgain,
                    child: Text(s.gameCompletePlayAgain)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultStat extends StatelessWidget {
  final String label, value;
  final bool highlight;
  const _ResultStat(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w700,
              color: highlight ? ZennColors.primary : ZennColors.textDark)),
      const SizedBox(height: 2),
      Text(label, style: ZennTextStyles.caption),
    ]);
  }
}