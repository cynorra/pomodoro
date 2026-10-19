import 'dart:ui' show Color, PlatformDispatcher;
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static const _accent = Color(0xFFD4AF37);

  // Channel names show up in Android's notification settings, outside the
  // app's own localization, so they follow the device language.
  static bool get _isTr => PlatformDispatcher.instance.locale.languageCode == 'tr';
  static String get _sessionChannelName =>
      _isTr ? 'Pomodoro Bildirimleri' : 'Pomodoro Notifications';
  static String get _sessionChannelDesc =>
      _isTr ? 'Seans bittiğinde bildirim' : 'Notification when a session ends';
  static String get _breakChannelName =>
      _isTr ? 'Mola Hatırlatıcıları' : 'Break Reminders';
  static String get _breakChannelDesc => _isTr
      ? 'Mola zamanı geldiğinde bildirim'
      : 'Notification when it is time for a break';

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@drawable/ic_stat_notification');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (details) {},
    );

    if (Platform.isAndroid) {
      final channel = AndroidNotificationChannel(
        'pomodoro_channel',
        _sessionChannelName,
        description: _sessionChannelDesc,
        importance: Importance.high,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final breakChannel = AndroidNotificationChannel(
        'break_channel',
        _breakChannelName,
        description: _breakChannelDesc,
        importance: Importance.max,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(breakChannel);
    }

    _initialized = true;
  }

  static Future<bool> _isPermitted() async {
    try {
      if (Platform.isAndroid) {
        return await _android?.areNotificationsEnabled() ?? false;
      }
      if (Platform.isIOS) {
        final options = await _ios?.checkPermissions();
        return options?.isEnabled ?? false;
      }
    } catch (_) {}
    return false;
  }

  static AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  static IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

  /// Asks the OS for notification permission (Android 13+ / iOS).
  static Future<bool> requestPermissionWithDialog({
    required String title,
    required String body,
    required String allowLabel,
    required String denyLabel,
    required dynamic context,
  }) async {
    await initialize();
    if (await _isPermitted()) return true;
    return requestPermissionIfNeeded();
  }

  static Future<void> showSessionComplete({
    required String title,
    required String body,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      _sessionChannelName,
      channelDescription: _sessionChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
        color: _accent,
      icon: '@drawable/ic_stat_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'break_channel',
        _breakChannelName,
        channelDescription: _breakChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        color: _accent,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: 1,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
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
      if (!await _isPermitted()) return;

      await _plugin.zonedSchedule(
        id: _sessionEndId,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.now(tz.local).add(delay),
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'pomodoro_channel',
            _sessionChannelName,
            channelDescription: _sessionChannelDesc,
            importance: Importance.high,
            priority: Priority.high,
        color: _accent,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (_) {}
  }

  static Future<void> cancelSessionEnd() async {
    try {
      await _plugin.cancel(id: _sessionEndId);
    } catch (_) {}
  }

  static Future<bool> requestPermissionIfNeeded() async {
    try {
      await initialize();
      if (await _isPermitted()) return true;
      if (Platform.isAndroid) {
        return await _android?.requestNotificationsPermission() ?? false;
      }
      if (Platform.isIOS) {
        return await _ios?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (_) {}
    return false;
  }

  static Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
