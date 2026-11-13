import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
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

  /// Deletes temporary files (share cards, data exports, plugin caches).
  /// Never touches the database or saved settings. Returns how many top-level
  /// entries were removed.
  static Future<int> clearCache({Iterable<Directory>? dirs}) async {
    var removed = 0;
    try {
      dirs ??= <Directory>{
        await getTemporaryDirectory(),
        await getApplicationCacheDirectory(),
      };
      for (final dir in dirs) {
        if (!await dir.exists()) continue;
        await for (final entity in dir.list()) {
          try {
            await entity.delete(recursive: true);
            removed++;
          } catch (_) {}
        }
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Clear cache failed');
    }
    return removed;
  }

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

    await clearCache();

    // The stored consent is gone, so stop collecting until it is given again.
    await PrivacyConsentService.apply(false);

    try {
      await DatabaseService.clearAllData();
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Local database wipe failed');
    }
  }
}
