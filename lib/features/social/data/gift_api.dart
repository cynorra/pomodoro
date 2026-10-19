import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/global_exception_handler.dart';
import '../domain/gift_rules.dart';
import '../domain/display_name.dart';

enum SendResult { success, notSignedIn, unavailable, error }

/// Treats between friends and the "focusing now" status. An interface so
/// screens can be tested without Firebase.
abstract class GiftApi {
  /// Advertises that this account is in a focus session until [endsAt].
  Future<void> startFocus(DateTime endsAt);

  /// Removes the focus status (paused, reset, finished).
  Future<void> stopFocus();

  /// Other accounts that are in a focus session right now.
  Future<List<FocusingUser>> focusingNow();

  /// Sends [itemId] to [toUid]. The caller charges the points on success.
  Future<SendResult> sendGift({required String toUid, required String itemId});

  /// Treats sent to this account, live.
  Stream<List<Gift>> incomingGifts();

  Future<void> markSeen(Iterable<String> giftIds);

  Future<void> deleteGifts(Iterable<String> giftIds);
}

class FirebaseGiftApi implements GiftApi {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  Future<void> startFocus(DateTime endsAt) async {
    final user = _user;
    if (user == null) return;
    try {
      await _db.collection('presence').doc(user.uid).set({
        'name': displayNameOrFallback(user.displayName),
        'endsAt': Timestamp.fromDate(endsAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  @override
  Future<void> stopFocus() async {
    final user = _user;
    if (user == null) return;
    try {
      await _db.collection('presence').doc(user.uid).delete();
    } catch (_) {}
  }

  @override
  Future<List<FocusingUser>> focusingNow() async {
    final me = _user?.uid;
    if (me == null) return const [];
    try {
      final now = DateTime.now();
      final snap = await _db
          .collection('presence')
          .where('endsAt', isGreaterThan: Timestamp.fromDate(now))
          .orderBy('endsAt')
          .limit(30)
          .get();
      return [
        for (final d in snap.docs)
          if (d.id != me && d.data()['endsAt'] is Timestamp)
            FocusingUser(
              uid: d.id,
              name: displayNameOrFallback(d.data()['name'] as String?),
              endsAt: (d.data()['endsAt'] as Timestamp).toDate(),
            ),
      ];
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Load focusing friends failed');
      return const [];
    }
  }

  @override
  Future<SendResult> sendGift({
    required String toUid,
    required String itemId,
  }) async {
    final user = _user;
    if (user == null) return SendResult.notSignedIn;
    final slot = giftSlot(DateTime.now());
    try {
      await _db.collection('gifts').doc(giftDocId(user.uid, toUid, slot)).set({
        'fromUid': user.uid,
        'fromName': displayNameOrFallback(user.displayName),
        'toUid': toUid,
        'itemId': itemId,
        'seen': false,
        'slot': slot,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return SendResult.success;
    } on FirebaseException catch (e) {
      // The rules refuse when the friend stopped focusing, or when this
      // sender already sent them a treat in the current slot.
      if (e.code == 'permission-denied') return SendResult.unavailable;
      return SendResult.error;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Send gift failed');
      return SendResult.error;
    }
  }

  @override
  Stream<List<Gift>> incomingGifts() {
    final me = _user?.uid;
    if (me == null) return Stream.value(const []);
    return _db
        .collection('gifts')
        .where('toUid', isEqualTo: me)
        .limit(100)
        .snapshots()
        .map((snap) => [
              for (final d in snap.docs)
                if (d.data()['createdAt'] is Timestamp)
                  Gift(
                    id: d.id,
                    fromUid: d.data()['fromUid'] as String? ?? '',
                    fromName:
                        displayNameOrFallback(d.data()['fromName'] as String?),
                    itemId: d.data()['itemId'] as String? ?? '',
                    createdAt: (d.data()['createdAt'] as Timestamp).toDate(),
                    seen: d.data()['seen'] == true,
                  ),
            ]);
  }

  @override
  Future<void> markSeen(Iterable<String> giftIds) async {
    try {
      final batch = _db.batch();
      for (final id in giftIds) {
        batch.update(_db.collection('gifts').doc(id), {'seen': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  @override
  Future<void> deleteGifts(Iterable<String> giftIds) async {
    try {
      final batch = _db.batch();
      for (final id in giftIds) {
        batch.delete(_db.collection('gifts').doc(id));
      }
      await batch.commit();
    } catch (_) {}
  }
}
