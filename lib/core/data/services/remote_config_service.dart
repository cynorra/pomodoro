import 'package:firebase_remote_config/firebase_remote_config.dart';
import '../../../features/pomodoro/domain/pomodoro_rules.dart';
import '../../utils/global_exception_handler.dart';

class RemoteConfigService {
  static final _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await _remoteConfig.setDefaults(<String, dynamic>{
        'pomodoro_focus_duration': 25,
        'pomodoro_short_break_duration': 5,
        'pomodoro_long_break_duration': 15,
        'points_per_focus_session': 10,
        'points_per_break_session': 2,
        'enable_ambient_sounds': true,
        'show_motivation_messages': true,
      });

      await _remoteConfig.fetchAndActivate();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Remote Config fetch failed');
    }
  }

  static int get focusDuration => clampConfig(
        _remoteConfig.getInt('pomodoro_focus_duration'),
        min: 1,
        max: 180,
        fallback: 25,
      );
  static int get shortBreakDuration => clampConfig(
        _remoteConfig.getInt('pomodoro_short_break_duration'),
        min: 1,
        max: 60,
        fallback: 5,
      );
  static int get longBreakDuration => clampConfig(
        _remoteConfig.getInt('pomodoro_long_break_duration'),
        min: 1,
        max: 120,
        fallback: 15,
      );
  static int get pointsPerFocus => clampConfig(
        _remoteConfig.getInt('points_per_focus_session'),
        min: 0,
        max: 1000,
        fallback: 10,
      );
  static int get pointsPerBreak => clampConfig(
        _remoteConfig.getInt('points_per_break_session'),
        min: 0,
        max: 1000,
        fallback: 2,
      );
  static bool get enableAmbientSounds => _remoteConfig.getBool('enable_ambient_sounds');
  static bool get showMotivationMessages => _remoteConfig.getBool('show_motivation_messages');
}
