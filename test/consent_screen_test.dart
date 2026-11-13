import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/onboarding/presentation/consent_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

Widget _app(Locale locale, VoidCallback onDone, Future<void> Function(bool) save) => MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ConsentScreen(onDone: onDone, save: save),
    );

void main() {
  for (final locale in const [Locale('en'), Locale('tr')]) {
    testWidgets('consent screen offers equal accept and decline (${locale.languageCode}) at 320px',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      var done = 0;
      final saved = <bool>[];
      await tester.pumpWidget(_app(locale, () => done++, (g) async => saved.add(g)));
      await tester.pumpAndSettle();

      final buttons = find.byType(OutlinedButton);
      expect(buttons, findsNWidgets(2));
      expect(tester.takeException(), isNull);

      // Declining must lead on into the app just like accepting.
      await tester.ensureVisible(buttons.last);
      await tester.tap(buttons.last);
      await tester.pumpAndSettle();
      expect(done, 1);
      expect(saved, [false]);
    });
  }
}
