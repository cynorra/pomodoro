import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../database/database_service.dart';
import '../models/cafe_item.dart';
import '../state/user_notifier.dart';

enum PurchaseResult {
  success,
  insufficientPoints,
  itemNotFound,
  error,
}

class CafePurchaseService {
  static Future<PurchaseResult> purchase({
    required String itemId,
    required int userPoints,
    required WidgetRef ref,
  }) async {
    try {
      final isar = DatabaseService.instance;
      final item = await isar.cafeItems.filter().itemIdEqualTo(itemId).findFirst();

      if (item == null) {
        return PurchaseResult.itemNotFound;
      }

      // Re-read the balance so a stale UI value cannot overspend.
      final currentPoints = ref.read(userProvider).totalPoints;
      if (currentPoints < item.cost || userPoints < item.cost) {
        return PurchaseResult.insufficientPoints;
      }

      final success = await DatabaseService.purchaseItem(itemId, currentPoints);
      if (success) {
        await ref.read(userProvider.notifier).deductPoints(item.cost);
        return PurchaseResult.success;
      } else {
        return PurchaseResult.error;
      }
    } catch (_) {
      return PurchaseResult.error;
    }
  }
}
