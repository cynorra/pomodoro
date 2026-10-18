import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/models/cafe_item.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/services/audio_service.dart';
import '../../../core/data/services/cafe_purchase_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../monetization/presentation/rewarded_ad_button.dart';
import 'cafe_notifier.dart';

class VirtualCafeScreen extends ConsumerStatefulWidget {
  const VirtualCafeScreen({super.key});

  @override
  ConsumerState<VirtualCafeScreen> createState() => _VirtualCafeScreenState();
}

class _VirtualCafeScreenState extends ConsumerState<VirtualCafeScreen> {
  @override
  Widget build(BuildContext context) {
    final cafeItemsAsync = ref.watch(cafeItemsProvider);
    final l10n = AppLocalizations.of(context);
    final currentSound = AudioService.currentSound;

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n?.virtualCafe ?? 'Sanal Kafe',
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          Semantics(
            button: true,
            label: l10n?.selectAmbientSound ?? 'Ortam sesi seç',
            child: IconButton(
              icon: Icon(
                currentSound != null ? Icons.volume_up : Icons.volume_off,
                color: ZyraColors.primary,
              ),
              onPressed: () {
                _showSoundSelector();
              },
            ),
          ),
        ],
      ),
      body: cafeItemsAsync.when(
        data: (items) => CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: const RewardedAdButton(),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = items[index];
                    return _CafeItemCard(item: item);
                  },
                  childCount: items.length,
                ),
              ),
            ),
          ],
        ),
        loading: () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => Container(
              decoration: BoxDecoration(
                color: ZyraColors.surface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Shimmer.fromColors(
                baseColor: ZyraColors.surface,
                highlightColor: ZyraColors.primary.withOpacity(0.1),
                child: Container(color: Colors.white),
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            l10n?.somethingWentWrong ?? 'Bir hata oluştu',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  void _showSoundSelector() {
    final l10n = AppLocalizations.of(context);
    final currentSound = AudioService.currentSound;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.selectAmbientSound ?? 'Ortam Sesi Seç',
              style: ZyraTypography.titleMedium.copyWith(
                color: ZyraColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            _SoundOption(
              icon: '🌧️',
              label: l10n?.rain ?? 'Yağmur',
              isSelected: currentSound == 'rain.mp3',
              onTap: () => _selectSound('rain.mp3', sheetContext),
            ),
            _SoundOption(
              icon: '☕',
              label: l10n?.coffeeShop ?? 'Kahve Dükkanı',
              isSelected: currentSound == 'coffee_shop.mp3',
              onTap: () => _selectSound('coffee_shop.mp3', sheetContext),
            ),
            _SoundOption(
              icon: '🔥',
              label: l10n?.fireplace ?? 'Şömine',
              isSelected: currentSound == 'fireplace.mp3',
              onTap: () => _selectSound('fireplace.mp3', sheetContext),
            ),
            _SoundOption(
              icon: '🎵',
              label: l10n?.lofiBeats ?? 'Lo-Fi Beats',
              isSelected: currentSound == 'lofi_beats.mp3',
              onTap: () => _selectSound('lofi_beats.mp3', sheetContext),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                l10n?.close ?? 'Kapat',
                style: ZyraTypography.labelLarge.copyWith(
                  color: ZyraColors.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            if (currentSound != null) ...[
              TextButton(
                onPressed: () {
                  AudioService.stopAmbient();
                  Navigator.pop(sheetContext);
                  if (mounted) setState(() {});
                },
                child: Text(
                  l10n?.turnOffSound ?? 'Sesi Kapat',
                  style: ZyraTypography.labelLarge.copyWith(
                    color: ZyraColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectSound(String soundFile, BuildContext sheetContext) async {
    try {
      await AudioService.playAmbient(soundFile);
      Navigator.pop(sheetContext);
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.somethingWentWrong ?? 'Ses çalınamadı',
            ),
            backgroundColor: Colors.red.shade900,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}

class _CafeItemCard extends ConsumerStatefulWidget {
  final CafeItem item;
  const _CafeItemCard({required this.item});

  @override
  ConsumerState<_CafeItemCard> createState() => _CafeItemCardState();
}

class _CafeItemCardState extends ConsumerState<_CafeItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isTr = l10n?.localeName == 'tr';
    final name = isTr ? widget.item.nameTr : widget.item.nameEn;

    return Semantics(
      button: true,
      label: l10n?.buyItem(name, widget.item.cost) ??
          '$name satın al, ${widget.item.cost} puan',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) async {
          if (!mounted) return;
          setState(() => _isPressed = false);

          if (widget.item.isOwned) {
            return;
          }

          final userState = ref.read(userProvider);
          final result = await CafePurchaseService.purchase(
            itemId: widget.item.itemId,
            userPoints: userState.totalPoints,
            ref: ref,
          );

          if (!mounted) return;

          if (result == PurchaseResult.insufficientPoints) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.insufficientPoints ?? 'Yetersiz Puan! 🎯',
                ),
                backgroundColor: Colors.red.shade900,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (result == PurchaseResult.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  l10n?.purchaseSuccess ?? 'Satın alındı! ☕',
                ),
                backgroundColor: Colors.green.shade900,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            1.0,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: ZyraColors.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.item.isOwned
                    ? ZyraColors.primary.withOpacity(0.5)
                    : ZyraColors.secondary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 60,
                        child: Text(
                          widget.item.iconCode,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        name,
                        style: ZyraTypography.titleMedium.copyWith(
                          color: ZyraColors.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ZyraColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.item.cost} ${l10n?.points ?? 'Puan'}',
                          style: ZyraTypography.labelLarge.copyWith(
                            color: ZyraColors.primary,
                          ),
                        ),
                      ),
                      if (widget.item.isOwned) ...[
                        const SizedBox(height: 8),
                        Text(
                          '${l10n?.inventory ?? 'Envanter'}: ${widget.item.quantity}',
                          style: ZyraTypography.labelSmall.copyWith(
                            color: ZyraColors.secondary,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoundOption extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(
        label,
        style: ZyraTypography.titleMedium.copyWith(
          color: isSelected ? ZyraColors.primary : ZyraColors.onSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: ZyraColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
