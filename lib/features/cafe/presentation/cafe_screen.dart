import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/services/audio_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../monetization/presentation/native_ad_card.dart';
import '../../monetization/presentation/rewarded_ad_button.dart';
import '../../social/presentation/send_treat_sheet.dart';
import 'cafe_item_widgets.dart';
import 'cafe_notifier.dart';

class VirtualCafeScreen extends ConsumerStatefulWidget {
  const VirtualCafeScreen({super.key});

  @override
  ConsumerState<VirtualCafeScreen> createState() => _VirtualCafeScreenState();
}

class _VirtualCafeScreenState extends ConsumerState<VirtualCafeScreen> {
  Set<String> _bundledSounds = {};

  @override
  void initState() {
    super.initState();
    AudioService.bundledSounds().then((sounds) {
      if (mounted) setState(() => _bundledSounds = sounds);
    });
  }

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
          l10n.virtualCafe,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
        actions: [
          if (_bundledSounds.isNotEmpty)
            Semantics(
              button: true,
              label: l10n.selectAmbientSound,
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
            const SliverToBoxAdapter(child: CafeStatus()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: const RewardedAdButton(),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: OutlinedButton.icon(
                  onPressed: () => showSendTreatSheet(context),
                  icon: const Icon(Icons.card_giftcard_rounded),
                  label: Text(l10n.sendTreat),
                ),
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
                    return CafeItemCard(item: item);
                  },
                  childCount: items.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: NativeAdCard()),
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
                color: ZyraColors.surface.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Shimmer.fromColors(
                baseColor: ZyraColors.surface,
                highlightColor: ZyraColors.primary.withValues(alpha: 0.1),
                child: Container(color: Colors.white),
              ),
            ),
          ),
        ),
        error: (err, stack) => Center(
          child: Text(
            l10n.somethingWentWrong,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }

  List<({String file, String icon, String label})> _soundChoices(
    AppLocalizations l10n,
  ) =>
      [
        (file: 'rain.mp3', icon: '🌧️', label: l10n.rain),
        (file: 'brown_noise.mp3', icon: '🎧', label: l10n.brownNoise),
        (file: 'fireplace.mp3', icon: '🔥', label: l10n.fireplace),
        (file: 'coffee_shop.mp3', icon: '☕', label: l10n.coffeeShop),
        (file: 'lofi_beats.mp3', icon: '🎵', label: l10n.lofiBeats),
      ];

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
              l10n.selectAmbientSound,
              style: ZyraTypography.titleMedium.copyWith(
                color: ZyraColors.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            for (final sound in _soundChoices(l10n))
              if (_bundledSounds.contains(sound.file))
                _SoundOption(
                  icon: sound.icon,
                  label: sound.label,
                  isSelected: currentSound == sound.file,
                  onTap: () => _selectSound(sound.file, sheetContext),
                ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(sheetContext),
              child: Text(
                l10n.close,
                style: ZyraTypography.labelLarge.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.6),
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
                  l10n.turnOffSound,
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
    final navigator = Navigator.of(sheetContext);
    try {
      await AudioService.playAmbient(soundFile);
      navigator.pop();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.somethingWentWrong,
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
