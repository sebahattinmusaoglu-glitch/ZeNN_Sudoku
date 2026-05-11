// lib/core/l10n.dart
//
// Kullanım:
//   import 'package:com.zennappstudio.zenn_sudoku/core/l10n.dart';
//
//   // Widget içinde:
//   final s = strings(context);
//   Text(s.greetingMorning)
//
//   // Parametreli string:
//   Text(s.streakDays.replaceFirst('{n}', streak.toString()))
//   Text(s.profilePuzzlesCompleted.replaceFirst('{n}', count.toString()))

import 'package:flutter/widgets.dart';
import 'app_strings.dart';
export 'app_strings.dart'; // AppStrings tipini l10n.dart üzerinden erişilebilir kılar

/// Mevcut locale'e göre doğru [AppStrings] nesnesini döner.
/// Türkçe dışındaki tüm diller için İngilizce fallback uygulanır.
AppStrings strings(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'tr' ? AppStrings.tr : AppStrings.en;
}