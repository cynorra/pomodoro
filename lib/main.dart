import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';
import 'core/utils/global_exception_handler.dart';
import 'core/data/services/analytics_service.dart';
import 'core/data/services/privacy_consent_service.dart';
import 'features/onboarding/presentation/consent_screen.dart';
import 'core/data/services/remote_config_service.dart';
import 'core/data/services/notification_service.dart';
import 'core/data/services/reminder_service.dart';
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

    await PrivacyConsentService.applyStored();
    GlobalExceptionHandler.initialize();
    await DatabaseService.initialize();

    final snapshot = await DatabaseService.readUserSnapshot();

    unawaited(
      RemoteConfigService.initialize().timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      ),
    );
    unawaited(NotificationService.initialize()
        .then((_) => ReminderService.refresh()));
    unawaited(AchievementService.seedDefaultAchievements());
    unawaited(AnalyticsService.logAppOpen());

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => unawaited(AdService.initialize()),
    );

    runApp(
      ProviderScope(
        retry: (retryCount, error) => null,
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
  bool _needsConsent = false;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
    _checkConsent();
  }

  Future<void> _checkConsent() async {
    final choice = await PrivacyConsentService.read();
    if (mounted && choice == null) setState(() => _needsConsent = true);
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
      // Show the app's value first; the (long) privacy consent comes right after.
      initialScreen = OnboardingScreen(
        onDone: () {
          if (mounted) setState(() => _showOnboarding = false);
        },
      );
    } else if (_needsConsent) {
      initialScreen = ConsentScreen(
        onDone: () {
          if (mounted) setState(() => _needsConsent = false);
        },
      );
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
      theme: ZyraTheme.darkTheme,
      // Keep phone-style layouts readable on tablets/landscape and cap
      // system font scaling so fixed-size widgets do not overflow.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        final width = media.size.width > 600 ? 600.0 : media.size.width;
        return MediaQuery(
          data: media.copyWith(
            size: Size(width, media.size.height),
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
