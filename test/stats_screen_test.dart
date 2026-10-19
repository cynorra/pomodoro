import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/models/study_session.dart';
import 'package:cynora_focus/features/stats/presentation/stats_provider.dart';
import 'package:cynora_focus/features/stats/presentation/stats_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

/// Months of history, so the all-time view has far more days than bars.
List<StudySession> _history() {
  final now = DateTime.now();
  return [
    for (var i = 0; i < 240; i += 2)
      StudySession(
        date: now.subtract(Duration(days: i, hours: 1)),
        durationSeconds: (25 + i % 90) * 60,
        pointsEarned: 10,
        sessionType: 'focus',
      ),
  ];
}

Future<void> _pump(
  WidgetTester tester, {
  required Locale locale,
  required Size size,
  List<StudySession>? sessions,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final data = sessions ?? _history();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        statsDataProvider.overrideWith((ref) async => data),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const StatsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  const sizes = {
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };

  for (final locale in const [Locale('en'), Locale('tr')]) {
    for (final size in sizes.entries) {
      for (final tab in const {
        'en': ['Week', 'Month', 'All Time'],
        'tr': ['Hafta', 'Ay', 'Tümü'],
      }[locale.languageCode]!) {
        testWidgets('stats "$tab" fits on ${size.key} (${locale.languageCode})',
            (tester) async {
          await _pump(tester, locale: locale, size: size.value);
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('empty history shows the empty state', (tester) async {
    await _pump(
      tester,
      locale: const Locale('en'),
      size: const Size(390, 844),
      sessions: const [],
    );
    expect(find.text('No study data yet'), findsOneWidget);
  });

  testWidgets('the chart title follows the selected filter', (tester) async {
    await _pump(tester, locale: const Locale('en'), size: const Size(390, 844));
    expect(find.text('Weekly Study Chart'), findsOneWidget);
    await tester.tap(find.text('Month'));
    await tester.pumpAndSettle();
    expect(find.text('Last 30 Days'), findsOneWidget);
    await tester.tap(find.text('All Time'));
    await tester.pumpAndSettle();
    expect(find.text('Last 6 Months'), findsOneWidget);
  });
}
