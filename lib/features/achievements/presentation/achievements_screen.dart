import 'dart:ui';
import 'package:isar/isar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/achievement.dart';
import '../../../l10n/generated/app_localizations.dart';

final achievementsProvider = FutureProvider<List<Achievement>>((ref) async {
  return await DatabaseService.instance.achievements.where().findAll();
});

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final achievementsAsync = ref.watch(achievementsProvider);
    final isTr = l10n.localeName == 'tr';

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.achievementBadges,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: achievementsAsync.when(
        data: (achievements) {
          final unlocked =
              achievements.where((a) => a.isUnlocked).length;
          final total = achievements.length;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _ProgressHeader(
                    unlocked: unlocked,
                    total: total,
                    l10n: l10n,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final achievement = achievements[index];
                      return _AchievementCard(
                        achievement: achievement,
                        isTr: isTr,
                        index: index,
                        l10n: l10n,
                      );
                    },
                    childCount: achievements.length,
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: ZyraColors.primary),
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
}

class _ProgressHeader extends StatelessWidget {
  final int unlocked;
  final int total;
  final AppLocalizations l10n;

  const _ProgressHeader({
    required this.unlocked,
    required this.total,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? unlocked / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ZyraColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.progress,
                    style: ZyraTypography.titleMedium.copyWith(
                      color: ZyraColors.onSurface,
                    ),
                  ),
                  Text(
                    '$unlocked / $total',
                    style: ZyraTypography.titleMedium.copyWith(
                      color: ZyraColors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: ZyraColors.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [ZyraColors.primary, ZyraColors.secondary],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isTr;
  final int index;
  final AppLocalizations l10n;

  const _AchievementCard({
    required this.achievement,
    required this.isTr,
    required this.index,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final name = isTr ? achievement.nameTr : achievement.nameEn;
    final description =
        isTr ? achievement.descriptionTr : achievement.descriptionEn;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withOpacity(
          achievement.isUnlocked ? 0.7 : 0.4,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isUnlocked
              ? ZyraColors.primary.withOpacity(0.5)
              : ZyraColors.onSurface.withOpacity(0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? ZyraColors.primary.withOpacity(0.2)
                      : ZyraColors.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    achievement.iconEmoji,
                    style: TextStyle(
                      fontSize: 32,
                      color: achievement.isUnlocked
                          ? null
                          : ZyraColors.onSurface.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: ZyraTypography.titleMedium.copyWith(
                  color: achievement.isUnlocked
                      ? ZyraColors.primary
                      : ZyraColors.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: ZyraTypography.labelSmall.copyWith(
                  color: ZyraColors.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (achievement.isUnlocked &&
                  achievement.unlockedAt != null) ...[
                const SizedBox(height: 8),
                Text(
                  _formatDate(
                    achievement.unlockedAt ?? DateTime.now(),
                    l10n,
                  ),
                  style: ZyraTypography.labelSmall.copyWith(
                    color: ZyraColors.secondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 * index),
          duration: 400.ms,
        )
        .slideY(begin: 0.2, end: 0, duration: 400.ms);
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {
    final isTr = l10n.localeName == 'tr';
    if (isTr) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
