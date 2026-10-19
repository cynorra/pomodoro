import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import '../../../core/data/state/locale_notifier.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../core/data/services/streak_service.dart';
import '../../../core/data/services/achievement_service.dart';
import '../../../core/data/services/ad_service.dart';
import '../../../core/data/services/analytics_service.dart';
import '../../../core/data/services/remote_config_service.dart';
import '../../../core/data/state/achievement_event_notifier.dart';
import '../../../core/data/services/haptic_service.dart';
import '../../../core/data/services/notification_service.dart';
import '../../../core/utils/global_exception_handler.dart';
import '../domain/pomodoro_rules.dart';
import '../domain/pomodoro_state.dart';

final pomodoroProvider = NotifierProvider<PomodoroNotifier, PomodoroState>(
  PomodoroNotifier.new,
);

class PomodoroNotifier extends Notifier<PomodoroState>
    with WidgetsBindingObserver {
  Timer? _timer;
  DateTime? _deadline;
  int _completedFocusSessions = 0;
  DateTime _lastResetDate = DateTime.now();
  bool _isCompletingSession = false;

  @override
  PomodoroState build() {
    WidgetsBinding.instance.addObserver(this);

    ref.onDispose(() {
      _timer?.cancel();
      WidgetsBinding.instance.removeObserver(this);
    });

    _checkDailyReset();

    return PomodoroState(
      remainingSeconds: RemoteConfigService.focusDuration * 60,
    );
  }

  void _checkDailyReset() {
    final now = DateTime.now();
    if (calendarDaysBetween(_lastResetDate, now) > 0) {
      _completedFocusSessions = 0;
      _lastResetDate = now;
    }
  }

  @override
  // `state` is already the notifier's own state here, so the parameter keeps its name.
  // ignore: avoid_renaming_method_parameters
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    if (lifecycle == AppLifecycleState.paused) {
      _timer?.cancel();
      _timer = null;
    } else if (lifecycle == AppLifecycleState.resumed) {
      _checkDailyReset();

      final deadline = _deadline;
      if (!state.isRunning || deadline == null || _isCompletingSession) {
        return;
      }

      final remaining = _secondsLeft(deadline);

      if (remaining <= 0) {
        unawaited(_completeSession());
      } else {
        state = state.copyWith(remainingSeconds: remaining);
        _startTimer();
      }
    }
  }

  // Round up so the display shows the full duration for the first second.
  int _secondsLeft(DateTime deadline) =>
      (deadline.difference(DateTime.now()).inMilliseconds + 999) ~/ 1000;

  void _scheduleEndNotification() {
    final l10n = lookupAppLocalizations(ref.read(localeProvider));
    final isFocus = state.sessionType == SessionType.focus;
    unawaited(NotificationService.scheduleSessionEnd(
      delay: Duration(seconds: state.remainingSeconds),
      title: 'Study Cafe',
      body: isFocus ? l10n.notifFocusDone : l10n.notifBreakDone,
    ));
  }

  void toggleTimer() {
    if (_isCompletingSession) return;

    if (state.isRunning) {
      _timer?.cancel();
      _timer = null;
      _deadline = null;
      unawaited(NotificationService.cancelSessionEnd());
      state = state.copyWith(isRunning: false);
    } else {
      if (state.remainingSeconds <= 0) return;
      state = state.copyWith(isRunning: true);
      _startTimer();
      unawaited(
        NotificationService.requestPermissionIfNeeded()
            .then((_) => state.isRunning ? _scheduleEndNotification() : null),
      );
    }
  }

  /// Stops the timer and puts the current session back to its full length.
  /// No points are given for an unfinished session.
  void resetTimer() {
    if (_isCompletingSession) return;
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    unawaited(NotificationService.cancelSessionEnd());
    state = state.copyWith(
      isRunning: false,
      remainingSeconds: _getDuration(state.sessionType) * 60,
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _deadline = DateTime.now().add(
      Duration(seconds: state.remainingSeconds),
    );

    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final deadline = _deadline;
    if (deadline == null || _isCompletingSession) return;

    final remaining = _secondsLeft(deadline);

    if (remaining <= 0) {
      state = state.copyWith(remainingSeconds: 0);
      unawaited(_completeSession());
    } else if (remaining != state.remainingSeconds) {
      state = state.copyWith(remainingSeconds: remaining);
    }
  }

  Future<void> _completeSession() async {
    if (_isCompletingSession) return;
    _isCompletingSession = true;

    try {
      _timer?.cancel();
      _timer = null;
      _deadline = null;

      unawaited(NotificationService.cancelSessionEnd());
      _checkDailyReset();

      final isFocus = state.sessionType == SessionType.focus;
      final pointsEarned = isFocus
          ? RemoteConfigService.pointsPerFocus
          : RemoteConfigService.pointsPerBreak;
      final minutesStudied = isFocus
          ? RemoteConfigService.focusDuration
          : (state.sessionType == SessionType.shortBreak
              ? RemoteConfigService.shortBreakDuration
              : RemoteConfigService.longBreakDuration);

      await HapticService.sessionComplete();

      final session = StudySession(
        date: DateTime.now(),
        durationSeconds: minutesStudied * 60,
        pointsEarned: pointsEarned,
        sessionType: state.sessionType.name,
      );
      await DatabaseService.saveSession(session);

      await ref.read(userProvider.notifier).addPoints(pointsEarned);
      if (isFocus) {
        await ref.read(userProvider.notifier).addStudyMinutes(minutesStudied);
      }

      if (isFocus) {
        await StreakService.updateStreakOnSessionComplete();
        ref.invalidate(streakProvider);
      }

      final newlyUnlocked =
          await AchievementService.checkAndUnlockAchievements();

      for (final achievement in newlyUnlocked) {
        await AnalyticsService.logAchievementUnlocked(
          achievement.achievementId,
        );
        AchievementEventStream.emit(achievement);
      }

      await AnalyticsService.logPomodoroComplete(
        sessionType: state.sessionType.name,
        durationSeconds: minutesStudied * 60,
        pointsEarned: pointsEarned,
      );

      if (isFocus) {
        _completedFocusSessions++;
        unawaited(AdService.onFocusSessionCompleted());
      }
      final nextSessionType = _determineNextSessionType(isFocus);
      final nextDuration = _getDuration(nextSessionType);

      state = state.copyWith(
        isRunning: false,
        remainingSeconds: nextDuration * 60,
        sessionType: nextSessionType,
      );
    } catch (e, stack) {
      GlobalExceptionHandler.logError(
        e,
        stack,
        'Pomodoro session complete failed',
      );
    } finally {
      _isCompletingSession = false;
    }
  }

  SessionType _determineNextSessionType(bool wasFocus) => nextSessionType(
        wasFocus: wasFocus,
        completedFocusSessions: _completedFocusSessions,
      );

  int _getDuration(SessionType type) {
    switch (type) {
      case SessionType.focus:
        return RemoteConfigService.focusDuration;
      case SessionType.shortBreak:
        return RemoteConfigService.shortBreakDuration;
      case SessionType.longBreak:
        return RemoteConfigService.longBreakDuration;
    }
  }
}
