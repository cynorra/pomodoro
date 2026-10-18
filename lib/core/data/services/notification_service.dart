import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      const channel = AndroidNotificationChannel(
        'pomodoro_channel',
        'Pomodoro Notifications',
        description: 'Notification when a session ends',
        importance: Importance.high,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      const breakChannel = AndroidNotificationChannel(
        'break_channel',
        'Break Reminders',
        description: 'Notification when it is time for a break',
        importance: Importance.max,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(breakChannel);
    }

    _initialized = true;
  }

  static Future<bool> requestPermissionWithDialog({
    required String title,
    required String body,
    required String allowLabel,
    required String denyLabel,
    required dynamic context,
  }) async {
    final status = await Permission.notification.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    final result = await Permission.notification.request();

    if (result.isGranted) {
      return true;
    } else if (result.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<void> showSessionComplete({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro Notifications',
      channelDescription: 'Notification when a session ends',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      0,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  static Future<void> scheduleBreakReminder({
    required int delayMinutes,
    required String title,
    required String body,
  }) async {
    final scheduledTime =
        tz.TZDateTime.now(tz.local).add(Duration(minutes: delayMinutes));

    final notificationDetails = const NotificationDetails(
      android: AndroidNotificationDetails(
        'break_channel',
        'Break Reminders',
        channelDescription: 'Notification when it is time for a break',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    if (Platform.isAndroid) {
      final scheduleMode = AndroidScheduleMode.inexactAllowWhileIdle;

      await _plugin.zonedSchedule(
        1,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      await _plugin.zonedSchedule(
        1,
        title,
        body,
        scheduledTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static const _sessionEndId = 2;

  /// Fires when a running session ends while the app is in the background.
  /// Inexact scheduling avoids the revocable exact-alarm permission.
  static Future<void> scheduleSessionEnd({
    required Duration delay,
    required String title,
    required String body,
  }) async {
    try {
      await initialize();
      final status = await Permission.notification.status;
      if (!status.isGranted) return;

      await _plugin.zonedSchedule(
        _sessionEndId,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(delay),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'pomodoro_channel',
            'Pomodoro Notifications',
            channelDescription: 'Notification when a session ends',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  static Future<void> cancelSessionEnd() async {
    try {
      await _plugin.cancel(_sessionEndId);
    } catch (_) {}
  }

  static Future<void> requestPermissionIfNeeded() async {
    try {
      final status = await Permission.notification.status;
      if (status.isDenied) await Permission.notification.request();
    } catch (_) {}
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
