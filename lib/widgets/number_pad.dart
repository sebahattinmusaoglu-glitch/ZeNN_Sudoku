// lib/widgets/number_pad.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_provider.dart';

class NumberPad extends ConsumerWidget {
  const NumberPad({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    if (state == null) return const SizedBox.shrink();
    final hapticOn = ref.read(hapticEnabledProvider);

    // Rakam kullanım sayıları
    int usedCount(int n) {
      var c = 0;
      for (final row in state.puzzle.board) for (final v in row) if (v == n) c++;
      return c;
    }

    return Column(
      children: [
        // ── Not modu banner ───────────────────────────────────────────────
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: state.isNoteMode
              ? Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: ZennColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: ZennColors.primary.withOpacity(0.22)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 13, color: ZennColors.primary),
                      SizedBox(width: 6),
                      Text(
                        'NOT MODU AKTİF — Sayı seç, hücreye not ekle',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: ZennColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Satır 1: 1-2-3-4-5 | Geri Al ────────────────────────────────
        Row(
          children: [
            // 1–5
            ...List.generate(5, (i) {
              final n         = i + 1;
              final used      = usedCount(n);
              final done      = used >= 9;
              final remaining = 9 - used;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: _NumberButton(
                    number: n,
                    done: done,
                    remaining: remaining,
                    isNoteMode: state.isNoteMode,
                    onTap: done
                        ? null
                        : () {
                            if (hapticOn) HapticFeedback.lightImpact();
                            ref.read(gameProvider.notifier).inputNumber(n);
                          },
                  ),
                ),
              );
            }),
            // Geri Al
            Expanded(
              child: _ActionButton(
                icon: Icons.undo_rounded,
                label: 'Geri Al',
                onTap: () {
                  if (hapticOn) HapticFeedback.lightImpact();
                  ref.read(gameProvider.notifier).undo();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // ── Satır 2: 6-7-8-9 | Sil | Not | İpucu ────────────────────────
        Row(
          children: [
            // 6–9
            ...List.generate(4, (i) {
              final n         = i + 6;
              final used      = usedCount(n);
              final done      = used >= 9;
              final remaining = 9 - used;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: _NumberButton(
                    number: n,
                    done: done,
                    remaining: remaining,
                    isNoteMode: state.isNoteMode,
                    onTap: done
                        ? null
                        : () {
                            if (hapticOn) HapticFeedback.lightImpact();
                            ref.read(gameProvider.notifier).inputNumber(n);
                          },
                  ),
                ),
              );
            }),
            // Sil
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: _ActionButton(
                  icon: Icons.backspace_outlined,
                  label: 'Sil',
                  onTap: () {
                    if (hapticOn) HapticFeedback.lightImpact();
                    ref.read(gameProvider.notifier).erase();
                  },
                ),
              ),
            ),
            // Not
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Not',
                  active: state.isNoteMode,
                  onTap: () {
                    if (hapticOn) HapticFeedback.lightImpact();
                    ref.read(gameProvider.notifier).toggleNoteMode();
                  },
                ),
              ),
            ),
            // İpucu
            Expanded(
              child: _ActionButton(
                icon: Icons.lightbulb_outline_rounded,
                label: 'İpucu',
                onTap: () async {
                  if (hapticOn) HapticFeedback.lightImpact();
                  final result =
                      await ref.read(gameProvider.notifier).useHint();
                  if (!context.mounted) return;
                  switch (result) {
                    case HintResult.success:
                      ref.invalidate(profileProvider);
                      HapticFeedback.mediumImpact();
                      break;
                    case HintResult.noCell:
                      ScaffoldMessenger.of(context).showSnackBar(
                        _hintSnackBar('Önce bir hücre seç 👆'),
                      );
                      break;
                    case HintResult.noDiamond:
                      ScaffoldMessenger.of(context).showSnackBar(
                        _hintSnackBar('Yeterli elmas yok 💎'),
                      );
                      break;
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}


// ─── Sayı Butonu ─────────────────────────────────────────────────────────────

class _NumberButton extends StatefulWidget {
  final int number;
  final bool done;
  final int remaining;
  final bool isNoteMode;
  final VoidCallback? onTap;

  const _NumberButton({
    required this.number,
    required this.done,
    required this.remaining,
    required this.isNoteMode,
    this.onTap,
  });

  @override
  State<_NumberButton> createState() => _NumberButtonState();
}

class _NumberButtonState extends State<_NumberButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.87).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 58,
          decoration: BoxDecoration(
            color: widget.done
                ? ZennColors.surfaceAlt
                : widget.isNoteMode
                    ? ZennColors.primary.withOpacity(0.1)
                    : ZennColors.cardLight,
            borderRadius: BorderRadius.circular(12),
            border: !widget.done && widget.isNoteMode
                ? Border.all(
                    color: ZennColors.primary.withOpacity(0.3),
                  )
                : null,
            boxShadow: widget.done
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.number.toString(),
                style: ZennTextStyles.numpadNumber.copyWith(
                  fontSize: 22,
                  color: widget.done
                      ? ZennColors.textHint
                      : widget.isNoteMode
                          ? ZennColors.primary
                          : ZennColors.textDark,
                ),
              ),
              // Kalan kullanım sayısı: ≤5 → nokta, >5 → rakam
              if (!widget.done) ...[
                const SizedBox(height: 4),
                _RemainingDots(remaining: widget.remaining),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Kalan Nokta Göstergesi ───────────────────────────────────────────────────

class _RemainingDots extends StatelessWidget {
  final int remaining;
  const _RemainingDots({required this.remaining});

  @override
  Widget build(BuildContext context) {
    // 6+ kalan varsa sayı göster, 5 ve altı nokta
    if (remaining > 5) {
      return Text(
        remaining.toString(),
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: ZennColors.textHint,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        remaining,
        (_) => Container(
          width: 3,
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: const BoxDecoration(
            color: ZennColors.textHint,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// ─── Aksiyon Butonu ───────────────────────────────────────────────────────────

class _ActionButton extends StatefulWidget {
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
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.90).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: 58,
              decoration: BoxDecoration(
                color: widget.active ? ZennColors.primary : ZennColors.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.active
                    ? [BoxShadow(
                        color: ZennColors.primary.withOpacity(0.25),
                        blurRadius: 8, offset: const Offset(0, 3))]
                    : null,
              ),
              child: Icon(widget.icon, size: 22,
                  color: widget.active ? Colors.white : ZennColors.textMid),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10,
                fontWeight: widget.active ? FontWeight.w600 : FontWeight.w400,
                color: widget.active ? ZennColors.primary : ZennColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

SnackBar _hintSnackBar(String message) => SnackBar(
  content: Text(message),
  behavior: SnackBarBehavior.floating,
  backgroundColor: ZennColors.primary,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  margin: const EdgeInsets.all(16),
  duration: const Duration(seconds: 2),
);