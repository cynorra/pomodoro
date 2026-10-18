import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/study_session.dart';
import '../models/cafe_item.dart';
import '../models/user_stats.dart';
import '../models/achievement.dart';
import '../../utils/global_exception_handler.dart';

class DatabaseService {
  static late Isar _isar;
  static bool _initialized = false;
  static bool _seeded = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [
          StudySessionSchema,
          CafeItemSchema,
          UserStatsSchema,
          AchievementSchema,
        ],
        directory: dir.path,
        inspector: kDebugMode,
      );

      _initialized = true;

      try {
        await _migrateData();
      } catch (e, stack) {
        GlobalExceptionHandler.logError(
          e,
          stack,
          'Migration failed, continuing with seed',
        );
      }

      try {
        await _seedDefaultData();
      } catch (e, stack) {
        GlobalExceptionHandler.logError(e, stack, 'Seed failed');
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Database init failed');
      rethrow;
    }
  }

  static Future<void> _migrateData() async {
    await _isar.writeTxn(() async {
      final stats = await _isar.userStats.where().findFirst();
      
      if (stats != null) {
          if (stats.lastStudyDate != null) {
            stats.lastStudyDate = stats.lastStudyDate!.toUtc();
          }
        
        if (stats.lifetimePointsEarned == 0 && stats.totalPoints > 0) {
          stats.lifetimePointsEarned = stats.totalPoints;
        }
        
        await _isar.userStats.put(stats);
      }
    });
  }

  static Future<void> _seedDefaultData() async {
    if (_seeded) return;
    _seeded = true;

    await _seedDefaultCafeItems();
  }

  static Future<void> _seedDefaultCafeItems() async {
    final existing = await _isar.cafeItems.count();
    if (existing == 0) {
      await _isar.writeTxn(() async {
        await _isar.cafeItems.putAll([
          CafeItem(
            itemId: 'coffee_espresso',
            nameTr: 'Espresso',
            nameEn: 'Espresso',
            cost: 50,
            iconCode: '☕',
          ),
          CafeItem(
            itemId: 'tea_green',
            nameTr: 'Yeşil Çay',
            nameEn: 'Green Tea',
            cost: 30,
            iconCode: '🍵',
          ),
          CafeItem(
            itemId: 'cake_cheese',
            nameTr: 'Cheesecake',
            nameEn: 'Cheesecake',
            cost: 100,
            iconCode: '🍰',
          ),
        ]);
      });
    }
  }

  static Future<void> saveSession(StudySession session) async {
    await _isar.writeTxn(() async {
      await _isar.studySessions.put(session);
    });
  }

  static Future<bool> purchaseItem(
    String itemId,
    int userCurrentPoints,
  ) async {
    return await _isar.writeTxn(() async {
      final item =
          await _isar.cafeItems.filter().itemIdEqualTo(itemId).findFirst();
      if (item == null) return false;

      if (userCurrentPoints >= item.cost) {
        item.isOwned = true;
        item.quantity += 1;
        await _isar.cafeItems.put(item);
        return true;
      }

      return false;
    });
  }

  static Future<({int points, int minutes})> readUserSnapshot() async {
    final stats = await _isar.userStats.where().findFirst();
    return (
      points: stats?.totalPoints ?? 0,
      minutes: stats?.totalStudyMinutes ?? 0,
    );
  }

  static Isar get instance => _isar;
}
