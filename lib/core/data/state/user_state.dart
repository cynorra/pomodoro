class UserState {
  final int totalPoints;
  final int totalStudyMinutes;

  const UserState({
    this.totalPoints = 0,
    this.totalStudyMinutes = 0,
  });

  UserState copyWith({
    int? totalPoints,
    int? totalStudyMinutes,
  }) {
    return UserState(
      totalPoints: totalPoints ?? this.totalPoints,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
    );
  }
}
