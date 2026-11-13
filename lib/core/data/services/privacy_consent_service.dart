import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Consent for anonymous usage analytics and crash reports (Firebase Analytics
/// and Crashlytics). Both are switched off in the manifest and only start once
/// the user says yes; a "no" keeps them off. The choice, its time and the text
/// version are stored so consent can be shown later.
class PrivacyConsentService {
  static const _storage = FlutterSecureStorage();
  static const _choiceKey = 'analytics_consent';
  static const _atKey = 'analytics_consent_at';
  static const _versionKey = 'analytics_consent_version';

  /// Bump when the consent text or what is collected changes, to ask again.
  static const textVersion = '1';

  /// true = granted, false = declined, null = not asked yet (or text changed).
  static Future<bool?> read() async {
    try {
      final version = await _storage.read(key: _versionKey);
      final choice = await _storage.read(key: _choiceKey);
      if (choice == null || version != textVersion) return null;
      return choice == 'granted';
    } catch (_) {
      return null;
    }
  }

  /// Stores the choice and switches the SDKs on or off.
  static Future<void> save(bool granted) async {
    try {
      await _storage.write(
          key: _choiceKey, value: granted ? 'granted' : 'denied');
      await _storage.write(
          key: _atKey, value: DateTime.now().toUtc().toIso8601String());
      await _storage.write(key: _versionKey, value: textVersion);
    } catch (_) {}
    await apply(granted);
  }

  /// Applies a choice to the SDKs without storing it (used at start-up).
  static Future<void> apply(bool granted) async {
    try {
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(granted);
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(granted);
      if (!granted) await FirebaseAnalytics.instance.resetAnalyticsData();
    } catch (_) {}
  }

  /// Start-up: apply the saved choice; nothing is collected until one exists.
  static Future<void> applyStored() async {
    await apply(await read() == true);
  }
}
