import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/home/domain/daily_goal.dart';

void main() {
  test('parseDailyGoal falls back to the default for bad input', () {
    expect(parseDailyGoal(null), defaultDailyGoalMinutes);
    expect(parseDailyGoal('abc'), defaultDailyGoalMinutes);
    expect(parseDailyGoal('0'), defaultDailyGoalMinutes);
    expect(parseDailyGoal('90'), 90);
  });

  test('dailyGoalProgress is clamped and safe for a zero goal', () {
    expect(dailyGoalProgress(25, 50), 0.5);
    expect(dailyGoalProgress(80, 50), 1.0);
    expect(dailyGoalProgress(10, 0), 0.0);
  });
}
