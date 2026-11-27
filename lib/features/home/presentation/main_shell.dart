import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/review_prompt_service.dart';
import '../../../core/ui/widgets/bottom_nav_bar.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../monetization/presentation/banner_ad_widget.dart';
import '../../social/domain/gift_rules.dart';
import '../../social/presentation/gift_texts.dart';
import '../../social/presentation/notifications_screen.dart';
import '../../social/presentation/social_providers.dart';
import '../../stats/presentation/stats_screen.dart';
import '../../cafe/presentation/cafe_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import 'home_screen.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  /// Ids seen in the previous snapshot; null until the first one arrives.
  Set<String>? _knownGiftIds;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _useInstallCode();
      ReviewPromptService.maybePrompt(context);
    });
  }

  /// A friend's code that came with the install link is used automatically.
  Future<void> _useInstallCode() async {
    final points = await redeemInstallReferral(ref);
    if (points > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).inviteRedeemed(points)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  static const _screens = [
    HomeScreen(),
    StatsScreen(),
    VirtualCafeScreen(),
    ProfileScreen(),
  ];

  /// A small floating message, no sound or vibration, so a treat never breaks
  /// the user's focus. Everything stays in the inbox behind the bell.
  void _onGifts(List<Gift>? gifts) {
    if (gifts == null || !mounted) return;
    final hidden = ref.read(hiddenSendersProvider).value ?? const <String>{};
    final isFirst = _knownGiftIds == null;
    final fresh = giftsToAnnounce(
      previousIds: _knownGiftIds,
      current: gifts,
      hiddenSenders: hidden,
    );
    _knownGiftIds = {for (final g in gifts) g.id};

    final l10n = AppLocalizations.of(context);
    final List<Gift> toShow = isFirst
        ? [
            for (final g in sortedNewestFirst(gifts))
              if (!g.seen && !hidden.contains(g.fromUid)) g
          ]
        : fresh;
    if (toShow.isEmpty) return;

    final text = toShow.length == 1
        ? l10n.giftReceived(
            toShow.first.fromName,
            giftItemLabel(l10n, toShow.first.itemId),
          )
        : l10n.giftToastMany(toShow.length);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: l10n.giftToastView,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<List<Gift>>>(
      incomingGiftsProvider,
      (previous, next) => _onGifts(next.value),
    );
    ref.listen<bool>(signedInProvider, (previous, signedIn) {
      if (!signedIn) _knownGiftIds = null;
      if (signedIn && previous != true) _useInstallCode();
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const BannerAdWidget(),
          ZyraBottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() => _currentIndex = index);
            },
          ),
        ],
      ),
    );
  }
}
