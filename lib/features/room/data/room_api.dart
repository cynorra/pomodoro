import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../social/domain/display_name.dart';

class RoomMember {
  final String uid;
  final String name;
  final DateTime? lastActive;
  const RoomMember(this.uid, this.name, this.lastActive);
}

/// A tiny shared study room. The room id is an invite code (the host's own
/// code), so only people who know it can find the room. Members publish their
/// name and when they were last active; nothing else.
class RoomApi {
  static const _storage = FlutterSecureStorage();
  static const _key = 'study_room_code';
  static const maxMembers = 20;

  FirebaseFirestore get _db => FirebaseFirestore.instance;
  User? get _user => FirebaseAuth.instance.currentUser;

  Future<String?> joinedCode() async {
    try {
      return await _storage.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>> _members(String code) =>
      _db.collection('rooms').doc(code).collection('members');

  /// Joins [code]. Returns false when the code is unknown or the write fails.
  Future<bool> join(String code) async {
    final user = _user;
    if (user == null) return false;
    try {
      final exists = (await _db.collection('invite_codes').doc(code).get()).exists;
      if (!exists) return false;
      await leave();
      await _members(code).doc(user.uid).set({
        'name': displayNameOrFallback(user.displayName),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await _storage.write(key: _key, value: code);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> leave() async {
    final user = _user;
    final code = await joinedCode();
    try {
      if (user != null && code != null) {
        await _members(code).doc(user.uid).delete();
      }
      await _storage.delete(key: _key);
    } catch (_) {}
  }

  /// Marks this user as active now (after a finished focus session).
  Future<void> touch() async {
    final user = _user;
    final code = await joinedCode();
    if (user == null || code == null) return;
    try {
      await _members(code).doc(user.uid).set({
        'name': displayNameOrFallback(user.displayName),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Stream<List<RoomMember>> members(String code) {
    return _members(code)
        .orderBy('updatedAt', descending: true)
        .limit(maxMembers)
        .snapshots()
        .map((snap) => [
              for (final d in snap.docs)
                RoomMember(
                  d.id,
                  displayNameOrFallback(d.data()['name'] as String?),
                  (d.data()['updatedAt'] as Timestamp?)?.toDate(),
                ),
            ]);
  }
}

final roomApiProvider = Provider<RoomApi>((ref) => RoomApi());
