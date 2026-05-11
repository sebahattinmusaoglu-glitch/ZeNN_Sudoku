// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/l10n.dart';
import '../providers/game_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/sudoku_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final s = strings(context);

    return Scaffold(
      backgroundColor: ZennColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ──────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_greeting(context), style: ZennTextStyles.caption),
                        const SizedBox(height: 2),
                        profile.when(
                          data: (p) => Text(
                            p?.username ?? s.playerDefault,
                            style: ZennTextStyles.headline2,
                          ),
                          loading: () => const SizedBox(
                              height: 24,
                              width: 100,
                              child: LinearProgressIndicator()),
                          error: (_, __) => Text(s.playerDefault),
                        ),
                      ],
                    ),
                  ),
                  const DiamondBadge(large: true),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push(AppConstants.routeProfile),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ZennColors.cardMedium,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: profile.when(
                        data: (p) => p?.avatarUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(p!.avatarUrl!,
                                    fit: BoxFit.cover),
                              )
                            : const Icon(Icons.person_rounded,
                                color: ZennColors.primary, size: 22),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const Icon(Icons.person_rounded,
                            color: ZennColors.primary, size: 22),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── Günlük Sudoku Banner ────────────────────────────────────
              const _DailyBanner(),

              const SizedBox(height: 24),

              // ── Hızlı Oyun ─────────────────────────────────────────────
              Text(s.quickPlay, style: ZennTextStyles.headline3),
              const SizedBox(height: 14),
              const _DifficultyGrid(),

              const SizedBox(height: 24),

              // ── İstatistikler ───────────────────────────────────────────
              const _StatsSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(currentIndex: 0),
    );
  }

  String _greeting(BuildContext context) {
    final s = strings(context);
    final h = DateTime.now().hour;
    if (h < 12) return '${s.greetingMorning} 🌤';
    if (h < 17) return '${s.greetingAfternoon} ☀️';
    return '${s.greetingEvening} 🌙';
  }
}

// ─── Günlük Sudoku Banner ─────────────────────────────────────────────────────

class _DailyBanner extends ConsumerWidget {
  const _DailyBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(profileProvider);
    final s = strings(context);
    final locale = Localizations.localeOf(context).languageCode;
    final today = DateFormat('d MMMM', locale).format(DateTime.now());

    return GestureDetector(
      onTap: () => context.push(AppConstants.routeDaily),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF005235), Color(0xFF1A6B4A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: ZennColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      today,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    s.dailyBannerTitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 5),
                      Text(
                        SupabaseService.instance.isSignedIn
                            ? s.earnDiamonds.replaceFirst(
                                '{n}', '${AppConstants.diamondsDaily}')
                            : s.signInEarnDiamonds,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 72),
          ],
        ),
      ),
    );
  }
}

// ─── Zorluk Grid ─────────────────────────────────────────────────────────────

