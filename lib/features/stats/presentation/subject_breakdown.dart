import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/zyra_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../subjects/domain/subject_rules.dart';
import 'stats_provider.dart';

/// Horizontal bars: focus minutes per subject in the selected period.
class SubjectBreakdown extends ConsumerWidget {
  const SubjectBreakdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final sessions = ref.watch(statsDataProvider).value ?? const [];
    final rows = minutesBySubject(
      sessions.map((s) => (subject: s.subject, seconds: s.durationSeconds)),
    );
    if (rows.isEmpty) return const SizedBox.shrink();
    final top = rows.first.value == 0 ? 1 : rows.first.value;

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
            l10n.statsBySubject,
            style:
                ZyraTypography.titleMedium.copyWith(color: ZyraColors.primary),
          ),
          const SizedBox(height: 12),
          for (final r in rows.take(8))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(r.key,
                            overflow: TextOverflow.ellipsis,
                            style: ZyraTypography.bodyMedium),
                      ),
                      Text(l10n.minutesShort(r.value),
                          style: ZyraTypography.bodyMedium.copyWith(
                            color: ZyraColors.onSurface.withValues(alpha: 0.7),
                          )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: r.value / top,
                      minHeight: 6,
                      color: ZyraColors.primary,
                      backgroundColor:
                          ZyraColors.onSurface.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
