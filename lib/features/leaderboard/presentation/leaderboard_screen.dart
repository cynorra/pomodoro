import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/moderation_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/l10n_extension.dart';

final _leaderboardProvider =
    FutureProvider.autoDispose<List<_LeaderboardEntry>>((ref) async {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return [];

  final snapshot = await FirebaseFirestore.instance
      .collection('leaderboard')
      .orderBy('totalPoints', descending: true)
      .limit(50)
      .get();

  String textOf(Object? v) => v is String ? v.trim() : '';
  int numberOf(Object? v) => v is num ? v.toInt() : 0;

  final hidden = await ModerationService.hiddenPlayers();
  final docs = snapshot.docs.where((d) => !hidden.contains(d.id)).toList();

  return [
    for (var i = 0; i < docs.length; i++)
      _LeaderboardEntry(
        uid: docs[i].id,
        rank: i + 1,
        name: textOf(docs[i].data()['displayName']),
        points: numberOf(docs[i].data()['totalPoints']),
        streak: numberOf(docs[i].data()['currentStreak']),
        isCurrentUser: docs[i].id == currentUid,
      ),
  ];
});

final _hiddenCountProvider = FutureProvider.autoDispose<int>(
  (ref) async => (await ModerationService.hiddenPlayers()).length,
);

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(_leaderboardProvider);
    final signedIn = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.leaderboard, style: ZyraTypography.titleLarge),
            Text(
              'GECE SIRALAMASI',
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          if ((ref.watch(_hiddenCountProvider).value ?? 0) > 0)
            IconButton(
              tooltip: context.l10n.showHiddenPlayers,
              icon: const Icon(Icons.visibility_outlined),
              onPressed: () async {
                await ModerationService.showAllPlayers();
                ref.invalidate(_leaderboardProvider);
                ref.invalidate(_hiddenCountProvider);
              },
            ),
        ],
      ),
      body: entries.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: ZyraColors.primary),
        ),
        error: (_, __) => _Message(
          text: context.l10n.leaderboardLoadFailed,
          actionLabel: context.l10n.tryAgain,
          onAction: () => ref.invalidate(_leaderboardProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return _Message(
              text: signedIn
                  ? context.l10n.leaderboardEmpty
                  : context.l10n.leaderboardSignInPrompt,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            itemCount: list.length,
            itemBuilder: (context, index) => _LeaderboardTile(
              entry: list[index],
              onMore: () => _showActions(context, ref, list[index]),
            ),
          );
        },
      ),
    );
  }
}

Future<void> _showActions(
  BuildContext context,
  WidgetRef ref,
  _LeaderboardEntry entry,
) async {
  if (entry.isCurrentUser) return;
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final action = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: ZyraColors.surface,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined, color: ZyraColors.primary),
            title: Text(l10n.reportPlayer),
            onTap: () => Navigator.pop(sheetContext, 'report'),
          ),
          ListTile(
            leading: const Icon(
              Icons.visibility_off_outlined,
              color: ZyraColors.textSecondary,
            ),
            title: Text(l10n.hidePlayer),
            onTap: () => Navigator.pop(sheetContext, 'hide'),
          ),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  if (action == 'hide') {
    await ModerationService.hidePlayer(entry.uid);
    ref.invalidate(_leaderboardProvider);
    ref.invalidate(_hiddenCountProvider);
    messenger.showSnackBar(SnackBar(content: Text(l10n.playerHidden)));
    return;
  }

  final reason = await showDialog<ReportReason>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      backgroundColor: ZyraColors.surface,
      title: Text(l10n.reportReasonTitle),
      children: [
        SimpleDialogOption(
          onPressed: () =>
              Navigator.pop(dialogContext, ReportReason.inappropriateName),
          child: Text(l10n.reportReasonName),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, ReportReason.cheating),
          child: Text(l10n.reportReasonCheating),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(dialogContext, ReportReason.other),
          child: Text(l10n.reportReasonOther),
        ),
      ],
    ),
  );
  if (reason == null) return;
  final ok =
      await ModerationService.reportPlayer(uid: entry.uid, reason: reason);
  messenger.showSnackBar(
    SnackBar(content: Text(ok ? l10n.reportSent : l10n.reportFailed)),
  );
}

class _Message extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 12),
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final _LeaderboardEntry entry;
  final VoidCallback onMore;

  const _LeaderboardTile({required this.entry, required this.onMore});

  @override
  Widget build(BuildContext context) {
    final rankText = entry.rank.toString().padLeft(2, '0');
    final initials = entry.name.trim().isNotEmpty
        ? entry.name.trim().characters.take(2).toString().toUpperCase()
        : 'NA';
    final isTop3 = entry.rank <= 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: entry.isCurrentUser
              ? ZyraColors.surfaceElevated
              : ZyraColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: entry.isCurrentUser
                ? ZyraColors.primary.withValues(alpha: 0.6)
                : ZyraColors.hairline,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  rankText,
                  style: ZyraTypography.dataMono.copyWith(
                    color: isTop3 || entry.isCurrentUser
                        ? ZyraColors.primary
                        : ZyraColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: entry.isCurrentUser
                      ? ZyraColors.primary.withValues(alpha: 0.18)
                      : ZyraColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isTop3
                        ? ZyraColors.primary.withValues(alpha: 0.45)
                        : ZyraColors.hairlineStrong,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: ZyraTypography.dataMono.copyWith(
                    fontSize: 12,
                    color: entry.isCurrentUser
                        ? ZyraColors.primaryBright
                        : ZyraColors.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ZyraTypography.titleMedium.copyWith(
                              fontSize: 14,
                              color: entry.isCurrentUser
                                  ? ZyraColors.primaryBright
                                  : ZyraColors.onBackground,
                            ),
                          ),
                        ),
                        if (entry.isCurrentUser) ...[
                          const SizedBox(width: 6),
                          const NocturnePillBadge(
                            label: 'SEN',
                            textColor: ZyraColors.primaryBright,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.streakDays(entry.streak),
                      style: ZyraTypography.labelSmall.copyWith(
                        color: ZyraColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${entry.points}',
                style: ZyraTypography.dataMono.copyWith(
                  color: entry.isCurrentUser || isTop3
                      ? ZyraColors.primaryBright
                      : ZyraColors.onBackground,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (!entry.isCurrentUser)
                IconButton(
                  tooltip: context.l10n.reportPlayer,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    size: 18,
                    color: ZyraColors.textTertiary,
                  ),
                  onPressed: onMore,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardEntry {
  final String uid;
  final int rank;
  final String name;
  final int points;
  final int streak;
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.uid,
    required this.rank,
    required this.name,
    required this.points,
    required this.streak,
    this.isCurrentUser = false,
  });
}
