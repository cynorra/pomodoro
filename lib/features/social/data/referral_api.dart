import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/global_exception_handler.dart';
import '../domain/referral_rules.dart';

enum RedeemResult {
  success,
  invalid,
  ownCode,
  notFound,
  alreadyRedeemed,
  notSignedIn,
  error,
}

/// Invite codes and referral rewards. An interface so screens can be tested
/// without Firebase.
abstract class ReferralApi {
  /// The signed-in user's own invite code (created on first use), or null when
  /// signed out or offline.
  Future<String?> myInviteCode();

  /// Whether this account already entered a friend's code.
  Future<bool> hasRedeemed();

  /// Enters a friend's code. The caller adds [referralInviteeBonus] on success.
  Future<RedeemResult> redeem(String input);

  /// Marks the rewards of friends who joined with this account's code as
  /// collected and returns how many were collected now. The caller adds
  /// [referralReferrerBonus] for each.
  Future<int> claimPendingRewards();
}

class FirebaseReferralApi implements ReferralApi {
  FirebaseFirestore get _db => FirebaseFirestore.instance;
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  Future<String?> myInviteCode() async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      final codes = _db.collection('invite_codes');
      // Two accounts can land on the same code; the next salt gives another one.
      for (var salt = 0; salt < 10; salt++) {
        final code = generateInviteCode(uid, salt: salt);
        final snap = await codes.doc(code).get();
        if (snap.exists) {
          if (snap.data()?['ownerUid'] == uid) return code;
          continue;
        }
        try {
          await codes.doc(code).set({'ownerUid': uid});
          return code;
        } on FirebaseException catch (e) {
          // Someone else created it a moment earlier.
          if (e.code != 'permission-denied') rethrow;
        }
      }
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Invite code failed');
    }
    return null;
  }

  @override
  Future<bool> hasRedeemed() async {
    final uid = _uid;
    if (uid == null) return false;
    try {
      return (await _db.collection('referrals').doc(uid).get()).exists;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<RedeemResult> redeem(String input) async {
    final me = _uid;
    if (me == null) return RedeemResult.notSignedIn;
    final code = normalizeInviteCode(input);
    if (code == null) return RedeemResult.invalid;
    try {
      final codeSnap = await _db.collection('invite_codes').doc(code).get();
      final owner = codeSnap.data()?['ownerUid'];
      if (!codeSnap.exists || owner is! String) return RedeemResult.notFound;
      if (owner == me) return RedeemResult.ownCode;

      final mine = _db.collection('referrals').doc(me);
      if ((await mine.get()).exists) return RedeemResult.alreadyRedeemed;

      await mine.set({
        'referrerUid': owner,
        'code': code,
        'claimed': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return RedeemResult.success;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(e, stack, 'Redeem invite code failed');
      return RedeemResult.error;
    }
  }

  @override
  Future<int> claimPendingRewards() async {
    final me = _uid;
    if (me == null) return 0;
    try {
      final referrals = _db.collection('referrals');
      final claimedSoFar = (await referrals
                  .where('referrerUid', isEqualTo: me)
                  .where('claimed', isEqualTo: true)
                  .count()
                  .get())
              .count ??
          0;
      final room = remainingReferralRewards(claimedSoFar);
      if (room == 0) return 0;

      final pending = await referrals
          .where('referrerUid', isEqualTo: me)
          .where('claimed', isEqualTo: false)
          .limit(room)
          .get();

      var claimed = 0;
      for (final doc in pending.docs) {
        try {
          // Mark first: a failure after this loses one reward but can never
          // pay the same friend twice.
          await doc.reference.update({'claimed': true});
          claimed++;
        } catch (_) {}
      }
      return claimed;
    } catch (e, stack) {
      GlobalExceptionHandler.logError(
          e, stack, 'Claim referral rewards failed');
      return 0;
    }
  }
}
