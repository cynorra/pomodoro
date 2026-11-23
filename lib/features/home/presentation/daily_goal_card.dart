import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/daily_goal.dart';

/// Quiet progress bar for today's focus minutes. Tap to pick another goal.
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.dailyGoalChange,
                style: ZyraTypography.titleMedium
                    .copyWith(color: ZyraColors.primary),
              ),
            ),
            for (final m in dailyGoalOptions)
              ListTile(
                title: Text('$m min'),
                trailing: m == _goal
                    ? const Icon(Icons.check, color: ZyraColors.primary)
                    : null,
                onTap: () => Navigator.pop(ctx, m),
              ),
          ],
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
    // Study minutes change after every finished session: refresh today's total.
    ref.listen(userProvider.select((u) => u.totalStudyMinutes),
        (_, __) => _loadToday());
    final l10n = AppLocalizations.of(context);
    final progress = dailyGoalProgress(_done, _goal);
    final reached = progress >= 1;

    return InkWell(
      onTap: _pickGoal,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ZyraColors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (reached ? ZyraColors.primary : ZyraColors.onSurface)
                .withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reached ? Icons.check_circle : Icons.flag_outlined,
                  color: ZyraColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.dailyGoalTitle,
                    style: ZyraTypography.titleMedium
                        .copyWith(color: ZyraColors.primary),
                  ),
                ),
                Text(
                  l10n.dailyGoalProgress(_done, _goal),
                  style: ZyraTypography.bodyMedium.copyWith(
                    color: ZyraColors.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                color: ZyraColors.primary,
                backgroundColor: ZyraColors.onSurface.withValues(alpha: 0.1),
              ),
            ),
            if (reached) ...[
              const SizedBox(height: 8),
              Text(
                l10n.dailyGoalReached,
                style: ZyraTypography.bodyMedium.copyWith(
                  color: ZyraColors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
