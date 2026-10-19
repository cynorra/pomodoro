import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/social/presentation/invite_friends_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

void main() {
  const sizes = <String, Size>{
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'phone landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };

  for (final locale in const [Locale('en'), Locale('tr')]) {
    for (final entry in sizes.entries) {
      testWidgets('invite friends fits on ${entry.key} (${locale.languageCode})',
          (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const InviteFriendsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  }
}
