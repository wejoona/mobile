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

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get action_tryAgain;

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
  /// **'External transfers are on the Polygon network. Network fees apply.'**
  String get send_networkInfo;

  /// Transfer success message
  ///
  /// In en, this message translates to:
  /// **'Transfer successful!'**
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

  /// Select contact sheet title
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
  /// **'Search contacts...'**
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

  /// Only send USDC warning
  ///
  /// In en, this message translates to:
  /// **'Only send USDC on {network} network'**
  String receive_onlySendUsdc(String network);

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
  /// **'Send USDC to my wallet on {network}:\n\n{address}'**
  String receive_shareMessage(String network, String address);

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
  /// **'Only send USDC on the {network} network to this address. Sending other tokens or using a different network may result in permanent loss of funds.'**
  String receive_warningMessage(String network);

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
