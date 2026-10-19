import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import 'chart_buckets.dart';
import 'stats_filter.dart';

export 'stats_filter.dart';

class StatsFilterNotifier extends Notifier<StatsFilter> {
  @override
  StatsFilter build() => StatsFilter.week;

  void select(StatsFilter filter) => state = filter;
}

final selectedFilterProvider =
    NotifierProvider<StatsFilterNotifier, StatsFilter>(StatsFilterNotifier.new);

final statsDataProvider = FutureProvider<List<StudySession>>((ref) async {
  final filter = ref.watch(selectedFilterProvider);

  final startDate = statsWindowStart(filter, DateTime.now());

  final all = await DatabaseService.instance.studySessions
      .filter()
      .dateGreaterThan(startDate, include: true)
      .sortByDateDesc()
      .findAll();

  return all.where((s) => s.sessionType == 'focus').toList();
});
