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
        'points_per_focus_session': 20,
        'points_per_break_session': 2,
        'enable_ambient_sounds': true,
        'show_motivation_messages': true,
        'enable_rewarded_ads': true,
        'show_active_users': false,
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
        fallback: 20,
      );
  static int get pointsPerBreak => clampConfig(
        _remoteConfig.getInt('points_per_break_session'),
        min: 0,
        max: 1000,
        fallback: 2,
      );
  static bool get enableAmbientSounds =>
      _remoteConfig.getBool('enable_ambient_sounds');
  /// "Watch an ad, earn points". Off by default; flip it in Remote Config.
  static bool get enableRewardedAds => _flag('enable_rewarded_ads');

  /// Shows how many people are focusing right now on the cafe screen. Off by
  /// default, because a count of 0 would only look bad while the app is new.
  static bool get showActiveUsers => _flag('show_active_users');

  /// Reads a feature flag; anything that goes wrong (Remote Config not ready,
  /// not set up in tests) counts as "off".
  static bool _flag(String key) {
    try {
      return _remoteConfig.getBool(key);
    } catch (_) {
      return false;
    }
  }

  static bool get showMotivationMessages =>
      _remoteConfig.getBool('show_motivation_messages');
}
