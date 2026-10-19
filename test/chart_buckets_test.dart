import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/models/study_session.dart';
import 'package:cynora_focus/features/stats/presentation/chart_buckets.dart';
import 'package:cynora_focus/features/stats/presentation/stats_provider.dart';

StudySession focus(DateTime date, int minutes) => StudySession(
      date: date,
      durationSeconds: minutes * 60,
      pointsEarned: 10,
      sessionType: 'focus',
    );

void main() {
  final now = DateTime(2026, 6, 10, 15, 30); // Wednesday

  group('statsWindowStart', () {
    test('week starts at midnight 6 days ago', () {
      expect(statsWindowStart(StatsFilter.week, now), DateTime(2026, 6, 4));
    });

    test('month starts at midnight 29 days ago', () {
      expect(statsWindowStart(StatsFilter.month, now), DateTime(2026, 5, 12));
    });

    test('all time starts in 2020', () {
      expect(statsWindowStart(StatsFilter.allTime, now), DateTime(2020));
    });

    test('crossing a month boundary', () {
      expect(statsWindowStart(StatsFilter.week, DateTime(2026, 3, 2)),
          DateTime(2026, 2, 24));
    });
  });

  group('buildChartBuckets', () {
    test('week: always 7 daily bars ending today', () {
      final b =
          buildChartBuckets(sessions: [], filter: StatsFilter.week, now: now);
      expect(b.length, 7);
      expect(b.first.start, DateTime(2026, 6, 4));
      expect(b.last.start, DateTime(2026, 6, 10));
      expect(b.every((x) => x.minutes == 0), isTrue);
    });

    test('week: sessions land on the right day and sum up', () {
      final b = buildChartBuckets(
        sessions: [
          focus(DateTime(2026, 6, 10, 8), 25),
          focus(DateTime(2026, 6, 10, 23, 59), 25),
          focus(DateTime(2026, 6, 9, 12), 50),
        ],
        filter: StatsFilter.week,
        now: now,
      );
      expect(b.last.minutes, 50);
      expect(b[5].minutes, 50);
      expect(b.fold<int>(0, (a, x) => a + x.minutes), 100);
    });

    test('week: a session 7 days ago is outside the window', () {
      final b = buildChartBuckets(
        sessions: [focus(DateTime(2026, 6, 3, 23, 59), 25)],
        filter: StatsFilter.week,
        now: now,
      );
      expect(b.fold<int>(0, (a, x) => a + x.minutes), 0);
    });

    test('week: the oldest included instant is midnight 6 days ago', () {
      final b = buildChartBuckets(
        sessions: [focus(DateTime(2026, 6, 4, 0, 0), 25)],
        filter: StatsFilter.week,
        now: now,
      );
      expect(b.first.minutes, 25);
    });

    test('month: 5 bars of 6 days covering the last 30 days exactly', () {
      final b =
          buildChartBuckets(sessions: [], filter: StatsFilter.month, now: now);
      expect(b.length, 5);
      expect(b.first.start, DateTime(2026, 5, 12));
      expect(b[1].start, DateTime(2026, 5, 18));
      expect(b.last.start, DateTime(2026, 6, 5));
    });

    test('month: today falls into the last bar, day 30 ago into the first', () {
      final b = buildChartBuckets(
        sessions: [
          focus(DateTime(2026, 6, 10, 9), 30),
          focus(DateTime(2026, 5, 12, 9), 20),
        ],
        filter: StatsFilter.month,
        now: now,
      );
      expect(b.last.minutes, 30);
      expect(b.first.minutes, 20);
    });

    test('allTime: last 6 calendar months, oldest first', () {
      final b = buildChartBuckets(
          sessions: [], filter: StatsFilter.allTime, now: now);
      expect(b.map((x) => x.start).toList(), [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
        DateTime(2026, 5, 1),
        DateTime(2026, 6, 1),
      ]);
    });

    test('allTime: window wraps over the year boundary', () {
      final b = buildChartBuckets(
        sessions: [],
        filter: StatsFilter.allTime,
        now: DateTime(2026, 2, 15),
      );
      expect(b.first.start, DateTime(2025, 9, 1));
      expect(b.last.start, DateTime(2026, 2, 1));
    });

    test(
        'allTime: sessions are grouped by month and old ones are ignored by the chart',
        () {
      final b = buildChartBuckets(
        sessions: [
          focus(DateTime(2026, 6, 1), 25),
          focus(DateTime(2026, 6, 30), 25),
          focus(DateTime(2026, 3, 15), 60),
          focus(DateTime(2025, 12, 31), 90), // older than 6 months
        ],
        filter: StatsFilter.allTime,
        now: now,
      );
      expect(b.last.minutes, 50);
      expect(b[2].minutes, 60);
      expect(b.fold<int>(0, (a, x) => a + x.minutes), 110);
    });

    test('the bar count never depends on how much history exists', () {
      final many = [
        for (var i = 0; i < 400; i++)
          focus(DateTime(2026, 6, 10).subtract(Duration(days: i)), 25)
      ];
      for (final f in StatsFilter.values) {
        final n = buildChartBuckets(sessions: many, filter: f, now: now).length;
        expect(n, lessThanOrEqualTo(7));
      }
    });

    test('UTC session times are bucketed by their local day', () {
      final b = buildChartBuckets(
        sessions: [focus(DateTime(2026, 6, 10, 9).toUtc(), 25)],
        filter: StatsFilter.week,
        now: now,
      );
      expect(b.last.minutes, 25);
    });
  });
}
