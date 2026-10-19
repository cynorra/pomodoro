import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import '../database/database_service.dart';
import '../models/user_stats.dart';
import 'user_state.dart';
import '../../../features/pomodoro/domain/pomodoro_rules.dart';

final initialUserProvider = Provider<UserState>((ref) {
  return const UserState();
});

final userProvider =
    NotifierProvider<UserNotifier, UserState>(UserNotifier.new);

class UserNotifier extends Notifier<UserState> {
  @override
  UserState build() => ref.watch(initialUserProvider);

  Future<void> addPoints(int points) async {
    state = state.copyWith(totalPoints: state.totalPoints + points);
    await _persistStats(earned: points);
  }

  Future<void> deductPoints(int points) async {
    final newPoints = (state.totalPoints - points).clamp(0, 99999999);
    state = state.copyWith(totalPoints: newPoints);
    await _persistStats();
  }

  Future<void> addStudyMinutes(int minutes) async {
    state =
        state.copyWith(totalStudyMinutes: state.totalStudyMinutes + minutes);
    await _persistStats();
  }

  /// [earned] is the amount just gained; it feeds the lifetime total, which
  /// (unlike the balance) never goes down when points are spent.
  Future<void> _persistStats({int earned = 0}) async {
    var lifetime = 0;
    try {
      final isar = DatabaseService.instance;
      await isar.writeTxn(() async {
        var stats = await isar.userStats.where().findFirst();
        if (stats == null) {
          stats = UserStats()
            ..totalPoints = state.totalPoints
            ..totalStudyMinutes = state.totalStudyMinutes
            ..lifetimePointsEarned = state.totalPoints
            ..isUtcMigrated = true;
        } else {
          stats.totalPoints = state.totalPoints;
          stats.totalStudyMinutes = state.totalStudyMinutes;
          stats.lifetimePointsEarned += earned;
          // Older installs tracked the highest balance instead; never go below it.
          if (stats.lifetimePointsEarned < state.totalPoints) {
            stats.lifetimePointsEarned = state.totalPoints;
          }
        }
        lifetime = stats.lifetimePointsEarned;
        await isar.userStats.put(stats);
      });
    } catch (_) {}
    await _syncToCloud(lifetime);
  }

  // Keeps the signed-in user's public leaderboard document up to date.
  Future<void> _syncToCloud(int lifetimePoints) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance
          .collection('leaderboard')
          .doc(user.uid)
          .set({
        'displayName': leaderboardName(user.displayName),
        // Total points earned, so spending points on treats does not lower the rank.
        'totalPoints': lifetimePoints > 0 ? lifetimePoints : state.totalPoints,
        'totalStudyMinutes': state.totalStudyMinutes,
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
