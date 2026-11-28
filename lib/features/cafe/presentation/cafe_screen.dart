import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/data/services/audio_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../monetization/presentation/native_ad_card.dart';
import '../../monetization/presentation/rewarded_ad_button.dart';
import '../../okey/presentation/okey_lobby_tab.dart';
import '../../social/presentation/send_treat_sheet.dart';
import 'cafe_hall_tab.dart';
import 'cafe_item_widgets.dart';
import 'cafe_notifier.dart';
import 'cafe_whisper_tab.dart';

class VirtualCafeScreen extends ConsumerStatefulWidget {
  const VirtualCafeScreen({super.key});

  @override
  ConsumerState<VirtualCafeScreen> createState() => _VirtualCafeScreenState();
}

class _VirtualCafeScreenState extends ConsumerState<VirtualCafeScreen> {
  Set<String> _bundledSounds = {};
  int _activeTab = 0; // 0: Menü, 1: Salon, 2: Fısıltı, 3: Oyun

  @override
  void initState() {
    super.initState();
    AudioService.bundledSounds().then((sounds) {
      if (mounted) setState(() => _bundledSounds = sounds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final currentSound = AudioService.currentSound;
    final totalPoints = ref.watch(userProvider).totalPoints;

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOCTURNE',
              style: ZyraTypography.titleLarge.copyWith(
                fontSize: 18,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              l10n.virtualCafe.toUpperCase(),
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: NocturnePillBadge(
              label: '$totalPoints',
              dotColor: ZyraColors.primary,
              textColor: ZyraColors.primaryBright,
              backgroundColor: ZyraColors.surface,
            ),
          ),
          if (_bundledSounds.isNotEmpty)
            Semantics(
              button: true,
              label: l10n.selectAmbientSound,
              child: IconButton(
                icon: Icon(
                  currentSound != null
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_outlined,
                  color: currentSound != null
                      ? ZyraColors.primary
                      : ZyraColors.textSecondary,
                ),
                onPressed: _showSoundSelector,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // 4-tab Nocturne Cafe pill switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: ZyraColors.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: ZyraColors.hairline),
              ),
              child: Row(
                children: [
                  _CafeSegmentTab(
                    label: 'Menü',
                    selected: _activeTab == 0,
                    onTap: () => setState(() => _activeTab = 0),
                  ),
                  _CafeSegmentTab(
                    label: 'Salon',
                    selected: _activeTab == 1,
                    onTap: () => setState(() => _activeTab = 1),
                  ),
                  _CafeSegmentTab(
                    label: 'Fısıltı',
                    selected: _activeTab == 2,
                    onTap: () => setState(() => _activeTab = 2),
                  ),
                  _CafeSegmentTab(
                    label: 'Oyun',
                    selected: _activeTab == 3,
                    onTap: () => setState(() => _activeTab = 3),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _activeTab,
              children: [
                _MenuTab(),
                CafeHallTab(
                  onOpenWhisper: () => setState(() => _activeTab = 2),
                  onOpenGames: () => setState(() => _activeTab = 3),
                ),
                const CafeWhisperTab(),
                const OkeyLobbyTab(),
              ],
            ),
          ),
        ],
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
      builder: (sheetContext) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: ZyraColors.hairlineStrong)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectAmbientSound,
                style: ZyraTypography.titleLarge,
              ),
              const SizedBox(height: 14),
              for (final sound in _soundChoices(l10n))
                if (_bundledSounds.contains(sound.file))
                  _SoundOption(
                    icon: sound.icon,
                    label: sound.label,
                    isSelected: currentSound == sound.file,
                    onTap: () => _selectSound(sound.file, sheetContext),
                  ),
              const SizedBox(height: 10),
              if (currentSound != null)
                TextButton(
                  onPressed: () {
                    AudioService.stopAmbient();
                    Navigator.pop(sheetContext);
                    if (mounted) setState(() {});
                  },
                  child: Text(l10n.turnOffSound),
                ),
              TextButton(
                onPressed: () => Navigator.pop(sheetContext),
                child: Text(
                  l10n.close,
                  style: ZyraTypography.labelLarge.copyWith(
                    color: ZyraColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
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
          SnackBar(content: Text(l10n.somethingWentWrong)),
        );
      }
    }
  }
}

class _CafeSegmentTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CafeSegmentTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? ZyraColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: ZyraTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              color:
                  selected ? ZyraColors.onPrimary : ZyraColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cafeItemsAsync = ref.watch(cafeItemsProvider);
    final l10n = AppLocalizations.of(context);

    return cafeItemsAsync.when(
      data: (items) => CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: CafeStatus()),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: RewardedAdButton(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
              child: OutlinedButton.icon(
                onPressed: () => showSendTreatSheet(context),
                icon: const Icon(Icons.card_giftcard_outlined, size: 18),
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
                childAspectRatio: 0.86,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => CafeItemCard(item: items[index]),
                childCount: items.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: NativeAdCard(),
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
            childAspectRatio: 0.86,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Shimmer.fromColors(
              baseColor: ZyraColors.surface,
              highlightColor: ZyraColors.surfaceElevated,
              child: Container(color: ZyraColors.surface),
            ),
          ),
        ),
      ),
      error: (err, stack) => Center(
        child: Text(
          l10n.somethingWentWrong,
          style: const TextStyle(color: ZyraColors.error),
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
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(
        label,
        style: ZyraTypography.titleMedium.copyWith(
          color: isSelected ? ZyraColors.primary : ZyraColors.onSurface,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: ZyraColors.primary)
          : null,
      onTap: onTap,
    );
  }
}
