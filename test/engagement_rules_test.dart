import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/profile/domain/level_rules.dart';
import 'package:cynora_focus/features/stats/domain/weekly_report.dart';
import 'package:cynora_focus/features/subjects/domain/subject_rules.dart';
import 'package:cynora_focus/features/tasks/domain/task_rules.dart';

void main() {
  test('levels grow with lifetime points', () {
    expect(levelForPoints(0), 1);
    expect(levelForPoints(49), 1);
    expect(levelForPoints(50), 2);
    expect(levelForPoints(200), 3);
    expect(levelProgress(125), closeTo(0.5, 0.001));
  });

  test('subjects: clean, dedupe, cap and total', () {
    expect(addSubject([], '  Math  '), ['Math']);
    expect(addSubject(['Math'], 'math'), ['Math']);
    expect(addSubject([], '   '), isEmpty);
    expect(cleanSubject('x' * 40).length, maxSubjectLength);
    final rows = minutesBySubject([
      (subject: 'A', seconds: 600),
      (subject: 'B', seconds: 1800),
      (subject: '', seconds: 9999),
      (subject: 'A', seconds: 600),
    ]);
    expect(rows.map((e) => e.key), ['B', 'A']);
    expect(rows.first.value, 30);
  });

  test('weekly report compares with the week before', () {
    final now = DateTime(2026, 11, 22, 12);
    final r = buildWeeklyReport([
      (date: DateTime(2026, 11, 22, 9), seconds: 1500, subject: 'Math'),
      (date: DateTime(2026, 11, 20, 9), seconds: 1500, subject: 'Math'),
      (date: DateTime(2026, 11, 12, 9), seconds: 1500, subject: 'Old'),
      (date: DateTime(2026, 10, 1), seconds: 9999, subject: 'Ancient'),
    ], now);
    expect(r.totalMinutes, 50);
    expect(r.previousMinutes, 25);
    expect(r.activeDays, 2);
    expect(r.topSubject, 'Math');
    expect(r.changePercent, 100);
  });

  test('nextSundays returns future Sundays at the hour', () {
    final out = nextSundays(DateTime(2026, 11, 23, 8)); // a Monday
    expect(out.length, 4);
    expect(out.every((d) => d.weekday == DateTime.sunday && d.hour == 19), isTrue);
    expect(out.first.isAfter(DateTime(2026, 11, 23)), isTrue);
  });

  test('tasks round-trip and tolerate bad data', () {
    final tasks = addTask(addTask([], 'Read ch. 3'), '  ');
    expect(tasks.length, 1);
    expect(decodeTasks(encodeTasks(tasks.map((t) => t.toggled()).toList())).first.done,
        isTrue);
    expect(decodeTasks('not json'), isEmpty);
    expect(sortedTasks([const TaskItem('a', done: true), const TaskItem('b')])
        .first
        .title, 'b');
  });
}
