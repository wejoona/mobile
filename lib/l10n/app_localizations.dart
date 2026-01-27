import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
    Locale('fr'),
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'JoonaPay'**
  String get appName;

  /// Home navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navigation_home;

  /// Settings navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navigation_settings;

  /// Send navigation label
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get navigation_send;

  /// Receive navigation label
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get navigation_receive;

  /// Transactions navigation label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navigation_transactions;

  /// Services navigation label
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get navigation_services;

  /// Continue action button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get action_continue;

  /// Cancel action button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get action_cancel;

  /// Confirm action button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get action_confirm;

  /// Back action button
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get action_back;

  /// Submit action button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get action_submit;

  /// Done action button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get action_done;

  /// Save action button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get action_save;

  /// Edit action button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get action_edit;

  /// Login label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get auth_login;

  /// Verify label
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get auth_verify;

  /// Enter OTP label
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get auth_enterOtp;

  /// Phone number label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phoneNumber;

  /// PIN label
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get auth_pin;

  /// Logout label
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get auth_logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get auth_logoutConfirm;

  /// Wallet balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get wallet_balance;

  /// Send money label
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get wallet_sendMoney;

  /// Receive money label
  ///
  /// In en, this message translates to:
  /// **'Receive Money'**
  String get wallet_receiveMoney;

  /// Transaction history label
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get wallet_transactionHistory;

  /// Available balance label
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get wallet_availableBalance;

  /// Profile settings label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get settings_profile;

  /// Profile settings description
  ///
  /// In en, this message translates to:
  /// **'Manage your personal information'**
  String get settings_profileDescription;

  /// Security settings section label
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settings_security;

  /// Security settings label
  ///
  /// In en, this message translates to:
  /// **'Security Settings'**
  String get settings_securitySettings;

  /// Security settings description
  ///
  /// In en, this message translates to:
  /// **'PIN, 2FA, biometrics'**
  String get settings_securityDescription;

  /// Language settings label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// Theme settings label
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settings_theme;

  /// Notifications settings label
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// Preferences section label
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get settings_preferences;

  /// Default currency label
  ///
  /// In en, this message translates to:
  /// **'Default Currency'**
  String get settings_defaultCurrency;

  /// Support section label
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get settings_support;

  /// Help and support label
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settings_helpSupport;

  /// Help and support description
  ///
  /// In en, this message translates to:
  /// **'FAQs, chat, contact'**
  String get settings_helpDescription;

  /// KYC verification label
  ///
  /// In en, this message translates to:
  /// **'KYC Verification'**
  String get settings_kycVerification;

  /// Transaction limits label
  ///
  /// In en, this message translates to:
  /// **'Transaction Limits'**
  String get settings_transactionLimits;

  /// Transaction limits description
  ///
  /// In en, this message translates to:
  /// **'View & increase limits'**
  String get settings_limitsDescription;

  /// Refer and earn label
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get settings_referEarn;

  /// Refer and earn description
  ///
  /// In en, this message translates to:
  /// **'Invite friends and earn rewards'**
  String get settings_referDescription;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// KYC verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get kyc_verified;

  /// KYC pending status
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get kyc_pending;

  /// KYC rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected - Retry'**
  String get kyc_rejected;

  /// KYC not started status
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get kyc_notStarted;

  /// Transaction sent label
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get transaction_sent;

  /// Transaction received label
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transaction_received;

  /// Transaction pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get transaction_pending;

  /// Transaction failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get transaction_failed;

  /// Transaction completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get transaction_completed;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get error_network;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// French language name
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get language_french;

  /// Select language label
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get language_selectLanguage;

  /// Change language label
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get language_changeLanguage;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
