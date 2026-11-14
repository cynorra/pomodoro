import 'dart:io';
import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/referral_rules.dart';

/// Picks up the invite code carried by the Play Store link a friend shared, so
/// the new user does not have to type it. Read once, kept until it is used.
class InstallReferral {
  static const _storage = FlutterSecureStorage();
  static const _codeKey = 'pending_invite_code';
  static const _checkedKey = 'install_referrer_checked';

  /// The code waiting to be redeemed, or null.
  static Future<String?> pendingCode() async {
    try {
      if (await _storage.read(key: _checkedKey) != 'true') {
        await _storage.write(key: _checkedKey, value: 'true');
        if (Platform.isAndroid) {
          final details = await AndroidPlayInstallReferrer.installReferrer;
          final code = inviteCodeFromReferrer(details.installReferrer);
          if (code != null) {
            await _storage.write(key: _codeKey, value: code);
          }
        }
      }
      return await _storage.read(key: _codeKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      await _storage.delete(key: _codeKey);
    } catch (_) {}
  }
}
