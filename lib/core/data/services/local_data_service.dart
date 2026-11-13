import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/global_exception_handler.dart';
import '../database/database_service.dart';
import 'audio_service.dart';
import 'notification_service.dart';
import 'privacy_consent_service.dart';

/// Removes everything the app stored on this device for the user. Used when an
/// account is deleted so no study history, points or social choices stay behind.
/// The language choice and the onboarding flag are not personal data and stay.
class LocalDataService {
  static const _storage = FlutterSecureStorage();
  static const _keepKeys = ['onboarding_completed', 'selected_locale'];

  static Future<void> wipe() async {
    try {
      await AudioService.stopAmbient();
    } catch (_) {}
    try {
      await NotificationService.cancelAll();
    } catch (_) {}

    try {
      final all = await _storage.readAll();
      final kept = Map.of(all)
        ..removeWhere((k, _) => !_keepKeys.contains(k));
      await _storage.deleteAll();
      for (final e in kept.entries) {
        await _storage.write(key: e.key, value: e.value);
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Secure storage wipe failed');
    }

    // The stored consent is gone, so stop collecting until it is given again.
    await PrivacyConsentService.apply(false);

    try {
      await DatabaseService.clearAllData();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Local database wipe failed');
    }
  }
}
