// lib/services/sudoku_generator.dart
import 'dart:math';
import '../core/constants.dart';
import '../models/puzzle.dart';

class SudokuGenerator {
  static final _rng = Random.secure();

  // ─── Public API ──────────────────────────────────────────────────────────

  static SudokuPuzzle generate(Difficulty difficulty) {
    final solution = _generateSolution();
    final puzzle   = _createPuzzle(solution, difficulty.clueCount);
    final given    = List.generate(9, (r) =>
        List.generate(9, (c) => puzzle[r][c] != 0));
    return SudokuPuzzle(
      board: puzzle,
      given: given,
      solution: solution,
      difficulty: difficulty,
    );
  }

  // ─── Solution generator (backtracking) ───────────────────────────────────

  static List<List<int>> _generateSolution() {
    final board = List.generate(9, (_) => List.filled(9, 0));
    _fillBoard(board);
    return board;
  }

  static bool _fillBoard(List<List<int>> board) {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != 0) continue;
        final nums = _shuffledDigits();
        for (final n in nums) {
          if (_isValid(board, r, c, n)) {
            board[r][c] = n;
            if (_fillBoard(board)) return true;
            board[r][c] = 0;
          }
        }
        return false;
      }
    }
    return true;
  }

  // ─── Puzzle creator (remove cells, keep unique solution) ─────────────────

  static List<List<int>> _createPuzzle(
      List<List<int>> solution, int targetClues) {
    final puzzle = solution.map((r) => List<int>.from(r)).toList();

    // Cells to remove = 81 - targetClues
    int toRemove = 81 - targetClues;

    // Generate shuffled list of all cell positions
    final positions = [for (int i = 0; i < 81; i++) i]..shuffle(_rng);

    for (final pos in positions) {
      if (toRemove == 0) break;
      final r = pos ~/ 9;
      final c = pos % 9;
      final backup = puzzle[r][c];
      puzzle[r][c] = 0;

      // Check if puzzle still has a unique solution
      if (!_hasUniqueSolution(puzzle)) {
        puzzle[r][c] = backup; // restore
      } else {
        toRemove--;
      }
    }

    return puzzle;
  }

  /// Returns true only when exactly one solution exists.
  static bool _hasUniqueSolution(List<List<int>> puzzle) {
    final copy = puzzle.map((r) => List<int>.from(r)).toList();
    int count = 0;
    _countSolutions(copy, count: (c) => count = c, limit: 2);
    return count == 1;
  }

  static void _countSolutions(
    List<List<int>> board, {
    required void Function(int) count,
    required int limit,
    int found = 0,
  }) {
    // Find first empty cell
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != 0) continue;
        for (int n = 1; n <= 9; n++) {
          if (_isValid(board, r, c, n)) {
            board[r][c] = n;
            int innerFound = found;
            _countSolutions(board,
                count: (v) => innerFound = v,
                limit: limit,
                found: innerFound);
            found = innerFound;
            board[r][c] = 0;
            if (found >= limit) {
              count(found);
              return;
            }
          }
        }
        count(found);
        return;
      }
    }
    count(found + 1);
  }

  // ─── Validation ───────────────────────────────────────────────────────────

  static bool _isValid(List<List<int>> b, int row, int col, int num) {
    // Row check
    if (b[row].contains(num)) return false;
    // Col check
    for (int r = 0; r < 9; r++) {
      if (b[r][col] == num) return false;
    }
    // Box check
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if (b[r][c] == num) return false;
      }
    }
    return true;
  }

  // ─── Public validation (used in game) ────────────────────────────────────

  static bool isValidMove(List<List<int>> board, int row, int col, int num) =>
      _isValid(board, row, col, num);

  /// Returns set of (row,col) cells that conflict with (row,col).
  static Set<(int, int)> findConflicts(
      List<List<int>> board, int row, int col) {
    final val = board[row][col];
    if (val == 0) return {};
    final conflicts = <(int, int)>{};
    for (int c = 0; c < 9; c++) {
      if (c != col && board[row][c] == val) conflicts.add((row, c));
    }
    for (int r = 0; r < 9; r++) {
      if (r != row && board[r][col] == val) conflicts.add((r, col));
    }
    final br = (row ~/ 3) * 3;
    final bc = (col ~/ 3) * 3;
    for (int r = br; r < br + 3; r++) {
      for (int c = bc; c < bc + 3; c++) {
        if ((r != row || c != col) && board[r][c] == val)
          conflicts.add((r, c));
      }
    }
    return conflicts;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static List<int> _shuffledDigits() {
    final d = List.generate(9, (i) => i + 1);
    d.shuffle(_rng);
    return d;
  }
}
