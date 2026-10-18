import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'YKS Pomodoro & Sanal Cafe'**
  String get appTitle;

  /// No description provided for @deepFocus.
  ///
  /// In tr, this message translates to:
  /// **'Derin Odak'**
  String get deepFocus;

  /// No description provided for @cafeBreak.
  ///
  /// In tr, this message translates to:
  /// **'Kafe Molası'**
  String get cafeBreak;

  /// No description provided for @longBreak.
  ///
  /// In tr, this message translates to:
  /// **'Uzun Mola'**
  String get longBreak;

  /// No description provided for @start.
  ///
  /// In tr, this message translates to:
  /// **'Başlat'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In tr, this message translates to:
  /// **'Duraklat'**
  String get pause;

  /// No description provided for @reset.
  ///
  /// In tr, this message translates to:
  /// **'Sıfırla'**
  String get reset;

  /// No description provided for @totalPoints.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Puan'**
  String get totalPoints;

  /// No description provided for @totalHours.
  ///
  /// In tr, this message translates to:
  /// **'Toplam Saat'**
  String get totalHours;

  /// No description provided for @points.
  ///
  /// In tr, this message translates to:
  /// **'Puan'**
  String get points;

  /// No description provided for @hours.
  ///
  /// In tr, this message translates to:
  /// **'Saat'**
  String get hours;

  /// No description provided for @sessions.
  ///
  /// In tr, this message translates to:
  /// **'Seans'**
  String get sessions;

  /// No description provided for @virtualCafe.
  ///
  /// In tr, this message translates to:
  /// **'Sanal Kafe'**
  String get virtualCafe;

  /// No description provided for @statistics.
  ///
  /// In tr, this message translates to:
  /// **'İstatistikler'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @achievements.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievements;

  /// No description provided for @insufficientPoints.
  ///
  /// In tr, this message translates to:
  /// **'Yetersiz Puan! Biraz daha odaklanmalısın 🎯'**
  String get insufficientPoints;

  /// No description provided for @purchaseSuccess.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma başarılı! ☕'**
  String get purchaseSuccess;

  /// No description provided for @inventory.
  ///
  /// In tr, this message translates to:
  /// **'Envanter'**
  String get inventory;

  /// No description provided for @week.
  ///
  /// In tr, this message translates to:
  /// **'Hafta'**
  String get week;

  /// No description provided for @month.
  ///
  /// In tr, this message translates to:
  /// **'Ay'**
  String get month;

  /// No description provided for @allTime.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get allTime;

  /// No description provided for @weeklyChart.
  ///
  /// In tr, this message translates to:
  /// **'Haftalık Çalışma Grafiği'**
  String get weeklyChart;

  /// No description provided for @achievementBadges.
  ///
  /// In tr, this message translates to:
  /// **'Başarı Rozetleri'**
  String get achievementBadges;

  /// No description provided for @progress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme'**
  String get progress;

  /// No description provided for @dayMonday.
  ///
  /// In tr, this message translates to:
  /// **'Pzt'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In tr, this message translates to:
  /// **'Sal'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In tr, this message translates to:
  /// **'Çar'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In tr, this message translates to:
  /// **'Per'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In tr, this message translates to:
  /// **'Cum'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In tr, this message translates to:
  /// **'Cmt'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In tr, this message translates to:
  /// **'Paz'**
  String get daySunday;

  /// No description provided for @threeDayStreak.
  ///
  /// In tr, this message translates to:
  /// **'3 Gün Seri'**
  String get threeDayStreak;

  /// No description provided for @threeDayStreakDesc.
  ///
  /// In tr, this message translates to:
  /// **'Üst üste 3 gün çalış'**
  String get threeDayStreakDesc;

  /// No description provided for @first100Points.
  ///
  /// In tr, this message translates to:
  /// **'İlk 100 Puan'**
  String get first100Points;

  /// No description provided for @first100PointsDesc.
  ///
  /// In tr, this message translates to:
  /// **'100 puan topla'**
  String get first100PointsDesc;

  /// No description provided for @focusMaster.
  ///
  /// In tr, this message translates to:
  /// **'Odak Ustası'**
  String get focusMaster;

  /// No description provided for @focusMasterDesc.
  ///
  /// In tr, this message translates to:
  /// **'10 seans tamamla'**
  String get focusMasterDesc;

  /// No description provided for @weekStreak.
  ///
  /// In tr, this message translates to:
  /// **'1 Hafta Seri'**
  String get weekStreak;

  /// No description provided for @weekStreakDesc.
  ///
  /// In tr, this message translates to:
  /// **'Üst üste 7 gün çalış'**
  String get weekStreakDesc;

  /// No description provided for @pointHunter.
  ///
  /// In tr, this message translates to:
  /// **'Puan Avcısı'**
  String get pointHunter;

  /// No description provided for @pointHunterDesc.
  ///
  /// In tr, this message translates to:
  /// **'500 puan topla'**
  String get pointHunterDesc;

  /// No description provided for @dailyMotivation.
  ///
  /// In tr, this message translates to:
  /// **'Günün Motivasyonu'**
  String get dailyMotivation;

  /// No description provided for @motivationText.
  ///
  /// In tr, this message translates to:
  /// **'Başarı, her gün tekrarlanan küçük çabaların toplamıdır. Bugün bir adım daha at! 🚀'**
  String get motivationText;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In tr, this message translates to:
  /// **'İngilizce'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get notifications;

  /// No description provided for @allow.
  ///
  /// In tr, this message translates to:
  /// **'İzin Ver'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi Değil'**
  String get notNow;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @turnOffSound.
  ///
  /// In tr, this message translates to:
  /// **'Sesi Kapat'**
  String get turnOffSound;

  /// No description provided for @selectAmbientSound.
  ///
  /// In tr, this message translates to:
  /// **'Ortam Sesi Seç'**
  String get selectAmbientSound;

  /// No description provided for @startTimer.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcıyı başlat'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In tr, this message translates to:
  /// **'Zamanlayıcıyı duraklat'**
  String get pauseTimer;

  /// No description provided for @buyItem.
  ///
  /// In tr, this message translates to:
  /// **'{name} satın al, {cost} puan'**
  String buyItem(String name, int cost);

  /// No description provided for @achievementUnlocked.
  ///
  /// In tr, this message translates to:
  /// **'Rozet Kazandın!'**
  String get achievementUnlocked;

  /// No description provided for @awesome.
  ///
  /// In tr, this message translates to:
  /// **'Harika!'**
  String get awesome;

  /// No description provided for @somethingWentWrong.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti 😔'**
  String get somethingWentWrong;

  /// No description provided for @rain.
  ///
  /// In tr, this message translates to:
  /// **'Yağmur'**
  String get rain;

  /// No description provided for @coffeeShop.
  ///
  /// In tr, this message translates to:
  /// **'Kahve Dükkanı'**
  String get coffeeShop;

  /// No description provided for @fireplace.
  ///
  /// In tr, this message translates to:
  /// **'Şömine'**
  String get fireplace;

  /// No description provided for @lofiBeats.
  ///
  /// In tr, this message translates to:
  /// **'Lo-Fi Beats'**
  String get lofiBeats;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @login.
  ///
  /// In tr, this message translates to:
  /// **'Giriş Yap'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt Ol'**
  String get signUp;

  /// No description provided for @displayName.
  ///
  /// In tr, this message translates to:
  /// **'İsim'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @noAccountSignup.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu? Kayıt ol'**
  String get noAccountSignup;

  /// No description provided for @createAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap Oluştur'**
  String get createAccount;

  /// No description provided for @agreeToTerms.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım şartlarını ve gizlilik politikasını kabul ediyorum'**
  String get agreeToTerms;

  /// No description provided for @privacyPolicy.
  ///
  /// In tr, this message translates to:
  /// **'Gizlilik Politikası'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım Şartları'**
  String get termsOfService;

  /// No description provided for @logout.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccount;

  /// No description provided for @inviteFriends.
  ///
  /// In tr, this message translates to:
  /// **'Arkadaş Davet Et'**
  String get inviteFriends;

  /// No description provided for @help.
  ///
  /// In tr, this message translates to:
  /// **'Yardım'**
  String get help;

  /// No description provided for @premium.
  ///
  /// In tr, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @watchAdForPoints.
  ///
  /// In tr, this message translates to:
  /// **'Reklam İzle +50 Puan'**
  String get watchAdForPoints;

  /// No description provided for @leaderboard.
  ///
  /// In tr, this message translates to:
  /// **'Global Sıralama'**
  String get leaderboard;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
