// lib/providers/game_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/puzzle.dart';
import '../services/sudoku_generator.dart';
import '../services/supabase_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class GameState {
  final SudokuPuzzle puzzle;
  final int? selectedRow;
  final int? selectedCol;
  final Set<(int, int)> conflicts;
  final Set<(int, int)> highlights;
  final List<List<List<int>>> history;
  final int mistakeCount;
  final int elapsedSeconds;
  final bool isComplete;
  final bool isPaused;
  final bool isNoteMode;
  final List<List<Set<int>>> notes;
  final Set<(int, int)> flashCells;

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
    this.flashCells = const {},
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
    Set<(int, int)>? flashCells,
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
      flashCells:     flashCells     ?? this.flashCells,
    );
  }

  String get elapsedFormatted {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class GameNotifier extends StateNotifier<GameState?> {
  GameNotifier() : super(null);
  Timer? _timer;
  Timer? _flashTimer;

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

  @override
  void dispose() {
    _timer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  Future<void> saveProgress() async {
    if (state == null) return;
    final s = state!;
    final prefs = await SharedPreferences.getInstance();
    final key = s.puzzle.dailyId != null ? 'saved_game_daily' : 'saved_game_${s.puzzle.difficulty.labelEn}';
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
      final data       = jsonDecode(raw) as Map<String, dynamic>;
      final flatBoard  = List<int>.from(data['board']);
      final flatGiven  = List<bool>.from(data['given']);
      final flatSol    = List<int>.from(data['solution']);
      final board      = List.generate(9, (r) => flatBoard.sublist(r*9, r*9+9));
      final given      = List.generate(9, (r) => flatGiven.sublist(r*9, r*9+9));
      final solution   = List.generate(9, (r) => flatSol.sublist(r*9, r*9+9));
      final puzzle = SudokuPuzzle(board: board, given: given, solution: solution, difficulty: difficulty, dailyId: data['dailyId'] as String?);
      final flatNotes = List<List<dynamic>>.from(data['notes']);
      final notes = List.generate(9, (r) => List.generate(9, (c) => Set<int>.from(flatNotes[r*9+c])));
      state = GameState(puzzle: puzzle, notes: notes, elapsedSeconds: data['elapsed'] as int, mistakeCount: data['mistakes'] as int, isPaused: true);
      _startTimer();
      return true;
    } catch (_) { return false; }
  }

  Future<void> clearProgress(Difficulty difficulty, {bool isDaily = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isDaily ? 'saved_game_daily' : 'saved_game_${difficulty.labelEn}');
  }

  void selectCell(int row, int col) {
    if (state == null || state!.isComplete) return;
    final board = state!.puzzle.board;
    final val   = board[row][col];
    final hi = <(int, int)>{};
    if (val != 0) {
      for (int r = 0; r < 9; r++)
        for (int c = 0; c < 9; c++)
          if (board[r][c] == val) hi.add((r, c));
    }
    state = state!.copyWith(selectedRow: row, selectedCol: col, highlights: hi);
  }

  void inputNumber(int num) {
    if (state == null) return;
    final s = state!;
    if (s.selectedRow == null || s.selectedCol == null) return;
    final r = s.selectedRow!;
    final c = s.selectedCol!;
    if (s.puzzle.given[r][c]) return;

    if (s.isNoteMode) { _toggleNote(r, c, num); return; }

    final snap       = s.puzzle.board.map((row) => List<int>.from(row)).toList();
    final newHistory = [...s.history, snap];
    final newBoard   = s.puzzle.board.map((row) => List<int>.from(row)).toList();
    newBoard[r][c]   = num;

    final newPuzzle = SudokuPuzzle(
      board: newBoard, given: s.puzzle.given, solution: s.puzzle.solution,
      difficulty: s.puzzle.difficulty, dailyId: s.puzzle.dailyId, date: s.puzzle.date,
    );

    final conflicts = SudokuGenerator.findConflicts(newBoard, r, c);
    final isMistake = num != 0 && newBoard[r][c] != s.puzzle.solution[r][c];

    final hi = <(int, int)>{};
    if (num != 0)
      for (int rr = 0; rr < 9; rr++)
        for (int cc = 0; cc < 9; cc++)
          if (newBoard[rr][cc] == num) hi.add((rr, cc));

    final newNotes = s.notes.map((row) => row.map((n) => Set<int>.from(n)).toList()).toList();
    if (num != 0) {
      for (int i = 0; i < 9; i++) { newNotes[r][i].remove(num); newNotes[i][c].remove(num); }
      final br = (r ~/ 3) * 3; final bc = (c ~/ 3) * 3;
      for (int rr = br; rr < br+3; rr++)
        for (int cc = bc; cc < bc+3; cc++)
          newNotes[rr][cc].remove(num);
    }

    // Tamamlanan satır / sütun / kutu tespiti
    final flash = <(int, int)>{};
    if (num != 0 && !isMistake) {
      if (_isRowComplete(newBoard, r))
        for (int cc = 0; cc < 9; cc++) flash.add((r, cc));
      if (_isColComplete(newBoard, c))
        for (int rr = 0; rr < 9; rr++) flash.add((rr, c));
      if (_isBoxComplete(newBoard, r, c)) {
        final br = (r ~/ 3) * 3; final bc = (c ~/ 3) * 3;
        for (int rr = br; rr < br+3; rr++)
          for (int cc = bc; cc < bc+3; cc++)
            flash.add((rr, cc));
      }
    }

    state = s.copyWith(
      puzzle: newPuzzle, conflicts: conflicts, highlights: hi,
      history: newHistory, notes: newNotes,
      mistakeCount: isMistake ? s.mistakeCount + 1 : s.mistakeCount,
      isComplete: newPuzzle.isSolved,
      flashCells: flash,
    );

    if (flash.isNotEmpty) {
      _flashTimer?.cancel();
      _flashTimer = Timer(const Duration(milliseconds: 650), () {
        if (state != null) state = state!.copyWith(flashCells: {});
      });
    }

    saveProgress();
  }

  bool _isRowComplete(List<List<int>> board, int r) {
    final v = board[r].toSet(); return v.length == 9 && !v.contains(0);
  }
  bool _isColComplete(List<List<int>> board, int c) {
    final v = <int>{}; for (int r = 0; r < 9; r++) v.add(board[r][c]); return v.length == 9 && !v.contains(0);
  }
  bool _isBoxComplete(List<List<int>> board, int r, int c) {
    final br = (r ~/ 3)*3; final bc = (c ~/ 3)*3; final v = <int>{};
    for (int rr = br; rr < br+3; rr++) for (int cc = bc; cc < bc+3; cc++) v.add(board[rr][cc]);
    return v.length == 9 && !v.contains(0);
  }

  void _toggleNote(int r, int c, int num) {
    final s = state!;
    final newNotes = s.notes.map((row) => row.map((n) => Set<int>.from(n)).toList()).toList();
    if (newNotes[r][c].contains(num)) newNotes[r][c].remove(num); else newNotes[r][c].add(num);
    state = s.copyWith(notes: newNotes);
  }

  Future<HintResult> useHint() async {
    if (state == null) return HintResult.noCell;
    final s = state!;
    if (s.selectedRow == null || s.selectedCol == null) return HintResult.noCell;
    final r = s.selectedRow!;
    final c = s.selectedCol!;
    if (s.puzzle.given[r][c]) return HintResult.noCell;
    if (s.puzzle.board[r][c] == s.puzzle.solution[r][c]) return HintResult.noCell;

    // Elmas kontrolü
    final profile = await SupabaseService.instance.getProfile();
    if (profile == null || profile.totalDiamonds < 1) return HintResult.noDiamond;

    // Elması düş
    await SupabaseService.instance.deductDiamond();

    // Hücreyi doldur
    final newBoard = s.puzzle.board.map((row) => List<int>.from(row)).toList();
    newBoard[r][c] = s.puzzle.solution[r][c];
    final newPuzzle = SudokuPuzzle(
      board: newBoard, given: s.puzzle.given, solution: s.puzzle.solution,
      difficulty: s.puzzle.difficulty, dailyId: s.puzzle.dailyId, date: s.puzzle.date,
    );
    state = s.copyWith(
      puzzle: newPuzzle,
      conflicts: {},
      isComplete: newPuzzle.isSolved,
    );
    saveProgress();
    return HintResult.success;
  }

  void erase() {
    if (state == null) return;
    if (state!.selectedRow == null || state!.selectedCol == null) return;
    inputNumber(0);
  }

  void undo() {
    if (state == null || state!.history.isEmpty) return;
    final s = state!;
    final newPuzzle = SudokuPuzzle(
      board: s.history.last, given: s.puzzle.given, solution: s.puzzle.solution,
      difficulty: s.puzzle.difficulty, dailyId: s.puzzle.dailyId, date: s.puzzle.date,
    );
    state = s.copyWith(puzzle: newPuzzle, history: s.history.sublist(0, s.history.length-1), conflicts: {});
  }

  void toggleNoteMode() {
    if (state == null) return;
    state = state!.copyWith(isNoteMode: !state!.isNoteMode);
  }

  Future<void> saveCompletion() async {
    if (state == null || !state!.isComplete) return;
    _timer?.cancel();
    await SupabaseService.instance.recordCompletion(
      difficulty: state!.puzzle.difficulty, timeTaken: state!.elapsedSeconds, dailyPuzzleId: state!.puzzle.dailyId,
    );
  }
}

// ─── Hint Result ─────────────────────────────────────────────────────────────

enum HintResult { success, noCell, noDiamond }

// ─── Providers ───────────────────────────────────────────────────────────────

final gameProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) => GameNotifier());
final profileProvider = FutureProvider((ref) async => SupabaseService.instance.getProfile());
final dailyPuzzleProvider = FutureProvider((ref) async => SupabaseService.instance.getDailyPuzzle());
final completionStatsProvider = FutureProvider((ref) async => SupabaseService.instance.getCompletionStats());

class HapticNotifier extends StateNotifier<bool> {
  HapticNotifier() : super(true) { _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('haptic_enabled') ?? true;
  }
  Future<void> setEnabled(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic_enabled', value);
  }
}

final hapticEnabledProvider = StateNotifierProvider<HapticNotifier, bool>((_) => HapticNotifier());