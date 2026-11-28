import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../core/ui/widgets/glass_card.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/daily_goal.dart';

/// Quiet 2px progress track for today's focus minutes. Tap to pick another goal.
class DailyGoalCard extends ConsumerStatefulWidget {
  const DailyGoalCard({super.key});

  @override
  ConsumerState<DailyGoalCard> createState() => _DailyGoalCardState();
}

class _DailyGoalCardState extends ConsumerState<DailyGoalCard> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'daily_goal_minutes';

  int _goal = defaultDailyGoalMinutes;
  int _done = 0;

  @override
  void initState() {
    super.initState();
    _loadGoal();
    _loadToday();
  }

  Future<void> _loadGoal() async {
    try {
      final goal = parseDailyGoal(await _storage.read(key: _key));
      if (mounted) setState(() => _goal = goal);
    } catch (_) {}
  }

  Future<void> _loadToday() async {
    try {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final sessions = await DatabaseService.instance.studySessions
          .filter()
          .sessionTypeEqualTo('focus')
          .dateGreaterThan(start, include: true)
          .findAll();
      final seconds = sessions.fold<int>(0, (a, s) => a + s.durationSeconds);
      if (mounted) setState(() => _done = seconds ~/ 60);
    } catch (_) {}
  }

  Future<void> _pickGoal() async {
    final l10n = AppLocalizations.of(context);
    final picked = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: ZyraColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dailyGoalChange,
                style: ZyraTypography.titleLarge,
              ),
              const SizedBox(height: 12),
              for (final m in dailyGoalOptions)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  title: Text(
                    '$m min',
                    style: ZyraTypography.dataMono.copyWith(fontSize: 15),
                  ),
                  trailing: m == _goal
                      ? const Icon(Icons.check_rounded, color: ZyraColors.primary)
                      : null,
                  onTap: () => Navigator.pop(ctx, m),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked == null) return;
    setState(() => _goal = picked);
    try {
      await _storage.write(key: _key, value: '$picked');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(userProvider.select((u) => u.totalStudyMinutes),
        (_, __) => _loadToday());
    final l10n = AppLocalizations.of(context);
    final progress = dailyGoalProgress(_done, _goal);
    final reached = progress >= 1;

    return GestureDetector(
      onTap: _pickGoal,
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.dailyGoalTitle.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ZyraTypography.sectionLabel.copyWith(
                      color: reached
                          ? ZyraColors.secondary
                          : ZyraColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.dailyGoalProgress(_done, _goal),
                  style: ZyraTypography.dataMono.copyWith(
                    color: ZyraColors.onBackground,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3,
                color: reached ? ZyraColors.secondary : ZyraColors.primary,
                backgroundColor: ZyraColors.surfaceElevated,
              ),
            ),
            if (reached) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 14,
                    color: ZyraColors.secondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      l10n.dailyGoalReached,
                      style: ZyraTypography.bodySmall.copyWith(
                        color: ZyraColors.secondaryBright,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
