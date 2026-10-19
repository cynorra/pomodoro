import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/moderation_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/gift_rules.dart';
import 'gift_texts.dart';
import 'social_providers.dart';

/// Inbox of treats friends sent. Opening it marks them as read after a moment
/// so the new ones stay highlighted while the user looks at them.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Timer? _markTimer;

  @override
  void initState() {
    super.initState();
    _markTimer = Timer(const Duration(milliseconds: 1500), _markAllSeen);
  }

  @override
  void dispose() {
    _markTimer?.cancel();
    super.dispose();
  }

  List<Gift> _visible() {
    final gifts = ref.read(incomingGiftsProvider).value ?? const <Gift>[];
    final hidden = ref.read(hiddenSendersProvider).value ?? const <String>{};
    return sortedNewestFirst(gifts.where((g) => !hidden.contains(g.fromUid)));
  }

  Future<void> _markAllSeen() async {
    final ids = [
      for (final g in _visible())
        if (!g.seen) g.id,
    ];
    if (ids.isNotEmpty) await ref.read(giftApiProvider).markSeen(ids);
  }

  Future<void> _clearAll() async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: ZyraColors.surface,
        content: Text(l10n.giftsClearConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(l10n.giftsClearAll),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref
          .read(giftApiProvider)
          .deleteGifts([for (final g in _visible()) g.id]);
    }
  }

  Future<void> _hide(Gift gift) async {
    await ModerationService.hidePlayer(gift.fromUid);
    ref.invalidate(hiddenSendersProvider);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).playerHidden),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _report(Gift gift) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ModerationService.reportPlayer(
      uid: gift.fromUid,
      reason: ReportReason.other,
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.reportSent : l10n.reportFailed),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Rebuild when the gifts or the hidden list change.
    ref.watch(incomingGiftsProvider);
    ref.watch(hiddenSendersProvider);
    final gifts = _visible();
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.notifications, style: ZyraTypography.headlineMedium),
        centerTitle: true,
        actions: [
          if (gifts.isNotEmpty)
            TextButton(onPressed: _clearAll, child: Text(l10n.giftsClearAll)),
        ],
      ),
      body: gifts.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      l10n.giftsEmpty,
                      textAlign: TextAlign.center,
                      style: ZyraTypography.bodyMedium.copyWith(
                        color: ZyraColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: gifts.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final gift = gifts[index];
                return _GiftTile(
                  gift: gift,
                  now: now,
                  onHide: () => _hide(gift),
                  onReport: () => _report(gift),
                );
              },
            ),
    );
  }
}

class _GiftTile extends StatelessWidget {
  final Gift gift;
  final DateTime now;
  final VoidCallback onHide;
  final VoidCallback onReport;

  const _GiftTile({
    required this.gift,
    required this.now,
    required this.onHide,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final item = giftItemById(gift.itemId);
    return Container(
      decoration: BoxDecoration(
        color: gift.seen
            ? ZyraColors.surface.withValues(alpha: 0.5)
            : ZyraColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: gift.seen
              ? ZyraColors.onSurface.withValues(alpha: 0.1)
              : ZyraColors.primary.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        leading:
            Text(item?.emoji ?? '🎁', style: const TextStyle(fontSize: 30)),
        title: Text(
          l10n.giftReceived(gift.fromName, giftItemLabel(l10n, gift.itemId)),
          style: ZyraTypography.bodyMedium.copyWith(
            color: ZyraColors.onSurface,
            fontWeight: gift.seen ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(relativeTime(l10n, gift.createdAt, now)),
        trailing: PopupMenuButton<String>(
          tooltip: l10n.reportPlayer,
          color: ZyraColors.surface,
          onSelected: (value) => value == 'hide' ? onHide() : onReport(),
          itemBuilder: (_) => [
            PopupMenuItem(value: 'hide', child: Text(l10n.hidePlayer)),
            PopupMenuItem(value: 'report', child: Text(l10n.reportPlayer)),
          ],
        ),
      ),
    );
  }
}
