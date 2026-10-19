import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final initialLocaleProvider = Provider<Locale>((ref) {
  return const Locale('en');
});

final localeProvider =
    NotifierProvider<LocaleNotifier, Locale>(LocaleNotifier.new);

class LocaleNotifier extends Notifier<Locale> {
  static const _storage = FlutterSecureStorage();
  static const _key = 'selected_locale';

  @override
  Locale build() => ref.watch(initialLocaleProvider);

  static Future<Locale> loadInitialLocale() async {
    try {
      final code = await _storage.read(key: _key);
      if (code == 'tr') return const Locale('tr');
      if (code == 'en') return const Locale('en');
    } catch (_) {}
    // Nothing chosen yet: Turkish devices get Turkish, everything else English.
    return PlatformDispatcher.instance.locale.languageCode == 'tr'
        ? const Locale('tr')
        : const Locale('en');
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    try {
      await _storage.write(key: _key, value: locale.languageCode);
    } catch (_) {}
  }
}
