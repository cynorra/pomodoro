import 'package:freezed_annotation/freezed_annotation.dart';

part 'pomodoro_state.freezed.dart';

enum SessionType { focus, shortBreak, longBreak }

@freezed
class PomodoroState with _$PomodoroState {
  const factory PomodoroState({
    @Default(25 * 60) int remainingSeconds,
    @Default(false) bool isRunning,
    @Default(0) int totalPoints,
    @Default(SessionType.focus) SessionType sessionType,
  }) = _PomodoroState;
}
