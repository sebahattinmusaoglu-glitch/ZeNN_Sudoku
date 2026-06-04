// lib/screens/daily_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../core/l10n.dart';
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
  bool _calendarLoaded = false;
  int _totalPuzzleDays = 0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadCalendar();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (SupabaseService.instance.isSignedIn && !_calendarLoaded) {
      _loadCalendar();
    }
  }

Future<void> _loadCalendar() async {
  try {
    final now       = DateTime.now();
    final completed = await SupabaseService.instance
        .getMonthlyCompletions(now.year, now.month);

    // DEBUG — sonuçları görmek için
    print('>>> completed dates: $completed');
    print('>>> streak: ${_calcStreak(completed, now)}');

    final totalPuzzles = await SupabaseService.instance
        .getMonthlyPuzzleCount(now.year, now.month);
    if (mounted) {
      setState(() {
        _completedDates  = completed;
        _totalPuzzleDays = totalPuzzles;
        _currentStreak   = _calcStreak(completed, now);
        _loadingCalendar = false;
        _calendarLoaded  = true;
      });
    }
  } catch (e) {
    print('>>> _loadCalendar HATA: $e'); // ← hatayı görmek için
    if (mounted) {
      setState(() {
        _loadingCalendar = false;
        _calendarLoaded  = true;
      });
    }
  }
}

  int _calcStreak(Set<String> completed, DateTime now) {
    int streak = 0;
    final todayKey = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    DateTime cursor = completed.contains(todayKey)
        ? now
        : now.subtract(const Duration(days: 1));
    while (true) {
      final key = '${cursor.year.toString().padLeft(4, '0')}-'
          '${cursor.month.toString().padLeft(2, '0')}-'
          '${cursor.day.toString().padLeft(2, '0')}';
      if (!completed.contains(key)) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final s = strings(context);

    ref.listen(profileProvider, (prev, next) {
      final wasSignedIn = prev?.valueOrNull != null;
      final isSignedIn = next.valueOrNull != null;
      if (!wasSignedIn && isSignedIn) _loadCalendar();
    });

    final daily = ref.watch(dailyPuzzleProvider);
    final now = DateTime.now();
    final isSignedIn = ref.watch(profileProvider).valueOrNull != null;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: ZennColors.background,
      appBar: AppBar(
        title: Text(s.dailyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: const [
          Padding(padding: EdgeInsets.only(right: 16), child: DiamondBadge()),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── Seri alanı ───────────────────────────────────────────
            if (isSignedIn)
              _StreakHero(streak: _currentStreak, loading: _loadingCalendar)
            else
              const _SignInStreakBanner(),

            const SizedBox(height: 16),

            // ── Bugünü Oyna ──────────────────────────────────────────
            daily.when(
              data: (puzzle) => puzzle != null
                  ? _TodayCard(puzzle: puzzle)
                  : const _NoPuzzleCard(),
              loading: () => const _PuzzleCardSkeleton(),
              error: (_, __) => const _NoPuzzleCard(),
            ),

            // ── Takvim + İlerleme (sadece giriş yapılmışsa) ──────────
            if (isSignedIn) ...[
              const SizedBox(height: 28),
              Row(
                children: [
                  Text(
                    DateFormat('MMMM yyyy', locale).format(now),
                    style: ZennTextStyles.headline3,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                          s.dailyBonusChip.replaceFirst(
                              '{n}', '${AppConstants.diamondsMonthly}'),
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ZennColors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
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
                      today: now),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ─── Giriş Yapılmamış Banner ──────────────────────────────────────────────────

class _SignInStreakBanner extends ConsumerWidget {
  const _SignInStreakBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = strings(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: ZennColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZennColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
                color: ZennColors.surfaceAlt, shape: BoxShape.circle),
            child:
                const Center(child: Text('🔒', style: TextStyle(fontSize: 30))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.streakSignInTitle, style: ZennTextStyles.headline3),
                const SizedBox(height: 6),
                Text(
                  s.streakSignInBody
                      .replaceFirst('{n}', '${AppConstants.diamondsMonthly}'),
                  style: ZennTextStyles.caption.copyWith(height: 1.5),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () => context.push(AppConstants.routeAuth),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(
                        color: ZennColors.primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.g_mobiledata,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(s.authSignIn,
                            style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ],
                    ),
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

// ─── Seri Hero ────────────────────────────────────────────────────────────────

class _StreakHero extends StatelessWidget {
  final int streak;
  final bool loading;
  const _StreakHero({required this.streak, this.loading = false});

  @override
  Widget build(BuildContext context) {
    final s = strings(context);

    if (loading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
        decoration: BoxDecoration(
            color: ZennColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: ZennColors.border)),
        child: Row(children: [
          const SizedBox(width: 72, height: 72),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(
              width: 120,
              height: 16,
              child: LinearProgressIndicator(
                  backgroundColor: ZennColors.border,
                  valueColor: AlwaysStoppedAnimation(ZennColors.primary)),
            ),
            const SizedBox(height: 8),
            Text(s.streakUpdating,
                style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: ZennColors.textHint)),
          ]),
        ]),
      );
    }

    final hasStreak = streak > 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: ZennColors.border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: hasStreak
                  ? ZennColors.primary.withOpacity(0.08)
                  : ZennColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(hasStreak ? '🔥' : '💤',
                  style: const TextStyle(fontSize: 26)),
              Text('$streak',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: hasStreak
                          ? ZennColors.primary
                          : ZennColors.textHint)),
            ]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                hasStreak
                    ? s.streakCurrentDays.replaceFirst('{n}', '$streak')
                    : s.streakBeginTitle,
                style: ZennTextStyles.headline3.copyWith(
                    color:
                        hasStreak ? ZennColors.primary : ZennColors.textDark),
              ),
              const SizedBox(height: 5),
              Text(
                hasStreak ? _streakMessage(streak, s) : s.streakBeginBody,
                style: ZennTextStyles.caption.copyWith(height: 1.5),
              ),
              if (hasStreak) ...[
                const SizedBox(height: 10),
                _StreakMiniBar(streak: streak),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  String _streakMessage(int streak, AppStrings s) {
    if (streak >= 30) return s.streakMsg30;
    if (streak >= 14) return s.streakMsg14;
    if (streak >= 7) return s.streakMsg7;
    if (streak >= 3) return s.streakMsg3;
    return s.streakMsg1;
  }
}

class _StreakMiniBar extends StatelessWidget {
  final int streak;
  const _StreakMiniBar({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(7, (i) {
        final filled = i < streak.clamp(0, 7);
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 22,
            height: 6,
            decoration: BoxDecoration(
              color: filled
                  ? ZennColors.primary
                  : ZennColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}

// ─── Today Card ───────────────────────────────────────────────────────────────

class _TodayCard extends ConsumerWidget {
  final DailyPuzzle puzzle;
  const _TodayCard({required this.puzzle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = strings(context);
    return FutureBuilder<List<dynamic>>(
      future: Future.wait([
        SupabaseService.instance.hasDailyCompleted(puzzle.id),
        SharedPreferences.getInstance()
            .then((p) => p.getString('saved_game_daily') != null),
      ]),
      builder: (context, snap) {
        final isCompleted = snap.data?[0] as bool? ?? false;
        final hasSavedGame = snap.data?[1] as bool? ?? false;
        final isSignedIn = ref.watch(profileProvider).valueOrNull != null;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isCompleted ? ZennColors.cardLight : ZennColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? ZennColors.primary.withOpacity(0.1)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : Icons.grid_on_rounded,
                  color: isCompleted ? ZennColors.primary : Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCompleted ? s.todayCompleted : s.todayPuzzle,
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? ZennColors.primary
                                : Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCompleted
                            ? s.todayDiamondsEarned.replaceFirst(
                                '{n}', '${AppConstants.diamondsDaily}')
                            : !isSignedIn
                                ? s.todaySignInEarn
                                : hasSavedGame
                                    ? s.dailyContinue
                                    : s.todayDiamondsBonus.replaceFirst(
                                        '{n}', '${AppConstants.diamondsDaily}'),
                        style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isCompleted
                                ? ZennColors.primary.withOpacity(0.7)
                                : Colors.white.withOpacity(0.8)),
                      ),
                    ]),
              ),
              if (!isCompleted)
                GestureDetector(
                  onTap: () async {
                    final p = SudokuPuzzle.fromStrings(
                      puzzleStr: puzzle.puzzle,
                      solutionStr: puzzle.solution,
                      difficulty: Difficulty.hard,
                      dailyId: puzzle.id,
                      date: puzzle.date,
                    );
                    if (hasSavedGame) {
                      await ref
                          .read(gameProvider.notifier)
                          .loadProgress(Difficulty.hard, isDaily: true);
                    } else {
                      ref.read(gameProvider.notifier).startGame(p);
                    }
                    if (!context.mounted) return;
                    context.push(AppConstants.routeGame);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12)),
                    child: Text(
                      hasSavedGame ? s.dailyResume : s.dailyPlay,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: ZennColors.primary),
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

class _NoPuzzleCard extends StatelessWidget {
  const _NoPuzzleCard();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: ZennColors.cardMedium,
            borderRadius: BorderRadius.circular(16)),
        child: Center(
          child: Text(strings(context).dailyNoPuzzle,
              textAlign: TextAlign.center, style: ZennTextStyles.body),
        ),
      );
}

class _PuzzleCardSkeleton extends StatelessWidget {
  const _PuzzleCardSkeleton();
  @override
  Widget build(BuildContext context) => Container(
        height: 72,
        decoration: BoxDecoration(
            color: ZennColors.cardMedium,
            borderRadius: BorderRadius.circular(16)),
      );
}

// ─── Month Calendar ───────────────────────────────────────────────────────────

class _MonthCalendar extends StatelessWidget {
  final int year, month;
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
    final s = strings(context);
    final daysInMonth = DateTimeRange(
      start: DateTime(year, month),
      end: DateTime(year, month + 1),
    ).duration.inDays;
    final offset = DateTime(year, month, 1).weekday - 1;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZennColors.border)),
      child: Column(
        children: [
          Row(
            children: s.weekdays
                .map((d) => Expanded(
                      child: Center(
                        child: Text(d,
                            style: ZennTextStyles.caption
                                .copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7, mainAxisSpacing: 4, crossAxisSpacing: 4),
            itemCount: offset + daysInMonth,
            itemBuilder: (_, i) {
              if (i < offset) return const SizedBox.shrink();
              final day = i - offset + 1;
              final dateStr = '${year.toString().padLeft(4, '0')}-'
                  '${month.toString().padLeft(2, '0')}-'
                  '${day.toString().padLeft(2, '0')}';
              return _CalendarDay(
                day: day,
                isToday: day == today.day,
                isCompleted: completedDates.contains(dateStr),
                isFuture: day > today.day,
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
  final bool isToday, isCompleted, isFuture;
  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isCompleted
        ? ZennColors.primary
        : isToday
            ? ZennColors.cardLight
            : isFuture
                ? Colors.transparent
                : ZennColors.surfaceAlt;
    final Color tc = isCompleted
        ? Colors.white
        : isToday
            ? ZennColors.primary
            : isFuture
                ? ZennColors.textHint
                : ZennColors.textMid;

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
        child: Text(day.toString(),
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: tc)),
      ),
    );
  }
}

// ─── Monthly Progress ─────────────────────────────────────────────────────────

class _MonthlyProgress extends StatelessWidget {
  final int completedCount, totalDays;
  const _MonthlyProgress(
      {required this.completedCount, required this.totalDays});

  @override
  Widget build(BuildContext context) {
    final s = strings(context);
    final progress = totalDays > 0 ? completedCount / totalDays : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ZennColors.border)),
      child: Row(
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(s.monthlyProgress,
                  style: ZennTextStyles.bodyMedium
                      .copyWith(color: ZennColors.textDark)),
              const SizedBox(height: 2),
              Text(
                s.dailyProgressDays
                    .replaceFirst('{c}', '$completedCount')
                    .replaceFirst('{t}', '$totalDays'),
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
            ]),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: ZennColors.cardLight, shape: BoxShape.circle),
            child: Center(
              child: Text('${(progress * 100).round()}%',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ZennColors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}
