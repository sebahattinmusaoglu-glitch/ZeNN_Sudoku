// lib/core/theme.dart
import 'package:flutter/material.dart';

// ─── Color Tokens ──────────────────────────────────────────────────────────
class ZennColors {
  ZennColors._();

  // Brand
  static const Color primary    = Color(0xFF005235);
  static const Color primaryMid = Color(0xFF1A6B4A);
  static const Color primarySoft= Color(0xFF2D6957);

  // Backgrounds
  static const Color background = Color(0xFFF8FAF8);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF2F4F2);

  // Cards / tonal
  static const Color cardLight  = Color(0xFFE8F5EE);
  static const Color cardMedium = Color(0xFFD9E5DF);
  static const Color cardGreen  = Color(0xFFD6E3DC);

  // Grid
  static const Color gridLine   = Color(0xFFE1E3E1);
  static const Color gridBold   = Color(0xFFBFC9C0);

  // Text
  static const Color textDark   = Color(0xFF191C1B);
  static const Color textMid    = Color(0xFF3F4943);
  static const Color textSoft   = Color(0xFF6F7A72);
  static const Color textLight  = Color(0xFF757C7B);
  static const Color textHint   = Color(0xFFACB3B2);

  // Semantic
  static const Color error      = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);
  static const Color diamond    = Color(0xFF005235);
  static const Color given      = Color(0xFF191C1B);   // pre-filled cell text
  static const Color entered    = Color(0xFF005235);   // user-entered text
  static const Color conflict   = Color(0xFFBA1A1A);   // duplicate highlight
  static const Color selected   = Color(0xFFD6E3DC);   // selected cell bg
  static const Color highlighted= Color(0xFFF0F7F4);   // same-number highlight
  static const Color border     = Color(0xFFE4E9E8);

  // Difficulty
  static const Color easy       = Color(0xFF1A6B4A);
  static const Color medium     = Color(0xFF005235);
  static const Color hard       = Color(0xFF191C1B);
  static const Color daily      = Color(0xFF005235);
}

// ─── Text Styles ────────────────────────────────────────────────────────────
class ZennTextStyles {
  ZennTextStyles._();

  static const String _font = 'Inter';

  static TextStyle display(BuildContext ctx) =>
    Theme.of(ctx).textTheme.displayMedium!;

  static const headline1 = TextStyle(
    fontFamily: _font, fontSize: 28, fontWeight: FontWeight.w700,
    color: ZennColors.textDark, letterSpacing: -0.5,
  );
  static const headline2 = TextStyle(
    fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w600,
    color: ZennColors.textDark, letterSpacing: -0.3,
  );
  static const headline3 = TextStyle(
    fontFamily: _font, fontSize: 18, fontWeight: FontWeight.w600,
    color: ZennColors.textDark,
  );
  static const body = TextStyle(
    fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w400,
    color: ZennColors.textMid,
  );
  static const bodyMedium = TextStyle(
    fontFamily: _font, fontSize: 15, fontWeight: FontWeight.w500,
    color: ZennColors.textMid,
  );
  static const caption = TextStyle(
    fontFamily: _font, fontSize: 12, fontWeight: FontWeight.w400,
    color: ZennColors.textLight,
  );
  static const label = TextStyle(
    fontFamily: _font, fontSize: 13, fontWeight: FontWeight.w500,
    color: ZennColors.textSoft,
  );
  static const buttonText = TextStyle(
    fontFamily: _font, fontSize: 16, fontWeight: FontWeight.w600,
    color: Colors.white, letterSpacing: 0.2,
  );
  static const cellNumber = TextStyle(
    fontFamily: _font, fontSize: 20, fontWeight: FontWeight.w600,
  );
  static const numpadNumber = TextStyle(
    fontFamily: _font, fontSize: 22, fontWeight: FontWeight.w700,
    color: ZennColors.textDark,
  );
}

// ─── App Theme ───────────────────────────────────────────────────────────────
ThemeData buildZennTheme() {
  const font = 'Inter';

  return ThemeData(
    useMaterial3: true,
    fontFamily: font,
    scaffoldBackgroundColor: ZennColors.background,
    colorScheme: const ColorScheme.light(
      primary:   ZennColors.primary,
      onPrimary: Colors.white,
      secondary: ZennColors.primaryMid,
      surface:   ZennColors.surface,
      error:     ZennColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: ZennColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      iconTheme: IconThemeData(color: ZennColors.textDark),
      titleTextStyle: TextStyle(
        fontFamily: font, fontSize: 17, fontWeight: FontWeight.w600,
        color: ZennColors.textDark,
      ),
    ),
    cardTheme: CardThemeData(
      color: ZennColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ZennColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: ZennTextStyles.buttonText,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ZennColors.primary,
        textStyle: const TextStyle(
          fontFamily: font, fontSize: 15, fontWeight: FontWeight.w600,
        ),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: ZennColors.border, thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ZennColors.surfaceAlt,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
