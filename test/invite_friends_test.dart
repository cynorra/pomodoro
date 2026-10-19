import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/social/data/referral_api.dart';
import 'package:cynora_focus/features/social/presentation/invite_friends_screen.dart';
import 'package:cynora_focus/features/social/presentation/social_providers.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

class FakeReferralApi implements ReferralApi {
  FakeReferralApi({
    this.code = 'ABC234',
    this.redeemed = false,
    this.result = RedeemResult.success,
    this.pending = 0,
  });

  final String? code;
  bool redeemed;
  RedeemResult result;
  int pending;
  final redeemCalls = <String>[];

  @override
  Future<String?> myInviteCode() async => code;

  @override
  Future<bool> hasRedeemed() async => redeemed;

  @override
  Future<RedeemResult> redeem(String input) async {
    redeemCalls.add(input);
    if (result == RedeemResult.success) redeemed = true;
    return result;
  }

  @override
  Future<int> claimPendingRewards() async {
    final n = pending;
    pending = 0;
    return n;
  }
}

Future<void> pumpInvite(
  WidgetTester tester,
  FakeReferralApi api, {
  bool signedIn = true,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        signedInProvider.overrideWithValue(signedIn),
        referralApiProvider.overrideWithValue(api),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const InviteFriendsScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

void main() {
  testWidgets('signed out: asks to log in, shows no code and no redeem box',
      (tester) async {
    await pumpInvite(tester, FakeReferralApi(), signedIn: false);
    expect(find.text('Log in to get your invite code and earn points.'),
        findsOneWidget);
    expect(find.text('ABC234'), findsNothing);
    expect(find.text("Have a friend's code?"), findsNothing);
  });

  testWidgets('signed in: shows my code and the redeem box', (tester) async {
    await pumpInvite(tester, FakeReferralApi());
    expect(find.text('Your invite code'), findsOneWidget);
    expect(find.text('ABC234'), findsOneWidget);
    expect(find.text("Have a friend's code?"), findsOneWidget);
    expect(find.text('Redeem'), findsOneWidget);
  });

  testWidgets('redeeming a code passes the typed text and gives +100',
      (tester) async {
    final api = FakeReferralApi();
    await pumpInvite(tester, api);
    await tester.enterText(find.byType(TextField), 'xyz789');
    await tester.ensureVisible(find.text('Redeem'));
    await tester.tap(find.text('Redeem'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(api.redeemCalls, ['xyz789']);
    expect(find.textContaining('+100 points'), findsOneWidget);
    // Once used, the redeem box goes away.
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Redeem'), findsNothing);
  });

  const failures = {
    RedeemResult.invalid:
        'That code is not valid. Codes have 6 letters and numbers.',
    RedeemResult.ownCode: "You can't use your own code.",
    RedeemResult.notFound: "We couldn't find that code.",
    RedeemResult.alreadyRedeemed: 'You have already used an invite code.',
    RedeemResult.error: 'Something went wrong 😔',
  };
  for (final entry in failures.entries) {
    testWidgets('redeem result ${entry.key.name} shows its message',
        (tester) async {
      final api = FakeReferralApi(result: entry.key);
      await pumpInvite(tester, api);
      await tester.enterText(find.byType(TextField), 'abc234');
      await tester.ensureVisible(find.text('Redeem'));
      await tester.tap(find.text('Redeem'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(entry.value), findsOneWidget);
    });
  }

  testWidgets('an account that already used a code does not see the box',
      (tester) async {
    await pumpInvite(tester, FakeReferralApi(redeemed: true));
    expect(find.text("Have a friend's code?"), findsNothing);
  });

  testWidgets(
      'rewards of friends who joined are announced when the screen opens',
      (tester) async {
    await pumpInvite(tester, FakeReferralApi(pending: 2));
    expect(find.text('🎉 2 friends joined with your code! +400 points'),
        findsOneWidget);
  });

  testWidgets('one friend uses the singular', (tester) async {
    await pumpInvite(tester, FakeReferralApi(pending: 1));
    expect(find.text('🎉 A friend joined with your code! +200 points'),
        findsOneWidget);
  });

  testWidgets('Turkish texts', (tester) async {
    await pumpInvite(tester, FakeReferralApi(), locale: const Locale('tr'));
    expect(find.text('Davet kodun'), findsOneWidget);
    expect(find.text('Kullan'), findsOneWidget);
  });

  const sizes = {
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };
  for (final locale in const [Locale('en'), Locale('tr')]) {
    for (final signedIn in const [true, false]) {
      for (final size in sizes.entries) {
        testWidgets(
            'invite screen fits on ${size.key} (${locale.languageCode}, ${signedIn ? 'signed in' : 'signed out'})',
            (tester) async {
          await pumpInvite(tester, FakeReferralApi(),
              signedIn: signedIn, locale: locale, size: size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
