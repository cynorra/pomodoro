// When the daily study reminders should fire. Pure so it can be tested.

const reminderDaysAhead = 14;
const defaultReminderHour = 18;
const defaultReminderMinute = 0;

/// Local times of the next reminders, one per day at [hour]:[minute].
///
/// Reminders are scheduled as separate one-off notifications (so each day can
/// carry a different message) for [days] days ahead; the app refreshes them
/// every time it is opened. A moment that has already passed is skipped, and
/// today is skipped too when [studiedToday] (no nagging after a session).
List<DateTime> reminderTimes({
  required DateTime now,
  required int hour,
  required int minute,
  bool studiedToday = false,
  int days = reminderDaysAhead,
}) {
  final result = <DateTime>[];
  for (var i = 0; i < days; i++) {
    // DateTime(...) normalizes day overflow and follows local DST rules.
    final at = DateTime(now.year, now.month, now.day + i, hour, minute);
    if (!at.isAfter(now)) continue;
    if (i == 0 && studiedToday) continue;
    result.add(at);
  }
  return result;
}
