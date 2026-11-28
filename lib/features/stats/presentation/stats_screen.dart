import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'chart_buckets.dart';
import 'stats_provider.dart';
import 'subject_breakdown.dart';
import 'weekly_report_card.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../core/ui/responsive.dart';
import '../../monetization/presentation/native_ad_card.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selectedFilter = ref.watch(selectedFilterProvider);

    return Scaffold(
      backgroundColor: ZyraColors.background,
      appBar: AppBar(
        backgroundColor: ZyraColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NOCTURNE',
              style: ZyraTypography.titleLarge.copyWith(
                fontSize: 18,
                letterSpacing: 1.8,
              ),
            ),
            Text(
              l10n.statistics.toUpperCase(),
              style: ZyraTypography.sectionLabel.copyWith(
                fontSize: 10,
                color: ZyraColors.textTertiary,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: _FilterSelector(
                selected: selectedFilter,
                onSelected: (filter) {
                  ref.read(selectedFilterProvider.notifier).select(filter);
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _SummaryCards(filter: selectedFilter),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _ActivityChart(filter: selectedFilter),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: NativeAdCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: WeeklyReportCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SubjectBreakdown(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _AchievementBadges(l10n: l10n),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: Column(
                children: [
                  Text(
                    '“Gecenin sessizliği, zihnin en berrak suyudur.”',
                    textAlign: TextAlign.center,
                    style: ZyraTypography.editorialItalic.copyWith(
                      fontSize: 14,
                      color: ZyraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '— NOCTURNE ATELIER',
                    style: ZyraTypography.dataMono.copyWith(
                      fontSize: 10,
                      color: ZyraColors.textTertiary,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSelector extends StatelessWidget {
  final StatsFilter selected;
  final ValueChanged<StatsFilter> onSelected;

  const _FilterSelector({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ZyraColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: ZyraColors.hairline),
      ),
      child: Row(
        children: [
          _FilterButton(
            label: l10n.week,
            isSelected: selected == StatsFilter.week,
            onTap: () => onSelected(StatsFilter.week),
          ),
          _FilterButton(
            label: l10n.month,
            isSelected: selected == StatsFilter.month,
            onTap: () => onSelected(StatsFilter.month),
          ),
          _FilterButton(
            label: l10n.allTime,
            isSelected: selected == StatsFilter.allTime,
            onTap: () => onSelected(StatsFilter.allTime),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? ZyraColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: ZyraTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? ZyraColors.onPrimary : ZyraColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCards extends ConsumerWidget {
  final StatsFilter filter;

  const _SummaryCards({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionsAsync = ref.watch(statsDataProvider);

    return sessionsAsync.when(
      data: (sessions) {
        final totalMinutes = sessions.fold<int>(
          0,
          (sum, session) => sum + (session.durationSeconds ~/ 60),
        );
        final totalPoints = sessions.fold<int>(
          0,
          (sum, session) => sum + session.pointsEarned,
        );
        final sessionsCompleted = sessions.length;

        return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _MetricCell(
                  label: l10n.hours.toUpperCase(),
                  value: (totalMinutes / 60).toStringAsFixed(1),
                  accent: ZyraColors.onBackground,
                ),
              ),
              Container(width: 1, height: 42, color: ZyraColors.divider),
              Expanded(
                child: _MetricCell(
                  label: l10n.sessions.toUpperCase(),
                  value: '$sessionsCompleted',
                  accent: ZyraColors.secondaryBright,
                ),
              ),
              Container(width: 1, height: 42, color: ZyraColors.divider),
              Expanded(
                child: _MetricCell(
                  label: l10n.points.toUpperCase(),
                  value: '$totalPoints',
                  accent: ZyraColors.primary,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: ZyraColors.primary),
        ),
      ),
      error: (err, stack) => Center(
        child: Text(
          l10n.somethingWentWrong,
          style: const TextStyle(color: ZyraColors.error),
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MetricCell({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: ZyraTypography.sectionLabel.copyWith(
            fontSize: 10,
            color: ZyraColors.textTertiary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: ZyraTypography.dataMonoLarge.copyWith(
            fontSize: 24,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _ActivityChart extends ConsumerWidget {
  final StatsFilter filter;

  const _ActivityChart({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionsAsync = ref.watch(statsDataProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return GlassCard(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: ZyraColors.textTertiary,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.noStudyData,
                    style: ZyraTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final buckets = buildChartBuckets(
          sessions: sessions,
          filter: filter,
          now: DateTime.now(),
        );
        final maxMinutes = buckets.fold<int>(
          0,
          (best, b) => b.minutes > best ? b.minutes : best,
        );
        final locale = Localizations.localeOf(context).toString();
        final dayNames = _getDayNames(l10n);

        String labelOf(ChartBucket bucket) {
          switch (filter) {
            case StatsFilter.week:
              return dayNames[bucket.start.weekday - 1];
            case StatsFilter.month:
              return DateFormat.MMMd(locale).format(bucket.start);
            case StatsFilter.allTime:
              return DateFormat.MMM(locale).format(bucket.start);
          }
        }

        final title = switch (filter) {
          StatsFilter.week => l10n.weeklyChart,
          StatsFilter.month => l10n.monthlyChart,
          StatsFilter.allTime => l10n.allTimeChart,
        };

        return GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bar_chart_rounded,
                    color: ZyraColors.primary,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: ZyraTypography.titleLarge.copyWith(fontSize: 18),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: (context.screenSize.height * 0.26)
                    .clamp(185.0, 250.0)
                    .toDouble(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final bucket in buckets)
                      Expanded(
                        child: _BarChartItem(
                          label: labelOf(bucket),
                          minutes: bucket.minutes,
                          maxMinutes: maxMinutes,
                          isPeak:
                              maxMinutes > 0 && bucket.minutes == maxMinutes,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 220,
        child: Center(
          child: CircularProgressIndicator(color: ZyraColors.primary),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  List<String> _getDayNames(AppLocalizations l10n) {
    return [
      l10n.dayMonday,
      l10n.dayTuesday,
      l10n.dayWednesday,
      l10n.dayThursday,
      l10n.dayFriday,
      l10n.daySaturday,
      l10n.daySunday,
    ];
  }
}

class _BarChartItem extends StatelessWidget {
  final String label;
  final int minutes;
  final int maxMinutes;
  final bool isPeak;

  const _BarChartItem({
    required this.label,
    required this.minutes,
    required this.maxMinutes,
    required this.isPeak,
  });

  String _amount(BuildContext context) {
    final l10n = context.l10n;
    if (minutes < 60) return l10n.minutesShort(minutes);
    return l10n.hoursShort((minutes / 60).toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    const labelsHeight = 44.0;
    final heightFactor = maxMinutes > 0 ? minutes / maxMinutes : 0.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final barArea =
            (constraints.maxHeight - labelsHeight).clamp(0.0, 360.0).toDouble();
        final barWidth = (constraints.maxWidth * 0.34)
            .clamp(8.0, context.scaled(16))
            .toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(
              height: 14,
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  minutes > 0 ? _amount(context) : '',
                  style: ZyraTypography.dataMono.copyWith(
                    color: isPeak
                        ? ZyraColors.primary
                        : ZyraColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            // Pill track + fill matching `i_statistik_al_ma_defteri`
            Container(
              width: barWidth,
              height: barArea,
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                color: ZyraColors.surfaceElevated,
                borderRadius: BorderRadius.circular(999),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                width: barWidth,
                height: (barArea * heightFactor).clamp(0.0, barArea),
                decoration: BoxDecoration(
                  color: isPeak
                      ? ZyraColors.primary
                      : ZyraColors.textTertiary.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 16,
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: ZyraTypography.labelSmall.copyWith(
                    color: isPeak
                        ? ZyraColors.onBackground
                        : ZyraColors.textTertiary,
                    fontWeight: isPeak ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AchievementBadges extends StatelessWidget {
  final AppLocalizations l10n;

  const _AchievementBadges({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final badges = [
      (
        icon: Icons.local_fire_department_outlined,
        title: l10n.threeDayStreak,
        description: l10n.threeDayStreakDesc,
      ),
      (
        icon: Icons.stars_outlined,
        title: l10n.first100Points,
        description: l10n.first100PointsDesc,
      ),
      (
        icon: Icons.track_changes_outlined,
        title: l10n.focusMaster,
        description: l10n.focusMasterDesc,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.achievementBadges,
            style: ZyraTypography.titleLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < badges.length; i++) ...[
            if (i > 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: ZyraColors.divider),
              ),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: ZyraColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ZyraColors.hairline),
                  ),
                  child: Icon(
                    badges[i].icon,
                    color: ZyraColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badges[i].title,
                        style: ZyraTypography.titleMedium.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        badges[i].description,
                        style: ZyraTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
