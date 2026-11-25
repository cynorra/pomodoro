import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/data/services/ad_service.dart';

class NativeAdCard extends StatefulWidget {
  const NativeAdCard({super.key});

  @override
  State<NativeAdCard> createState() => _NativeAdCardState();
}

class _NativeAdCardState extends State<NativeAdCard> {
  NativeAd? _ad;
  bool _loaded = false;
  bool _disposed = false;
  bool _started = false;
  Timer? _retryTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    AdService.adsReady.then((ok) {
      if (ok && !_disposed && mounted) _load();
    });
  }

  void _load() {
    if (_disposed || !mounted) return;
    final scheme = Theme.of(context).colorScheme;
    final ad = NativeAd(
      adUnitId: AdService.nativeAdUnitId,
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.small,
        mainBackgroundColor: scheme.surface,
        cornerRadius: 16,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: scheme.onPrimary,
          backgroundColor: scheme.primary,
        ),
        primaryTextStyle: NativeTemplateTextStyle(textColor: scheme.onSurface),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: scheme.onSurfaceVariant,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (loaded) {
          if (_disposed || !mounted) {
            loaded.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (failed, error) {
          failed.dispose();
          if (!_disposed && mounted) {
            setState(() {
              _ad = null;
              _loaded = false;
            });
            _retryTimer?.cancel();
            _retryTimer = Timer(const Duration(seconds: 30), () {
              if (!_disposed && mounted && _ad == null) {
                _load();
              }
            });
          }
        },
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _disposed = true;
    _retryTimer?.cancel();
    _ad?.dispose();
    _ad = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 90, maxHeight: 120),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
