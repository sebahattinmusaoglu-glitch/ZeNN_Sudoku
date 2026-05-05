// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/puzzle.dart';
import '../services/sudoku_generator.dart';
import '../services/supabase_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Game State ────────────────────────────────────────────────────────────

class GameState {
  final SudokuPuzzle puzzle;
  final int? selectedRow;
  final int? selectedCol;
  final Set<(int, int)> conflicts;
  final Set<(int, int)> highlights;   // cells with same number
  final List<List<List<int>>> history; // undo stack
  final int mistakeCount;
  final int elapsedSeconds;
  final bool isComplete;
  final bool isPaused;
  final bool isNoteMode;
  final List<List<Set<int>>> notes;

  const GameState({
    required this.puzzle,
    this.selectedRow,
    this.selectedCol,
    this.conflicts = const {},
    this.highlights = const {},
    this.history = const [],
    this.mistakeCount = 0,
    this.elapsedSeconds = 0,
    this.isComplete = false,
    this.isPaused = false,
    this.isNoteMode = false,
    required this.notes,
  });

  GameState copyWith({
    SudokuPuzzle? puzzle,
    int? selectedRow,
    int? selectedCol,
    Set<(int, int)>? conflicts,
    Set<(int, int)>? highlights,
    List<List<List<int>>>? history,
    int? mistakeCount,
    int? elapsedSeconds,
    bool? isComplete,
    bool? isPaused,
    bool? isNoteMode,
    List<List<Set<int>>>? notes,
    bool clearSelection = false,
  }) {
    return GameState(
      puzzle:         puzzle         ?? this.puzzle,
      selectedRow:    clearSelection ? null : (selectedRow ?? this.selectedRow),
      selectedCol:    clearSelection ? null : (selectedCol ?? this.selectedCol),
      conflicts:      conflicts      ?? this.conflicts,
      highlights:     highlights     ?? this.highlights,
      history:        history        ?? this.history,
      mistakeCount:   mistakeCount   ?? this.mistakeCount,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isComplete:     isComplete     ?? this.isComplete,
      isPaused:       isPaused       ?? this.isPaused,
      isNoteMode:     isNoteMode     ?? this.isNoteMode,
      notes:          notes          ?? this.notes,
    );
  }

  String get elapsedFormatted {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Notifier ──────────────────────────────────────────────────────────────

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier() : super(null);

  Timer? _timer;

  // ── Lifecycle ──────────────────────────────────────────────────────────

  void startGame(SudokuPuzzle puzzle) {
    _timer?.cancel();
    final emptyNotes = List.generate(9, (_) => List.generate(9, (_) => <int>{}));
    state = GameState(puzzle: puzzle, notes: emptyNotes, isPaused: true);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state == null || state!.isPaused || state!.isComplete) return;
      state = state!.copyWith(elapsedSeconds: state!.elapsedSeconds + 1);
    });
  }

  void togglePause() {
    if (state == null) return;
    state = state!.copyWith(isPaused: !state!.isPaused);
  }

  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

// ── Save / Load ──────────────────────────────────────────────

Future<void> saveProgress() async {
    if (state == null) return;
    final s = state!;
    final prefs = await SharedPreferences.getInstance();
    final key = s.puzzle.dailyId != null
        ? 'saved_game_daily'
        : 'saved_game_${s.puzzle.difficulty.labelEn}';
    final data = {
      'board':      s.puzzle.board.expand((r) => r).toList(),
      'given':      s.puzzle.given.expand((r) => r).toList(),
      'solution':   s.puzzle.solution.expand((r) => r).toList(),
      'difficulty': s.puzzle.difficulty.labelEn,
      'dailyId':    s.puzzle.dailyId,
      'elapsed':    s.elapsedSeconds,
      'mistakes':   s.mistakeCount,
      'notes':      s.notes.expand((r) => r.map((n) => n.toList())).toList(),
    };
    await prefs.setString(key, jsonEncode(data));
  }

