import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:isar_community/isar.dart';
import '../database/database_service.dart';
import '../models/study_session.dart';
import 'notification_service.dart';
import 'reminder_rules.dart';

/// The user's choice for the daily study reminder: on by default, 18:00.
class ReminderSettings {
  final bool enabled;
  final int hour;
  final int minute;

  const ReminderSettings({
    this.enabled = true,
    this.hour = defaultReminderHour,
    this.minute = defaultReminderMinute,
  });
}

class ReminderService {
  static const _storage = FlutterSecureStorage();
  static const _enabledKey = 'reminder_enabled';
  static const _timeKey = 'reminder_time';

  static Future<ReminderSettings> load() async {
    try {
      final enabled = await _storage.read(key: _enabledKey);
      final time = await _storage.read(key: _timeKey);
      var hour = defaultReminderHour;
      var minute = defaultReminderMinute;
      final parts = time?.split(':');
      if (parts != null && parts.length == 2) {
        final h = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        if (h != null && m != null && h >= 0 && h < 24 && m >= 0 && m < 60) {
          hour = h;
          minute = m;
        }
      }
      return ReminderSettings(
        enabled: enabled != 'false',
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return const ReminderSettings();
    }
  }

  static Future<void> save(ReminderSettings settings) async {
    try {
      await _storage.write(key: _enabledKey, value: '${settings.enabled}');
      await _storage.write(
        key: _timeKey,
        value: '${settings.hour}:${settings.minute}',
      );
    } catch (_) {}
    await refresh();
  }

  /// Re-plans the reminders from the saved settings. Called on app start,
  /// when the app comes back, after a session and after settings change.
  static Future<void> refresh() async {
    final settings = await load();
    if (!settings.enabled) {
      await NotificationService.cancelDailyReminders();
      await NotificationService.cancelWeeklyReports();
      return;
    }
    await NotificationService.scheduleWeeklyReports();
    await NotificationService.scheduleDailyReminders(
      hour: settings.hour,
      minute: settings.minute,
      studiedToday: await _studiedToday(),
    );
  }

  static Future<bool> _studiedToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final count = await DatabaseService.instance.studySessions
          .filter()
          .sessionTypeEqualTo('focus')
          .dateGreaterThan(startOfDay)
          .count();
      return count > 0;
    } catch (_) {
      return false;
    }
  }
}
