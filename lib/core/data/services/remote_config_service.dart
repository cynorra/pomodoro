import 'package:firebase_remote_config/firebase_remote_config.dart';
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

  static int get focusDuration => _remoteConfig.getInt('pomodoro_focus_duration');
  static int get shortBreakDuration => _remoteConfig.getInt('pomodoro_short_break_duration');
  static int get longBreakDuration => _remoteConfig.getInt('pomodoro_long_break_duration');
  static int get pointsPerFocus => _remoteConfig.getInt('points_per_focus_session');
  static int get pointsPerBreak => _remoteConfig.getInt('points_per_break_session');
  static bool get enableAmbientSounds => _remoteConfig.getBool('enable_ambient_sounds');
  static bool get showMotivationMessages => _remoteConfig.getBool('show_motivation_messages');
}