class _DifficultyGrid extends ConsumerWidget {
  const _DifficultyGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: Difficulty.values.map((d) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: d != Difficulty.hard ? 10 : 0,
            ),
            child: _DifficultyCard(difficulty: d),
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultyCard extends ConsumerStatefulWidget {
  final Difficulty difficulty;
  const _DifficultyCard({required this.difficulty});

  @override
  ConsumerState<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends ConsumerState<_DifficultyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _pressScale;

  // Sadece görsel config (renkler ve doluluk) — etiketler build'de strings(context)'ten alınır
  static const _config = {
    Difficulty.easy: (
      color: Color(0xFF1A6B4A),
      fillColor: Color(0xFFE8F5EE),
      accentColor: Color(0xFF1A6B4A),
      barFill: 0.33,
    ),
    Difficulty.medium: (
      color: Color(0xFF855A00),
      fillColor: Color(0xFFFFF3E0),
      accentColor: Color(0xFFE8A000),
      barFill: 0.66,
    ),
    Difficulty.hard: (
      color: Color(0xFFBA1A1A),
      fillColor: Color(0xFFFFEDED),
      accentColor: Color(0xFFBA1A1A),
      barFill: 1.0,
    ),
  };

  String _label(AppStrings s) {
    switch (widget.difficulty) {
      case Difficulty.easy:   return s.diffEasy;
      case Difficulty.medium: return s.diffMedium;
      case Difficulty.hard:   return s.diffHard;
    }
  }

  String _sub(AppStrings s) {
    switch (widget.difficulty) {
      case Difficulty.easy:   return s.diffEasySub;
      case Difficulty.medium: return s.diffMediumSub;
      case Difficulty.hard:   return s.diffHardSub;
    }
  }

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 90));
    _pressScale = Tween<double>(begin: 1.0, end: 0.94).animate(
        CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    final cfg = _config[widget.difficulty]!;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        _onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: _pressScale,
        builder: (_, child) =>
            Transform.scale(scale: _pressScale.value, child: child),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 16),
          decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: ZennColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seviye adı
              Text(
                _label(s),
                style: ZennTextStyles.headline3.copyWith(
                  color: cfg.color,
                ),
              ),
              const SizedBox(height: 2),
              Text(_sub(s), style: ZennTextStyles.caption),

              const SizedBox(height: 12),

              // Renkli seviye çubuğu
              _LevelBar(fill: cfg.barFill, color: cfg.accentColor),

              const SizedBox(height: 12),

              // Elmas ödülü
              Row(
                children: [
                  const Text('💎', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 4),
                  Text(
                    '+${widget.difficulty.diamonds}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cfg.accentColor,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    s.diamondsLabel,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cfg.accentColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onTap() async {
    // Async gap öncesinde strings'i al
    final s = strings(context);
    final notifier = ref.read(gameProvider.notifier);
    final prefs = await SharedPreferences.getInstance();
    final key = 'saved_game_${widget.difficulty.labelEn}';
    final raw = prefs.getString(key);

    if (raw != null) {
      if (!mounted) return;
      final resume = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(s.savedGameTitle),
          content: Text(s.savedGameBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(s.savedGameNew),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(s.savedGameContinue),
            ),
          ],
        ),
      );

      if (resume == true) {
        await notifier.loadProgress(widget.difficulty);
      } else {
        await notifier.clearProgress(widget.difficulty);
        final puzzle = SudokuGenerator.generate(widget.difficulty);
        notifier.startGame(puzzle);
      }
    } else {
      final puzzle = SudokuGenerator.generate(widget.difficulty);
      notifier.startGame(puzzle);
    }

    if (!mounted) return;
    context.push(AppConstants.routeGame);
  }
}

// ─── Seviye Çubuğu ────────────────────────────────────────────────────────────

class _LevelBar extends StatelessWidget {
  final double fill;
  final Color color;
  const _LevelBar({required this.fill, required this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final totalW = constraints.maxWidth;
        const segCount = 3;
        const gap = 3.0;
        final segW = (totalW - gap * (segCount - 1)) / segCount;
        final filledCount = (fill * segCount).round();

        return Row(
          children: List.generate(segCount, (i) {
            final filled = i < filledCount;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: segW,
                  height: 5,
                  decoration: BoxDecoration(
                    color: filled ? color : color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (i < segCount - 1) const SizedBox(width: gap),
              ],
            );
          }),
        );
      },
    );
  }
}

// ─── İstatistik Bölümü ────────────────────────────────────────────────────────

class _StatsSection extends ConsumerWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = strings(context);
    final stats = ref.watch(completionStatsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.statsTitle, style: ZennTextStyles.headline3),
        const SizedBox(height: 14),
        stats.when(
          data: (st) => Row(
            children: [
              _StatTile(label: s.statsEasy,   count: st['easy']   ?? 0, color: ZennColors.easy),
              const SizedBox(width: 10),
              _StatTile(label: s.statsMedium, count: st['medium'] ?? 0, color: ZennColors.medium),
              const SizedBox(width: 10),
              _StatTile(label: s.statsHard,   count: st['hard']   ?? 0, color: ZennColors.hard),
              const SizedBox(width: 10),
              _StatTile(label: s.statsDaily,  count: st['daily']  ?? 0, color: ZennColors.daily),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StatTile(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ZennColors.border),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: ZennTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ZennColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                iconFilled: Icons.grid_view_rounded,
                label: s.navHome,
                active: currentIndex == 0,
                onTap: () => context.go(AppConstants.routeHome),
              ),
              _NavItem(
                icon: Icons.calendar_today_outlined,
                iconFilled: Icons.calendar_today_rounded,
                label: s.navDaily,
                active: currentIndex == 1,
                onTap: () => context.push(AppConstants.routeDaily),
              ),
              _NavItem(
                icon: Icons.person_outline_rounded,
                iconFilled: Icons.person_rounded,
                label: s.navProfile,
                active: currentIndex == 2,
                onTap: () => context.push(AppConstants.routeProfile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData iconFilled;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.iconFilled,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? ZennColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                active ? iconFilled : icon,
                key: ValueKey(active),
                size: 26,
                color: active ? ZennColors.primary : ZennColors.textHint,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? ZennColors.primary : ZennColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}