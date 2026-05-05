# ZeNN Sudoku – Kurulum Kılavuzu

## 1. Supabase Kurulumu

### a) Proje Oluştur
1. https://supabase.com → New Project
2. Proje adı: `zenn-sudoku`

### b) Schema Uygula
Supabase Dashboard → SQL Editor → `supabase/schema.sql` dosyasının içeriğini yapıştır → Run

### c) Authentication Ayarları
Dashboard → Authentication → Providers → Google → Enable  
Google OAuth Client ID ve Secret'ı gir (aşağıda açıklandı).

---

## 2. Google OAuth Ayarları

### Google Cloud Console
1. https://console.cloud.google.com → New Project veya mevcut proje
2. APIs & Services → Credentials → Create Credentials → OAuth 2.0 Client ID
3. Android için:
   - Application type: Android
   - Package name: `com.zennappstudio.zenn_sudoku`
   - SHA-1: `keytool -keystore debug.keystore -list -v` ile debug SHA-1'i al
4. Web için (Supabase OAuth callback için):
   - Application type: Web
   - Authorized redirect URI: `https://YOUR_PROJECT_ID.supabase.co/auth/v1/callback`

### Supabase'e Ekle
Dashboard → Authentication → Providers → Google:
- Client ID: Web client ID
- Client Secret: Web client secret

---

## 3. Flutter Kurulumu

### `lib/core/constants.dart` dosyasını güncelle:
```dart
static const String supabaseUrl    = 'https://YOUR_PROJECT_ID.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

Supabase Dashboard → Project Settings → API'den alabilirsin.

### `android/app/build.gradle` güncelle:
```gradle
android {
    defaultConfig {
        applicationId "com.zennappstudio.zenn_sudoku"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### `android/app/src/main/AndroidManifest.xml`'e ekle:
```xml
<manifest>
  <application>
    <!-- Google Sign-In için -->
    <meta-data
      android:name="com.google.android.gms.version"
      android:value="@integer/google_play_services_version" />

    <!-- Supabase OAuth deep link -->
    <activity android:name="com.linusu.flutter_web_auth_2.CallbackActivity"
      android:exported="true">
      <intent-filter android:label="flutter_web_auth_2">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="com.zennappstudio.zenn.sudoku" />
      </intent-filter>
    </activity>
  </application>
</manifest>
```

---

## 4. Font Kurulumu

Inter fontunu Google Fonts'tan indir:
https://fonts.google.com/specimen/Inter

`assets/fonts/` klasörüne ekle:
- Inter-Regular.ttf
- Inter-Medium.ttf
- Inter-SemiBold.ttf
- Inter-Bold.ttf

---

## 5. Paketleri Yükle

```bash
flutter pub get
flutter run
```

---

## 6. Günlük Puzzle Yükleme

Supabase Edge Function veya Cron Job ile her gün yeni puzzle ekleyebilirsin:

```sql
INSERT INTO daily_puzzles (date, puzzle, solution)
VALUES (
  '2025-01-15',
  '530070000600195000098000060800060003400803001700020006060000280000419005000080079',
  '534678912672195348198342567859761423426853791713924856961537284287419635345286179'
);
```

---

## 7. Proje Yapısı

```
lib/
├── core/
│   ├── constants.dart     # App constants, Difficulty enum
│   ├── router.dart        # GoRouter navigation
│   └── theme.dart         # Colors, typography, ThemeData
├── models/
│   ├── profile.dart       # UserProfile model
│   └── puzzle.dart        # SudokuPuzzle, DailyPuzzle, Completion
├── providers/
│   └── game_provider.dart # Riverpod: GameState, GameNotifier
├── screens/
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── game_screen.dart
│   ├── daily_screen.dart
│   └── profile_screen.dart
├── services/
│   ├── supabase_service.dart  # Auth + DB operations
│   └── sudoku_generator.dart  # Puzzle generation (backtracking)
├── widgets/
│   ├── sudoku_grid.dart       # 9x9 game board
│   ├── number_pad.dart        # Input pad
│   └── common_widgets.dart    # DiamondBadge, ZennButton, etc.
└── main.dart
```

---

## 8. Elmas Sistemi

| Eylem             | Elmas |
|-------------------|-------|
| Kolay tamamla     | +2 💎 |
| Orta tamamla      | +4 💎 |
| Zor tamamla       | +6 💎 |
| Günlük tamamla    | +10 💎 |
| Aylık tüm günlük  | +50 💎 |

---

## Notlar

- Puzzle üretimi (`sudoku_generator.dart`) backtracking algoritmasıyla çalışır.
- Günlük puzzle için Supabase'e her gün yeni kayıt eklenmesi gerekir.
- `award_diamonds` RPC atomic olduğu için yarış koşulları yoktur.
