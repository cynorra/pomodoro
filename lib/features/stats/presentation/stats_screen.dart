import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'stats_provider.dart';

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
          l10n?.statistics ?? 'İstatistikler',
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
                  ref.read(selectedFilterProvider.notifier).state = filter;
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
              child: _WeeklyChart(filter: selectedFilter),
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
        color: ZyraColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _FilterButton(
            label: l10n?.week ?? 'Hafta',
            isSelected: selected == StatsFilter.week,
            onTap: () => onSelected(StatsFilter.week),
          ),
          _FilterButton(
            label: l10n?.month ?? 'Ay',
            isSelected: selected == StatsFilter.month,
            onTap: () => onSelected(StatsFilter.month),
          ),
          _FilterButton(
            label: l10n?.allTime ?? 'Tümü',
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
                  ? ZyraColors.primary.withOpacity(0.2)
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
                    : ZyraColors.onSurface.withOpacity(0.6),
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
                value: '${(totalMinutes / 60).toStringAsFixed(1)}',
                unit: l10n?.hours ?? 'Saat',
                color: ZyraColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.stars_rounded,
                value: '$totalPoints',
                unit: l10n?.points ?? 'Puan',
                color: ZyraColors.secondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SummaryCard(
                icon: Icons.check_circle_outline,
                value: '$sessionsCompleted',
                unit: l10n?.sessions ?? 'Seans',
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
          l10n?.somethingWentWrong ?? 'Hata',
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
        color: ZyraColors.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
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
                  color: ZyraColors.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyChart extends ConsumerWidget {
  final StatsFilter filter;

  const _WeeklyChart({required this.filter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessionsAsync = ref.watch(statsDataProvider);

    return sessionsAsync.when(
      data: (sessions) {
        if (sessions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ZyraColors.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: ZyraColors.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
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
                    'Henüz çalışma verisi yok',
                    style: ZyraTypography.bodyMedium.copyWith(
                      color: ZyraColors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final now = DateTime.now();
        final dayCount = switch (filter) {
          StatsFilter.week => 7,
          StatsFilter.month => 30,
          StatsFilter.allTime => 90,
        };

        final today = DateTime(now.year, now.month, now.day);
        final weekData = <_DayData>[];

        for (int i = dayCount - 1; i >= 0; i--) {
          final day = DateTime(today.year, today.month, today.day - i);
          final dayStart = DateTime(day.year, day.month, day.day);
          final dayEnd = dayStart.add(const Duration(days: 1));

          final daySessions = sessions.where((s) {
            final sessionDate = DateTime(
              s.date.year,
              s.date.month,
              s.date.day,
            );
            return sessionDate.isAtSameMomentAs(dayStart) ||
                (sessionDate.isAfter(dayStart) &&
                    sessionDate.isBefore(dayEnd));
          });

          final totalMinutes = daySessions.fold<int>(
            0,
            (sum, s) => sum + (s.durationSeconds ~/ 60),
          );

          weekData.add(_DayData(
            dayIndex: day.weekday,
            minutes: totalMinutes,
          ));
        }

        final dayNames = _getDayNames(l10n);
        final maxMinutes = weekData.isEmpty
            ? 1
            : weekData.map((d) => d.minutes).reduce(
                (a, b) => a > b ? a : b,
              );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: ZyraColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ZyraColors.primary.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.weeklyChart ?? 'Haftalık Çalışma Grafiği',
                style: ZyraTypography.titleMedium.copyWith(
                  color: ZyraColors.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekData.map((data) {
                    return _BarChartItem(
                      day: dayNames[data.dayIndex - 1],
                      minutes: data.minutes,
                      maxMinutes: maxMinutes,
                    );
                  }).toList(),
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

  List<String> _getDayNames(AppLocalizations? l10n) {
    return [
      l10n?.dayMonday ?? 'Mon',
      l10n?.dayTuesday ?? 'Tue',
      l10n?.dayWednesday ?? 'Wed',
      l10n?.dayThursday ?? 'Thu',
      l10n?.dayFriday ?? 'Fri',
      l10n?.daySaturday ?? 'Sat',
      l10n?.daySunday ?? 'Sun',
    ];
  }
}

class _DayData {
  final int dayIndex;
  final int minutes;
  const _DayData({required this.dayIndex, required this.minutes});
}

class _BarChartItem extends StatelessWidget {
  final String day;
  final int minutes;
  final int maxMinutes;

  const _BarChartItem({
    required this.day,
    required this.minutes,
    required this.maxMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final heightFactor = maxMinutes > 0 ? minutes / maxMinutes : 0.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: 32,
          height: 150 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                ZyraColors.primary.withOpacity(0.8),
                ZyraColors.secondary.withOpacity(0.8),
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${minutes}dk',
          style: ZyraTypography.labelSmall.copyWith(
            color: ZyraColors.onSurface.withOpacity(0.6),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: ZyraTypography.labelSmall.copyWith(
            color: ZyraColors.onSurface,
          ),
        ),
      ],
    );
  }
}

class _AchievementBadges extends StatelessWidget {
  final AppLocalizations? l10n;

  const _AchievementBadges({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final badges = [
      {
        'icon': '🔥',
        'title': l10n?.threeDayStreak ?? '3 Gün Seri',
        'description': l10n?.threeDayStreakDesc ?? 'Üst üste 3 gün çalış'
      },
      {
        'icon': '⭐',
        'title': l10n?.first100Points ?? 'İlk 100 Puan',
        'description': l10n?.first100PointsDesc ?? '100 puan topla'
      },
      {
        'icon': '🎯',
        'title': l10n?.focusMaster ?? 'Odak Ustası',
        'description': l10n?.focusMasterDesc ?? '10 seans tamamla'
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZyraColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ZyraColors.secondary.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.achievementBadges ?? 'Başarı Rozetleri',
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
            color: ZyraColors.primary.withOpacity(0.2),
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
                  color: ZyraColors.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
