import 'package:isar_community/isar.dart';

part 'user_stats.g.dart';

@collection
class UserStats {
  Id id = Isar.autoIncrement;

  int currentStreak = 0;
  int longestStreak = 0;
  int totalPoints = 0;
  int totalStudyMinutes = 0;
  int lifetimePointsEarned = 0;
  DateTime? lastStudyDate;
  bool isUtcMigrated = false;

  UserStats({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.totalPoints = 0,
    this.totalStudyMinutes = 0,
    this.lifetimePointsEarned = 0,
    this.lastStudyDate,
    this.isUtcMigrated = false,
  });
}
