import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/global_exception_handler.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static String get _localeKey {
    const salt = 'cynora_2024';
    final combined = 'app_locale$salt';
    return base64.encode(utf8.encode(combined));
  }

  static Future<String?> readLocale() async {
    try {
      return await _storage.read(key: _localeKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> writeLocale(String value) async {
    try {
      await _storage.write(key: _localeKey, value: value);
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Locale write failed');
    }
  }
}
