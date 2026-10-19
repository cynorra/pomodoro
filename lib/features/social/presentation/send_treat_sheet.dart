import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../auth/presentation/login_screen.dart';
import '../data/gift_api.dart';
import '../domain/gift_rules.dart';
import 'gift_texts.dart';
import 'social_providers.dart';

/// Bottom sheet to pick a treat and send it to a friend who is focusing now.
Future<void> showSendTreatSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: ZyraColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => const SendTreatSheet(),
  );
}

class SendTreatSheet extends ConsumerStatefulWidget {
  const SendTreatSheet({super.key});

  @override
  ConsumerState<SendTreatSheet> createState() => _SendTreatSheetState();
}

class _SendTreatSheetState extends ConsumerState<SendTreatSheet> {
  GiftItem _selected = giftItems[1]; // the cheapest treat
  List<FocusingUser>? _friends;
  String? _sendingTo;

  @override
  void initState() {
    super.initState();
    if (ref.read(signedInProvider)) _load();
  }

  Future<void> _load() async {
    setState(() => _friends = null);
    final friends = await ref.read(giftApiProvider).focusingNow();
    if (mounted) setState(() => _friends = friends);
  }

  Future<void> _send(FocusingUser friend) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    if (ref.read(userProvider).totalPoints < _selected.cost) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.insufficientPoints)));
      return;
    }
    setState(() => _sendingTo = friend.uid);
    final result = await ref
        .read(giftApiProvider)
        .sendGift(toUid: friend.uid, itemId: _selected.id);
    if (!mounted) return;
    setState(() => _sendingTo = null);

    switch (result) {
      case SendResult.success:
        await ref.read(userProvider.notifier).deductPoints(_selected.cost);
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.sendTreatSent(_selected.emoji, friend.name)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      case SendResult.unavailable:
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.sendTreatUnavailable)),
        );
        await _load();
      case SendResult.notSignedIn:
        messenger.showSnackBar(SnackBar(content: Text(l10n.sendTreatSignIn)));
      case SendResult.error:
        messenger
            .showSnackBar(SnackBar(content: Text(l10n.somethingWentWrong)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final signedIn = ref.watch(signedInProvider);
    final balance = ref.watch(userProvider).totalPoints;
    final now = DateTime.now();
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.sendTreatTitle,
                textAlign: TextAlign.center,
                style: ZyraTypography.titleMedium
                    .copyWith(color: ZyraColors.onSurface),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.sendTreatInfo,
                textAlign: TextAlign.center,
                style: ZyraTypography.labelSmall.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              if (!signedIn) ...[
                Text(l10n.sendTreatSignIn, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  ),
                  child: Text(l10n.login),
                ),
              ] else ...[
                Text(
                  l10n.sendTreatChoose,
                  style: ZyraTypography.labelLarge
                      .copyWith(color: ZyraColors.primary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final item in giftItems)
                      ChoiceChip(
                        selected: item.id == _selected.id,
                        onSelected: (_) => setState(() => _selected = item),
                        label: Text(
                          '${item.emoji} ${giftItemName(l10n, item.id)} · ${l10n.sendTreatCost(item.cost)}',
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.sendTreatFriends,
                        style: ZyraTypography.labelLarge
                            .copyWith(color: ZyraColors.primary),
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.sendTreatRefresh,
                      icon: const Icon(Icons.refresh),
                      onPressed: _load,
                    ),
                  ],
                ),
                if (_friends == null)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_friends!.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      l10n.sendTreatNobody,
                      textAlign: TextAlign.center,
                      style: ZyraTypography.bodyMedium.copyWith(
                        color: ZyraColors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  )
                else
                  for (final friend in _friends!)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Text('🍅', style: TextStyle(fontSize: 26)),
                      title: Text(friend.name, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        l10n.sendTreatMinLeft(minutesLeft(friend.endsAt, now)),
                      ),
                      trailing: FilledButton.tonal(
                        onPressed:
                            _sendingTo != null || balance < _selected.cost
                                ? null
                                : () => _send(friend),
                        child: _sendingTo == friend.uid
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(l10n.sendTreatSend),
                      ),
                    ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
