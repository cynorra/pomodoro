import 'package:flutter/foundation.dart';
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

  @override
  void initState() {
    super.initState();
    if (kReleaseMode && !AdService.bannerAdUnitId.contains('GERCEK')) _load();
  }

  void _load() {
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loaded) {
          if (_disposed) {
            loaded.dispose();
            return;
          }
          setState(() {
            _ad = loaded as BannerAd;
            _loaded = true;
          });
        },
        onAdFailedToLoad: (failed, error) {
          failed.dispose();
          if (!_disposed) setState(() => _loaded = false);
        },
      ),
    );
    ad.load();
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
    if (!_loaded || ad == null) {
      return const SizedBox(height: 50);
    }
    return SizedBox(height: 50, child: AdWidget(ad: ad));
  }
}
