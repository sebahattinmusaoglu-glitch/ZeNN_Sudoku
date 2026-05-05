// lib/core/constants.dart

class AppConstants {
  AppConstants._();

  // ── Supabase ──────────────────────────────────────────────
  // Replace these with your actual Supabase project values
  static const String supabaseUrl    = 'https://xquoykwzpxgeevryxfte.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_XlBiCha8d9TktR4Ox-Bmjw_FolsxDZi';

  // ── Diamond Rewards ───────────────────────────────────────
  static const int diamondsEasy    = 2;
  static const int diamondsMedium  = 4;
  static const int diamondsHard    = 6;
  static const int diamondsDaily   = 10;
  static const int diamondsMonthly = 50;  // bonus for full month

  // ── Sudoku ────────────────────────────────────────────────
  static const int boardSize  = 9;
  static const int boxSize    = 3;
  static const int emptyCell  = 0;

  // Clue counts per difficulty (approx.)
  static const int cluesEasy   = 38;
  static const int cluesMedium = 30;
  static const int cluesHard   = 24;

  // ── Navigation ────────────────────────────────────────────
  static const String routeSplash     = '/';
  static const String routeHome       = '/home';
  static const String routeDifficulty = '/difficulty';
  static const String routeGame       = '/game';
  static const String routeDaily      = '/daily';
  static const String routeProfile    = '/profile';

  // ── Misc ──────────────────────────────────────────────────
  static const String appName  = 'ZeNN Sudoku';
  static const String studio   = 'Zenn App Studio';
  static const int maxMistakes = 3;
}

enum Difficulty { easy, medium, hard }

extension DifficultyExt on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:   return 'Kolay';
      case Difficulty.medium: return 'Orta';
      case Difficulty.hard:   return 'Zor';
    }
  }

  String get labelEn {
    switch (this) {
      case Difficulty.easy:   return 'easy';
      case Difficulty.medium: return 'medium';
      case Difficulty.hard:   return 'hard';
    }
  }

  int get diamonds {
    switch (this) {
      case Difficulty.easy:   return AppConstants.diamondsEasy;
      case Difficulty.medium: return AppConstants.diamondsMedium;
      case Difficulty.hard:   return AppConstants.diamondsHard;
    }
  }

  int get clueCount {
    switch (this) {
      case Difficulty.easy:   return AppConstants.cluesEasy;
      case Difficulty.medium: return AppConstants.cluesMedium;
      case Difficulty.hard:   return AppConstants.cluesHard;
    }
  }
}
