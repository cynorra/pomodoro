import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../database/database_service.dart';
import '../models/achievement.dart';
import '../models/cafe_item.dart';
import '../models/study_session.dart';
import '../models/user_stats.dart';
import 'share_service.dart';

/// Builds a machine-readable copy of the user's data (KVKK m.11 / data
/// portability) and hands it to the system share sheet.
class DataExportService {
  static Future<Map<String, dynamic>> buildExport() async {
    final isar = DatabaseService.instance;
    final stats = await isar.userStats.where().findFirst();
    final sessions = await isar.studySessions.where().findAll();
    final achievements = await isar.achievements.where().findAll();
    final items = await isar.cafeItems.where().findAll();
    final user = FirebaseAuth.instance.currentUser;

    return {
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'app': 'Study Cafe',
      'account': user == null
          ? null
          : {
              'uid': user.uid,
              'email': user.email,
              'displayName': user.displayName,
            },
      'stats': stats == null
          ? null
          : {
              'totalPoints': stats.totalPoints,
              'lifetimePointsEarned': stats.lifetimePointsEarned,
              'totalStudyMinutes': stats.totalStudyMinutes,
              'currentStreak': stats.currentStreak,
              'longestStreak': stats.longestStreak,
              'lastStudyDate': stats.lastStudyDate?.toUtc().toIso8601String(),
            },
      'sessions': [
        for (final s in sessions)
          {
            'date': s.date.toUtc().toIso8601String(),
            'durationSeconds': s.durationSeconds,
            'pointsEarned': s.pointsEarned,
            'sessionType': s.sessionType,
            'subject': s.subject,
          },
      ],
      'achievements': [
        for (final a in achievements)
          {
            'id': a.achievementId,
            'unlocked': a.isUnlocked,
            'unlockedAt': a.unlockedAt?.toUtc().toIso8601String(),
          },
      ],
      'cafeItems': [
        for (final i in items)
          {'id': i.itemId, 'owned': i.isOwned, 'quantity': i.quantity},
      ],
    };
  }

  static Future<void> exportAndShare() async {
    final data = await buildExport();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/study-cafe-data.json');
    // Sharing is asynchronous (the receiving app reads the file later), so the
    // file is not deleted right away; it is replaced on the next export and
    // removed by "Clear cache" and on account deletion.
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
    await ShareService.shareGeneral(
      text: 'Study Cafe',
      images: [file],
      subject: 'Study Cafe data export',
    );
  }
}
