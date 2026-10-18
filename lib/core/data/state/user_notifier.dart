import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/database_service.dart';
import '../models/user_stats.dart';
import 'user_state.dart';

final initialUserProvider = Provider<UserState>((ref) {
  return const UserState();
});

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  final initial = ref.watch(initialUserProvider);
  return UserNotifier(initial);
});

class UserNotifier extends StateNotifier<UserState> {
  UserNotifier(super.initialState);

  Future<void> addPoints(int points) async {
    state = state.copyWith(totalPoints: state.totalPoints + points);
    await _persistStats();
  }

  Future<void> deductPoints(int points) async {
    final newPoints = (state.totalPoints - points).clamp(0, 99999999);
    state = state.copyWith(totalPoints: newPoints);
    await _persistStats();
  }

  Future<void> addStudyMinutes(int minutes) async {
    state = state.copyWith(totalStudyMinutes: state.totalStudyMinutes + minutes);
    await _persistStats();
  }

  Future<void> _persistStats() async {
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
          if (state.totalPoints > stats.lifetimePointsEarned) {
            stats.lifetimePointsEarned = state.totalPoints;
          }
        }
        await isar.userStats.put(stats);
      });
    } catch (_) {}
    await _syncToCloud();
  }

  // Keeps the signed-in user's public leaderboard document up to date.
  Future<void> _syncToCloud() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('leaderboard').doc(user.uid).set({
        'displayName': user.displayName ?? '',
        'totalPoints': state.totalPoints,
        'totalStudyMinutes': state.totalStudyMinutes,
      }, SetOptions(merge: true));
    } catch (_) {}
  }
}
