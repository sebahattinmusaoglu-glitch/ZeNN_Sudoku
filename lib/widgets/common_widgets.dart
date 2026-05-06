// lib/widgets/common_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/game_provider.dart';

// ─── Diamond Badge ────────────────────────────────────────────────────────────

class DiamondBadge extends ConsumerWidget {
  final bool large;
  const DiamondBadge({super.key, this.large = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final count   = profile.valueOrNull?.totalDiamonds ?? 0;
    return _DiamondChip(count: count, large: large);
  }
}

class DiamondChipStatic extends StatelessWidget {
  final int count;
  final bool large;
  const DiamondChipStatic({super.key, required this.count, this.large = false});

  @override
  Widget build(BuildContext ctx) => _DiamondChip(count: count, large: large);
}

class _DiamondChip extends StatelessWidget {
  final int count;
  final bool large;
  const _DiamondChip({required this.count, required this.large});

  @override
  Widget build(BuildContext context) {
    final size = large ? 20.0 : 16.0;
    final fs   = large ? 16.0 : 13.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 14 : 10, vertical: large ? 8 : 5),
      decoration: BoxDecoration(
        color: ZennColors.cardMedium,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💎', style: TextStyle(fontSize: size * 0.85)),
          const SizedBox(width: 5),
          Text(
            count.toString(),
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: fs,
              fontWeight: FontWeight.w700,
              color: ZennColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}


// ─── Mistake Indicator ───────────────────────────────────────────────────────

class MistakeIndicator extends StatelessWidget {
  final int mistakes;
  final int maxMistakes;
  const MistakeIndicator({
    super.key,
    required this.mistakes,
    this.maxMistakes = AppConstants.maxMistakes,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(maxMistakes, (i) {
        final active = i < mistakes;
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Icon(
            Icons.close_rounded,
            size: 18, 
            color: active ? ZennColors.error : ZennColors.gridLine,
          ),
        );
      }),
    );
  }
}

// ─── Difficulty Tag ───────────────────────────────────────────────────────────

class DifficultyTag extends StatelessWidget {
  final Difficulty difficulty;
  const DifficultyTag({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (difficulty) {
      Difficulty.easy   => (ZennColors.easy,   const Color(0xFFE8F5EE)),
      Difficulty.medium => (ZennColors.medium,  const Color(0xFFD9E5DF)),
      Difficulty.hard   => (ZennColors.hard,    const Color(0xFFE4E9E8)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        difficulty.label,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ─── ZeNN Logo Text ───────────────────────────────────────────────────────────

class ZennLogoText extends StatelessWidget {
  final double size;
  final Color? color;
  const ZennLogoText({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? ZennColors.primary;
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Ze',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: size, fontWeight: FontWeight.w700,
              color: c,
            ),
          ),
          TextSpan(
            text: 'NN',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: size, fontWeight: FontWeight.w900,
              color: c,
            ),
          ),
          TextSpan(
            text: ' Sudoku',
            style: TextStyle(
              fontFamily: 'Inter', fontSize: size * 0.7, fontWeight: FontWeight.w400,
              color: c.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class ZennButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final Color? color;
  final Widget? leading;

  const ZennButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.color,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final bg = color ?? ZennColors.primary;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (leading != null) ...[leading!, const SizedBox(width: 8)],
                  Text(label, style: ZennTextStyles.buttonText),
                ],
              ),
      ),
    );
  }
}
