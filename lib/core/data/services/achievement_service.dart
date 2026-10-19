import 'package:isar_community/isar.dart';
import '../database/database_service.dart';
import '../models/achievement.dart';
import '../models/user_stats.dart';
import '../models/study_session.dart';
import '../../utils/global_exception_handler.dart';

class AchievementService {
  static Future<void> seedDefaultAchievements() async {
    try {
      final count = await DatabaseService.instance.achievements.count();
      if (count > 0) return;

      final defaults = [
        Achievement(
          achievementId: 'streak_3',
          nameTr: '3 Gün Seri',
          nameEn: '3 Day Streak',
          descriptionTr: 'Üst üste 3 gün çalış',
          descriptionEn: 'Study 3 days in a row',
          iconEmoji: '🔥',
        ),
        Achievement(
          achievementId: 'points_100',
          nameTr: 'İlk 100 Puan',
          nameEn: 'First 100 Points',
          descriptionTr: '100 puan topla',
          descriptionEn: 'Collect 100 points',
          iconEmoji: '⭐',
        ),
        Achievement(
          achievementId: 'sessions_10',
          nameTr: 'Odak Ustası',
          nameEn: 'Focus Master',
          descriptionTr: '10 seans tamamla',
          descriptionEn: 'Complete 10 sessions',
          iconEmoji: '🎯',
        ),
        Achievement(
          achievementId: 'streak_7',
          nameTr: '1 Hafta Seri',
          nameEn: '1 Week Streak',
          descriptionTr: 'Üst üste 7 gün çalış',
          descriptionEn: 'Study 7 days in a row',
          iconEmoji: '💎',
        ),
        Achievement(
          achievementId: 'points_500',
          nameTr: 'Puan Avcısı',
          nameEn: 'Point Hunter',
          descriptionTr: '500 puan topla',
          descriptionEn: 'Collect 500 points',
          iconEmoji: '🏆',
        ),
      ];

      await DatabaseService.instance.writeTxn(() async {
        await DatabaseService.instance.achievements.putAll(defaults);
      });
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Seed achievements failed');
    }
  }

  static Future<List<Achievement>> checkAndUnlockAchievements() async {
    try {
      final stats =
          await DatabaseService.instance.userStats.where().findFirst();
      if (stats == null) return [];

      // Breaks are not study sessions.
      final totalSessions = await DatabaseService.instance.studySessions
          .filter()
          .sessionTypeEqualTo('focus')
          .count();
      final achievements =
          await DatabaseService.instance.achievements.where().findAll();
      final newlyUnlocked = <Achievement>[];
      final toUpdate = <Achievement>[];

      for (final achievement in achievements) {
        if (achievement.isUnlocked) continue;

        bool shouldUnlock = false;

        switch (achievement.achievementId) {
          case 'streak_3':
            shouldUnlock = stats.currentStreak >= 3;
            break;
          case 'streak_7':
            shouldUnlock = stats.currentStreak >= 7;
            break;
          case 'points_100':
            shouldUnlock = stats.lifetimePointsEarned >= 100;
            break;
          case 'points_500':
            shouldUnlock = stats.lifetimePointsEarned >= 500;
            break;
          case 'sessions_10':
            shouldUnlock = totalSessions >= 10;
            break;
        }

        if (shouldUnlock) {
          achievement.isUnlocked = true;
          achievement.unlockedAt = DateTime.now();
          toUpdate.add(achievement);
          newlyUnlocked.add(achievement);
        }
      }

      if (toUpdate.isNotEmpty) {
        await DatabaseService.instance.writeTxn(() async {
          await DatabaseService.instance.achievements.putAll(toUpdate);
        });
      }

      return newlyUnlocked;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Check achievements failed');
      return [];
    }
  }
}
