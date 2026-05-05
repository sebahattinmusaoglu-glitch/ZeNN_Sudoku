// lib/models/puzzle.dart
import '../core/constants.dart';

class SudokuPuzzle {
  /// 9×9 board – 0 means empty
  final List<List<int>> board;

  /// Original clues (immutable cells)
  final List<List<bool>> given;

  /// Full solution
  final List<List<int>> solution;

  final Difficulty difficulty;

  /// For daily puzzles
  final String? dailyId;
  final DateTime? date;

  SudokuPuzzle({
    required this.board,
    required this.given,
    required this.solution,
    required this.difficulty,
    this.dailyId,
    this.date,
  });

  factory SudokuPuzzle.fromStrings({
    required String puzzleStr,
    required String solutionStr,
    required Difficulty difficulty,
    String? dailyId,
    DateTime? date,
  }) {
    final board    = _parseBoard(puzzleStr);
    final solution = _parseBoard(solutionStr);
    final given    = List.generate(9, (r) =>
        List.generate(9, (c) => board[r][c] != 0));
    return SudokuPuzzle(
      board: board, given: given, solution: solution,
      difficulty: difficulty, dailyId: dailyId, date: date,
    );
  }

  static List<List<int>> _parseBoard(String s) {
    assert(s.length == 81);
    return List.generate(9, (r) =>
        List.generate(9, (c) => int.parse(s[r * 9 + c])));
  }

  String boardToString() =>
      board.expand((row) => row).map((v) => v.toString()).join();

  bool get isSolved {
    for (int r = 0; r < 9; r++) {
      for (int c = 0; c < 9; c++) {
        if (board[r][c] != solution[r][c]) return false;
      }
    }
    return true;
  }

  int get emptyCells =>
      board.expand((r) => r).where((v) => v == 0).length;
}

class DailyPuzzle {
  final String id;
  final DateTime date;
  final String puzzle;
  final String solution;

  const DailyPuzzle({
    required this.id,
    required this.date,
    required this.puzzle,
    required this.solution,
  });

  factory DailyPuzzle.fromMap(Map<String, dynamic> m) => DailyPuzzle(
    id: m['id'] as String,
    date: DateTime.parse(m['date'] as String),
    puzzle: m['puzzle'] as String,
    solution: m['solution'] as String,
  );
}

class Completion {
  final String id;
  final String userId;
  final String puzzleType;
  final String? dailyPuzzleId;
  final int timeTaken;
  final int diamondsEarned;
  final DateTime completedAt;

  const Completion({
    required this.id,
    required this.userId,
    required this.puzzleType,
    this.dailyPuzzleId,
    required this.timeTaken,
    required this.diamondsEarned,
    required this.completedAt,
  });

  factory Completion.fromMap(Map<String, dynamic> m) => Completion(
    id: m['id'] as String,
    userId: m['user_id'] as String,
    puzzleType: m['puzzle_type'] as String,
    dailyPuzzleId: m['daily_puzzle_id'] as String?,
    timeTaken: (m['time_taken'] as int?) ?? 0,
    diamondsEarned: m['diamonds_earned'] as int,
    completedAt: DateTime.parse(m['completed_at'] as String),
  );
}
