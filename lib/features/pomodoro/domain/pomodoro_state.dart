enum SessionType { focus, shortBreak, longBreak }

class PomodoroState {
  final int remainingSeconds;
  final bool isRunning;
  final int totalPoints;
  final SessionType sessionType;

  const PomodoroState({
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.totalPoints = 0,
    this.sessionType = SessionType.focus,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    int? totalPoints,
    SessionType? sessionType,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      totalPoints: totalPoints ?? this.totalPoints,
      sessionType: sessionType ?? this.sessionType,
    );
  }
}
