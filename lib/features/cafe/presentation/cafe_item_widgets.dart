import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/cafe_item.dart';
import '../../../core/data/services/cafe_purchase_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/active_users_api.dart';
import '../domain/cafe_rules.dart';
import 'boost_notifier.dart';
import 'cafe_notifier.dart';

/// Balance, the running boost, shield count and (when switched on in Remote
/// Config) how many people are focusing right now.
class CafeStatus extends ConsumerWidget {
  const CafeStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final points = ref.watch(userProvider).totalPoints;
    final boost = ref.watch(activeBoostProvider);
    final items = ref.watch(cafeItemsProvider).value ?? const <CafeItem>[];
    final shields = items
        .where((i) => i.itemId == streakShieldId)
        .fold<int>(0, (sum, i) => sum + i.quantity);
    final people = ref.watch(activeUsersProvider).value;

    Widget chip(String text, IconData icon) => Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: ZyraColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
            border:
                Border.all(color: ZyraColors.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: ZyraColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: ZyraTypography.labelLarge
                      .copyWith(color: ZyraColors.onSurface),
                ),
              ),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        children: [
          chip(l10n.cafeBalance(points), Icons.stars_rounded),
          if (boost != null)
            chip(
              l10n.cafeBoostBanner(
                  boostLabel(boost.percent), boost.sessionsLeft),
              Icons.bolt_rounded,
            ),
          if (shields > 0)
            chip(l10n.cafeShieldBanner(shields), Icons.shield_rounded),
          if (people != null)
            chip(l10n.peopleFocusing(people), Icons.groups_rounded),
        ],
      ),
    );
  }
}

class CafeItemCard extends ConsumerWidget {
  final CafeItem item;
  const CafeItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTr = l10n.localeName == 'tr';
    final name = isTr ? item.nameTr : item.nameEn;

    return Semantics(
      button: true,
      label: l10n.buyItem(name, item.cost),
      child: GestureDetector(
        onTap: () => showCafeItemSheet(context, item.itemId),
        child: Container(
          decoration: BoxDecoration(
            color: ZyraColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: item.quantity > 0
                  ? ZyraColors.primary.withValues(alpha: 0.5)
                  : ZyraColors.secondary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                // Scale the content down to whatever the grid cell offers, so
                // the card never overflows on narrow phones or with large
                // system fonts.
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 60,
                          child: Text(
                            item.iconCode,
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
                            color: ZyraColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${item.cost} ${l10n.points}',
                            style: ZyraTypography.labelLarge.copyWith(
                              color: ZyraColors.primary,
                            ),
                          ),
                        ),
                        if (item.quantity > 0) ...[
                          const SizedBox(height: 8),
                          Text(
                            l10n.cafeOwned(item.quantity),
                            style: ZyraTypography.labelSmall.copyWith(
                              color: ZyraColors.secondary,
                            ),
                          ),
                        ],
                      ],
                    ),
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

void showCafeItemSheet(BuildContext context, String itemId) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ItemSheet(itemId: itemId),
  );
}

/// Details of one cafe item with Buy and Use buttons.
class _ItemSheet extends ConsumerWidget {
  final String itemId;
  const _ItemSheet({required this.itemId});

  SnackBar _snack(String text, {Color color = const Color(0xFF1B5E20)}) =>
      SnackBar(
        content: Text(text),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isTr = l10n.localeName == 'tr';
    final items = ref.watch(cafeItemsProvider).value ?? const <CafeItem>[];
    final item = items.where((i) => i.itemId == itemId).firstOrNull;
    final entry = catalogEntry(itemId);
    if (item == null || entry == null) return const SizedBox.shrink();

    final points = ref.watch(userProvider).totalPoints;
    final boostRunning = ref.watch(activeBoostProvider) != null;
    final isBoost = entry.effect == CafeEffect.pointBoost;
    final description = isBoost
        ? l10n.cafeBoostDesc(
            boostLabel(entry.boostPercent), entry.boostSessions)
        : l10n.cafeShieldDesc;
    final canAfford = points >= item.cost;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: const BoxDecoration(
          color: ZyraColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(item.iconCode, style: const TextStyle(fontSize: 56)),
              const SizedBox(height: 8),
              Text(
                isTr ? item.nameTr : item.nameEn,
                style: ZyraTypography.headlineMedium
                    .copyWith(color: ZyraColors.onSurface),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.8),
                ),
              ),
              if (item.quantity > 0) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.cafeOwned(item.quantity),
                  style: ZyraTypography.labelLarge
                      .copyWith(color: ZyraColors.secondary),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      canAfford ? () => _buy(context, ref, l10n) : null,
                  child: Text(l10n.cafeBuy(item.cost)),
                ),
              ),
              if (!canAfford)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    l10n.insufficientPoints,
                    style: ZyraTypography.labelSmall
                        .copyWith(color: Colors.red.shade300),
                  ),
                ),
              if (isBoost) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: item.quantity > 0
                        ? () => _use(context, ref, l10n, entry, boostRunning)
                        : null,
                    child: Text(l10n.cafeUse),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _buy(
      BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await CafePurchaseService.purchase(
      itemId: itemId,
      userPoints: ref.read(userProvider).totalPoints,
      ref: ref,
    );
    if (result == PurchaseResult.success) {
      ref.invalidate(cafeItemsProvider);
      messenger.showSnackBar(_snack(l10n.purchaseSuccess));
    } else if (result == PurchaseResult.insufficientPoints) {
      messenger.showSnackBar(
          _snack(l10n.insufficientPoints, color: Colors.red.shade900));
    } else {
      messenger.showSnackBar(
          _snack(l10n.somethingWentWrong, color: Colors.red.shade900));
    }
  }

  Future<void> _use(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      CafeCatalogEntry entry, bool boostRunning) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (boostRunning) {
      messenger.showSnackBar(
          _snack(l10n.cafeBoostBusy, color: Colors.orange.shade900));
      return;
    }
    final boost = boostFor(entry.itemId);
    if (boost == null || !await DatabaseService.consumeItem(entry.itemId)) {
      return;
    }
    await ref.read(activeBoostProvider.notifier).start(boost);
    ref.invalidate(cafeItemsProvider);
    messenger.showSnackBar(_snack(
        l10n.cafeBoostStarted(boostLabel(boost.percent), boost.sessionsLeft)));
    navigator.pop();
  }
}