Future<bool> loadProgress(Difficulty difficulty, {bool isDaily = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final key = isDaily ? 'saved_game_daily' : 'saved_game_${difficulty.labelEn}';
  final raw = prefs.getString(key);
  if (raw == null) return false;

    try {
      final data = jsonDecode(raw) as Map<String, dynamic>;

      final flatBoard    = List<int>.from(data['board']);
      final flatGiven    = List<bool>.from(data['given']);
      final flatSolution = List<int>.from(data['solution']);

      final board    = List.generate(9, (r) => flatBoard.sublist(r*9, r*9+9));
      final given    = List.generate(9, (r) => flatGiven.sublist(r*9, r*9+9));
      final solution = List.generate(9, (r) => flatSolution.sublist(r*9, r*9+9));

      final puzzle = SudokuPuzzle(
        board: board, given: given, solution: solution,
        difficulty: difficulty,
        dailyId: data['dailyId'] as String?,
      );

      final flatNotes = List<List<dynamic>>.from(data['notes']);
      final notes = List.generate(9, (r) =>
          List.generate(9, (c) =>
              Set<int>.from(flatNotes[r * 9 + c])));

      state = GameState(
        puzzle:         puzzle,
        notes:          notes,
        elapsedSeconds: data['elapsed'] as int,
        mistakeCount:   data['mistakes'] as int,
        isPaused:       true,
      );
      _startTimer();
      return true;
    } catch (_) {
      return false;
    }
  }

Future<void> clearProgress(Difficulty difficulty, {bool isDaily = false}) async {
  final prefs = await SharedPreferences.getInstance();
  final key = isDaily ? 'saved_game_daily' : 'saved_game_${difficulty.labelEn}';
  await prefs.remove(key);
}

  // ── Selection ────────────────────────────────────────────────────────

  void selectCell(int row, int col) {
    if (state == null || state!.isComplete) return;
    final board = state!.puzzle.board;
    final val   = board[row][col];

    // Highlight all cells with same value
    final hi = <(int, int)>{};
    if (val != 0) {
      for (int r = 0; r < 9; r++) {
        for (int c = 0; c < 9; c++) {
          if (board[r][c] == val) hi.add((r, c));
        }
      }
    }

    state = state!.copyWith(
      selectedRow: row,
      selectedCol: col,
      highlights: hi,
    );
  }

  // ── Input ────────────────────────────────────────────────────────────

  void inputNumber(int num) {
    if (state == null) return;
    final s = state!;
    if (s.selectedRow == null || s.selectedCol == null) return;
    final r = s.selectedRow!;
    final c = s.selectedCol!;
    if (s.puzzle.given[r][c]) return; // can't edit given cells

    if (s.isNoteMode) {
      _toggleNote(r, c, num);
      return;
    }

    // Save history for undo
    final snap = s.puzzle.board.map((row) => List<int>.from(row)).toList();
    final newHistory = [...s.history, snap];

    // Place number
    final newBoard = s.puzzle.board.map((row) => List<int>.from(row)).toList();
    newBoard[r][c] = num;

    final newPuzzle = SudokuPuzzle(
      board:      newBoard,
      given:      s.puzzle.given,
      solution:   s.puzzle.solution,
      difficulty: s.puzzle.difficulty,
      dailyId:    s.puzzle.dailyId,
      date:       s.puzzle.date,
    );

    // Check conflicts
    final conflicts = SudokuGenerator.findConflicts(newBoard, r, c);
    bool isMistake  = false;
    if (num != 0 && newBoard[r][c] != s.puzzle.solution[r][c]) {
      isMistake = true;
    }

    // Highlight
    final hi = <(int, int)>{};
    if (num != 0) {
      for (int rr = 0; rr < 9; rr++) {
        for (int cc = 0; cc < 9; cc++) {
          if (newBoard[rr][cc] == num) hi.add((rr, cc));
        }
      }
    }

    // Clear notes in same row/col/box
    final newNotes = s.notes.map((row) => row.map((n) => Set<int>.from(n)).toList()).toList();
    if (num != 0) {
      for (int i = 0; i < 9; i++) {
        newNotes[r][i].remove(num);
        newNotes[i][c].remove(num);
      }
      final br = (r ~/ 3) * 3;
      final bc = (c ~/ 3) * 3;
      for (int rr = br; rr < br + 3; rr++) {
        for (int cc = bc; cc < bc + 3; cc++) {
          newNotes[rr][cc].remove(num);
        }
      }
    }

    state = s.copyWith(
      puzzle:       newPuzzle,
      conflicts:    conflicts,
      highlights:   hi,
      history:      newHistory,
      notes:        newNotes,
      mistakeCount: isMistake ? s.mistakeCount + 1 : s.mistakeCount,
      isComplete:   newPuzzle.isSolved,
    );
    saveProgress();
  }

  void _toggleNote(int r, int c, int num) {
    final s = state!;
    final newNotes = s.notes.map((row) => row.map((n) => Set<int>.from(n)).toList()).toList();
    if (newNotes[r][c].contains(num)) {
      newNotes[r][c].remove(num);
    } else {
      newNotes[r][c].add(num);
    }
    state = s.copyWith(notes: newNotes);
  }

  void erase() {
    if (state == null) return;
    final s = state!;
    if (s.selectedRow == null || s.selectedCol == null) return;
    inputNumber(0);
  }

  void undo() {
    if (state == null || state!.history.isEmpty) return;
    final s = state!;
    final prevBoard = s.history.last;
    final newHistory = s.history.sublist(0, s.history.length - 1);
    final newPuzzle = SudokuPuzzle(
      board:      prevBoard,
      given:      s.puzzle.given,
      solution:   s.puzzle.solution,
      difficulty: s.puzzle.difficulty,
      dailyId:    s.puzzle.dailyId,
      date:       s.puzzle.date,
    );
    state = s.copyWith(puzzle: newPuzzle, history: newHistory, conflicts: {});
  }

  void toggleNoteMode() {
    if (state == null) return;
    state = state!.copyWith(isNoteMode: !state!.isNoteMode);
  }

  // ── Completion callback ────────────────────────────────────────────────

  Future<void> saveCompletion() async {
    if (state == null || !state!.isComplete) return;
    _timer?.cancel();
    await SupabaseService.instance.recordCompletion(
      difficulty:     state!.puzzle.difficulty,
      timeTaken:      state!.elapsedSeconds,
      dailyPuzzleId:  state!.puzzle.dailyId,
    );
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final gameProvider =
    StateNotifierProvider<GameNotifier, GameState?>((ref) => GameNotifier());

final profileProvider = FutureProvider((ref) async {
  return SupabaseService.instance.getProfile();
});

final dailyPuzzleProvider = FutureProvider((ref) async {
  return SupabaseService.instance.getDailyPuzzle();
});

final completionStatsProvider = FutureProvider((ref) async {
  return SupabaseService.instance.getCompletionStats();
});
