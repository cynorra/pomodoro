import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cynora_focus/core/data/models/achievement.dart';
import 'package:cynora_focus/core/data/models/cafe_item.dart';
import 'package:cynora_focus/core/data/state/streak_notifier.dart';
import 'package:cynora_focus/core/data/state/user_notifier.dart';
import 'package:cynora_focus/core/data/state/user_state.dart';
import 'package:cynora_focus/features/achievements/presentation/achievements_screen.dart';
import 'package:cynora_focus/features/auth/presentation/auth_notifier.dart';
import 'package:cynora_focus/features/auth/presentation/auth_state.dart';
import 'package:cynora_focus/features/cafe/presentation/cafe_notifier.dart';
import 'package:cynora_focus/features/cafe/presentation/cafe_screen.dart';
import 'package:cynora_focus/features/home/presentation/home_screen.dart';
import 'package:cynora_focus/features/pomodoro/domain/pomodoro_state.dart';
import 'package:cynora_focus/features/pomodoro/presentation/pomodoro_notifier.dart';
import 'package:cynora_focus/features/profile/presentation/profile_screen.dart';
import 'package:cynora_focus/l10n/generated/app_localizations.dart';

class _FakeAuth extends AuthNotifier {
  @override
  AuthState build() => AuthState.unauthenticated();
}

class _FakePomodoro extends PomodoroNotifier {
  @override
  PomodoroState build() => const PomodoroState(remainingSeconds: 1500);
}

final _cafeItems = [
  CafeItem(
      itemId: 'coffee_espresso',
      nameTr: 'Espresso',
      nameEn: 'Espresso',
      cost: 50,
      iconCode: '☕'),
  CafeItem(
      itemId: 'tea_green',
      nameTr: 'Yeşil Çay',
      nameEn: 'Green Tea',
      cost: 30,
      iconCode: '🍵',
      isOwned: true,
      quantity: 1),
  CafeItem(
      itemId: 'cake_cheese',
      nameTr: 'Cheesecake',
      nameEn: 'Cheesecake',
      cost: 100,
      iconCode: '🍰'),
];

final _achievements = [
  Achievement(
    achievementId: 'streak_3',
    nameTr: '3 Gün Seri',
    nameEn: '3 Day Streak',
    descriptionTr: 'Üst üste 3 gün çalış',
    descriptionEn: 'Study 3 days in a row',
    iconEmoji: '🔥',
    isUnlocked: true,
  ),
  Achievement(
    achievementId: 'points_100',
    nameTr: 'İlk 100 Puan',
    nameEn: 'First 100 Points',
    descriptionTr: '100 puan topla',
    descriptionEn: 'Collect 100 points',
    iconEmoji: '⭐',
  ),
  Achievement(
    achievementId: 'sessions_10',
    nameTr: 'Odak Ustası',
    nameEn: 'Focus Master',
    descriptionTr: '10 seans tamamla',
    descriptionEn: 'Complete 10 sessions',
    iconEmoji: '🎯',
  ),
];

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  required Locale locale,
  required Size size,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        initialUserProvider.overrideWithValue(
          const UserState(totalPoints: 1250, totalStudyMinutes: 540),
        ),
        streakProvider.overrideWith((ref) async => 3),
        authProvider.overrideWith(_FakeAuth.new),
        pomodoroProvider.overrideWith(_FakePomodoro.new),
        cafeItemsProvider.overrideWith((ref) async => _cafeItems),
        achievementsProvider.overrideWith((ref) async => _achievements),
      ],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
  // Screens animate in; settle them without waiting on never-ending timers.
  // The first pump delivers the provider data and builds the lists; their
  // entrance animations start in that frame, so a second pump lets them finish.
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 8));
}

void main() {
  const sizes = {
    'small phone': Size(320, 480),
    'phone': Size(390, 844),
    'landscape': Size(844, 390),
    'tablet': Size(800, 1280),
  };
  final screens = <String, Widget Function()>{
    'home': () => const HomeScreen(),
    'profile': () => const ProfileScreen(),
    'achievements': () => const AchievementsScreen(),
    'cafe': () => const VirtualCafeScreen(),
  };

  for (final screen in screens.entries) {
    for (final locale in const [Locale('en'), Locale('tr')]) {
      for (final size in sizes.entries) {
        testWidgets(
            '${screen.key} fits on ${size.key} (${locale.languageCode})',
            (tester) async {
          await _pump(tester, screen.value(), locale: locale, size: size.value);
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('home shows the real timer card, points and streak',
      (tester) async {
    await _pump(tester, const HomeScreen(),
        locale: const Locale('en'), size: const Size(390, 844));
    expect(find.text('25:00'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('1250'), findsWidgets);
    expect(find.text('3'), findsWidgets);
  });

  testWidgets('cafe lists exactly the three treats', (tester) async {
    await _pump(tester, const VirtualCafeScreen(),
        locale: const Locale('en'), size: const Size(390, 844));
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('Green Tea'), findsOneWidget);
    expect(find.text('Cheesecake'), findsOneWidget);
  });
}
