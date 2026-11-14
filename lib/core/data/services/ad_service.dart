import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/global_exception_handler.dart';
import 'remote_config_service.dart';

class AdService {
  static const _focusSessionsPerInterstitial = 3;
  static const _minInterstitialGap = Duration(minutes: 5);

  static RewardedAd? _rewardedAdInstance;

  /// Lets the UI react when a rewarded ad becomes (un)available.
  static final ValueNotifier<bool> rewardedReady = ValueNotifier<bool>(false);

  static RewardedAd? get _rewardedAd => _rewardedAdInstance;
  static set _rewardedAd(RewardedAd? ad) {
    _rewardedAdInstance = ad;
    rewardedReady.value = ad != null;
  }
  static InterstitialAd? _interstitialAd;
  static int _focusSessionsSinceAd = 0;
  static DateTime? _lastInterstitialAt;
  static bool _isInitialized = false;

  // Sadece resmi canlı AdMob ID'leri (Test / DEV ID'leri kesinlikle kullanılmaz)
  static const String bannerAdUnitId = 'ca-app-pub-4674211063760769/7365067197';
  static const String interstitialAdUnitId = 'ca-app-pub-4674211063760769/1556627735';
  static const String nativeAdUnitId = 'ca-app-pub-4674211063760769/9799658844';
  static const String rewardedAdUnitId = 'ca-app-pub-4674211063760769/8433027271';

  // Release builds ship with placeholder ad unit IDs until real ones are set;
  // loading ads with them would only produce failed requests.
  static bool get hasBannerAdUnit =>
      kDebugMode || !bannerAdUnitId.contains('GERCEK');

  static bool get hasRewardedAdUnit => _hasRewardedAdUnit;

  static bool get _hasRewardedAdUnit =>
      kDebugMode || !rewardedAdUnitId.contains('GERCEK');

  static final Completer<bool> _adsReady = Completer<bool>();

  /// Completes once consent has been handled: true when ads may be requested.
  static Future<bool> get adsReady => _adsReady.future;

  static void _finishReady(bool ok) {
    if (!_adsReady.isCompleted) _adsReady.complete(ok);
  }

  /// Runs Google's User Messaging Platform flow (GDPR/UK consent form when
  /// the user's region requires one).
  static Future<void> _gatherConsent() async {
    final done = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        try {
          await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        } catch (e, stack) {
          GlobalExceptionHandler.logError(e, stack, 'Consent form failed');
        }
        if (!done.isCompleted) done.complete();
      },
      (error) {
        debugPrint('Consent info update failed: ${error.message}');
        if (!done.isCompleted) done.complete();
      },
    );
    await done.future;
  }

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _gatherConsent();
      if (!await ConsentInformation.instance.canRequestAds()) {
        _finishReady(false);
        return;
      }
      await MobileAds.instance.initialize();
      _isInitialized = true;
      _finishReady(true);
      unawaited(_loadInterstitialAd());
      if (_hasRewardedAdUnit && RemoteConfigService.enableRewardedAds) {
        await _loadRewardedAd();
      }
    } catch (e, stack) {
      _finishReady(false);
      GlobalExceptionHandler.logError(e, stack, 'AdMob init failed');
    }
  }

  static Future<void> _loadInterstitialAd() async {
    try {
      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) => _interstitialAd = ad,
          onAdFailedToLoad: (error) {
            debugPrint('Interstitial ad load failed: ${error.message}');
            _interstitialAd = null;
          },
        ),
      );
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Load interstitial ad failed');
    }
  }

  /// Called after every completed focus session; shows an interstitial on
  /// every [_focusSessionsPerInterstitial]th one, at most once per
  /// [_minInterstitialGap], so the ad never interrupts a running timer.
  static Future<void> onFocusSessionCompleted() async {
    _focusSessionsSinceAd++;
    if (_focusSessionsSinceAd < _focusSessionsPerInterstitial) return;
    final last = _lastInterstitialAt;
    if (last != null && DateTime.now().difference(last) < _minInterstitialGap) {
      return;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      unawaited(_loadInterstitialAd());
      return;
    }
    _interstitialAd = null;
    _focusSessionsSinceAd = 0;
    _lastInterstitialAt = DateTime.now();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
      },
    );
    try {
      await ad.show();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Show interstitial ad failed');
      ad.dispose();
      unawaited(_loadInterstitialAd());
    }
  }

  static Future<void> _loadRewardedAd() async {
    if (!_hasRewardedAdUnit) return;
    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                ad.dispose();
                _rewardedAd = null;
                _loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                ad.dispose();
                _rewardedAd = null;
                _loadRewardedAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            GlobalExceptionHandler.log(
              'Rewarded ad load failed: ${error.message}',
            );
            _rewardedAd = null;
          },
        ),
      );
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Load rewarded ad failed');
    }
  }

  static Future<RewardedAdResult> showRewardedAd() async {
    final ad = _rewardedAd;
    if (ad == null) {
      await _loadRewardedAd();
      return RewardedAdResult.notReady;
    }

    return await _showAdWithReward(ad);
  }

  static Future<RewardedAdResult> _showAdWithReward(
    RewardedAd ad,
  ) async {
    bool rewarded = false;

    try {
      await ad.show(
        onUserEarnedReward: (context, reward) {
          rewarded = true;
        },
      );

      await Future.delayed(const Duration(milliseconds: 500));
      return rewarded
          ? RewardedAdResult.rewarded
          : RewardedAdResult.notRewarded;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Show rewarded ad failed');
      ad.dispose();
      _rewardedAd = null;
      await _loadRewardedAd();
      return RewardedAdResult.error;
    }
  }

  static bool get isRewardedAdReady => _rewardedAd != null;

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

enum RewardedAdResult { rewarded, notRewarded, notReady, error }
