// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pomodoro_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PomodoroState {
  int get remainingSeconds => throw _privateConstructorUsedError;
  bool get isRunning => throw _privateConstructorUsedError;
  int get totalPoints => throw _privateConstructorUsedError;
  SessionType get sessionType => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PomodoroStateCopyWith<PomodoroState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PomodoroStateCopyWith<$Res> {
  factory $PomodoroStateCopyWith(
          PomodoroState value, $Res Function(PomodoroState) then) =
      _$PomodoroStateCopyWithImpl<$Res, PomodoroState>;
  @useResult
  $Res call(
      {int remainingSeconds,
      bool isRunning,
      int totalPoints,
      SessionType sessionType});
}

/// @nodoc
class _$PomodoroStateCopyWithImpl<$Res, $Val extends PomodoroState>
    implements $PomodoroStateCopyWith<$Res> {
  _$PomodoroStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingSeconds = null,
    Object? isRunning = null,
    Object? totalPoints = null,
    Object? sessionType = null,
  }) {
    return _then(_value.copyWith(
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as SessionType,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PomodoroStateImplCopyWith<$Res>
    implements $PomodoroStateCopyWith<$Res> {
  factory _$$PomodoroStateImplCopyWith(
          _$PomodoroStateImpl value, $Res Function(_$PomodoroStateImpl) then) =
      __$$PomodoroStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int remainingSeconds,
      bool isRunning,
      int totalPoints,
      SessionType sessionType});
}

/// @nodoc
class __$$PomodoroStateImplCopyWithImpl<$Res>
    extends _$PomodoroStateCopyWithImpl<$Res, _$PomodoroStateImpl>
    implements _$$PomodoroStateImplCopyWith<$Res> {
  __$$PomodoroStateImplCopyWithImpl(
      _$PomodoroStateImpl _value, $Res Function(_$PomodoroStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? remainingSeconds = null,
    Object? isRunning = null,
    Object? totalPoints = null,
    Object? sessionType = null,
  }) {
    return _then(_$PomodoroStateImpl(
      remainingSeconds: null == remainingSeconds
          ? _value.remainingSeconds
          : remainingSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRunning: null == isRunning
          ? _value.isRunning
          : isRunning // ignore: cast_nullable_to_non_nullable
              as bool,
      totalPoints: null == totalPoints
          ? _value.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      sessionType: null == sessionType
          ? _value.sessionType
          : sessionType // ignore: cast_nullable_to_non_nullable
              as SessionType,
    ));
  }
}

/// @nodoc

class _$PomodoroStateImpl implements _PomodoroState {
  const _$PomodoroStateImpl(
      {this.remainingSeconds = 25 * 60,
      this.isRunning = false,
      this.totalPoints = 0,
      this.sessionType = SessionType.focus});

  @override
  @JsonKey()
  final int remainingSeconds;
  @override
  @JsonKey()
  final bool isRunning;
  @override
  @JsonKey()
  final int totalPoints;
  @override
  @JsonKey()
  final SessionType sessionType;

  @override
  String toString() {
    return 'PomodoroState(remainingSeconds: $remainingSeconds, isRunning: $isRunning, totalPoints: $totalPoints, sessionType: $sessionType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PomodoroStateImpl &&
            (identical(other.remainingSeconds, remainingSeconds) ||
                other.remainingSeconds == remainingSeconds) &&
            (identical(other.isRunning, isRunning) ||
                other.isRunning == isRunning) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.sessionType, sessionType) ||
                other.sessionType == sessionType));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, remainingSeconds, isRunning, totalPoints, sessionType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PomodoroStateImplCopyWith<_$PomodoroStateImpl> get copyWith =>
      __$$PomodoroStateImplCopyWithImpl<_$PomodoroStateImpl>(this, _$identity);
}

abstract class _PomodoroState implements PomodoroState {
  const factory _PomodoroState(
      {final int remainingSeconds,
      final bool isRunning,
      final int totalPoints,
      final SessionType sessionType}) = _$PomodoroStateImpl;

  @override
  int get remainingSeconds;
  @override
  bool get isRunning;
  @override
  int get totalPoints;
  @override
  SessionType get sessionType;
  @override
  @JsonKey(ignore: true)
  _$$PomodoroStateImplCopyWith<_$PomodoroStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
