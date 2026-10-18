import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final initialLocaleProvider = Provider<Locale>((ref) {
  return const Locale('en');
});

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  final initial = ref.watch(initialLocaleProvider);
  return LocaleNotifier(initial);
});

class LocaleNotifier extends StateNotifier<Locale> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'selected_locale';

  LocaleNotifier(super.initialLocale);

  static Future<Locale> loadInitialLocale() async {
    try {
      final code = await _storage.read(key: _key);
      if (code == 'tr') return const Locale('tr');
      return const Locale('en');
    } catch (_) {
      return const Locale('en');
    }
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      await _storage.write(key: _key, value: locale.languageCode);
    } catch (_) {}
  }
}
