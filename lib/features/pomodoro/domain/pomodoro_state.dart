enum SessionType { focus, shortBreak, longBreak }

/// What a finished session paid out; the screen shows it once.
class SessionReward {
  /// Grows with every session so listeners can tell two equal rewards apart.
  final int id;
  final int points;
  final int boostPercent;
  final bool wasFocus;

  const SessionReward({
    required this.id,
    required this.points,
    this.boostPercent = 0,
    this.wasFocus = true,
  });
}

class PomodoroState {
  final int remainingSeconds;
  final bool isRunning;
  final int totalPoints;
  final SessionType sessionType;
  final SessionReward? lastReward;

  const PomodoroState({
    this.remainingSeconds = 25 * 60,
    this.isRunning = false,
    this.totalPoints = 0,
    this.sessionType = SessionType.focus,
    this.lastReward,
  });

  PomodoroState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    int? totalPoints,
    SessionType? sessionType,
    SessionReward? lastReward,
  }) {
    return PomodoroState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      totalPoints: totalPoints ?? this.totalPoints,
      sessionType: sessionType ?? this.sessionType,
      lastReward: lastReward ?? this.lastReward,
    );
  }
}
