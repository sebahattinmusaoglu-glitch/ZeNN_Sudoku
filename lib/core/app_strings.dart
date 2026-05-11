// lib/core/app_strings.dart
//
// ZeNN Sudoku — Lokalizasyon String Tablosu
// Kullanım: strings(context).keyAdi
// Yeni dil eklemek için: AppStrings.xx = AppStrings(...) ekle
//                         l10n.dart'ta switch'e ekle

class AppStrings {
  // ─── Genel ────────────────────────────────────────────────────────────────
  final String appName;
  final String ok;
  final String cancel;
  final String close;
  final String save;
  final String loading;
  final String errorGeneric;

  // ─── BottomNav ────────────────────────────────────────────────────────────
  final String navHome;
  final String navDaily;
  final String navProfile;

  // ─── HomeScreen ───────────────────────────────────────────────────────────
  final String greetingMorning;    // 06:00–11:59
  final String greetingAfternoon;  // 12:00–17:59
  final String greetingEvening;    // 18:00–23:59
  final String dailyBannerTitle;
  final String dailyBannerSubtitle;
  final String quickPlay;
  final String statsTitle;
  final String signInEarnDiamonds; // "Giriş yap, 10 Elmas kazan"

  // ─── Genel — Oyuncu / Elmas ──────────────────────────────────────────────
  final String playerDefault;   // Giriş yapılmamış kullanıcı adı
  final String diamondsLabel;   // "Elmas" (kart üzerindeki kısa etiket)
  final String earnDiamonds;    // "+N Elmas kazan"  {n} yerine sayı gir

  // ─── Kayıtlı Oyun Dialogu ────────────────────────────────────────────────
  final String savedGameTitle;
  final String savedGameBody;
  final String savedGameNew;
  final String savedGameContinue;

  // ─── Zorluk Seviyeleri ────────────────────────────────────────────────────
  final String diffEasy;
  final String diffEasySub;
  final String diffMedium;
  final String diffMediumSub;
  final String diffHard;
  final String diffHardSub;
  final String diffDaily;

  // ─── GameScreen ───────────────────────────────────────────────────────────
  final String gameTitle;
  final String gamePause;
  final String gameResume;
  final String gameMistakes;       // "Hata"
  final String gameTime;           // "Süre"
  final String gameDiamondReward;  // "Ödül"
  final String gamePaused;           // "Oyun Duraklatıldı"
  final String gamePausedHint;       // "Devam etmek için ▶ tuşuna bas"
  final String gameCompleteTitle;
  final String gameCompleteSubtitle;
  final String gameCompletedBody;    // "Bu sudokuyu tamamladın ve\n💎 +{n} elmas kazandın."
  final String gameStartNew;         // "Yeni Oyun Başlat"
  final String gameCompleteTime;
  final String gameCompleteMistakes;
  final String gameCompleteDiamonds;
  final String gameCompletePlayAgain;
  final String gameCompleteGoHome;

  // ─── NumberPad ────────────────────────────────────────────────────────────
  final String numpadUndo;
  final String numpadErase;
  final String numpadNote;
  final String numpadHint;
  final String noteModeActive;     // "NOT MODU AKTİF — Sayı seç, hücreye not ekle"

  // ─── İpucu / Hint ─────────────────────────────────────────────────────────
  final String hintDialogTitle;
  final String hintDialogBody;
  final String hintWatchAd;
  final String hintAdCancel;       // "Vazgeç" / "Dismiss"
  final String hintAdFailed;       // "Reklam yüklenemedi, tekrar dene 🔄"
  final String hintUseDiamond;
  final String hintNoDiamondsTitle;
  final String hintNoDiamondsBody;
  final String hintSuccess;
  final String hintAlreadyFilled;
  final String hintNoCell;         // "Önce bir hücre seç 👆"

  // ─── DailyScreen ──────────────────────────────────────────────────────────
  final String dailyTitle;
  final String dailyNoPuzzle;
  final String dailyProgressDays;     // "{c} / {t} gün tamamlandı"
  final List<String> weekdays;
  final String monthlyProgress;
  final String monthlyBonus;
  final String dailyBonusChip;        // "Bonus: +{n} 💎"
  final String dailyPlay;             // "Oyna" (buton)
  final String dailyResume;           // "Devam" (kısa buton)
  final String dailyContinue;         // "Devam Et" (uzun)

  // Giriş yapılmamış banner
  final String streakSignInTitle;     // "Serine başla!"
  final String streakSignInBody;      // "Giriş yap... +{n} 💎 bonus kazan."

  // Streak Hero
  final String streakUpdating;        // "Veriler güncelleniyor..."
  final String streakCurrentDays;     // "{n} günlük seri!"
  final String streakBeginTitle;      // "Seriyi başlat!"
  final String streakBeginBody;       // "Her gün bir bulmaca çözerek..."
  final String streakMsg30;           // ≥30 gün mesajı
  final String streakMsg14;           // ≥14 gün mesajı
  final String streakMsg7;            // ≥7 gün mesajı
  final String streakMsg3;            // ≥3 gün mesajı
  final String streakMsg1;            // <3 gün mesajı

