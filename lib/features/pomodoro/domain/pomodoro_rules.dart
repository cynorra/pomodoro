import '../../cafe/domain/cafe_rules.dart';
import 'pomodoro_state.dart';

/// Pure rules behind the timer, streaks and bonuses. Kept free of Firebase,
/// Isar and Flutter so they can be unit-tested directly.

/// Which session follows the one that just ended. A long break comes after
/// every 4th completed focus session.
SessionType nextSessionType({
  required bool wasFocus,
  required int completedFocusSessions,
}) {
  if (!wasFocus) return SessionType.focus;
  if (completedFocusSessions > 0 && completedFocusSessions % 4 == 0) {
    return SessionType.longBreak;
  }
  return SessionType.shortBreak;
}

/// Whole calendar days from [from] to [to], ignoring the time of day and
/// daylight-saving changes (a 23 or 25 hour day still counts as one day).
int calendarDaysBetween(DateTime from, DateTime to) {
  final a = DateTime.utc(from.year, from.month, from.day);
  final b = DateTime.utc(to.year, to.month, to.day);
  return b.difference(a).inDays;
}

/// The streak to show: the stored value while it is still alive (studied today
/// or yesterday), otherwise 0, because a missed day has already broken it.
///
/// [shields] are streak shields in the cafe inventory; each one covers a
/// missed day, so the streak stays alive while enough of them are left.
int effectiveStreak({
  required int storedStreak,
  required DateTime? lastStudy,
  required DateTime now,
  int shields = 0,
}) {
  if (storedStreak <= 0) return 0;
  if (lastStudy == null) return storedStreak;
  final last = lastStudy.isUtc ? lastStudy.toLocal() : lastStudy;
  return streakAlive(
          daysSinceLast: calendarDaysBetween(last, now), shields: shields)
      ? storedStreak
      : 0;
}

/// Keeps a remotely configured number inside a sane range.
int clampConfig(int value,
    {required int min, required int max, required int fallback}) {
  if (value < min || value > max) return fallback;
  return value;
}

/// True when a once-a-day bonus has not been given on [now]'s calendar day yet.
bool dailyBonusAvailable(
    {required DateTime? lastGranted, required DateTime now}) {
  if (lastGranted == null) return true;
  return calendarDaysBetween(lastGranted, now) >= 1;
}

/// Display name as stored on the public leaderboard: trimmed and at most
/// [maxLength] characters (the Firestore rules reject anything longer).
String leaderboardName(String? name, {int maxLength = 40}) {
  final trimmed = (name ?? '').trim();
  final runes = trimmed.runes.toList();
  if (runes.length <= maxLength) return trimmed;
  return String.fromCharCodes(runes.take(maxLength)).trimRight();
}
