// lib/widgets/sudoku_grid.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/game_provider.dart';

class SudokuGrid extends ConsumerWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    if (state == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: ZennColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ZennColors.gridBold, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2D3320).withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final cellSize = constraints.maxWidth / 9;
              return Stack(
                children: [
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 9),
                    itemCount: 81,
                    itemBuilder: (_, index) =>
                        _SudokuCell(row: index ~/ 9, col: index % 9),
                  ),
                  IgnorePointer(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _BoxLinePainter(cellSize: cellSize),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── Tek Hücre ────────────────────────────────────────────────────────────────

class _SudokuCell extends ConsumerStatefulWidget {
  final int row;
  final int col;
  const _SudokuCell({required this.row, required this.col});

  @override
  ConsumerState<_SudokuCell> createState() => _SudokuCellState();
}

class _SudokuCellState extends ConsumerState<_SudokuCell>
    with TickerProviderStateMixin {
  // Press animasyonu
  late AnimationController _pressCtrl;
  late Animation<double>   _pressScale;

  // Flash animasyonu
  late AnimationController _flashCtrl;
  late Animation<double>   _flashOpacity;
  late Animation<double>   _flashScale;

  bool _wasFlashing = false;

  @override
  void initState() {
    super.initState();

    _pressCtrl  = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _pressScale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));

    _flashCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 650));

    // Opaklık: 0 → 0.45 (ilk %30) → 0 (son %70)
    _flashOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.45), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.45, end: 0.0), weight: 70),
    ]).animate(_flashCtrl);

    // Scale: 1.0 → 1.06 → 1.0
    _flashScale = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 1.06)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.06, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 70),
    ]).animate(_flashCtrl);
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    _flashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameProvider);
    if (state == null) return const SizedBox.shrink();

    final isFlashing = state.flashCells.contains((widget.row, widget.col));

    if (isFlashing && !_wasFlashing) {
      _flashCtrl.forward(from: 0);
    }
    _wasFlashing = isFlashing;

    final board    = state.puzzle.board;
    final given    = state.puzzle.given;
    final solution = state.puzzle.solution;
    final value    = board[widget.row][widget.col];

    final isSelected  = state.selectedRow == widget.row &&
        state.selectedCol == widget.col;
    final isHighlight = state.highlights.contains((widget.row, widget.col));
    final isConflict  = state.conflicts.contains((widget.row, widget.col));
    final isRelated   = _isRelated(
        state.selectedRow, state.selectedCol, widget.row, widget.col);
    final notes = state.notes[widget.row][widget.col];

    // Temel arka plan rengi
    Color baseBg = ZennColors.surface;
    if (isConflict)       baseBg = ZennColors.errorLight;
    else if (isSelected)  baseBg = ZennColors.selected;
    else if (isRelated)   baseBg = const Color(0xFFF0F7F4);
    else if (isHighlight) baseBg = const Color(0xFFE8F5EE);

    Color textColor;
    if (isConflict) {
      textColor = ZennColors.error;
    } else if (!given[widget.row][widget.col] && value != 0) {
      textColor = value != solution[widget.row][widget.col]
          ? ZennColors.error
          : ZennColors.entered;
    } else {
      textColor = ZennColors.given;
    }

    final thinBorder = BorderSide(color: ZennColors.gridLine, width: 0.5);
    final greenBorder = const BorderSide(color: ZennColors.primary, width: 2);

    return GestureDetector(
      onTapDown: (_) {
        if (!given[widget.row][widget.col]) _pressCtrl.forward();
      },
      onTapUp: (_) {
        _pressCtrl.reverse();
        if (ref.read(hapticEnabledProvider)) HapticFeedback.selectionClick();
        ref.read(gameProvider.notifier).selectCell(widget.row, widget.col);
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_pressCtrl, _flashCtrl]),
        builder: (_, __) {
          // Flash rengini arka plana blend et — Stack yok, boyut sorunu yok
          final bg = _flashCtrl.value > 0
              ? Color.lerp(baseBg, ZennColors.primary, _flashOpacity.value) ?? baseBg
              : baseBg;

          final scale = _pressScale.value * _flashScale.value;

          return Transform.scale(
            scale: scale,
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                border: Border(
                  right:  thinBorder,
                  bottom: thinBorder,
                  // Seçili hücrede 4 kenar da yeşil
                  left:   isSelected ? greenBorder : thinBorder,
                  top:    isSelected ? greenBorder : thinBorder,
                ),
              ),
              child: value != 0
                  ? Center(
                      child: Text(
                        value.toString(),
                        style: ZennTextStyles.cellNumber.copyWith(
                          color: textColor,
                          fontWeight: given[widget.row][widget.col]
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    )
                  : notes.isNotEmpty
                      ? _NotesGrid(notes: notes)
                      : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }

  bool _isRelated(int? sr, int? sc, int r, int c) {
    if (sr == null || sc == null) return false;
    if (sr == r || sc == c) return true;
    if ((sr ~/ 3) == (r ~/ 3) && (sc ~/ 3) == (c ~/ 3)) return true;
    return false;
  }
}

// ─── Not Izgarası ─────────────────────────────────────────────────────────────

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  const _NotesGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1.5),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: 9,
      itemBuilder: (_, i) {
        final n      = i + 1;
        final active = notes.contains(n);
        return Center(
          child: Text(
            active ? n.toString() : '',
            style: TextStyle(
              fontSize: 8,
              color: active
                  ? ZennColors.primary.withOpacity(0.75)
                  : Colors.transparent,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }
}

// ─── 3×3 Kutu Çizgi Painter ───────────────────────────────────────────────────

class _BoxLinePainter extends CustomPainter {
  final double cellSize;
  const _BoxLinePainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color       = ZennColors.gridBold
      ..strokeWidth = 2;
    for (int i = 1; i < 3; i++) {
      final x = cellSize * 3 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (int i = 1; i < 3; i++) {
      final y = cellSize * 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_BoxLinePainter old) => old.cellSize != cellSize;
}