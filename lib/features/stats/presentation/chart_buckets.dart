import '../../../core/data/models/study_session.dart';
import 'stats_filter.dart';

/// One bar of the activity chart: study minutes in [start] up to the next bucket.
class ChartBucket {
  final DateTime start;
  final int minutes;
  const ChartBucket(this.start, this.minutes);
}

/// First instant the statistics window for [filter] includes. Week and month
/// are whole calendar days ending today, so the numbers and the chart agree.
DateTime statsWindowStart(StatsFilter filter, DateTime now) {
  switch (filter) {
    case StatsFilter.week:
      return DateTime(now.year, now.month, now.day - 6);
    case StatsFilter.month:
      return DateTime(now.year, now.month, now.day - 29);
    case StatsFilter.allTime:
      return DateTime(2020);
  }
}

/// Chart bars for [filter]: 7 days for the week, 5 six-day slices for the last
/// 30 days, and the last 6 calendar months for all time. The count is fixed so
/// the chart always fits the screen no matter how much history there is.
List<ChartBucket> buildChartBuckets({
  required Iterable<StudySession> sessions,
  required StatsFilter filter,
  required DateTime now,
}) {
  final starts = <DateTime>[];
  final ends = <DateTime>[];

  switch (filter) {
    case StatsFilter.week:
      for (var i = 0; i < 7; i++) {
        starts.add(DateTime(now.year, now.month, now.day - 6 + i));
        ends.add(DateTime(now.year, now.month, now.day - 5 + i));
      }
    case StatsFilter.month:
      for (var k = 0; k < 5; k++) {
        starts.add(DateTime(now.year, now.month, now.day - 29 + 6 * k));
        ends.add(DateTime(now.year, now.month, now.day - 29 + 6 * (k + 1)));
      }
    case StatsFilter.allTime:
      for (var k = 0; k < 6; k++) {
        starts.add(DateTime(now.year, now.month - 5 + k, 1));
        ends.add(DateTime(now.year, now.month - 4 + k, 1));
      }
  }

  final minutes = List<int>.filled(starts.length, 0);
  for (final s in sessions) {
    final d = s.date.isUtc ? s.date.toLocal() : s.date;
    for (var i = 0; i < starts.length; i++) {
      if (!d.isBefore(starts[i]) && d.isBefore(ends[i])) {
        minutes[i] += s.durationSeconds ~/ 60;
        break;
      }
    }
  }

  return [
    for (var i = 0; i < starts.length; i++) ChartBucket(starts[i], minutes[i]),
  ];
}
