// Pure rules for the invite-a-friend rewards, free of Firebase so they can be
// unit-tested.

const referralCodeLength = 6;

/// Points the new user gets for entering a friend's code.
const referralInviteeBonus = 100;

/// Points the inviting user gets for each friend who joined with the code.
const referralReferrerBonus = 200;

/// Most rewards one account can collect from invites.
const maxReferralRewards = 20;

// 32 symbols (5 bits each). No I, O, 0 or 1, so codes survive being read aloud
// or typed from a chat message.
const _alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

int _fnv1a(String input) {
  var hash = 0x811C9DC5;
  for (final unit in input.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}

/// A short, stable code for [uid]. [salt] produces another candidate when two
/// accounts happen to collide on the same code.
String generateInviteCode(String uid, {int salt = 0}) {
  final a = _fnv1a('$uid#$salt');
  final b = _fnv1a('$salt#$uid');
  final rotated = ((b << 7) | (b >> 25)) & 0xFFFFFFFF;
  var value = (a ^ rotated) & 0x3FFFFFFF; // 30 bits = 6 symbols
  final out = StringBuffer();
  for (var i = 0; i < referralCodeLength; i++) {
    out.write(_alphabet[value & 31]);
    value >>= 5;
  }
  return out.toString();
}

final _validCode = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');

/// Cleans up what the user typed (case, spaces, dashes) and returns the code,
/// or null when it cannot be a valid invite code.
String? normalizeInviteCode(String input) {
  final cleaned = input.toUpperCase().replaceAll(RegExp(r'[\s\-]'), '');
  return _validCode.hasMatch(cleaned) ? cleaned : null;
}

/// How many more rewards an inviter may still collect.
int remainingReferralRewards(int alreadyClaimed) =>
    (maxReferralRewards - alreadyClaimed).clamp(0, maxReferralRewards);