  // TodayCard durumları
  final String todayCompleted;        // "Bugün tamamlandı"
  final String todayPuzzle;           // "Bugünün bulmacası"
  final String todayDiamondsEarned;   // "+{n} elmas kazandın ✓"
  final String todaySignInEarn;       // "Giriş yaparak elmas ve bonus kazan"
  final String todayDiamondsBonus;    // "+{n} elmas • Aylık bonusa katıl"
  final String todayContinueHint;     // "Kaldığın yerden devam et"

  // Eski alanlar (kullanılanlar korundu)
  final String dailyPlayNow;
  final String dailyCompletedBadge;
  final String dailyCompletedToday;
  final String dailyMonthlyBonusJoin;
  final String streakDays;
  final String streakTitle;
  final String streakBest;
  final String calendarTitle;
  final String dailyCompleted;
  final String signInStreakCta;

  // ─── ProfileScreen ────────────────────────────────────────────────────────
  final String profilePuzzlesCompleted; // "{n} bulmaca tamamlandı"
  final String profileDiamonds;
  final String diamondCardSubtitle;     // "Toplam Kazandığın" / "Total Earned"
  final String statsCompletedTitle;     // "Tamamlanan Bulmacalar" / "Completed Puzzles"
  final String statsTotal;              // "Toplam: {n}" / "Total: {n}"
  final String profileSettings;
  final String settingsComingSoon;      // "Bu özellik yakında kullanılabilecek 🚀"
  final String settingsNotifications;
  final String settingsNotificationsSoon;
  final String settingsDarkMode;
  final String settingsDarkModeSoon;
  final String settingsHaptic;
  final String settingsAbout;
  final String settingsSignOut;
  final String signInPromptTitle;       // "Giriş Yapın" / "Sign In"
  final String signInPromptBody;        // "Elmas kazanmak..." / "Sign in to earn..."
  final String statsEasy;
  final String statsMedium;
  final String statsHard;
  final String statsDaily;

  // ─── AuthScreen ───────────────────────────────────────────────────────────
  final String authSignIn;
  final String authSignUp;
  final String authOr;                   // "veya" / "or"
  final String authDescription;          // "Giriş yap, istatistiklerini kaydet..."
  final String authSignInGoogle;
  final String authGoogleFailed;         // "Google girişi başarısız"
  final String authEmail;
  final String authEmailHint;            // "E-posta adresi" (input hint)
  final String authPassword;
  final String authPasswordHint;         // "Şifre" (input hint)
  final String authPasswordMinHint;      // "Şifre (en az 6 karakter)"
  final String authPasswordConfirmHint;  // "Şifreyi tekrar gir"
  final String authForgotPassword;
  final String authForgotPasswordSent;
  final String authEnterEmailFirst;      // "Önce e-posta adresini gir"
  final String authResetFailed;          // "Gönderilemedi"
  final String authSignInButton;
  final String authSignUpButton;
  final String authSignInToEarn;
  final String authEmailRequired;        // "E-posta ve şifre gerekli"
  final String authFillAllFields;        // "Tüm alanları doldur"
  final String authPasswordMismatch;     // "Şifreler eşleşmiyor"
  final String authPasswordTooShort;     // "Şifre en az 6 karakter olmalı"
  // Supabase hata mesajları
  final String authErrInvalidCredentials;
  final String authErrEmailNotConfirmed;
  final String authErrWeakPassword;
  final String authErrEmailAlreadyExists;
  final String authErrInvalidEmail;      // "Geçersiz e-posta adresi"
  final String authErrNetworkError;

  // ─── AboutScreen ──────────────────────────────────────────────────────────
  final String aboutTitle;            // "Uygulama Hakkında" / "About"
  final String aboutVersion;          // "Sürüm {v}" / "Version {v}"
  final String aboutSupport;          // "Destek" / "Support" (bölüm başlığı)
  final String aboutSupportEmail;     // "Destek E-postası" / "Support Email"
  final String aboutSupportEmailCopied; // "E-posta adresi kopyalandı"
  final String aboutRateApp;          // "Uygulamayı Puanla" / "Rate the App"
  final String aboutRateOnPlay;       // "Google Play'de değerlendir"
  final String aboutPackageCopied;    // "Paket adı kopyalandı"
  final String aboutLegal;            // "Yasal" / "Legal"
  final String aboutPrivacyPolicy;
  final String aboutTerms;
  final String aboutOpenSource;
  final String privacyPolicyContent;
  final String termsContent;

  // ─── Supabase Transaction Descriptions ────────────────────────────────────
  // Not: Bunlar DB'ye yazılır. Dil bağımsız tutmak için
  //      kısa İngilizce kod kullanılmasını öneririz (ör. "puzzle_complete_easy").
  //      Aşağıdakiler UI'da göstermek içindir.
  final String txEasyComplete;
  final String txMediumComplete;
  final String txHardComplete;
  final String txDailyComplete;
  final String txMonthlyBonus;
  final String txHintUsed;

