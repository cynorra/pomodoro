import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../utils/global_exception_handler.dart';

enum ReportReason { inappropriateName, cheating, other }

/// Lets users report and hide other players on the public leaderboard, as
/// required for apps that show user-generated content.
class ModerationService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'hidden_players';

  static Future<Set<String>> hiddenPlayers() async {
    try {
      final raw = await _storage.read(key: _key);
      if (raw == null || raw.isEmpty) return {};
      return raw.split(',').where((id) => id.isNotEmpty).toSet();
    } catch (_) {
      return {};
    }
  }

  static Future<void> hidePlayer(String uid) async {
    final hidden = await hiddenPlayers()
      ..add(uid);
    try {
      await _storage.write(key: _key, value: hidden.join(','));
    } catch (_) {}
  }

  static Future<void> showAllPlayers() async {
    try {
      await _storage.delete(key: _key);
    } catch (_) {}
  }

  /// One report per reporter and player (the document id is deterministic and
  /// the rules allow create only), so a second report returns false.
  static Future<bool> reportPlayer({
    required String uid,
    required ReportReason reason,
  }) async {
    final me = FirebaseAuth.instance.currentUser;
    if (me == null || me.uid == uid) return false;
    try {
      await FirebaseFirestore.instance
          .collection('reports')
          .doc('${me.uid}_$uid')
          .set({
        'reportedUid': uid,
        'reporterUid': me.uid,
        'reason': reason.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Report player failed');
      return false;
    }
  }
}
