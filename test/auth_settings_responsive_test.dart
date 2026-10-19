import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/auth/presentation/auth_notifier.dart';
import 'package:cynora_focus/features/auth/presentation/auth_state.dart';
import 'package:cynora_focus/features/auth/presentation/login_screen.dart';
import 'package:cynora_focus/features/auth/presentation/signup_screen.dart';
import 'package:cynora_focus/features/help/presentation/help_screen.dart';
import 'package:cynora_focus/features/profile/presentation/settings_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

/// Skips the Firebase auth stream the real notifier subscribes to.
class _FakeAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => AuthState.unauthenticated();
}

void main() {
  const sizes = <String, Size>{
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'phone landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };

  final screens = <String, Widget Function()>{
    'login': () => const LoginScreen(),
    'signup': () => const SignupScreen(),
    'settings': () => const SettingsScreen(),
    'help': () => const HelpScreen(),
  };

  for (final screen in screens.entries) {
    for (final locale in const [Locale('en'), Locale('tr')]) {
      for (final size in sizes.entries) {
        testWidgets(
            '${screen.key} fits on ${size.key} (${locale.languageCode})',
            (tester) async {
          tester.view.physicalSize = size.value;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                authProvider.overrideWith(_FakeAuthNotifier.new),
              ],
              child: MaterialApp(
                locale: locale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: screen.value(),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 500));

          expect(tester.takeException(), isNull);
        });
      }
    }
  }
}
