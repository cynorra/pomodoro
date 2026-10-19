import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/pomodoro/domain/pomodoro_rules.dart';
import 'package:cynora_focus/features/pomodoro/domain/pomodoro_state.dart';

void main() {
  group('nextSessionType', () {
    test('a break is always followed by focus', () {
      expect(nextSessionType(wasFocus: false, completedFocusSessions: 3),
          SessionType.focus);
      expect(nextSessionType(wasFocus: false, completedFocusSessions: 4),
          SessionType.focus);
    });

    test('long break only after every 4th focus session', () {
      final results = [
        for (var n = 1; n <= 8; n++)
          nextSessionType(wasFocus: true, completedFocusSessions: n),
      ];
      expect(results, [
        SessionType.shortBreak,
        SessionType.shortBreak,
        SessionType.shortBreak,
        SessionType.longBreak,
        SessionType.shortBreak,
        SessionType.shortBreak,
        SessionType.shortBreak,
        SessionType.longBreak,
      ]);
    });

    test('zero completed sessions never gives a long break', () {
      expect(nextSessionType(wasFocus: true, completedFocusSessions: 0),
          SessionType.shortBreak);
    });
  });

  group('calendarDaysBetween', () {
    test('same day, any time of day, is zero', () {
      expect(
          calendarDaysBetween(
              DateTime(2026, 5, 1, 0, 1), DateTime(2026, 5, 1, 23, 59)),
          0);
    });

    test('consecutive days are one apart even across midnight by minutes', () {
      expect(
          calendarDaysBetween(
              DateTime(2026, 5, 1, 23, 59), DateTime(2026, 5, 2, 0, 1)),
          1);
    });

    test('month and year boundaries', () {
      expect(
          calendarDaysBetween(DateTime(2026, 1, 31), DateTime(2026, 2, 1)), 1);
      expect(
          calendarDaysBetween(DateTime(2026, 12, 31), DateTime(2027, 1, 1)), 1);
      expect(
          calendarDaysBetween(DateTime(2028, 2, 28), DateTime(2028, 3, 1)), 2);
    });

    test('daylight-saving change days still count as exactly one day', () {
      // European DST dates; the result must not depend on the machine time zone.
      expect(
          calendarDaysBetween(DateTime(2026, 3, 28), DateTime(2026, 3, 29)), 1);
      expect(
          calendarDaysBetween(DateTime(2026, 3, 29), DateTime(2026, 3, 30)), 1);
      expect(
          calendarDaysBetween(DateTime(2026, 10, 24), DateTime(2026, 10, 25)),
          1);
      expect(
          calendarDaysBetween(DateTime(2026, 10, 25), DateTime(2026, 10, 26)),
          1);
    });

    test('going backwards is negative', () {
      expect(
          calendarDaysBetween(DateTime(2026, 5, 3), DateTime(2026, 5, 1)), -2);
    });
  });

  group('effectiveStreak', () {
    final now = DateTime(2026, 6, 10, 12);

    test('studied today keeps the streak', () {
      expect(
          effectiveStreak(
              storedStreak: 5, lastStudy: DateTime(2026, 6, 10, 8), now: now),
          5);
    });

    test('studied yesterday keeps the streak', () {
      expect(
          effectiveStreak(
              storedStreak: 5, lastStudy: DateTime(2026, 6, 9, 22), now: now),
          5);
    });

    test('missed a day breaks the streak', () {
      expect(
          effectiveStreak(
              storedStreak: 5, lastStudy: DateTime(2026, 6, 8, 22), now: now),
          0);
    });

    test('a stored zero stays zero', () {
      expect(
          effectiveStreak(
              storedStreak: 0, lastStudy: DateTime(2026, 6, 10), now: now),
          0);
    });

    test('a missing date keeps the stored value', () {
      expect(effectiveStreak(storedStreak: 3, lastStudy: null, now: now), 3);
    });

    test('UTC timestamps are converted to the local day', () {
      final utc = DateTime.utc(2026, 6, 9, 10);
      expect(effectiveStreak(storedStreak: 2, lastStudy: utc, now: now), 2);
    });
  });

  group('clampConfig', () {
    test('keeps good values', () {
      expect(clampConfig(25, min: 1, max: 180, fallback: 25), 25);
    });

    test('falls back for zero, negative and huge values', () {
      expect(clampConfig(0, min: 1, max: 180, fallback: 25), 25);
      expect(clampConfig(-5, min: 1, max: 180, fallback: 25), 25);
      expect(clampConfig(100000, min: 1, max: 180, fallback: 25), 25);
    });
  });

  group('dailyBonusAvailable', () {
    final now = DateTime(2026, 6, 10, 12);

    test('never granted before', () {
      expect(dailyBonusAvailable(lastGranted: null, now: now), isTrue);
    });

    test('not again on the same day', () {
      expect(
          dailyBonusAvailable(lastGranted: DateTime(2026, 6, 10, 1), now: now),
          isFalse);
    });

    test('available the next day', () {
      expect(
          dailyBonusAvailable(lastGranted: DateTime(2026, 6, 9, 23), now: now),
          isTrue);
    });

    test('a clock set back does not unlock extra grants', () {
      expect(dailyBonusAvailable(lastGranted: DateTime(2026, 6, 11), now: now),
          isFalse);
    });
  });

  group('leaderboardName', () {
    test('trims whitespace', () {
      expect(leaderboardName('  Mia  '), 'Mia');
    });

    test('null becomes empty', () {
      expect(leaderboardName(null), '');
    });

    test('caps at 40 characters', () {
      final long = 'a' * 60;
      expect(leaderboardName(long).length, 40);
    });

    test('does not split emoji or accented characters', () {
      final name = '${'é' * 39}😀😀';
      final out = leaderboardName(name);
      expect(out.runes.length, 40);
      expect(out.endsWith('😀'), isTrue);
    });
  });
}
