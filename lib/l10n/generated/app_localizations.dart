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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
  /// In en, this message translates to:
  /// **'Study Cafe: Pomodoro Timer'**
  String get appTitle;

  /// No description provided for @deepFocus.
  ///
  /// In en, this message translates to:
  /// **'Deep Focus'**
  String get deepFocus;

  /// No description provided for @cafeBreak.
  ///
  /// In en, this message translates to:
  /// **'Cafe Break'**
  String get cafeBreak;

  /// No description provided for @longBreak.
  ///
  /// In en, this message translates to:
  /// **'Long Break'**
  String get longBreak;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @totalPoints.
  ///
  /// In en, this message translates to:
  /// **'Total Points'**
  String get totalPoints;

  /// No description provided for @totalHours.
  ///
  /// In en, this message translates to:
  /// **'Total Hours'**
  String get totalHours;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @hours.
  ///
  /// In en, this message translates to:
  /// **'Hours'**
  String get hours;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @virtualCafe.
  ///
  /// In en, this message translates to:
  /// **'Virtual Cafe'**
  String get virtualCafe;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @insufficientPoints.
  ///
  /// In en, this message translates to:
  /// **'Not enough points! Focus a bit more 🎯'**
  String get insufficientPoints;

  /// No description provided for @purchaseSuccess.
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! ☕'**
  String get purchaseSuccess;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @week.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get week;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get month;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @weeklyChart.
  ///
  /// In en, this message translates to:
  /// **'Weekly Study Chart'**
  String get weeklyChart;

  /// No description provided for @achievementBadges.
  ///
  /// In en, this message translates to:
  /// **'Achievement Badges'**
  String get achievementBadges;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @dayMonday.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get dayMonday;

  /// No description provided for @dayTuesday.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get dayTuesday;

  /// No description provided for @dayWednesday.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get dayWednesday;

  /// No description provided for @dayThursday.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get dayThursday;

  /// No description provided for @dayFriday.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get dayFriday;

  /// No description provided for @daySaturday.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get daySaturday;

  /// No description provided for @daySunday.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get daySunday;

  /// No description provided for @threeDayStreak.
  ///
  /// In en, this message translates to:
  /// **'3 Day Streak'**
  String get threeDayStreak;

  /// No description provided for @threeDayStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Study 3 days in a row'**
  String get threeDayStreakDesc;

  /// No description provided for @first100Points.
  ///
  /// In en, this message translates to:
  /// **'First 100 Points'**
  String get first100Points;

  /// No description provided for @first100PointsDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect 100 points'**
  String get first100PointsDesc;

  /// No description provided for @focusMaster.
  ///
  /// In en, this message translates to:
  /// **'Focus Master'**
  String get focusMaster;

  /// No description provided for @focusMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 sessions'**
  String get focusMasterDesc;

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'1 Week Streak'**
  String get weekStreak;

  /// No description provided for @weekStreakDesc.
  ///
  /// In en, this message translates to:
  /// **'Study 7 days in a row'**
  String get weekStreakDesc;

  /// No description provided for @pointHunter.
  ///
  /// In en, this message translates to:
  /// **'Point Hunter'**
  String get pointHunter;

  /// No description provided for @pointHunterDesc.
  ///
  /// In en, this message translates to:
  /// **'Collect 500 points'**
  String get pointHunterDesc;

  /// No description provided for @dailyMotivation.
  ///
  /// In en, this message translates to:
  /// **'Daily Motivation'**
  String get dailyMotivation;

  /// No description provided for @motivationText.
  ///
  /// In en, this message translates to:
  /// **'Success is the sum of small efforts repeated day in and day out. Take one more step today! 🚀'**
  String get motivationText;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Türkçe'**
  String get turkish;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @turnOffSound.
  ///
  /// In en, this message translates to:
  /// **'Turn Off Sound'**
  String get turnOffSound;

  /// No description provided for @selectAmbientSound.
  ///
  /// In en, this message translates to:
  /// **'Select Ambient Sound'**
  String get selectAmbientSound;

  /// No description provided for @startTimer.
  ///
  /// In en, this message translates to:
  /// **'Start timer'**
  String get startTimer;

  /// No description provided for @pauseTimer.
  ///
  /// In en, this message translates to:
  /// **'Pause timer'**
  String get pauseTimer;

  /// No description provided for @buyItem.
  ///
  /// In en, this message translates to:
  /// **'Buy {name}, {cost} points'**
  String buyItem(String name, int cost);

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// No description provided for @awesome.
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong 😔'**
  String get somethingWentWrong;

  /// No description provided for @rain.
  ///
  /// In en, this message translates to:
  /// **'Rain'**
  String get rain;

  /// No description provided for @brownNoise.
  ///
  /// In en, this message translates to:
  /// **'Brown Noise'**
  String get brownNoise;

  /// No description provided for @coffeeShop.
  ///
  /// In en, this message translates to:
  /// **'Coffee Shop'**
  String get coffeeShop;

  /// No description provided for @fireplace.
  ///
  /// In en, this message translates to:
  /// **'Fireplace'**
  String get fireplace;

  /// No description provided for @lofiBeats.
  ///
  /// In en, this message translates to:
  /// **'Lo-Fi Beats'**
  String get lofiBeats;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get displayName;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @noAccountSignup.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get noAccountSignup;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the terms of service and privacy policy'**
  String get agreeToTerms;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @inviteFriends.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @watchAdForPoints.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad +50 Points'**
  String get watchAdForPoints;

  /// No description provided for @leaderboard.
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboard'**
  String get leaderboard;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @navFocus.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get navFocus;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navCafe.
  ///
  /// In en, this message translates to:
  /// **'Cafe'**
  String get navCafe;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @authErrorUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get authErrorUnknown;

  /// No description provided for @authErrorUserNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get authErrorUserNotFound;

  /// No description provided for @authErrorDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not delete the account'**
  String get authErrorDeleteFailed;

  /// No description provided for @authErrorResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the email'**
  String get authErrorResetFailed;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In en, this message translates to:
  /// **'This email is already in use'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password is too weak (at least 6 characters)'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorWrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Wrong email or password'**
  String get authErrorWrongPassword;

  /// No description provided for @authErrorTooManyRequests.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Please try again later'**
  String get authErrorTooManyRequests;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @orDivider.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get orDivider;

  /// No description provided for @authGoogleSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed. Please try again.'**
  String get authGoogleSignInFailed;

  /// No description provided for @adPrivacySettings.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy settings'**
  String get adPrivacySettings;

  /// No description provided for @reportPlayer.
  ///
  /// In en, this message translates to:
  /// **'Report player'**
  String get reportPlayer;

  /// No description provided for @hidePlayer.
  ///
  /// In en, this message translates to:
  /// **'Hide this player'**
  String get hidePlayer;

  /// No description provided for @reportReasonTitle.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this player?'**
  String get reportReasonTitle;

  /// No description provided for @reportReasonName.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate name'**
  String get reportReasonName;

  /// No description provided for @reportReasonCheating.
  ///
  /// In en, this message translates to:
  /// **'Cheating'**
  String get reportReasonCheating;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportSent.
  ///
  /// In en, this message translates to:
  /// **'Thanks. We will review this report.'**
  String get reportSent;

  /// No description provided for @reportFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not send the report. You may have already reported this player.'**
  String get reportFailed;

  /// No description provided for @playerHidden.
  ///
  /// In en, this message translates to:
  /// **'Player hidden'**
  String get playerHidden;

  /// No description provided for @showHiddenPlayers.
  ///
  /// In en, this message translates to:
  /// **'Show hidden players'**
  String get showHiddenPlayers;

  /// No description provided for @monthlyChart.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get monthlyChart;

  /// No description provided for @allTimeChart.
  ///
  /// In en, this message translates to:
  /// **'Last 6 Months'**
  String get allTimeChart;

  /// No description provided for @hoursShort.
  ///
  /// In en, this message translates to:
  /// **'{value}h'**
  String hoursShort(String value);

  /// No description provided for @notificationsOn.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get notificationsOn;

  /// No description provided for @notificationsOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get notificationsOff;

  /// No description provided for @notificationsOnHelp.
  ///
  /// In en, this message translates to:
  /// **'Study Cafe tells you when a focus session or a break ends. To change this, open your phone\'s Settings > Apps > Study Cafe > Notifications.'**
  String get notificationsOnHelp;

  /// No description provided for @notificationsOffHelp.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off. To get a reminder when a session ends, open your phone\'s Settings > Apps > Study Cafe > Notifications and turn them on.'**
  String get notificationsOffHelp;

  /// No description provided for @shareAction.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareAction;

  /// No description provided for @inviteYourCode.
  ///
  /// In en, this message translates to:
  /// **'Your invite code'**
  String get inviteYourCode;

  /// No description provided for @inviteMessageWithCode.
  ///
  /// In en, this message translates to:
  /// **'Start focusing with Study Cafe! Use my code {code} to get +100 points: {link}'**
  String inviteMessageWithCode(String code, String link);

  /// No description provided for @inviteEnterCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Have a friend\'s code?'**
  String get inviteEnterCodeTitle;

  /// No description provided for @inviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCodeHint;

  /// No description provided for @inviteRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get inviteRedeem;

  /// No description provided for @inviteRedeemed.
  ///
  /// In en, this message translates to:
  /// **'🎉 Code accepted! +{points} points'**
  String inviteRedeemed(int points);

  /// No description provided for @inviteCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That code is not valid. Codes have 6 letters and numbers.'**
  String get inviteCodeInvalid;

  /// No description provided for @inviteCodeOwn.
  ///
  /// In en, this message translates to:
  /// **'You can\'t use your own code.'**
  String get inviteCodeOwn;

  /// No description provided for @inviteCodeAlready.
  ///
  /// In en, this message translates to:
  /// **'You have already used an invite code.'**
  String get inviteCodeAlready;

  /// No description provided for @inviteCodeNotFound.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t find that code.'**
  String get inviteCodeNotFound;

  /// No description provided for @inviteSignInRequired.
  ///
  /// In en, this message translates to:
  /// **'Log in to get your invite code and earn points.'**
  String get inviteSignInRequired;

  /// No description provided for @inviteRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'🎉 {count, plural, =1{A friend joined} other{{count} friends joined}} with your code! +{points} points'**
  String inviteRewardEarned(int count, int points);

  /// No description provided for @itemEspresso.
  ///
  /// In en, this message translates to:
  /// **'Espresso'**
  String get itemEspresso;

  /// No description provided for @itemGreenTea.
  ///
  /// In en, this message translates to:
  /// **'Green Tea'**
  String get itemGreenTea;

  /// No description provided for @itemCheesecake.
  ///
  /// In en, this message translates to:
  /// **'Cheesecake'**
  String get itemCheesecake;

  /// No description provided for @giftReceived.
  ///
  /// In en, this message translates to:
  /// **'{name} sent you {item}'**
  String giftReceived(String name, String item);

  /// No description provided for @giftToastMany.
  ///
  /// In en, this message translates to:
  /// **'{count} new treats from friends 🎁'**
  String giftToastMany(int count);

  /// No description provided for @giftToastView.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get giftToastView;

  /// No description provided for @giftsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No treats yet. When a friend sends you one, it will show up here.'**
  String get giftsEmpty;

  /// No description provided for @giftsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get giftsClearAll;

  /// No description provided for @giftsClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all notifications?'**
  String get giftsClearConfirm;

  /// No description provided for @timeJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String timeMinutesAgo(int count);

  /// No description provided for @timeHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String timeHoursAgo(int count);

  /// No description provided for @timeDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String timeDaysAgo(int count);

  /// No description provided for @sendTreat.
  ///
  /// In en, this message translates to:
  /// **'Send a treat'**
  String get sendTreat;

  /// No description provided for @sendTreatTitle.
  ///
  /// In en, this message translates to:
  /// **'Send a treat to a friend'**
  String get sendTreatTitle;

  /// No description provided for @sendTreatChoose.
  ///
  /// In en, this message translates to:
  /// **'Choose a treat'**
  String get sendTreatChoose;

  /// No description provided for @sendTreatCost.
  ///
  /// In en, this message translates to:
  /// **'{cost} points'**
  String sendTreatCost(int cost);

  /// No description provided for @sendTreatFriends.
  ///
  /// In en, this message translates to:
  /// **'Focusing right now'**
  String get sendTreatFriends;

  /// No description provided for @sendTreatInfo.
  ///
  /// In en, this message translates to:
  /// **'Only friends who are in a focus session right now can receive treats.'**
  String get sendTreatInfo;

  /// No description provided for @sendTreatNobody.
  ///
  /// In en, this message translates to:
  /// **'Nobody is focusing right now. Check back in a bit!'**
  String get sendTreatNobody;

  /// No description provided for @sendTreatMinLeft.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min left'**
  String sendTreatMinLeft(int minutes);

  /// No description provided for @sendTreatSend.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendTreatSend;

  /// No description provided for @sendTreatSent.
  ///
  /// In en, this message translates to:
  /// **'{emoji} Sent to {name}!'**
  String sendTreatSent(String emoji, String name);

  /// No description provided for @sendTreatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'They just stopped focusing, or you already sent them a treat a moment ago.'**
  String get sendTreatUnavailable;

  /// No description provided for @sendTreatSignIn.
  ///
  /// In en, this message translates to:
  /// **'Log in to send treats to friends.'**
  String get sendTreatSignIn;

  /// No description provided for @sendTreatRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get sendTreatRefresh;

  /// No description provided for @focusStatusTitle.
  ///
  /// In en, this message translates to:
  /// **'Show when I\'m focusing'**
  String get focusStatusTitle;

  /// No description provided for @focusStatusHelp.
  ///
  /// In en, this message translates to:
  /// **'Friends can send you treats while a focus session is running. Other users can see your display name and when your session ends.'**
  String get focusStatusHelp;

  /// No description provided for @focusStatusSignIn.
  ///
  /// In en, this message translates to:
  /// **'Log in to turn this on.'**
  String get focusStatusSignIn;

  /// No description provided for @authErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get authErrorGeneric;

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in'**
  String get authSignInFailed;

  /// No description provided for @authSignUpFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign up'**
  String get authSignUpFailed;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameRequired;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @signingIn.
  ///
  /// In en, this message translates to:
  /// **'Signing in...'**
  String get signingIn;

  /// No description provided for @signingUp.
  ///
  /// In en, this message translates to:
  /// **'Signing up...'**
  String get signingUp;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @yourEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Your email address'**
  String get yourEmailAddress;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get resetEmailSent;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account?'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteIrreversible.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. All your data will be permanently deleted:'**
  String get deleteIrreversible;

  /// No description provided for @deleteItemStudy.
  ///
  /// In en, this message translates to:
  /// **'All your study data'**
  String get deleteItemStudy;

  /// No description provided for @deleteItemBadges.
  ///
  /// In en, this message translates to:
  /// **'Badges and points you\'ve earned'**
  String get deleteItemBadges;

  /// No description provided for @deleteItemStreak.
  ///
  /// In en, this message translates to:
  /// **'Your streak records'**
  String get deleteItemStreak;

  /// No description provided for @deleteItemCafe.
  ///
  /// In en, this message translates to:
  /// **'Your virtual cafe inventory'**
  String get deleteItemCafe;

  /// No description provided for @deleteConfirmCheckbox.
  ///
  /// In en, this message translates to:
  /// **'I confirm that my account will be permanently deleted'**
  String get deleteConfirmCheckbox;

  /// No description provided for @deleting.
  ///
  /// In en, this message translates to:
  /// **'Deleting account...'**
  String get deleting;

  /// No description provided for @deleteWebHint.
  ///
  /// In en, this message translates to:
  /// **'If the button doesn\'t work, you can delete it on the web:'**
  String get deleteWebHint;

  /// No description provided for @accountDeleted.
  ///
  /// In en, this message translates to:
  /// **'Your account was deleted'**
  String get accountDeleted;

  /// No description provided for @securityCheck.
  ///
  /// In en, this message translates to:
  /// **'Security Check'**
  String get securityCheck;

  /// No description provided for @reauthPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your password again to delete your account'**
  String get reauthPrompt;

  /// No description provided for @guestName.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestName;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'Not signed in'**
  String get notSignedIn;

  /// No description provided for @signInOrSignUp.
  ///
  /// In en, this message translates to:
  /// **'Log In / Sign Up'**
  String get signInOrSignUp;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirm;

  /// No description provided for @leaderboardLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load the leaderboard'**
  String get leaderboardLoadFailed;

  /// No description provided for @leaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nobody is on the leaderboard yet'**
  String get leaderboardEmpty;

  /// No description provided for @leaderboardSignInPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to join the leaderboard'**
  String get leaderboardSignInPrompt;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'🔥 {count}-day streak'**
  String streakDays(int count);

  /// No description provided for @pointsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} pts'**
  String pointsCount(int count);

  /// No description provided for @noStudyData.
  ///
  /// In en, this message translates to:
  /// **'No study data yet'**
  String get noStudyData;

  /// No description provided for @adNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Ad not completed'**
  String get adNotCompleted;

  /// No description provided for @adUnavailable.
  ///
  /// In en, this message translates to:
  /// **'The ad is not available right now'**
  String get adUnavailable;

  /// No description provided for @shareCaption.
  ///
  /// In en, this message translates to:
  /// **'🔥 I\'m focusing with Study Cafe! #StudyCafe #Pomodoro'**
  String get shareCaption;

  /// No description provided for @shareCaptionWithLink.
  ///
  /// In en, this message translates to:
  /// **'🔥 I\'m focusing with Study Cafe! Join me: {link}'**
  String shareCaptionWithLink(String link);

  /// No description provided for @shareSubject.
  ///
  /// In en, this message translates to:
  /// **'I studied with Study Cafe!'**
  String get shareSubject;

  /// No description provided for @shareSummary.
  ///
  /// In en, this message translates to:
  /// **'🎯 I focused for {minutes} minutes today!\n\n🔥 My {streak}-day streak continues\n⭐ I earned {points} points in total\n\nStart focusing with Study Cafe too!\n{link}\n\n#StudyCafe #Pomodoro #StudyGram #Focus'**
  String shareSummary(int minutes, int streak, int points, String link);

  /// No description provided for @shareCardFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not create the card'**
  String get shareCardFailed;

  /// No description provided for @shareCardStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK'**
  String get shareCardStreak;

  /// No description provided for @shareCardPoints.
  ///
  /// In en, this message translates to:
  /// **'POINTS'**
  String get shareCardPoints;

  /// No description provided for @shareCardLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest: {days} days'**
  String shareCardLongest(int days);

  /// No description provided for @inviteBonus.
  ///
  /// In en, this message translates to:
  /// **'You get +200 points for every friend who joins with your code, and they get +100!'**
  String get inviteBonus;

  /// No description provided for @inviteStep1.
  ///
  /// In en, this message translates to:
  /// **'Share your invite code with a friend'**
  String get inviteStep1;

  /// No description provided for @inviteStep2.
  ///
  /// In en, this message translates to:
  /// **'They sign up and enter your code on this screen'**
  String get inviteStep2;

  /// No description provided for @inviteStep3.
  ///
  /// In en, this message translates to:
  /// **'You get +200 points and they get +100!'**
  String get inviteStep3;

  /// No description provided for @inviteMessage.
  ///
  /// In en, this message translates to:
  /// **'Start focusing with Study Cafe! {link}'**
  String inviteMessage(String link);

  /// No description provided for @faqPomodoroQ.
  ///
  /// In en, this message translates to:
  /// **'What is the Pomodoro technique?'**
  String get faqPomodoroQ;

  /// No description provided for @faqPomodoroA.
  ///
  /// In en, this message translates to:
  /// **'A productive study method built on 25 minutes of focus followed by a 5-minute break. After every 4 sessions, take a longer 15-30 minute break.'**
  String get faqPomodoroA;

  /// No description provided for @faqPointsQ.
  ///
  /// In en, this message translates to:
  /// **'How do I earn points?'**
  String get faqPointsQ;

  /// No description provided for @faqPointsA.
  ///
  /// In en, this message translates to:
  /// **'You earn 10 points for every completed Pomodoro session and 2 points for breaks. You can also earn +50 points by watching an ad.'**
  String get faqPointsA;

  /// No description provided for @faqCafeQ.
  ///
  /// In en, this message translates to:
  /// **'What can I do in the virtual cafe?'**
  String get faqCafeQ;

  /// No description provided for @faqCafeA.
  ///
  /// In en, this message translates to:
  /// **'Spend your points on virtual items like coffee, tea and dessert, and set the mood with ambient sounds.'**
  String get faqCafeA;

  /// No description provided for @faqStreakQ.
  ///
  /// In en, this message translates to:
  /// **'How do I keep my streak?'**
  String get faqStreakQ;

  /// No description provided for @faqStreakA.
  ///
  /// In en, this message translates to:
  /// **'Complete at least one Pomodoro session every day to keep your streak going. If you skip a day, it resets.'**
  String get faqStreakA;

  /// No description provided for @faqDataQ.
  ///
  /// In en, this message translates to:
  /// **'Is my data safe?'**
  String get faqDataQ;

  /// No description provided for @faqDataA.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on your device. Log in to join the leaderboard. You can read our privacy policy for details.'**
  String get faqDataA;

  /// No description provided for @faqDeleteQ.
  ///
  /// In en, this message translates to:
  /// **'How do I delete my account?'**
  String get faqDeleteQ;

  /// No description provided for @faqDeleteA.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile → Delete Account, or delete it permanently from the web.'**
  String get faqDeleteA;

  /// No description provided for @helpMoreQuestions.
  ///
  /// In en, this message translates to:
  /// **'Have another question?'**
  String get helpMoreQuestions;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact us: {email}'**
  String contactUs(String email);

  /// No description provided for @onboardFocusTitle.
  ///
  /// In en, this message translates to:
  /// **'Focus'**
  String get onboardFocusTitle;

  /// No description provided for @onboardFocusBody.
  ///
  /// In en, this message translates to:
  /// **'Study efficiently with the Pomodoro technique. 25 minutes of focus, 5 minutes of break.'**
  String get onboardFocusBody;

  /// No description provided for @onboardEarnTitle.
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get onboardEarnTitle;

  /// No description provided for @onboardEarnBody.
  ///
  /// In en, this message translates to:
  /// **'Earn points after every session. Buy coffee, tea and dessert in your virtual cafe.'**
  String get onboardEarnBody;

  /// No description provided for @onboardAchieveTitle.
  ///
  /// In en, this message translates to:
  /// **'Achieve'**
  String get onboardAchieveTitle;

  /// No description provided for @onboardAchieveBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock badges, keep your streak alive and track your stats.'**
  String get onboardAchieveBody;

  /// No description provided for @notifFocusDone.
  ///
  /// In en, this message translates to:
  /// **'Focus session done, time for a break! ☕'**
  String get notifFocusDone;

  /// No description provided for @notifBreakDone.
  ///
  /// In en, this message translates to:
  /// **'Break is over, time to focus!'**
  String get notifBreakDone;

  /// No description provided for @shareCardFocused.
  ///
  /// In en, this message translates to:
  /// **'FOCUSED'**
  String get shareCardFocused;

  /// No description provided for @shareCardMinutes.
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get shareCardMinutes;

  /// No description provided for @shareCardMyStreak.
  ///
  /// In en, this message translates to:
  /// **'MY STREAK'**
  String get shareCardMyStreak;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @daysUnit.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysUnit;

  /// No description provided for @adRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'🎉 You earned +50 points!'**
  String get adRewardEarned;

  /// No description provided for @shareRewardEarned.
  ///
  /// In en, this message translates to:
  /// **'🎉 You earned +25 points for sharing!'**
  String get shareRewardEarned;

  /// No description provided for @shareYourSuccess.
  ///
  /// In en, this message translates to:
  /// **'Share Your Achievement'**
  String get shareYourSuccess;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Account Permanently'**
  String get deleteAccountPermanently;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'Invite Your Friends'**
  String get inviteTitle;

  /// No description provided for @howItWorks.
  ///
  /// In en, this message translates to:
  /// **'How It Works'**
  String get howItWorks;

  /// No description provided for @onboardNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboardNext;

  /// No description provided for @onboardSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboardSkip;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Gamified Study Cafe'**
  String get splashTagline;

  /// No description provided for @rewardedAdHint.
  ///
  /// In en, this message translates to:
  /// **'Earn +50 points'**
  String get rewardedAdHint;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{count}m'**
  String minutesShort(int count);

  /// No description provided for @consentTitle.
  ///
  /// In en, this message translates to:
  /// **'Help us improve Study Cafe'**
  String get consentTitle;

  /// No description provided for @consentBody.
  ///
  /// In en, this message translates to:
  /// **'With your permission, Study Cafe collects anonymous usage statistics and crash reports (Google Firebase Analytics and Crashlytics). They include things like which screens are used, your device model and Android version, and an app instance ID. They never include your name, email or study content. This data is processed on Google servers outside Türkiye. Nothing is collected until you choose.'**
  String get consentBody;

  /// No description provided for @consentFootnote.
  ///
  /// In en, this message translates to:
  /// **'Either choice keeps every feature working. You can change it any time in Settings. Ads are handled separately by Google AdMob.'**
  String get consentFootnote;

  /// No description provided for @consentAccept.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get consentAccept;

  /// No description provided for @consentDecline.
  ///
  /// In en, this message translates to:
  /// **'Do not allow'**
  String get consentDecline;

  /// No description provided for @consentPrivacyLink.
  ///
  /// In en, this message translates to:
  /// **'Read the privacy policy'**
  String get consentPrivacyLink;

  /// No description provided for @analyticsConsentTitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymous usage and crash data'**
  String get analyticsConsentTitle;

  /// No description provided for @analyticsConsentHelp.
  ///
  /// In en, this message translates to:
  /// **'Helps us fix problems. Off means nothing is sent.'**
  String get analyticsConsentHelp;

  /// No description provided for @exportData.
  ///
  /// In en, this message translates to:
  /// **'Export my data'**
  String get exportData;

  /// No description provided for @exportDataHelp.
  ///
  /// In en, this message translates to:
  /// **'Saves a copy of your progress and account details as a JSON file.'**
  String get exportDataHelp;

  /// No description provided for @exportDataFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not export your data.'**
  String get exportDataFailed;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheHelp.
  ///
  /// In en, this message translates to:
  /// **'Removes temporary files such as share images. Your progress, points and settings are kept.'**
  String get clearCacheHelp;

  /// No description provided for @cacheCleared.
  ///
  /// In en, this message translates to:
  /// **'Cache cleared.'**
  String get cacheCleared;
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
