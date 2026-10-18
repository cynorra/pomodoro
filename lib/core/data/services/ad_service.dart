import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../utils/global_exception_handler.dart';

class AdService {
  static RewardedAd? _rewardedAd;
  static bool _isInitialized = false;

  static String get bannerAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-GERCEK-ID/GERCEK-UNIT';

  static String get rewardedAdUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917'
      : 'ca-app-pub-GERCEK-ID/GERCEK-UNIT';

  // Release builds ship with placeholder ad unit IDs until real ones are set;
  // loading ads with them would only produce failed requests.
  static bool get _hasRealAdUnits =>
      kDebugMode || !rewardedAdUnitId.contains('GERCEK');

  static Future<void> initialize() async {
    if (_isInitialized || !_hasRealAdUnits) return;

    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      await _loadRewardedAd();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'AdMob init failed');
    }
  }

  static Future<void> _loadRewardedAd() async {
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
