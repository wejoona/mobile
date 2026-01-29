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
  String get action_remove => 'Remove';

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
  String get auth_logout => 'Logout';

  @override
  String get auth_logoutConfirm => 'Are you sure you want to logout?';

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
  String get auth_phoneInvalid => 'Please enter a valid phone number';

  @override
  String get auth_otp => 'OTP Code';

  @override
  String get auth_resendOtp => 'Resend OTP';

  @override
  String get auth_error_invalidOtp => 'Invalid OTP code. Please try again.';

  @override
  String get login_welcomeBack => 'Welcome back';

  @override
  String get login_enterPhone => 'Enter your phone number to login';

  @override
  String get login_rememberPhone => 'Remember this device';

  @override
  String get login_noAccount => 'Don\'t have an account?';

  @override
  String get login_createAccount => 'Create account';

  @override
  String get login_verifyCode => 'Verify your code';

  @override
  String login_codeSentTo(String countryCode, String phone) {
    return 'Enter the 6-digit code sent to $countryCode $phone';
  }

  @override
  String get login_resendCode => 'Resend code';

  @override
  String login_resendIn(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get login_verifying => 'Verifying...';

  @override
  String get login_enterPin => 'Enter your PIN';

  @override
  String get login_pinSubtitle =>
      'Enter your 6-digit PIN to access your wallet';

  @override
  String get login_forgotPin => 'Forgot PIN?';

  @override
  String login_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining',
      one: '1 attempt remaining',
    );
    return '$_temp0';
  }

  @override
  String get login_accountLocked => 'Account Locked';

  @override
  String get login_lockedMessage =>
      'Too many failed attempts. Your account has been locked for 15 minutes for security.';

  @override
  String get common_ok => 'OK';

  @override
  String get common_continue => 'Continue';

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
  String get wallet_activateTitle => 'Activate Your Wallet';

  @override
  String get wallet_activateDescription =>
      'Set up your USDC wallet to start sending and receiving money instantly';

  @override
  String get wallet_activateButton => 'Activate Wallet';

  @override
  String get wallet_activating => 'Activating your wallet...';

  @override
  String get wallet_activateFailed =>
      'Failed to activate wallet. Please try again.';

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
  String get home_balance => 'Balance';

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
      'External transfers may take a few minutes. Small fees apply.';

  @override
  String get send_transferSuccess => 'Transfer Successful!';

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
  String get send_searchContacts => 'Search contacts';

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
  String get receive_onlySendUsdc => 'Share your address to receive USDC';

  @override
  String get receive_yourWalletAddress => 'Your Wallet Address';

  @override
  String get receive_walletNotAvailable => 'Wallet address not available';

  @override
  String get receive_addressCopied =>
      'Address copied to clipboard (auto-clears in 60s)';

  @override
  String receive_shareMessage(String address) {
    return 'Send USDC to my JoonaPay wallet:\n\n$address';
  }

  @override
  String get receive_shareSubject => 'My USDC Wallet Address';

  @override
  String get receive_important => 'Important';

  @override
  String get receive_warningMessage =>
      'Only send USDC to this address. Sending other tokens may result in permanent loss of funds.';

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
  String get settings_devices => 'Devices';

  @override
  String get settings_devicesDescription =>
      'Manage devices that have access to your account. Revoke access from any device.';

  @override
  String get settings_thisDevice => 'This device';

  @override
  String get settings_lastActive => 'Last active';

  @override
  String get settings_loginCount => 'Logins';

  @override
  String get settings_times => 'times';

  @override
  String get settings_lastIp => 'Last IP';

  @override
  String get settings_trustDevice => 'Trust Device';

  @override
  String get settings_removeDevice => 'Remove Device';

  @override
  String get settings_removeDeviceConfirm =>
      'This device will be logged out and will need to authenticate again to access your account.';

  @override
  String get settings_noDevices => 'No Devices Found';

  @override
  String get settings_noDevicesDescription =>
      'You don\'t have any registered devices yet.';

  @override
  String get kyc_verified => 'Verified';

  @override
  String get kyc_pending => 'Pending Review';

  @override
  String get kyc_rejected => 'Rejected - Retry';

  @override
  String get kyc_notStarted => 'Not Started';

  @override
  String get kyc_title => 'Identity Verification';

  @override
  String get kyc_selectDocumentType => 'Select Document Type';

  @override
  String get kyc_selectDocumentType_description =>
      'Choose the type of document you\'d like to verify with';

  @override
  String get kyc_documentType_nationalId => 'National ID Card';

  @override
  String get kyc_documentType_nationalId_description =>
      'Government-issued ID card';

  @override
  String get kyc_documentType_passport => 'Passport';

  @override
  String get kyc_documentType_passport_description =>
      'International travel document';

  @override
  String get kyc_documentType_driversLicense => 'Driver\'s License';

  @override
  String get kyc_documentType_driversLicense_description =>
      'Government-issued driver\'s license';

  @override
  String get kyc_capture_frontSide_guidance =>
      'Align the front of your document within the frame';

  @override
  String get kyc_capture_backSide_guidance =>
      'Align the back of your document within the frame';

  @override
  String get kyc_capture_nationalIdInstructions =>
      'Position your ID card flat and well-lit within the frame';

  @override
  String get kyc_capture_passportInstructions =>
      'Position your passport photo page within the frame';

  @override
  String get kyc_capture_driversLicenseInstructions =>
      'Position your driver\'s license flat within the frame';

  @override
  String get kyc_capture_backInstructions =>
      'Now capture the back side of your document';

  @override
  String get kyc_checkingQuality => 'Checking image quality...';

  @override
  String get kyc_reviewImage => 'Review Image';

  @override
  String get kyc_retake => 'Retake';

  @override
  String get kyc_accept => 'Accept';

  @override
  String get kyc_error_imageQuality =>
      'Image quality is not acceptable. Please try again.';

  @override
  String get kyc_error_imageBlurry =>
      'Image is too blurry. Hold your phone steady and try again.';

  @override
  String get kyc_error_imageGlare =>
      'Too much glare detected. Avoid direct light and try again.';

  @override
  String get kyc_error_imageTooDark =>
      'Image is too dark. Use better lighting and try again.';

  @override
  String get kyc_status_pending_title => 'Start Verification';

  @override
  String get kyc_status_pending_description =>
      'Complete your identity verification to unlock higher limits and all features.';

  @override
  String get kyc_status_submitted_title => 'Verification In Progress';

  @override
  String get kyc_status_submitted_description =>
      'Your documents are being reviewed. This usually takes 1-2 business days.';

  @override
  String get kyc_status_approved_title => 'Verification Complete';

  @override
  String get kyc_status_approved_description =>
      'Your identity has been verified. You now have access to all features!';

  @override
  String get kyc_status_rejected_title => 'Verification Failed';

  @override
  String get kyc_status_rejected_description =>
      'We couldn\'t verify your documents. Please review the reason below and try again.';

  @override
  String get kyc_status_additionalInfo_title => 'Additional Information Needed';

  @override
  String get kyc_status_additionalInfo_description =>
      'Please provide additional information to complete your verification.';

  @override
  String get kyc_rejectionReason => 'Rejection Reason';

  @override
  String get kyc_tryAgain => 'Try Again';

  @override
  String get kyc_startVerification => 'Start Verification';

  @override
  String get kyc_info_security_title => 'Your Data is Secure';

  @override
  String get kyc_info_security_description =>
      'All documents are encrypted and securely stored';

  @override
  String get kyc_info_time_title => 'Quick Process';

  @override
  String get kyc_info_time_description =>
      'Verification usually takes 1-2 business days';

  @override
  String get kyc_info_documents_title => 'Documents Needed';

  @override
  String get kyc_info_documents_description =>
      'Valid government-issued ID or passport';

  @override
  String get kyc_reviewDocuments => 'Review Documents';

  @override
  String get kyc_review_description =>
      'Review your captured documents before submitting for verification';

  @override
  String get kyc_review_documents => 'Documents';

  @override
  String get kyc_review_documentFront => 'Document Front';

  @override
  String get kyc_review_documentBack => 'Document Back';

  @override
  String get kyc_review_selfie => 'Selfie';

  @override
  String get kyc_review_yourSelfie => 'Your Selfie';

  @override
  String get kyc_submitForVerification => 'Submit for Verification';

  @override
  String get kyc_selfie_title => 'Take a Selfie';

  @override
  String get kyc_selfie_guidance => 'Position your face in the oval frame';

  @override
  String get kyc_selfie_livenessHint => 'Make sure you\'re in a well-lit area';

  @override
  String get kyc_selfie_instructions =>
      'Look straight at the camera and keep your face within the frame';

  @override
  String get kyc_reviewSelfie => 'Review Selfie';

  @override
  String get kyc_submitted_title => 'Verification Submitted';

  @override
  String get kyc_submitted_description =>
      'Thank you! Your documents have been submitted for verification. We\'ll notify you once the review is complete.';

  @override
  String get kyc_submitted_timeEstimate =>
      'Verification usually takes 1-2 business days';

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

  @override
  String get currency_primary => 'Primary Currency';

  @override
  String get currency_reference => 'Reference Currency';

  @override
  String get currency_referenceDescription =>
      'Displays local currency equivalent below your USDC balance for reference only. Exchange rates are approximate.';

  @override
  String get currency_showReference => 'Show Local Currency';

  @override
  String get currency_showReferenceDescription =>
      'Display approximate local currency value below USDC amounts';

  @override
  String get currency_preview => 'Preview';

  @override
  String get settings_activeSessions => 'Active Sessions';

  @override
  String get sessions_currentSession => 'Current session';

  @override
  String get sessions_unknownLocation => 'Unknown location';

  @override
  String get sessions_unknownIP => 'Unknown IP';

  @override
  String get sessions_lastActive => 'Last active';

  @override
  String get sessions_revokeTitle => 'Revoke Session';

  @override
  String get sessions_revokeMessage =>
      'Are you sure you want to revoke this session? This device will be logged out immediately.';

  @override
  String get sessions_revoke => 'Revoke';

  @override
  String get sessions_revokeSuccess => 'Session revoked successfully';

  @override
  String get sessions_logoutAllDevices => 'Logout from All Devices';

  @override
  String get sessions_logoutAllTitle => 'Logout from All Devices?';

  @override
  String get sessions_logoutAllMessage =>
      'This will log you out from all devices including this one. You\'ll need to log in again.';

  @override
  String get sessions_logoutAllWarning => 'This action cannot be undone';

  @override
  String get sessions_logoutAll => 'Logout All';

  @override
  String get sessions_logoutAllSuccess => 'Logged out from all devices';

  @override
  String get sessions_errorLoading => 'Failed to Load Sessions';

  @override
  String get sessions_noActiveSessions => 'No Active Sessions';

  @override
  String get sessions_noActiveSessionsDesc =>
      'You don\'t have any active sessions at the moment.';

  @override
  String get beneficiaries_title => 'Beneficiaries';

  @override
  String get beneficiaries_tabAll => 'All';

  @override
  String get beneficiaries_tabFavorites => 'Favorites';

  @override
  String get beneficiaries_tabRecent => 'Recent';

  @override
  String get beneficiaries_searchHint => 'Search by name or phone';

  @override
  String get beneficiaries_addTitle => 'Add Beneficiary';

  @override
  String get beneficiaries_editTitle => 'Edit Beneficiary';

  @override
  String get beneficiaries_fieldName => 'Name';

  @override
  String get beneficiaries_fieldPhone => 'Phone Number';

  @override
  String get beneficiaries_fieldAccountType => 'Account Type';

  @override
  String get beneficiaries_fieldWalletAddress => 'Wallet Address';

  @override
  String get beneficiaries_fieldBankCode => 'Bank Code';

  @override
  String get beneficiaries_fieldBankAccount => 'Bank Account Number';

  @override
  String get beneficiaries_fieldMobileMoneyProvider => 'Mobile Money Provider';

  @override
  String get beneficiaries_typeJoonapay => 'JoonaPay User';

  @override
  String get beneficiaries_typeWallet => 'External Wallet';

  @override
  String get beneficiaries_typeBank => 'Bank Account';

  @override
  String get beneficiaries_typeMobileMoney => 'Mobile Money';

  @override
  String get beneficiaries_addButton => 'Add Beneficiary';

  @override
  String get beneficiaries_addFirst => 'Add Your First Beneficiary';

  @override
  String get beneficiaries_emptyTitle => 'No Beneficiaries Yet';

  @override
  String get beneficiaries_emptyMessage =>
      'Add beneficiaries to send money faster next time';

  @override
  String get beneficiaries_emptyFavoritesTitle => 'No Favorites';

  @override
  String get beneficiaries_emptyFavoritesMessage =>
      'Star your frequently used beneficiaries to see them here';

  @override
  String get beneficiaries_emptyRecentTitle => 'No Recent Transfers';

  @override
  String get beneficiaries_emptyRecentMessage =>
      'Beneficiaries you\'ve sent money to will appear here';

  @override
  String get beneficiaries_menuEdit => 'Edit';

  @override
  String get beneficiaries_menuDelete => 'Delete';

  @override
  String get beneficiaries_deleteTitle => 'Delete Beneficiary?';

  @override
  String beneficiaries_deleteMessage(String name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String get beneficiaries_deleteSuccess => 'Beneficiary deleted successfully';

  @override
  String get beneficiaries_createSuccess => 'Beneficiary added successfully';

  @override
  String get beneficiaries_updateSuccess => 'Beneficiary updated successfully';

  @override
  String get beneficiaries_errorTitle => 'Error Loading Beneficiaries';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Retry';

  @override
  String get error_required => 'This field is required';

  @override
  String get qr_receiveTitle => 'Receive Payment';

  @override
  String get qr_scanTitle => 'Scan QR Code';

  @override
  String get qr_requestSpecificAmount => 'Request specific amount';

  @override
  String get qr_amountLabel => 'Amount (USD)';

  @override
  String get qr_howToReceive => 'How to receive payment';

  @override
  String get qr_receiveInstructions =>
      'Share this QR code with the sender. They can scan it with their JoonaPay app to send you money instantly.';

  @override
  String get qr_savedToGallery => 'QR code saved to gallery';

  @override
  String get qr_failedToSave => 'Failed to save QR code';

  @override
  String get qr_initializingCamera => 'Initializing camera...';

  @override
  String get qr_scanInstruction => 'Scan a JoonaPay QR code';

  @override
  String get qr_scanSubInstruction =>
      'Point your camera at a QR code to send money';

  @override
  String get qr_scanned => 'QR Code Scanned';

  @override
  String get qr_invalidCode => 'Invalid QR Code';

  @override
  String get qr_invalidCodeMessage =>
      'This QR code is not a valid JoonaPay payment code.';

  @override
  String get qr_scanAgain => 'Scan Again';

  @override
  String get qr_sendMoney => 'Send Money';

  @override
  String get qr_cameraPermissionRequired => 'Camera Permission Required';

  @override
  String get qr_cameraPermissionMessage =>
      'Please grant camera permission to scan QR codes.';

  @override
  String get qr_openSettings => 'Open Settings';

  @override
  String get qr_galleryImportSoon => 'Gallery import coming soon';

  @override
  String get home_goodMorning => 'Good morning';

  @override
  String get home_goodAfternoon => 'Good afternoon';

  @override
  String get home_goodEvening => 'Good evening';

  @override
  String get home_goodNight => 'Good night';

  @override
  String get home_totalBalance => 'Total Balance';

  @override
  String get home_hideBalance => 'Hide balance';

  @override
  String get home_showBalance => 'Show balance';

  @override
  String get home_quickAction_send => 'Send';

  @override
  String get home_quickAction_receive => 'Receive';

  @override
  String get home_quickAction_deposit => 'Deposit';

  @override
  String get home_quickAction_history => 'History';

  @override
  String get home_kycBanner_title =>
      'Complete verification to unlock all features';

  @override
  String get home_kycBanner_action => 'Verify Now';

  @override
  String get home_recentActivity => 'Recent Activity';

  @override
  String get home_seeAll => 'See All';

  @override
  String get deposit_title => 'Deposit Funds';

  @override
  String get deposit_quickAmounts => 'Quick amounts';

  @override
  String deposit_rateUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get deposit_youWillReceive => 'You will receive';

  @override
  String get deposit_youWillPay => 'You will pay';

  @override
  String get deposit_limits => 'Deposit Limits';

  @override
  String get deposit_selectProvider => 'Select Provider';

  @override
  String get deposit_chooseProvider => 'Choose a payment method';

  @override
  String get deposit_amountToPay => 'Amount to pay';

  @override
  String get deposit_noFee => 'No fee';

  @override
  String get deposit_fee => 'fee';

  @override
  String get deposit_paymentInstructions => 'Payment Instructions';

  @override
  String get deposit_expiresIn => 'Expires in';

  @override
  String deposit_via(String provider) {
    return 'via $provider';
  }

  @override
  String get deposit_referenceNumber => 'Reference Number';

  @override
  String get deposit_howToPay => 'How to complete payment';

  @override
  String get deposit_ussdCode => 'USSD Code';

  @override
  String deposit_openApp(String provider) {
    return 'Open $provider App';
  }

  @override
  String get deposit_completedPayment => 'I\'ve completed payment';

  @override
  String get deposit_copied => 'Copied to clipboard';

  @override
  String get deposit_cancelTitle => 'Cancel deposit?';

  @override
  String get deposit_cancelMessage =>
      'Your payment session will be cancelled. You can start a new deposit later.';

  @override
  String get deposit_processing => 'Processing';

  @override
  String get deposit_success => 'Deposit Successful!';

  @override
  String get deposit_failed => 'Deposit Failed';

  @override
  String get deposit_expired => 'Session Expired';

  @override
  String get deposit_processingMessage =>
      'We\'re processing your payment. This may take a few moments.';

  @override
  String get deposit_successMessage =>
      'Your funds have been added to your wallet!';

  @override
  String get deposit_failedMessage =>
      'We couldn\'t process your payment. Please try again.';

  @override
  String get deposit_expiredMessage =>
      'Your payment session has expired. Please start a new deposit.';

  @override
  String get deposit_deposited => 'Deposited';

  @override
  String get deposit_received => 'Received';

  @override
  String get deposit_backToHome => 'Back to Home';

  @override
  String get common_error => 'An error occurred';

  @override
  String get pin_createTitle => 'Create Your PIN';

  @override
  String get pin_confirmTitle => 'Confirm Your PIN';

  @override
  String get pin_changeTitle => 'Change PIN';

  @override
  String get pin_resetTitle => 'Reset PIN';

  @override
  String get pin_enterNewPin => 'Enter your new 6-digit PIN';

  @override
  String get pin_reenterPin => 'Re-enter your PIN to confirm';

  @override
  String get pin_enterCurrentPin => 'Enter your current PIN';

  @override
  String get pin_confirmNewPin => 'Confirm your new PIN';

  @override
  String get pin_requirements => 'PIN Requirements';

  @override
  String get pin_rule_6digits => '6 digits';

  @override
  String get pin_rule_noSequential => 'No sequential numbers (123456)';

  @override
  String get pin_rule_noRepeated => 'No repeated digits (111111)';

  @override
  String get pin_error_sequential => 'PIN cannot be sequential numbers';

  @override
  String get pin_error_repeated => 'PIN cannot be all the same digit';

  @override
  String get pin_error_noMatch => 'PINs don\'t match. Please try again.';

  @override
  String get pin_error_wrongCurrent => 'Current PIN is incorrect';

  @override
  String get pin_error_saveFailed => 'Failed to save PIN. Please try again.';

  @override
  String get pin_error_changeFailed =>
      'Failed to change PIN. Please try again.';

  @override
  String get pin_error_resetFailed => 'Failed to reset PIN. Please try again.';

  @override
  String get pin_success_set => 'PIN created successfully';

  @override
  String get pin_success_changed => 'PIN changed successfully';

  @override
  String get pin_success_reset => 'PIN reset successfully';

  @override
  String pin_attemptsRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count attempts remaining',
      one: '1 attempt remaining',
    );
    return '$_temp0';
  }

  @override
  String get pin_forgotPin => 'Forgot PIN?';

  @override
  String get pin_locked_title => 'PIN Locked';

  @override
  String get pin_locked_message =>
      'Too many failed attempts. Your PIN is temporarily locked.';

  @override
  String get pin_locked_tryAgainIn => 'Try again in';

  @override
  String get pin_resetViaOtp => 'Reset PIN via SMS';

  @override
  String get pin_reset_requestTitle => 'Reset Your PIN';

  @override
  String get pin_reset_requestMessage =>
      'We\'ll send a verification code to your registered phone number to reset your PIN.';

  @override
  String get pin_reset_sendOtp => 'Send Verification Code';

  @override
  String get pin_reset_enterOtp => 'Enter the 6-digit code sent to your phone';

  @override
  String get send_selectRecipient => 'Select Recipient';

  @override
  String get send_recipientPhone => 'Recipient Phone Number';

  @override
  String get send_fromContacts => 'Contacts';

  @override
  String get send_fromBeneficiaries => 'Beneficiaries';

  @override
  String get send_recentRecipients => 'Recent Recipients';

  @override
  String get send_contactsPermissionDenied =>
      'Contacts permission is required to select a contact';

  @override
  String get send_noContactsFound => 'No contacts found';

  @override
  String get send_selectBeneficiary => 'Select Beneficiary';

  @override
  String get send_searchBeneficiaries => 'Search beneficiaries';

  @override
  String get send_noBeneficiariesFound => 'No beneficiaries found';

  @override
  String get send_enterAmount => 'Enter Amount';

  @override
  String get send_amount => 'Amount';

  @override
  String get send_max => 'MAX';

  @override
  String get send_note => 'Note';

  @override
  String get send_noteOptional => 'Add a note (optional)';

  @override
  String get send_fee => 'Fee';

  @override
  String get send_total => 'Total';

  @override
  String get send_confirmTransfer => 'Confirm Transfer';

  @override
  String get send_pinVerificationRequired =>
      'You will be asked to enter your PIN to confirm this transfer';

  @override
  String get send_confirmAndSend => 'Confirm & Send';

  @override
  String get send_verifyPin => 'Verify PIN';

  @override
  String get send_enterPinToConfirm => 'Enter your PIN';

  @override
  String get send_pinVerificationDescription =>
      'Enter your 6-digit PIN to confirm this transfer';

  @override
  String get send_useBiometric => 'Use Biometric';

  @override
  String get send_biometricReason =>
      'Verify your identity to complete the transfer';

  @override
  String get send_transferFailed => 'Transfer Failed';

  @override
  String get send_transferSuccessMessage =>
      'Your money has been sent successfully';

  @override
  String get send_sentTo => 'Sent to';

  @override
  String get send_reference => 'Reference';

  @override
  String get send_date => 'Date';

  @override
  String get send_saveAsBeneficiary => 'Save as Beneficiary';

  @override
  String get send_shareReceipt => 'Share Receipt';

  @override
  String get send_transferReceipt => 'Transfer Receipt';

  @override
  String get send_beneficiarySaved => 'Beneficiary saved successfully';

  @override
  String get error_phoneRequired => 'Phone number is required';

  @override
  String get error_phoneInvalid => 'Invalid phone number';

  @override
  String get error_amountRequired => 'Amount is required';

  @override
  String get error_amountInvalid => 'Invalid amount';

  @override
  String get error_insufficientBalance => 'Insufficient balance';

  @override
  String get error_pinIncorrect => 'Incorrect PIN. Please try again.';

  @override
  String get error_biometricFailed => 'Biometric authentication failed';

  @override
  String get error_transferFailed => 'Transfer failed. Please try again.';

  @override
  String get common_copiedToClipboard => 'Copied to clipboard';

  @override
  String get notifications_permission_title => 'Stay Informed';

  @override
  String get notifications_permission_description =>
      'Get instant updates about your transactions, security alerts, and important account activity.';

  @override
  String get notifications_benefit_transactions => 'Transaction Updates';

  @override
  String get notifications_benefit_transactions_desc =>
      'Instant alerts when you send or receive money';

  @override
  String get notifications_benefit_security => 'Security Alerts';

  @override
  String get notifications_benefit_security_desc =>
      'Be notified of suspicious activity and new device logins';

  @override
  String get notifications_benefit_updates => 'Important Updates';

  @override
  String get notifications_benefit_updates_desc =>
      'Stay updated on new features and special offers';

  @override
  String get notifications_enable_notifications => 'Enable Notifications';

  @override
  String get notifications_maybe_later => 'Maybe Later';

  @override
  String get notifications_enabled_success =>
      'Notifications enabled successfully';

  @override
  String get notifications_permission_denied_title => 'Permission Required';

  @override
  String get notifications_permission_denied_message =>
      'To receive notifications, you need to enable them in your device settings.';

  @override
  String get action_open_settings => 'Open Settings';

  @override
  String get notifications_preferences_title => 'Notification Preferences';

  @override
  String get notifications_preferences_description =>
      'Choose which notifications you\'d like to receive';

  @override
  String get notifications_pref_transaction_title => 'Transaction Alerts';

  @override
  String get notifications_pref_transaction_alerts => 'All transaction alerts';

  @override
  String get notifications_pref_transaction_alerts_desc =>
      'Get notified for all incoming and outgoing transactions';

  @override
  String get notifications_pref_security_title => 'Security';

  @override
  String get notifications_pref_security_alerts => 'Security alerts';

  @override
  String get notifications_pref_security_alerts_desc =>
      'Critical security alerts (cannot be disabled)';

  @override
  String get notifications_pref_promotional_title => 'Promotional';

  @override
  String get notifications_pref_promotions => 'Promotions and offers';

  @override
  String get notifications_pref_promotions_desc =>
      'Special offers and promotional campaigns';

  @override
  String get notifications_pref_price_title => 'Market Updates';

  @override
  String get notifications_pref_price_alerts => 'Price alerts';

  @override
  String get notifications_pref_price_alerts_desc =>
      'USDC and crypto price movements';

  @override
  String get notifications_pref_summary_title => 'Reports';

  @override
  String get notifications_pref_weekly_summary => 'Weekly spending summary';

  @override
  String get notifications_pref_weekly_summary_desc =>
      'Receive a summary of your weekly activity';

  @override
  String get notifications_pref_thresholds_title => 'Alert Thresholds';

  @override
  String get notifications_pref_thresholds_description =>
      'Set custom amounts to trigger alerts';

  @override
  String get notifications_pref_large_transaction_threshold =>
      'Large transaction alert';

  @override
  String get notifications_pref_low_balance_threshold => 'Low balance alert';

  @override
  String get settings_editProfile => 'Edit Profile';

  @override
  String get settings_account => 'Account';

  @override
  String get settings_about => 'About';

  @override
  String get settings_termsOfService => 'Terms of Service';

  @override
  String get settings_privacyPolicy => 'Privacy Policy';

  @override
  String get settings_appVersion => 'App Version';

  @override
  String get profile_firstName => 'First Name';

  @override
  String get profile_lastName => 'Last Name';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_phoneNumber => 'Phone Number';

  @override
  String get profile_phoneCannotChange => 'Phone number cannot be changed';

  @override
  String get profile_updateSuccess => 'Profile updated successfully';

  @override
  String get profile_updateError => 'Failed to update profile';

  @override
  String get help_faq => 'Frequently Asked Questions';

  @override
  String get help_needMoreHelp => 'Need More Help?';

  @override
  String get help_reportProblem => 'Report Problem';

  @override
  String get help_liveChat => 'Live Chat';

  @override
  String get help_emailSupport => 'Email Support';

  @override
  String get help_whatsappSupport => 'WhatsApp Support';

  @override
  String get help_copiedToClipboard => 'Copied to clipboard';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_getStarted => 'Get Started';

  @override
  String get onboarding_slide1_title => 'Send Money Instantly';

  @override
  String get onboarding_slide1_description =>
      'Transfer USDC to anyone, anywhere in West Africa. Fast, secure, and with minimal fees.';

  @override
  String get onboarding_slide2_title => 'Pay Bills Easily';

  @override
  String get onboarding_slide2_description =>
      'Pay your utility bills, buy airtime, and manage all your payments in one place.';

  @override
  String get onboarding_slide3_title => 'Save for Goals';

  @override
  String get onboarding_slide3_description =>
      'Set savings goals and watch your money grow with USDC\'s stable value.';

  @override
  String get onboarding_phoneInput_title => 'Enter your phone number';

  @override
  String get onboarding_phoneInput_subtitle =>
      'We\'ll send you a code to verify your number';

  @override
  String get onboarding_phoneInput_label => 'Phone Number';

  @override
  String get onboarding_phoneInput_terms =>
      'I agree to the Terms of Service and Privacy Policy';

  @override
  String get onboarding_phoneInput_loginLink =>
      'Already have an account? Login';

  @override
  String get onboarding_otp_title => 'Verify your number';

  @override
  String onboarding_otp_subtitle(String dialCode, String phoneNumber) {
    return 'Enter the 6-digit code sent to $dialCode $phoneNumber';
  }

  @override
  String get onboarding_otp_resend => 'Resend Code';

  @override
  String onboarding_otp_resendIn(int seconds) {
    return 'Resend in ${seconds}s';
  }

  @override
  String get onboarding_otp_verifying => 'Verifying...';

  @override
  String get onboarding_pin_title => 'Create your PIN';

  @override
  String get onboarding_pin_confirmTitle => 'Confirm your PIN';

  @override
  String get onboarding_pin_enterPin => 'Enter your new 6-digit PIN';

  @override
  String get onboarding_pin_confirmPin => 'Re-enter your PIN to confirm';

  @override
  String get pin_error_mismatch => 'PINs don\'t match. Please try again.';

  @override
  String get onboarding_profile_title => 'Tell us about yourself';

  @override
  String get onboarding_profile_subtitle =>
      'This helps us personalize your experience';

  @override
  String get onboarding_profile_firstName => 'First Name';

  @override
  String get onboarding_profile_firstNameHint => 'e.g., Amadou';

  @override
  String get onboarding_profile_firstNameRequired => 'First name is required';

  @override
  String get onboarding_profile_lastName => 'Last Name';

  @override
  String get onboarding_profile_lastNameHint => 'e.g., Diallo';

  @override
  String get onboarding_profile_lastNameRequired => 'Last name is required';

  @override
  String get onboarding_profile_email => 'Email (Optional)';

  @override
  String get onboarding_profile_emailHint => 'e.g., amadou@example.com';

  @override
  String get onboarding_profile_emailInvalid =>
      'Please enter a valid email address';

  @override
  String get onboarding_kyc_title => 'Verify your identity';

  @override
  String get onboarding_kyc_subtitle => 'Unlock higher limits and all features';

  @override
  String get onboarding_kyc_benefit1 => 'Higher transaction limits';

  @override
  String get onboarding_kyc_benefit2 => 'Send to external wallets';

  @override
  String get onboarding_kyc_benefit3 => 'All features unlocked';

  @override
  String get onboarding_kyc_verify => 'Verify Now';

  @override
  String get onboarding_kyc_later => 'Maybe Later';

  @override
  String get onboarding_success_title => 'Welcome to JoonaPay!';

  @override
  String onboarding_success_subtitle(String name) {
    return 'Hi $name, you\'re all set!';
  }

  @override
  String get onboarding_success_walletCreated => 'Your Wallet is Ready';

  @override
  String get onboarding_success_walletMessage =>
      'Start sending, receiving, and managing your USDC today';

  @override
  String get onboarding_success_continue => 'Start Using JoonaPay';

  @override
  String get action_delete => 'Delete';

  @override
  String get savingsPots_title => 'Savings Pots';

  @override
  String get savingsPots_emptyTitle => 'Start saving for your goals';

  @override
  String get savingsPots_emptyMessage =>
      'Create pots to save money for specific goals like vacations, gadgets, or emergencies.';

  @override
  String get savingsPots_createFirst => 'Create Your First Pot';

  @override
  String get savingsPots_totalSaved => 'Total Saved';

  @override
  String get savingsPots_createTitle => 'Create Savings Pot';

  @override
  String get savingsPots_editTitle => 'Edit Pot';

  @override
  String get savingsPots_nameLabel => 'Pot Name';

  @override
  String get savingsPots_nameHint => 'e.g., Vacation, New Phone';

  @override
  String get savingsPots_nameRequired => 'Please enter a pot name';

  @override
  String get savingsPots_targetLabel => 'Target Amount (Optional)';

  @override
  String get savingsPots_targetHint => 'How much do you want to save?';

  @override
  String get savingsPots_targetOptional =>
      'Leave blank if you don\'t have a specific goal';

  @override
  String get savingsPots_emojiRequired => 'Please select an emoji';

  @override
  String get savingsPots_colorRequired => 'Please select a color';

  @override
  String get savingsPots_createButton => 'Create Pot';

  @override
  String get savingsPots_updateButton => 'Update Pot';

  @override
  String get savingsPots_createSuccess => 'Pot created successfully!';

  @override
  String get savingsPots_updateSuccess => 'Pot updated successfully!';

  @override
  String get savingsPots_addMoney => 'Add Money';

  @override
  String get savingsPots_withdraw => 'Withdraw';

  @override
  String get savingsPots_availableBalance => 'Available Balance';

  @override
  String get savingsPots_potBalance => 'Pot Balance';

  @override
  String get savingsPots_amount => 'Amount';

  @override
  String get savingsPots_quick10 => '10%';

  @override
  String get savingsPots_quick25 => '25%';

  @override
  String get savingsPots_quick50 => '50%';

  @override
  String get savingsPots_addButton => 'Add to Pot';

  @override
  String get savingsPots_withdrawButton => 'Withdraw';

  @override
  String get savingsPots_withdrawAll => 'Withdraw All';

  @override
  String get savingsPots_invalidAmount => 'Please enter a valid amount';

  @override
  String get savingsPots_insufficientBalance =>
      'Insufficient balance in your wallet';

  @override
  String get savingsPots_insufficientPotBalance =>
      'Insufficient balance in this pot';

  @override
  String get savingsPots_addSuccess => 'Money added successfully!';

  @override
  String get savingsPots_withdrawSuccess => 'Money withdrawn successfully!';

  @override
  String get savingsPots_transactionHistory => 'Transaction History';

  @override
  String get savingsPots_noTransactions => 'No transactions yet';

  @override
  String get savingsPots_deposit => 'Deposit';

  @override
  String get savingsPots_withdrawal => 'Withdrawal';

  @override
  String get savingsPots_goalReached => 'Goal Reached!';

  @override
  String get savingsPots_deleteTitle => 'Delete Pot?';

  @override
  String get savingsPots_deleteMessage =>
      'The money in this pot will be returned to your main balance. This action cannot be undone.';

  @override
  String get savingsPots_deleteSuccess => 'Pot deleted successfully';

  @override
  String get sendExternal_title => 'Send to External Wallet';

  @override
  String get sendExternal_info =>
      'Send USDC to any wallet address on Polygon or Ethereum networks';

  @override
  String get sendExternal_walletAddress => 'Wallet Address';

  @override
  String get sendExternal_addressHint => '0x1234...abcd';

  @override
  String get sendExternal_addressRequired => 'Wallet address is required';

  @override
  String get sendExternal_paste => 'Paste';

  @override
  String get sendExternal_scanQr => 'Scan QR';

  @override
  String get sendExternal_supportedNetworks => 'Supported Networks';

  @override
  String get sendExternal_polygonInfo => 'Fast (1-2 min), Low fee (~\$0.01)';

  @override
  String get sendExternal_ethereumInfo =>
      'Slower (5-10 min), Higher fee (~\$2-5)';

  @override
  String get sendExternal_enterAmount => 'Enter Amount';

  @override
  String get sendExternal_recipientAddress => 'Recipient Address';

  @override
  String get sendExternal_selectNetwork => 'Select Network';

  @override
  String get sendExternal_recommended => 'Recommended';

  @override
  String get sendExternal_fee => 'Fee';

  @override
  String get sendExternal_amount => 'Amount';

  @override
  String get sendExternal_networkFee => 'Network Fee';

  @override
  String get sendExternal_total => 'Total';

  @override
  String get sendExternal_confirmTransfer => 'Confirm Transfer';

  @override
  String get sendExternal_warningTitle => 'Important';

  @override
  String get sendExternal_warningMessage =>
      'External transfers cannot be reversed. Please verify the address carefully.';

  @override
  String get sendExternal_transferSummary => 'Transfer Summary';

  @override
  String get sendExternal_network => 'Network';

  @override
  String get sendExternal_totalDeducted => 'Total Deducted';

  @override
  String get sendExternal_estimatedTime => 'Estimated Time';

  @override
  String get sendExternal_confirmAndSend => 'Confirm and Send';

  @override
  String get sendExternal_addressCopied => 'Address copied to clipboard';

  @override
  String get sendExternal_transferSuccess => 'Transfer Successful';

  @override
  String get sendExternal_processingMessage =>
      'Your transaction is being processed on the blockchain';

  @override
  String get sendExternal_amountSent => 'Amount Sent';

  @override
  String get sendExternal_transactionDetails => 'Transaction Details';

  @override
  String get sendExternal_transactionHash => 'Transaction Hash';

  @override
  String get sendExternal_status => 'Status';

  @override
  String get sendExternal_viewOnExplorer => 'View on Block Explorer';

  @override
  String get sendExternal_shareDetails => 'Share Details';

  @override
  String get sendExternal_hashCopied => 'Transaction hash copied to clipboard';

  @override
  String get sendExternal_statusPending => 'Pending';

  @override
  String get sendExternal_statusCompleted => 'Completed';

  @override
  String get sendExternal_statusProcessing => 'Processing';

  @override
  String get billPayments_title => 'Pay Bills';

  @override
  String get billPayments_categories => 'Categories';

  @override
  String get billPayments_providers => 'Providers';

  @override
  String get billPayments_allProviders => 'All Providers';

  @override
  String get billPayments_searchProviders => 'Search providers...';

  @override
  String get billPayments_noProvidersFound => 'No Providers Found';

  @override
  String get billPayments_tryAdjustingSearch => 'Try adjusting your search';

  @override
  String get billPayments_history => 'Payment History';

  @override
  String get billPayments_category_electricity => 'Electricity';

  @override
  String get billPayments_category_water => 'Water';

  @override
  String get billPayments_category_airtime => 'Airtime';

  @override
  String get billPayments_category_internet => 'Internet';

  @override
  String get billPayments_category_tv => 'TV';

  @override
  String get billPayments_verifyAccount => 'Verify Account';

  @override
  String get billPayments_accountVerified => 'Account verified';

  @override
  String get billPayments_verificationFailed => 'Verification failed';

  @override
  String get billPayments_amount => 'Amount';

  @override
  String get billPayments_processingFee => 'Processing Fee';

  @override
  String get billPayments_totalAmount => 'Total';

  @override
  String get billPayments_paymentSuccessful => 'Payment Successful!';

  @override
  String get billPayments_paymentProcessing => 'Payment Processing';

  @override
  String get billPayments_billPaidSuccessfully =>
      'Your bill has been paid successfully';

  @override
  String get billPayments_paymentBeingProcessed =>
      'Your payment is being processed';

  @override
  String get billPayments_receiptNumber => 'Receipt Number';

  @override
  String get billPayments_provider => 'Provider';

  @override
  String get billPayments_account => 'Account';

  @override
  String get billPayments_customer => 'Customer';

  @override
  String get billPayments_totalPaid => 'Total Paid';

  @override
  String get billPayments_date => 'Date';

  @override
  String get billPayments_reference => 'Reference';

  @override
  String get billPayments_yourToken => 'Your Token';

  @override
  String get billPayments_shareReceipt => 'Share Receipt';

  @override
  String get billPayments_confirmPayment => 'Confirm Payment';

  @override
  String get billPayments_failedToLoadProviders => 'Failed to Load Providers';

  @override
  String get billPayments_failedToLoadReceipt => 'Failed to Load Receipt';

  @override
  String get billPayments_returnHome => 'Return Home';

  @override
  String get navigation_cards => 'Cards';

  @override
  String get navigation_history => 'History';

  @override
  String get cards_comingSoon => 'Coming Soon';

  @override
  String get cards_title => 'Virtual Cards';

  @override
  String get cards_description =>
      'Spend your USDC with virtual debit cards. Perfect for online shopping and subscriptions.';

  @override
  String get cards_feature1Title => 'Shop Online';

  @override
  String get cards_feature1Description =>
      'Use virtual cards for secure online purchases';

  @override
  String get cards_feature2Title => 'Stay Secure';

  @override
  String get cards_feature2Description =>
      'Freeze, unfreeze, or delete cards instantly';

  @override
  String get cards_feature3Title => 'Control Spending';

  @override
  String get cards_feature3Description =>
      'Set custom spending limits for each card';

  @override
  String get cards_notifyMe => 'Notify Me When Available';

  @override
  String get cards_notifyDialogTitle => 'Get Notified';

  @override
  String get cards_notifyDialogMessage =>
      'We\'ll send you a notification when virtual cards are available in your region.';

  @override
  String get cards_notifySuccess =>
      'You\'ll be notified when cards are available';

  @override
  String get insights_title => 'Insights';

  @override
  String get insights_period_week => 'Week';

  @override
  String get insights_period_month => 'Month';

  @override
  String get insights_period_year => 'Year';

  @override
  String get insights_summary => 'Summary';

  @override
  String get insights_total_spent => 'Total Spent';

  @override
  String get insights_total_received => 'Total Received';

  @override
  String get insights_net_flow => 'Net Flow';

  @override
  String get insights_categories => 'Categories';

  @override
  String get insights_spending_trend => 'Spending Trend';

  @override
  String get insights_top_recipients => 'Top Recipients';

  @override
  String get insights_empty_title => 'No Insights Yet';

  @override
  String get insights_empty_description =>
      'Start using JoonaPay to see your spending insights and analytics';

  @override
  String get insights_export_report => 'Export Report';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get contacts_search => 'Search contacts';

  @override
  String get contacts_on_joonapay => 'On JoonaPay';

  @override
  String get contacts_invite_to_joonapay => 'Invite to JoonaPay';

  @override
  String get contacts_empty => 'No contacts found. Pull down to refresh.';

  @override
  String get contacts_no_results => 'No contacts match your search';

  @override
  String contacts_sync_success(int count) {
    return 'Found $count JoonaPay users!';
  }

  @override
  String get contacts_synced_just_now => 'Just now';

  @override
  String contacts_synced_minutes_ago(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String contacts_synced_hours_ago(int hours) {
    return '${hours}h ago';
  }

  @override
  String contacts_synced_days_ago(int days) {
    return '${days}d ago';
  }

  @override
  String get contacts_permission_title => 'Find Your Friends';

  @override
  String get contacts_permission_subtitle =>
      'See which of your contacts are already on JoonaPay';

  @override
  String get contacts_permission_benefit1_title => 'Find Friends Instantly';

  @override
  String get contacts_permission_benefit1_desc =>
      'See which contacts are on JoonaPay and send money instantly';

  @override
  String get contacts_permission_benefit2_title => 'Private & Secure';

  @override
  String get contacts_permission_benefit2_desc =>
      'We never store your contacts. Phone numbers are hashed before syncing.';

  @override
  String get contacts_permission_benefit3_title => 'Always Up to Date';

  @override
  String get contacts_permission_benefit3_desc =>
      'Automatically sync when new contacts join JoonaPay';

  @override
  String get contacts_permission_allow => 'Allow Access';

  @override
  String get contacts_permission_later => 'Maybe Later';

  @override
  String get contacts_permission_denied_title => 'Permission Denied';

  @override
  String get contacts_permission_denied_message =>
      'To find your friends on JoonaPay, please allow contact access in Settings.';

  @override
  String contacts_invite_title(String name) {
    return 'Invite $name to JoonaPay';
  }

  @override
  String get contacts_invite_subtitle =>
      'Send money to friends instantly with JoonaPay';

  @override
  String get contacts_invite_via_sms => 'Send SMS Invite';

  @override
  String get contacts_invite_via_sms_desc =>
      'Send an SMS with your invite link';

  @override
  String get contacts_invite_via_whatsapp => 'Invite via WhatsApp';

  @override
  String get contacts_invite_via_whatsapp_desc =>
      'Share invite link on WhatsApp';

  @override
  String get contacts_invite_copy_link => 'Copy Invite Link';

  @override
  String get contacts_invite_copy_link_desc => 'Copy link to share anywhere';

  @override
  String get contacts_invite_message =>
      'Hey! I\'m using JoonaPay to send money instantly. Join me and get your first transfer free! Download: https://joonapay.com/app';

  @override
  String get recurringTransfers_title => 'Recurring Transfers';

  @override
  String get recurringTransfers_createNew => 'Create New';

  @override
  String get recurringTransfers_createTitle => 'Create Recurring Transfer';

  @override
  String get recurringTransfers_createFirst => 'Create Your First';

  @override
  String get recurringTransfers_emptyTitle => 'No Recurring Transfers';

  @override
  String get recurringTransfers_emptyMessage =>
      'Set up automatic transfers to send money regularly to your loved ones';

  @override
  String get recurringTransfers_active => 'Active Transfers';

  @override
  String get recurringTransfers_paused => 'Paused Transfers';

  @override
  String get recurringTransfers_upcoming => 'Upcoming This Week';

  @override
  String get recurringTransfers_amount => 'Amount';

  @override
  String get recurringTransfers_frequency => 'Frequency';

  @override
  String get recurringTransfers_nextExecution => 'Next';

  @override
  String get recurringTransfers_recipientSection => 'Recipient Details';

  @override
  String get recurringTransfers_amountSection => 'Transfer Amount';

  @override
  String get recurringTransfers_scheduleSection => 'Schedule';

  @override
  String get recurringTransfers_startDate => 'Start Date';

  @override
  String get recurringTransfers_endCondition => 'End Condition';

  @override
  String get recurringTransfers_neverEnd => 'Never (until cancelled)';

  @override
  String get recurringTransfers_afterOccurrences =>
      'After specific number of transfers';

  @override
  String get recurringTransfers_untilDate => 'Until specific date';

  @override
  String get recurringTransfers_occurrencesCount => 'Number of times';

  @override
  String get recurringTransfers_selectDate => 'Select Date';

  @override
  String get recurringTransfers_note => 'Note (Optional)';

  @override
  String get recurringTransfers_noteHint =>
      'e.g., Monthly rent, Weekly allowance';

  @override
  String get recurringTransfers_create => 'Create Recurring Transfer';

  @override
  String get recurringTransfers_createSuccess =>
      'Recurring transfer created successfully';

  @override
  String get recurringTransfers_createError =>
      'Failed to create recurring transfer';

  @override
  String get recurringTransfers_details => 'Transfer Details';

  @override
  String get recurringTransfers_schedule => 'Schedule';

  @override
  String get recurringTransfers_upcomingExecutions => 'Next Scheduled';

  @override
  String get recurringTransfers_statistics => 'Statistics';

  @override
  String get recurringTransfers_executed => 'Executed';

  @override
  String get recurringTransfers_remaining => 'Remaining';

  @override
  String get recurringTransfers_executionHistory => 'Execution History';

  @override
  String get recurringTransfers_executionSuccess => 'Completed successfully';

  @override
  String get recurringTransfers_executionFailed => 'Failed';

  @override
  String get recurringTransfers_pause => 'Pause Transfer';

  @override
  String get recurringTransfers_resume => 'Resume Transfer';

  @override
  String get recurringTransfers_cancel => 'Cancel Transfer';

  @override
  String get recurringTransfers_pauseSuccess => 'Transfer paused successfully';

  @override
  String get recurringTransfers_pauseError => 'Failed to pause transfer';

  @override
  String get recurringTransfers_resumeSuccess =>
      'Transfer resumed successfully';

  @override
  String get recurringTransfers_resumeError => 'Failed to resume transfer';

  @override
  String get recurringTransfers_cancelConfirmTitle =>
      'Cancel Recurring Transfer?';

  @override
  String get recurringTransfers_cancelConfirmMessage =>
      'This will permanently cancel this recurring transfer. This action cannot be undone.';

  @override
  String get recurringTransfers_confirmCancel => 'Yes, Cancel';

  @override
  String get recurringTransfers_cancelSuccess =>
      'Transfer cancelled successfully';

  @override
  String get recurringTransfers_cancelError => 'Failed to cancel transfer';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_invalidAmount => 'Please enter a valid amount';

  @override
  String get common_today => 'Today';

  @override
  String get common_tomorrow => 'Tomorrow';
}
