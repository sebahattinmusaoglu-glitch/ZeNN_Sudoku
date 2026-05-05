// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';
import '../widgets/common_widgets.dart';
import '../services/sudoku_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: ZennColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // ── Header ──────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: ZennTextStyles.caption,
                        ),
                        const SizedBox(height: 2),
                        profile.when(
                          data: (p) => Text(
                            p?.username ?? 'Oyuncu',
                            style: ZennTextStyles.headline2,
                          ),
                          loading: () => const SizedBox(height: 24, width: 100,
                              child: LinearProgressIndicator()),
                          error: (_, __) => const Text('Oyuncu'),
                        ),
                      ],
                    ),
                  ),
                  const DiamondBadge(large: true),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => context.push(AppConstants.routeProfile),
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: ZennColors.cardMedium,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: profile.when(
                        data: (p) => p?.avatarUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(p!.avatarUrl!, fit: BoxFit.cover),
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

              // ── Daily Puzzle Banner ──────────────────────────────────
              _DailyBanner(),

              const SizedBox(height: 24),

              // ── Quick Play ───────────────────────────────────────────
              Text('Hızlı Oyun', style: ZennTextStyles.headline3),
              const SizedBox(height: 14),
              _DifficultyGrid(),

              const SizedBox(height: 24),

              // ── Stats ─────────────────────────────────────────────────
              _StatsSection(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(currentIndex: 0),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Günaydın 🌤';
    if (h < 17) return 'İyi günler ☀️';
    return 'İyi akşamlar 🌙';
  }
}

// ─── Daily Puzzle Banner ──────────────────────────────────────────────────────

class _DailyBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyPuzzleProvider);
    final today = DateFormat('d MMMM', 'tr').format(DateTime.now());

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
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      today,
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 12,
                        fontWeight: FontWeight.w500, color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Günün Sudokusu',
                    style: TextStyle(
                      fontFamily: 'Inter', fontSize: 22,
                      fontWeight: FontWeight.w700, color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const _DiamondWhite(),
                      const SizedBox(width: 5),
                      Text(
                        '+${AppConstants.diamondsDaily} elmas',
                        style: TextStyle(
                          fontFamily: 'Inter', fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Mini preview sudoku or stars icon
            _StarBurst(),
          ],
        ),
      ),
    );
  }
}

class _DiamondWhite extends StatelessWidget {
  const _DiamondWhite();
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(14, 14),
      painter: _WhiteDiamondPainter(),
    );
  }
}

class _WhiteDiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.white..style = PaintingStyle.fill;
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

class _StarBurst extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.workspace_premium_rounded,
        color: Colors.white, size: 72);
  }
}

// ─── Difficulty Grid ─────────────────────────────────────────────────────────

class _DifficultyGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: Difficulty.values.map((d) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: d != Difficulty.hard ? 8 : 0,
            ),
            child: _DifficultyCard(difficulty: d),
          ),
        );
      }).toList(),
    );
  }
}

class _DifficultyCard extends ConsumerWidget {
  final Difficulty difficulty;
  const _DifficultyCard({required this.difficulty});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (emoji, desc) = switch (difficulty) {
      Difficulty.easy   => ('🟢', 'Başlangıç'),
      Difficulty.medium => ('🟡', 'Orta Seviye'),
      Difficulty.hard   => ('🔴', 'Uzman'),
    };

    return GestureDetector(
      onTap: () async {
        final notifier = ref.read(gameProvider.notifier);
        final prefs = await SharedPreferences.getInstance();
        final key = 'saved_game_${difficulty.labelEn}';
        final raw = prefs.getString(key);

        if (raw != null) {
          if (!context.mounted) return;
          final resume = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Kayıtlı Oyun'),
              content: const Text('Kaldığın yerden devam etmek ister misin?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Yeni Oyun'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Devam Et'),
                ),
              ],
            ),
          );

          if (resume == true) {
            await notifier.loadProgress(difficulty);
          } else {
            await notifier.clearProgress(difficulty);
            final puzzle = SudokuGenerator.generate(difficulty);
            notifier.startGame(puzzle);
          }
        } else {
          final puzzle = SudokuGenerator.generate(difficulty);
          notifier.startGame(puzzle);
        }

        if (!context.mounted) return;
        context.push(AppConstants.routeGame);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 10),
            Text(difficulty.label, style: ZennTextStyles.headline3),
            const SizedBox(height: 2),
            Text(desc, style: ZennTextStyles.caption),
            const SizedBox(height: 10),
            Row(
              children: [
                CustomPaint(size: const Size(11, 11),
                    painter: _SmallDiamondPainter()),
                const SizedBox(width: 3),
                Text(
                  '+${difficulty.diamonds}',
                  style: const TextStyle(
                    fontFamily: 'Inter', fontSize: 12,
                    fontWeight: FontWeight.w600, color: ZennColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallDiamondPainter extends CustomPainter {
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

// ─── Stats Section ────────────────────────────────────────────────────────────

class _StatsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(completionStatsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('İstatistikler', style: ZennTextStyles.headline3),
        const SizedBox(height: 14),
        stats.when(
          data: (s) => Row(
            children: [
              _StatTile(label: 'Kolay',  count: s['easy']   ?? 0, color: ZennColors.easy),
              const SizedBox(width: 10),
              _StatTile(label: 'Orta',   count: s['medium'] ?? 0, color: ZennColors.medium),
              const SizedBox(width: 10),
              _StatTile(label: 'Zor',    count: s['hard']   ?? 0, color: ZennColors.hard),
              const SizedBox(width: 10),
              _StatTile(label: 'Günlük', count: s['daily']  ?? 0, color: ZennColors.daily),
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
  const _StatTile({required this.label, required this.count, required this.color});

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
                fontFamily: 'Inter', fontSize: 22,
                fontWeight: FontWeight.w700, color: color,
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

// ─── Bottom Nav ────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  const _BottomNav({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ZennColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(icon: Icons.grid_view_rounded,   label: 'Ana Sayfa', active: currentIndex == 0, onTap: () => context.go(AppConstants.routeHome)),
              _NavItem(icon: Icons.calendar_today_rounded, label: 'Günlük',    active: currentIndex == 1, onTap: () => context.push(AppConstants.routeDaily)),
              _NavItem(icon: Icons.person_rounded,      label: 'Profil',    active: currentIndex == 2, onTap: () => context.push(AppConstants.routeProfile)),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavItem({required this.icon, required this.label,
      required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 26,
              color: active ? ZennColors.primary : ZennColors.textHint),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter', fontSize: 11,
              fontWeight: FontWeight.w500,
              color: active ? ZennColors.primary : ZennColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
