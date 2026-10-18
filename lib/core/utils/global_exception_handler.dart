import 'package:flutter/foundation.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class GlobalExceptionHandler {
  static void initialize() {
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  static void logError(dynamic error, [StackTrace? stack, String? reason]) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
    } else {
      debugPrint('ERROR: $error\n$stack\n$reason');
    }
  }

  static void log(String message) {
    if (kReleaseMode) {
      FirebaseCrashlytics.instance.log(message);
    } else {
      debugPrint('LOG: $message');
    }
  }
}
