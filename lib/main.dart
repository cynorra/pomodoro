import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';
import 'core/utils/global_exception_handler.dart';
import 'core/data/services/analytics_service.dart';
import 'core/data/services/remote_config_service.dart';
import 'core/data/services/notification_service.dart';
import 'core/data/services/audio_service.dart';
import 'core/data/services/achievement_service.dart';
import 'core/data/services/ad_service.dart';
import 'core/data/database/database_service.dart';
import 'core/data/state/locale_notifier.dart';
import 'core/data/state/user_notifier.dart';
import 'core/data/state/user_state.dart';
import 'core/data/state/achievement_event_notifier.dart';
import 'core/ui/zyra_theme.dart';
import 'core/ui/widgets/animated_splash.dart';
import 'features/home/presentation/main_shell.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final initialLocale = await LocaleNotifier.loadInitialLocale();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    GlobalExceptionHandler.initialize();
    await DatabaseService.initialize();

    final snapshot = await DatabaseService.readUserSnapshot();

    unawaited(
      RemoteConfigService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      ),
    );
    unawaited(
      AdService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      ),
    );
    unawaited(NotificationService.initialize());
    unawaited(AchievementService.seedDefaultAchievements());
    unawaited(AnalyticsService.logAppOpen());

    runApp(
      ProviderScope(
        overrides: [
          initialLocaleProvider.overrideWithValue(initialLocale),
          initialUserProvider.overrideWithValue(
            UserState(
              totalPoints: snapshot.points,
              totalStudyMinutes: snapshot.minutes,
            ),
          ),
        ],
        child: const StudyCafeApp(),
      ),
    );
  } catch (e, stack) {
    GlobalExceptionHandler.logError(e, stack, 'App initialization failed');
    runApp(const ErrorApp());
  }
}

class StudyCafeApp extends ConsumerStatefulWidget {
  const StudyCafeApp({super.key});

  @override
  ConsumerState<StudyCafeApp> createState() => _StudyCafeAppState();
}

class _StudyCafeAppState extends ConsumerState<StudyCafeApp> {
  bool _showSplash = true;
  bool _showOnboarding = false;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final completed = await _storage.read(key: 'onboarding_completed');
    if (mounted) {
      setState(() => _showOnboarding = completed != 'true');
    }
  }

  @override
  void dispose() {
    AudioService.dispose();
    AchievementEventStream.dispose();
    AdService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    Widget initialScreen;
    if (_showSplash) {
      initialScreen = AnimatedSplashOverlay(
        onComplete: () {
          if (mounted) setState(() => _showSplash = false);
        },
      );
    } else if (_showOnboarding) {
      initialScreen = const OnboardingScreen();
    } else {
      initialScreen = const MainShell();
    }

    return MaterialApp(
      title: 'Study Cafe',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('tr')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: ZyraColors.primary,
        scaffoldBackgroundColor: ZyraColors.background,
        colorScheme: const ColorScheme.dark(
          primary: ZyraColors.primary,
          secondary: ZyraColors.secondary,
          surface: ZyraColors.surface,
        ),
        useMaterial3: true,
      ),
      // Keep phone-style layouts readable on tablets/landscape and cap
      // system font scaling so fixed-size widgets do not overflow.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.3,
            ),
          ),
          child: ColoredBox(
            color: ZyraColors.background,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: child,
              ),
            ),
          ),
        );
      },
      home: initialScreen,
      navigatorObservers: [
        SafeAnalyticsObserver(),
      ],
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('tr')],
      builder: (context, child) {
        final l10n = AppLocalizations.of(context);
        return Scaffold(
          backgroundColor: ZyraColors.background,
          body: Center(
            child: Text(
              l10n.somethingWentWrong,
              style: ZyraTypography.headlineMedium.copyWith(
                color: ZyraColors.onBackground,
              ),
            ),
          ),
        );
      },
    );
  }
}
