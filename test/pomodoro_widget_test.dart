import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/features/pomodoro/domain/pomodoro_state.dart';
import 'package:cynora_focus/features/pomodoro/presentation/pomodoro_notifier.dart';
import 'package:cynora_focus/features/pomodoro/presentation/pomodoro_widget.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

/// Replaces the real timer (Firebase Remote Config, notifications, ticking)
/// so only the widget's behaviour is tested.
class _FakePomodoro extends PomodoroNotifier {
  _FakePomodoro(this.initial);

  final PomodoroState initial;
  int toggles = 0;
  int resets = 0;

  @override
  PomodoroState build() => initial;

  @override
  void toggleTimer() => toggles++;

  @override
  void resetTimer() => resets++;
}

Future<_FakePomodoro> _pump(
  WidgetTester tester, {
  required PomodoroState state,
  Locale locale = const Locale('en'),
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  late _FakePomodoro fake;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pomodoroProvider.overrideWith(() => fake = _FakePomodoro(state)),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SingleChildScrollView(child: PomodoroWidget())),
      ),
    ),
  );
  await tester.pump();
  return fake;
}

void main() {
  testWidgets('shows the time, the session label and Start / Reset', (tester) async {
    await _pump(tester, state: const PomodoroState(remainingSeconds: 25 * 60));
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Deep Focus'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
  });

  testWidgets('formats minutes and seconds with leading zeros', (tester) async {
    await _pump(tester, state: const PomodoroState(remainingSeconds: 5 * 60 + 7));
    expect(find.text('05:07'), findsOneWidget);
  });

  testWidgets('a running timer offers Pause', (tester) async {
    await _pump(
      tester,
      state: const PomodoroState(remainingSeconds: 600, isRunning: true),
    );
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Start'), findsNothing);
  });

  testWidgets('break sessions get their own labels', (tester) async {
    await _pump(
      tester,
      state: const PomodoroState(remainingSeconds: 300, sessionType: SessionType.shortBreak),
    );
    expect(find.text('Cafe Break'), findsOneWidget);
  });

  testWidgets('long break label', (tester) async {
    await _pump(
      tester,
      state: const PomodoroState(remainingSeconds: 900, sessionType: SessionType.longBreak),
    );
    expect(find.text('Long Break'), findsOneWidget);
  });

  testWidgets('tapping Start toggles and Reset resets', (tester) async {
    final fake = await _pump(tester, state: const PomodoroState());
    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(fake.toggles, 1);
    expect(fake.resets, 0);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(fake.resets, 1);
  });

  testWidgets('Turkish labels', (tester) async {
    await _pump(
      tester,
      state: const PomodoroState(),
      locale: const Locale('tr'),
    );
    expect(find.text('Sıfırla'), findsOneWidget);
    expect(find.text('Başlat'), findsOneWidget);
  });

  for (final size in const [Size(320, 480), Size(390, 844), Size(844, 390), Size(800, 1280)]) {
    for (final locale in const [Locale('en'), Locale('tr')]) {
      testWidgets('fits at ${size.width.toInt()}x${size.height.toInt()} (${locale.languageCode})',
          (tester) async {
        await _pump(
          tester,
          state: const PomodoroState(remainingSeconds: 1500, isRunning: true),
          locale: locale,
          size: size,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
