import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import '../../../core/data/services/share_service.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/widgets/story_card.dart';
import '../../../core/ui/widgets/story_share_dialog.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/weekly_report.dart';

final weeklyReportProvider = FutureProvider<WeeklyReport>((ref) async {
  ref.watch(userProvider.select((u) => u.totalStudyMinutes));
  try {
    final now = DateTime.now();
    final from = DateTime(now.year, now.month, now.day - 13);
    final list = await DatabaseService.instance.studySessions
        .filter()
        .sessionTypeEqualTo('focus')
        .dateGreaterThan(from, include: true)
        .findAll();
    return buildWeeklyReport(
      list.map((s) => (
            date: s.date,
            seconds: s.durationSeconds,
            subject: s.subject,
          )),
      now,
    );
  } catch (_) {
    return const WeeklyReport();
  }
});

/// "This week" summary with two share buttons (weekly report, streak).
class WeeklyReportCard extends ConsumerWidget {
  const WeeklyReportCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final r = ref.watch(weeklyReportProvider).value ?? const WeeklyReport();
    final streak = ref.watch(streakProvider).value ?? 0;
    final change = r.changePercent;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZyraColors.primary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.weeklyReportTitle,
            style:
                ZyraTypography.titleMedium.copyWith(color: ZyraColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.weeklyReportSummary(r.totalMinutes, r.activeDays),
            style: ZyraTypography.bodyMedium,
          ),
          if (change != null)
            Text(
              l10n.weeklyReportChange(change),
              style: ZyraTypography.bodyMedium.copyWith(
                color: ZyraColors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.ios_share, size: 18),
                label: Text(l10n.weeklyReportShare),
                onPressed: () => showStoryShare(
                  context,
                  ref,
                  campaign: 'weekly_report',
                  card: _weeklyCard(l10n, r),
                  message: (link) => l10n.weeklyReportMessage(
                    r.totalMinutes,
                    link,
                  ),
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.local_fire_department_outlined,
                    size: 18),
                label: Text(l10n.streakShare),
                onPressed: () => showStoryShare(
                  context,
                  ref,
                  campaign: 'streak',
                  card: StoryCard(
                    title: l10n.streakCardTitle,
                    emoji: '🔥',
                    value: '$streak',
                    caption: l10n.streakCardCaption(streak),
                    footer: ShareService.storeDisplayName,
                  ),
                  message: (link) => l10n.streakMessage(streak, link),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weeklyCard(AppLocalizations l10n, WeeklyReport r) {
    final change = r.changePercent;
    return StoryCard(
      title: l10n.weeklyReportTitle.toUpperCase(),
      emoji: '📚',
      value: '${r.totalMinutes}',
      caption: l10n.weeklyCardCaption,
      lines: [
        l10n.weeklyCardDays(r.activeDays),
        if (r.topSubject.isNotEmpty) l10n.weeklyCardTop(r.topSubject),
        if (change != null) l10n.weeklyReportChange(change),
      ],
      footer: ShareService.storeDisplayName,
    );
  }
}
