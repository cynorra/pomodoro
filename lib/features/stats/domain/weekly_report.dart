/// The last seven days (today included) compared with the seven before.
class WeeklyReport {
  final int totalMinutes;
  final int previousMinutes;
  final int activeDays;
  final String topSubject;

  const WeeklyReport({
    this.totalMinutes = 0,
    this.previousMinutes = 0,
    this.activeDays = 0,
    this.topSubject = '',
  });

  /// Change against the previous week in percent; null when there is no
  /// previous week to compare with.
  int? get changePercent => previousMinutes <= 0
      ? null
      : (((totalMinutes - previousMinutes) * 100) / previousMinutes).round();
}

WeeklyReport buildWeeklyReport(
  Iterable<({DateTime date, int seconds, String subject})> sessions,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final weekStart = DateTime(today.year, today.month, today.day - 6);
  final prevStart = DateTime(today.year, today.month, today.day - 13);
  var total = 0;
  var prev = 0;
  final days = <int>{};
  final bySubject = <String, int>{};
  for (final s in sessions) {
    final d = DateTime(s.date.year, s.date.month, s.date.day);
    if (!d.isBefore(weekStart) && !d.isAfter(today)) {
      total += s.seconds;
      days.add(d.millisecondsSinceEpoch);
      if (s.subject.isNotEmpty) {
        bySubject[s.subject] = (bySubject[s.subject] ?? 0) + s.seconds;
      }
    } else if (!d.isBefore(prevStart) && d.isBefore(weekStart)) {
      prev += s.seconds;
    }
  }
  var top = '';
  var topSeconds = 0;
  bySubject.forEach((k, v) {
    if (v > topSeconds) {
      top = k;
      topSeconds = v;
    }
  });
  return WeeklyReport(
    totalMinutes: total ~/ 60,
    previousMinutes: prev ~/ 60,
    activeDays: days.length,
    topSubject: top,
  );
}

/// Next [count] Sundays at [hour]:00 that are still in the future.
List<DateTime> nextSundays(DateTime now, {int hour = 19, int count = 4}) {
  final out = <DateTime>[];
  for (var i = 0; i < 7 * (count + 1) && out.length < count; i++) {
    final at = DateTime(now.year, now.month, now.day + i, hour);
    if (at.weekday == DateTime.sunday && at.isAfter(now)) out.add(at);
  }
  return out;
}
