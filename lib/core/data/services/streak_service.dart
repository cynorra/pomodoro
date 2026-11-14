import 'dart:math' show max;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar_community/isar.dart';
import '../database/database_service.dart';
import '../models/cafe_item.dart';
import '../models/user_stats.dart';
import '../../../features/cafe/domain/cafe_rules.dart';
import '../../../features/pomodoro/domain/pomodoro_rules.dart';
import '../../utils/global_exception_handler.dart';

class StreakService {
  static Future<void> updateStreakOnSessionComplete() async {
    try {
      await DatabaseService.instance.writeTxn(() async {
        final stats =
            await DatabaseService.instance.userStats.where().findFirst();

        final nowUtc = DateTime.now().toUtc();
        final localNow = DateTime.now();

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
        // Calendar-day arithmetic: a 23 or 25 hour DST day is still one day.
        final diff = calendarDaysBetween(lastLocal, localNow);

        if (diff == 0) return;

        // A streak shield in the cafe inventory covers each missed day.
        final shield = await DatabaseService.instance.cafeItems
            .filter()
            .itemIdEqualTo(streakShieldId)
            .findFirst();
        final result = streakAfterSession(
          storedStreak: stats.currentStreak,
          daysSinceLast: diff,
          shields: shield?.quantity ?? 0,
        );
        if (shield != null && result.shieldsUsed > 0) {
          shield.quantity -= result.shieldsUsed;
          shield.isOwned = shield.quantity > 0;
          await DatabaseService.instance.cafeItems.put(shield);
        }
        stats.currentStreak = result.streak;
        stats.longestStreak = max(stats.longestStreak, stats.currentStreak);
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
      await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(user.uid)
          .set({
        'currentStreak': stats == null
            ? 0
            : effectiveStreak(
                storedStreak: stats.currentStreak,
                lastStudy: stats.lastStudyDate,
                now: DateTime.now(),
                shields: await DatabaseService.itemQuantity(streakShieldId),
              ),
        'longestStreak': stats?.longestStreak ?? 0,
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  static Future<int> getCurrentStreak() async {
    try {
      final stats =
          await DatabaseService.instance.userStats.where().findFirst();
      if (stats == null) return 0;
      // A streak that was not continued yesterday or today is already over.
      return effectiveStreak(
        storedStreak: stats.currentStreak,
        lastStudy: stats.lastStudyDate,
        now: DateTime.now(),
        shields: await DatabaseService.itemQuantity(streakShieldId),
      );
    } catch (_) {
      return 0;
    }
  }
}
