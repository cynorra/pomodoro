import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/services/moderation_service.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../core/ui/responsive.dart';

const _rankAvatars = ['🥇', '🥈', '🥉'];

final _leaderboardProvider =
    FutureProvider.autoDispose<List<_LeaderboardEntry>>((ref) async {
  final currentUid = FirebaseAuth.instance.currentUser?.uid;
  if (currentUid == null) return [];

  // `leaderboard` holds only public fields (no email), unlike `users`.
  final snapshot = await FirebaseFirestore.instance
      .collection('leaderboard')
      .orderBy('totalPoints', descending: true)
      .limit(50)
      .get();

  // Documents are client-written, so read every field defensively: one
  // malformed entry must not break the list for everyone.
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
        avatar: i < _rankAvatars.length ? _rankAvatars[i] : '🏅',
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.l10n.leaderboard,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
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
          return Column(
            children: [
              _TopThreePodium(
                entries: list.take(3).toList(),
                onMore: (e) => _showActions(context, ref, e),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: list.length > 3 ? list.length - 3 : 0,
                  itemBuilder: (context, index) => _LeaderboardTile(
                    entry: list[index + 3],
                    onMore: () => _showActions(context, ref, list[index + 3]),
                  ),
                ),
              ),
            ],
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
            leading: const Icon(Icons.flag_outlined),
            title: Text(l10n.reportPlayer),
            onTap: () => Navigator.pop(sheetContext, 'report'),
          ),
          ListTile(
            leading: const Icon(Icons.visibility_off_outlined),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: ZyraTypography.bodyMedium.copyWith(
              color: ZyraColors.onSurface.withValues(alpha: 0.7),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _TopThreePodium extends StatelessWidget {
  final List<_LeaderboardEntry> entries;
  final ValueChanged<_LeaderboardEntry> onMore;

  const _TopThreePodium({required this.entries, required this.onMore});

  @override
  Widget build(BuildContext context) {
    if (entries.length < 3) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumItem(
            entry: entries[1],
            height: context.scaled(120),
            order: 2,
            onMore: () => onMore(entries[1]),
          ),
          _PodiumItem(
            entry: entries[0],
            height: context.scaled(160),
            order: 1,
            onMore: () => onMore(entries[0]),
          ),
          _PodiumItem(
            entry: entries[2],
            height: context.scaled(100),
            order: 3,
            onMore: () => onMore(entries[2]),
          ),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final _LeaderboardEntry entry;
  final double height;
  final int order;
  final VoidCallback onMore;

  const _PodiumItem({
    required this.entry,
    required this.height,
    required this.order,
    required this.onMore,
  });

  Color get _color {
    switch (order) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return ZyraColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(entry.avatar, style: TextStyle(fontSize: context.scaled(48))),
        const SizedBox(height: 8),
        Text(
          entry.name,
          style: ZyraTypography.labelLarge.copyWith(
            color: ZyraColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        if (!entry.isCurrentUser)
          IconButton(
            tooltip: context.l10n.reportPlayer,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 28),
            iconSize: 18,
            icon: const Icon(Icons.more_horiz),
            onPressed: onMore,
          ),
        const SizedBox(height: 4),
        Text(
          context.l10n.pointsCount(entry.points),
          style: ZyraTypography.labelSmall.copyWith(
            color: _color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: context.scaled(80),
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _color.withValues(alpha: 0.8),
                _color.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
          ),
          child: Center(
            child: Text(
              '#${entry.rank}',
              style: ZyraTypography.headlineMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final _LeaderboardEntry entry;
  final VoidCallback onMore;

  const _LeaderboardTile({required this.entry, required this.onMore});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? ZyraColors.primary.withValues(alpha: 0.15)
            : ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: entry.isCurrentUser
              ? ZyraColors.primary
              : ZyraColors.onSurface.withValues(alpha: 0.1),
          width: entry.isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: ZyraColors.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                '#${entry.rank}',
                style: ZyraTypography.labelLarge.copyWith(
                  color: ZyraColors.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(entry.avatar, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  style: ZyraTypography.titleMedium.copyWith(
                    color: ZyraColors.onSurface,
                    fontWeight: entry.isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                Text(
                  context.l10n.streakDays(entry.streak),
                  style: ZyraTypography.labelSmall.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${entry.points}',
            style: ZyraTypography.titleMedium.copyWith(
              color: ZyraColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!entry.isCurrentUser)
            IconButton(
              tooltip: context.l10n.reportPlayer,
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.more_vert, size: 20),
              onPressed: onMore,
            ),
        ],
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
  final String avatar;
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.uid,
    required this.rank,
    required this.name,
    required this.points,
    required this.streak,
    required this.avatar,
    this.isCurrentUser = false,
  });
}
