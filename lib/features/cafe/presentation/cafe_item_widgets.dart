import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/cafe_item.dart';
import '../../../core/data/services/cafe_purchase_service.dart';
import '../../../core/data/services/sfx_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../core/ui/widgets/jelly_button.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../data/active_users_api.dart';
import '../domain/cafe_rules.dart';
import 'boost_notifier.dart';
import 'cafe_notifier.dart';

/// Balance, running boost, shield count, and active focusing people.
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

    Widget rowChip(String text, IconData icon, {Color accent = ZyraColors.primary}) =>
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Icon(icon, size: 18, color: accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: ZyraTypography.bodyMedium.copyWith(
                      fontSize: 13,
                      color: ZyraColors.onBackground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          rowChip(l10n.cafeBalance(points), Icons.toll_outlined),
          if (boost != null)
            rowChip(
              l10n.cafeBoostBanner(
                  boostLabel(boost.percent), boost.sessionsLeft),
              Icons.bolt_rounded,
              accent: ZyraColors.primaryBright,
            ),
          if (shields > 0)
            rowChip(
              l10n.cafeShieldBanner(shields),
              Icons.shield_outlined,
              accent: ZyraColors.secondaryBright,
            ),
          if (people != null)
            rowChip(
              l10n.peopleFocusing(people),
              Icons.groups_outlined,
              accent: ZyraColors.secondary,
            ),
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
        child: GlassCard(
          padding: const EdgeInsets.all(14),
          border: Border.all(
            color: item.quantity > 0
                ? ZyraColors.primary.withValues(alpha: 0.45)
                : ZyraColors.hairline,
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: ZyraColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ZyraColors.hairline),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item.iconCode,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  NocturnePillBadge(
                    label: '${item.cost} ${l10n.points}',
                    dotColor: ZyraColors.primary,
                    textColor: ZyraColors.primaryBright,
                  ),
                  if (item.quantity > 0) ...[
                    const SizedBox(height: 6),
                    Text(
                      l10n.cafeOwned(item.quantity),
                      style: ZyraTypography.dataMono.copyWith(
                        fontSize: 11,
                        color: ZyraColors.secondaryBright,
                      ),
                    ),
                  ],
                ],
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

class _ItemSheet extends ConsumerWidget {
  final String itemId;
  const _ItemSheet({required this.itemId});

  SnackBar _snack(String text, {bool isError = false}) => SnackBar(
        content: Text(text),
        backgroundColor:
            isError ? ZyraColors.errorContainer : ZyraColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
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
          border: Border(
            top: BorderSide(color: ZyraColors.hairlineStrong),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: ZyraColors.textTertiary.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ZyraColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ZyraColors.hairlineStrong),
                ),
                alignment: Alignment.center,
                child: Text(item.iconCode, style: const TextStyle(fontSize: 38)),
              ),
              const SizedBox(height: 14),
              Text(
                isTr ? item.nameTr : item.nameEn,
                style: ZyraTypography.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: ZyraTypography.bodySmall.copyWith(height: 1.5),
              ),
              if (item.quantity > 0) ...[
                const SizedBox(height: 10),
                NocturnePillBadge(
                  label: l10n.cafeOwned(item.quantity),
                  dotColor: ZyraColors.secondary,
                  textColor: ZyraColors.secondaryBright,
                ),
              ],
              const SizedBox(height: 20),
              JellyButton(
                onPressed: canAfford ? () => _buy(context, ref, l10n) : null,
                label: l10n.cafeBuy(item.cost),
              ),
              if (!canAfford)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l10n.insufficientPoints,
                    style: ZyraTypography.labelSmall.copyWith(
                      color: ZyraColors.error,
                    ),
                  ),
                ),
              if (isBoost) ...[
                const SizedBox(height: 10),
                JellyButton(
                  onPressed: item.quantity > 0
                      ? () => _use(context, ref, l10n, entry, boostRunning)
                      : null,
                  label: l10n.cafeUse,
                  outlined: true,
                ),
              ],
              const SizedBox(height: 6),
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
      SfxService.play(Sfx.purchase);
      HapticFeedback.mediumImpact();
      messenger.showSnackBar(_snack(l10n.purchaseSuccess));
    } else if (result == PurchaseResult.insufficientPoints) {
      messenger.showSnackBar(_snack(l10n.insufficientPoints, isError: true));
    } else {
      messenger.showSnackBar(_snack(l10n.somethingWentWrong, isError: true));
    }
  }

  Future<void> _use(BuildContext context, WidgetRef ref, AppLocalizations l10n,
      CafeCatalogEntry entry, bool boostRunning) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    if (boostRunning) {
      messenger.showSnackBar(_snack(l10n.cafeBoostBusy, isError: true));
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
