import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/social/domain/referral_rules.dart';

void main() {
  group('generateInviteCode', () {
    test('is 6 symbols from the unambiguous alphabet', () {
      final re = RegExp(r'^[A-HJ-NP-Z2-9]{6}$');
      for (var i = 0; i < 200; i++) {
        expect(re.hasMatch(generateInviteCode('user-$i')), isTrue);
      }
    });

    test('never contains the confusing characters I, O, 0, 1', () {
      for (var i = 0; i < 500; i++) {
        final code = generateInviteCode('uid_$i');
        expect(code.contains(RegExp(r'[IO01]')), isFalse, reason: code);
      }
    });

    test('is deterministic', () {
      expect(generateInviteCode('abc123'), generateInviteCode('abc123'));
    });

    test('a different salt gives a different candidate', () {
      final codes = {for (var s = 0; s < 10; s++) generateInviteCode('abc123', salt: s)};
      expect(codes.length, greaterThan(8));
    });

    test('different users almost never share a code', () {
      final codes = {for (var i = 0; i < 5000; i++) generateInviteCode('Zx9${i}Qw$i')};
      // 5000 draws from ~1e9 codes: a collision is possible but must be very rare.
      expect(codes.length, greaterThan(4990));
    });

    test('real-looking Firebase uids work', () {
      final code = generateInviteCode('iYH4gpANkcf20hGphSYt7oSAohm2');
      expect(code.length, 6);
      expect(normalizeInviteCode(code), code);
    });
  });

  group('normalizeInviteCode', () {
    test('accepts lower case, spaces and dashes', () {
      expect(normalizeInviteCode(' abc-234 '), 'ABC234');
      expect(normalizeInviteCode('abc 234'), 'ABC234');
    });

    test('rejects wrong length', () {
      expect(normalizeInviteCode('ABC23'), isNull);
      expect(normalizeInviteCode('ABC2345'), isNull);
      expect(normalizeInviteCode(''), isNull);
    });

    test('rejects confusing or foreign characters', () {
      expect(normalizeInviteCode('ABC0O1'), isNull);
      expect(normalizeInviteCode('ABCI23'), isNull);
      expect(normalizeInviteCode('ABC23!'), isNull);
      expect(normalizeInviteCode('ÇABC23'), isNull);
    });
  });

  group('rewards', () {
    test('bonuses and the cap', () {
      expect(referralInviteeBonus, 100);
      expect(referralReferrerBonus, 200);
      expect(maxReferralRewards, 20);
    });

    test('remaining rewards never goes negative', () {
      expect(remainingReferralRewards(0), 20);
      expect(remainingReferralRewards(7), 13);
      expect(remainingReferralRewards(20), 0);
      expect(remainingReferralRewards(35), 0);
    });
  });
}
