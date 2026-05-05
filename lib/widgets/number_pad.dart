// lib/widgets/number_pad.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    if (state == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Action row: Undo | Erase | Notes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ActionButton(
              icon: Icons.undo_rounded,
              label: 'Geri Al',
              onTap: () => ref.read(gameProvider.notifier).undo(),
            ),
            _ActionButton(
              icon: Icons.backspace_outlined,
              label: 'Sil',
              onTap: () => ref.read(gameProvider.notifier).erase(),
            ),
            _ActionButton(
              icon: Icons.edit_outlined,
              label: 'Not',
              active: state.isNoteMode,
              onTap: () => ref.read(gameProvider.notifier).toggleNoteMode(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Number buttons 1–9
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(9, (i) {
            final n = i + 1;
            // Count how many of this number are on the board
            final board = state.puzzle.board;
            int count = 0;
            for (final row in board) {
              for (final v in row) {
                if (v == n) count++;
              }
            }
            final done = count >= 9;
            return _NumberButton(
              number: n,
              done: done,
              onTap: done
                  ? null
                  : () => ref.read(gameProvider.notifier).inputNumber(n),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Number Button ────────────────────────────────────────────────────────────

class _NumberButton extends StatelessWidget {
  final int number;
  final bool done;
  final VoidCallback? onTap;

  const _NumberButton({
    required this.number,
    required this.done,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 52,
        decoration: BoxDecoration(
          color: done ? ZennColors.surfaceAlt : ZennColors.cardLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            number.toString(),
            style: ZennTextStyles.numpadNumber.copyWith(
              color: done ? ZennColors.textHint : ZennColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? ZennColors.primary : ZennColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: active ? Colors.white : ZennColors.textMid,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: ZennTextStyles.caption),
        ],
      ),
    );
  }
}
