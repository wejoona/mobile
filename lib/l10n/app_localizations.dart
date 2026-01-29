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

  /// Copy action button
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get action_copy;

  /// Share action button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get action_share;

  /// Scan action button
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get action_scan;

  /// Retry action button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get action_retry;

  /// Clear all filters action
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get action_clearAll;

  /// Clear filters button
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get action_clearFilters;

  /// Clear action button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get action_clear;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get action_tryAgain;

  /// Remove action button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get action_remove;

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

  /// Logout button label
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get auth_logout;

  /// Logout confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get auth_logoutConfirm;

  /// Welcome back message
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get auth_welcomeBack;

  /// Create wallet subtitle
  ///
  /// In en, this message translates to:
  /// **'Create your USDC wallet'**
  String get auth_createWallet;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_createAccount;

  /// Already have account prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get auth_alreadyHaveAccount;

  /// Don't have account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get auth_dontHaveAccount;

  /// Sign in link
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get auth_signIn;

  /// Sign up link
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get auth_signUp;

  /// Country label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get auth_country;

  /// Select country title
  ///
  /// In en, this message translates to:
  /// **'Select Country'**
  String get auth_selectCountry;

  /// Search country placeholder
  ///
  /// In en, this message translates to:
  /// **'Search country...'**
  String get auth_searchCountry;

  /// Enter digits helper text
  ///
  /// In en, this message translates to:
  /// **'Enter {count} digits'**
  String auth_enterDigits(int count);

  /// Terms agreement prompt
  ///
  /// In en, this message translates to:
  /// **'By continuing, you agree to our'**
  String get auth_termsPrompt;

  /// Terms of service link
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get auth_termsOfService;

  /// Privacy policy link
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get auth_privacyPolicy;

  /// And conjunction
  ///
  /// In en, this message translates to:
  /// **' and '**
  String get auth_and;

  /// Secure login title
  ///
  /// In en, this message translates to:
  /// **'Secure Login'**
  String get auth_secureLogin;

  /// OTP verification message
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {phone}'**
  String auth_otpMessage(String phone);

  /// Waiting for SMS indicator
  ///
  /// In en, this message translates to:
  /// **'Waiting for SMS...'**
  String get auth_waitingForSms;

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get auth_resendCode;

  /// Invalid phone number error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid phone number'**
  String get auth_phoneInvalid;

  /// OTP code field label
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get auth_otp;

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get auth_resendOtp;

  /// Invalid OTP error message
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP code. Please try again.'**
  String get auth_error_invalidOtp;

  /// Login welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get login_welcomeBack;

  /// Login phone input subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to login'**
  String get login_enterPhone;

  /// Remember device checkbox
  ///
  /// In en, this message translates to:
  /// **'Remember this device'**
  String get login_rememberPhone;

  /// No account prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_noAccount;

  /// Create account link
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get login_createAccount;

  /// OTP verification title
  ///
  /// In en, this message translates to:
  /// **'Verify your code'**
  String get login_verifyCode;

  /// Code sent message
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {countryCode} {phone}'**
  String login_codeSentTo(String countryCode, String phone);

  /// Resend code button
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get login_resendCode;

  /// Resend countdown
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String login_resendIn(int seconds);

  /// Verifying message
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get login_verifying;

  /// PIN entry title
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get login_enterPin;

  /// PIN entry subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN to access your wallet'**
  String get login_pinSubtitle;

  /// Forgot PIN link
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get login_forgotPin;

  /// PIN attempts remaining
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt remaining} other{{count} attempts remaining}}'**
  String login_attemptsRemaining(int count);

  /// Account locked title
  ///
  /// In en, this message translates to:
  /// **'Account Locked'**
  String get login_accountLocked;

  /// Account locked message
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Your account has been locked for 15 minutes for security.'**
  String get login_lockedMessage;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// Continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get common_continue;

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

  /// Total balance label
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get wallet_totalBalance;

  /// USD balance label
  ///
  /// In en, this message translates to:
  /// **'USD'**
  String get wallet_usdBalance;

  /// USDC balance label
  ///
  /// In en, this message translates to:
  /// **'USDC'**
  String get wallet_usdcBalance;

  /// Fiat balance subtitle
  ///
  /// In en, this message translates to:
  /// **'Fiat Balance'**
  String get wallet_fiatBalance;

  /// Stablecoin subtitle
  ///
  /// In en, this message translates to:
  /// **'Stablecoin'**
  String get wallet_stablecoin;

  /// Create wallet button
  ///
  /// In en, this message translates to:
  /// **'Create Wallet'**
  String get wallet_createWallet;

  /// No wallet found title
  ///
  /// In en, this message translates to:
  /// **'No Wallet Found'**
  String get wallet_noWalletFound;

  /// Create wallet message
  ///
  /// In en, this message translates to:
  /// **'Create your wallet to start sending and receiving money'**
  String get wallet_createWalletMessage;

  /// Loading wallet message
  ///
  /// In en, this message translates to:
  /// **'Loading wallet...'**
  String get wallet_loadingWallet;

  /// Title for wallet activation card
  ///
  /// In en, this message translates to:
  /// **'Activate Your Wallet'**
  String get wallet_activateTitle;

  /// Description for wallet activation
  ///
  /// In en, this message translates to:
  /// **'Set up your USDC wallet to start sending and receiving money instantly'**
  String get wallet_activateDescription;

  /// Button to activate wallet
  ///
  /// In en, this message translates to:
  /// **'Activate Wallet'**
  String get wallet_activateButton;

  /// Loading message during wallet activation
  ///
  /// In en, this message translates to:
  /// **'Activating your wallet...'**
  String get wallet_activating;

  /// Error message when wallet activation fails
  ///
  /// In en, this message translates to:
  /// **'Failed to activate wallet. Please try again.'**
  String get wallet_activateFailed;

  /// Welcome back greeting
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get home_welcomeBack;

  /// All services link
  ///
  /// In en, this message translates to:
  /// **'All Services'**
  String get home_allServices;

  /// View all features subtitle
  ///
  /// In en, this message translates to:
  /// **'View all available features'**
  String get home_viewAllFeatures;

  /// Recent transactions title
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get home_recentTransactions;

  /// No transactions yet title
  ///
  /// In en, this message translates to:
  /// **'No Transactions Yet'**
  String get home_noTransactionsYet;

  /// Transactions will appear message
  ///
  /// In en, this message translates to:
  /// **'Your recent transactions will appear here'**
  String get home_transactionsWillAppear;

  /// Balance label on home screen
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get home_balance;

  /// Send money page title
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get send_title;

  /// To phone tab
  ///
  /// In en, this message translates to:
  /// **'To Phone'**
  String get send_toPhone;

  /// To wallet tab
  ///
  /// In en, this message translates to:
  /// **'To Wallet'**
  String get send_toWallet;

  /// Recent contacts label
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get send_recent;

  /// Recipient label
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get send_recipient;

  /// Saved recipients button
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get send_saved;

  /// Contacts button
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get send_contacts;

  /// Amount in USD label
  ///
  /// In en, this message translates to:
  /// **'Amount (USD)'**
  String get send_amountUsd;

  /// Wallet address label
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get send_walletAddress;

  /// Network info message
  ///
  /// In en, this message translates to:
  /// **'External transfers may take a few minutes. Small fees apply.'**
  String get send_networkInfo;

  /// Transfer success title
  ///
  /// In en, this message translates to:
  /// **'Transfer Successful!'**
  String get send_transferSuccess;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get send_invalidAmount;

  /// Insufficient balance error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get send_insufficientBalance;

  /// Address format error
  ///
  /// In en, this message translates to:
  /// **'Address must start with 0x'**
  String get send_addressMustStartWith0x;

  /// Address length error
  ///
  /// In en, this message translates to:
  /// **'Address must be exactly 42 characters'**
  String get send_addressLength;

  /// Invalid Ethereum address error
  ///
  /// In en, this message translates to:
  /// **'Invalid Ethereum address format'**
  String get send_invalidEthereumAddress;

  /// Save recipient dialog title
  ///
  /// In en, this message translates to:
  /// **'Save Recipient?'**
  String get send_saveRecipientPrompt;

  /// Save recipient dialog message
  ///
  /// In en, this message translates to:
  /// **'Would you like to save this recipient for future transfers?'**
  String get send_saveRecipientMessage;

  /// Not now button
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get send_notNow;

  /// Save recipient input title
  ///
  /// In en, this message translates to:
  /// **'Save Recipient'**
  String get send_saveRecipientTitle;

  /// Enter recipient name prompt
  ///
  /// In en, this message translates to:
  /// **'Enter a name for this recipient'**
  String get send_enterRecipientName;

  /// Name input placeholder
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get send_name;

  /// Recipient saved success message
  ///
  /// In en, this message translates to:
  /// **'Recipient saved'**
  String get send_recipientSaved;

  /// Failed to save recipient error
  ///
  /// In en, this message translates to:
  /// **'Failed to save recipient'**
  String get send_failedToSaveRecipient;

  /// Select saved recipient sheet title
  ///
  /// In en, this message translates to:
  /// **'Select Saved Recipient'**
  String get send_selectSavedRecipient;

  /// Contact picker title
  ///
  /// In en, this message translates to:
  /// **'Select Contact'**
  String get send_selectContact;

  /// Search recipients placeholder
  ///
  /// In en, this message translates to:
  /// **'Search recipients...'**
  String get send_searchRecipients;

  /// Search contacts placeholder
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get send_searchContacts;

  /// No saved recipients message
  ///
  /// In en, this message translates to:
  /// **'No saved recipients'**
  String get send_noSavedRecipients;

  /// Failed to load recipients error
  ///
  /// In en, this message translates to:
  /// **'Failed to load recipients'**
  String get send_failedToLoadRecipients;

  /// JoonaPay user badge
  ///
  /// In en, this message translates to:
  /// **'JoonaPay user'**
  String get send_joonaPayUser;

  /// Too many PIN attempts error
  ///
  /// In en, this message translates to:
  /// **'Too many incorrect attempts. Please try again later.'**
  String get send_tooManyAttempts;

  /// Receive USDC page title
  ///
  /// In en, this message translates to:
  /// **'Receive USDC'**
  String get receive_title;

  /// Receive USDC info title
  ///
  /// In en, this message translates to:
  /// **'Receive USDC'**
  String get receive_receiveUsdc;

  /// Receive USDC info
  ///
  /// In en, this message translates to:
  /// **'Share your address to receive USDC'**
  String get receive_onlySendUsdc;

  /// Your wallet address label
  ///
  /// In en, this message translates to:
  /// **'Your Wallet Address'**
  String get receive_yourWalletAddress;

  /// Wallet address not available message
  ///
  /// In en, this message translates to:
  /// **'Wallet address not available'**
  String get receive_walletNotAvailable;

  /// Address copied success message
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard (auto-clears in 60s)'**
  String get receive_addressCopied;

  /// Share wallet address message
  ///
  /// In en, this message translates to:
  /// **'Send USDC to my JoonaPay wallet:\n\n{address}'**
  String receive_shareMessage(String address);

  /// Share subject
  ///
  /// In en, this message translates to:
  /// **'My USDC Wallet Address'**
  String get receive_shareSubject;

  /// Important warning label
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get receive_important;

  /// Important warning message
  ///
  /// In en, this message translates to:
  /// **'Only send USDC to this address. Sending other tokens may result in permanent loss of funds.'**
  String get receive_warningMessage;

  /// Transactions page title
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions_title;

  /// Search transactions placeholder
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get transactions_searchPlaceholder;

  /// No results found title
  ///
  /// In en, this message translates to:
  /// **'No Results Found'**
  String get transactions_noResultsFound;

  /// No transactions title
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get transactions_noTransactions;

  /// Adjust filters message
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search query to find what you\'re looking for.'**
  String get transactions_adjustFilters;

  /// Transaction history message
  ///
  /// In en, this message translates to:
  /// **'Your transaction history will appear here once you make your first deposit or transfer.'**
  String get transactions_historyMessage;

  /// Something went wrong title
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get transactions_somethingWentWrong;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get transactions_today;

  /// Yesterday label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get transactions_yesterday;

  /// Deposit transaction type
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get transactions_deposit;

  /// Withdrawal transaction type
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get transactions_withdrawal;

  /// Transfer received transaction type
  ///
  /// In en, this message translates to:
  /// **'Transfer Received'**
  String get transactions_transferReceived;

  /// Transfer sent transaction type
  ///
  /// In en, this message translates to:
  /// **'Transfer Sent'**
  String get transactions_transferSent;

  /// Mobile money deposit subtitle
  ///
  /// In en, this message translates to:
  /// **'Mobile Money Deposit'**
  String get transactions_mobileMoneyDeposit;

  /// Mobile money withdrawal subtitle
  ///
  /// In en, this message translates to:
  /// **'Mobile Money Withdrawal'**
  String get transactions_mobileMoneyWithdrawal;

  /// From JoonaPay user subtitle
  ///
  /// In en, this message translates to:
  /// **'From JoonaPay User'**
  String get transactions_fromJoonaPayUser;

  /// External wallet subtitle
  ///
  /// In en, this message translates to:
  /// **'External Wallet'**
  String get transactions_externalWallet;

  /// Deposits filter
  ///
  /// In en, this message translates to:
  /// **'Deposits'**
  String get transactions_deposits;

  /// Withdrawals filter
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get transactions_withdrawals;

  /// Received filter
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get transactions_receivedFilter;

  /// Sent filter
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get transactions_sentFilter;

  /// Services page title
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services_title;

  /// Core services section
  ///
  /// In en, this message translates to:
  /// **'Core Services'**
  String get services_coreServices;

  /// Financial services section
  ///
  /// In en, this message translates to:
  /// **'Financial Services'**
  String get services_financialServices;

  /// Bills and payments section
  ///
  /// In en, this message translates to:
  /// **'Bills & Payments'**
  String get services_billsPayments;

  /// Tools and analytics section
  ///
  /// In en, this message translates to:
  /// **'Tools & Analytics'**
  String get services_toolsAnalytics;

  /// Send money service
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get services_sendMoney;

  /// Send money description
  ///
  /// In en, this message translates to:
  /// **'Transfer to any wallet'**
  String get services_sendMoneyDesc;

  /// Receive money service
  ///
  /// In en, this message translates to:
  /// **'Receive Money'**
  String get services_receiveMoney;

  /// Receive money description
  ///
  /// In en, this message translates to:
  /// **'Get your wallet address'**
  String get services_receiveMoneyDesc;

  /// Request money service
  ///
  /// In en, this message translates to:
  /// **'Request Money'**
  String get services_requestMoney;

  /// Request money description
  ///
  /// In en, this message translates to:
  /// **'Create payment request'**
  String get services_requestMoneyDesc;

  /// Scan QR service
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get services_scanQr;

  /// Scan QR description
  ///
  /// In en, this message translates to:
  /// **'Scan to pay or receive'**
  String get services_scanQrDesc;

  /// Recipients service
  ///
  /// In en, this message translates to:
  /// **'Recipients'**
  String get services_recipients;

  /// Recipients description
  ///
  /// In en, this message translates to:
  /// **'Manage saved contacts'**
  String get services_recipientsDesc;

  /// Scheduled transfers service
  ///
  /// In en, this message translates to:
  /// **'Scheduled Transfers'**
  String get services_scheduledTransfers;

  /// Scheduled transfers description
  ///
  /// In en, this message translates to:
  /// **'Manage recurring payments'**
  String get services_scheduledTransfersDesc;

  /// Virtual card service
  ///
  /// In en, this message translates to:
  /// **'Virtual Card'**
  String get services_virtualCard;

  /// Virtual card description
  ///
  /// In en, this message translates to:
  /// **'Online shopping card'**
  String get services_virtualCardDesc;

  /// Savings goals service
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get services_savingsGoals;

  /// Savings goals description
  ///
  /// In en, this message translates to:
  /// **'Track your savings'**
  String get services_savingsGoalsDesc;

  /// Budget service
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get services_budget;

  /// Budget description
  ///
  /// In en, this message translates to:
  /// **'Manage spending limits'**
  String get services_budgetDesc;

  /// Currency converter service
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get services_currencyConverter;

  /// Currency converter description
  ///
  /// In en, this message translates to:
  /// **'Convert currencies'**
  String get services_currencyConverterDesc;

  /// Bill payments service
  ///
  /// In en, this message translates to:
  /// **'Bill Payments'**
  String get services_billPayments;

  /// Bill payments description
  ///
  /// In en, this message translates to:
  /// **'Pay utility bills'**
  String get services_billPaymentsDesc;

  /// Buy airtime service
  ///
  /// In en, this message translates to:
  /// **'Buy Airtime'**
  String get services_buyAirtime;

  /// Buy airtime description
  ///
  /// In en, this message translates to:
  /// **'Mobile top-up'**
  String get services_buyAirtimeDesc;

  /// Split bills service
  ///
  /// In en, this message translates to:
  /// **'Split Bills'**
  String get services_splitBills;

  /// Split bills description
  ///
  /// In en, this message translates to:
  /// **'Share expenses'**
  String get services_splitBillsDesc;

  /// Analytics service
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get services_analytics;

  /// Analytics description
  ///
  /// In en, this message translates to:
  /// **'View spending insights'**
  String get services_analyticsDesc;

  /// Referrals service
  ///
  /// In en, this message translates to:
  /// **'Referrals'**
  String get services_referrals;

  /// Referrals description
  ///
  /// In en, this message translates to:
  /// **'Invite and earn'**
  String get services_referralsDesc;

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

  /// Select theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get settings_selectTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settings_themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settings_themeDark;

  /// System theme option (follows device)
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settings_themeSystem;

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

  /// Devices screen title
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get settings_devices;

  /// Devices screen description
  ///
  /// In en, this message translates to:
  /// **'Manage devices that have access to your account. Revoke access from any device.'**
  String get settings_devicesDescription;

  /// Current device badge
  ///
  /// In en, this message translates to:
  /// **'This device'**
  String get settings_thisDevice;

  /// Last active label
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get settings_lastActive;

  /// Login count label
  ///
  /// In en, this message translates to:
  /// **'Logins'**
  String get settings_loginCount;

  /// Times unit
  ///
  /// In en, this message translates to:
  /// **'times'**
  String get settings_times;

  /// Last IP address label
  ///
  /// In en, this message translates to:
  /// **'Last IP'**
  String get settings_lastIp;

  /// Trust device button
  ///
  /// In en, this message translates to:
  /// **'Trust Device'**
  String get settings_trustDevice;

  /// Remove device button
  ///
  /// In en, this message translates to:
  /// **'Remove Device'**
  String get settings_removeDevice;

  /// Remove device confirmation message
  ///
  /// In en, this message translates to:
  /// **'This device will be logged out and will need to authenticate again to access your account.'**
  String get settings_removeDeviceConfirm;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Devices Found'**
  String get settings_noDevices;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any registered devices yet.'**
  String get settings_noDevicesDescription;

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

  /// KYC page title
  ///
  /// In en, this message translates to:
  /// **'Identity Verification'**
  String get kyc_title;

  /// Document type selection title
  ///
  /// In en, this message translates to:
  /// **'Select Document Type'**
  String get kyc_selectDocumentType;

  /// Document type selection description
  ///
  /// In en, this message translates to:
  /// **'Choose the type of document you\'d like to verify with'**
  String get kyc_selectDocumentType_description;

  /// National ID document type
  ///
  /// In en, this message translates to:
  /// **'National ID Card'**
  String get kyc_documentType_nationalId;

  /// National ID document description
  ///
  /// In en, this message translates to:
  /// **'Government-issued ID card'**
  String get kyc_documentType_nationalId_description;

  /// Passport document type
  ///
  /// In en, this message translates to:
  /// **'Passport'**
  String get kyc_documentType_passport;

  /// Passport document description
  ///
  /// In en, this message translates to:
  /// **'International travel document'**
  String get kyc_documentType_passport_description;

  /// Driver's license document type
  ///
  /// In en, this message translates to:
  /// **'Driver\'s License'**
  String get kyc_documentType_driversLicense;

  /// Driver's license document description
  ///
  /// In en, this message translates to:
  /// **'Government-issued driver\'s license'**
  String get kyc_documentType_driversLicense_description;

  /// Front side capture guidance
  ///
  /// In en, this message translates to:
  /// **'Align the front of your document within the frame'**
  String get kyc_capture_frontSide_guidance;

  /// Back side capture guidance
  ///
  /// In en, this message translates to:
  /// **'Align the back of your document within the frame'**
  String get kyc_capture_backSide_guidance;

  /// National ID capture instructions
  ///
  /// In en, this message translates to:
  /// **'Position your ID card flat and well-lit within the frame'**
  String get kyc_capture_nationalIdInstructions;

  /// Passport capture instructions
  ///
  /// In en, this message translates to:
  /// **'Position your passport photo page within the frame'**
  String get kyc_capture_passportInstructions;

  /// Driver's license capture instructions
  ///
  /// In en, this message translates to:
  /// **'Position your driver\'s license flat within the frame'**
  String get kyc_capture_driversLicenseInstructions;

  /// Back side capture instructions
  ///
  /// In en, this message translates to:
  /// **'Now capture the back side of your document'**
  String get kyc_capture_backInstructions;

  /// Image quality check message
  ///
  /// In en, this message translates to:
  /// **'Checking image quality...'**
  String get kyc_checkingQuality;

  /// Review image screen title
  ///
  /// In en, this message translates to:
  /// **'Review Image'**
  String get kyc_reviewImage;

  /// Retake photo button
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get kyc_retake;

  /// Accept photo button
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get kyc_accept;

  /// Generic image quality error
  ///
  /// In en, this message translates to:
  /// **'Image quality is not acceptable. Please try again.'**
  String get kyc_error_imageQuality;

  /// Blurry image error
  ///
  /// In en, this message translates to:
  /// **'Image is too blurry. Hold your phone steady and try again.'**
  String get kyc_error_imageBlurry;

  /// Glare detected error
  ///
  /// In en, this message translates to:
  /// **'Too much glare detected. Avoid direct light and try again.'**
  String get kyc_error_imageGlare;

  /// Image too dark error
  ///
  /// In en, this message translates to:
  /// **'Image is too dark. Use better lighting and try again.'**
  String get kyc_error_imageTooDark;

  /// Pending status title
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get kyc_status_pending_title;

  /// Pending status description
  ///
  /// In en, this message translates to:
  /// **'Complete your identity verification to unlock higher limits and all features.'**
  String get kyc_status_pending_description;

  /// Submitted status title
  ///
  /// In en, this message translates to:
  /// **'Verification In Progress'**
  String get kyc_status_submitted_title;

  /// Submitted status description
  ///
  /// In en, this message translates to:
  /// **'Your documents are being reviewed. This usually takes 1-2 business days.'**
  String get kyc_status_submitted_description;

  /// Approved status title
  ///
  /// In en, this message translates to:
  /// **'Verification Complete'**
  String get kyc_status_approved_title;

  /// Approved status description
  ///
  /// In en, this message translates to:
  /// **'Your identity has been verified. You now have access to all features!'**
  String get kyc_status_approved_description;

  /// Rejected status title
  ///
  /// In en, this message translates to:
  /// **'Verification Failed'**
  String get kyc_status_rejected_title;

  /// Rejected status description
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify your documents. Please review the reason below and try again.'**
  String get kyc_status_rejected_description;

  /// Additional info needed title
  ///
  /// In en, this message translates to:
  /// **'Additional Information Needed'**
  String get kyc_status_additionalInfo_title;

  /// Additional info needed description
  ///
  /// In en, this message translates to:
  /// **'Please provide additional information to complete your verification.'**
  String get kyc_status_additionalInfo_description;

  /// Rejection reason label
  ///
  /// In en, this message translates to:
  /// **'Rejection Reason'**
  String get kyc_rejectionReason;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get kyc_tryAgain;

  /// Start verification button
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get kyc_startVerification;

  /// Security info title
  ///
  /// In en, this message translates to:
  /// **'Your Data is Secure'**
  String get kyc_info_security_title;

  /// Security info description
  ///
  /// In en, this message translates to:
  /// **'All documents are encrypted and securely stored'**
  String get kyc_info_security_description;

  /// Time info title
  ///
  /// In en, this message translates to:
  /// **'Quick Process'**
  String get kyc_info_time_title;

  /// Time info description
  ///
  /// In en, this message translates to:
  /// **'Verification usually takes 1-2 business days'**
  String get kyc_info_time_description;

  /// Documents info title
  ///
  /// In en, this message translates to:
  /// **'Documents Needed'**
  String get kyc_info_documents_title;

  /// Documents info description
  ///
  /// In en, this message translates to:
  /// **'Valid government-issued ID or passport'**
  String get kyc_info_documents_description;

  /// Review documents title
  ///
  /// In en, this message translates to:
  /// **'Review Documents'**
  String get kyc_reviewDocuments;

  /// Review screen description
  ///
  /// In en, this message translates to:
  /// **'Review your captured documents before submitting for verification'**
  String get kyc_review_description;

  /// Documents section label
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get kyc_review_documents;

  /// Document front label
  ///
  /// In en, this message translates to:
  /// **'Document Front'**
  String get kyc_review_documentFront;

  /// Document back label
  ///
  /// In en, this message translates to:
  /// **'Document Back'**
  String get kyc_review_documentBack;

  /// Selfie section label
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get kyc_review_selfie;

  /// Your selfie label
  ///
  /// In en, this message translates to:
  /// **'Your Selfie'**
  String get kyc_review_yourSelfie;

  /// Submit button label
  ///
  /// In en, this message translates to:
  /// **'Submit for Verification'**
  String get kyc_submitForVerification;

  /// Selfie capture title
  ///
  /// In en, this message translates to:
  /// **'Take a Selfie'**
  String get kyc_selfie_title;

  /// Selfie capture guidance
  ///
  /// In en, this message translates to:
  /// **'Position your face in the oval frame'**
  String get kyc_selfie_guidance;

  /// Selfie liveness hint
  ///
  /// In en, this message translates to:
  /// **'Make sure you\'re in a well-lit area'**
  String get kyc_selfie_livenessHint;

  /// Selfie capture instructions
  ///
  /// In en, this message translates to:
  /// **'Look straight at the camera and keep your face within the frame'**
  String get kyc_selfie_instructions;

  /// Review selfie title
  ///
  /// In en, this message translates to:
  /// **'Review Selfie'**
  String get kyc_reviewSelfie;

  /// Submission success title
  ///
  /// In en, this message translates to:
  /// **'Verification Submitted'**
  String get kyc_submitted_title;

  /// Submission success description
  ///
  /// In en, this message translates to:
  /// **'Thank you! Your documents have been submitted for verification. We\'ll notify you once the review is complete.'**
  String get kyc_submitted_description;

  /// Time estimate for verification
  ///
  /// In en, this message translates to:
  /// **'Verification usually takes 1-2 business days'**
  String get kyc_submitted_timeEstimate;

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

  /// Failed to load balance error
  ///
  /// In en, this message translates to:
  /// **'Failed to load balance'**
  String get error_failedToLoadBalance;

  /// Failed to load transactions error
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions'**
  String get error_failedToLoadTransactions;

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

  /// Primary currency section label
  ///
  /// In en, this message translates to:
  /// **'Primary Currency'**
  String get currency_primary;

  /// Reference currency section label
  ///
  /// In en, this message translates to:
  /// **'Reference Currency'**
  String get currency_reference;

  /// Reference currency description
  ///
  /// In en, this message translates to:
  /// **'Displays local currency equivalent below your USDC balance for reference only. Exchange rates are approximate.'**
  String get currency_referenceDescription;

  /// Show reference currency toggle label
  ///
  /// In en, this message translates to:
  /// **'Show Local Currency'**
  String get currency_showReference;

  /// Show reference currency toggle description
  ///
  /// In en, this message translates to:
  /// **'Display approximate local currency value below USDC amounts'**
  String get currency_showReferenceDescription;

  /// Currency preview section label
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get currency_preview;

  /// Active sessions screen title
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get settings_activeSessions;

  /// Current session badge
  ///
  /// In en, this message translates to:
  /// **'Current session'**
  String get sessions_currentSession;

  /// Unknown location placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get sessions_unknownLocation;

  /// Unknown IP placeholder
  ///
  /// In en, this message translates to:
  /// **'Unknown IP'**
  String get sessions_unknownIP;

  /// Last active label
  ///
  /// In en, this message translates to:
  /// **'Last active'**
  String get sessions_lastActive;

  /// Revoke session dialog title
  ///
  /// In en, this message translates to:
  /// **'Revoke Session'**
  String get sessions_revokeTitle;

  /// Revoke session dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to revoke this session? This device will be logged out immediately.'**
  String get sessions_revokeMessage;

  /// Revoke button label
  ///
  /// In en, this message translates to:
  /// **'Revoke'**
  String get sessions_revoke;

  /// Revoke session success message
  ///
  /// In en, this message translates to:
  /// **'Session revoked successfully'**
  String get sessions_revokeSuccess;

  /// Logout all devices button
  ///
  /// In en, this message translates to:
  /// **'Logout from All Devices'**
  String get sessions_logoutAllDevices;

  /// Logout all devices dialog title
  ///
  /// In en, this message translates to:
  /// **'Logout from All Devices?'**
  String get sessions_logoutAllTitle;

  /// Logout all devices dialog message
  ///
  /// In en, this message translates to:
  /// **'This will log you out from all devices including this one. You\'ll need to log in again.'**
  String get sessions_logoutAllMessage;

  /// Logout all devices warning
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get sessions_logoutAllWarning;

  /// Logout all confirmation button
  ///
  /// In en, this message translates to:
  /// **'Logout All'**
  String get sessions_logoutAll;

  /// Logout all success message
  ///
  /// In en, this message translates to:
  /// **'Logged out from all devices'**
  String get sessions_logoutAllSuccess;

  /// Error loading sessions title
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Sessions'**
  String get sessions_errorLoading;

  /// No active sessions title
  ///
  /// In en, this message translates to:
  /// **'No Active Sessions'**
  String get sessions_noActiveSessions;

  /// No active sessions description
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any active sessions at the moment.'**
  String get sessions_noActiveSessionsDesc;

  /// Beneficiaries screen title
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get beneficiaries_title;

  /// All beneficiaries tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get beneficiaries_tabAll;

  /// Favorites tab
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get beneficiaries_tabFavorites;

  /// Recent tab
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get beneficiaries_tabRecent;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get beneficiaries_searchHint;

  /// Add beneficiary screen title
  ///
  /// In en, this message translates to:
  /// **'Add Beneficiary'**
  String get beneficiaries_addTitle;

  /// Edit beneficiary screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Beneficiary'**
  String get beneficiaries_editTitle;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get beneficiaries_fieldName;

  /// Phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get beneficiaries_fieldPhone;

  /// Account type field label
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get beneficiaries_fieldAccountType;

  /// Wallet address field label
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get beneficiaries_fieldWalletAddress;

  /// Bank code field label
  ///
  /// In en, this message translates to:
  /// **'Bank Code'**
  String get beneficiaries_fieldBankCode;

  /// Bank account field label
  ///
  /// In en, this message translates to:
  /// **'Bank Account Number'**
  String get beneficiaries_fieldBankAccount;

  /// Mobile money provider field label
  ///
  /// In en, this message translates to:
  /// **'Mobile Money Provider'**
  String get beneficiaries_fieldMobileMoneyProvider;

  /// JoonaPay user account type
  ///
  /// In en, this message translates to:
  /// **'JoonaPay User'**
  String get beneficiaries_typeJoonapay;

  /// External wallet account type
  ///
  /// In en, this message translates to:
  /// **'External Wallet'**
  String get beneficiaries_typeWallet;

  /// Bank account type
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get beneficiaries_typeBank;

  /// Mobile money account type
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get beneficiaries_typeMobileMoney;

  /// Add beneficiary button
  ///
  /// In en, this message translates to:
  /// **'Add Beneficiary'**
  String get beneficiaries_addButton;

  /// Add first beneficiary button
  ///
  /// In en, this message translates to:
  /// **'Add Your First Beneficiary'**
  String get beneficiaries_addFirst;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Beneficiaries Yet'**
  String get beneficiaries_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Add beneficiaries to send money faster next time'**
  String get beneficiaries_emptyMessage;

  /// Empty favorites title
  ///
  /// In en, this message translates to:
  /// **'No Favorites'**
  String get beneficiaries_emptyFavoritesTitle;

  /// Empty favorites message
  ///
  /// In en, this message translates to:
  /// **'Star your frequently used beneficiaries to see them here'**
  String get beneficiaries_emptyFavoritesMessage;

  /// Empty recent title
  ///
  /// In en, this message translates to:
  /// **'No Recent Transfers'**
  String get beneficiaries_emptyRecentTitle;

  /// Empty recent message
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries you\'ve sent money to will appear here'**
  String get beneficiaries_emptyRecentMessage;

  /// Edit menu item
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get beneficiaries_menuEdit;

  /// Delete menu item
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get beneficiaries_menuDelete;

  /// Delete confirmation title
  ///
  /// In en, this message translates to:
  /// **'Delete Beneficiary?'**
  String get beneficiaries_deleteTitle;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {name}?'**
  String beneficiaries_deleteMessage(String name);

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'Beneficiary deleted successfully'**
  String get beneficiaries_deleteSuccess;

  /// Create success message
  ///
  /// In en, this message translates to:
  /// **'Beneficiary added successfully'**
  String get beneficiaries_createSuccess;

  /// Update success message
  ///
  /// In en, this message translates to:
  /// **'Beneficiary updated successfully'**
  String get beneficiaries_updateSuccess;

  /// Error loading title
  ///
  /// In en, this message translates to:
  /// **'Error Loading Beneficiaries'**
  String get beneficiaries_errorTitle;

  /// Account details section title
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get beneficiaries_accountDetails;

  /// Statistics section title
  ///
  /// In en, this message translates to:
  /// **'Transfer Statistics'**
  String get beneficiaries_statistics;

  /// Total transfers label
  ///
  /// In en, this message translates to:
  /// **'Total Transfers'**
  String get beneficiaries_totalTransfers;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get beneficiaries_totalAmount;

  /// Last transfer label
  ///
  /// In en, this message translates to:
  /// **'Last Transfer'**
  String get beneficiaries_lastTransfer;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get common_verified;

  /// Required field error
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get error_required;

  /// Receive QR screen title
  ///
  /// In en, this message translates to:
  /// **'Receive Payment'**
  String get qr_receiveTitle;

  /// Scan QR screen title
  ///
  /// In en, this message translates to:
  /// **'Scan QR Code'**
  String get qr_scanTitle;

  /// Checkbox label for including amount in QR
  ///
  /// In en, this message translates to:
  /// **'Request specific amount'**
  String get qr_requestSpecificAmount;

  /// Amount input label
  ///
  /// In en, this message translates to:
  /// **'Amount (USD)'**
  String get qr_amountLabel;

  /// Instructions title
  ///
  /// In en, this message translates to:
  /// **'How to receive payment'**
  String get qr_howToReceive;

  /// Instructions for receiving payment
  ///
  /// In en, this message translates to:
  /// **'Share this QR code with the sender. They can scan it with their JoonaPay app to send you money instantly.'**
  String get qr_receiveInstructions;

  /// Success message for saving QR
  ///
  /// In en, this message translates to:
  /// **'QR code saved to gallery'**
  String get qr_savedToGallery;

  /// Error message for saving QR
  ///
  /// In en, this message translates to:
  /// **'Failed to save QR code'**
  String get qr_failedToSave;

  /// Loading message for camera
  ///
  /// In en, this message translates to:
  /// **'Initializing camera...'**
  String get qr_initializingCamera;

  /// Main scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Scan a JoonaPay QR code'**
  String get qr_scanInstruction;

  /// Secondary scanner instruction
  ///
  /// In en, this message translates to:
  /// **'Point your camera at a QR code to send money'**
  String get qr_scanSubInstruction;

  /// Success title after scanning
  ///
  /// In en, this message translates to:
  /// **'QR Code Scanned'**
  String get qr_scanned;

  /// Error title for invalid QR
  ///
  /// In en, this message translates to:
  /// **'Invalid QR Code'**
  String get qr_invalidCode;

  /// Error message for invalid QR
  ///
  /// In en, this message translates to:
  /// **'This QR code is not a valid JoonaPay payment code.'**
  String get qr_invalidCodeMessage;

  /// Button to retry scanning
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get qr_scanAgain;

  /// Button to proceed with payment
  ///
  /// In en, this message translates to:
  /// **'Send Money'**
  String get qr_sendMoney;

  /// Permission denied title
  ///
  /// In en, this message translates to:
  /// **'Camera Permission Required'**
  String get qr_cameraPermissionRequired;

  /// Permission denied message
  ///
  /// In en, this message translates to:
  /// **'Please grant camera permission to scan QR codes.'**
  String get qr_cameraPermissionMessage;

  /// Button to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get qr_openSettings;

  /// Placeholder message for gallery import feature
  ///
  /// In en, this message translates to:
  /// **'Gallery import coming soon'**
  String get qr_galleryImportSoon;

  /// Good morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get home_goodMorning;

  /// Good afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get home_goodAfternoon;

  /// Good evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get home_goodEvening;

  /// Good night greeting
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get home_goodNight;

  /// Total balance label
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get home_totalBalance;

  /// Hide balance tooltip
  ///
  /// In en, this message translates to:
  /// **'Hide balance'**
  String get home_hideBalance;

  /// Show balance tooltip
  ///
  /// In en, this message translates to:
  /// **'Show balance'**
  String get home_showBalance;

  /// Quick action send label
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get home_quickAction_send;

  /// Quick action receive label
  ///
  /// In en, this message translates to:
  /// **'Receive'**
  String get home_quickAction_receive;

  /// Quick action deposit label
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get home_quickAction_deposit;

  /// Quick action history label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get home_quickAction_history;

  /// KYC banner title
  ///
  /// In en, this message translates to:
  /// **'Complete verification to unlock all features'**
  String get home_kycBanner_title;

  /// KYC banner action button
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get home_kycBanner_action;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get home_recentActivity;

  /// See all link text
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get home_seeAll;

  /// Deposit screen title
  ///
  /// In en, this message translates to:
  /// **'Deposit Funds'**
  String get deposit_title;

  /// Quick amounts section label
  ///
  /// In en, this message translates to:
  /// **'Quick amounts'**
  String get deposit_quickAmounts;

  /// Exchange rate update time
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String deposit_rateUpdated(String time);

  /// Amount you will receive label
  ///
  /// In en, this message translates to:
  /// **'You will receive'**
  String get deposit_youWillReceive;

  /// Amount you will pay label
  ///
  /// In en, this message translates to:
  /// **'You will pay'**
  String get deposit_youWillPay;

  /// Deposit limits label
  ///
  /// In en, this message translates to:
  /// **'Deposit Limits'**
  String get deposit_limits;

  /// Select provider screen title
  ///
  /// In en, this message translates to:
  /// **'Select Provider'**
  String get deposit_selectProvider;

  /// Choose provider instruction
  ///
  /// In en, this message translates to:
  /// **'Choose a payment method'**
  String get deposit_chooseProvider;

  /// Amount to pay label
  ///
  /// In en, this message translates to:
  /// **'Amount to pay'**
  String get deposit_amountToPay;

  /// No fee label
  ///
  /// In en, this message translates to:
  /// **'No fee'**
  String get deposit_noFee;

  /// Fee suffix
  ///
  /// In en, this message translates to:
  /// **'fee'**
  String get deposit_fee;

  /// Payment instructions screen title
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get deposit_paymentInstructions;

  /// Expiration countdown label
  ///
  /// In en, this message translates to:
  /// **'Expires in'**
  String get deposit_expiresIn;

  /// Payment via provider label
  ///
  /// In en, this message translates to:
  /// **'via {provider}'**
  String deposit_via(String provider);

  /// Reference number label
  ///
  /// In en, this message translates to:
  /// **'Reference Number'**
  String get deposit_referenceNumber;

  /// Payment instructions section title
  ///
  /// In en, this message translates to:
  /// **'How to complete payment'**
  String get deposit_howToPay;

  /// USSD code label
  ///
  /// In en, this message translates to:
  /// **'USSD Code'**
  String get deposit_ussdCode;

  /// Open provider app button
  ///
  /// In en, this message translates to:
  /// **'Open {provider} App'**
  String deposit_openApp(String provider);

  /// Completed payment button
  ///
  /// In en, this message translates to:
  /// **'I\'ve completed payment'**
  String get deposit_completedPayment;

  /// Copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get deposit_copied;

  /// Cancel deposit dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel deposit?'**
  String get deposit_cancelTitle;

  /// Cancel deposit dialog message
  ///
  /// In en, this message translates to:
  /// **'Your payment session will be cancelled. You can start a new deposit later.'**
  String get deposit_cancelMessage;

  /// Processing status title
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get deposit_processing;

  /// Success status title
  ///
  /// In en, this message translates to:
  /// **'Deposit Successful!'**
  String get deposit_success;

  /// Failed status title
  ///
  /// In en, this message translates to:
  /// **'Deposit Failed'**
  String get deposit_failed;

  /// Expired status title
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get deposit_expired;

  /// Processing status message
  ///
  /// In en, this message translates to:
  /// **'We\'re processing your payment. This may take a few moments.'**
  String get deposit_processingMessage;

  /// Success status message
  ///
  /// In en, this message translates to:
  /// **'Your funds have been added to your wallet!'**
  String get deposit_successMessage;

  /// Failed status message
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t process your payment. Please try again.'**
  String get deposit_failedMessage;

  /// Expired status message
  ///
  /// In en, this message translates to:
  /// **'Your payment session has expired. Please start a new deposit.'**
  String get deposit_expiredMessage;

  /// Deposited amount label
  ///
  /// In en, this message translates to:
  /// **'Deposited'**
  String get deposit_deposited;

  /// Received amount label
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get deposit_received;

  /// Back to home button
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get deposit_backToHome;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get common_error;

  /// Required field validation message
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get common_requiredField;

  /// Create PIN screen title
  ///
  /// In en, this message translates to:
  /// **'Create Your PIN'**
  String get pin_createTitle;

  /// Confirm PIN screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get pin_confirmTitle;

  /// Change PIN screen title
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get pin_changeTitle;

  /// Reset PIN screen title
  ///
  /// In en, this message translates to:
  /// **'Reset PIN'**
  String get pin_resetTitle;

  /// Enter new PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your new 6-digit PIN'**
  String get pin_enterNewPin;

  /// Re-enter PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN to confirm'**
  String get pin_reenterPin;

  /// Enter current PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your current PIN'**
  String get pin_enterCurrentPin;

  /// Confirm new PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Confirm your new PIN'**
  String get pin_confirmNewPin;

  /// PIN requirements section title
  ///
  /// In en, this message translates to:
  /// **'PIN Requirements'**
  String get pin_requirements;

  /// PIN must be 6 digits rule
  ///
  /// In en, this message translates to:
  /// **'6 digits'**
  String get pin_rule_6digits;

  /// No sequential numbers rule
  ///
  /// In en, this message translates to:
  /// **'No sequential numbers (123456)'**
  String get pin_rule_noSequential;

  /// No repeated digits rule
  ///
  /// In en, this message translates to:
  /// **'No repeated digits (111111)'**
  String get pin_rule_noRepeated;

  /// Sequential PIN error message
  ///
  /// In en, this message translates to:
  /// **'PIN cannot be sequential numbers'**
  String get pin_error_sequential;

  /// Repeated digit PIN error message
  ///
  /// In en, this message translates to:
  /// **'PIN cannot be all the same digit'**
  String get pin_error_repeated;

  /// PIN mismatch error message
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Please try again.'**
  String get pin_error_noMatch;

  /// Wrong current PIN error message
  ///
  /// In en, this message translates to:
  /// **'Current PIN is incorrect'**
  String get pin_error_wrongCurrent;

  /// Failed to save PIN error message
  ///
  /// In en, this message translates to:
  /// **'Failed to save PIN. Please try again.'**
  String get pin_error_saveFailed;

  /// Failed to change PIN error message
  ///
  /// In en, this message translates to:
  /// **'Failed to change PIN. Please try again.'**
  String get pin_error_changeFailed;

  /// Failed to reset PIN error message
  ///
  /// In en, this message translates to:
  /// **'Failed to reset PIN. Please try again.'**
  String get pin_error_resetFailed;

  /// PIN created success message
  ///
  /// In en, this message translates to:
  /// **'PIN created successfully'**
  String get pin_success_set;

  /// PIN changed success message
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully'**
  String get pin_success_changed;

  /// PIN reset success message
  ///
  /// In en, this message translates to:
  /// **'PIN reset successfully'**
  String get pin_success_reset;

  /// Attempts remaining message
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 attempt remaining} other{{count} attempts remaining}}'**
  String pin_attemptsRemaining(int count);

  /// Forgot PIN link text
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get pin_forgotPin;

  /// PIN locked screen title
  ///
  /// In en, this message translates to:
  /// **'PIN Locked'**
  String get pin_locked_title;

  /// PIN locked message
  ///
  /// In en, this message translates to:
  /// **'Too many failed attempts. Your PIN is temporarily locked.'**
  String get pin_locked_message;

  /// Try again in label
  ///
  /// In en, this message translates to:
  /// **'Try again in'**
  String get pin_locked_tryAgainIn;

  /// Reset PIN via OTP button
  ///
  /// In en, this message translates to:
  /// **'Reset PIN via SMS'**
  String get pin_resetViaOtp;

  /// Reset PIN request title
  ///
  /// In en, this message translates to:
  /// **'Reset Your PIN'**
  String get pin_reset_requestTitle;

  /// Reset PIN request message
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your registered phone number to reset your PIN.'**
  String get pin_reset_requestMessage;

  /// Send OTP button
  ///
  /// In en, this message translates to:
  /// **'Send Verification Code'**
  String get pin_reset_sendOtp;

  /// Enter OTP instruction
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone'**
  String get pin_reset_enterOtp;

  /// Select recipient screen title
  ///
  /// In en, this message translates to:
  /// **'Select Recipient'**
  String get send_selectRecipient;

  /// Recipient phone input label
  ///
  /// In en, this message translates to:
  /// **'Recipient Phone Number'**
  String get send_recipientPhone;

  /// Select from contacts button
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get send_fromContacts;

  /// Select from beneficiaries button
  ///
  /// In en, this message translates to:
  /// **'Beneficiaries'**
  String get send_fromBeneficiaries;

  /// Recent recipients section title
  ///
  /// In en, this message translates to:
  /// **'Recent Recipients'**
  String get send_recentRecipients;

  /// Contacts permission denied message
  ///
  /// In en, this message translates to:
  /// **'Contacts permission is required to select a contact'**
  String get send_contactsPermissionDenied;

  /// No contacts found message
  ///
  /// In en, this message translates to:
  /// **'No contacts found'**
  String get send_noContactsFound;

  /// Beneficiary picker title
  ///
  /// In en, this message translates to:
  /// **'Select Beneficiary'**
  String get send_selectBeneficiary;

  /// Search beneficiaries placeholder
  ///
  /// In en, this message translates to:
  /// **'Search beneficiaries'**
  String get send_searchBeneficiaries;

  /// No beneficiaries found message
  ///
  /// In en, this message translates to:
  /// **'No beneficiaries found'**
  String get send_noBeneficiariesFound;

  /// Enter amount screen title
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get send_enterAmount;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get send_amount;

  /// Max button label
  ///
  /// In en, this message translates to:
  /// **'MAX'**
  String get send_max;

  /// Note/memo label
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get send_note;

  /// Note placeholder
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get send_noteOptional;

  /// Fee label
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get send_fee;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get send_total;

  /// Confirm transfer screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get send_confirmTransfer;

  /// PIN verification info message
  ///
  /// In en, this message translates to:
  /// **'You will be asked to enter your PIN to confirm this transfer'**
  String get send_pinVerificationRequired;

  /// Confirm and send button
  ///
  /// In en, this message translates to:
  /// **'Confirm & Send'**
  String get send_confirmAndSend;

  /// PIN verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verify PIN'**
  String get send_verifyPin;

  /// Enter PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN'**
  String get send_enterPinToConfirm;

  /// PIN verification description
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN to confirm this transfer'**
  String get send_pinVerificationDescription;

  /// Use biometric button
  ///
  /// In en, this message translates to:
  /// **'Use Biometric'**
  String get send_useBiometric;

  /// Biometric authentication reason
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to complete the transfer'**
  String get send_biometricReason;

  /// Transfer failed title
  ///
  /// In en, this message translates to:
  /// **'Transfer Failed'**
  String get send_transferFailed;

  /// Transfer success message
  ///
  /// In en, this message translates to:
  /// **'Your money has been sent successfully'**
  String get send_transferSuccessMessage;

  /// Sent to label
  ///
  /// In en, this message translates to:
  /// **'Sent to'**
  String get send_sentTo;

  /// Transaction reference label
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get send_reference;

  /// Transaction date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get send_date;

  /// Save as beneficiary button
  ///
  /// In en, this message translates to:
  /// **'Save as Beneficiary'**
  String get send_saveAsBeneficiary;

  /// Share receipt button
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get send_shareReceipt;

  /// Transfer receipt title for sharing
  ///
  /// In en, this message translates to:
  /// **'Transfer Receipt'**
  String get send_transferReceipt;

  /// Beneficiary saved success message
  ///
  /// In en, this message translates to:
  /// **'Beneficiary saved successfully'**
  String get send_beneficiarySaved;

  /// Phone number required error
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get error_phoneRequired;

  /// Invalid phone number error
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get error_phoneInvalid;

  /// Amount required error
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get error_amountRequired;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get error_amountInvalid;

  /// Insufficient balance error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance'**
  String get error_insufficientBalance;

  /// Incorrect PIN error
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get error_pinIncorrect;

  /// Biometric authentication failed error
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication failed'**
  String get error_biometricFailed;

  /// Transfer failed error
  ///
  /// In en, this message translates to:
  /// **'Transfer failed. Please try again.'**
  String get error_transferFailed;

  /// Copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get common_copiedToClipboard;

  /// Notification permission screen title
  ///
  /// In en, this message translates to:
  /// **'Stay Informed'**
  String get notifications_permission_title;

  /// Notification permission screen description
  ///
  /// In en, this message translates to:
  /// **'Get instant updates about your transactions, security alerts, and important account activity.'**
  String get notifications_permission_description;

  /// Transaction benefit title
  ///
  /// In en, this message translates to:
  /// **'Transaction Updates'**
  String get notifications_benefit_transactions;

  /// Transaction benefit description
  ///
  /// In en, this message translates to:
  /// **'Instant alerts when you send or receive money'**
  String get notifications_benefit_transactions_desc;

  /// Security benefit title
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get notifications_benefit_security;

  /// Security benefit description
  ///
  /// In en, this message translates to:
  /// **'Be notified of suspicious activity and new device logins'**
  String get notifications_benefit_security_desc;

  /// Updates benefit title
  ///
  /// In en, this message translates to:
  /// **'Important Updates'**
  String get notifications_benefit_updates;

  /// Updates benefit description
  ///
  /// In en, this message translates to:
  /// **'Stay updated on new features and special offers'**
  String get notifications_benefit_updates_desc;

  /// Enable notifications button
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get notifications_enable_notifications;

  /// Maybe later button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get notifications_maybe_later;

  /// Notifications enabled success message
  ///
  /// In en, this message translates to:
  /// **'Notifications enabled successfully'**
  String get notifications_enabled_success;

  /// Permission denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get notifications_permission_denied_title;

  /// Permission denied dialog message
  ///
  /// In en, this message translates to:
  /// **'To receive notifications, you need to enable them in your device settings.'**
  String get notifications_permission_denied_message;

  /// Open settings button
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get action_open_settings;

  /// Notification preferences screen title
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notifications_preferences_title;

  /// Notification preferences screen description
  ///
  /// In en, this message translates to:
  /// **'Choose which notifications you\'d like to receive'**
  String get notifications_preferences_description;

  /// Transaction alerts section title
  ///
  /// In en, this message translates to:
  /// **'Transaction Alerts'**
  String get notifications_pref_transaction_title;

  /// Transaction alerts label
  ///
  /// In en, this message translates to:
  /// **'All transaction alerts'**
  String get notifications_pref_transaction_alerts;

  /// Transaction alerts description
  ///
  /// In en, this message translates to:
  /// **'Get notified for all incoming and outgoing transactions'**
  String get notifications_pref_transaction_alerts_desc;

  /// Security section title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get notifications_pref_security_title;

  /// Security alerts label
  ///
  /// In en, this message translates to:
  /// **'Security alerts'**
  String get notifications_pref_security_alerts;

  /// Security alerts description
  ///
  /// In en, this message translates to:
  /// **'Critical security alerts (cannot be disabled)'**
  String get notifications_pref_security_alerts_desc;

  /// Promotional section title
  ///
  /// In en, this message translates to:
  /// **'Promotional'**
  String get notifications_pref_promotional_title;

  /// Promotions label
  ///
  /// In en, this message translates to:
  /// **'Promotions and offers'**
  String get notifications_pref_promotions;

  /// Promotions description
  ///
  /// In en, this message translates to:
  /// **'Special offers and promotional campaigns'**
  String get notifications_pref_promotions_desc;

  /// Price alerts section title
  ///
  /// In en, this message translates to:
  /// **'Market Updates'**
  String get notifications_pref_price_title;

  /// Price alerts label
  ///
  /// In en, this message translates to:
  /// **'Price alerts'**
  String get notifications_pref_price_alerts;

  /// Price alerts description
  ///
  /// In en, this message translates to:
  /// **'USDC and crypto price movements'**
  String get notifications_pref_price_alerts_desc;

  /// Summary section title
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get notifications_pref_summary_title;

  /// Weekly summary label
  ///
  /// In en, this message translates to:
  /// **'Weekly spending summary'**
  String get notifications_pref_weekly_summary;

  /// Weekly summary description
  ///
  /// In en, this message translates to:
  /// **'Receive a summary of your weekly activity'**
  String get notifications_pref_weekly_summary_desc;

  /// Thresholds section title
  ///
  /// In en, this message translates to:
  /// **'Alert Thresholds'**
  String get notifications_pref_thresholds_title;

  /// Thresholds section description
  ///
  /// In en, this message translates to:
  /// **'Set custom amounts to trigger alerts'**
  String get notifications_pref_thresholds_description;

  /// Large transaction threshold label
  ///
  /// In en, this message translates to:
  /// **'Large transaction alert'**
  String get notifications_pref_large_transaction_threshold;

  /// Low balance threshold label
  ///
  /// In en, this message translates to:
  /// **'Low balance alert'**
  String get notifications_pref_low_balance_threshold;

  /// Edit profile screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get settings_editProfile;

  /// Account settings section
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settings_account;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// Terms of service label
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settings_termsOfService;

  /// Privacy policy label
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settings_privacyPolicy;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get settings_appVersion;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get profile_firstName;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get profile_lastName;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get profile_phoneNumber;

  /// Phone number read-only hint
  ///
  /// In en, this message translates to:
  /// **'Phone number cannot be changed'**
  String get profile_phoneCannotChange;

  /// Profile update success message
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updateSuccess;

  /// Profile update error message
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profile_updateError;

  /// FAQ section title
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get help_faq;

  /// Contact section title
  ///
  /// In en, this message translates to:
  /// **'Need More Help?'**
  String get help_needMoreHelp;

  /// Report problem button
  ///
  /// In en, this message translates to:
  /// **'Report Problem'**
  String get help_reportProblem;

  /// Live chat button
  ///
  /// In en, this message translates to:
  /// **'Live Chat'**
  String get help_liveChat;

  /// Email support label
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get help_emailSupport;

  /// WhatsApp support label
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Support'**
  String get help_whatsappSupport;

  /// Copied to clipboard message
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get help_copiedToClipboard;

  /// Need help button text
  ///
  /// In en, this message translates to:
  /// **'Need Help?'**
  String get help_needHelp;

  /// Transaction details screen title
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transactionDetails_title;

  /// Transaction ID label
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactionDetails_transactionId;

  /// Transaction date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transactionDetails_date;

  /// Transaction currency label
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get transactionDetails_currency;

  /// Recipient phone label
  ///
  /// In en, this message translates to:
  /// **'Recipient Phone'**
  String get transactionDetails_recipientPhone;

  /// Recipient address label
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get transactionDetails_recipientAddress;

  /// Transaction description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get transactionDetails_description;

  /// Additional transaction details section
  ///
  /// In en, this message translates to:
  /// **'Additional Details'**
  String get transactionDetails_additionalDetails;

  /// Transaction failure reason label
  ///
  /// In en, this message translates to:
  /// **'Failure Reason'**
  String get transactionDetails_failureReason;

  /// Filter transactions screen title
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filters_title;

  /// Reset filters button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filters_reset;

  /// Transaction type filter label
  ///
  /// In en, this message translates to:
  /// **'Transaction Type'**
  String get filters_transactionType;

  /// Status filter label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filters_status;

  /// Date range filter label
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get filters_dateRange;

  /// Amount range filter label
  ///
  /// In en, this message translates to:
  /// **'Amount Range'**
  String get filters_amountRange;

  /// Sort by filter label
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get filters_sortBy;

  /// Date range from label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get filters_from;

  /// Date range to label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get filters_to;

  /// Clear filters button
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get filters_clear;

  /// Skip button on welcome slides
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// Get started button
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_getStarted;

  /// First onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Send Money Instantly'**
  String get onboarding_slide1_title;

  /// First onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Transfer USDC to anyone, anywhere in West Africa. Fast, secure, and with minimal fees.'**
  String get onboarding_slide1_description;

  /// Second onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Pay Bills Easily'**
  String get onboarding_slide2_title;

  /// Second onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Pay your utility bills, buy airtime, and manage all your payments in one place.'**
  String get onboarding_slide2_description;

  /// Third onboarding slide title
  ///
  /// In en, this message translates to:
  /// **'Save for Goals'**
  String get onboarding_slide3_title;

  /// Third onboarding slide description
  ///
  /// In en, this message translates to:
  /// **'Set savings goals and watch your money grow with USDC\'s stable value.'**
  String get onboarding_slide3_description;

  /// Phone input screen title
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number'**
  String get onboarding_phoneInput_title;

  /// Phone input screen subtitle
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a code to verify your number'**
  String get onboarding_phoneInput_subtitle;

  /// Phone number input label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get onboarding_phoneInput_label;

  /// Terms acceptance checkbox text
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy'**
  String get onboarding_phoneInput_terms;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get onboarding_phoneInput_loginLink;

  /// OTP verification screen title
  ///
  /// In en, this message translates to:
  /// **'Verify your number'**
  String get onboarding_otp_title;

  /// OTP verification screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to {dialCode} {phoneNumber}'**
  String onboarding_otp_subtitle(String dialCode, String phoneNumber);

  /// Resend OTP button
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get onboarding_otp_resend;

  /// Resend countdown text
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String onboarding_otp_resendIn(int seconds);

  /// Verifying OTP loading text
  ///
  /// In en, this message translates to:
  /// **'Verifying...'**
  String get onboarding_otp_verifying;

  /// PIN setup screen title
  ///
  /// In en, this message translates to:
  /// **'Create your PIN'**
  String get onboarding_pin_title;

  /// PIN confirm screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm your PIN'**
  String get onboarding_pin_confirmTitle;

  /// Enter PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your new 6-digit PIN'**
  String get onboarding_pin_enterPin;

  /// Confirm PIN instruction
  ///
  /// In en, this message translates to:
  /// **'Re-enter your PIN to confirm'**
  String get onboarding_pin_confirmPin;

  /// PIN mismatch error message
  ///
  /// In en, this message translates to:
  /// **'PINs don\'t match. Please try again.'**
  String get pin_error_mismatch;

  /// Profile setup screen title
  ///
  /// In en, this message translates to:
  /// **'Tell us about yourself'**
  String get onboarding_profile_title;

  /// Profile setup screen subtitle
  ///
  /// In en, this message translates to:
  /// **'This helps us personalize your experience'**
  String get onboarding_profile_subtitle;

  /// First name field label
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get onboarding_profile_firstName;

  /// First name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Amadou'**
  String get onboarding_profile_firstNameHint;

  /// First name required error
  ///
  /// In en, this message translates to:
  /// **'First name is required'**
  String get onboarding_profile_firstNameRequired;

  /// Last name field label
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get onboarding_profile_lastName;

  /// Last name field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Diallo'**
  String get onboarding_profile_lastNameHint;

  /// Last name required error
  ///
  /// In en, this message translates to:
  /// **'Last name is required'**
  String get onboarding_profile_lastNameRequired;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email (Optional)'**
  String get onboarding_profile_email;

  /// Email field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., amadou@example.com'**
  String get onboarding_profile_emailHint;

  /// Invalid email error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get onboarding_profile_emailInvalid;

  /// KYC prompt screen title
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get onboarding_kyc_title;

  /// KYC prompt screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Unlock higher limits and all features'**
  String get onboarding_kyc_subtitle;

  /// KYC benefit 1
  ///
  /// In en, this message translates to:
  /// **'Higher transaction limits'**
  String get onboarding_kyc_benefit1;

  /// KYC benefit 2
  ///
  /// In en, this message translates to:
  /// **'Send to external wallets'**
  String get onboarding_kyc_benefit2;

  /// KYC benefit 3
  ///
  /// In en, this message translates to:
  /// **'All features unlocked'**
  String get onboarding_kyc_benefit3;

  /// Verify KYC button
  ///
  /// In en, this message translates to:
  /// **'Verify Now'**
  String get onboarding_kyc_verify;

  /// Skip KYC button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get onboarding_kyc_later;

  /// Success screen title
  ///
  /// In en, this message translates to:
  /// **'Welcome to JoonaPay!'**
  String get onboarding_success_title;

  /// Success screen subtitle with user name
  ///
  /// In en, this message translates to:
  /// **'Hi {name}, you\'re all set!'**
  String onboarding_success_subtitle(String name);

  /// Wallet created message
  ///
  /// In en, this message translates to:
  /// **'Your Wallet is Ready'**
  String get onboarding_success_walletCreated;

  /// Wallet ready message
  ///
  /// In en, this message translates to:
  /// **'Start sending, receiving, and managing your USDC today'**
  String get onboarding_success_walletMessage;

  /// Continue to app button
  ///
  /// In en, this message translates to:
  /// **'Start Using JoonaPay'**
  String get onboarding_success_continue;

  /// Delete action button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get action_delete;

  /// Savings pots screen title
  ///
  /// In en, this message translates to:
  /// **'Savings Pots'**
  String get savingsPots_title;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'Start saving for your goals'**
  String get savingsPots_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Create pots to save money for specific goals like vacations, gadgets, or emergencies.'**
  String get savingsPots_emptyMessage;

  /// Create first pot button
  ///
  /// In en, this message translates to:
  /// **'Create Your First Pot'**
  String get savingsPots_createFirst;

  /// Total saved across all pots label
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get savingsPots_totalSaved;

  /// Create pot screen title
  ///
  /// In en, this message translates to:
  /// **'Create Savings Pot'**
  String get savingsPots_createTitle;

  /// Edit pot screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Pot'**
  String get savingsPots_editTitle;

  /// Pot name input label
  ///
  /// In en, this message translates to:
  /// **'Pot Name'**
  String get savingsPots_nameLabel;

  /// Pot name input hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Vacation, New Phone'**
  String get savingsPots_nameHint;

  /// Pot name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a pot name'**
  String get savingsPots_nameRequired;

  /// Target amount input label
  ///
  /// In en, this message translates to:
  /// **'Target Amount (Optional)'**
  String get savingsPots_targetLabel;

  /// Target amount input hint
  ///
  /// In en, this message translates to:
  /// **'How much do you want to save?'**
  String get savingsPots_targetHint;

  /// Target amount optional note
  ///
  /// In en, this message translates to:
  /// **'Leave blank if you don\'t have a specific goal'**
  String get savingsPots_targetOptional;

  /// Emoji validation error
  ///
  /// In en, this message translates to:
  /// **'Please select an emoji'**
  String get savingsPots_emojiRequired;

  /// Color validation error
  ///
  /// In en, this message translates to:
  /// **'Please select a color'**
  String get savingsPots_colorRequired;

  /// Create pot button
  ///
  /// In en, this message translates to:
  /// **'Create Pot'**
  String get savingsPots_createButton;

  /// Update pot button
  ///
  /// In en, this message translates to:
  /// **'Update Pot'**
  String get savingsPots_updateButton;

  /// Create success message
  ///
  /// In en, this message translates to:
  /// **'Pot created successfully!'**
  String get savingsPots_createSuccess;

  /// Update success message
  ///
  /// In en, this message translates to:
  /// **'Pot updated successfully!'**
  String get savingsPots_updateSuccess;

  /// Add money button
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get savingsPots_addMoney;

  /// Withdraw button
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get savingsPots_withdraw;

  /// Available balance label
  ///
  /// In en, this message translates to:
  /// **'Available Balance'**
  String get savingsPots_availableBalance;

  /// Pot balance label
  ///
  /// In en, this message translates to:
  /// **'Pot Balance'**
  String get savingsPots_potBalance;

  /// Amount input label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get savingsPots_amount;

  /// Quick amount 10% button
  ///
  /// In en, this message translates to:
  /// **'10%'**
  String get savingsPots_quick10;

  /// Quick amount 25% button
  ///
  /// In en, this message translates to:
  /// **'25%'**
  String get savingsPots_quick25;

  /// Quick amount 50% button
  ///
  /// In en, this message translates to:
  /// **'50%'**
  String get savingsPots_quick50;

  /// Add to pot button
  ///
  /// In en, this message translates to:
  /// **'Add to Pot'**
  String get savingsPots_addButton;

  /// Withdraw button
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get savingsPots_withdrawButton;

  /// Withdraw all button
  ///
  /// In en, this message translates to:
  /// **'Withdraw All'**
  String get savingsPots_withdrawAll;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get savingsPots_invalidAmount;

  /// Insufficient balance error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance in your wallet'**
  String get savingsPots_insufficientBalance;

  /// Insufficient pot balance error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance in this pot'**
  String get savingsPots_insufficientPotBalance;

  /// Add money success message
  ///
  /// In en, this message translates to:
  /// **'Money added successfully!'**
  String get savingsPots_addSuccess;

  /// Withdraw success message
  ///
  /// In en, this message translates to:
  /// **'Money withdrawn successfully!'**
  String get savingsPots_withdrawSuccess;

  /// Transaction history section title
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get savingsPots_transactionHistory;

  /// No transactions message
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get savingsPots_noTransactions;

  /// Deposit transaction type
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get savingsPots_deposit;

  /// Withdrawal transaction type
  ///
  /// In en, this message translates to:
  /// **'Withdrawal'**
  String get savingsPots_withdrawal;

  /// Goal reached badge
  ///
  /// In en, this message translates to:
  /// **'Goal Reached!'**
  String get savingsPots_goalReached;

  /// Delete confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Pot?'**
  String get savingsPots_deleteTitle;

  /// Delete confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'The money in this pot will be returned to your main balance. This action cannot be undone.'**
  String get savingsPots_deleteMessage;

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'Pot deleted successfully'**
  String get savingsPots_deleteSuccess;

  /// Emoji picker label
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get savingsPots_chooseEmoji;

  /// Color picker label
  ///
  /// In en, this message translates to:
  /// **'Choose a color'**
  String get savingsPots_chooseColor;

  /// External transfer screen title
  ///
  /// In en, this message translates to:
  /// **'Send to External Wallet'**
  String get sendExternal_title;

  /// External transfer info message
  ///
  /// In en, this message translates to:
  /// **'Send USDC to any wallet address on Polygon or Ethereum networks'**
  String get sendExternal_info;

  /// Wallet address field label
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get sendExternal_walletAddress;

  /// Wallet address input hint
  ///
  /// In en, this message translates to:
  /// **'0x1234...abcd'**
  String get sendExternal_addressHint;

  /// Address required error
  ///
  /// In en, this message translates to:
  /// **'Wallet address is required'**
  String get sendExternal_addressRequired;

  /// Paste button label
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get sendExternal_paste;

  /// Scan QR button label
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get sendExternal_scanQr;

  /// Supported networks section title
  ///
  /// In en, this message translates to:
  /// **'Supported Networks'**
  String get sendExternal_supportedNetworks;

  /// Polygon network info
  ///
  /// In en, this message translates to:
  /// **'Fast (1-2 min), Low fee (~\$0.01)'**
  String get sendExternal_polygonInfo;

  /// Ethereum network info
  ///
  /// In en, this message translates to:
  /// **'Slower (5-10 min), Higher fee (~\$2-5)'**
  String get sendExternal_ethereumInfo;

  /// Enter amount screen title
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get sendExternal_enterAmount;

  /// Recipient address label
  ///
  /// In en, this message translates to:
  /// **'Recipient Address'**
  String get sendExternal_recipientAddress;

  /// Select network label
  ///
  /// In en, this message translates to:
  /// **'Select Network'**
  String get sendExternal_selectNetwork;

  /// Recommended badge label
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get sendExternal_recommended;

  /// Fee label
  ///
  /// In en, this message translates to:
  /// **'Fee'**
  String get sendExternal_fee;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get sendExternal_amount;

  /// Network fee label
  ///
  /// In en, this message translates to:
  /// **'Network Fee'**
  String get sendExternal_networkFee;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get sendExternal_total;

  /// Confirm transfer screen title
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get sendExternal_confirmTransfer;

  /// Warning title
  ///
  /// In en, this message translates to:
  /// **'Important'**
  String get sendExternal_warningTitle;

  /// Warning message
  ///
  /// In en, this message translates to:
  /// **'External transfers cannot be reversed. Please verify the address carefully.'**
  String get sendExternal_warningMessage;

  /// Transfer summary section title
  ///
  /// In en, this message translates to:
  /// **'Transfer Summary'**
  String get sendExternal_transferSummary;

  /// Network label
  ///
  /// In en, this message translates to:
  /// **'Network'**
  String get sendExternal_network;

  /// Total deducted label
  ///
  /// In en, this message translates to:
  /// **'Total Deducted'**
  String get sendExternal_totalDeducted;

  /// Estimated time label
  ///
  /// In en, this message translates to:
  /// **'Estimated Time'**
  String get sendExternal_estimatedTime;

  /// Confirm and send button
  ///
  /// In en, this message translates to:
  /// **'Confirm and Send'**
  String get sendExternal_confirmAndSend;

  /// Address copied message
  ///
  /// In en, this message translates to:
  /// **'Address copied to clipboard'**
  String get sendExternal_addressCopied;

  /// Transfer success title
  ///
  /// In en, this message translates to:
  /// **'Transfer Successful'**
  String get sendExternal_transferSuccess;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Your transaction is being processed on the blockchain'**
  String get sendExternal_processingMessage;

  /// Amount sent label
  ///
  /// In en, this message translates to:
  /// **'Amount Sent'**
  String get sendExternal_amountSent;

  /// Transaction details section title
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get sendExternal_transactionDetails;

  /// Transaction hash label
  ///
  /// In en, this message translates to:
  /// **'Transaction Hash'**
  String get sendExternal_transactionHash;

  /// Status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get sendExternal_status;

  /// View on explorer button
  ///
  /// In en, this message translates to:
  /// **'View on Block Explorer'**
  String get sendExternal_viewOnExplorer;

  /// Share details button
  ///
  /// In en, this message translates to:
  /// **'Share Details'**
  String get sendExternal_shareDetails;

  /// Hash copied message
  ///
  /// In en, this message translates to:
  /// **'Transaction hash copied to clipboard'**
  String get sendExternal_hashCopied;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get sendExternal_statusPending;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sendExternal_statusCompleted;

  /// Processing status
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get sendExternal_statusProcessing;

  /// Bill payments screen title
  ///
  /// In en, this message translates to:
  /// **'Pay Bills'**
  String get billPayments_title;

  /// Bill categories section
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get billPayments_categories;

  /// Bill providers section
  ///
  /// In en, this message translates to:
  /// **'Providers'**
  String get billPayments_providers;

  /// All providers label
  ///
  /// In en, this message translates to:
  /// **'All Providers'**
  String get billPayments_allProviders;

  /// Search providers placeholder
  ///
  /// In en, this message translates to:
  /// **'Search providers...'**
  String get billPayments_searchProviders;

  /// No providers found message
  ///
  /// In en, this message translates to:
  /// **'No Providers Found'**
  String get billPayments_noProvidersFound;

  /// Adjust search suggestion
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search'**
  String get billPayments_tryAdjustingSearch;

  /// Payment history title
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get billPayments_history;

  /// Electricity category
  ///
  /// In en, this message translates to:
  /// **'Electricity'**
  String get billPayments_category_electricity;

  /// Water category
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get billPayments_category_water;

  /// Airtime category
  ///
  /// In en, this message translates to:
  /// **'Airtime'**
  String get billPayments_category_airtime;

  /// Internet category
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get billPayments_category_internet;

  /// TV category
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get billPayments_category_tv;

  /// Verify account button
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get billPayments_verifyAccount;

  /// Account verified message
  ///
  /// In en, this message translates to:
  /// **'Account verified'**
  String get billPayments_accountVerified;

  /// Verification failed message
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get billPayments_verificationFailed;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get billPayments_amount;

  /// Processing fee label
  ///
  /// In en, this message translates to:
  /// **'Processing Fee'**
  String get billPayments_processingFee;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get billPayments_totalAmount;

  /// Payment successful message
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get billPayments_paymentSuccessful;

  /// Payment processing message
  ///
  /// In en, this message translates to:
  /// **'Payment Processing'**
  String get billPayments_paymentProcessing;

  /// Bill paid successfully message
  ///
  /// In en, this message translates to:
  /// **'Your bill has been paid successfully'**
  String get billPayments_billPaidSuccessfully;

  /// Payment being processed message
  ///
  /// In en, this message translates to:
  /// **'Your payment is being processed'**
  String get billPayments_paymentBeingProcessed;

  /// Receipt number label
  ///
  /// In en, this message translates to:
  /// **'Receipt Number'**
  String get billPayments_receiptNumber;

  /// Provider label
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get billPayments_provider;

  /// Account label
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get billPayments_account;

  /// Customer label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get billPayments_customer;

  /// Total paid label
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get billPayments_totalPaid;

  /// Date label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get billPayments_date;

  /// Reference label
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get billPayments_reference;

  /// Your token label
  ///
  /// In en, this message translates to:
  /// **'Your Token'**
  String get billPayments_yourToken;

  /// Share receipt button
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get billPayments_shareReceipt;

  /// Confirm payment title
  ///
  /// In en, this message translates to:
  /// **'Confirm Payment'**
  String get billPayments_confirmPayment;

  /// Failed to load providers error
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Providers'**
  String get billPayments_failedToLoadProviders;

  /// Failed to load receipt error
  ///
  /// In en, this message translates to:
  /// **'Failed to Load Receipt'**
  String get billPayments_failedToLoadReceipt;

  /// Return home button
  ///
  /// In en, this message translates to:
  /// **'Return Home'**
  String get billPayments_returnHome;

  /// Pay provider title
  ///
  /// In en, this message translates to:
  /// **'Pay {providerName}'**
  String billPayments_payProvider(String providerName);

  /// Enter field hint
  ///
  /// In en, this message translates to:
  /// **'Enter {field}'**
  String billPayments_enterField(String field);

  /// Validation error for empty field
  ///
  /// In en, this message translates to:
  /// **'Please enter {field}'**
  String billPayments_pleaseEnterField(String field);

  /// Validation error for field length
  ///
  /// In en, this message translates to:
  /// **'{field} must be {length} characters'**
  String billPayments_fieldMustBeLength(String field, int length);

  /// Meter number label
  ///
  /// In en, this message translates to:
  /// **'Meter Number'**
  String get billPayments_meterNumber;

  /// Meter number hint
  ///
  /// In en, this message translates to:
  /// **'Enter meter number'**
  String get billPayments_enterMeterNumber;

  /// Meter number validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter meter number'**
  String get billPayments_pleaseEnterMeterNumber;

  /// Outstanding balance display
  ///
  /// In en, this message translates to:
  /// **'Outstanding: {amount} {currency}'**
  String billPayments_outstanding(String amount, String currency);

  /// Amount validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter amount'**
  String get billPayments_pleaseEnterAmount;

  /// Invalid amount validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get billPayments_pleaseEnterValidAmount;

  /// Minimum amount validation error
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is {amount} {currency}'**
  String billPayments_minimumAmount(int amount, String currency);

  /// Maximum amount validation error
  ///
  /// In en, this message translates to:
  /// **'Maximum amount is {amount} {currency}'**
  String billPayments_maximumAmount(int amount, String currency);

  /// Amount range display
  ///
  /// In en, this message translates to:
  /// **'Min: {min} - Max: {max} {currency}'**
  String billPayments_minMaxRange(int min, int max, String currency);

  /// Available balance display
  ///
  /// In en, this message translates to:
  /// **'Available: {amount} {currency}'**
  String billPayments_available(String amount, String currency);

  /// Pay button with amount
  ///
  /// In en, this message translates to:
  /// **'Pay {amount} {currency}'**
  String billPayments_payAmount(String amount, String currency);

  /// PIN confirmation subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your PIN to pay {providerName}'**
  String billPayments_enterPinToPay(String providerName);

  /// Payment failed error message
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get billPayments_paymentFailed;

  /// Empty state for no providers
  ///
  /// In en, this message translates to:
  /// **'No providers available for this category'**
  String get billPayments_noProvidersAvailable;

  /// No fee display
  ///
  /// In en, this message translates to:
  /// **'No fee'**
  String get billPayments_feeNone;

  /// Percentage fee display
  ///
  /// In en, this message translates to:
  /// **'{percentage}% fee'**
  String billPayments_feePercentage(String percentage);

  /// Fixed fee display
  ///
  /// In en, this message translates to:
  /// **'{amount} {currency} fee'**
  String billPayments_feeFixed(int amount, String currency);

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get billPayments_statusCompleted;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get billPayments_statusPending;

  /// Processing status
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get billPayments_statusProcessing;

  /// Failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get billPayments_statusFailed;

  /// Refunded status
  ///
  /// In en, this message translates to:
  /// **'Refunded'**
  String get billPayments_statusRefunded;

  /// Cards navigation label
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get navigation_cards;

  /// History navigation label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navigation_history;

  /// Cards coming soon badge
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get cards_comingSoon;

  /// Cards feature title
  ///
  /// In en, this message translates to:
  /// **'Virtual Cards'**
  String get cards_title;

  /// Cards feature description
  ///
  /// In en, this message translates to:
  /// **'Spend your USDC with virtual debit cards. Perfect for online shopping and subscriptions.'**
  String get cards_description;

  /// Cards feature 1 title
  ///
  /// In en, this message translates to:
  /// **'Shop Online'**
  String get cards_feature1Title;

  /// Cards feature 1 description
  ///
  /// In en, this message translates to:
  /// **'Use virtual cards for secure online purchases'**
  String get cards_feature1Description;

  /// Cards feature 2 title
  ///
  /// In en, this message translates to:
  /// **'Stay Secure'**
  String get cards_feature2Title;

  /// Cards feature 2 description
  ///
  /// In en, this message translates to:
  /// **'Freeze, unfreeze, or delete cards instantly'**
  String get cards_feature2Description;

  /// Cards feature 3 title
  ///
  /// In en, this message translates to:
  /// **'Control Spending'**
  String get cards_feature3Title;

  /// Cards feature 3 description
  ///
  /// In en, this message translates to:
  /// **'Set custom spending limits for each card'**
  String get cards_feature3Description;

  /// Cards notify me button
  ///
  /// In en, this message translates to:
  /// **'Notify Me When Available'**
  String get cards_notifyMe;

  /// Cards notify dialog title
  ///
  /// In en, this message translates to:
  /// **'Get Notified'**
  String get cards_notifyDialogTitle;

  /// Cards notify dialog message
  ///
  /// In en, this message translates to:
  /// **'We\'ll send you a notification when virtual cards are available in your region.'**
  String get cards_notifyDialogMessage;

  /// Cards notify success message
  ///
  /// In en, this message translates to:
  /// **'You\'ll be notified when cards are available'**
  String get cards_notifySuccess;

  /// No description provided for @cards_featureDisabled.
  ///
  /// In en, this message translates to:
  /// **'Virtual cards feature is not available'**
  String get cards_featureDisabled;

  /// No description provided for @cards_noCards.
  ///
  /// In en, this message translates to:
  /// **'No Cards Yet'**
  String get cards_noCards;

  /// No description provided for @cards_noCardsDescription.
  ///
  /// In en, this message translates to:
  /// **'Request your first virtual card to start making online purchases'**
  String get cards_noCardsDescription;

  /// No description provided for @cards_requestCard.
  ///
  /// In en, this message translates to:
  /// **'Request Card'**
  String get cards_requestCard;

  /// No description provided for @cards_cardDetails.
  ///
  /// In en, this message translates to:
  /// **'Card Details'**
  String get cards_cardDetails;

  /// No description provided for @cards_cardNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card not found'**
  String get cards_cardNotFound;

  /// No description provided for @cards_cardInformation.
  ///
  /// In en, this message translates to:
  /// **'Card Information'**
  String get cards_cardInformation;

  /// No description provided for @cards_cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cards_cardNumber;

  /// No description provided for @cards_cvv.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cards_cvv;

  /// No description provided for @cards_expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get cards_expiryDate;

  /// No description provided for @cards_spendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Spending Limit'**
  String get cards_spendingLimit;

  /// No description provided for @cards_spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get cards_spent;

  /// No description provided for @cards_limit.
  ///
  /// In en, this message translates to:
  /// **'Limit'**
  String get cards_limit;

  /// No description provided for @cards_viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View Transactions'**
  String get cards_viewTransactions;

  /// No description provided for @cards_freezeCard.
  ///
  /// In en, this message translates to:
  /// **'Freeze Card'**
  String get cards_freezeCard;

  /// No description provided for @cards_unfreezeCard.
  ///
  /// In en, this message translates to:
  /// **'Unfreeze Card'**
  String get cards_unfreezeCard;

  /// No description provided for @cards_freezeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to freeze this card? You can unfreeze it anytime.'**
  String get cards_freezeConfirmation;

  /// No description provided for @cards_unfreezeConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to unfreeze this card?'**
  String get cards_unfreezeConfirmation;

  /// No description provided for @cards_cardFrozen.
  ///
  /// In en, this message translates to:
  /// **'Card frozen successfully'**
  String get cards_cardFrozen;

  /// No description provided for @cards_cardUnfrozen.
  ///
  /// In en, this message translates to:
  /// **'Card unfrozen successfully'**
  String get cards_cardUnfrozen;

  /// No description provided for @cards_copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get cards_copiedToClipboard;

  /// No description provided for @cards_requestInfo.
  ///
  /// In en, this message translates to:
  /// **'Your virtual card will be ready instantly after approval. Requires KYC Level 2.'**
  String get cards_requestInfo;

  /// No description provided for @cards_cardholderName.
  ///
  /// In en, this message translates to:
  /// **'Cardholder Name'**
  String get cards_cardholderName;

  /// No description provided for @cards_cardholderNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter name as it appears on card'**
  String get cards_cardholderNameHint;

  /// No description provided for @cards_nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Cardholder name is required'**
  String get cards_nameRequired;

  /// No description provided for @cards_spendingLimitHint.
  ///
  /// In en, this message translates to:
  /// **'Enter spending limit in USD'**
  String get cards_spendingLimitHint;

  /// No description provided for @cards_limitRequired.
  ///
  /// In en, this message translates to:
  /// **'Spending limit is required'**
  String get cards_limitRequired;

  /// No description provided for @cards_limitInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid spending limit'**
  String get cards_limitInvalid;

  /// No description provided for @cards_limitTooLow.
  ///
  /// In en, this message translates to:
  /// **'Minimum spending limit is \$10'**
  String get cards_limitTooLow;

  /// No description provided for @cards_limitTooHigh.
  ///
  /// In en, this message translates to:
  /// **'Maximum spending limit is \$10,000'**
  String get cards_limitTooHigh;

  /// No description provided for @cards_cardFeatures.
  ///
  /// In en, this message translates to:
  /// **'Card Features'**
  String get cards_cardFeatures;

  /// No description provided for @cards_featureOnlineShopping.
  ///
  /// In en, this message translates to:
  /// **'Shop online worldwide'**
  String get cards_featureOnlineShopping;

  /// No description provided for @cards_featureSecure.
  ///
  /// In en, this message translates to:
  /// **'Secure and encrypted'**
  String get cards_featureSecure;

  /// No description provided for @cards_featureFreeze.
  ///
  /// In en, this message translates to:
  /// **'Freeze and unfreeze instantly'**
  String get cards_featureFreeze;

  /// No description provided for @cards_featureAlerts.
  ///
  /// In en, this message translates to:
  /// **'Real-time transaction alerts'**
  String get cards_featureAlerts;

  /// No description provided for @cards_requestCardSubmit.
  ///
  /// In en, this message translates to:
  /// **'Request Virtual Card'**
  String get cards_requestCardSubmit;

  /// No description provided for @cards_kycRequired.
  ///
  /// In en, this message translates to:
  /// **'KYC Verification Required'**
  String get cards_kycRequired;

  /// No description provided for @cards_kycRequiredDescription.
  ///
  /// In en, this message translates to:
  /// **'You need to complete KYC Level 2 verification to request a virtual card.'**
  String get cards_kycRequiredDescription;

  /// No description provided for @cards_completeKYC.
  ///
  /// In en, this message translates to:
  /// **'Complete KYC'**
  String get cards_completeKYC;

  /// No description provided for @cards_requestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Card requested successfully'**
  String get cards_requestSuccess;

  /// No description provided for @cards_requestFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to request card'**
  String get cards_requestFailed;

  /// No description provided for @cards_cardSettings.
  ///
  /// In en, this message translates to:
  /// **'Card Settings'**
  String get cards_cardSettings;

  /// No description provided for @cards_cardStatus.
  ///
  /// In en, this message translates to:
  /// **'Card Status'**
  String get cards_cardStatus;

  /// No description provided for @cards_statusActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get cards_statusActive;

  /// No description provided for @cards_statusFrozen.
  ///
  /// In en, this message translates to:
  /// **'Frozen'**
  String get cards_statusFrozen;

  /// No description provided for @cards_statusActiveDescription.
  ///
  /// In en, this message translates to:
  /// **'Your card is active and ready to use'**
  String get cards_statusActiveDescription;

  /// No description provided for @cards_statusFrozenDescription.
  ///
  /// In en, this message translates to:
  /// **'Your card is frozen and cannot be used'**
  String get cards_statusFrozenDescription;

  /// No description provided for @cards_currentLimit.
  ///
  /// In en, this message translates to:
  /// **'Current Limit'**
  String get cards_currentLimit;

  /// No description provided for @cards_availableLimit.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get cards_availableLimit;

  /// No description provided for @cards_updateLimit.
  ///
  /// In en, this message translates to:
  /// **'Update Limit'**
  String get cards_updateLimit;

  /// No description provided for @cards_newLimit.
  ///
  /// In en, this message translates to:
  /// **'New Limit'**
  String get cards_newLimit;

  /// No description provided for @cards_limitRange.
  ///
  /// In en, this message translates to:
  /// **'Limit must be between \$10 and \$10,000'**
  String get cards_limitRange;

  /// No description provided for @cards_limitUpdated.
  ///
  /// In en, this message translates to:
  /// **'Spending limit updated successfully'**
  String get cards_limitUpdated;

  /// No description provided for @cards_dangerZone.
  ///
  /// In en, this message translates to:
  /// **'Danger Zone'**
  String get cards_dangerZone;

  /// No description provided for @cards_blockCard.
  ///
  /// In en, this message translates to:
  /// **'Block Card'**
  String get cards_blockCard;

  /// No description provided for @cards_blockCardDescription.
  ///
  /// In en, this message translates to:
  /// **'Permanently block this card. This action cannot be undone.'**
  String get cards_blockCardDescription;

  /// No description provided for @cards_blockCardButton.
  ///
  /// In en, this message translates to:
  /// **'Block Card Permanently'**
  String get cards_blockCardButton;

  /// No description provided for @cards_blockCardConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently block this card? This action cannot be undone and you\'ll need to request a new card.'**
  String get cards_blockCardConfirmation;

  /// No description provided for @cards_cardBlocked.
  ///
  /// In en, this message translates to:
  /// **'Card blocked successfully'**
  String get cards_cardBlocked;

  /// No description provided for @cards_transactions.
  ///
  /// In en, this message translates to:
  /// **'Card Transactions'**
  String get cards_transactions;

  /// No description provided for @cards_noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No Transactions'**
  String get cards_noTransactions;

  /// No description provided for @cards_noTransactionsDescription.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t made any purchases with this card yet'**
  String get cards_noTransactionsDescription;

  /// Insights screen title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights_title;

  /// Week period label
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get insights_period_week;

  /// Month period label
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get insights_period_month;

  /// Year period label
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get insights_period_year;

  /// Summary section title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get insights_summary;

  /// Total spent label
  ///
  /// In en, this message translates to:
  /// **'Total Spent'**
  String get insights_total_spent;

  /// Total received label
  ///
  /// In en, this message translates to:
  /// **'Total Received'**
  String get insights_total_received;

  /// Net flow label
  ///
  /// In en, this message translates to:
  /// **'Net Flow'**
  String get insights_net_flow;

  /// Categories section title
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get insights_categories;

  /// Spending trend section title
  ///
  /// In en, this message translates to:
  /// **'Spending Trend'**
  String get insights_spending_trend;

  /// Top recipients section title
  ///
  /// In en, this message translates to:
  /// **'Top Recipients'**
  String get insights_top_recipients;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Insights Yet'**
  String get insights_empty_title;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Start using JoonaPay to see your spending insights and analytics'**
  String get insights_empty_description;

  /// Export report button
  ///
  /// In en, this message translates to:
  /// **'Export Report'**
  String get insights_export_report;

  /// Daily spending section title
  ///
  /// In en, this message translates to:
  /// **'Daily Spending'**
  String get insights_daily_spending;

  /// Daily average spending label
  ///
  /// In en, this message translates to:
  /// **'Daily Avg'**
  String get insights_daily_average;

  /// Highest spending day label
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get insights_highest_day;

  /// Income vs expenses chart title
  ///
  /// In en, this message translates to:
  /// **'Income vs Expenses'**
  String get insights_income_vs_expenses;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get insights_income;

  /// Expenses label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get insights_expenses;

  /// Contacts screen title
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contacts_title;

  /// Search contacts placeholder
  ///
  /// In en, this message translates to:
  /// **'Search contacts'**
  String get contacts_search;

  /// JoonaPay users section title
  ///
  /// In en, this message translates to:
  /// **'On JoonaPay'**
  String get contacts_on_joonapay;

  /// Non-users section title
  ///
  /// In en, this message translates to:
  /// **'Invite to JoonaPay'**
  String get contacts_invite_to_joonapay;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No contacts found. Pull down to refresh.'**
  String get contacts_empty;

  /// No search results message
  ///
  /// In en, this message translates to:
  /// **'No contacts match your search'**
  String get contacts_no_results;

  /// Sync success message
  ///
  /// In en, this message translates to:
  /// **'Found {count} JoonaPay users!'**
  String contacts_sync_success(int count);

  /// Last synced just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get contacts_synced_just_now;

  /// Last synced minutes ago
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String contacts_synced_minutes_ago(int minutes);

  /// Last synced hours ago
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String contacts_synced_hours_ago(int hours);

  /// Last synced days ago
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String contacts_synced_days_ago(int days);

  /// Permission screen title
  ///
  /// In en, this message translates to:
  /// **'Find Your Friends'**
  String get contacts_permission_title;

  /// Permission screen subtitle
  ///
  /// In en, this message translates to:
  /// **'See which of your contacts are already on JoonaPay'**
  String get contacts_permission_subtitle;

  /// Permission benefit 1 title
  ///
  /// In en, this message translates to:
  /// **'Find Friends Instantly'**
  String get contacts_permission_benefit1_title;

  /// Permission benefit 1 description
  ///
  /// In en, this message translates to:
  /// **'See which contacts are on JoonaPay and send money instantly'**
  String get contacts_permission_benefit1_desc;

  /// Permission benefit 2 title
  ///
  /// In en, this message translates to:
  /// **'Private & Secure'**
  String get contacts_permission_benefit2_title;

  /// Permission benefit 2 description
  ///
  /// In en, this message translates to:
  /// **'We never store your contacts. Phone numbers are hashed before syncing.'**
  String get contacts_permission_benefit2_desc;

  /// Permission benefit 3 title
  ///
  /// In en, this message translates to:
  /// **'Always Up to Date'**
  String get contacts_permission_benefit3_title;

  /// Permission benefit 3 description
  ///
  /// In en, this message translates to:
  /// **'Automatically sync when new contacts join JoonaPay'**
  String get contacts_permission_benefit3_desc;

  /// Allow permission button
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get contacts_permission_allow;

  /// Skip permission button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get contacts_permission_later;

  /// Permission denied dialog title
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get contacts_permission_denied_title;

  /// Permission denied dialog message
  ///
  /// In en, this message translates to:
  /// **'To find your friends on JoonaPay, please allow contact access in Settings.'**
  String get contacts_permission_denied_message;

  /// Invite sheet title
  ///
  /// In en, this message translates to:
  /// **'Invite {name} to JoonaPay'**
  String contacts_invite_title(String name);

  /// Invite sheet subtitle
  ///
  /// In en, this message translates to:
  /// **'Send money to friends instantly with JoonaPay'**
  String get contacts_invite_subtitle;

  /// Invite via SMS option
  ///
  /// In en, this message translates to:
  /// **'Send SMS Invite'**
  String get contacts_invite_via_sms;

  /// Invite via SMS description
  ///
  /// In en, this message translates to:
  /// **'Send an SMS with your invite link'**
  String get contacts_invite_via_sms_desc;

  /// Invite via WhatsApp option
  ///
  /// In en, this message translates to:
  /// **'Invite via WhatsApp'**
  String get contacts_invite_via_whatsapp;

  /// Invite via WhatsApp description
  ///
  /// In en, this message translates to:
  /// **'Share invite link on WhatsApp'**
  String get contacts_invite_via_whatsapp_desc;

  /// Copy invite link option
  ///
  /// In en, this message translates to:
  /// **'Copy Invite Link'**
  String get contacts_invite_copy_link;

  /// Copy invite link description
  ///
  /// In en, this message translates to:
  /// **'Copy link to share anywhere'**
  String get contacts_invite_copy_link_desc;

  /// Default invite message
  ///
  /// In en, this message translates to:
  /// **'Hey! I\'m using JoonaPay to send money instantly. Join me and get your first transfer free! Download: https://joonapay.com/app'**
  String get contacts_invite_message;

  /// Recurring transfers screen title
  ///
  /// In en, this message translates to:
  /// **'Recurring Transfers'**
  String get recurringTransfers_title;

  /// Create new recurring transfer button
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get recurringTransfers_createNew;

  /// Create recurring transfer screen title
  ///
  /// In en, this message translates to:
  /// **'Create Recurring Transfer'**
  String get recurringTransfers_createTitle;

  /// Create first recurring transfer button
  ///
  /// In en, this message translates to:
  /// **'Create Your First'**
  String get recurringTransfers_createFirst;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Recurring Transfers'**
  String get recurringTransfers_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Set up automatic transfers to send money regularly to your loved ones'**
  String get recurringTransfers_emptyMessage;

  /// Active transfers section
  ///
  /// In en, this message translates to:
  /// **'Active Transfers'**
  String get recurringTransfers_active;

  /// Paused transfers section
  ///
  /// In en, this message translates to:
  /// **'Paused Transfers'**
  String get recurringTransfers_paused;

  /// Upcoming executions section
  ///
  /// In en, this message translates to:
  /// **'Upcoming This Week'**
  String get recurringTransfers_upcoming;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recurringTransfers_amount;

  /// Frequency label
  ///
  /// In en, this message translates to:
  /// **'Frequency'**
  String get recurringTransfers_frequency;

  /// Next execution label
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get recurringTransfers_nextExecution;

  /// Recipient section header
  ///
  /// In en, this message translates to:
  /// **'Recipient Details'**
  String get recurringTransfers_recipientSection;

  /// Amount section header
  ///
  /// In en, this message translates to:
  /// **'Transfer Amount'**
  String get recurringTransfers_amountSection;

  /// Schedule section header
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get recurringTransfers_scheduleSection;

  /// Start date label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get recurringTransfers_startDate;

  /// End condition label
  ///
  /// In en, this message translates to:
  /// **'End Condition'**
  String get recurringTransfers_endCondition;

  /// Never end option
  ///
  /// In en, this message translates to:
  /// **'Never (until cancelled)'**
  String get recurringTransfers_neverEnd;

  /// After occurrences option
  ///
  /// In en, this message translates to:
  /// **'After specific number of transfers'**
  String get recurringTransfers_afterOccurrences;

  /// Until date option
  ///
  /// In en, this message translates to:
  /// **'Until specific date'**
  String get recurringTransfers_untilDate;

  /// Occurrences count label
  ///
  /// In en, this message translates to:
  /// **'Number of times'**
  String get recurringTransfers_occurrencesCount;

  /// Select date placeholder
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get recurringTransfers_selectDate;

  /// Note field label
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get recurringTransfers_note;

  /// Note field hint
  ///
  /// In en, this message translates to:
  /// **'e.g., Monthly rent, Weekly allowance'**
  String get recurringTransfers_noteHint;

  /// Create button label
  ///
  /// In en, this message translates to:
  /// **'Create Recurring Transfer'**
  String get recurringTransfers_create;

  /// Create success message
  ///
  /// In en, this message translates to:
  /// **'Recurring transfer created successfully'**
  String get recurringTransfers_createSuccess;

  /// Create error message
  ///
  /// In en, this message translates to:
  /// **'Failed to create recurring transfer'**
  String get recurringTransfers_createError;

  /// Detail screen title
  ///
  /// In en, this message translates to:
  /// **'Transfer Details'**
  String get recurringTransfers_details;

  /// Schedule label
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get recurringTransfers_schedule;

  /// Upcoming executions section
  ///
  /// In en, this message translates to:
  /// **'Next Scheduled'**
  String get recurringTransfers_upcomingExecutions;

  /// Statistics section
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get recurringTransfers_statistics;

  /// Executed count label
  ///
  /// In en, this message translates to:
  /// **'Executed'**
  String get recurringTransfers_executed;

  /// Remaining count label
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get recurringTransfers_remaining;

  /// Execution history section
  ///
  /// In en, this message translates to:
  /// **'Execution History'**
  String get recurringTransfers_executionHistory;

  /// Execution success label
  ///
  /// In en, this message translates to:
  /// **'Completed successfully'**
  String get recurringTransfers_executionSuccess;

  /// Execution failed label
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get recurringTransfers_executionFailed;

  /// Pause button label
  ///
  /// In en, this message translates to:
  /// **'Pause Transfer'**
  String get recurringTransfers_pause;

  /// Resume button label
  ///
  /// In en, this message translates to:
  /// **'Resume Transfer'**
  String get recurringTransfers_resume;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel Transfer'**
  String get recurringTransfers_cancel;

  /// Pause success message
  ///
  /// In en, this message translates to:
  /// **'Transfer paused successfully'**
  String get recurringTransfers_pauseSuccess;

  /// Pause error message
  ///
  /// In en, this message translates to:
  /// **'Failed to pause transfer'**
  String get recurringTransfers_pauseError;

  /// Resume success message
  ///
  /// In en, this message translates to:
  /// **'Transfer resumed successfully'**
  String get recurringTransfers_resumeSuccess;

  /// Resume error message
  ///
  /// In en, this message translates to:
  /// **'Failed to resume transfer'**
  String get recurringTransfers_resumeError;

  /// Cancel confirmation dialog title
  ///
  /// In en, this message translates to:
  /// **'Cancel Recurring Transfer?'**
  String get recurringTransfers_cancelConfirmTitle;

  /// Cancel confirmation dialog message
  ///
  /// In en, this message translates to:
  /// **'This will permanently cancel this recurring transfer. This action cannot be undone.'**
  String get recurringTransfers_cancelConfirmMessage;

  /// Confirm cancel button
  ///
  /// In en, this message translates to:
  /// **'Yes, Cancel'**
  String get recurringTransfers_confirmCancel;

  /// Cancel success message
  ///
  /// In en, this message translates to:
  /// **'Transfer cancelled successfully'**
  String get recurringTransfers_cancelSuccess;

  /// Cancel error message
  ///
  /// In en, this message translates to:
  /// **'Failed to cancel transfer'**
  String get recurringTransfers_cancelError;

  /// Required field validation
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// Invalid amount validation
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get validation_invalidAmount;

  /// Today label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// Tomorrow label
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get common_tomorrow;

  /// Limits screen title
  ///
  /// In en, this message translates to:
  /// **'Transaction Limits'**
  String get limits_title;

  /// Daily limits section title
  ///
  /// In en, this message translates to:
  /// **'Daily Limits'**
  String get limits_dailyLimits;

  /// Monthly limits section title
  ///
  /// In en, this message translates to:
  /// **'Monthly Limits'**
  String get limits_monthlyLimits;

  /// Daily transactions limit label
  ///
  /// In en, this message translates to:
  /// **'Daily Transactions'**
  String get limits_dailyTransactions;

  /// Monthly transactions limit label
  ///
  /// In en, this message translates to:
  /// **'Monthly Transactions'**
  String get limits_monthlyTransactions;

  /// Remaining limit text
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get limits_remaining;

  /// Of text in limit display
  ///
  /// In en, this message translates to:
  /// **'of'**
  String get limits_of;

  /// Upgrade prompt title
  ///
  /// In en, this message translates to:
  /// **'Need higher limits?'**
  String get limits_upgradeTitle;

  /// Upgrade prompt description
  ///
  /// In en, this message translates to:
  /// **'Verify your identity to unlock premium limits'**
  String get limits_upgradeDescription;

  /// Upgrade to tier text
  ///
  /// In en, this message translates to:
  /// **'Upgrade to'**
  String get limits_upgradeToTier;

  /// Day text for limits
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get limits_day;

  /// Month text for limits
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get limits_month;

  /// About limits info card title
  ///
  /// In en, this message translates to:
  /// **'About Limits'**
  String get limits_aboutTitle;

  /// About limits info card description
  ///
  /// In en, this message translates to:
  /// **'Limits reset at midnight UTC. Complete KYC verification to increase your limits.'**
  String get limits_aboutDescription;

  /// KYC prompt text
  ///
  /// In en, this message translates to:
  /// **'Complete KYC for higher limits'**
  String get limits_kycPrompt;

  /// Max tier reached text
  ///
  /// In en, this message translates to:
  /// **'You have the highest tier'**
  String get limits_maxTier;

  /// Single transaction limit label
  ///
  /// In en, this message translates to:
  /// **'Single Transaction'**
  String get limits_singleTransaction;

  /// Withdrawal limit label
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Limit'**
  String get limits_withdrawal;

  /// Reset time prefix
  ///
  /// In en, this message translates to:
  /// **'Resets in'**
  String get limits_resetIn;

  /// Hours label
  ///
  /// In en, this message translates to:
  /// **'hours'**
  String get limits_hours;

  /// Minutes label
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get limits_minutes;

  /// Other limits section title
  ///
  /// In en, this message translates to:
  /// **'Other Limits'**
  String get limits_otherLimits;

  /// No data message
  ///
  /// In en, this message translates to:
  /// **'No limit data available'**
  String get limits_noData;

  /// Limit reached warning title
  ///
  /// In en, this message translates to:
  /// **'Limit Reached'**
  String get limits_limitReached;

  /// Daily limit reached message
  ///
  /// In en, this message translates to:
  /// **'You have reached your daily transaction limit of'**
  String get limits_dailyLimitReached;

  /// Monthly limit reached message
  ///
  /// In en, this message translates to:
  /// **'You have reached your monthly transaction limit of'**
  String get limits_monthlyLimitReached;

  /// Upgrade to increase limits text
  ///
  /// In en, this message translates to:
  /// **'Upgrade your account to increase limits'**
  String get limits_upgradeToIncrease;

  /// Approaching limit warning
  ///
  /// In en, this message translates to:
  /// **'Approaching Limit'**
  String get limits_approachingLimit;

  /// Remaining today text
  ///
  /// In en, this message translates to:
  /// **'remaining today'**
  String get limits_remainingToday;

  /// Remaining this month text
  ///
  /// In en, this message translates to:
  /// **'remaining this month'**
  String get limits_remainingThisMonth;

  /// Payment Links feature title
  ///
  /// In en, this message translates to:
  /// **'Payment Links'**
  String get paymentLinks_title;

  /// Create payment link button
  ///
  /// In en, this message translates to:
  /// **'Create Payment Link'**
  String get paymentLinks_createLink;

  /// Create new payment link button
  ///
  /// In en, this message translates to:
  /// **'Create New'**
  String get paymentLinks_createNew;

  /// Create payment link description
  ///
  /// In en, this message translates to:
  /// **'Generate a shareable payment link to receive money from anyone'**
  String get paymentLinks_createDescription;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get paymentLinks_amount;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get paymentLinks_description;

  /// Description hint text
  ///
  /// In en, this message translates to:
  /// **'What is this payment for? (optional)'**
  String get paymentLinks_descriptionHint;

  /// Expiry label
  ///
  /// In en, this message translates to:
  /// **'Link expires in'**
  String get paymentLinks_expiresIn;

  /// 6 hours option
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get paymentLinks_6hours;

  /// 24 hours option
  ///
  /// In en, this message translates to:
  /// **'24 hours'**
  String get paymentLinks_24hours;

  /// 3 days option
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get paymentLinks_3days;

  /// 7 days option
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get paymentLinks_7days;

  /// Payment link info message
  ///
  /// In en, this message translates to:
  /// **'Anyone with this link can pay you. Link expires automatically.'**
  String get paymentLinks_info;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get paymentLinks_invalidAmount;

  /// Minimum amount error
  ///
  /// In en, this message translates to:
  /// **'Minimum amount is CFA 100'**
  String get paymentLinks_minimumAmount;

  /// Link created title
  ///
  /// In en, this message translates to:
  /// **'Link Created'**
  String get paymentLinks_linkCreated;

  /// Link ready title
  ///
  /// In en, this message translates to:
  /// **'Your payment link is ready!'**
  String get paymentLinks_linkReadyTitle;

  /// Link ready description
  ///
  /// In en, this message translates to:
  /// **'Share this link with anyone to receive payment'**
  String get paymentLinks_linkReadyDescription;

  /// Requested amount label
  ///
  /// In en, this message translates to:
  /// **'Requested Amount'**
  String get paymentLinks_requestedAmount;

  /// Share link button
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get paymentLinks_shareLink;

  /// View details button
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get paymentLinks_viewDetails;

  /// Copy link option
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get paymentLinks_copyLink;

  /// Share on WhatsApp option
  ///
  /// In en, this message translates to:
  /// **'Share on WhatsApp'**
  String get paymentLinks_shareWhatsApp;

  /// Share via SMS option
  ///
  /// In en, this message translates to:
  /// **'Share via SMS'**
  String get paymentLinks_shareSMS;

  /// Share other way option
  ///
  /// In en, this message translates to:
  /// **'Share Other Way'**
  String get paymentLinks_shareOther;

  /// Link copied message
  ///
  /// In en, this message translates to:
  /// **'Link copied to clipboard'**
  String get paymentLinks_linkCopied;

  /// Payment request subject
  ///
  /// In en, this message translates to:
  /// **'Payment Request'**
  String get paymentLinks_paymentRequest;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No payment links yet'**
  String get paymentLinks_emptyTitle;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Create your first payment link to start receiving money easily'**
  String get paymentLinks_emptyDescription;

  /// Create first link button
  ///
  /// In en, this message translates to:
  /// **'Create Your First Link'**
  String get paymentLinks_createFirst;

  /// Active links stat label
  ///
  /// In en, this message translates to:
  /// **'Active Links'**
  String get paymentLinks_activeLinks;

  /// Paid links stat label
  ///
  /// In en, this message translates to:
  /// **'Paid Links'**
  String get paymentLinks_paidLinks;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get paymentLinks_filterAll;

  /// Pending filter option
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get paymentLinks_filterPending;

  /// Viewed filter option
  ///
  /// In en, this message translates to:
  /// **'Viewed'**
  String get paymentLinks_filterViewed;

  /// Paid filter option
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentLinks_filterPaid;

  /// Expired filter option
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get paymentLinks_filterExpired;

  /// No links with filter message
  ///
  /// In en, this message translates to:
  /// **'No links match this filter'**
  String get paymentLinks_noLinksWithFilter;

  /// Link details title
  ///
  /// In en, this message translates to:
  /// **'Link Details'**
  String get paymentLinks_linkDetails;

  /// Link code label
  ///
  /// In en, this message translates to:
  /// **'Link Code'**
  String get paymentLinks_linkCode;

  /// Link URL label
  ///
  /// In en, this message translates to:
  /// **'Link URL'**
  String get paymentLinks_linkUrl;

  /// View count label
  ///
  /// In en, this message translates to:
  /// **'View Count'**
  String get paymentLinks_viewCount;

  /// Created label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get paymentLinks_created;

  /// Expires label
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get paymentLinks_expires;

  /// Paid by label
  ///
  /// In en, this message translates to:
  /// **'Paid By'**
  String get paymentLinks_paidBy;

  /// Paid at label
  ///
  /// In en, this message translates to:
  /// **'Paid At'**
  String get paymentLinks_paidAt;

  /// Cancel link button
  ///
  /// In en, this message translates to:
  /// **'Cancel Link'**
  String get paymentLinks_cancelLink;

  /// Cancel confirmation title
  ///
  /// In en, this message translates to:
  /// **'Cancel Link?'**
  String get paymentLinks_cancelConfirmTitle;

  /// Cancel confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this payment link? This action cannot be undone.'**
  String get paymentLinks_cancelConfirmMessage;

  /// Link cancelled message
  ///
  /// In en, this message translates to:
  /// **'Payment link cancelled'**
  String get paymentLinks_linkCancelled;

  /// View transaction button
  ///
  /// In en, this message translates to:
  /// **'View Transaction'**
  String get paymentLinks_viewTransaction;

  /// Pay via link screen title
  ///
  /// In en, this message translates to:
  /// **'Pay via Link'**
  String get paymentLinks_payTitle;

  /// Paying to label
  ///
  /// In en, this message translates to:
  /// **'Paying to'**
  String get paymentLinks_payingTo;

  /// Pay amount button
  ///
  /// In en, this message translates to:
  /// **'Pay {amount}'**
  String paymentLinks_payAmount(String amount);

  /// Payment for label
  ///
  /// In en, this message translates to:
  /// **'Payment for'**
  String get paymentLinks_paymentFor;

  /// Link expired error title
  ///
  /// In en, this message translates to:
  /// **'Link Expired'**
  String get paymentLinks_linkExpiredTitle;

  /// Link expired error message
  ///
  /// In en, this message translates to:
  /// **'This payment link has expired and can no longer be used'**
  String get paymentLinks_linkExpiredMessage;

  /// Link already paid title
  ///
  /// In en, this message translates to:
  /// **'Already Paid'**
  String get paymentLinks_linkPaidTitle;

  /// Link already paid message
  ///
  /// In en, this message translates to:
  /// **'This payment link has already been paid'**
  String get paymentLinks_linkPaidMessage;

  /// Link not found title
  ///
  /// In en, this message translates to:
  /// **'Link Not Found'**
  String get paymentLinks_linkNotFoundTitle;

  /// Link not found message
  ///
  /// In en, this message translates to:
  /// **'This payment link doesn\'t exist or has been cancelled'**
  String get paymentLinks_linkNotFoundMessage;

  /// Payment successful title
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get paymentLinks_paymentSuccess;

  /// Payment successful message
  ///
  /// In en, this message translates to:
  /// **'Your payment has been sent successfully'**
  String get paymentLinks_paymentSuccessMessage;

  /// Insufficient balance error
  ///
  /// In en, this message translates to:
  /// **'Insufficient balance to complete this payment'**
  String get paymentLinks_insufficientBalance;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// Unknown value
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get common_unknown;

  /// Yes button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// Offline banner message
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offline_youreOffline;

  /// Offline banner with pending count
  ///
  /// In en, this message translates to:
  /// **'You\'re offline · {count} pending'**
  String offline_youreOfflineWithPending(int count);

  /// Syncing indicator message
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get offline_syncing;

  /// Pending transfer label
  ///
  /// In en, this message translates to:
  /// **'Pending Transfer'**
  String get offline_pendingTransfer;

  /// Transfer queued success message
  ///
  /// In en, this message translates to:
  /// **'Transfer queued'**
  String get offline_transferQueued;

  /// Transfer queued description
  ///
  /// In en, this message translates to:
  /// **'Your transfer will be sent when you\'re back online'**
  String get offline_transferQueuedDesc;

  /// View pending transfers button
  ///
  /// In en, this message translates to:
  /// **'View Pending'**
  String get offline_viewPending;

  /// Retry failed transfer button
  ///
  /// In en, this message translates to:
  /// **'Retry Failed'**
  String get offline_retryFailed;

  /// Cancel pending transfer button
  ///
  /// In en, this message translates to:
  /// **'Cancel Transfer'**
  String get offline_cancelTransfer;

  /// No connection message
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get offline_noConnection;

  /// Check connection message
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again'**
  String get offline_checkConnection;

  /// Cache data indicator
  ///
  /// In en, this message translates to:
  /// **'Showing cached data'**
  String get offline_cacheData;

  /// Last sync time
  ///
  /// In en, this message translates to:
  /// **'Last synced: {time}'**
  String offline_lastSynced(String time);

  /// Referrals page title
  ///
  /// In en, this message translates to:
  /// **'Refer & Earn'**
  String get referrals_title;

  /// Referrals page subtitle
  ///
  /// In en, this message translates to:
  /// **'Invite friends and earn rewards together'**
  String get referrals_subtitle;

  /// Referral earn amount
  ///
  /// In en, this message translates to:
  /// **'Earn \$5'**
  String get referrals_earnAmount;

  /// Referral earn description
  ///
  /// In en, this message translates to:
  /// **'for each friend who signs up and makes their first deposit'**
  String get referrals_earnDescription;

  /// Your referral code label
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get referrals_yourCode;

  /// Share link button
  ///
  /// In en, this message translates to:
  /// **'Share Link'**
  String get referrals_shareLink;

  /// Invite button
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get referrals_invite;

  /// Your rewards section title
  ///
  /// In en, this message translates to:
  /// **'Your Rewards'**
  String get referrals_yourRewards;

  /// Friends invited label
  ///
  /// In en, this message translates to:
  /// **'Friends Invited'**
  String get referrals_friendsInvited;

  /// Total earned label
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get referrals_totalEarned;

  /// How it works section title
  ///
  /// In en, this message translates to:
  /// **'How it works'**
  String get referrals_howItWorks;

  /// Step 1 title
  ///
  /// In en, this message translates to:
  /// **'Share your code'**
  String get referrals_step1Title;

  /// Step 1 description
  ///
  /// In en, this message translates to:
  /// **'Send your referral code or link to friends'**
  String get referrals_step1Description;

  /// Step 2 title
  ///
  /// In en, this message translates to:
  /// **'Friend signs up'**
  String get referrals_step2Title;

  /// Step 2 description
  ///
  /// In en, this message translates to:
  /// **'They create an account using your code'**
  String get referrals_step2Description;

  /// Step 3 title
  ///
  /// In en, this message translates to:
  /// **'First deposit'**
  String get referrals_step3Title;

  /// Step 3 description
  ///
  /// In en, this message translates to:
  /// **'They make their first deposit of \$10 or more'**
  String get referrals_step3Description;

  /// Step 4 title
  ///
  /// In en, this message translates to:
  /// **'You both earn!'**
  String get referrals_step4Title;

  /// Step 4 description
  ///
  /// In en, this message translates to:
  /// **'You get \$5, and your friend gets \$5 too'**
  String get referrals_step4Description;

  /// Referral history section title
  ///
  /// In en, this message translates to:
  /// **'Referral History'**
  String get referrals_history;

  /// No referrals message
  ///
  /// In en, this message translates to:
  /// **'No referrals yet'**
  String get referrals_noReferrals;

  /// Start inviting message
  ///
  /// In en, this message translates to:
  /// **'Start inviting friends to see your rewards here'**
  String get referrals_startInviting;

  /// Code copied message
  ///
  /// In en, this message translates to:
  /// **'Referral code copied!'**
  String get referrals_codeCopied;

  /// Share message template
  ///
  /// In en, this message translates to:
  /// **'Join JoonaPay and get \$5 bonus on your first deposit! Use my referral code: {code}\n\nDownload now: https://joonapay.com/download'**
  String referrals_shareMessage(String code);

  /// Share subject
  ///
  /// In en, this message translates to:
  /// **'Join JoonaPay - Get \$5 bonus!'**
  String get referrals_shareSubject;

  /// Invite coming soon message
  ///
  /// In en, this message translates to:
  /// **'Contact invite coming soon'**
  String get referrals_inviteComingSoon;

  /// Analytics page title
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics_title;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get analytics_income;

  /// Expenses label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get analytics_expenses;

  /// Net change label
  ///
  /// In en, this message translates to:
  /// **'Net Change'**
  String get analytics_netChange;

  /// Surplus label
  ///
  /// In en, this message translates to:
  /// **'Surplus'**
  String get analytics_surplus;

  /// Deficit label
  ///
  /// In en, this message translates to:
  /// **'Deficit'**
  String get analytics_deficit;

  /// Spending by category title
  ///
  /// In en, this message translates to:
  /// **'Spending by Category'**
  String get analytics_spendingByCategory;

  /// Category details title
  ///
  /// In en, this message translates to:
  /// **'Category Details'**
  String get analytics_categoryDetails;

  /// Transaction frequency title
  ///
  /// In en, this message translates to:
  /// **'Transaction Frequency'**
  String get analytics_transactionFrequency;

  /// Insights title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get analytics_insights;

  /// 7 days period
  ///
  /// In en, this message translates to:
  /// **'7 Days'**
  String get analytics_period7Days;

  /// 30 days period
  ///
  /// In en, this message translates to:
  /// **'30 Days'**
  String get analytics_period30Days;

  /// 90 days period
  ///
  /// In en, this message translates to:
  /// **'90 Days'**
  String get analytics_period90Days;

  /// 1 year period
  ///
  /// In en, this message translates to:
  /// **'1 Year'**
  String get analytics_period1Year;

  /// Transfers category
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get analytics_categoryTransfers;

  /// Withdrawals category
  ///
  /// In en, this message translates to:
  /// **'Withdrawals'**
  String get analytics_categoryWithdrawals;

  /// Bills category
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get analytics_categoryBills;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get analytics_categoryOther;

  /// Transactions count
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String analytics_transactions(int count);

  /// Spending down insight title
  ///
  /// In en, this message translates to:
  /// **'Spending Down'**
  String get analytics_insightSpendingDown;

  /// Spending down insight description
  ///
  /// In en, this message translates to:
  /// **'Your spending is 5.2% lower than last month. Great job!'**
  String get analytics_insightSpendingDownDesc;

  /// Savings opportunity insight title
  ///
  /// In en, this message translates to:
  /// **'Savings Opportunity'**
  String get analytics_insightSavings;

  /// Savings opportunity insight description
  ///
  /// In en, this message translates to:
  /// **'You could save \$50/month by reducing withdrawal fees.'**
  String get analytics_insightSavingsDesc;

  /// Peak activity insight title
  ///
  /// In en, this message translates to:
  /// **'Peak Activity'**
  String get analytics_insightPeakActivity;

  /// Peak activity insight description
  ///
  /// In en, this message translates to:
  /// **'Most of your transactions happen on Thursdays.'**
  String get analytics_insightPeakActivityDesc;

  /// Exporting report message
  ///
  /// In en, this message translates to:
  /// **'Exporting report...'**
  String get analytics_exportingReport;

  /// Currency converter title
  ///
  /// In en, this message translates to:
  /// **'Currency Converter'**
  String get converter_title;

  /// From currency label
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get converter_from;

  /// To currency label
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get converter_to;

  /// Select currency title
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get converter_selectCurrency;

  /// Rate information title
  ///
  /// In en, this message translates to:
  /// **'Rate Information'**
  String get converter_rateInfo;

  /// Rate disclaimer text
  ///
  /// In en, this message translates to:
  /// **'Exchange rates are for informational purposes only and may differ from actual transaction rates. Rates are updated every hour.'**
  String get converter_rateDisclaimer;

  /// Quick amounts title
  ///
  /// In en, this message translates to:
  /// **'Quick Amounts'**
  String get converter_quickAmounts;

  /// Popular currencies title
  ///
  /// In en, this message translates to:
  /// **'Popular Currencies'**
  String get converter_popularCurrencies;

  /// Per USDC label
  ///
  /// In en, this message translates to:
  /// **'per USDC'**
  String get converter_perUsdc;

  /// Rates updated message
  ///
  /// In en, this message translates to:
  /// **'Exchange rates updated'**
  String get converter_ratesUpdated;

  /// Updated just now label
  ///
  /// In en, this message translates to:
  /// **'Updated just now'**
  String get converter_updatedJustNow;

  /// Exchange rate display
  ///
  /// In en, this message translates to:
  /// **'1 {from} = {rate} {to}'**
  String converter_exchangeRate(String from, String rate, String to);

  /// US Dollar
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currency_usd;

  /// USD Coin
  ///
  /// In en, this message translates to:
  /// **'USD Coin'**
  String get currency_usdc;

  /// Euro
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currency_eur;

  /// British Pound
  ///
  /// In en, this message translates to:
  /// **'British Pound'**
  String get currency_gbp;

  /// West African CFA Franc
  ///
  /// In en, this message translates to:
  /// **'West African CFA Franc'**
  String get currency_xof;

  /// Nigerian Naira
  ///
  /// In en, this message translates to:
  /// **'Nigerian Naira'**
  String get currency_ngn;

  /// Kenyan Shilling
  ///
  /// In en, this message translates to:
  /// **'Kenyan Shilling'**
  String get currency_kes;

  /// South African Rand
  ///
  /// In en, this message translates to:
  /// **'South African Rand'**
  String get currency_zar;

  /// Ghanaian Cedi
  ///
  /// In en, this message translates to:
  /// **'Ghanaian Cedi'**
  String get currency_ghs;

  /// Account type setting
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get settings_accountType;

  /// Personal account type
  ///
  /// In en, this message translates to:
  /// **'Personal'**
  String get settings_personalAccount;

  /// Business account type
  ///
  /// In en, this message translates to:
  /// **'Business'**
  String get settings_businessAccount;

  /// Account type selector title
  ///
  /// In en, this message translates to:
  /// **'Select Account Type'**
  String get settings_selectAccountType;

  /// Personal account description
  ///
  /// In en, this message translates to:
  /// **'For individual use'**
  String get settings_personalAccountDescription;

  /// Business account description
  ///
  /// In en, this message translates to:
  /// **'For business operations'**
  String get settings_businessAccountDescription;

  /// Success message when switching to personal
  ///
  /// In en, this message translates to:
  /// **'Switched to Personal account'**
  String get settings_switchedToPersonal;

  /// Success message when switching to business
  ///
  /// In en, this message translates to:
  /// **'Switched to Business account'**
  String get settings_switchedToBusiness;

  /// Business setup screen title
  ///
  /// In en, this message translates to:
  /// **'Business Setup'**
  String get business_setupTitle;

  /// Business setup description
  ///
  /// In en, this message translates to:
  /// **'Set up your business profile to unlock business features'**
  String get business_setupDescription;

  /// Business name field
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get business_businessName;

  /// Business registration number field
  ///
  /// In en, this message translates to:
  /// **'Registration Number'**
  String get business_registrationNumber;

  /// Business type field
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get business_businessType;

  /// Business address field
  ///
  /// In en, this message translates to:
  /// **'Business Address'**
  String get business_businessAddress;

  /// Tax ID field
  ///
  /// In en, this message translates to:
  /// **'Tax ID'**
  String get business_taxId;

  /// KYB verification note
  ///
  /// In en, this message translates to:
  /// **'Your business will need to undergo verification (KYB) before you can access all business features.'**
  String get business_verificationNote;

  /// Complete setup button
  ///
  /// In en, this message translates to:
  /// **'Complete Setup'**
  String get business_completeSetup;

  /// Success message after setup
  ///
  /// In en, this message translates to:
  /// **'Business profile created successfully'**
  String get business_setupSuccess;

  /// Business profile screen title
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get business_profileTitle;

  /// Message when no business profile exists
  ///
  /// In en, this message translates to:
  /// **'No business profile found'**
  String get business_noProfile;

  /// Button to start business setup
  ///
  /// In en, this message translates to:
  /// **'Set Up Business Profile'**
  String get business_setupNow;

  /// Business verification status - verified
  ///
  /// In en, this message translates to:
  /// **'Business Verified'**
  String get business_verified;

  /// Verified business description
  ///
  /// In en, this message translates to:
  /// **'Your business has been successfully verified'**
  String get business_verifiedDescription;

  /// Business verification status - pending
  ///
  /// In en, this message translates to:
  /// **'Verification Pending'**
  String get business_verificationPending;

  /// Pending verification description
  ///
  /// In en, this message translates to:
  /// **'Your business verification is under review'**
  String get business_verificationPendingDescription;

  /// Business information section title
  ///
  /// In en, this message translates to:
  /// **'Business Information'**
  String get business_information;

  /// Complete KYB button
  ///
  /// In en, this message translates to:
  /// **'Complete Business Verification'**
  String get business_completeVerification;

  /// KYB description
  ///
  /// In en, this message translates to:
  /// **'Verify your business to unlock all features'**
  String get business_kybDescription;

  /// KYB dialog title
  ///
  /// In en, this message translates to:
  /// **'Business Verification (KYB)'**
  String get business_kybTitle;

  /// KYB information text
  ///
  /// In en, this message translates to:
  /// **'Business verification allows you to:\n\n• Accept higher transaction limits\n• Access advanced reporting\n• Enable merchant features\n• Build trust with customers\n\nVerification typically takes 2-3 business days.'**
  String get business_kybInfo;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get action_close;

  /// Sub-businesses screen title
  ///
  /// In en, this message translates to:
  /// **'Sub-Businesses'**
  String get subBusiness_title;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Sub-Businesses Yet'**
  String get subBusiness_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Create departments, branches, or teams to organize your business operations.'**
  String get subBusiness_emptyMessage;

  /// Create first sub-business button
  ///
  /// In en, this message translates to:
  /// **'Create First Sub-Business'**
  String get subBusiness_createFirst;

  /// Total balance label
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get subBusiness_totalBalance;

  /// Single unit label
  ///
  /// In en, this message translates to:
  /// **'unit'**
  String get subBusiness_unit;

  /// Multiple units label
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get subBusiness_units;

  /// List section title
  ///
  /// In en, this message translates to:
  /// **'All Sub-Businesses'**
  String get subBusiness_listTitle;

  /// Create screen title
  ///
  /// In en, this message translates to:
  /// **'Create Sub-Business'**
  String get subBusiness_createTitle;

  /// Name input label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get subBusiness_nameLabel;

  /// Description input label
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get subBusiness_descriptionLabel;

  /// Type selector label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get subBusiness_typeLabel;

  /// Department type
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get subBusiness_typeDepartment;

  /// Branch type
  ///
  /// In en, this message translates to:
  /// **'Branch'**
  String get subBusiness_typeBranch;

  /// Subsidiary type
  ///
  /// In en, this message translates to:
  /// **'Subsidiary'**
  String get subBusiness_typeSubsidiary;

  /// Team type
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get subBusiness_typeTeam;

  /// Create info message
  ///
  /// In en, this message translates to:
  /// **'Each sub-business will have its own wallet for tracking income and expenses separately.'**
  String get subBusiness_createInfo;

  /// Create button label
  ///
  /// In en, this message translates to:
  /// **'Create Sub-Business'**
  String get subBusiness_createButton;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Sub-business created successfully'**
  String get subBusiness_createSuccess;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get subBusiness_balance;

  /// Transfer button
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get subBusiness_transfer;

  /// Transactions button
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get subBusiness_transactions;

  /// Information section title
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get subBusiness_information;

  /// Type label
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get subBusiness_type;

  /// Description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get subBusiness_description;

  /// Created date label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get subBusiness_created;

  /// Staff section title
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get subBusiness_staff;

  /// Manage staff button
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get subBusiness_manageStaff;

  /// No staff message
  ///
  /// In en, this message translates to:
  /// **'No staff members yet. Add team members to give them access to this sub-business.'**
  String get subBusiness_noStaff;

  /// Add first staff button
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get subBusiness_addFirstStaff;

  /// View all staff button
  ///
  /// In en, this message translates to:
  /// **'View All Staff'**
  String get subBusiness_viewAllStaff;

  /// Staff screen title
  ///
  /// In en, this message translates to:
  /// **'Staff Management'**
  String get subBusiness_staffTitle;

  /// No staff title
  ///
  /// In en, this message translates to:
  /// **'No Staff Members'**
  String get subBusiness_noStaffTitle;

  /// No staff message
  ///
  /// In en, this message translates to:
  /// **'Invite team members to collaborate on this sub-business.'**
  String get subBusiness_noStaffMessage;

  /// Staff info message
  ///
  /// In en, this message translates to:
  /// **'Staff members can view and manage this sub-business based on their assigned role.'**
  String get subBusiness_staffInfo;

  /// Single member label
  ///
  /// In en, this message translates to:
  /// **'member'**
  String get subBusiness_member;

  /// Multiple members label
  ///
  /// In en, this message translates to:
  /// **'members'**
  String get subBusiness_members;

  /// Add staff dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get subBusiness_addStaffTitle;

  /// Phone input label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get subBusiness_phoneLabel;

  /// Role selector label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get subBusiness_roleLabel;

  /// Owner role
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get subBusiness_roleOwner;

  /// Admin role
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get subBusiness_roleAdmin;

  /// Viewer role
  ///
  /// In en, this message translates to:
  /// **'Viewer'**
  String get subBusiness_roleViewer;

  /// Owner role description
  ///
  /// In en, this message translates to:
  /// **'Full access to manage everything'**
  String get subBusiness_roleOwnerDesc;

  /// Admin role description
  ///
  /// In en, this message translates to:
  /// **'Can manage and transfer funds'**
  String get subBusiness_roleAdminDesc;

  /// Viewer role description
  ///
  /// In en, this message translates to:
  /// **'Can only view transactions'**
  String get subBusiness_roleViewerDesc;

  /// Invite button
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get subBusiness_inviteButton;

  /// Invite success message
  ///
  /// In en, this message translates to:
  /// **'Staff member invited successfully'**
  String get subBusiness_inviteSuccess;

  /// Change role option
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get subBusiness_changeRole;

  /// Remove staff option
  ///
  /// In en, this message translates to:
  /// **'Remove Staff'**
  String get subBusiness_removeStaff;

  /// Change role dialog title
  ///
  /// In en, this message translates to:
  /// **'Change Role'**
  String get subBusiness_changeRoleTitle;

  /// Role update success message
  ///
  /// In en, this message translates to:
  /// **'Role updated successfully'**
  String get subBusiness_roleUpdateSuccess;

  /// Remove staff dialog title
  ///
  /// In en, this message translates to:
  /// **'Remove Staff Member'**
  String get subBusiness_removeStaffTitle;

  /// Remove staff confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this staff member? They will lose access to this sub-business.'**
  String get subBusiness_removeStaffConfirm;

  /// Remove button
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get subBusiness_removeButton;

  /// Remove success message
  ///
  /// In en, this message translates to:
  /// **'Staff member removed successfully'**
  String get subBusiness_removeSuccess;

  /// Bulk payments screen title
  ///
  /// In en, this message translates to:
  /// **'Bulk Payments'**
  String get bulkPayments_title;

  /// Upload CSV button
  ///
  /// In en, this message translates to:
  /// **'Upload CSV File'**
  String get bulkPayments_uploadCsv;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No bulk payments yet'**
  String get bulkPayments_emptyTitle;

  /// Empty state description
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV file to send payments to multiple recipients at once'**
  String get bulkPayments_emptyDescription;

  /// Active batches section
  ///
  /// In en, this message translates to:
  /// **'Active Batches'**
  String get bulkPayments_active;

  /// Completed batches section
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bulkPayments_completed;

  /// Failed batches section
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get bulkPayments_failed;

  /// Upload view title
  ///
  /// In en, this message translates to:
  /// **'Upload Bulk Payments'**
  String get bulkPayments_uploadTitle;

  /// Instructions section
  ///
  /// In en, this message translates to:
  /// **'Instructions'**
  String get bulkPayments_instructions;

  /// Instructions description
  ///
  /// In en, this message translates to:
  /// **'Upload a CSV file containing phone numbers, amounts, and descriptions for multiple payments'**
  String get bulkPayments_instructionsDescription;

  /// Upload file section
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get bulkPayments_uploadFile;

  /// Select file prompt
  ///
  /// In en, this message translates to:
  /// **'Tap to select CSV file'**
  String get bulkPayments_selectFile;

  /// CSV only hint
  ///
  /// In en, this message translates to:
  /// **'CSV files only'**
  String get bulkPayments_csvOnly;

  /// CSV format section
  ///
  /// In en, this message translates to:
  /// **'CSV Format'**
  String get bulkPayments_csvFormat;

  /// Phone format rule
  ///
  /// In en, this message translates to:
  /// **'Phone: International format (+225...)'**
  String get bulkPayments_phoneFormat;

  /// Amount format rule
  ///
  /// In en, this message translates to:
  /// **'Amount: Numeric value (50.00)'**
  String get bulkPayments_amountFormat;

  /// Description format rule
  ///
  /// In en, this message translates to:
  /// **'Description: Required text'**
  String get bulkPayments_descriptionFormat;

  /// Example section
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get bulkPayments_example;

  /// Preview view title
  ///
  /// In en, this message translates to:
  /// **'Preview Payments'**
  String get bulkPayments_preview;

  /// Total payments label
  ///
  /// In en, this message translates to:
  /// **'Total Payments'**
  String get bulkPayments_totalPayments;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get bulkPayments_totalAmount;

  /// Errors found message
  ///
  /// In en, this message translates to:
  /// **'{count} errors found'**
  String bulkPayments_errorsFound(int count);

  /// Fix errors message
  ///
  /// In en, this message translates to:
  /// **'Please fix errors before submitting'**
  String get bulkPayments_fixErrors;

  /// Show invalid toggle
  ///
  /// In en, this message translates to:
  /// **'Show invalid only'**
  String get bulkPayments_showInvalidOnly;

  /// No payments message
  ///
  /// In en, this message translates to:
  /// **'No payments to display'**
  String get bulkPayments_noPayments;

  /// Submit batch button
  ///
  /// In en, this message translates to:
  /// **'Submit Batch'**
  String get bulkPayments_submitBatch;

  /// Confirm submit dialog title
  ///
  /// In en, this message translates to:
  /// **'Confirm Batch Submission'**
  String get bulkPayments_confirmSubmit;

  /// Confirm message
  ///
  /// In en, this message translates to:
  /// **'Send {count} payments totaling {amount}?'**
  String bulkPayments_confirmMessage(int count, String amount);

  /// Submit success message
  ///
  /// In en, this message translates to:
  /// **'Batch submitted successfully'**
  String get bulkPayments_submitSuccess;

  /// Batch status view title
  ///
  /// In en, this message translates to:
  /// **'Batch Status'**
  String get bulkPayments_batchStatus;

  /// Progress section
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get bulkPayments_progress;

  /// Successful label
  ///
  /// In en, this message translates to:
  /// **'Successful'**
  String get bulkPayments_successful;

  /// Pending label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bulkPayments_pending;

  /// Details section
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get bulkPayments_details;

  /// Created at label
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get bulkPayments_createdAt;

  /// Processed at label
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get bulkPayments_processedAt;

  /// Failed payments section
  ///
  /// In en, this message translates to:
  /// **'Failed Payments'**
  String get bulkPayments_failedPayments;

  /// Failed description
  ///
  /// In en, this message translates to:
  /// **'Download a report of failed payments to retry'**
  String get bulkPayments_failedDescription;

  /// Download report button
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get bulkPayments_downloadReport;

  /// Failed report share title
  ///
  /// In en, this message translates to:
  /// **'Failed Payments Report'**
  String get bulkPayments_failedReportTitle;

  /// Download failed message
  ///
  /// In en, this message translates to:
  /// **'Failed to download report'**
  String get bulkPayments_downloadFailed;

  /// Draft status
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get bulkPayments_statusDraft;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bulkPayments_statusPending;

  /// Processing status
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get bulkPayments_statusProcessing;

  /// Completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bulkPayments_statusCompleted;

  /// Partially completed status
  ///
  /// In en, this message translates to:
  /// **'Partially Completed'**
  String get bulkPayments_statusPartial;

  /// Failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get bulkPayments_statusFailed;

  /// Expenses screen title
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses_title;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Expenses Yet'**
  String get expenses_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Start tracking your expenses by capturing receipts or adding them manually'**
  String get expenses_emptyMessage;

  /// Capture receipt button
  ///
  /// In en, this message translates to:
  /// **'Capture Receipt'**
  String get expenses_captureReceipt;

  /// Add manually button
  ///
  /// In en, this message translates to:
  /// **'Add Manually'**
  String get expenses_addManually;

  /// Add expense button
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get expenses_addExpense;

  /// Total expenses label
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get expenses_totalExpenses;

  /// Items count label
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get expenses_items;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get expenses_category;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get expenses_amount;

  /// Vendor field label
  ///
  /// In en, this message translates to:
  /// **'Vendor'**
  String get expenses_vendor;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get expenses_date;

  /// Time field label
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get expenses_time;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get expenses_description;

  /// Travel category
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get expenses_categoryTravel;

  /// Meals category
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get expenses_categoryMeals;

  /// Office category
  ///
  /// In en, this message translates to:
  /// **'Office'**
  String get expenses_categoryOffice;

  /// Transport category
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get expenses_categoryTransport;

  /// Other category
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get expenses_categoryOther;

  /// Amount required error
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get expenses_errorAmountRequired;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get expenses_errorInvalidAmount;

  /// Success message
  ///
  /// In en, this message translates to:
  /// **'Expense added successfully'**
  String get expenses_addedSuccessfully;

  /// Camera instruction
  ///
  /// In en, this message translates to:
  /// **'Position the receipt within the frame'**
  String get expenses_positionReceipt;

  /// Preview screen title
  ///
  /// In en, this message translates to:
  /// **'Receipt Preview'**
  String get expenses_receiptPreview;

  /// Processing message
  ///
  /// In en, this message translates to:
  /// **'Processing receipt...'**
  String get expenses_processingReceipt;

  /// OCR results title
  ///
  /// In en, this message translates to:
  /// **'Extracted Data'**
  String get expenses_extractedData;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm & Edit'**
  String get expenses_confirmAndEdit;

  /// Retake button
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get expenses_retake;

  /// Confirm details title
  ///
  /// In en, this message translates to:
  /// **'Confirm Details'**
  String get expenses_confirmDetails;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get expenses_saveExpense;

  /// Detail screen title
  ///
  /// In en, this message translates to:
  /// **'Expense Details'**
  String get expenses_expenseDetails;

  /// Details section title
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get expenses_details;

  /// Linked transaction label
  ///
  /// In en, this message translates to:
  /// **'Linked Transaction'**
  String get expenses_linkedTransaction;

  /// Delete dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get expenses_deleteExpense;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get expenses_deleteConfirmation;

  /// Delete success message
  ///
  /// In en, this message translates to:
  /// **'Expense deleted successfully'**
  String get expenses_deletedSuccessfully;

  /// Reports screen title
  ///
  /// In en, this message translates to:
  /// **'Expense Reports'**
  String get expenses_reports;

  /// View reports button
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get expenses_viewReports;

  /// Report period label
  ///
  /// In en, this message translates to:
  /// **'Report Period'**
  String get expenses_reportPeriod;

  /// Start date label
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get expenses_startDate;

  /// End date label
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get expenses_endDate;

  /// Summary section title
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get expenses_reportSummary;

  /// Average expense label
  ///
  /// In en, this message translates to:
  /// **'Average Expense'**
  String get expenses_averageExpense;

  /// Category breakdown title
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get expenses_byCategory;

  /// Export PDF button
  ///
  /// In en, this message translates to:
  /// **'Export as PDF'**
  String get expenses_exportPdf;

  /// Export CSV button
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get expenses_exportCsv;

  /// Report generated message
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully'**
  String get expenses_reportGenerated;

  /// Notifications screen title
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// Mark all notifications as read button
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notifications_markAllRead;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Notifications'**
  String get notifications_emptyTitle;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notifications_emptyMessage;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Failed to Load'**
  String get notifications_errorTitle;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get notifications_errorGeneric;

  /// Time format for just now
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifications_timeJustNow;

  /// Time format for minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifications_timeMinutesAgo(int count);

  /// Time format for hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifications_timeHoursAgo(int count);

  /// Time format for days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifications_timeDaysAgo(int count);

  /// Security screen title
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security_title;

  /// Authentication section header
  ///
  /// In en, this message translates to:
  /// **'Authentication'**
  String get security_authentication;

  /// Change PIN option
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get security_changePin;

  /// Change PIN subtitle
  ///
  /// In en, this message translates to:
  /// **'Update your 4-digit PIN'**
  String get security_changePinSubtitle;

  /// Biometric login option
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get security_biometricLogin;

  /// Biometric login subtitle
  ///
  /// In en, this message translates to:
  /// **'Use Face ID or fingerprint'**
  String get security_biometricSubtitle;

  /// Biometric not available message
  ///
  /// In en, this message translates to:
  /// **'Not available on this device'**
  String get security_biometricNotAvailable;

  /// Biometric unavailable snackbar message
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication is not available on this device'**
  String get security_biometricUnavailableMessage;

  /// Biometric verification reason
  ///
  /// In en, this message translates to:
  /// **'Verify to enable biometric login'**
  String get security_biometricVerifyReason;

  /// Loading state text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get security_loading;

  /// Checking biometric availability
  ///
  /// In en, this message translates to:
  /// **'Checking availability...'**
  String get security_checkingAvailability;

  /// Error loading biometric state
  ///
  /// In en, this message translates to:
  /// **'Error loading state'**
  String get security_errorLoadingState;

  /// Error checking biometric availability
  ///
  /// In en, this message translates to:
  /// **'Error checking availability'**
  String get security_errorCheckingAvailability;

  /// Two-factor authentication option
  ///
  /// In en, this message translates to:
  /// **'Two-Factor Authentication'**
  String get security_twoFactorAuth;

  /// 2FA enabled subtitle
  ///
  /// In en, this message translates to:
  /// **'Enabled via Authenticator app'**
  String get security_twoFactorEnabledSubtitle;

  /// 2FA disabled subtitle
  ///
  /// In en, this message translates to:
  /// **'Add extra protection'**
  String get security_twoFactorDisabledSubtitle;

  /// Transaction security section header
  ///
  /// In en, this message translates to:
  /// **'Transaction Security'**
  String get security_transactionSecurity;

  /// Require PIN for transactions option
  ///
  /// In en, this message translates to:
  /// **'Require PIN for Transactions'**
  String get security_requirePinForTransactions;

  /// Require PIN subtitle
  ///
  /// In en, this message translates to:
  /// **'Confirm all transactions with PIN'**
  String get security_requirePinSubtitle;

  /// Security alerts section header
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get security_alerts;

  /// Login notifications option
  ///
  /// In en, this message translates to:
  /// **'Login Notifications'**
  String get security_loginNotifications;

  /// Login notifications subtitle
  ///
  /// In en, this message translates to:
  /// **'Get notified of new logins'**
  String get security_loginNotificationsSubtitle;

  /// New device alerts option
  ///
  /// In en, this message translates to:
  /// **'New Device Alerts'**
  String get security_newDeviceAlerts;

  /// New device alerts subtitle
  ///
  /// In en, this message translates to:
  /// **'Alert when a new device is used'**
  String get security_newDeviceAlertsSubtitle;

  /// Sessions section header
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get security_sessions;

  /// Devices option
  ///
  /// In en, this message translates to:
  /// **'Devices'**
  String get security_devices;

  /// Devices subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your devices'**
  String get security_devicesSubtitle;

  /// Active sessions option
  ///
  /// In en, this message translates to:
  /// **'Active Sessions'**
  String get security_activeSessions;

  /// Active sessions subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage your active sessions'**
  String get security_activeSessionsSubtitle;

  /// Log out all devices option
  ///
  /// In en, this message translates to:
  /// **'Log Out All Devices'**
  String get security_logoutAllDevices;

  /// Log out all devices subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign out from all other devices'**
  String get security_logoutAllDevicesSubtitle;

  /// Privacy section header
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get security_privacy;

  /// Login history option
  ///
  /// In en, this message translates to:
  /// **'Login History'**
  String get security_loginHistory;

  /// Login history subtitle
  ///
  /// In en, this message translates to:
  /// **'View recent login activity'**
  String get security_loginHistorySubtitle;

  /// Delete account option
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get security_deleteAccount;

  /// Delete account subtitle
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get security_deleteAccountSubtitle;

  /// Security score title
  ///
  /// In en, this message translates to:
  /// **'Security Score'**
  String get security_scoreTitle;

  /// Excellent security score description
  ///
  /// In en, this message translates to:
  /// **'Excellent! Your account is well protected.'**
  String get security_scoreExcellent;

  /// Good security score description
  ///
  /// In en, this message translates to:
  /// **'Good security. A few improvements possible.'**
  String get security_scoreGood;

  /// Moderate security score description
  ///
  /// In en, this message translates to:
  /// **'Moderate security. Enable more features.'**
  String get security_scoreModerate;

  /// Low security score description
  ///
  /// In en, this message translates to:
  /// **'Low security. Please enable protection features.'**
  String get security_scoreLow;

  /// Tip to enable 2FA
  ///
  /// In en, this message translates to:
  /// **'Enable 2FA to increase your score by 25 points'**
  String get security_tipEnable2FA;

  /// Tip to enable biometrics
  ///
  /// In en, this message translates to:
  /// **'Enable biometrics for easier secure login'**
  String get security_tipEnableBiometrics;

  /// Tip to require PIN
  ///
  /// In en, this message translates to:
  /// **'Require PIN for transactions for extra safety'**
  String get security_tipRequirePin;

  /// Tip to enable notifications
  ///
  /// In en, this message translates to:
  /// **'Enable all notifications for maximum security'**
  String get security_tipEnableNotifications;

  /// Set up 2FA dialog title
  ///
  /// In en, this message translates to:
  /// **'Set Up Two-Factor Authentication'**
  String get security_setup2FATitle;

  /// Set up 2FA dialog message
  ///
  /// In en, this message translates to:
  /// **'Use an authenticator app like Google Authenticator or Authy for enhanced security.'**
  String get security_setup2FAMessage;

  /// Continue setup button
  ///
  /// In en, this message translates to:
  /// **'Continue Setup'**
  String get security_continueSetup;

  /// 2FA enabled success message
  ///
  /// In en, this message translates to:
  /// **'2FA enabled successfully'**
  String get security_2FAEnabledSuccess;

  /// Disable 2FA dialog title
  ///
  /// In en, this message translates to:
  /// **'Disable 2FA?'**
  String get security_disable2FATitle;

  /// Disable 2FA dialog message
  ///
  /// In en, this message translates to:
  /// **'This will make your account less secure. Are you sure?'**
  String get security_disable2FAMessage;

  /// Disable button
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get security_disable;

  /// Log out all devices dialog title
  ///
  /// In en, this message translates to:
  /// **'Log Out All Devices?'**
  String get security_logoutAllTitle;

  /// Log out all devices dialog message
  ///
  /// In en, this message translates to:
  /// **'You will be logged out from all other devices. You will need to log in again on those devices.'**
  String get security_logoutAllMessage;

  /// Log out all button
  ///
  /// In en, this message translates to:
  /// **'Log Out All'**
  String get security_logoutAll;

  /// Log out all success message
  ///
  /// In en, this message translates to:
  /// **'All other devices have been logged out'**
  String get security_logoutAllSuccess;

  /// Login history sheet title
  ///
  /// In en, this message translates to:
  /// **'Login History'**
  String get security_loginHistoryTitle;

  /// Login success status
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get security_loginSuccess;

  /// Login failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get security_loginFailed;

  /// Delete account dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get security_deleteAccountTitle;

  /// Delete account dialog message
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data, transaction history, and funds will be lost.'**
  String get security_deleteAccountMessage;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get security_delete;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// KYC status field label
  ///
  /// In en, this message translates to:
  /// **'KYC Status'**
  String get profile_kycStatus;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get profile_country;

  /// Field not set placeholder
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get profile_notSet;

  /// Verify button
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get profile_verify;

  /// KYC not verified status
  ///
  /// In en, this message translates to:
  /// **'Not Verified'**
  String get profile_kycNotVerified;

  /// KYC pending status
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get profile_kycPending;

  /// KYC verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get profile_kycVerified;

  /// KYC rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get profile_kycRejected;

  /// Ivory Coast country name
  ///
  /// In en, this message translates to:
  /// **'Ivory Coast'**
  String get profile_countryIvoryCoast;

  /// Nigeria country name
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get profile_countryNigeria;

  /// Kenya country name
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get profile_countryKenya;

  /// Ghana country name
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get profile_countryGhana;

  /// Senegal country name
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get profile_countrySenegal;

  /// Change PIN screen title
  ///
  /// In en, this message translates to:
  /// **'Change PIN'**
  String get changePin_title;

  /// New PIN step title
  ///
  /// In en, this message translates to:
  /// **'New PIN'**
  String get changePin_newPinTitle;

  /// Confirm PIN step title
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get changePin_confirmTitle;

  /// Enter current PIN step title
  ///
  /// In en, this message translates to:
  /// **'Enter Current PIN'**
  String get changePin_enterCurrentPinTitle;

  /// Enter current PIN step subtitle
  ///
  /// In en, this message translates to:
  /// **'Enter your current 4-digit PIN to continue'**
  String get changePin_enterCurrentPinSubtitle;

  /// Create new PIN step title
  ///
  /// In en, this message translates to:
  /// **'Create New PIN'**
  String get changePin_createNewPinTitle;

  /// Create new PIN step subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose a new 4-digit PIN for your account'**
  String get changePin_createNewPinSubtitle;

  /// Confirm PIN step title
  ///
  /// In en, this message translates to:
  /// **'Confirm Your PIN'**
  String get changePin_confirmPinTitle;

  /// Confirm PIN step subtitle
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new PIN to confirm'**
  String get changePin_confirmPinSubtitle;

  /// Biometric required error
  ///
  /// In en, this message translates to:
  /// **'Biometric confirmation required'**
  String get changePin_errorBiometricRequired;

  /// Incorrect PIN error
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN. Please try again.'**
  String get changePin_errorIncorrectPin;

  /// Unable to verify PIN error
  ///
  /// In en, this message translates to:
  /// **'Unable to verify PIN. Please try again.'**
  String get changePin_errorUnableToVerify;

  /// Weak PIN error
  ///
  /// In en, this message translates to:
  /// **'PIN is too simple. Choose a stronger PIN.'**
  String get changePin_errorWeakPin;

  /// Same as current PIN error
  ///
  /// In en, this message translates to:
  /// **'New PIN must be different from current PIN.'**
  String get changePin_errorSameAsCurrentPin;

  /// PIN mismatch error
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Try again.'**
  String get changePin_errorPinMismatch;

  /// PIN changed success message
  ///
  /// In en, this message translates to:
  /// **'PIN changed successfully!'**
  String get changePin_successMessage;

  /// Failed to set new PIN error
  ///
  /// In en, this message translates to:
  /// **'Failed to set new PIN. Please try a different PIN.'**
  String get changePin_errorFailedToSet;

  /// Failed to save PIN error
  ///
  /// In en, this message translates to:
  /// **'Failed to save PIN. Please try again.'**
  String get changePin_errorFailedToSave;

  /// Email notifications section
  ///
  /// In en, this message translates to:
  /// **'Email Notifications'**
  String get notifications_email;

  /// Email receipts option
  ///
  /// In en, this message translates to:
  /// **'Email Receipts'**
  String get notifications_emailReceipts;

  /// Email receipts description
  ///
  /// In en, this message translates to:
  /// **'Receive transaction receipts by email'**
  String get notifications_emailReceiptsDescription;

  /// Error loading notification settings
  ///
  /// In en, this message translates to:
  /// **'Failed to load notification settings'**
  String get notifications_loadError;

  /// Marketing notifications option
  ///
  /// In en, this message translates to:
  /// **'Marketing'**
  String get notifications_marketing;

  /// Marketing notifications description
  ///
  /// In en, this message translates to:
  /// **'Promotional offers and updates'**
  String get notifications_marketingDescription;

  /// Monthly statement option
  ///
  /// In en, this message translates to:
  /// **'Monthly Statement'**
  String get notifications_monthlyStatement;

  /// Monthly statement description
  ///
  /// In en, this message translates to:
  /// **'Receive monthly account statement'**
  String get notifications_monthlyStatementDescription;

  /// Newsletter option
  ///
  /// In en, this message translates to:
  /// **'Newsletter'**
  String get notifications_newsletter;

  /// Newsletter description
  ///
  /// In en, this message translates to:
  /// **'Product news and updates'**
  String get notifications_newsletterDescription;

  /// Push notifications section
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get notifications_push;

  /// Required notification indicator
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get notifications_required;

  /// Error saving notification preferences
  ///
  /// In en, this message translates to:
  /// **'Failed to save preferences'**
  String get notifications_saveError;

  /// Save preferences button
  ///
  /// In en, this message translates to:
  /// **'Save Preferences'**
  String get notifications_savePreferences;

  /// Success saving preferences
  ///
  /// In en, this message translates to:
  /// **'Preferences saved successfully'**
  String get notifications_saveSuccess;

  /// Security alerts option
  ///
  /// In en, this message translates to:
  /// **'Security Alerts'**
  String get notifications_security;

  /// Security codes option
  ///
  /// In en, this message translates to:
  /// **'Security Codes'**
  String get notifications_securityCodes;

  /// Security codes description
  ///
  /// In en, this message translates to:
  /// **'Receive login and verification codes'**
  String get notifications_securityCodesDescription;

  /// Security notifications description
  ///
  /// In en, this message translates to:
  /// **'Account security notifications'**
  String get notifications_securityDescription;

  /// Security notification note
  ///
  /// In en, this message translates to:
  /// **'Security notifications cannot be disabled'**
  String get notifications_securityNote;

  /// SMS notifications section
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get notifications_sms;

  /// SMS transaction alerts option
  ///
  /// In en, this message translates to:
  /// **'Transaction Alerts'**
  String get notifications_smsTransactions;

  /// SMS transaction alerts description
  ///
  /// In en, this message translates to:
  /// **'Receive SMS for transactions'**
  String get notifications_smsTransactionsDescription;

  /// Transaction notifications option
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get notifications_transactions;

  /// Transaction notifications description
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for transfers and payments'**
  String get notifications_transactionsDescription;

  /// Unsaved changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get notifications_unsavedChanges;

  /// Unsaved changes dialog message
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Discard them?'**
  String get notifications_unsavedChangesMessage;

  /// Call us button
  ///
  /// In en, this message translates to:
  /// **'Call Us'**
  String get help_callUs;

  /// Email us button
  ///
  /// In en, this message translates to:
  /// **'Email Us'**
  String get help_emailUs;

  /// Get help title
  ///
  /// In en, this message translates to:
  /// **'Get Help'**
  String get help_getHelp;

  /// Search results label
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get help_results;

  /// Help search placeholder
  ///
  /// In en, this message translates to:
  /// **'Search help articles...'**
  String get help_searchPlaceholder;

  /// Discard action
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get action_discard;

  /// Coming soon label
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get common_comingSoon;

  /// Maybe later button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get common_maybeLater;

  /// Optional field indicator
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get common_optional;

  /// Share action
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// Invalid number error
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get error_invalidNumber;

  /// Export title
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export_title;

  /// Account details header
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get bankLinking_accountDetails;

  /// Account holder name field
  ///
  /// In en, this message translates to:
  /// **'Account Holder Name'**
  String get bankLinking_accountHolderName;

  /// Account holder name validation error
  ///
  /// In en, this message translates to:
  /// **'Account holder name is required'**
  String get bankLinking_accountHolderNameRequired;

  /// Account number field
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get bankLinking_accountNumber;

  /// Account number validation error
  ///
  /// In en, this message translates to:
  /// **'Account number is required'**
  String get bankLinking_accountNumberRequired;

  /// Amount field
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get bankLinking_amount;

  /// Amount validation error
  ///
  /// In en, this message translates to:
  /// **'Amount is required'**
  String get bankLinking_amountRequired;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get bankLinking_balance;

  /// Balance check action
  ///
  /// In en, this message translates to:
  /// **'Balance Check'**
  String get bankLinking_balanceCheck;

  /// Confirm deposit button
  ///
  /// In en, this message translates to:
  /// **'Confirm Deposit'**
  String get bankLinking_confirmDeposit;

  /// Confirm withdrawal button
  ///
  /// In en, this message translates to:
  /// **'Confirm Withdrawal'**
  String get bankLinking_confirmWithdraw;

  /// Deposit action
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get bankLinking_deposit;

  /// Deposit confirmation message
  ///
  /// In en, this message translates to:
  /// **'Deposit {amount} from your bank?'**
  String bankLinking_depositConfirmation(String amount);

  /// Deposit from bank action
  ///
  /// In en, this message translates to:
  /// **'Deposit from Bank'**
  String get bankLinking_depositFromBank;

  /// Deposit information message
  ///
  /// In en, this message translates to:
  /// **'Funds will be credited within 24 hours'**
  String get bankLinking_depositInfo;

  /// Deposit success message
  ///
  /// In en, this message translates to:
  /// **'Deposit successful'**
  String get bankLinking_depositSuccess;

  /// Development OTP hint
  ///
  /// In en, this message translates to:
  /// **'Dev OTP: 123456'**
  String get bankLinking_devOtpHint;

  /// Direct debit label
  ///
  /// In en, this message translates to:
  /// **'Direct Debit'**
  String get bankLinking_directDebit;

  /// Enter amount placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter amount'**
  String get bankLinking_enterAmount;

  /// Failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get bankLinking_failed;

  /// Invalid amount error
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get bankLinking_invalidAmount;

  /// Invalid OTP error
  ///
  /// In en, this message translates to:
  /// **'Invalid OTP'**
  String get bankLinking_invalidOtp;

  /// Link account action
  ///
  /// In en, this message translates to:
  /// **'Link Account'**
  String get bankLinking_linkAccount;

  /// Link account description
  ///
  /// In en, this message translates to:
  /// **'Link your bank account for easy transfers'**
  String get bankLinking_linkAccountDesc;

  /// Linked accounts title
  ///
  /// In en, this message translates to:
  /// **'Linked Accounts'**
  String get bankLinking_linkedAccounts;

  /// Link failed error message
  ///
  /// In en, this message translates to:
  /// **'Failed to link account'**
  String get bankLinking_linkFailed;

  /// Link new account action
  ///
  /// In en, this message translates to:
  /// **'Link New Account'**
  String get bankLinking_linkNewAccount;

  /// No linked accounts message
  ///
  /// In en, this message translates to:
  /// **'No linked accounts'**
  String get bankLinking_noLinkedAccounts;

  /// OTP code field
  ///
  /// In en, this message translates to:
  /// **'OTP Code'**
  String get bankLinking_otpCode;

  /// OTP resent confirmation
  ///
  /// In en, this message translates to:
  /// **'OTP resent'**
  String get bankLinking_otpResent;

  /// Pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bankLinking_pending;

  /// Primary account label
  ///
  /// In en, this message translates to:
  /// **'Primary'**
  String get bankLinking_primary;

  /// Primary account set confirmation
  ///
  /// In en, this message translates to:
  /// **'Primary account set'**
  String get bankLinking_primaryAccountSet;

  /// Resend OTP action
  ///
  /// In en, this message translates to:
  /// **'Resend OTP'**
  String get bankLinking_resendOtp;

  /// Resend OTP countdown
  ///
  /// In en, this message translates to:
  /// **'Resend OTP in {seconds}s'**
  String bankLinking_resendOtpIn(int seconds);

  /// Select bank action
  ///
  /// In en, this message translates to:
  /// **'Select Bank'**
  String get bankLinking_selectBank;

  /// Select bank description
  ///
  /// In en, this message translates to:
  /// **'Choose your bank to link'**
  String get bankLinking_selectBankDesc;

  /// Select bank title
  ///
  /// In en, this message translates to:
  /// **'Select Your Bank'**
  String get bankLinking_selectBankTitle;

  /// Suspended status
  ///
  /// In en, this message translates to:
  /// **'Suspended'**
  String get bankLinking_suspended;

  /// Verification description
  ///
  /// In en, this message translates to:
  /// **'Enter the OTP sent to your phone'**
  String get bankLinking_verificationDesc;

  /// Verification failed error
  ///
  /// In en, this message translates to:
  /// **'Verification failed'**
  String get bankLinking_verificationFailed;

  /// Verification required title
  ///
  /// In en, this message translates to:
  /// **'Verification Required'**
  String get bankLinking_verificationRequired;

  /// Verification success message
  ///
  /// In en, this message translates to:
  /// **'Account verified'**
  String get bankLinking_verificationSuccess;

  /// Verify account title
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get bankLinking_verificationTitle;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get bankLinking_verified;

  /// Verify action
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get bankLinking_verify;

  /// Verify account action
  ///
  /// In en, this message translates to:
  /// **'Verify Account'**
  String get bankLinking_verifyAccount;

  /// Withdraw action
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get bankLinking_withdraw;

  /// Withdraw confirmation message
  ///
  /// In en, this message translates to:
  /// **'Withdraw {amount} to your bank?'**
  String bankLinking_withdrawConfirmation(String amount);

  /// Withdraw information message
  ///
  /// In en, this message translates to:
  /// **'Funds will arrive in 1-3 business days'**
  String get bankLinking_withdrawInfo;

  /// Withdrawal success message
  ///
  /// In en, this message translates to:
  /// **'Withdrawal successful'**
  String get bankLinking_withdrawSuccess;

  /// Withdrawal processing time
  ///
  /// In en, this message translates to:
  /// **'Processing time: 1-3 business days'**
  String get bankLinking_withdrawTime;

  /// Withdraw to bank action
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Bank'**
  String get bankLinking_withdrawToBank;

  /// Confirm button text
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// Total amount label for expenses
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get expenses_totalAmount;

  /// Additional documents screen title
  ///
  /// In en, this message translates to:
  /// **'Additional Documents'**
  String get kyc_additionalDocs_title;

  /// Additional documents screen description
  ///
  /// In en, this message translates to:
  /// **'Provide additional information for verification'**
  String get kyc_additionalDocs_description;

  /// Employment section title
  ///
  /// In en, this message translates to:
  /// **'Employment Information'**
  String get kyc_additionalDocs_employment_title;

  /// Occupation field label
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get kyc_additionalDocs_occupation;

  /// Employer field label
  ///
  /// In en, this message translates to:
  /// **'Employer'**
  String get kyc_additionalDocs_employer;

  /// Monthly income field label
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get kyc_additionalDocs_monthlyIncome;

  /// Source of funds section title
  ///
  /// In en, this message translates to:
  /// **'Source of Funds'**
  String get kyc_additionalDocs_sourceOfFunds_title;

  /// Source of funds section description
  ///
  /// In en, this message translates to:
  /// **'Tell us about your source of funds'**
  String get kyc_additionalDocs_sourceOfFunds_description;

  /// Source details field label
  ///
  /// In en, this message translates to:
  /// **'Source Details'**
  String get kyc_additionalDocs_sourceDetails;

  /// Supporting documents section title
  ///
  /// In en, this message translates to:
  /// **'Supporting Documents'**
  String get kyc_additionalDocs_supportingDocs_title;

  /// Supporting documents section description
  ///
  /// In en, this message translates to:
  /// **'Upload documents to verify your information'**
  String get kyc_additionalDocs_supportingDocs_description;

  /// Take photo button text
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get kyc_additionalDocs_takePhoto;

  /// Upload file button text
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get kyc_additionalDocs_uploadFile;

  /// Error message when document submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed to submit documents'**
  String get kyc_additionalDocs_error;

  /// Info section title
  ///
  /// In en, this message translates to:
  /// **'Why we need this'**
  String get kyc_additionalDocs_info_title;

  /// Info section description
  ///
  /// In en, this message translates to:
  /// **'This helps us verify your identity'**
  String get kyc_additionalDocs_info_description;

  /// Submit documents button text
  ///
  /// In en, this message translates to:
  /// **'Submit Documents'**
  String get kyc_additionalDocs_submit;

  /// Salary source type
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get kyc_additionalDocs_sourceType_salary;

  /// Business income source type
  ///
  /// In en, this message translates to:
  /// **'Business Income'**
  String get kyc_additionalDocs_sourceType_business;

  /// Investments source type
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get kyc_additionalDocs_sourceType_investments;

  /// Savings source type
  ///
  /// In en, this message translates to:
  /// **'Savings'**
  String get kyc_additionalDocs_sourceType_savings;

  /// Inheritance source type
  ///
  /// In en, this message translates to:
  /// **'Inheritance'**
  String get kyc_additionalDocs_sourceType_inheritance;

  /// Gift source type
  ///
  /// In en, this message translates to:
  /// **'Gift'**
  String get kyc_additionalDocs_sourceType_gift;

  /// Other source type
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get kyc_additionalDocs_sourceType_other;

  /// Pay slip document suggestion
  ///
  /// In en, this message translates to:
  /// **'Pay slip'**
  String get kyc_additionalDocs_suggestion_paySlip;

  /// Bank statement document suggestion
  ///
  /// In en, this message translates to:
  /// **'Bank statement'**
  String get kyc_additionalDocs_suggestion_bankStatement;

  /// Business registration document suggestion
  ///
  /// In en, this message translates to:
  /// **'Business registration'**
  String get kyc_additionalDocs_suggestion_businessReg;

  /// Tax return document suggestion
  ///
  /// In en, this message translates to:
  /// **'Tax return'**
  String get kyc_additionalDocs_suggestion_taxReturn;

  /// Address verification screen title
  ///
  /// In en, this message translates to:
  /// **'Address Verification'**
  String get kyc_address_title;

  /// Address verification screen description
  ///
  /// In en, this message translates to:
  /// **'Verify your residential address'**
  String get kyc_address_description;

  /// Address form section title
  ///
  /// In en, this message translates to:
  /// **'Your Address'**
  String get kyc_address_form_title;

  /// Address line 1 field label
  ///
  /// In en, this message translates to:
  /// **'Address Line 1'**
  String get kyc_address_addressLine1;

  /// Address line 2 field label
  ///
  /// In en, this message translates to:
  /// **'Address Line 2'**
  String get kyc_address_addressLine2;

  /// City field label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get kyc_address_city;

  /// State/Region field label
  ///
  /// In en, this message translates to:
  /// **'State/Region'**
  String get kyc_address_state;

  /// Postal code field label
  ///
  /// In en, this message translates to:
  /// **'Postal Code'**
  String get kyc_address_postalCode;

  /// Country field label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get kyc_address_country;

  /// Proof of address section title
  ///
  /// In en, this message translates to:
  /// **'Proof of Address'**
  String get kyc_address_proofDocument_title;

  /// Proof of address section description
  ///
  /// In en, this message translates to:
  /// **'Upload a document showing your address'**
  String get kyc_address_proofDocument_description;

  /// Take photo button text
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get kyc_address_takePhoto;

  /// Retake photo button text
  ///
  /// In en, this message translates to:
  /// **'Retake Photo'**
  String get kyc_address_retakePhoto;

  /// Choose file button text
  ///
  /// In en, this message translates to:
  /// **'Choose File'**
  String get kyc_address_chooseFile;

  /// Change file button text
  ///
  /// In en, this message translates to:
  /// **'Change File'**
  String get kyc_address_changeFile;

  /// Upload document button text
  ///
  /// In en, this message translates to:
  /// **'Upload Document'**
  String get kyc_address_uploadDocument;

  /// Submit address button text
  ///
  /// In en, this message translates to:
  /// **'Submit Address'**
  String get kyc_address_submit;

  /// Error message when address submission fails
  ///
  /// In en, this message translates to:
  /// **'Failed to submit address'**
  String get kyc_address_error;

  /// Accepted documents info title
  ///
  /// In en, this message translates to:
  /// **'Accepted Documents'**
  String get kyc_address_info_title;

  /// Accepted documents info description
  ///
  /// In en, this message translates to:
  /// **'Documents must be dated within 3 months'**
  String get kyc_address_info_description;

  /// Utility bill document type
  ///
  /// In en, this message translates to:
  /// **'Utility Bill'**
  String get kyc_address_docType_utilityBill;

  /// Utility bill document type description
  ///
  /// In en, this message translates to:
  /// **'Electricity, water, or gas bill'**
  String get kyc_address_docType_utilityBill_description;

  /// Bank statement document type
  ///
  /// In en, this message translates to:
  /// **'Bank Statement'**
  String get kyc_address_docType_bankStatement;

  /// Bank statement document type description
  ///
  /// In en, this message translates to:
  /// **'Recent bank statement'**
  String get kyc_address_docType_bankStatement_description;

  /// Government letter document type
  ///
  /// In en, this message translates to:
  /// **'Government Letter'**
  String get kyc_address_docType_governmentLetter;

  /// Government letter document type description
  ///
  /// In en, this message translates to:
  /// **'Official government correspondence'**
  String get kyc_address_docType_governmentLetter_description;

  /// Rental agreement document type
  ///
  /// In en, this message translates to:
  /// **'Rental Agreement'**
  String get kyc_address_docType_rentalAgreement;

  /// Rental agreement document type description
  ///
  /// In en, this message translates to:
  /// **'Signed rental or lease agreement'**
  String get kyc_address_docType_rentalAgreement_description;

  /// Video verification screen title
  ///
  /// In en, this message translates to:
  /// **'Video Verification'**
  String get kyc_video_title;

  /// Video instructions section title
  ///
  /// In en, this message translates to:
  /// **'Before You Start'**
  String get kyc_video_instructions_title;

  /// Video instructions section description
  ///
  /// In en, this message translates to:
  /// **'Follow these guidelines for best results'**
  String get kyc_video_instructions_description;

  /// Lighting instruction title
  ///
  /// In en, this message translates to:
  /// **'Good Lighting'**
  String get kyc_video_instruction_lighting_title;

  /// Lighting instruction description
  ///
  /// In en, this message translates to:
  /// **'Find a well-lit area'**
  String get kyc_video_instruction_lighting_description;

  /// Face position instruction title
  ///
  /// In en, this message translates to:
  /// **'Face Position'**
  String get kyc_video_instruction_position_title;

  /// Face position instruction description
  ///
  /// In en, this message translates to:
  /// **'Keep your face in the frame'**
  String get kyc_video_instruction_position_description;

  /// Quiet environment instruction title
  ///
  /// In en, this message translates to:
  /// **'Quiet Environment'**
  String get kyc_video_instruction_quiet_title;

  /// Quiet environment instruction description
  ///
  /// In en, this message translates to:
  /// **'Find a quiet place'**
  String get kyc_video_instruction_quiet_description;

  /// Solo instruction title
  ///
  /// In en, this message translates to:
  /// **'Be Alone'**
  String get kyc_video_instruction_solo_title;

  /// Solo instruction description
  ///
  /// In en, this message translates to:
  /// **'Only you should be in the frame'**
  String get kyc_video_instruction_solo_description;

  /// Video actions section title
  ///
  /// In en, this message translates to:
  /// **'Follow Instructions'**
  String get kyc_video_actions_title;

  /// Video actions section description
  ///
  /// In en, this message translates to:
  /// **'Complete each action as prompted'**
  String get kyc_video_actions_description;

  /// Look straight action
  ///
  /// In en, this message translates to:
  /// **'Look straight'**
  String get kyc_video_action_lookStraight;

  /// Turn left action
  ///
  /// In en, this message translates to:
  /// **'Turn left'**
  String get kyc_video_action_turnLeft;

  /// Turn right action
  ///
  /// In en, this message translates to:
  /// **'Turn right'**
  String get kyc_video_action_turnRight;

  /// Smile action
  ///
  /// In en, this message translates to:
  /// **'Smile'**
  String get kyc_video_action_smile;

  /// Blink action
  ///
  /// In en, this message translates to:
  /// **'Blink'**
  String get kyc_video_action_blink;

  /// Start recording button text
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get kyc_video_startRecording;

  /// Continue button text
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get kyc_video_continue;

  /// Video preview section title
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get kyc_video_preview_title;

  /// Video preview section description
  ///
  /// In en, this message translates to:
  /// **'Review your video'**
  String get kyc_video_preview_description;

  /// Video recorded status message
  ///
  /// In en, this message translates to:
  /// **'Video recorded'**
  String get kyc_video_preview_videoRecorded;

  /// Retake video button text
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get kyc_video_retake;

  /// Upgrade verification screen title
  ///
  /// In en, this message translates to:
  /// **'Upgrade Verification'**
  String get kyc_upgrade_title;

  /// Select tier section title
  ///
  /// In en, this message translates to:
  /// **'Select Tier'**
  String get kyc_upgrade_selectTier;

  /// Select tier section description
  ///
  /// In en, this message translates to:
  /// **'Choose your verification level'**
  String get kyc_upgrade_selectTier_description;

  /// Current tier label
  ///
  /// In en, this message translates to:
  /// **'Current Tier'**
  String get kyc_upgrade_currentTier;

  /// Recommended tier badge
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get kyc_upgrade_recommended;

  /// Per transaction limit label
  ///
  /// In en, this message translates to:
  /// **'Per Transaction'**
  String get kyc_upgrade_perTransaction;

  /// Daily limit label
  ///
  /// In en, this message translates to:
  /// **'Daily Limit'**
  String get kyc_upgrade_dailyLimit;

  /// Monthly limit label
  ///
  /// In en, this message translates to:
  /// **'Monthly Limit'**
  String get kyc_upgrade_monthlyLimit;

  /// And more features text
  ///
  /// In en, this message translates to:
  /// **'and more'**
  String get kyc_upgrade_andMore;

  /// Requirements section title
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get kyc_upgrade_requirements_title;

  /// ID document requirement
  ///
  /// In en, this message translates to:
  /// **'ID Document'**
  String get kyc_upgrade_requirement_idDocument;

  /// Selfie requirement
  ///
  /// In en, this message translates to:
  /// **'Selfie'**
  String get kyc_upgrade_requirement_selfie;

  /// Address proof requirement
  ///
  /// In en, this message translates to:
  /// **'Address Proof'**
  String get kyc_upgrade_requirement_addressProof;

  /// Source of funds requirement
  ///
  /// In en, this message translates to:
  /// **'Source of Funds'**
  String get kyc_upgrade_requirement_sourceOfFunds;

  /// Video verification requirement
  ///
  /// In en, this message translates to:
  /// **'Video Verification'**
  String get kyc_upgrade_requirement_videoVerification;

  /// Start verification button text
  ///
  /// In en, this message translates to:
  /// **'Start Verification'**
  String get kyc_upgrade_startVerification;

  /// Why upgrade section title
  ///
  /// In en, this message translates to:
  /// **'Why upgrade?'**
  String get kyc_upgrade_reason_title;

  /// Success message when device is marked as trusted
  ///
  /// In en, this message translates to:
  /// **'Device marked as trusted'**
  String get settings_deviceTrustedSuccess;

  /// Error message when device trust fails
  ///
  /// In en, this message translates to:
  /// **'Failed to trust device'**
  String get settings_deviceTrustError;

  /// Success message when device is removed
  ///
  /// In en, this message translates to:
  /// **'Device removed successfully'**
  String get settings_deviceRemovedSuccess;

  /// Error message when device removal fails
  ///
  /// In en, this message translates to:
  /// **'Failed to remove device'**
  String get settings_deviceRemoveError;

  /// Help and support settings option
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settings_help;

  /// Rate app option in settings
  ///
  /// In en, this message translates to:
  /// **'Rate JoonaPay'**
  String get settings_rateApp;

  /// Description for rate app option
  ///
  /// In en, this message translates to:
  /// **'Enjoying JoonaPay? Rate us on the App Store'**
  String get settings_rateAppDescription;

  /// Message shown when text is copied to clipboard
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get action_copiedToClipboard;

  /// Title for successful transfer screen
  ///
  /// In en, this message translates to:
  /// **'Transfer Successful!'**
  String get transfer_successTitle;

  /// Message for successful transfer
  ///
  /// In en, this message translates to:
  /// **'Your transfer of {amount} was successful'**
  String transfer_successMessage(String amount);

  /// Transaction ID label
  ///
  /// In en, this message translates to:
  /// **'Transaction ID'**
  String get transactions_transactionId;

  /// Amount label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get common_amount;

  /// Transaction status label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get transactions_status;

  /// Completed transaction status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get transactions_completed;

  /// Note label
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get common_note;

  /// Share receipt button text
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get action_shareReceipt;

  /// Mobile Money withdrawal method
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get withdraw_mobileMoney;

  /// Bank transfer withdrawal method
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get withdraw_bankTransfer;

  /// Crypto wallet withdrawal method
  ///
  /// In en, this message translates to:
  /// **'Crypto Wallet'**
  String get withdraw_crypto;

  /// Mobile Money withdrawal description
  ///
  /// In en, this message translates to:
  /// **'Withdraw to Orange Money, MTN, Wave'**
  String get withdraw_mobileMoneyDesc;

  /// Bank transfer withdrawal description
  ///
  /// In en, this message translates to:
  /// **'Transfer to your bank account'**
  String get withdraw_bankDesc;

  /// Crypto withdrawal description
  ///
  /// In en, this message translates to:
  /// **'Send to external wallet'**
  String get withdraw_cryptoDesc;

  /// Withdraw navigation item
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get navigation_withdraw;

  /// Withdrawal method label
  ///
  /// In en, this message translates to:
  /// **'Withdrawal Method'**
  String get withdraw_method;

  /// Withdrawal processing time info
  ///
  /// In en, this message translates to:
  /// **'Processing times vary by method'**
  String get withdraw_processingInfo;

  /// Withdrawal amount label
  ///
  /// In en, this message translates to:
  /// **'Amount to Withdraw'**
  String get withdraw_amountLabel;

  /// Mobile Money number input label
  ///
  /// In en, this message translates to:
  /// **'Mobile Money Number'**
  String get withdraw_mobileNumber;

  /// Bank details input label
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get withdraw_bankDetails;

  /// Crypto wallet address input label
  ///
  /// In en, this message translates to:
  /// **'Wallet Address'**
  String get withdraw_walletAddress;

  /// Warning about network compatibility
  ///
  /// In en, this message translates to:
  /// **'Make sure you are sending to a Solana USDC address'**
  String get withdraw_networkWarning;
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
