// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'JoonaPay';

  @override
  String get navigation_home => 'Home';

  @override
  String get navigation_settings => 'Settings';

  @override
  String get navigation_send => 'Send';

  @override
  String get navigation_receive => 'Receive';

  @override
  String get navigation_transactions => 'Transactions';

  @override
  String get navigation_services => 'Services';

  @override
  String get action_continue => 'Continue';

  @override
  String get action_cancel => 'Cancel';

  @override
  String get action_confirm => 'Confirm';

  @override
  String get action_back => 'Back';

  @override
  String get action_submit => 'Submit';

  @override
  String get action_done => 'Done';

  @override
  String get action_save => 'Save';

  @override
  String get action_edit => 'Edit';

  @override
  String get action_copy => 'Copy';

  @override
  String get action_share => 'Share';

  @override
  String get action_scan => 'Scan';

  @override
  String get action_retry => 'Retry';

  @override
  String get action_clearAll => 'Clear all';

  @override
  String get action_clearFilters => 'Clear Filters';

  @override
  String get action_tryAgain => 'Try Again';

  @override
  String get auth_login => 'Login';

  @override
  String get auth_verify => 'Verify';

  @override
  String get auth_enterOtp => 'Enter OTP';

  @override
  String get auth_phoneNumber => 'Phone Number';

  @override
  String get auth_pin => 'PIN';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get auth_logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get auth_welcomeBack => 'Welcome back';

  @override
  String get auth_createWallet => 'Create your USDC wallet';

  @override
  String get auth_createAccount => 'Create Account';

  @override
  String get auth_alreadyHaveAccount => 'Already have an account? ';

  @override
  String get auth_dontHaveAccount => 'Don\'t have an account? ';

  @override
  String get auth_signIn => 'Sign in';

  @override
  String get auth_signUp => 'Sign up';

  @override
  String get auth_country => 'Country';

  @override
  String get auth_selectCountry => 'Select Country';

  @override
  String get auth_searchCountry => 'Search country...';

  @override
  String auth_enterDigits(int count) {
    return 'Enter $count digits';
  }

  @override
  String get auth_termsPrompt => 'By continuing, you agree to our';

  @override
  String get auth_termsOfService => 'Terms of Service';

  @override
  String get auth_privacyPolicy => 'Privacy Policy';

  @override
  String get auth_and => ' and ';

  @override
  String get auth_secureLogin => 'Secure Login';

  @override
  String auth_otpMessage(String phone) {
    return 'Enter the 6-digit code sent to $phone';
  }

  @override
  String get auth_waitingForSms => 'Waiting for SMS...';

  @override
  String get auth_resendCode => 'Resend Code';

  @override
  String get wallet_balance => 'Balance';

  @override
  String get wallet_sendMoney => 'Send Money';

  @override
  String get wallet_receiveMoney => 'Receive Money';

  @override
  String get wallet_transactionHistory => 'Transaction History';

  @override
  String get wallet_availableBalance => 'Available Balance';

  @override
  String get wallet_totalBalance => 'Total Balance';

  @override
  String get wallet_usdBalance => 'USD';

  @override
  String get wallet_usdcBalance => 'USDC';

  @override
  String get wallet_fiatBalance => 'Fiat Balance';

  @override
  String get wallet_stablecoin => 'Stablecoin';

  @override
  String get wallet_createWallet => 'Create Wallet';

  @override
  String get wallet_noWalletFound => 'No Wallet Found';

  @override
  String get wallet_createWalletMessage =>
      'Create your wallet to start sending and receiving money';

  @override
  String get wallet_loadingWallet => 'Loading wallet...';

  @override
  String get home_welcomeBack => 'Welcome back';

  @override
  String get home_allServices => 'All Services';

  @override
  String get home_viewAllFeatures => 'View all available features';

  @override
  String get home_recentTransactions => 'Recent Transactions';

  @override
  String get home_noTransactionsYet => 'No Transactions Yet';

  @override
  String get home_transactionsWillAppear =>
      'Your recent transactions will appear here';

  @override
  String get send_title => 'Send Money';

  @override
  String get send_toPhone => 'To Phone';

  @override
  String get send_toWallet => 'To Wallet';

  @override
  String get send_recent => 'Recent';

  @override
  String get send_recipient => 'Recipient';

  @override
  String get send_saved => 'Saved';

  @override
  String get send_contacts => 'Contacts';

  @override
  String get send_amountUsd => 'Amount (USD)';

  @override
  String get send_walletAddress => 'Wallet Address';

  @override
  String get send_networkInfo =>
      'External transfers are on the Polygon network. Network fees apply.';

  @override
  String get send_transferSuccess => 'Transfer successful!';

  @override
  String get send_invalidAmount => 'Enter a valid amount';

  @override
  String get send_insufficientBalance => 'Insufficient balance';

  @override
  String get send_addressMustStartWith0x => 'Address must start with 0x';

  @override
  String get send_addressLength => 'Address must be exactly 42 characters';

  @override
  String get send_invalidEthereumAddress => 'Invalid Ethereum address format';

  @override
  String get send_saveRecipientPrompt => 'Save Recipient?';

  @override
  String get send_saveRecipientMessage =>
      'Would you like to save this recipient for future transfers?';

  @override
  String get send_notNow => 'Not Now';

  @override
  String get send_saveRecipientTitle => 'Save Recipient';

  @override
  String get send_enterRecipientName => 'Enter a name for this recipient';

  @override
  String get send_name => 'Name';

  @override
  String get send_recipientSaved => 'Recipient saved';

  @override
  String get send_failedToSaveRecipient => 'Failed to save recipient';

  @override
  String get send_selectSavedRecipient => 'Select Saved Recipient';

  @override
  String get send_selectContact => 'Select Contact';

  @override
  String get send_searchRecipients => 'Search recipients...';

  @override
  String get send_searchContacts => 'Search contacts...';

  @override
  String get send_noSavedRecipients => 'No saved recipients';

  @override
  String get send_failedToLoadRecipients => 'Failed to load recipients';

  @override
  String get send_joonaPayUser => 'JoonaPay user';

  @override
  String get send_tooManyAttempts =>
      'Too many incorrect attempts. Please try again later.';

  @override
  String get receive_title => 'Receive USDC';

  @override
  String get receive_receiveUsdc => 'Receive USDC';

  @override
  String receive_onlySendUsdc(String network) {
    return 'Only send USDC on $network network';
  }

  @override
  String get receive_yourWalletAddress => 'Your Wallet Address';

  @override
  String get receive_walletNotAvailable => 'Wallet address not available';

  @override
  String get receive_addressCopied =>
      'Address copied to clipboard (auto-clears in 60s)';

  @override
  String receive_shareMessage(String network, String address) {
    return 'Send USDC to my wallet on $network:\n\n$address';
  }

  @override
  String get receive_shareSubject => 'My USDC Wallet Address';

  @override
  String get receive_important => 'Important';

  @override
  String receive_warningMessage(String network) {
    return 'Only send USDC on the $network network to this address. Sending other tokens or using a different network may result in permanent loss of funds.';
  }

  @override
  String get transactions_title => 'Transactions';

  @override
  String get transactions_searchPlaceholder => 'Search transactions...';

  @override
  String get transactions_noResultsFound => 'No Results Found';

  @override
  String get transactions_noTransactions => 'No Transactions';

  @override
  String get transactions_adjustFilters =>
      'Try adjusting your filters or search query to find what you\'re looking for.';

  @override
  String get transactions_historyMessage =>
      'Your transaction history will appear here once you make your first deposit or transfer.';

  @override
  String get transactions_somethingWentWrong => 'Something Went Wrong';

  @override
  String get transactions_today => 'Today';

  @override
  String get transactions_yesterday => 'Yesterday';

  @override
  String get transactions_deposit => 'Deposit';

  @override
  String get transactions_withdrawal => 'Withdrawal';

  @override
  String get transactions_transferReceived => 'Transfer Received';

  @override
  String get transactions_transferSent => 'Transfer Sent';

  @override
  String get transactions_mobileMoneyDeposit => 'Mobile Money Deposit';

  @override
  String get transactions_mobileMoneyWithdrawal => 'Mobile Money Withdrawal';

  @override
  String get transactions_fromJoonaPayUser => 'From JoonaPay User';

  @override
  String get transactions_externalWallet => 'External Wallet';

  @override
  String get transactions_deposits => 'Deposits';

  @override
  String get transactions_withdrawals => 'Withdrawals';

  @override
  String get transactions_receivedFilter => 'Received';

  @override
  String get transactions_sentFilter => 'Sent';

  @override
  String get services_title => 'Services';

  @override
  String get services_coreServices => 'Core Services';

  @override
  String get services_financialServices => 'Financial Services';

  @override
  String get services_billsPayments => 'Bills & Payments';

  @override
  String get services_toolsAnalytics => 'Tools & Analytics';

  @override
  String get services_sendMoney => 'Send Money';

  @override
  String get services_sendMoneyDesc => 'Transfer to any wallet';

  @override
  String get services_receiveMoney => 'Receive Money';

  @override
  String get services_receiveMoneyDesc => 'Get your wallet address';

  @override
  String get services_requestMoney => 'Request Money';

  @override
  String get services_requestMoneyDesc => 'Create payment request';

  @override
  String get services_scanQr => 'Scan QR';

  @override
  String get services_scanQrDesc => 'Scan to pay or receive';

  @override
  String get services_recipients => 'Recipients';

  @override
  String get services_recipientsDesc => 'Manage saved contacts';

  @override
  String get services_scheduledTransfers => 'Scheduled Transfers';

  @override
  String get services_scheduledTransfersDesc => 'Manage recurring payments';

  @override
  String get services_virtualCard => 'Virtual Card';

  @override
  String get services_virtualCardDesc => 'Online shopping card';

  @override
  String get services_savingsGoals => 'Savings Goals';

  @override
  String get services_savingsGoalsDesc => 'Track your savings';

  @override
  String get services_budget => 'Budget';

  @override
  String get services_budgetDesc => 'Manage spending limits';

  @override
  String get services_currencyConverter => 'Currency Converter';

  @override
  String get services_currencyConverterDesc => 'Convert currencies';

  @override
  String get services_billPayments => 'Bill Payments';

  @override
  String get services_billPaymentsDesc => 'Pay utility bills';

  @override
  String get services_buyAirtime => 'Buy Airtime';

  @override
  String get services_buyAirtimeDesc => 'Mobile top-up';

  @override
  String get services_splitBills => 'Split Bills';

  @override
  String get services_splitBillsDesc => 'Share expenses';

  @override
  String get services_analytics => 'Analytics';

  @override
  String get services_analyticsDesc => 'View spending insights';

  @override
  String get services_referrals => 'Referrals';

  @override
  String get services_referralsDesc => 'Invite and earn';

  @override
  String get settings_profile => 'Profile';

  @override
  String get settings_profileDescription => 'Manage your personal information';

  @override
  String get settings_security => 'Security';

  @override
  String get settings_securitySettings => 'Security Settings';

  @override
  String get settings_securityDescription => 'PIN, 2FA, biometrics';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_preferences => 'Preferences';

  @override
  String get settings_defaultCurrency => 'Default Currency';

  @override
  String get settings_support => 'Support';

  @override
  String get settings_helpSupport => 'Help & Support';

  @override
  String get settings_helpDescription => 'FAQs, chat, contact';

  @override
  String get settings_kycVerification => 'KYC Verification';

  @override
  String get settings_transactionLimits => 'Transaction Limits';

  @override
  String get settings_limitsDescription => 'View & increase limits';

  @override
  String get settings_referEarn => 'Refer & Earn';

  @override
  String get settings_referDescription => 'Invite friends and earn rewards';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get kyc_verified => 'Verified';

  @override
  String get kyc_pending => 'Pending Review';

  @override
  String get kyc_rejected => 'Rejected - Retry';

  @override
  String get kyc_notStarted => 'Not Started';

  @override
  String get transaction_sent => 'Sent';

  @override
  String get transaction_received => 'Received';

  @override
  String get transaction_pending => 'Pending';

  @override
  String get transaction_failed => 'Failed';

  @override
  String get transaction_completed => 'Completed';

  @override
  String get error_generic => 'Something went wrong. Please try again.';

  @override
  String get error_network => 'Network error. Please check your connection.';

  @override
  String get error_failedToLoadBalance => 'Failed to load balance';

  @override
  String get error_failedToLoadTransactions => 'Failed to load transactions';

  @override
  String get language_english => 'English';

  @override
  String get language_french => 'French';

  @override
  String get language_selectLanguage => 'Select Language';

  @override
  String get language_changeLanguage => 'Change Language';
}
