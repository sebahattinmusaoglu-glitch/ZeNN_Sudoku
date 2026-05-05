// lib/widgets/sudoku_grid.dart
import 'package:flutter/material.dart';
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
                  // Cells
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 81,
                    itemBuilder: (_, index) {
                      final r = index ~/ 9;
                      final c = index % 9;
                      return _SudokuCell(row: r, col: c);
                    },
                  ),
                  // Bold 3×3 box lines drawn on top
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

// ─── Single Cell ─────────────────────────────────────────────────────────────

class _SudokuCell extends ConsumerWidget {
  final int row;
  final int col;
  const _SudokuCell({required this.row, required this.col});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gameProvider);
    if (state == null) return const SizedBox.shrink();

    final board    = state.puzzle.board;
    final given    = state.puzzle.given;
    final solution = state.puzzle.solution;
    final value    = board[row][col];
    final isSelected  = state.selectedRow == row && state.selectedCol == col;
    final isHighlight = state.highlights.contains((row, col));
    final isConflict  = state.conflicts.contains((row, col));
    final isRelated   = _isRelated(state.selectedRow, state.selectedCol, row, col);
    final notes = state.notes[row][col];

    // Background color priority: selected > conflict > related > highlighted > default
    Color bg = ZennColors.surface;
    if (isConflict) {
      bg = ZennColors.errorLight;
    } else if (isSelected) {
      bg = ZennColors.selected;
    } else if (isRelated) {
      bg = const Color(0xFFF0F7F4);
    } else if (isHighlight) {
      bg = const Color(0xFFE8F5EE);
    }

    // Text color
    Color textColor;
    if (isConflict) {
      textColor = ZennColors.error;
    } else if (!given[row][col] && value != 0) {
      // Wrong answer?
      textColor = value != solution[row][col]
          ? ZennColors.error
          : ZennColors.entered;
    } else {
      textColor = ZennColors.given;
    }

    // Cell border
    final borderSide = BorderSide(color: ZennColors.gridLine, width: 0.5);

    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).selectCell(row, col),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right:  borderSide,
            bottom: borderSide,
          ),
        ),
        child: value != 0
            ? Center(
                child: Text(
                  value.toString(),
                  style: ZennTextStyles.cellNumber.copyWith(
                    color:      textColor,
                    fontWeight: given[row][col]
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
  }

  bool _isRelated(int? sr, int? sc, int r, int c) {
    if (sr == null || sc == null) return false;
    if (sr == r || sc == c) return true;
    if ((sr ~/ 3) == (r ~/ 3) && (sc ~/ 3) == (c ~/ 3)) return true;
    return false;
  }
}

// ─── Notes (pencil marks) ────────────────────────────────────────────────────

class _NotesGrid extends StatelessWidget {
  final Set<int> notes;
  const _NotesGrid({required this.notes});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: 9,
      itemBuilder: (_, i) {
        final n = i + 1;
        return Center(
          child: Text(
            notes.contains(n) ? n.toString() : '',
            style: const TextStyle(
              fontSize: 7,
              color: ZennColors.textSoft,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

// ─── 3×3 box line painter ─────────────────────────────────────────────────────

class _BoxLinePainter extends CustomPainter {
  final double cellSize;
  const _BoxLinePainter({required this.cellSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZennColors.gridBold
      ..strokeWidth = 2;

    // Draw 2 inner vertical lines (at col 3 and col 6)
    for (int i = 1; i < 3; i++) {
      final x = cellSize * 3 * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    // Draw 2 inner horizontal lines (at row 3 and row 6)
    for (int i = 1; i < 3; i++) {
      final y = cellSize * 3 * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_BoxLinePainter old) => old.cellSize != cellSize;
}
