import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/data/models/auth_status.dart';
import '../../../core/data/services/moderation_service.dart';
import '../../../core/data/state/user_notifier.dart';
import '../../auth/presentation/auth_notifier.dart';
import '../data/gift_api.dart';
import '../data/install_referral.dart';
import '../data/referral_api.dart';
import '../domain/gift_rules.dart';
import '../domain/referral_rules.dart';

/// True while a user is signed in. A provider of its own so screens (and
/// tests) can depend on it without touching Firebase.
final signedInProvider = Provider<bool>(
  (ref) => ref.watch(authProvider).status == AuthStatus.authenticated,
);

final referralApiProvider =
    Provider<ReferralApi>((ref) => FirebaseReferralApi());

final inviteCodeProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.read(referralApiProvider).myInviteCode(),
);

final referralRedeemedProvider = FutureProvider.autoDispose<bool>(
  (ref) => ref.read(referralApiProvider).hasRedeemed(),
);

/// Collects the rewards of friends who joined with this account's code, adds
/// the points, and returns how many friends were rewarded.
Future<int> claimReferralRewards(WidgetRef ref) async {
  if (!ref.read(signedInProvider)) return 0;
  final friends = await ref.read(referralApiProvider).claimPendingRewards();
  if (friends > 0) {
    await ref
        .read(userProvider.notifier)
        .addPoints(friends * referralReferrerBonus);
  }
  return friends;
}

/// Uses the invite code that came with the install link, once the user is
/// signed in. Returns the bonus points added (0 when nothing happened).
Future<int> redeemInstallReferral(WidgetRef ref) async {
  if (!ref.read(signedInProvider)) return 0;
  final code = await InstallReferral.pendingCode();
  if (code == null) return 0;
  final result = await ref.read(referralApiProvider).redeem(code);
  switch (result) {
    case RedeemResult.success:
      await InstallReferral.clear();
      await ref.read(userProvider.notifier).addPoints(referralInviteeBonus);
      ref.invalidate(referralRedeemedProvider);
      return referralInviteeBonus;
    case RedeemResult.invalid:
    case RedeemResult.ownCode:
    case RedeemResult.notFound:
    case RedeemResult.alreadyRedeemed:
      await InstallReferral.clear(); // can never work, stop trying
    case RedeemResult.notSignedIn:
    case RedeemResult.error:
      break; // try again next time
  }
  return 0;
}

// ---------------------------------------------------------------------------
// Treats between friends

final giftApiProvider = Provider<GiftApi>((ref) => FirebaseGiftApi());

/// Whether this user lets friends see when they are focusing, which is also
/// what allows them to receive treats. Off until the user turns it on.
class FocusStatusNotifier extends Notifier<bool> {
  static const _key = 'focus_status_enabled';
  static const _storage = FlutterSecureStorage();

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    try {
      if (await _storage.read(key: _key) == 'true') state = true;
    } catch (_) {}
  }

  Future<void> set(bool enabled) async {
    state = enabled;
    try {
      await _storage.write(key: _key, value: '$enabled');
    } catch (_) {}
    if (!enabled) unawaited(ref.read(giftApiProvider).stopFocus());
  }
}

final focusStatusProvider =
    NotifierProvider<FocusStatusNotifier, bool>(FocusStatusNotifier.new);

/// Senders the user hid; their treats are not shown or announced.
final hiddenSendersProvider = FutureProvider<Set<String>>(
  (ref) => ModerationService.hiddenPlayers(),
);

final incomingGiftsProvider = StreamProvider<List<Gift>>((ref) {
  if (!ref.watch(signedInProvider)) return Stream.value(const <Gift>[]);
  return ref.watch(giftApiProvider).incomingGifts();
});

final unseenGiftCountProvider = Provider<int>((ref) {
  final gifts = ref.watch(incomingGiftsProvider).value ?? const <Gift>[];
  final hidden = ref.watch(hiddenSendersProvider).value ?? const <String>{};
  return unseenCount(gifts, hidden);
});

/// Called by the timer when a focus session starts: tells friends this user is
/// focusing, but only when the user turned that on and is signed in.
Future<void> publishFocusStatus(Ref ref, DateTime endsAt) async {
  if (!ref.read(signedInProvider) || !ref.read(focusStatusProvider)) return;
  await ref.read(giftApiProvider).startFocus(endsAt);
}

/// Called when the session pauses, resets or ends.
Future<void> clearFocusStatus(Ref ref) async {
  if (!ref.read(signedInProvider) || !ref.read(focusStatusProvider)) return;
  await ref.read(giftApiProvider).stopFocus();
}
