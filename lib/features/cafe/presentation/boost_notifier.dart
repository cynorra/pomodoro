import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/cafe_rules.dart';

/// The point boost that is running right now (from a cafe item the user used),
/// or null. Kept on the device; it is wiped with the rest of the local data.
final activeBoostProvider =
    NotifierProvider<ActiveBoostNotifier, ActiveBoost?>(
        ActiveBoostNotifier.new);

class ActiveBoostNotifier extends Notifier<ActiveBoost?> {
  static const _key = 'active_boost';
  static const _storage = FlutterSecureStorage();

  @override
  ActiveBoost? build() {
    _load();
    return null;
  }

  Future<void> _load() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null) return;
      final boost = ActiveBoost.fromJson(jsonDecode(raw));
      if (boost != null && state == null) state = boost;
    } catch (_) {}
  }

  Future<void> start(ActiveBoost boost) async {
    state = boost;
    await _save();
  }

  /// Called after a focus session: counts it against the boost.
  Future<void> sessionUsed() async {
    final current = state;
    if (current == null) return;
    state = current.afterSession();
    await _save();
  }

  Future<void> _save() async {
    try {
      final boost = state;
      if (boost == null) {
        await _storage.delete(key: _key);
      } else {
        await _storage.write(key: _key, value: jsonEncode(boost.toJson()));
      }
    } catch (_) {}
  }
}
