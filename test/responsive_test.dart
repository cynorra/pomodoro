import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/onboarding/presentation/onboarding_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

void main() {
  const sizes = <String, Size>{
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'large phone': Size(430, 932),
    'phone landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };

  for (final locale in const [Locale('en'), Locale('tr')]) {
    for (final entry in sizes.entries) {
      testWidgets('onboarding fits on ${entry.key} (${locale.languageCode})',
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
              home: const OnboardingScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // A RenderFlex overflow is reported as a framework exception.
        expect(tester.takeException(), isNull);
      });
    }
  }
}
