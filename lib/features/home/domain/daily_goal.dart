/// Daily study goal: the choices offered and the progress maths.
const dailyGoalOptions = [25, 50, 90, 120, 180];
const defaultDailyGoalMinutes = 50;

/// Parses a stored goal; anything unknown falls back to the default.
int parseDailyGoal(String? raw) {
  final value = int.tryParse(raw ?? '');
  if (value == null || value < 5 || value > 720) return defaultDailyGoalMinutes;
  return value;
}

/// 0.0 to 1.0, safe for a zero goal.
double dailyGoalProgress(int doneMinutes, int goalMinutes) {
  if (goalMinutes <= 0) return 0;
  return (doneMinutes / goalMinutes).clamp(0.0, 1.0).toDouble();
}