  const AppStrings({
    required this.appName,
    required this.ok,
    required this.cancel,
    required this.close,
    required this.save,
    required this.loading,
    required this.errorGeneric,
    required this.navHome,
    required this.navDaily,
    required this.navProfile,
    required this.greetingMorning,
    required this.greetingAfternoon,
    required this.greetingEvening,
    required this.dailyBannerTitle,
    required this.dailyBannerSubtitle,
    required this.quickPlay,
    required this.statsTitle,
    required this.signInEarnDiamonds,
    required this.playerDefault,
    required this.diamondsLabel,
    required this.earnDiamonds,
    required this.savedGameTitle,
    required this.savedGameBody,
    required this.savedGameNew,
    required this.savedGameContinue,
    required this.diffEasy,
    required this.diffEasySub,
    required this.diffMedium,
    required this.diffMediumSub,
    required this.diffHard,
    required this.diffHardSub,
    required this.diffDaily,
    required this.gameTitle,
    required this.gamePause,
    required this.gameResume,
    required this.gameMistakes,
    required this.gameTime,
    required this.gameDiamondReward,
    required this.gamePaused,
    required this.gamePausedHint,
    required this.gameCompleteTitle,
    required this.gameCompleteSubtitle,
    required this.gameCompletedBody,
    required this.gameStartNew,
    required this.gameCompleteTime,
    required this.gameCompleteMistakes,
    required this.gameCompleteDiamonds,
    required this.gameCompletePlayAgain,
    required this.gameCompleteGoHome,
    required this.numpadUndo,
    required this.numpadErase,
    required this.numpadNote,
    required this.numpadHint,
    required this.noteModeActive,
    required this.hintDialogTitle,
    required this.hintDialogBody,
    required this.hintWatchAd,
    required this.hintAdCancel,
    required this.hintAdFailed,
    required this.hintUseDiamond,
    required this.hintNoDiamondsTitle,
    required this.hintNoDiamondsBody,
    required this.hintSuccess,
    required this.hintAlreadyFilled,
    required this.hintNoCell,
    required this.dailyTitle,
    required this.dailyNoPuzzle,
    required this.dailyProgressDays,
    required this.weekdays,
    required this.monthlyProgress,
    required this.monthlyBonus,
    required this.dailyBonusChip,
    required this.dailyPlay,
    required this.dailyResume,
    required this.dailyContinue,
    required this.streakSignInTitle,
    required this.streakSignInBody,
    required this.streakUpdating,
    required this.streakCurrentDays,
    required this.streakBeginTitle,
    required this.streakBeginBody,
    required this.streakMsg30,
    required this.streakMsg14,
    required this.streakMsg7,
    required this.streakMsg3,
    required this.streakMsg1,
    required this.todayCompleted,
    required this.todayPuzzle,
    required this.todayDiamondsEarned,
    required this.todaySignInEarn,
    required this.todayDiamondsBonus,
    required this.todayContinueHint,
    required this.dailyPlayNow,
    required this.dailyCompletedBadge,
    required this.dailyCompletedToday,
    required this.dailyMonthlyBonusJoin,
    required this.streakDays,
    required this.streakTitle,
    required this.streakBest,
    required this.calendarTitle,
    required this.dailyCompleted,
    required this.signInStreakCta,
    required this.profilePuzzlesCompleted,
    required this.profileDiamonds,
    required this.diamondCardSubtitle,
    required this.statsCompletedTitle,
    required this.statsTotal,
    required this.profileSettings,
    required this.settingsComingSoon,
    required this.settingsNotifications,
    required this.settingsNotificationsSoon,
    required this.settingsDarkMode,
    required this.settingsDarkModeSoon,
    required this.settingsHaptic,
    required this.settingsAbout,
    required this.settingsSignOut,
    required this.signInPromptTitle,
    required this.signInPromptBody,
    required this.statsEasy,
    required this.statsMedium,
    required this.statsHard,
    required this.statsDaily,
    required this.authSignIn,
    required this.authSignUp,
    required this.authOr,
    required this.authDescription,
    required this.authSignInGoogle,
    required this.authGoogleFailed,
    required this.authEmail,
    required this.authEmailHint,
    required this.authPassword,
    required this.authPasswordHint,
    required this.authPasswordMinHint,
    required this.authPasswordConfirmHint,
    required this.authForgotPassword,
    required this.authForgotPasswordSent,
    required this.authEnterEmailFirst,
    required this.authResetFailed,
    required this.authSignInButton,
    required this.authSignUpButton,
    required this.authSignInToEarn,
    required this.authEmailRequired,
    required this.authFillAllFields,
    required this.authPasswordMismatch,
    required this.authPasswordTooShort,
    required this.authErrInvalidCredentials,
    required this.authErrEmailNotConfirmed,
    required this.authErrWeakPassword,
    required this.authErrEmailAlreadyExists,
    required this.authErrInvalidEmail,
    required this.authErrNetworkError,
    required this.aboutTitle,
    required this.aboutVersion,
    required this.aboutSupport,
    required this.aboutSupportEmail,
    required this.aboutSupportEmailCopied,
    required this.aboutRateApp,
    required this.aboutRateOnPlay,
    required this.aboutPackageCopied,
    required this.aboutLegal,
    required this.aboutPrivacyPolicy,
    required this.aboutTerms,
    required this.aboutOpenSource,
    required this.privacyPolicyContent,
    required this.termsContent,
    required this.txEasyComplete,
    required this.txMediumComplete,
    required this.txHardComplete,
    required this.txDailyComplete,
    required this.txMonthlyBonus,
    required this.txHintUsed,
  });

