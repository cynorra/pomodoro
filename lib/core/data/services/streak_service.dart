import 'dart:math' show max;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar_community/isar.dart';
import '../database/database_service.dart';
import '../models/user_stats.dart';
import '../../utils/global_exception_handler.dart';

class StreakService {
  static Future<void> updateStreakOnSessionComplete() async {
    try {
      await DatabaseService.instance.writeTxn(() async {
        final stats =
            await DatabaseService.instance.userStats.where().findFirst();

        final nowUtc = DateTime.now().toUtc();
        final localNow = DateTime.now();
        final today = DateTime(
          localNow.year,
          localNow.month,
          localNow.day,
        );

        if (stats == null) {
          await DatabaseService.instance.userStats.put(
            UserStats(
              currentStreak: 1,
              longestStreak: 1,
              lastStudyDate: nowUtc,
              isUtcMigrated: true,
            ),
          );
          return;
        }

        // Points saving must not own lastStudyDate; a missing date or a zero
        // streak means this is the first completed focus session.
        if (stats.lastStudyDate == null || stats.currentStreak == 0) {
          stats.currentStreak = 1;
          stats.longestStreak = max(stats.longestStreak, 1);
          stats.lastStudyDate = nowUtc;
          stats.isUtcMigrated = true;
          await DatabaseService.instance.userStats.put(stats);
          return;
        }

        final stored = stats.lastStudyDate!;
        final lastLocal = stored.isUtc ? stored.toLocal() : stored;
        final lastDay = DateTime(
          lastLocal.year,
          lastLocal.month,
          lastLocal.day,
        );

        final diff = today.difference(lastDay).inDays;

        if (diff == 0) return;

        stats.currentStreak =
            diff == 1 ? stats.currentStreak + 1 : 1;
        stats.longestStreak =
            max(stats.longestStreak, stats.currentStreak);
        stats.lastStudyDate = nowUtc;
        stats.isUtcMigrated = true;

        await DatabaseService.instance.userStats.put(stats);
      });
      await _syncStreakToCloud();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Streak update failed');
    }
  }

  static Future<void> _syncStreakToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final stats =
          await DatabaseService.instance.userStats.where().findFirst();
      await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).set({
        'currentStreak': stats?.currentStreak ?? 0,
        'longestStreak': stats?.longestStreak ?? 0,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<int> getCurrentStreak() async {
    try {
      final stats =
          await DatabaseService.instance.userStats.where().findFirst();
      return stats?.currentStreak ?? 0;
    } catch (_) {
      return 0;
    }
  }
}
