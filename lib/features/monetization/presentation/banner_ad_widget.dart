import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/data/services/ad_service.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _ad;
  bool _loaded = false;
  bool _disposed = false;
  bool _isLoading = false;
  AdSize? _adSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isLoading && _ad == null && AdService.hasBannerAdUnit) {
      _loadAdaptiveBanner();
    }
  }

  Future<void> _loadAdaptiveBanner() async {
    _isLoading = true;
    final ready = await AdService.adsReady;
    if (!ready || _disposed || !mounted) {
      _isLoading = false;
      return;
    }

    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width.truncate();
    final orientation = mediaQuery.orientation;

    AdSize? size;
    try {
      size = await AdSize.getLargeAnchoredAdaptiveBannerAdSizeWithOrientation(
        orientation,
        width,
      );
    } catch (_) {
      size = null;
    }

    size ??= AdSize.banner;

    if (_disposed || !mounted) return;

    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          if (_disposed || !mounted) {
            loaded.dispose();
            return;
          }
          setState(() {
            _ad = loaded as BannerAd;
            _adSize = size;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failed, error) {
          // Kod 3 (no fill) veya herhangi bir yükleme hatasında sessizce dispose et
          failed.dispose();
          if (!_disposed && mounted) {
            setState(() {
              _loaded = false;
              _ad = null;
            });
          }
        },
      ),
    );

    await ad.load();
  }

  @override
  void dispose() {
    _disposed = true;
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    final size = _adSize;
    final screenWidth = MediaQuery.of(context).size.width;

    // Silent fail: Reklam yüklenmediğinde veya no-fill durumunda ekran kayması / boş kutu olmadan null/SizedBox.shrink döner
    if (!_loaded || ad == null || size == null) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(maxWidth: screenWidth),
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      alignment: Alignment.center,
      width: size.width.toDouble(),
      height: size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
