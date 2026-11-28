import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/database/database_service.dart';
import '../../../core/data/models/study_session.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../../core/data/state/streak_notifier.dart';
import '../../../core/data/services/streak_service.dart';
import '../../../core/data/services/achievement_service.dart';
import '../../../core/data/services/ad_service.dart';
import '../../../core/data/services/analytics_service.dart';
import '../../../core/data/services/remote_config_service.dart';
import '../../../core/data/state/achievement_event_notifier.dart';
import '../../../core/data/services/haptic_service.dart';
import '../../../core/data/services/notification_service.dart';
import '../../../core/data/services/notification_texts.dart';
import '../../../core/data/services/reminder_service.dart';
import '../../../core/utils/global_exception_handler.dart';
import '../../social/presentation/social_providers.dart';
import '../../cafe/domain/cafe_rules.dart';
import '../../cafe/presentation/boost_notifier.dart';
import '../../subjects/presentation/subject_notifier.dart';
import '../../room/data/room_api.dart';
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
      unawaited(ReminderService.refresh());

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

  /// Shows the countdown in the notification shade and plans the end alert,
  /// in the user's language (see [NotificationTexts]).
  Future<void> _scheduleEndNotification() async {
    final texts = await NotificationTexts.load();
    // The timer may have been paused while the language was being read.
    if (!state.isRunning) return;
    final isFocus = state.sessionType == SessionType.focus;
    final remaining = Duration(seconds: state.remainingSeconds);
    unawaited(NotificationService.scheduleSessionEnd(
      delay: remaining,
      title: 'Study Cafe',
      body: isFocus ? texts.focusDone : texts.breakDone,
    ));
    unawaited(NotificationService.showTimerRunning(
      title: isFocus ? texts.timerFocus : texts.timerBreak,
      body: texts.runningBody(_getDuration(state.sessionType)),
      endsAt: DateTime.now().add(remaining),
      channelName: texts.channelTimer,
    ));
  }

  void toggleTimer() {
    if (_isCompletingSession) return;

    if (state.isRunning) {
      _timer?.cancel();
      _timer = null;
      _deadline = null;
      unawaited(NotificationService.cancelSessionEnd());
      unawaited(NotificationService.cancelTimerRunning());
      _clearPresence();
      state = state.copyWith(isRunning: false);
    } else {
      if (state.remainingSeconds <= 0) return;
      state = state.copyWith(isRunning: true);
      _startTimer();
      _publishPresence();
      unawaited(
        NotificationService.requestPermissionIfNeeded().then((_) {
          if (!state.isRunning) return null;
          // The permission may have just been granted: plan the reminders too.
          unawaited(ReminderService.refresh());
          return _scheduleEndNotification();
        }),
      );
    }
  }

  /// Lets friends who are allowed to see it know a focus session is running.
  void _publishPresence() {
    if (state.sessionType != SessionType.focus) return;
    final endsAt =
        DateTime.now().add(Duration(seconds: state.remainingSeconds));
    unawaited(publishFocusStatus(ref, endsAt));
  }

  void _clearPresence() => unawaited(clearFocusStatus(ref));

  /// Switches between focus, short break, and long break when not running.
  void selectSessionType(SessionType type) {
    if (_isCompletingSession || state.sessionType == type) return;
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    unawaited(NotificationService.cancelSessionEnd());
    unawaited(NotificationService.cancelTimerRunning());
    _clearPresence();
    state = state.copyWith(
      isRunning: false,
      sessionType: type,
      remainingSeconds: _getDuration(type) * 60,
    );
  }

  /// Total duration in seconds for the given session type.
  /// Falls back to standard 25/5/15 durations when Remote Config isn't ready
  /// (e.g. in unit/widget tests without Firebase initialized).
  int totalSecondsFor(SessionType type) {
    try {
      return _getDuration(type) * 60;
    } catch (_) {
      return switch (type) {
        SessionType.focus => 25 * 60,
        SessionType.shortBreak => 5 * 60,
        SessionType.longBreak => 15 * 60,
      };
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
    unawaited(NotificationService.cancelTimerRunning());
    _clearPresence();
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
      unawaited(NotificationService.cancelTimerRunning());
      _clearPresence();
      _checkDailyReset();

      final isFocus = state.sessionType == SessionType.focus;
      final basePoints = isFocus
          ? RemoteConfigService.pointsPerFocus
          : RemoteConfigService.pointsPerBreak;
      // A cafe boost multiplies the points of focus sessions only.
      final boost = isFocus ? ref.read(activeBoostProvider) : null;
      final pointsEarned = boostedPoints(basePoints, boost);
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
        subject: isFocus ? ref.read(subjectProvider).selected : '',
      );
      await DatabaseService.saveSession(session);

      await ref.read(userProvider.notifier).addPoints(pointsEarned);
      if (isFocus) {
        await ref.read(userProvider.notifier).addStudyMinutes(minutesStudied);
      }

      if (boost != null) {
        await ref.read(activeBoostProvider.notifier).sessionUsed();
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
        lastReward: SessionReward(
          id: (state.lastReward?.id ?? 0) + 1,
          points: pointsEarned,
          boostPercent: boost?.percent ?? 0,
          wasFocus: isFocus,
        ),
      );
      unawaited(ReminderService.refresh());
      if (isFocus) unawaited(ref.read(roomApiProvider).touch());
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
