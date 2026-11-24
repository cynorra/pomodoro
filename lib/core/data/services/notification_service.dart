import 'dart:ui' show Color, PlatformDispatcher;
import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_texts.dart';
import 'reminder_rules.dart';
import '../../../features/stats/domain/weekly_report.dart';

class NotificationService {
  static const _accent = Color(0xFFD4AF37);

  // Channel names show up in Android's notification settings, outside the
  // app's own localization, so they follow the device language.
  static bool get _isTr =>
      PlatformDispatcher.instance.locale.languageCode == 'tr';
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
  static const _sessionChannelId = 'pomodoro_channel_v2';
  static const _breakChannelId = 'break_channel_v2';
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_stat_notification');
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
      // v2 channels: a channel's sound cannot be changed once created, so the
      // new custom chime needs new ids.
      final channel = AndroidNotificationChannel(
        _sessionChannelId,
        _sessionChannelName,
        description: _sessionChannelDesc,
        importance: Importance.high,
        sound: const RawResourceAndroidNotificationSound('session_complete'),
        playSound: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      final breakChannel = AndroidNotificationChannel(
        _breakChannelId,
        _breakChannelName,
        description: _breakChannelDesc,
        importance: Importance.max,
        sound: const RawResourceAndroidNotificationSound('session_complete'),
        playSound: true,
      );

      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(breakChannel);
    }

    _initialized = true;
  }

  /// Whether the OS currently lets the app show notifications.
  static Future<bool> notificationsEnabled() => _isPermitted();

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
      _sessionChannelId,
      _sessionChannelName,
      channelDescription: _sessionChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      sound: const RawResourceAndroidNotificationSound('session_complete'),
      playSound: true,
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
        _breakChannelId,
        _breakChannelName,
        channelDescription: _breakChannelDesc,
        importance: Importance.max,
        priority: Priority.high,
        sound: const RawResourceAndroidNotificationSound('session_complete'),
        playSound: true,
        color: _accent,
      ),
      iOS: DarwinNotificationDetails(),
    );

    // Inexact scheduling avoids the restricted exact-alarm permission for Play Store compliance.
    await _plugin.zonedSchedule(
      id: 1,
      title: title,
      body: body,
      scheduledDate: scheduledTime,
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static const _timerId = 3;
  static const _reminderBaseId = 100;

  /// Shows the running timer in the notification shade. The system counts the
  /// time down itself (chronometer), so it stays correct with the app closed,
  /// and the notification removes itself when the session ends.
  static Future<void> showTimerRunning({
    required String title,
    required String body,
    required DateTime endsAt,
    required String channelName,
  }) async {
    try {
      await initialize();
      if (!await _isPermitted()) return;
      final remaining = endsAt.difference(DateTime.now());
      if (remaining <= Duration.zero) return;
      await _plugin.show(
        id: _timerId,
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_channel',
            channelName,
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            playSound: false,
            enableVibration: false,
            showWhen: true,
            when: endsAt.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            timeoutAfter: remaining.inMilliseconds,
            category: AndroidNotificationCategory.progress,
            color: _accent,
            icon: '@drawable/ic_stat_notification',
          ),
        ),
      );
    } catch (_) {}
  }

  static Future<void> cancelTimerRunning() async {
    try {
      await _plugin.cancel(id: _timerId);
    } catch (_) {}
  }

  /// Schedules one study reminder per day for the next two weeks (a different
  /// message each day), replacing earlier ones. Does nothing without the
  /// notification permission.
  static Future<void> scheduleDailyReminders({
    required int hour,
    required int minute,
    required bool studiedToday,
  }) async {
    try {
      await initialize();
      await cancelDailyReminders();
      if (!await _isPermitted()) return;
      final texts = await NotificationTexts.load();
      final times = reminderTimes(
        now: DateTime.now(),
        hour: hour,
        minute: minute,
        studiedToday: studiedToday,
      );
      for (var i = 0; i < times.length; i++) {
        final at = times[i];
        // Rotate the message by calendar day so it differs from day to day.
        final dayNumber = DateTime.utc(at.year, at.month, at.day)
            .difference(DateTime.utc(2024))
            .inDays;
        await _plugin.zonedSchedule(
          id: _reminderBaseId + i,
          title: 'Study Cafe',
          body: texts.reminder(dayNumber),
          // The exact instant is what matters, so it is built from UTC and
          // does not depend on the time zone database being set up.
          scheduledDate: tz.TZDateTime.from(at.toUtc(), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              texts.channelReminder,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: _accent,
              icon: '@drawable/ic_stat_notification',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {}
  }

  static const _weeklyBaseId = 200;
  static const _weeklyCount = 4;

  /// Schedules the "your weekly report is ready" nudge for the next Sundays at
  /// 19:00. Refreshed every time the app starts, like the daily reminders.
  static Future<void> scheduleWeeklyReports() async {
    try {
      await initialize();
      await cancelWeeklyReports();
      if (!await _isPermitted()) return;
      final lang = await NotificationTexts.resolveLanguage();
      final tr = lang == 'tr';
      final times = nextSundays(DateTime.now(), count: _weeklyCount);
      for (var i = 0; i < times.length; i++) {
        await _plugin.zonedSchedule(
          id: _weeklyBaseId + i,
          title: 'Study Cafe',
          body: tr
              ? 'Haftalık çalışma raporun hazır. Bu hafta ne kadar çalıştın?'
              : 'Your weekly study report is ready. See how your week went.',
          scheduledDate: tz.TZDateTime.from(times[i].toUtc(), tz.UTC),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              'reminder_channel',
              tr ? 'Hatırlatıcılar' : 'Reminders',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              color: _accent,
              icon: '@drawable/ic_stat_notification',
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      }
    } catch (_) {}
  }

  static Future<void> cancelWeeklyReports() async {
    try {
      for (var i = 0; i < _weeklyCount; i++) {
        await _plugin.cancel(id: _weeklyBaseId + i);
      }
    } catch (_) {}
  }

  static Future<void> cancelDailyReminders() async {
    try {
      for (var i = 0; i < reminderDaysAhead; i++) {
        await _plugin.cancel(id: _reminderBaseId + i);
      }
    } catch (_) {}
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

      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'pomodoro_channel',
          _sessionChannelName,
          channelDescription: _sessionChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
          color: _accent,
        ),
        iOS: DarwinNotificationDetails(),
      );
      final when = tz.TZDateTime.now(tz.local).add(delay);

      // Inexact scheduling avoids the restricted exact-alarm permission for Play Store compliance.
      await _plugin.zonedSchedule(
        id: _sessionEndId,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: details,
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
