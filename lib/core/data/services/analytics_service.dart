import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../../utils/global_exception_handler.dart';

class SafeAnalyticsObserver extends FirebaseAnalyticsObserver {
  SafeAnalyticsObserver() : super(analytics: FirebaseAnalytics.instance);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == null) return;

    try {
      super.didPush(route, previousRoute);
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Analytics didPush failed');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == null) return;

    try {
      super.didPop(route, previousRoute);
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Analytics didPop failed');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute == null && oldRoute == null) return;

    try {
      super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    } catch (e, stack) {
      GlobalExceptionHandler.logError(
        e,
        stack,
        'Analytics didReplace failed',
      );
    }
  }
}

class AnalyticsService {
  static final _analytics = FirebaseAnalytics.instance;
  static final Map<String, DateTime> _lastEventTimes = {};
  static const _minInterval = Duration(seconds: 1);

  static Future<void> _logEventWithRateLimit(
    String eventName, [
    Map<String, dynamic>? parameters,
  ]) async {
    final now = DateTime.now();
    final lastTime = _lastEventTimes[eventName];

    if (lastTime != null && now.difference(lastTime) < _minInterval) {
      return;
    }

    _lastEventTimes[eventName] = now;

    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters?.cast<String, Object>(),
      );
    } catch (e, stack) {
      GlobalExceptionHandler.logError(
        e,
        stack,
        'Analytics event failed: $eventName',
      );
    }
  }

  static Future<void> logPomodoroStart(String sessionType) async {
    await _logEventWithRateLimit(
      'pomodoro_start',
      {'session_type': sessionType},
    );
  }

  static Future<void> logPomodoroComplete({
    required String sessionType,
    required int durationSeconds,
    required int pointsEarned,
  }) async {
    await _logEventWithRateLimit(
      'pomodoro_complete',
      {
        'session_type': sessionType,
        'duration_seconds': durationSeconds,
        'points_earned': pointsEarned,
      },
    );
  }

  static Future<void> logCafePurchase({
    required String itemId,
    required int cost,
  }) async {
    await _logEventWithRateLimit(
      'cafe_purchase',
      {'item_id': itemId, 'cost': cost},
    );
  }

  static Future<void> logAchievementUnlocked(String achievementId) async {
    await _logEventWithRateLimit(
      'achievement_unlocked',
      {'achievement_id': achievementId},
    );
  }

  static Future<void> logScreenView(String screenName) async {
    await _logEventWithRateLimit(
      'screen_view',
      {'screen_name': screenName},
    );
  }

  static Future<void> logAppOpen() async {
    await _logEventWithRateLimit('app_open');
  }
}
