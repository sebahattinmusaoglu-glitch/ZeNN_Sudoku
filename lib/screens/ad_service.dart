// lib/services/ad_service.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final instance = AdService._();

  // ── Banner ────────────────────────────────────────────────────────────────

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return const bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-1419242257837616/9933160527'
          : 'ca-app-pub-3940256099942544/6300978111'; // Test ID
    }
    return 'ca-app-pub-3940256099942544/2934735716'; // iOS test ID
  }

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  bool get isBannerLoaded => _isBannerLoaded;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadBanner({
    required void Function() onLoaded,
    void Function()? onFailed,
  }) async {
    await _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;

    _bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerLoaded = true;
          onLoaded();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          _isBannerLoaded = false;
          onFailed?.call();
        },
      ),
    );

    await _bannerAd!.load();
  }

  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerLoaded = false;
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return const bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-1419242257837616/6184047816'
          : 'ca-app-pub-3940256099942544/5224354917'; // Test ID
    }
    return 'ca-app-pub-3940256099942544/1712485313'; // iOS test ID
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// Ödüllü reklamı önceden yükler (ipucu butonuna basılmadan hazır olsun)
  Future<void> loadRewarded() async {
    if (_rewardedAd != null || _isRewardedLoading) return;
    _isRewardedLoading = true;

    await RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Ödüllü reklamı gösterir.
  /// [onRewarded] → kullanıcı reklamı izledi, ödülü ver
  /// [onDismissed] → reklam kapandı (ödüllü olsun ya da olmasın)
  /// [onFailed]    → reklam yüklenemedi veya gösterilemedi
  Future<void> showRewarded({
    required void Function() onRewarded,
    void Function()? onDismissed,
    void Function()? onFailed,
  }) async {
    if (_rewardedAd == null) {
      onFailed?.call();
      return;
    }

    bool rewarded = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onDismissed?.call();
        // Bir sonraki kullanım için yeniden yükle
        loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onFailed?.call();
        loadRewarded();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onRewarded();
      },
    );
  }

  void disposeRewarded() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}