import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'chart_buckets.dart';
import 'stats_provider.dart';
import '../../../l10n/l10n_extension.dart';
import '../../../core/ui/responsive.dart';

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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.statistics,
          style: ZyraTypography.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _AchievementBadges(l10n: l10n),
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
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
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

class _FilterButton extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.diagonal3Values(
            _isPressed ? 0.95 : 1.0,
            _isPressed ? 0.95 : 1.0,
            1.0,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? ZyraColors.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? Border.all(color: ZyraColors.primary, width: 1.5)
                  : null,
            ),
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              style: ZyraTypography.labelLarge.copyWith(
                color: widget.isSelected
                    ? ZyraColors.primary
                    : ZyraColors.onSurface.withValues(alpha: 0.6),
              ),
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

        return Row(
          children: [
            Expanded(
              child: _SummaryCard(
                icon: Icons.timer_outlined,
                value: (totalMinutes / 60).toStringAsFixed(1),
                unit: l10n.hours,
                color: ZyraColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.stars_rounded,
                value: '$totalPoints',
                unit: l10n.points,
                color: ZyraColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                value: '$sessionsCompleted',
                unit: l10n.sessions,
                color: ZyraColors.primary,
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
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                value,
                style: ZyraTypography.headlineMedium.copyWith(
                  color: color,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unit,
                style: ZyraTypography.labelSmall.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
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

    final decoration = BoxDecoration(
      color: ZyraColors.surface.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: ZyraColors.primary.withValues(alpha: 0.2),
        width: 1.5,
      ),
    );

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: decoration,
            child: Center(
              child: Column(
                children: [
                  const Icon(
                    Icons.show_chart,
                    color: ZyraColors.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.noStudyData,
                    style: ZyraTypography.bodyMedium.copyWith(
                      color: ZyraColors.onSurface.withValues(alpha: 0.6),
                    ),
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

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: decoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: (context.screenSize.height * 0.28)
                    .clamp(190.0, 280.0)
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
        height: 250,
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

/// One bar. It takes whatever width and height its slot gives it, so the chart
/// can never overflow, whether it shows 5, 6 or 7 bars and on any screen size.
class _BarChartItem extends StatelessWidget {
  final String label;
  final int minutes;
  final int maxMinutes;

  const _BarChartItem({
    required this.label,
    required this.minutes,
    required this.maxMinutes,
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
            (constraints.maxHeight - labelsHeight).clamp(0.0, 400.0).toDouble();
        final barWidth = (constraints.maxWidth * 0.62)
            .clamp(8.0, context.scaled(36))
            .toDouble();

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              width: barWidth,
              height: barArea * heightFactor,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ZyraColors.primary.withValues(alpha: 0.8),
                    ZyraColors.secondary.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 14,
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _amount(context),
                  style: ZyraTypography.labelSmall.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 18,
              width: constraints.maxWidth,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: ZyraTypography.labelSmall.copyWith(
                    color: ZyraColors.onSurface,
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
      {
        'icon': '🔥',
        'title': l10n.threeDayStreak,
        'description': l10n.threeDayStreakDesc
      },
      {
        'icon': '⭐',
        'title': l10n.first100Points,
        'description': l10n.first100PointsDesc
      },
      {
        'icon': '🎯',
        'title': l10n.focusMaster,
        'description': l10n.focusMasterDesc
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZyraColors.secondary.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.achievementBadges,
            style: ZyraTypography.titleMedium.copyWith(
              color: ZyraColors.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...badges.map(
            (badge) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _BadgeItem(
                icon: badge['icon'] as String,
                title: badge['title'] as String,
                description: badge['description'] as String,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeItem extends StatelessWidget {
  final String icon;
  final String title;
  final String description;

  const _BadgeItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: ZyraColors.primary.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