  // ─── TÜRKÇE ───────────────────────────────────────────────────────────────
  static const tr = AppStrings(
    appName: 'ZeNN Sudoku',
    ok: 'Tamam',
    cancel: 'İptal',
    close: 'Kapat',
    save: 'Kaydet',
    loading: 'Yükleniyor...',
    errorGeneric: 'Bir hata oluştu. Lütfen tekrar deneyin.',

    navHome: 'Ana Sayfa',
    navDaily: 'Günlük',
    navProfile: 'Profil',

    greetingMorning: 'Günaydın',
    greetingAfternoon: 'İyi günler',
    greetingEvening: 'İyi akşamlar',
    dailyBannerTitle: 'Günün Sudokusu',
    dailyBannerSubtitle: 'Bugünkü bulmacayı çöz',
    quickPlay: 'Hızlı Oyun',
    statsTitle: 'İstatistikler',
    signInEarnDiamonds: 'Giriş yap, 10 Elmas kazan',

    playerDefault: 'Oyuncu',
    diamondsLabel: 'Kazan',
    earnDiamonds: '+{n} Elmas kazan',
    savedGameTitle: 'Kayıtlı Oyun',
    savedGameBody: 'Kaldığın yerden devam etmek ister misin?',
    savedGameNew: 'Yeni Oyun',
    savedGameContinue: 'Devam Et',
    diffEasy: 'Kolay',
    diffEasySub: 'Başlangıç',
    diffMedium: 'Orta',
    diffMediumSub: 'Orta Seviye',
    diffHard: 'Zor',
    diffHardSub: 'Uzman',
    diffDaily: 'Günlük',

    gameTitle: 'Sudoku',
    gamePause: 'Duraklat',
    gameResume: 'Devam Et',
    gameMistakes: 'Hata',
    gameTime: 'Süre',
    gameDiamondReward: 'Ödül',
    gamePaused: 'Oyun Duraklatıldı',
    gamePausedHint: 'Devam etmek için ▶ tuşuna bas',
    gameCompleteTitle: 'Tebrikler! 🎉',
    gameCompleteSubtitle: 'Sudokuyu tamamladın!',
    gameCompletedBody: 'Bu sudokuyu tamamladın ve\n💎 +{n} elmas kazandın.',
    gameStartNew: 'Yeni Oyun Başlat',
    gameCompleteTime: 'Süre',
    gameCompleteMistakes: 'Hata',
    gameCompleteDiamonds: 'Elmas',
    gameCompletePlayAgain: 'Tekrar Oyna',
    gameCompleteGoHome: 'Ana Sayfaya Dön',

    numpadUndo: 'Geri Al',
    numpadErase: 'Sil',
    numpadNote: 'Not',
    numpadHint: 'İpucu',
    noteModeActive: 'NOT MODU AKTİF — Sayı seç, hücreye not ekle',

    hintDialogTitle: 'İpucu Kullan',
    hintDialogBody: '1 elmas harcanacak. Onaylıyor musun?',
    hintWatchAd: 'Reklam İzle',
    hintAdCancel: 'Vazgeç',
    hintAdFailed: 'Reklam yüklenemedi, tekrar dene 🔄',
    hintUseDiamond: '1 Elmas Kullan',
    hintNoDiamondsTitle: 'Elmas Yetersiz 💎',
    hintNoDiamondsBody: 'İpucu için yeterli elmasın yok.\nKısa bir reklam izleyerek ücretsiz ipucu alabilirsin.',
    hintSuccess: 'İpucu uygulandı',
    hintAlreadyFilled: 'Bu hücre zaten dolu',
    hintNoCell: 'Önce bir hücre seç 👆',

    dailyTitle: 'Günün Sudokusu',
    dailyNoPuzzle: 'Bugün için bulmaca hazır değil. Yakında!',
    dailyProgressDays: '{c} / {t} gün tamamlandı',
    weekdays: ['Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pz'],
    monthlyProgress: 'Aylık İlerleme',
    monthlyBonus: 'Aylık Bonus',
    dailyBonusChip: 'Bonus: +{n} 💎',
    dailyPlay: 'Oyna',
    dailyResume: 'Devam',
    dailyContinue: 'Devam Et',
    streakSignInTitle: 'Serine başla!',
    streakSignInBody: 'Giriş yap, günlük serini takip et ve aylık\n+{n} 💎 bonus kazan.',
    streakUpdating: 'Veriler güncelleniyor...',
    streakCurrentDays: '{n} günlük seri!',
    streakBeginTitle: 'Seriyi başlat!',
    streakBeginBody: 'Her gün bir bulmaca çözerek serine başla ve aylık bonusu kazan.',
    streakMsg30: 'Mükemmel! Tam ay boyunca hiç bırakmadın 🏆',
    streakMsg14: 'İnanılmaz! 2 haftadır her gün çözüyorsun 🌟',
    streakMsg7: 'Harika! Bir haftadır kesintisiz devam ediyorsun ⚡',
    streakMsg3: 'Güzel başlangıç! Devam edersen aylık bonusu kazanabilirsin.',
    streakMsg1: 'Güzel! Seriyi korumaya devam et, her gün bir adım.',
    todayCompleted: 'Bugün tamamlandı',
    todayPuzzle: 'Bugünün bulmacası',
    todayDiamondsEarned: '+{n} elmas kazandın ✓',
    todaySignInEarn: 'Giriş yaparak elmas ve bonus kazan',
    todayDiamondsBonus: '+{n} elmas • Aylık bonusa katıl',
    todayContinueHint: 'Kaldığın yerden devam et',
    dailyPlayNow: 'Şimdi Oyna',
    dailyCompletedBadge: 'Tamamlandı',
    dailyCompletedToday: 'Bugün tamamlandı ✓',
    dailyMonthlyBonusJoin: 'Aylık Bonusa Katıl',
    streakDays: '{n} Gün',
    streakTitle: 'Mevcut Seri',
    streakBest: 'En İyi Seri',
    calendarTitle: 'Bu Ay',
    dailyCompleted: 'Bugünkü bulmacayı tamamladın! 🎉',
    signInStreakCta: 'Giriş yap, serini takip et ve aylık bonus kazan',

    profilePuzzlesCompleted: '{n} bulmaca tamamlandı',
    profileDiamonds: 'Elmaslarım',
    diamondCardSubtitle: 'Toplam Kazandığın',
    statsCompletedTitle: 'Tamamlanan Bulmacalar',
    statsTotal: 'Toplam: {n}',
    profileSettings: 'Ayarlar',
    settingsComingSoon: 'Bu özellik yakında kullanılabilecek 🚀',
    settingsNotifications: 'Bildirimler',
    settingsNotificationsSoon: 'Yakında',
    settingsDarkMode: 'Karanlık Mod',
    settingsDarkModeSoon: 'Yakında',
    settingsHaptic: 'Titreşim',
    settingsAbout: 'Uygulama Hakkında',
    settingsSignOut: 'Çıkış Yap',
    signInPromptTitle: 'Giriş Yapın',
    signInPromptBody: 'Elmas kazanmak ve istatistiklerinizi\ntakip etmek için giriş yapın.',
    statsEasy: 'Kolay',
    statsMedium: 'Orta',
    statsHard: 'Zor',
    statsDaily: 'Günlük',

    authSignIn: 'Giriş Yap',
    authSignUp: 'Kayıt Ol',
    authOr: 'veya',
    authDescription: 'Giriş yap, istatistiklerini kaydet\nve elmas kazan.',
    authSignInGoogle: 'Google ile Giriş Yap',
    authGoogleFailed: 'Google girişi başarısız',
    authEmail: 'E-posta',
    authEmailHint: 'E-posta adresi',
    authPassword: 'Şifre',
    authPasswordHint: 'Şifre',
    authPasswordMinHint: 'Şifre (en az 6 karakter)',
    authPasswordConfirmHint: 'Şifreyi tekrar gir',
    authForgotPassword: 'Şifremi unuttum',
    authForgotPasswordSent: 'Şifre sıfırlama linki gönderildi',
    authEnterEmailFirst: 'Önce e-posta adresini gir',
    authResetFailed: 'Gönderilemedi',
    authSignInButton: 'Giriş Yap',
    authSignUpButton: 'Kayıt Ol',
    authSignInToEarn: 'Giriş yap, 10 elmas kazan',
    authEmailRequired: 'E-posta ve şifre gerekli',
    authFillAllFields: 'Tüm alanları doldur',
    authPasswordMismatch: 'Şifreler eşleşmiyor',
    authPasswordTooShort: 'Şifre en az 6 karakter olmalı',
    authErrInvalidCredentials: 'E-posta veya şifre hatalı',
    authErrEmailNotConfirmed: 'E-posta adresin henüz doğrulanmamış.',
    authErrWeakPassword: 'Şifre en az 6 karakter olmalı',
    authErrEmailAlreadyExists: 'Bu e-posta zaten kayıtlı',
    authErrInvalidEmail: 'Geçersiz e-posta adresi',
    authErrNetworkError: 'Bağlantı hatası. İnternet bağlantını kontrol et.',

    aboutTitle: 'Uygulama Hakkında',
    aboutVersion: 'Sürüm {v}',
    aboutSupport: 'Destek',
    aboutSupportEmail: 'Destek E-postası',
    aboutSupportEmailCopied: 'E-posta adresi kopyalandı',
    aboutRateApp: 'Uygulamayı Puanla',
    aboutRateOnPlay: "Google Play'de değerlendir",
    aboutPackageCopied: 'Paket adı kopyalandı',
    aboutLegal: 'Yasal',
    aboutPrivacyPolicy: 'Gizlilik Politikası',
    aboutTerms: 'Kullanım Koşulları',
    aboutOpenSource: 'Açık Kaynak Lisansları',
    privacyPolicyContent: '''Son güncelleme: Mayıs 2026

Zenn App Studio olarak gizliliğinizi ciddiye alıyoruz. Bu politika, ZeNN Sudoku uygulamasının hangi verileri topladığını ve nasıl kullandığını açıklamaktadır.

1. Toplanan Veriler

Uygulamamız aşağıdaki verileri toplar:

• Hesap bilgileri: Google ile giriş yaptığınızda adınız, e-posta adresiniz ve profil fotoğrafınız Supabase altyapımızda saklanır.
• Oyun verileri: Tamamladığınız bulmacalar, kazandığınız elmaslar ve oyun istatistikleriniz hesabınıza bağlı olarak kaydedilir.
• Cihaz verileri: Uygulama performansı için anonim kullanım istatistikleri toplanabilir.

2. Verilerin Kullanımı

Toplanan veriler yalnızca şu amaçlarla kullanılır:

• Oyun ilerlemenizi ve istatistiklerinizi kaydetmek
• Liderboard gibi sosyal özellikleri sunmak
• Uygulama deneyimini iyileştirmek

Verileriniz üçüncü taraflarla paylaşılmaz, reklam amaçlı kullanılmaz veya satılmaz.

3. Veri Güvenliği

Verileriniz Supabase altyapısında güvenli biçimde saklanmakta ve SSL/TLS şifreleme ile korunmaktadır.

4. Veri Silme

Hesabınızı ve tüm verilerinizi silmek için hello@zennappstudio.com adresine e-posta gönderebilirsiniz. Talebiniz 30 gün içinde işleme alınır.

5. İletişim

Gizlilik politikamız hakkında sorularınız için:
hello@zennappstudio.com''',
    termsContent: '''Son güncelleme: Mayıs 2026

ZeNN Sudoku uygulamasını kullanarak aşağıdaki koşulları kabul etmiş sayılırsınız.

1. Uygulamanın Kullanımı

ZeNN Sudoku kişisel ve eğlence amaçlı kullanım için sunulmaktadır. Uygulamayı yasa dışı amaçlarla veya başkalarına zarar verecek şekilde kullanamazsınız.

2. Hesap

Google hesabınızla giriş yaparak oluşturduğunuz profil size aittir. Hesabınızın güvenliğinden siz sorumlusunuz. Hesabınızı başkalarıyla paylaşmamanızı öneririz.

3. Elmas Sistemi

Uygulama içindeki elmaslar yalnızca uygulama içi değere sahiptir; gerçek para karşılığı nakde çevrilemez veya transfer edilemez. Zenn App Studio, elmas sisteminde değişiklik yapma hakkını saklı tutar.

4. Güncellemeler

Uygulamayı ve bu koşulları önceden bildirmeksizin güncelleme hakkımızı saklı tutarız. Güncellemeden sonra uygulamayı kullanmaya devam etmeniz yeni koşulları kabul ettiğiniz anlamına gelir.

5. Sorumluluk Sınırı

Zenn App Studio, uygulama kesintileri, veri kayıpları veya beklenmedik hatalardan doğan zararlardan sorumlu tutulamaz. Uygulama "olduğu gibi" sunulmaktadır.

6. İletişim

Kullanım koşullarına ilişkin sorularınız için:
hello@zennappstudio.com''',

    txEasyComplete: 'Kolay bulmaca tamamlandı',
    txMediumComplete: 'Orta bulmaca tamamlandı',
    txHardComplete: 'Zor bulmaca tamamlandı',
    txDailyComplete: 'Günlük bulmaca tamamlandı',
    txMonthlyBonus: 'Aylık tamamlama bonusu',
    txHintUsed: 'İpucu kullanıldı',
  );

