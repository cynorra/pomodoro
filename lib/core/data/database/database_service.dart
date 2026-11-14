import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/study_session.dart';
import '../models/cafe_item.dart';
import '../../../features/cafe/domain/cafe_rules.dart';
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

  /// Keeps the stored menu in line with [cafeCatalog]: adds new items and
  /// refreshes names, icons and prices, but never touches what the user owns.
  static Future<void> _seedDefaultCafeItems() async {
    await _isar.writeTxn(() async {
      for (final entry in cafeCatalog) {
        final stored = await _isar.cafeItems
            .filter()
            .itemIdEqualTo(entry.itemId)
            .findFirst();
        if (stored == null) {
          await _isar.cafeItems.put(CafeItem(
            itemId: entry.itemId,
            nameTr: entry.nameTr,
            nameEn: entry.nameEn,
            cost: entry.cost,
            iconCode: entry.icon,
          ));
        } else {
          stored
            ..nameTr = entry.nameTr
            ..nameEn = entry.nameEn
            ..cost = entry.cost
            ..iconCode = entry.icon;
          await _isar.cafeItems.put(stored);
        }
      }
    });
  }

  /// Deletes everything stored on the device (sessions, stats, badges, owned
  /// cafe items) and restores the default cafe menu.
  static Future<void> clearAllData() async {
    await _isar.writeTxn(() => _isar.clear());
    _seeded = false;
    await _seedDefaultData();
  }

  static Future<void> saveSession(StudySession session) async {
    await _isar.writeTxn(() async {
      await _isar.studySessions.put(session);
    });
  }

  /// Buys one more of [itemId]; items are consumables, so they can be bought
  /// again and again. Returns false when the points do not cover it.
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

  /// Takes one [itemId] out of the inventory; false when there is none.
  static Future<bool> consumeItem(String itemId) async {
    return await _isar.writeTxn(() async {
      final item =
          await _isar.cafeItems.filter().itemIdEqualTo(itemId).findFirst();
      if (item == null || item.quantity <= 0) return false;
      item.quantity -= 1;
      item.isOwned = item.quantity > 0;
      await _isar.cafeItems.put(item);
      return true;
    });
  }

  static Future<int> itemQuantity(String itemId) async {
    final item =
        await _isar.cafeItems.filter().itemIdEqualTo(itemId).findFirst();
    return item?.quantity ?? 0;
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
