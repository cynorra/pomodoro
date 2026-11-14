import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/services/notification_texts.dart';
import 'package:cynora_focus/core/data/services/reminder_rules.dart';
import 'package:cynora_focus/features/cafe/domain/cafe_rules.dart';
import 'package:cynora_focus/features/pomodoro/domain/pomodoro_rules.dart';

void main() {
  group('boosts', () {
    test('a boost multiplies the points', () {
      final espresso = boostFor('coffee_espresso');
      expect(espresso, isNotNull);
      expect(boostedPoints(20, espresso), 40);
      expect(boostedPoints(20, boostFor('tea_green')), 30);
      expect(boostedPoints(20, boostFor('cake_cheese')), 60);
    });

    test('no boost leaves the points alone', () {
      expect(boostedPoints(20, null), 20);
      expect(boostedPoints(0, boostFor('coffee_espresso')), 0);
    });

    test('items that are not boosts start none', () {
      expect(boostFor(streakShieldId), isNull);
      expect(boostFor('does_not_exist'), isNull);
    });

    test('a boost lasts its sessions and then ends', () {
      var boost = boostFor('coffee_espresso');
      var used = 0;
      while (boost != null) {
        boost = boost.afterSession();
        used++;
      }
      expect(used, 3);
    });

    test('a stored boost survives a round trip, junk is rejected', () {
      final boost = boostFor('cake_cheese')!;
      final back = ActiveBoost.fromJson(boost.toJson());
      expect(back?.percent, boost.percent);
      expect(back?.sessionsLeft, boost.sessionsLeft);
      expect(ActiveBoost.fromJson({'id': 'x', 'pct': 50, 'left': 2}), isNull);
      expect(ActiveBoost.fromJson({'id': 'x', 'pct': 200, 'left': 0}), isNull);
      expect(ActiveBoost.fromJson('nope'), isNull);
    });

    test('labels', () {
      expect(boostLabel(200), '×2');
      expect(boostLabel(300), '×3');
      expect(boostLabel(150), '+50%');
    });

    test('every catalog item can pay for itself or has a clear use', () {
      for (final item in cafeCatalog) {
        expect(item.cost, greaterThan(0));
        if (item.effect == CafeEffect.pointBoost) {
          expect(item.boostPercent, greaterThan(100));
          expect(item.boostSessions, greaterThan(0));
        }
      }
      expect(cafeCatalog.map((e) => e.itemId).toSet().length,
          cafeCatalog.length);
    });
  });

  group('streak shield', () {
    test('continuing normally needs no shield', () {
      final r = streakAfterSession(
          storedStreak: 4, daysSinceLast: 1, shields: 0);
      expect(r.streak, 5);
      expect(r.shieldsUsed, 0);
    });

    test('a missed day is covered by one shield', () {
      final r = streakAfterSession(
          storedStreak: 4, daysSinceLast: 2, shields: 2);
      expect(r.streak, 5);
      expect(r.shieldsUsed, 1);
    });

    test('not enough shields restarts the streak and keeps them', () {
      final r = streakAfterSession(
          storedStreak: 4, daysSinceLast: 4, shields: 1);
      expect(r.streak, 1);
      expect(r.shieldsUsed, 0);
    });

    test('same day changes nothing', () {
      final r = streakAfterSession(
          storedStreak: 4, daysSinceLast: 0, shields: 1);
      expect(r.streak, 4);
      expect(r.shieldsUsed, 0);
    });

    test('displayed streak stays alive while shields cover the gap', () {
      final now = DateTime(2026, 11, 14, 12);
      final lastStudy = DateTime(2026, 11, 12, 9);
      expect(
          effectiveStreak(storedStreak: 6, lastStudy: lastStudy, now: now),
          0);
      expect(
          effectiveStreak(
              storedStreak: 6, lastStudy: lastStudy, now: now, shields: 1),
          6);
    });
  });

  group('daily reminders', () {
    test('one reminder per day, in the future only', () {
      final now = DateTime(2026, 11, 14, 10);
      final times = reminderTimes(now: now, hour: 18, minute: 30);
      expect(times.length, reminderDaysAhead);
      expect(times.first, DateTime(2026, 11, 14, 18, 30));
      expect(times.every((t) => t.isAfter(now)), isTrue);
    });

    test('today is skipped once the time has passed', () {
      final now = DateTime(2026, 11, 14, 19);
      final times = reminderTimes(now: now, hour: 18, minute: 0);
      expect(times.first, DateTime(2026, 11, 15, 18));
      expect(times.length, reminderDaysAhead - 1);
    });

    test('today is skipped after studying', () {
      final now = DateTime(2026, 11, 14, 10);
      final times =
          reminderTimes(now: now, hour: 18, minute: 0, studiedToday: true);
      expect(times.first, DateTime(2026, 11, 15, 18));
    });

    test('runs across a month end', () {
      final now = DateTime(2026, 11, 29, 10);
      final times = reminderTimes(now: now, hour: 8, minute: 0, days: 4);
      expect(times.map((t) => t.day), [30, 1, 2]);
    });
  });

  group('notification texts', () {
    test('English is the default for unknown languages', () {
      expect(NotificationTexts.forLanguage('xx').focusDone,
          NotificationTexts.forLanguage('en').focusDone);
      expect(NotificationTexts.forLanguage(null).breakDone,
          NotificationTexts.forLanguage('en').breakDone);
    });

    test('many languages are available, English and Turkish included', () {
      final languages = NotificationTexts.languages.toSet();
      expect(languages.length, greaterThanOrEqualTo(15));
      expect(languages, containsAll(['en', 'tr', 'de', 'es', 'fr', 'ar']));
    });

    test('every language is complete', () {
      for (final code in NotificationTexts.languages) {
        final t = NotificationTexts.forLanguage(code);
        expect(t.focusDone.trim(), isNotEmpty, reason: code);
        expect(t.breakDone.trim(), isNotEmpty, reason: code);
        expect(t.timerFocus.trim(), isNotEmpty, reason: code);
        expect(t.timerBreak.trim(), isNotEmpty, reason: code);
        expect(t.channelTimer.trim(), isNotEmpty, reason: code);
        expect(t.channelReminder.trim(), isNotEmpty, reason: code);
        expect(t.running, contains('{n}'), reason: code);
        expect(t.reminders.length, 5, reason: code);
        for (final r in t.reminders) {
          expect(r.trim(), isNotEmpty, reason: code);
        }
      }
    });

    test('the running body shows the minutes', () {
      expect(NotificationTexts.forLanguage('en').runningBody(25),
          contains('25'));
      expect(NotificationTexts.forLanguage('tr').runningBody(5),
          contains('5'));
    });

    test('reminders rotate and never run out of range', () {
      final t = NotificationTexts.forLanguage('en');
      expect(t.reminder(0), t.reminders[0]);
      expect(t.reminder(5), t.reminders[0]);
      expect(t.reminder(8000), isNotEmpty);
    });
  });
}
