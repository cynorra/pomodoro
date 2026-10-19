import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/social/data/gift_api.dart';
import 'package:cynora_focus/features/social/domain/gift_rules.dart';
import 'package:cynora_focus/features/social/presentation/notifications_screen.dart';
import 'package:cynora_focus/features/social/presentation/send_treat_sheet.dart';
import 'package:cynora_focus/features/social/presentation/social_providers.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

class FakeGiftApi implements GiftApi {
  FakeGiftApi({this.gifts = const [], this.friends = const []});

  final List<Gift> gifts;
  final List<FocusingUser> friends;
  final marked = <String>[];
  final deleted = <String>[];

  @override
  Future<void> startFocus(DateTime endsAt) async {}
  @override
  Future<void> stopFocus() async {}
  @override
  Future<List<FocusingUser>> focusingNow() async => friends;
  @override
  Future<SendResult> sendGift({
    required String toUid,
    required String itemId,
  }) async =>
      SendResult.success;
  @override
  Stream<List<Gift>> incomingGifts() => Stream.value(gifts);
  @override
  Future<void> markSeen(Iterable<String> giftIds) async =>
      marked.addAll(giftIds);
  @override
  Future<void> deleteGifts(Iterable<String> giftIds) async =>
      deleted.addAll(giftIds);
}

Future<void> pump(
  WidgetTester tester,
  Widget child,
  FakeGiftApi api, {
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        signedInProvider.overrideWithValue(true),
        giftApiProvider.overrideWithValue(api),
        hiddenSendersProvider.overrideWith((ref) async => <String>{'bad'}),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: child,
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Gift gift(String id, String from, {bool seen = false}) => Gift(
      id: id,
      fromUid: from,
      fromName: 'Mia',
      itemId: 'tea_green',
      createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      seen: seen,
    );

void main() {
  testWidgets('inbox shows empty state', (tester) async {
    await pump(tester, const NotificationsScreen(), FakeGiftApi());
    expect(find.text('🎁'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('inbox lists treats, hides blocked senders, marks read',
      (tester) async {
    final api = FakeGiftApi(gifts: [
      gift('1', 'ok'),
      gift('2', 'bad'),
    ]);
    await pump(tester, const NotificationsScreen(), api);
    expect(find.byType(ListTile), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(api.marked, ['1']);
  });

  testWidgets('inbox fits 320px wide in Turkish', (tester) async {
    await pump(
      tester,
      const NotificationsScreen(),
      FakeGiftApi(gifts: [gift('1', 'ok')]),
      locale: const Locale('tr'),
      size: const Size(320, 568),
    );
    await tester.pump(const Duration(milliseconds: 1600));
    expect(tester.takeException(), isNull);
  });

  testWidgets('send sheet with nobody focusing', (tester) async {
    await pump(tester, const Scaffold(body: SendTreatSheet()), FakeGiftApi());
    expect(find.byType(ChoiceChip), findsNWidgets(giftItems.length));
    expect(find.byType(ListTile), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('send sheet lists a focusing friend without overflow at 320px',
      (tester) async {
    final api = FakeGiftApi(friends: [
      FocusingUser(
        uid: 'f',
        name: 'A very long friend name that must not overflow the row',
        endsAt: DateTime.now().add(const Duration(minutes: 12)),
      ),
    ]);
    await pump(
      tester,
      const Scaffold(body: SendTreatSheet()),
      api,
      size: const Size(320, 568),
    );
    expect(find.byType(ListTile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
