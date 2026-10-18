import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';

enum StatsFilter { week, month, allTime }

final selectedFilterProvider =
    StateProvider<StatsFilter>((ref) => StatsFilter.week);

final statsDataProvider = FutureProvider<List<StudySession>>((ref) async {
  final filter = ref.watch(selectedFilterProvider);

  final now = DateTime.now();
  DateTime startDate;

  switch (filter) {
    case StatsFilter.week:
      startDate = now.subtract(const Duration(days: 7));
      break;
    case StatsFilter.month:
      startDate = now.subtract(const Duration(days: 30));
      break;
    case StatsFilter.allTime:
      startDate = DateTime(2020);
      break;
  }

  final all = await DatabaseService.instance.studySessions
      .filter()
      .dateGreaterThan(startDate)
      .sortByDateDesc()
      .findAll();

  return all.where((s) => s.sessionType == 'focus').toList();
});
