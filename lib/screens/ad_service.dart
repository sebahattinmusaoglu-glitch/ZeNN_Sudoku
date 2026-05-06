// lib/services/ad_service.dart
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final instance = AdService._();

  // Test cihazlarda test ID, production'da gerçek ID
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return const bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-1419242257837616/9933160527'   // Gerçek ID
          : 'ca-app-pub-3940256099942544/6300978111';  // Test ID
    }
    // iOS için buraya iOS banner ID eklenecek
    return 'ca-app-pub-3940256099942544/2934735716';   // iOS test ID
  }

  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;

  bool get isBannerLoaded => _isBannerLoaded;
  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadBanner({
    required void Function() onLoaded,
    void Function()? onFailed,
  }) async {
    _bannerAd?.dispose();
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
}