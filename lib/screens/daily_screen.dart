// lib/screens/daily_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../models/puzzle.dart';
import '../providers/game_provider.dart';
import '../services/supabase_service.dart';
import '../services/sudoku_generator.dart';
import '../widgets/common_widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';


class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});
  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

class _DailyScreenState extends ConsumerState<DailyScreen> {
  Set<String> _completedDates = {};
  bool _loadingCalendar = true;
  int _totalPuzzleDays = 0;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  Future<void> _loadCalendar() async {
    final now = DateTime.now();
    final completed = await SupabaseService.instance
        .getMonthlyCompletions(now.year, now.month);
    
    // Kaç günlük puzzle eklenmiş
    final totalPuzzles = await SupabaseService.instance
        .getMonthlyPuzzleCount(now.year, now.month);
    
    if (mounted) {
      setState(() {
        _completedDates  = completed;
        _totalPuzzleDays = totalPuzzles;
        _loadingCalendar = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final daily = ref.watch(dailyPuzzleProvider);
    final now   = DateTime.now();

    return Scaffold(
      backgroundColor: ZennColors.background,
      appBar: AppBar(
        title: const Text('Günün Sudokusu'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: DiamondBadge(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Today's Puzzle Card ──────────────────────────────────
            daily.when(
              data: (puzzle) => puzzle != null
                  ? _TodayCard(puzzle: puzzle)
                  : const _NoPuzzleCard(),
              loading: () => const _PuzzleCardSkeleton(),
              error: (_, __) => const _NoPuzzleCard(),
            ),

            const SizedBox(height: 28),

            // ── Monthly Calendar ─────────────────────────────────────
            Row(
              children: [
                Text(
                  DateFormat('MMMM yyyy', 'tr').format(now),
                  style: ZennTextStyles.headline3,
                ),
                const Spacer(),
                // Monthly bonus info
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ZennColors.cardLight,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded,
                          size: 14, color: ZennColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Bonus: +${AppConstants.diamondsMonthly} 💎',
                        style: const TextStyle(
                          fontFamily: 'Inter', fontSize: 11,
                          fontWeight: FontWeight.w600, color: ZennColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        const SizedBox(height: 14),

            // Monthly progress
            _MonthlyProgress(
              completedCount: _completedDates.length,
              totalDays: _totalPuzzleDays,
            ),

            const SizedBox(height: 16),

            _loadingCalendar
                ? const LinearProgressIndicator()
                : _MonthCalendar(
                    year: now.year,
                    month: now.month,
                    completedDates: _completedDates,
                    today: now,
                  ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Today's Puzzle Card ──────────────────────────────────────────────────────

class _TodayCard extends ConsumerWidget {
  final DailyPuzzle puzzle;
  const _TodayCard({required this.puzzle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<bool>>(
      future: Future.wait([
      SupabaseService.instance.hasDailyCompleted(puzzle.id),
      SharedPreferences.getInstance().then((p) => p.getString('saved_game_daily') != null),
    ]),
    builder: (context, snap) {
        final isCompleted = snap.data?[0] ?? false;
        final hasSavedGame = snap.data?[1] ?? false;

        return Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF005235), Color(0xFF1A6B4A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('d MMMM yyyy', 'tr').format(puzzle.date),
                          style: const TextStyle(
                            fontFamily: 'Inter', fontSize: 13,
                            color: Colors.white70, fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Günün Sudokusu',
                          style: TextStyle(
                            fontFamily: 'Inter', fontSize: 22,
                            fontWeight: FontWeight.w700, color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Tamamlandı',
                              style: TextStyle(
                                fontFamily: 'Inter', fontSize: 12,
                                fontWeight: FontWeight.w500, color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              // Reward row
              Row(
                children: [
                  _RewardChip(
                    icon: Icons.diamond_outlined,
                    label: '+${AppConstants.diamondsDaily} Elmas',
                  ),
                  const SizedBox(width: 8),
                  _RewardChip(
                    icon: Icons.stars_rounded,
                    label: 'Aylık Bonusa Katıl',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!isCompleted)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final raw = prefs.getString('saved_game_daily');
                      
                      final p = SudokuPuzzle.fromStrings(
                        puzzleStr:   puzzle.puzzle,
                        solutionStr: puzzle.solution,
                        difficulty:  Difficulty.hard,
                        dailyId:     puzzle.id,
                        date:        puzzle.date,
                      );

                      if (raw != null) {
                        await ref.read(gameProvider.notifier).loadProgress(Difficulty.hard, isDaily: true);
                      } else {
                        ref.read(gameProvider.notifier).startGame(p);
                      }
                      
                      if (!context.mounted) return;
                      context.push(AppConstants.routeGame);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: ZennColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      hasSavedGame ? 'Devam Et' : 'Şimdi Oyna',
                      style: const TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Bugün tamamlandı ✓',
                      style: TextStyle(
                        fontFamily: 'Inter', fontSize: 16,
                        fontWeight: FontWeight.w600, color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _RewardChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(
            fontFamily: 'Inter', fontSize: 12,
            fontWeight: FontWeight.w500, color: Colors.white,
          )),
        ],
      ),
    );
  }
}

class _NoPuzzleCard extends StatelessWidget {
  const _NoPuzzleCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: ZennColors.cardMedium,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text('Bugün için bulmaca hazır değil. Yakında!',
            textAlign: TextAlign.center,
            style: ZennTextStyles.body),
      ),
    );
  }
}

class _PuzzleCardSkeleton extends StatelessWidget {
  const _PuzzleCardSkeleton();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: ZennColors.cardMedium,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

// ─── Month Calendar ───────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Set<String> completedDates;
  final DateTime today;

  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.completedDates,
    required this.today,
  });

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTimeRange(
      start: DateTime(year, month),
      end:   DateTime(year, month + 1),
    ).duration.inDays;

    final firstWeekday = DateTime(year, month, 1).weekday; // 1=Mon
    final offset = firstWeekday - 1; // cells before day 1

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ZennColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZennColors.border),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: ['Pt','Sa','Ça','Pe','Cu','Ct','Pz'].map((d) =>
              Expanded(
                child: Center(
                  child: Text(d, style: ZennTextStyles.caption.copyWith(
                    fontWeight: FontWeight.w600)),
                ),
              ),
            ).toList(),
          ),
          const SizedBox(height: 10),
          // Day grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: offset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox.shrink();
              final day = i - offset + 1;
              final dateStr = '${year.toString().padLeft(4,'0')}-'
                  '${month.toString().padLeft(2,'0')}-'
                  '${day.toString().padLeft(2,'0')}';
              final isToday     = day == today.day;
              final isCompleted = completedDates.contains(dateStr);
              final isFuture    = day > today.day;

              return _CalendarDay(
                day: day,
                isToday: isToday,
                isCompleted: isCompleted,
                isFuture: isFuture,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isCompleted;
  final bool isFuture;
  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color textColor;

    if (isCompleted) {
      bg        = ZennColors.primary;
      textColor = Colors.white;
    } else if (isToday) {
      bg        = ZennColors.cardLight;
      textColor = ZennColors.primary;
    } else if (isFuture) {
      bg        = Colors.transparent;
      textColor = ZennColors.textHint;
    } else {
      bg        = ZennColors.surfaceAlt;
      textColor = ZennColors.textMid;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: isToday && !isCompleted
            ? Border.all(color: ZennColors.primary, width: 1.5)
            : null,
      ),
      child: Center(
        child: Text(
          day.toString(),
          style: TextStyle(
            fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ─── Monthly Progress ─────────────────────────────────────────────────────────

class _MonthlyProgress extends StatelessWidget {
  final int completedCount;
  final int totalDays;
  const _MonthlyProgress({
    required this.completedCount,
    required this.totalDays,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalDays > 0 ? completedCount / totalDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZennColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZennColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aylık İlerleme',
                  style: ZennTextStyles.bodyMedium.copyWith(
                      color: ZennColors.textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  '$completedCount / $totalDays gün tamamlandı',
                  style: ZennTextStyles.caption,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: ZennColors.border,
                    valueColor: const AlwaysStoppedAnimation(ZennColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: ZennColors.cardLight,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Inter', fontSize: 13,
                  fontWeight: FontWeight.w700, color: ZennColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