  // ─── İNGİLİZCE ────────────────────────────────────────────────────────────
  static const en = AppStrings(
    appName: 'ZeNN Sudoku',
    ok: 'OK',
    cancel: 'Cancel',
    close: 'Close',
    save: 'Save',
    loading: 'Loading...',
    errorGeneric: 'Something went wrong. Please try again.',

    navHome: 'Home',
    navDaily: 'Daily',
    navProfile: 'Profile',

    greetingMorning: 'Good morning',
    greetingAfternoon: 'Good afternoon',
    greetingEvening: 'Good evening',
    dailyBannerTitle: "Today's Sudoku",
    dailyBannerSubtitle: 'Solve the daily puzzle',
    quickPlay: 'Quick Play',
    statsTitle: 'Statistics',
    signInEarnDiamonds: 'Sign in to earn 10 Diamonds',

    playerDefault: 'Player',
    diamondsLabel: 'Win',
    earnDiamonds: '+{n} Diamonds',
    savedGameTitle: 'Saved Game',
    savedGameBody: 'Would you like to continue where you left off?',
    savedGameNew: 'New Game',
    savedGameContinue: 'Continue',
    diffEasy: 'Easy',
    diffEasySub: 'Beginner',
    diffMedium: 'Medium',
    diffMediumSub: 'Intermediate',
    diffHard: 'Hard',
    diffHardSub: 'Expert',
    diffDaily: 'Daily',

    gameTitle: 'Sudoku',
    gamePause: 'Pause',
    gameResume: 'Resume',
    gameMistakes: 'Mistakes',
    gameTime: 'Time',
    gameDiamondReward: 'Reward',
    gamePaused: 'Game Paused',
    gamePausedHint: 'Tap ▶ to resume',
    gameCompleteTitle: 'Congratulations! 🎉',
    gameCompleteSubtitle: 'Puzzle complete!',
    gameCompletedBody: 'You completed this puzzle and\nearned 💎 +{n} diamonds.',
    gameStartNew: 'Start New Game',
    gameCompleteTime: 'Time',
    gameCompleteMistakes: 'Mistakes',
    gameCompleteDiamonds: 'Diamonds',
    gameCompletePlayAgain: 'Play Again',
    gameCompleteGoHome: 'Go Home',

    numpadUndo: 'Undo',
    numpadErase: 'Erase',
    numpadNote: 'Note',
    numpadHint: 'Hint',
    noteModeActive: 'NOTE MODE — Select a number to add a note',

    hintDialogTitle: 'Use a Hint',
    hintDialogBody: 'This will cost 1 diamond. Continue?',
    hintWatchAd: 'Watch Ad',
    hintAdCancel: 'Dismiss',
    hintAdFailed: 'Ad failed to load, try again 🔄',
    hintUseDiamond: 'Use 1 Diamond',
    hintNoDiamondsTitle: 'Not Enough Diamonds 💎',
    hintNoDiamondsBody: "You don't have enough diamonds.\nWatch a short ad to get a free hint.",
    hintSuccess: 'Hint applied',
    hintAlreadyFilled: 'This cell is already filled',
    hintNoCell: 'Select a cell first 👆',

    dailyTitle: "Today's Sudoku",
    dailyNoPuzzle: 'No puzzle available today. Coming soon!',
    dailyProgressDays: '{c} / {t} days completed',
    weekdays: ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'],
    monthlyProgress: 'Monthly Progress',
    monthlyBonus: 'Monthly Bonus',
    dailyBonusChip: 'Bonus: +{n} 💎',
    dailyPlay: 'Play',
    dailyResume: 'Resume',
    dailyContinue: 'Continue',
    streakSignInTitle: 'Start your streak!',
    streakSignInBody: 'Sign in to track your daily streak\nand earn a monthly +{n} 💎 bonus.',
    streakUpdating: 'Updating...',
    streakCurrentDays: '{n} day streak!',
    streakBeginTitle: 'Start your streak!',
    streakBeginBody: 'Solve a puzzle every day to build your streak and earn a monthly bonus.',
    streakMsg30: "Perfect! You haven't missed a day all month 🏆",
    streakMsg14: "Amazing! You've been solving every day for 2 weeks 🌟",
    streakMsg7: "Great! You've kept it up for a whole week ⚡",
    streakMsg3: 'Great start! Keep going to earn the monthly bonus.',
    streakMsg1: 'Nice! Keep the streak alive, one day at a time.',
    todayCompleted: 'Completed today',
    todayPuzzle: "Today's puzzle",
    todayDiamondsEarned: '+{n} diamonds earned ✓',
    todaySignInEarn: 'Sign in to earn diamonds and bonuses',
    todayDiamondsBonus: '+{n} diamonds • Join monthly bonus',
    todayContinueHint: 'Continue where you left off',
    dailyPlayNow: 'Play Now',
    dailyCompletedBadge: 'Completed',
    dailyCompletedToday: 'Completed today ✓',
    dailyMonthlyBonusJoin: 'Join Monthly Bonus',
    streakDays: '{n} Days',
    streakTitle: 'Current Streak',
    streakBest: 'Best Streak',
    calendarTitle: 'This Month',
    dailyCompleted: "Today's puzzle complete! 🎉",
    signInStreakCta: 'Sign in to track your streak and earn monthly bonuses',

    profilePuzzlesCompleted: '{n} puzzles completed',
    profileDiamonds: 'My Diamonds',
    diamondCardSubtitle: 'Total Earned',
    statsCompletedTitle: 'Completed Puzzles',
    statsTotal: 'Total: {n}',
    profileSettings: 'Settings',
    settingsComingSoon: 'This feature is coming soon 🚀',
    settingsNotifications: 'Notifications',
    settingsNotificationsSoon: 'Coming soon',
    settingsDarkMode: 'Dark Mode',
    settingsDarkModeSoon: 'Coming soon',
    settingsHaptic: 'Haptic Feedback',
    settingsAbout: 'About',
    settingsSignOut: 'Sign Out',
    signInPromptTitle: 'Sign In',
    signInPromptBody: 'Sign in to earn diamonds\nand track your statistics.',
    statsEasy: 'Easy',
    statsMedium: 'Medium',
    statsHard: 'Hard',
    statsDaily: 'Daily',

    authSignIn: 'Sign In',
    authSignUp: 'Sign Up',
    authOr: 'or',
    authDescription: 'Sign in, save your stats\nand earn diamonds.',
    authSignInGoogle: 'Continue with Google',
    authGoogleFailed: 'Google sign-in failed',
    authEmail: 'Email',
    authEmailHint: 'Email address',
    authPassword: 'Password',
    authPasswordHint: 'Password',
    authPasswordMinHint: 'Password (min. 6 characters)',
    authPasswordConfirmHint: 'Confirm password',
    authForgotPassword: 'Forgot password?',
    authForgotPasswordSent: 'Password reset link sent',
    authEnterEmailFirst: 'Please enter your email address first',
    authResetFailed: 'Failed to send',
    authSignInButton: 'Sign In',
    authSignUpButton: 'Create Account',
    authSignInToEarn: 'Sign in to earn 10 diamonds',
    authEmailRequired: 'Email and password are required',
    authFillAllFields: 'Please fill in all fields',
    authPasswordMismatch: 'Passwords do not match',
    authPasswordTooShort: 'Password must be at least 6 characters',
    authErrInvalidCredentials: 'Incorrect email or password',
    authErrEmailNotConfirmed: 'Your email address has not been verified yet.',
    authErrWeakPassword: 'Password must be at least 6 characters',
    authErrEmailAlreadyExists: 'An account with this email already exists',
    authErrInvalidEmail: 'Invalid email address',
    authErrNetworkError: 'Connection error. Please check your internet.',

    aboutTitle: 'About',
    aboutVersion: 'Version {v}',
    aboutSupport: 'Support',
    aboutSupportEmail: 'Support Email',
    aboutSupportEmailCopied: 'Email address copied',
    aboutRateApp: 'Rate the App',
    aboutRateOnPlay: 'Rate on Google Play',
    aboutPackageCopied: 'Package name copied',
    aboutLegal: 'Legal',
    aboutPrivacyPolicy: 'Privacy Policy',
    aboutTerms: 'Terms of Use',
    aboutOpenSource: 'Open Source Licenses',
    privacyPolicyContent: '''Last updated: May 2026

At Zenn App Studio, we take your privacy seriously. This policy explains what data ZeNN Sudoku collects and how it is used.

1. Data We Collect

Our app collects the following data:

• Account information: When you sign in with Google, your name, email address, and profile photo are stored in our Supabase infrastructure.
• Game data: Completed puzzles, earned diamonds, and game statistics are saved to your account.
• Device data: Anonymous usage statistics may be collected to improve app performance.

2. How We Use Your Data

Collected data is used solely for the following purposes:

• Saving your game progress and statistics
• Providing social features such as leaderboards
• Improving the app experience

Your data is never shared with third parties, used for advertising, or sold.

3. Data Security

Your data is stored securely in Supabase infrastructure and protected with SSL/TLS encryption.

4. Data Deletion

To delete your account and all associated data, please email hello@zennappstudio.com. Your request will be processed within 30 days.

5. Contact

If you have questions about our privacy policy:
hello@zennappstudio.com''',
    termsContent: '''Last updated: May 2026

By using the ZeNN Sudoku app, you agree to the following terms.

1. Use of the App

ZeNN Sudoku is provided for personal and entertainment use. You may not use the app for illegal purposes or in any way that could harm others.

2. Account

The profile you create by signing in with your Google account belongs to you. You are responsible for the security of your account. We recommend not sharing your account with others.

3. Diamond System

Diamonds within the app have in-app value only; they cannot be converted to cash or transferred for real money. Zenn App Studio reserves the right to make changes to the diamond system.

4. Updates

We reserve the right to update the app and these terms without prior notice. Continued use of the app after an update constitutes acceptance of the new terms.

5. Limitation of Liability

Zenn App Studio cannot be held liable for damages arising from app interruptions, data loss, or unexpected errors. The app is provided "as is".

6. Contact

If you have questions about these terms:
hello@zennappstudio.com''',

    txEasyComplete: 'Easy puzzle completed',
    txMediumComplete: 'Medium puzzle completed',
    txHardComplete: 'Hard puzzle completed',
    txDailyComplete: 'Daily puzzle completed',
    txMonthlyBonus: 'Monthly completion bonus',
    txHintUsed: 'Hint used',
  );
}