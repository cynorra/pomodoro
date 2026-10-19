import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../features/pomodoro/domain/pomodoro_rules.dart';

/// Once-a-day bonuses. Opening a share sheet and cancelling it used to pay
/// out every time, so the share bonus is now limited to one per calendar day.
class DailyBonusService {
  static const _storage = FlutterSecureStorage();
  static const _shareKey = 'share_bonus_last';

  /// Returns true, and records today, when the share bonus may be given now.
  static Future<bool> claimShareBonus() async {
    try {
      final raw = await _storage.read(key: _shareKey);
      final last = raw == null ? null : DateTime.tryParse(raw);
      final now = DateTime.now();
      if (!dailyBonusAvailable(lastGranted: last, now: now)) return false;
      await _storage.write(key: _shareKey, value: now.toIso8601String());
      return true;
    } catch (_) {
      return false;
    }
  }
}
