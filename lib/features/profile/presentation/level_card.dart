import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/user_stats.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/level_rules.dart';

final lifetimePointsProvider = FutureProvider<int>((ref) async {
  // Re-read whenever the balance changes (a session ended or points were spent).
  ref.watch(userProvider.select((u) => u.totalPoints));
  try {
    final stats = await DatabaseService.instance.userStats.where().findFirst();
    return stats?.lifetimePointsEarned ?? 0;
  } catch (_) {
    return 0;
  }
});

/// Level and progress to the next level, shown on the profile.
class LevelCard extends ConsumerWidget {
  const LevelCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final points = ref.watch(lifetimePointsProvider).value ?? 0;
    final level = levelForPoints(points);
    final next = pointsForLevel(level + 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZyraColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.levelLabel(level),
                  style: ZyraTypography.titleMedium
                      .copyWith(color: ZyraColors.primary),
                ),
              ),
              Text(
                '$points / $next XP',
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: levelProgress(points),
              minHeight: 8,
              color: ZyraColors.primary,
              backgroundColor: ZyraColors.onSurface.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}
