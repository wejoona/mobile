// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Korido';

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
  String get action_clear => 'Clear';

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
  String get auth_resendOtp => 'Resend Code';

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
  String get send_joonaPayUser => 'Korido user';

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
    return 'Send USDC to my Korido wallet:\n\n$address';
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
  String get transactions_fromKoridoUser => 'From Korido User';

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
  String get settings_selectTheme => 'Select Theme';

  @override
  String get settings_themeLight => 'Light';

  @override
  String get settings_themeDark => 'Dark';

  @override
  String get settings_themeSystem => 'System';

  @override
  String get settings_themeLightDescription => 'Bright and clean appearance';

  @override
  String get settings_themeDarkDescription => 'Easy on the eyes at night';

  @override
  String get settings_themeSystemDescription => 'Matches your device settings';

  @override
  String get settings_appearance => 'Appearance';

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
  String get kyc_personalInfo_title => 'Personal Information';

  @override
  String get kyc_personalInfo_subtitle =>
      'Enter your details exactly as they appear on your ID document';

  @override
  String get kyc_personalInfo_firstName => 'First name';

  @override
  String get kyc_personalInfo_firstNameRequired => 'First name is required';

  @override
  String get kyc_personalInfo_lastName => 'Last name';

  @override
  String get kyc_personalInfo_lastNameRequired => 'Last name is required';

  @override
  String get kyc_personalInfo_dateOfBirth => 'Date of birth';

  @override
  String get kyc_personalInfo_selectDate => 'Select date';

  @override
  String get kyc_personalInfo_dateRequired => 'Date of birth is required';

  @override
  String get kyc_personalInfo_matchIdHint =>
      'Your information must match exactly what appears on your ID document for verification to succeed';

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
  String get kyc_camera_unavailable => 'Camera Not Available';

  @override
  String get kyc_camera_unavailable_description =>
      'Your device camera is not accessible. You can select a photo from your gallery instead.';

  @override
  String get kyc_chooseFromGallery => 'Choose from Gallery';

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
  String get error_generic =>
      'We encountered an issue. Please try again in a moment.';

  @override
  String get error_network =>
      'Unable to connect. Please check your internet connection and try again.';

  @override
  String get error_failedToLoadBalance =>
      'Unable to load your balance. Pull down to refresh or try again later.';

  @override
  String get error_failedToLoadTransactions =>
      'Unable to load transactions. Pull down to refresh or try again later.';

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
  String get beneficiaries_typeJoonapay => 'Korido User';

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
  String get beneficiaries_accountDetails => 'Account Details';

  @override
  String get beneficiaries_statistics => 'Transfer Statistics';

  @override
  String get beneficiaries_totalTransfers => 'Total Transfers';

  @override
  String get beneficiaries_totalAmount => 'Total Amount';

  @override
  String get beneficiaries_lastTransfer => 'Last Transfer';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_logout => 'Logout';

  @override
  String get common_save => 'Save';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_verified => 'Verified';

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
      'Share this QR code with the sender. They can scan it with their Korido app to send you money instantly.';

  @override
  String get qr_savedToGallery => 'QR code saved to gallery';

  @override
  String get qr_failedToSave => 'Failed to save QR code';

  @override
  String get qr_initializingCamera => 'Initializing camera...';

  @override
  String get qr_scanInstruction => 'Scan a Korido QR code';

  @override
  String get qr_scanSubInstruction =>
      'Point your camera at a QR code to send money';

  @override
  String get qr_scanned => 'QR Code Scanned';

  @override
  String get qr_invalidCode => 'Invalid QR Code';

  @override
  String get qr_invalidCodeMessage =>
      'This QR code is not a valid Korido payment code.';

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
  String deposit_rateUpdated(String time, DateTime hora) {
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
  String deposit_expiresIn(String time) {
    return 'Expires in $time';
  }

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
  String get common_requiredField => 'This field is required';

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
  String get help_needHelp => 'Need Help?';

  @override
  String get transactionDetails_title => 'Transaction Details';

  @override
  String get transactionDetails_transactionId => 'Transaction ID';

  @override
  String get transactionDetails_date => 'Date';

  @override
  String get transactionDetails_currency => 'Currency';

  @override
  String get transactionDetails_recipientPhone => 'Recipient Phone';

  @override
  String get transactionDetails_recipientAddress => 'Recipient Address';

  @override
  String get transactionDetails_description => 'Description';

  @override
  String get transactionDetails_additionalDetails => 'Additional Details';

  @override
  String get transactionDetails_failureReason => 'Failure Reason';

  @override
  String get filters_title => 'Filter Transactions';

  @override
  String get filters_reset => 'Reset';

  @override
  String get filters_transactionType => 'Transaction Type';

  @override
  String get filters_status => 'Status';

  @override
  String get filters_dateRange => 'Date Range';

  @override
  String get filters_amountRange => 'Amount Range';

  @override
  String get filters_sortBy => 'Sort By';

  @override
  String get filters_from => 'From';

  @override
  String get filters_to => 'To';

  @override
  String get filters_clear => 'Clear';

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
  String get onboarding_success_title => 'Welcome to Korido!';

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
  String get onboarding_success_continue => 'Start Using Korido';

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
  String get savingsPots_chooseEmoji => 'Choose an emoji';

  @override
  String get savingsPots_chooseColor => 'Choose a color';

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
  String billPayments_payProvider(String providerName, Object providername) {
    return 'Pay $providerName';
  }

  @override
  String billPayments_enterField(String field) {
    return 'Enter $field';
  }

  @override
  String billPayments_pleaseEnterField(String field) {
    return 'Please enter $field';
  }

  @override
  String billPayments_fieldMustBeLength(String field, int length) {
    return '$field must be $length characters';
  }

  @override
  String get billPayments_meterNumber => 'Meter Number';

  @override
  String get billPayments_enterMeterNumber => 'Enter meter number';

  @override
  String get billPayments_pleaseEnterMeterNumber => 'Please enter meter number';

  @override
  String billPayments_outstanding(String amount, String currency) {
    return 'Outstanding: $amount $currency';
  }

  @override
  String get billPayments_pleaseEnterAmount => 'Please enter amount';

  @override
  String get billPayments_pleaseEnterValidAmount =>
      'Please enter a valid amount';

  @override
  String billPayments_minimumAmount(int amount, String currency) {
    return 'Minimum amount is $amount $currency';
  }

  @override
  String billPayments_maximumAmount(int amount, String currency) {
    return 'Maximum amount is $amount $currency';
  }

  @override
  String billPayments_minMaxRange(int min, int max, String currency) {
    return 'Min: $min - Max: $max $currency';
  }

  @override
  String billPayments_available(String amount, String currency) {
    return 'Available: $amount $currency';
  }

  @override
  String billPayments_payAmount(String amount, String currency) {
    return 'Pay $amount $currency';
  }

  @override
  String billPayments_enterPinToPay(String providerName, Object providername) {
    return 'Enter your PIN to pay $providerName';
  }

  @override
  String get billPayments_paymentFailed => 'Payment failed';

  @override
  String get billPayments_noProvidersAvailable =>
      'No providers available for this category';

  @override
  String get billPayments_feeNone => 'No fee';

  @override
  String billPayments_feePercentage(String percentage) {
    return '$percentage% fee';
  }

  @override
  String billPayments_feeFixed(int amount, String currency) {
    return '$amount $currency fee';
  }

  @override
  String get billPayments_statusCompleted => 'Completed';

  @override
  String get billPayments_statusPending => 'Pending';

  @override
  String get billPayments_statusProcessing => 'Processing';

  @override
  String get billPayments_statusFailed => 'Failed';

  @override
  String get billPayments_statusRefunded => 'Refunded';

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
  String get cards_featureDisabled => 'Virtual cards feature is not available';

  @override
  String get cards_noCards => 'No Cards Yet';

  @override
  String get cards_noCardsDescription =>
      'Request your first virtual card to start making online purchases';

  @override
  String get cards_requestCard => 'Request Card';

  @override
  String get cards_cardDetails => 'Card Details';

  @override
  String get cards_cardNotFound => 'Card not found';

  @override
  String get cards_cardInformation => 'Card Information';

  @override
  String get cards_cardNumber => 'Card Number';

  @override
  String get cards_cvv => 'CVV';

  @override
  String get cards_expiryDate => 'Expiry Date';

  @override
  String get cards_spendingLimit => 'Spending Limit';

  @override
  String get cards_spent => 'Spent';

  @override
  String get cards_limit => 'Limit';

  @override
  String get cards_viewTransactions => 'View Transactions';

  @override
  String get cards_freezeCard => 'Freeze Card';

  @override
  String get cards_unfreezeCard => 'Unfreeze Card';

  @override
  String get cards_freezeConfirmation =>
      'Are you sure you want to freeze this card? You can unfreeze it anytime.';

  @override
  String get cards_unfreezeConfirmation =>
      'Are you sure you want to unfreeze this card?';

  @override
  String get cards_cardFrozen => 'Card frozen successfully';

  @override
  String get cards_cardUnfrozen => 'Card unfrozen successfully';

  @override
  String get cards_copiedToClipboard => 'Copied to clipboard';

  @override
  String get cards_requestInfo =>
      'Your virtual card will be ready instantly after approval. Requires KYC Level 2.';

  @override
  String get cards_cardholderName => 'Cardholder Name';

  @override
  String get cards_cardholderNameHint => 'Enter name as it appears on card';

  @override
  String get cards_nameRequired => 'Cardholder name is required';

  @override
  String get cards_spendingLimitHint => 'Enter spending limit in USD';

  @override
  String get cards_limitRequired => 'Spending limit is required';

  @override
  String get cards_limitInvalid => 'Invalid spending limit';

  @override
  String get cards_limitTooLow => 'Minimum spending limit is \$10';

  @override
  String get cards_limitTooHigh => 'Maximum spending limit is \$10,000';

  @override
  String get cards_cardFeatures => 'Card Features';

  @override
  String get cards_featureOnlineShopping => 'Shop online worldwide';

  @override
  String get cards_featureSecure => 'Secure and encrypted';

  @override
  String get cards_featureFreeze => 'Freeze and unfreeze instantly';

  @override
  String get cards_featureAlerts => 'Real-time transaction alerts';

  @override
  String get cards_requestCardSubmit => 'Request Virtual Card';

  @override
  String get cards_kycRequired => 'KYC Verification Required';

  @override
  String get cards_kycRequiredDescription =>
      'You need to complete KYC Level 2 verification to request a virtual card.';

  @override
  String get cards_completeKYC => 'Complete KYC';

  @override
  String get cards_requestSuccess => 'Card requested successfully';

  @override
  String get cards_requestFailed => 'Failed to request card';

  @override
  String get cards_cardSettings => 'Card Settings';

  @override
  String get cards_cardStatus => 'Card Status';

  @override
  String get cards_statusActive => 'Active';

  @override
  String get cards_statusFrozen => 'Frozen';

  @override
  String get cards_statusActiveDescription =>
      'Your card is active and ready to use';

  @override
  String get cards_statusFrozenDescription =>
      'Your card is frozen and cannot be used';

  @override
  String get cards_currentLimit => 'Current Limit';

  @override
  String get cards_availableLimit => 'Available';

  @override
  String get cards_updateLimit => 'Update Limit';

  @override
  String get cards_newLimit => 'New Limit';

  @override
  String get cards_limitRange => 'Limit must be between \$10 and \$10,000';

  @override
  String get cards_limitUpdated => 'Spending limit updated successfully';

  @override
  String get cards_dangerZone => 'Danger Zone';

  @override
  String get cards_blockCard => 'Block Card';

  @override
  String get cards_blockCardDescription =>
      'Permanently block this card. This action cannot be undone.';

  @override
  String get cards_blockCardButton => 'Block Card Permanently';

  @override
  String get cards_blockCardConfirmation =>
      'Are you sure you want to permanently block this card? This action cannot be undone and you\'ll need to request a new card.';

  @override
  String get cards_cardBlocked => 'Card blocked successfully';

  @override
  String get cards_transactions => 'Card Transactions';

  @override
  String get cards_noTransactions => 'No Transactions';

  @override
  String get cards_noTransactionsDescription =>
      'You haven\'t made any purchases with this card yet';

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
      'Start using Korido to see your spending insights and analytics';

  @override
  String get insights_export_report => 'Export Report';

  @override
  String get insights_daily_spending => 'Daily Spending';

  @override
  String get insights_daily_average => 'Daily Avg';

  @override
  String get insights_highest_day => 'Highest';

  @override
  String get insights_income_vs_expenses => 'Income vs Expenses';

  @override
  String get insights_income => 'Income';

  @override
  String get insights_expenses => 'Expenses';

  @override
  String get contacts_title => 'Contacts';

  @override
  String get contacts_search => 'Search contacts';

  @override
  String get contacts_on_joonapay => 'On Korido';

  @override
  String get contacts_invite_to_joonapay => 'Invite to Korido';

  @override
  String get contacts_empty => 'No contacts found. Pull down to refresh.';

  @override
  String get contacts_no_results => 'No contacts match your search';

  @override
  String contacts_sync_success(int count) {
    return 'Found $count Korido users!';
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
      'See which of your contacts are already on Korido';

  @override
  String get contacts_permission_benefit1_title => 'Find Friends Instantly';

  @override
  String get contacts_permission_benefit1_desc =>
      'See which contacts are on Korido and send money instantly';

  @override
  String get contacts_permission_benefit2_title => 'Private & Secure';

  @override
  String get contacts_permission_benefit2_desc =>
      'We never store your contacts. Phone numbers are hashed before syncing.';

  @override
  String get contacts_permission_benefit3_title => 'Always Up to Date';

  @override
  String get contacts_permission_benefit3_desc =>
      'Automatically sync when new contacts join Korido';

  @override
  String get contacts_permission_allow => 'Allow Access';

  @override
  String get contacts_permission_later => 'Maybe Later';

  @override
  String get contacts_permission_denied_title => 'Permission Denied';

  @override
  String get contacts_permission_denied_message =>
      'To find your friends on Korido, please allow contact access in Settings.';

  @override
  String contacts_invite_title(String name) {
    return 'Invite $name to Korido';
  }

  @override
  String get contacts_invite_subtitle =>
      'Send money to friends instantly with Korido';

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
      'Hey! I\'m using Korido to send money instantly. Join me and get your first transfer free! Download: https://joonapay.com/app';

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

  @override
  String get limits_title => 'Transaction Limits';

  @override
  String get limits_dailyLimits => 'Daily Limits';

  @override
  String get limits_monthlyLimits => 'Monthly Limits';

  @override
  String get limits_dailyTransactions => 'Daily Transactions';

  @override
  String get limits_monthlyTransactions => 'Monthly Transactions';

  @override
  String get limits_remaining => 'remaining';

  @override
  String get limits_of => 'of';

  @override
  String get limits_upgradeTitle => 'Need higher limits?';

  @override
  String get limits_upgradeDescription =>
      'Verify your identity to unlock premium limits';

  @override
  String get limits_upgradeToTier => 'Upgrade to';

  @override
  String get limits_day => 'day';

  @override
  String get limits_month => 'month';

  @override
  String get limits_aboutTitle => 'About Limits';

  @override
  String get limits_aboutDescription =>
      'Limits reset at midnight UTC. Complete KYC verification to increase your limits.';

  @override
  String get limits_kycPrompt => 'Complete KYC for higher limits';

  @override
  String get limits_maxTier => 'You have the highest tier';

  @override
  String get limits_singleTransaction => 'Single Transaction';

  @override
  String get limits_withdrawal => 'Withdrawal Limit';

  @override
  String get limits_resetIn => 'Resets in';

  @override
  String get limits_hours => 'hours';

  @override
  String get limits_minutes => 'minutes';

  @override
  String get limits_otherLimits => 'Other Limits';

  @override
  String get limits_noData => 'No limit data available';

  @override
  String get limits_limitReached => 'Limit Reached';

  @override
  String get limits_dailyLimitReached =>
      'You have reached your daily transaction limit of';

  @override
  String get limits_monthlyLimitReached =>
      'You have reached your monthly transaction limit of';

  @override
  String get limits_upgradeToIncrease =>
      'Upgrade your account to increase limits';

  @override
  String get limits_approachingLimit => 'Approaching Limit';

  @override
  String get limits_remainingToday => 'remaining today';

  @override
  String get limits_remainingThisMonth => 'remaining this month';

  @override
  String get paymentLinks_title => 'Payment Links';

  @override
  String get paymentLinks_createLink => 'Create Payment Link';

  @override
  String get paymentLinks_createNew => 'Create New';

  @override
  String get paymentLinks_createDescription =>
      'Generate a shareable payment link to receive money from anyone';

  @override
  String get paymentLinks_amount => 'Amount';

  @override
  String get paymentLinks_description => 'Description';

  @override
  String get paymentLinks_descriptionHint =>
      'What is this payment for? (optional)';

  @override
  String get paymentLinks_expiresIn => 'Link expires in';

  @override
  String get paymentLinks_6hours => '6 hours';

  @override
  String get paymentLinks_24hours => '24 hours';

  @override
  String get paymentLinks_3days => '3 days';

  @override
  String get paymentLinks_7days => '7 days';

  @override
  String get paymentLinks_info =>
      'Anyone with this link can pay you. Link expires automatically.';

  @override
  String get paymentLinks_invalidAmount => 'Please enter a valid amount';

  @override
  String get paymentLinks_minimumAmount => 'Minimum amount is CFA 100';

  @override
  String get paymentLinks_linkCreated => 'Link Created';

  @override
  String get paymentLinks_linkReadyTitle => 'Your payment link is ready!';

  @override
  String get paymentLinks_linkReadyDescription =>
      'Share this link with anyone to receive payment';

  @override
  String get paymentLinks_requestedAmount => 'Requested Amount';

  @override
  String get paymentLinks_shareLink => 'Share Link';

  @override
  String get paymentLinks_viewDetails => 'View Details';

  @override
  String get paymentLinks_copyLink => 'Copy Link';

  @override
  String get paymentLinks_shareWhatsApp => 'Share on WhatsApp';

  @override
  String get paymentLinks_shareSMS => 'Share via SMS';

  @override
  String get paymentLinks_shareOther => 'Share Other Way';

  @override
  String get paymentLinks_linkCopied => 'Link copied to clipboard';

  @override
  String get paymentLinks_paymentRequest => 'Payment Request';

  @override
  String get paymentLinks_emptyTitle => 'No payment links yet';

  @override
  String get paymentLinks_emptyDescription =>
      'Create your first payment link to start receiving money easily';

  @override
  String get paymentLinks_createFirst => 'Create Your First Link';

  @override
  String get paymentLinks_activeLinks => 'Active Links';

  @override
  String get paymentLinks_paidLinks => 'Paid Links';

  @override
  String get paymentLinks_filterAll => 'All';

  @override
  String get paymentLinks_filterPending => 'Pending';

  @override
  String get paymentLinks_filterViewed => 'Viewed';

  @override
  String get paymentLinks_filterPaid => 'Paid';

  @override
  String get paymentLinks_filterExpired => 'Expired';

  @override
  String get paymentLinks_noLinksWithFilter => 'No links match this filter';

  @override
  String get paymentLinks_linkDetails => 'Link Details';

  @override
  String get paymentLinks_linkCode => 'Link Code';

  @override
  String get paymentLinks_linkUrl => 'Link URL';

  @override
  String get paymentLinks_viewCount => 'View Count';

  @override
  String get paymentLinks_created => 'Created';

  @override
  String get paymentLinks_expires => 'Expires';

  @override
  String get paymentLinks_paidBy => 'Paid By';

  @override
  String get paymentLinks_paidAt => 'Paid At';

  @override
  String get paymentLinks_cancelLink => 'Cancel Link';

  @override
  String get paymentLinks_cancelConfirmTitle => 'Cancel Link?';

  @override
  String get paymentLinks_cancelConfirmMessage =>
      'Are you sure you want to cancel this payment link? This action cannot be undone.';

  @override
  String get paymentLinks_linkCancelled => 'Payment link cancelled';

  @override
  String get paymentLinks_viewTransaction => 'View Transaction';

  @override
  String get paymentLinks_payTitle => 'Pay via Link';

  @override
  String get paymentLinks_payingTo => 'Paying to';

  @override
  String paymentLinks_payAmount(String amount) {
    return 'Pay $amount';
  }

  @override
  String get paymentLinks_paymentFor => 'Payment for';

  @override
  String get paymentLinks_linkExpiredTitle => 'Link Expired';

  @override
  String get paymentLinks_linkExpiredMessage =>
      'This payment link has expired and can no longer be used';

  @override
  String get paymentLinks_linkPaidTitle => 'Already Paid';

  @override
  String get paymentLinks_linkPaidMessage =>
      'This payment link has already been paid';

  @override
  String get paymentLinks_linkNotFoundTitle => 'Link Not Found';

  @override
  String get paymentLinks_linkNotFoundMessage =>
      'This payment link doesn\'t exist or has been cancelled';

  @override
  String get paymentLinks_paymentSuccess => 'Payment Successful';

  @override
  String get paymentLinks_paymentSuccessMessage =>
      'Your payment has been sent successfully';

  @override
  String get paymentLinks_insufficientBalance =>
      'Insufficient balance to complete this payment';

  @override
  String get common_done => 'Done';

  @override
  String get common_close => 'Close';

  @override
  String get common_unknown => 'Unknown';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get offline_youreOffline => 'You\'re offline';

  @override
  String offline_youreOfflineWithPending(int count) {
    return 'You\'re offline · $count pending';
  }

  @override
  String get offline_syncing => 'Syncing...';

  @override
  String get offline_pendingTransfer => 'Pending Transfer';

  @override
  String get offline_transferQueued => 'Transfer queued';

  @override
  String get offline_transferQueuedDesc =>
      'Your transfer will be sent when you\'re back online';

  @override
  String get offline_viewPending => 'View Pending';

  @override
  String get offline_retryFailed => 'Retry Failed';

  @override
  String get offline_cancelTransfer => 'Cancel Transfer';

  @override
  String get offline_noConnection => 'No internet connection';

  @override
  String get offline_checkConnection =>
      'Please check your internet connection and try again';

  @override
  String get offline_cacheData => 'Showing cached data';

  @override
  String offline_lastSynced(String time) {
    return 'Last synced: $time';
  }

  @override
  String get referrals_title => 'Refer & Earn';

  @override
  String get referrals_subtitle => 'Invite friends and earn rewards together';

  @override
  String get referrals_earnAmount => 'Earn \$5';

  @override
  String get referrals_earnDescription =>
      'for each friend who signs up and makes their first deposit';

  @override
  String get referrals_yourCode => 'Your Referral Code';

  @override
  String get referrals_shareLink => 'Share Link';

  @override
  String get referrals_invite => 'Invite';

  @override
  String get referrals_yourRewards => 'Your Rewards';

  @override
  String get referrals_friendsInvited => 'Friends Invited';

  @override
  String get referrals_totalEarned => 'Total Earned';

  @override
  String get referrals_howItWorks => 'How it works';

  @override
  String get referrals_step1Title => 'Share your code';

  @override
  String get referrals_step1Description =>
      'Send your referral code or link to friends';

  @override
  String get referrals_step2Title => 'Friend signs up';

  @override
  String get referrals_step2Description =>
      'They create an account using your code';

  @override
  String get referrals_step3Title => 'First deposit';

  @override
  String get referrals_step3Description =>
      'They make their first deposit of \$10 or more';

  @override
  String get referrals_step4Title => 'You both earn!';

  @override
  String get referrals_step4Description =>
      'You get \$5, and your friend gets \$5 too';

  @override
  String get referrals_history => 'Referral History';

  @override
  String get referrals_noReferrals => 'No referrals yet';

  @override
  String get referrals_startInviting =>
      'Start inviting friends to see your rewards here';

  @override
  String get referrals_codeCopied => 'Referral code copied!';

  @override
  String referrals_shareMessage(String code) {
    return 'Join Korido and get \$5 bonus on your first deposit! Use my referral code: $code\n\nDownload now: https://joonapay.com/download';
  }

  @override
  String get referrals_shareSubject => 'Join Korido - Get \$5 bonus!';

  @override
  String get referrals_inviteComingSoon => 'Contact invite coming soon';

  @override
  String get analytics_title => 'Analytics';

  @override
  String get analytics_income => 'Income';

  @override
  String get analytics_expenses => 'Expenses';

  @override
  String get analytics_netChange => 'Net Change';

  @override
  String get analytics_surplus => 'Surplus';

  @override
  String get analytics_deficit => 'Deficit';

  @override
  String get analytics_spendingByCategory => 'Spending by Category';

  @override
  String get analytics_categoryDetails => 'Category Details';

  @override
  String get analytics_transactionFrequency => 'Transaction Frequency';

  @override
  String get analytics_insights => 'Insights';

  @override
  String get analytics_period7Days => '7 Days';

  @override
  String get analytics_period30Days => '30 Days';

  @override
  String get analytics_period90Days => '90 Days';

  @override
  String get analytics_period1Year => '1 Year';

  @override
  String get analytics_categoryTransfers => 'Transfers';

  @override
  String get analytics_categoryWithdrawals => 'Withdrawals';

  @override
  String get analytics_categoryBills => 'Bills';

  @override
  String get analytics_categoryOther => 'Other';

  @override
  String analytics_transactions(int count) {
    return '$count transactions';
  }

  @override
  String get analytics_insightSpendingDown => 'Spending Down';

  @override
  String get analytics_insightSpendingDownDesc =>
      'Your spending is 5.2% lower than last month. Great job!';

  @override
  String get analytics_insightSavings => 'Savings Opportunity';

  @override
  String get analytics_insightSavingsDesc =>
      'You could save \$50/month by reducing withdrawal fees.';

  @override
  String get analytics_insightPeakActivity => 'Peak Activity';

  @override
  String get analytics_insightPeakActivityDesc =>
      'Most of your transactions happen on Thursdays.';

  @override
  String get analytics_exportingReport => 'Exporting report...';

  @override
  String get converter_title => 'Currency Converter';

  @override
  String get converter_from => 'From';

  @override
  String get converter_to => 'To';

  @override
  String get converter_selectCurrency => 'Select Currency';

  @override
  String get converter_rateInfo => 'Rate Information';

  @override
  String get converter_rateDisclaimer =>
      'Exchange rates are for informational purposes only and may differ from actual transaction rates. Rates are updated every hour.';

  @override
  String get converter_quickAmounts => 'Quick Amounts';

  @override
  String get converter_popularCurrencies => 'Popular Currencies';

  @override
  String get converter_perUsdc => 'per USDC';

  @override
  String get converter_ratesUpdated => 'Exchange rates updated';

  @override
  String get converter_updatedJustNow => 'Updated just now';

  @override
  String converter_exchangeRate(String from, String rate, String to) {
    return '1 $from = $rate $to';
  }

  @override
  String get currency_usd => 'US Dollar';

  @override
  String get currency_usdc => 'USD Coin';

  @override
  String get currency_eur => 'Euro';

  @override
  String get currency_gbp => 'British Pound';

  @override
  String get currency_xof => 'West African CFA Franc';

  @override
  String get currency_ngn => 'Nigerian Naira';

  @override
  String get currency_kes => 'Kenyan Shilling';

  @override
  String get currency_zar => 'South African Rand';

  @override
  String get currency_ghs => 'Ghanaian Cedi';

  @override
  String get settings_accountType => 'Account Type';

  @override
  String get settings_personalAccount => 'Personal';

  @override
  String get settings_businessAccount => 'Business';

  @override
  String get settings_selectAccountType => 'Select Account Type';

  @override
  String get settings_personalAccountDescription => 'For individual use';

  @override
  String get settings_businessAccountDescription => 'For business operations';

  @override
  String get settings_switchedToPersonal => 'Switched to Personal account';

  @override
  String get settings_switchedToBusiness => 'Switched to Business account';

  @override
  String get business_setupTitle => 'Business Setup';

  @override
  String get business_setupDescription =>
      'Set up your business profile to unlock business features';

  @override
  String get business_businessName => 'Business Name';

  @override
  String get business_registrationNumber => 'Registration Number';

  @override
  String get business_businessType => 'Business Type';

  @override
  String get business_businessAddress => 'Business Address';

  @override
  String get business_taxId => 'Tax ID';

  @override
  String get business_verificationNote =>
      'Your business will need to undergo verification (KYB) before you can access all business features.';

  @override
  String get business_completeSetup => 'Complete Setup';

  @override
  String get business_setupSuccess => 'Business profile created successfully';

  @override
  String get business_profileTitle => 'Business Profile';

  @override
  String get business_noProfile => 'No business profile found';

  @override
  String get business_setupNow => 'Set Up Business Profile';

  @override
  String get business_verified => 'Business Verified';

  @override
  String get business_verifiedDescription =>
      'Your business has been successfully verified';

  @override
  String get business_verificationPending => 'Verification Pending';

  @override
  String get business_verificationPendingDescription =>
      'Your business verification is under review';

  @override
  String get business_information => 'Business Information';

  @override
  String get business_completeVerification => 'Complete Business Verification';

  @override
  String get business_kybDescription =>
      'Verify your business to unlock all features';

  @override
  String get business_kybTitle => 'Business Verification (KYB)';

  @override
  String get business_kybInfo =>
      'Business verification allows you to:\n\n• Accept higher transaction limits\n• Access advanced reporting\n• Enable merchant features\n• Build trust with customers\n\nVerification typically takes 2-3 business days.';

  @override
  String get action_close => 'Close';

  @override
  String get subBusiness_title => 'Sub-Businesses';

  @override
  String get subBusiness_emptyTitle => 'No Sub-Businesses Yet';

  @override
  String get subBusiness_emptyMessage =>
      'Create departments, branches, or teams to organize your business operations.';

  @override
  String get subBusiness_createFirst => 'Create First Sub-Business';

  @override
  String get subBusiness_totalBalance => 'Total Balance';

  @override
  String get subBusiness_unit => 'unit';

  @override
  String get subBusiness_units => 'units';

  @override
  String get subBusiness_listTitle => 'All Sub-Businesses';

  @override
  String get subBusiness_createTitle => 'Create Sub-Business';

  @override
  String get subBusiness_nameLabel => 'Name';

  @override
  String get subBusiness_descriptionLabel => 'Description (Optional)';

  @override
  String get subBusiness_typeLabel => 'Type';

  @override
  String get subBusiness_typeDepartment => 'Department';

  @override
  String get subBusiness_typeBranch => 'Branch';

  @override
  String get subBusiness_typeSubsidiary => 'Subsidiary';

  @override
  String get subBusiness_typeTeam => 'Team';

  @override
  String get subBusiness_createInfo =>
      'Each sub-business will have its own wallet for tracking income and expenses separately.';

  @override
  String get subBusiness_createButton => 'Create Sub-Business';

  @override
  String get subBusiness_createSuccess => 'Sub-business created successfully';

  @override
  String get subBusiness_balance => 'Balance';

  @override
  String get subBusiness_transfer => 'Transfer';

  @override
  String get subBusiness_transactions => 'Transactions';

  @override
  String get subBusiness_information => 'Information';

  @override
  String get subBusiness_type => 'Type';

  @override
  String get subBusiness_description => 'Description';

  @override
  String get subBusiness_created => 'Created';

  @override
  String get subBusiness_staff => 'Staff';

  @override
  String get subBusiness_manageStaff => 'Manage Staff';

  @override
  String get subBusiness_noStaff =>
      'No staff members yet. Add team members to give them access to this sub-business.';

  @override
  String get subBusiness_addFirstStaff => 'Add Staff Member';

  @override
  String get subBusiness_viewAllStaff => 'View All Staff';

  @override
  String get subBusiness_staffTitle => 'Staff Management';

  @override
  String get subBusiness_noStaffTitle => 'No Staff Members';

  @override
  String get subBusiness_noStaffMessage =>
      'Invite team members to collaborate on this sub-business.';

  @override
  String get subBusiness_staffInfo =>
      'Staff members can view and manage this sub-business based on their assigned role.';

  @override
  String get subBusiness_member => 'member';

  @override
  String get subBusiness_members => 'members';

  @override
  String get subBusiness_addStaffTitle => 'Add Staff Member';

  @override
  String get subBusiness_phoneLabel => 'Phone Number';

  @override
  String get subBusiness_roleLabel => 'Role';

  @override
  String get subBusiness_roleOwner => 'Owner';

  @override
  String get subBusiness_roleAdmin => 'Admin';

  @override
  String get subBusiness_roleViewer => 'Viewer';

  @override
  String get subBusiness_roleOwnerDesc => 'Full access to manage everything';

  @override
  String get subBusiness_roleAdminDesc => 'Can manage and transfer funds';

  @override
  String get subBusiness_roleViewerDesc => 'Can only view transactions';

  @override
  String get subBusiness_inviteButton => 'Invite';

  @override
  String get subBusiness_inviteSuccess => 'Staff member invited successfully';

  @override
  String get subBusiness_changeRole => 'Change Role';

  @override
  String get subBusiness_removeStaff => 'Remove Staff';

  @override
  String get subBusiness_changeRoleTitle => 'Change Role';

  @override
  String get subBusiness_roleUpdateSuccess => 'Role updated successfully';

  @override
  String get subBusiness_removeStaffTitle => 'Remove Staff Member';

  @override
  String get subBusiness_removeStaffConfirm =>
      'Are you sure you want to remove this staff member? They will lose access to this sub-business.';

  @override
  String get subBusiness_removeButton => 'Remove';

  @override
  String get subBusiness_removeSuccess => 'Staff member removed successfully';

  @override
  String get bulkPayments_title => 'Bulk Payments';

  @override
  String get bulkPayments_uploadCsv => 'Upload CSV File';

  @override
  String get bulkPayments_emptyTitle => 'No bulk payments yet';

  @override
  String get bulkPayments_emptyDescription =>
      'Upload a CSV file to send payments to multiple recipients at once';

  @override
  String get bulkPayments_active => 'Active Batches';

  @override
  String get bulkPayments_completed => 'Completed';

  @override
  String get bulkPayments_failed => 'Failed';

  @override
  String get bulkPayments_uploadTitle => 'Upload Bulk Payments';

  @override
  String get bulkPayments_instructions => 'Instructions';

  @override
  String get bulkPayments_instructionsDescription =>
      'Upload a CSV file containing phone numbers, amounts, and descriptions for multiple payments';

  @override
  String get bulkPayments_uploadFile => 'Upload File';

  @override
  String get bulkPayments_selectFile => 'Tap to select CSV file';

  @override
  String get bulkPayments_csvOnly => 'CSV files only';

  @override
  String get bulkPayments_csvFormat => 'CSV Format';

  @override
  String get bulkPayments_phoneFormat =>
      'Phone: International format (+225...)';

  @override
  String get bulkPayments_amountFormat => 'Amount: Numeric value (50.00)';

  @override
  String get bulkPayments_descriptionFormat => 'Description: Required text';

  @override
  String get bulkPayments_example => 'Example';

  @override
  String get bulkPayments_preview => 'Preview Payments';

  @override
  String get bulkPayments_totalPayments => 'Total Payments';

  @override
  String get bulkPayments_totalAmount => 'Total Amount';

  @override
  String bulkPayments_errorsFound(int count) {
    return '$count errors found';
  }

  @override
  String get bulkPayments_fixErrors => 'Please fix errors before submitting';

  @override
  String get bulkPayments_showInvalidOnly => 'Show invalid only';

  @override
  String get bulkPayments_noPayments => 'No payments to display';

  @override
  String get bulkPayments_submitBatch => 'Submit Batch';

  @override
  String get bulkPayments_confirmSubmit => 'Confirm Batch Submission';

  @override
  String bulkPayments_confirmMessage(int count, String amount) {
    return 'Send $count payments totaling $amount?';
  }

  @override
  String get bulkPayments_submitSuccess => 'Batch submitted successfully';

  @override
  String get bulkPayments_batchStatus => 'Batch Status';

  @override
  String get bulkPayments_progress => 'Progress';

  @override
  String get bulkPayments_successful => 'Successful';

  @override
  String get bulkPayments_pending => 'Pending';

  @override
  String get bulkPayments_details => 'Details';

  @override
  String get bulkPayments_createdAt => 'Created';

  @override
  String get bulkPayments_processedAt => 'Processed';

  @override
  String get bulkPayments_failedPayments => 'Failed Payments';

  @override
  String get bulkPayments_failedDescription =>
      'Download a report of failed payments to retry';

  @override
  String get bulkPayments_downloadReport => 'Download Report';

  @override
  String get bulkPayments_failedReportTitle => 'Failed Payments Report';

  @override
  String get bulkPayments_downloadFailed => 'Failed to download report';

  @override
  String get bulkPayments_statusDraft => 'Draft';

  @override
  String get bulkPayments_statusPending => 'Pending';

  @override
  String get bulkPayments_statusProcessing => 'Processing';

  @override
  String get bulkPayments_statusCompleted => 'Completed';

  @override
  String get bulkPayments_statusPartial => 'Partially Completed';

  @override
  String get bulkPayments_statusFailed => 'Failed';

  @override
  String get expenses_title => 'Expenses';

  @override
  String get expenses_emptyTitle => 'No Expenses Yet';

  @override
  String get expenses_emptyMessage =>
      'Start tracking your expenses by capturing receipts or adding them manually';

  @override
  String get expenses_captureReceipt => 'Capture Receipt';

  @override
  String get expenses_addManually => 'Add Manually';

  @override
  String get expenses_addExpense => 'Add Expense';

  @override
  String get expenses_totalExpenses => 'Total Expenses';

  @override
  String get expenses_items => 'items';

  @override
  String get expenses_category => 'Category';

  @override
  String get expenses_amount => 'Amount';

  @override
  String get expenses_vendor => 'Vendor';

  @override
  String get expenses_date => 'Date';

  @override
  String get expenses_time => 'Time';

  @override
  String get expenses_description => 'Description';

  @override
  String get expenses_categoryTravel => 'Travel';

  @override
  String get expenses_categoryMeals => 'Meals';

  @override
  String get expenses_categoryOffice => 'Office';

  @override
  String get expenses_categoryTransport => 'Transport';

  @override
  String get expenses_categoryOther => 'Other';

  @override
  String get expenses_errorAmountRequired => 'Amount is required';

  @override
  String get expenses_errorInvalidAmount => 'Invalid amount';

  @override
  String get expenses_addedSuccessfully => 'Expense added successfully';

  @override
  String get expenses_positionReceipt =>
      'Position the receipt within the frame';

  @override
  String get expenses_receiptPreview => 'Receipt Preview';

  @override
  String get expenses_processingReceipt => 'Processing receipt...';

  @override
  String get expenses_extractedData => 'Extracted Data';

  @override
  String get expenses_confirmAndEdit => 'Confirm & Edit';

  @override
  String get expenses_retake => 'Retake Photo';

  @override
  String get expenses_confirmDetails => 'Confirm Details';

  @override
  String get expenses_saveExpense => 'Save Expense';

  @override
  String get expenses_expenseDetails => 'Expense Details';

  @override
  String get expenses_details => 'Details';

  @override
  String get expenses_linkedTransaction => 'Linked Transaction';

  @override
  String get expenses_deleteExpense => 'Delete Expense';

  @override
  String get expenses_deleteConfirmation =>
      'Are you sure you want to delete this expense?';

  @override
  String get expenses_deletedSuccessfully => 'Expense deleted successfully';

  @override
  String get expenses_reports => 'Expense Reports';

  @override
  String get expenses_viewReports => 'View Reports';

  @override
  String get expenses_reportPeriod => 'Report Period';

  @override
  String get expenses_startDate => 'Start Date';

  @override
  String get expenses_endDate => 'End Date';

  @override
  String get expenses_reportSummary => 'Summary';

  @override
  String get expenses_averageExpense => 'Average Expense';

  @override
  String get expenses_byCategory => 'By Category';

  @override
  String get expenses_exportPdf => 'Export as PDF';

  @override
  String get expenses_exportCsv => 'Export as CSV';

  @override
  String get expenses_reportGenerated => 'Report generated successfully';

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_markAllRead => 'Mark all read';

  @override
  String get notifications_emptyTitle => 'No Notifications';

  @override
  String get notifications_emptyMessage => 'You\'re all caught up!';

  @override
  String get notifications_errorTitle => 'Failed to Load';

  @override
  String get notifications_errorGeneric => 'An error occurred';

  @override
  String get notifications_timeJustNow => 'Just now';

  @override
  String notifications_timeMinutesAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}m ago';
  }

  @override
  String notifications_timeHoursAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}h ago';
  }

  @override
  String notifications_timeDaysAgo(int count) {
    final intl.NumberFormat countNumberFormat = intl.NumberFormat.compact(
      locale: localeName,
    );
    final String countString = countNumberFormat.format(count);

    return '${countString}d ago';
  }

  @override
  String get security_title => 'Security';

  @override
  String get security_authentication => 'Authentication';

  @override
  String get security_changePin => 'Change PIN';

  @override
  String get security_changePinSubtitle => 'Update your 4-digit PIN';

  @override
  String get security_biometricLogin => 'Biometric Login';

  @override
  String get security_biometricSubtitle => 'Use Face ID or fingerprint';

  @override
  String get security_biometricNotAvailable => 'Not available on this device';

  @override
  String get security_biometricUnavailableMessage =>
      'Biometric authentication is not available on this device';

  @override
  String get security_biometricVerifyReason =>
      'Verify to enable biometric login';

  @override
  String get security_loading => 'Loading...';

  @override
  String get security_checkingAvailability => 'Checking availability...';

  @override
  String get security_errorLoadingState => 'Error loading state';

  @override
  String get security_errorCheckingAvailability =>
      'Error checking availability';

  @override
  String get security_twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get security_twoFactorEnabledSubtitle =>
      'Enabled via Authenticator app';

  @override
  String get security_twoFactorDisabledSubtitle => 'Add extra protection';

  @override
  String get security_transactionSecurity => 'Transaction Security';

  @override
  String get security_requirePinForTransactions =>
      'Require PIN for Transactions';

  @override
  String get security_requirePinSubtitle => 'Confirm all transactions with PIN';

  @override
  String get security_alerts => 'Security Alerts';

  @override
  String get security_loginNotifications => 'Login Notifications';

  @override
  String get security_loginNotificationsSubtitle =>
      'Get notified of new logins';

  @override
  String get security_newDeviceAlerts => 'New Device Alerts';

  @override
  String get security_newDeviceAlertsSubtitle =>
      'Alert when a new device is used';

  @override
  String get security_sessions => 'Sessions';

  @override
  String get security_devices => 'Devices';

  @override
  String get security_devicesSubtitle => 'Manage your devices';

  @override
  String get security_activeSessions => 'Active Sessions';

  @override
  String get security_activeSessionsSubtitle => 'Manage your active sessions';

  @override
  String get security_logoutAllDevices => 'Log Out All Devices';

  @override
  String get security_logoutAllDevicesSubtitle =>
      'Sign out from all other devices';

  @override
  String get security_privacy => 'Privacy';

  @override
  String get security_loginHistory => 'Login History';

  @override
  String get security_loginHistorySubtitle => 'View recent login activity';

  @override
  String get security_deleteAccount => 'Delete Account';

  @override
  String get security_deleteAccountSubtitle =>
      'Permanently delete your account';

  @override
  String get security_scoreTitle => 'Security Score';

  @override
  String get security_scoreExcellent =>
      'Excellent! Your account is well protected.';

  @override
  String get security_scoreGood =>
      'Good security. A few improvements possible.';

  @override
  String get security_scoreModerate =>
      'Moderate security. Enable more features.';

  @override
  String get security_scoreLow =>
      'Low security. Please enable protection features.';

  @override
  String get security_tipEnable2FA =>
      'Enable 2FA to increase your score by 25 points';

  @override
  String get security_tipEnableBiometrics =>
      'Enable biometrics for easier secure login';

  @override
  String get security_tipRequirePin =>
      'Require PIN for transactions for extra safety';

  @override
  String get security_tipEnableNotifications =>
      'Enable all notifications for maximum security';

  @override
  String get security_setup2FATitle => 'Set Up Two-Factor Authentication';

  @override
  String get security_setup2FAMessage =>
      'Use an authenticator app like Google Authenticator or Authy for enhanced security.';

  @override
  String get security_continueSetup => 'Continue Setup';

  @override
  String get security_2FAEnabledSuccess => '2FA enabled successfully';

  @override
  String get security_disable2FATitle => 'Disable 2FA?';

  @override
  String get security_disable2FAMessage =>
      'This will make your account less secure. Are you sure?';

  @override
  String get security_disable => 'Disable';

  @override
  String get security_logoutAllTitle => 'Log Out All Devices?';

  @override
  String get security_logoutAllMessage =>
      'You will be logged out from all other devices. You will need to log in again on those devices.';

  @override
  String get security_logoutAll => 'Log Out All';

  @override
  String get security_logoutAllSuccess =>
      'All other devices have been logged out';

  @override
  String get security_loginHistoryTitle => 'Login History';

  @override
  String get security_loginSuccess => 'Success';

  @override
  String get security_loginFailed => 'Failed';

  @override
  String get security_deleteAccountTitle => 'Delete Account?';

  @override
  String get security_deleteAccountMessage =>
      'This action is permanent and cannot be undone. All your data, transaction history, and funds will be lost.';

  @override
  String get security_delete => 'Delete';

  @override
  String get biometric_enrollment_title => 'Secure Your Account';

  @override
  String get biometric_enrollment_subtitle =>
      'Add an extra layer of security with biometric authentication';

  @override
  String get biometric_enrollment_enable => 'Enable Biometric Authentication';

  @override
  String get biometric_enrollment_skip => 'Skip for Now';

  @override
  String get biometric_enrollment_benefit_fast_title => 'Fast Access';

  @override
  String get biometric_enrollment_benefit_fast_desc =>
      'Unlock your wallet instantly without entering PIN';

  @override
  String get biometric_enrollment_benefit_secure_title => 'Enhanced Security';

  @override
  String get biometric_enrollment_benefit_secure_desc =>
      'Your unique biometrics provide an additional security layer';

  @override
  String get biometric_enrollment_benefit_convenient_title =>
      'Convenient Authentication';

  @override
  String get biometric_enrollment_benefit_convenient_desc =>
      'Quickly verify transactions and sensitive actions';

  @override
  String get biometric_enrollment_authenticate_reason =>
      'Authenticate to enable biometric login';

  @override
  String get biometric_enrollment_success_title => 'Biometric Enabled!';

  @override
  String get biometric_enrollment_success_message =>
      'You can now use biometric authentication to access your wallet';

  @override
  String get biometric_enrollment_error_not_available =>
      'Biometric authentication is not available on this device';

  @override
  String get biometric_enrollment_error_failed =>
      'Biometric authentication failed. Please try again';

  @override
  String get biometric_enrollment_error_generic =>
      'Failed to enable biometric authentication';

  @override
  String get biometric_enrollment_skip_confirm_title => 'Skip Biometric Setup?';

  @override
  String get biometric_enrollment_skip_confirm_message =>
      'You can enable biometric authentication later in Settings';

  @override
  String get biometric_settings_title => 'Biometric Settings';

  @override
  String get biometric_settings_authentication => 'Authentication';

  @override
  String get biometric_settings_use_cases => 'Use Biometric For';

  @override
  String get biometric_settings_advanced => 'Advanced';

  @override
  String get biometric_settings_actions => 'Actions';

  @override
  String get biometric_settings_status_enabled => 'Enabled';

  @override
  String get biometric_settings_status_disabled => 'Disabled';

  @override
  String get biometric_settings_active => 'Active';

  @override
  String get biometric_settings_inactive => 'Inactive';

  @override
  String get biometric_settings_unavailable => 'Unavailable';

  @override
  String get biometric_settings_enabled_subtitle =>
      'Biometric authentication is active';

  @override
  String get biometric_settings_disabled_subtitle =>
      'Enable to use biometric authentication';

  @override
  String get biometric_settings_app_unlock_title => 'App Unlock';

  @override
  String get biometric_settings_app_unlock_subtitle =>
      'Use biometric to unlock the app';

  @override
  String get biometric_settings_transactions_title =>
      'Transaction Confirmation';

  @override
  String get biometric_settings_transactions_subtitle =>
      'Verify transactions with biometric';

  @override
  String get biometric_settings_sensitive_title => 'Sensitive Settings';

  @override
  String get biometric_settings_sensitive_subtitle =>
      'Protect PIN change and security settings';

  @override
  String get biometric_settings_view_balance_title => 'View Balance';

  @override
  String get biometric_settings_view_balance_subtitle =>
      'Require biometric to see wallet balance';

  @override
  String get biometric_settings_timeout_title => 'Biometric Timeout';

  @override
  String get biometric_settings_timeout_immediate =>
      'Immediate (Always required)';

  @override
  String get biometric_settings_timeout_5min => '5 minutes';

  @override
  String get biometric_settings_timeout_15min => '15 minutes';

  @override
  String get biometric_settings_timeout_30min => '30 minutes';

  @override
  String biometric_settings_timeout_custom(String minutes) {
    return '$minutes minutes';
  }

  @override
  String get biometric_settings_timeout_select_title => 'Select Timeout';

  @override
  String get biometric_settings_high_value_title => 'High-Value Threshold';

  @override
  String biometric_settings_high_value_subtitle(String amount) {
    return 'Require biometric + PIN for transfers over \$$amount';
  }

  @override
  String get biometric_settings_threshold_select_title => 'Select Threshold';

  @override
  String get biometric_settings_reenroll_title => 'Re-enroll Biometric';

  @override
  String get biometric_settings_reenroll_subtitle =>
      'Update your biometric authentication';

  @override
  String get biometric_settings_reenroll_confirm_title =>
      'Re-enroll Biometric?';

  @override
  String get biometric_settings_reenroll_confirm_message =>
      'Your current biometric setup will be removed and you\'ll need to set it up again';

  @override
  String get biometric_settings_fallback_title => 'Manage PIN';

  @override
  String get biometric_settings_fallback_subtitle =>
      'PIN is always available as fallback';

  @override
  String get biometric_settings_disable_title => 'Disable Biometric?';

  @override
  String get biometric_settings_disable_message =>
      'You\'ll need to use your PIN to authenticate instead';

  @override
  String get biometric_settings_disable => 'Disable';

  @override
  String get biometric_settings_error_loading =>
      'Failed to load biometric settings';

  @override
  String get biometric_type_face_id => 'Face ID';

  @override
  String get biometric_type_fingerprint => 'Fingerprint';

  @override
  String get biometric_type_iris => 'Iris';

  @override
  String get biometric_type_none => 'None';

  @override
  String get biometric_error_lockout =>
      'Biometric authentication is temporarily locked. Please try again later';

  @override
  String get biometric_error_not_enrolled =>
      'No biometrics enrolled on this device. Please add biometrics in device settings';

  @override
  String get biometric_error_hardware_unavailable =>
      'Biometric hardware is not available';

  @override
  String get biometric_change_detected_title => 'Biometric Change Detected';

  @override
  String get biometric_change_detected_message =>
      'Device biometric enrollment has changed. For security, biometric authentication has been disabled. Please re-enroll if you want to continue using it';

  @override
  String get profile_title => 'Profile';

  @override
  String get profile_kycStatus => 'KYC Status';

  @override
  String get profile_country => 'Country';

  @override
  String get profile_notSet => 'Not set';

  @override
  String get profile_verify => 'Verify';

  @override
  String get profile_kycNotVerified => 'Not Verified';

  @override
  String get profile_kycPending => 'Pending Review';

  @override
  String get profile_kycVerified => 'Verified';

  @override
  String get profile_kycRejected => 'Rejected';

  @override
  String get profile_countryIvoryCoast => 'Ivory Coast';

  @override
  String get profile_countryNigeria => 'Nigeria';

  @override
  String get profile_countryKenya => 'Kenya';

  @override
  String get profile_countryGhana => 'Ghana';

  @override
  String get profile_countrySenegal => 'Senegal';

  @override
  String get changePin_title => 'Change PIN';

  @override
  String get changePin_newPinTitle => 'New PIN';

  @override
  String get changePin_confirmTitle => 'Confirm PIN';

  @override
  String get changePin_enterCurrentPinTitle => 'Enter Current PIN';

  @override
  String get changePin_enterCurrentPinSubtitle =>
      'Enter your current 4-digit PIN to continue';

  @override
  String get changePin_createNewPinTitle => 'Create New PIN';

  @override
  String get changePin_createNewPinSubtitle =>
      'Choose a new 4-digit PIN for your account';

  @override
  String get changePin_confirmPinTitle => 'Confirm Your PIN';

  @override
  String get changePin_confirmPinSubtitle => 'Re-enter your new PIN to confirm';

  @override
  String get changePin_errorBiometricRequired =>
      'Biometric confirmation required';

  @override
  String get changePin_errorIncorrectPin => 'Incorrect PIN. Please try again.';

  @override
  String get changePin_errorUnableToVerify =>
      'Unable to verify PIN. Please try again.';

  @override
  String get changePin_errorWeakPin =>
      'PIN is too simple. Choose a stronger PIN.';

  @override
  String get changePin_errorSameAsCurrentPin =>
      'New PIN must be different from current PIN.';

  @override
  String get changePin_errorPinMismatch => 'PINs do not match. Try again.';

  @override
  String get changePin_successMessage => 'PIN changed successfully!';

  @override
  String get changePin_errorFailedToSet =>
      'Failed to set new PIN. Please try a different PIN.';

  @override
  String get changePin_errorFailedToSave =>
      'Failed to save PIN. Please try again.';

  @override
  String get notifications_email => 'Email Notifications';

  @override
  String get notifications_emailReceipts => 'Email Receipts';

  @override
  String get notifications_emailReceiptsDescription =>
      'Receive transaction receipts by email';

  @override
  String get notifications_loadError => 'Failed to load notification settings';

  @override
  String get notifications_marketing => 'Marketing';

  @override
  String get notifications_marketingDescription =>
      'Promotional offers and updates';

  @override
  String get notifications_monthlyStatement => 'Monthly Statement';

  @override
  String get notifications_monthlyStatementDescription =>
      'Receive monthly account statement';

  @override
  String get notifications_newsletter => 'Newsletter';

  @override
  String get notifications_newsletterDescription => 'Product news and updates';

  @override
  String get notifications_push => 'Push Notifications';

  @override
  String get notifications_required => 'Required';

  @override
  String get notifications_saveError => 'Failed to save preferences';

  @override
  String get notifications_savePreferences => 'Save Preferences';

  @override
  String get notifications_saveSuccess => 'Preferences saved successfully';

  @override
  String get notifications_security => 'Security Alerts';

  @override
  String get notifications_securityCodes => 'Security Codes';

  @override
  String get notifications_securityCodesDescription =>
      'Receive login and verification codes';

  @override
  String get notifications_securityDescription =>
      'Account security notifications';

  @override
  String get notifications_securityNote =>
      'Security notifications cannot be disabled';

  @override
  String get notifications_sms => 'SMS Notifications';

  @override
  String get notifications_smsTransactions => 'Transaction Alerts';

  @override
  String get notifications_smsTransactionsDescription =>
      'Receive SMS for transactions';

  @override
  String get notifications_transactions => 'Transactions';

  @override
  String get notifications_transactionsDescription =>
      'Receive notifications for transfers and payments';

  @override
  String get notifications_unsavedChanges => 'Unsaved Changes';

  @override
  String get notifications_unsavedChangesMessage =>
      'You have unsaved changes. Discard them?';

  @override
  String get help_callUs => 'Call Us';

  @override
  String get help_emailUs => 'Email Us';

  @override
  String get help_getHelp => 'Get Help';

  @override
  String get help_results => 'Results';

  @override
  String get help_searchPlaceholder => 'Search help articles...';

  @override
  String get action_discard => 'Discard';

  @override
  String get common_comingSoon => 'Coming Soon';

  @override
  String get common_maybeLater => 'Maybe Later';

  @override
  String get common_optional => 'Optional';

  @override
  String get common_share => 'Share';

  @override
  String get error_invalidNumber => 'Invalid number';

  @override
  String get export_title => 'Export';

  @override
  String get bankLinking_accountDetails => 'Account Details';

  @override
  String get bankLinking_accountHolderName => 'Account Holder Name';

  @override
  String get bankLinking_accountHolderNameRequired =>
      'Account holder name is required';

  @override
  String get bankLinking_accountNumber => 'Account Number';

  @override
  String get bankLinking_accountNumberRequired => 'Account number is required';

  @override
  String get bankLinking_amount => 'Amount';

  @override
  String get bankLinking_amountRequired => 'Amount is required';

  @override
  String get bankLinking_balance => 'Balance';

  @override
  String get bankLinking_balanceCheck => 'Balance Check';

  @override
  String get bankLinking_confirmDeposit => 'Confirm Deposit';

  @override
  String get bankLinking_confirmWithdraw => 'Confirm Withdrawal';

  @override
  String get bankLinking_deposit => 'Deposit';

  @override
  String bankLinking_depositConfirmation(String amount) {
    return 'Deposit $amount from your bank?';
  }

  @override
  String get bankLinking_depositFromBank => 'Deposit from Bank';

  @override
  String get bankLinking_depositInfo =>
      'Funds will be credited within 24 hours';

  @override
  String get bankLinking_depositSuccess => 'Deposit successful';

  @override
  String get bankLinking_devOtpHint => 'Dev OTP: 123456';

  @override
  String get bankLinking_directDebit => 'Direct Debit';

  @override
  String get bankLinking_enterAmount => 'Enter amount';

  @override
  String get bankLinking_failed => 'Failed';

  @override
  String get bankLinking_invalidAmount => 'Invalid amount';

  @override
  String get bankLinking_invalidOtp => 'Invalid OTP';

  @override
  String get bankLinking_linkAccount => 'Link Account';

  @override
  String get bankLinking_linkAccountDesc =>
      'Link your bank account for easy transfers';

  @override
  String get bankLinking_linkedAccounts => 'Linked Accounts';

  @override
  String get bankLinking_linkFailed => 'Failed to link account';

  @override
  String get bankLinking_linkNewAccount => 'Link New Account';

  @override
  String get bankLinking_noLinkedAccounts => 'No linked accounts';

  @override
  String get bankLinking_otpCode => 'OTP Code';

  @override
  String get bankLinking_otpResent => 'OTP resent';

  @override
  String get bankLinking_pending => 'Pending';

  @override
  String get bankLinking_primary => 'Primary';

  @override
  String get bankLinking_primaryAccountSet => 'Primary account set';

  @override
  String get bankLinking_resendOtp => 'Resend OTP';

  @override
  String bankLinking_resendOtpIn(int seconds) {
    return 'Resend OTP in ${seconds}s';
  }

  @override
  String get bankLinking_selectBank => 'Select Bank';

  @override
  String get bankLinking_selectBankDesc => 'Choose your bank to link';

  @override
  String get bankLinking_selectBankTitle => 'Select Your Bank';

  @override
  String get bankLinking_suspended => 'Suspended';

  @override
  String get bankLinking_verificationDesc => 'Enter the OTP sent to your phone';

  @override
  String get bankLinking_verificationFailed => 'Verification failed';

  @override
  String get bankLinking_verificationRequired => 'Verification Required';

  @override
  String get bankLinking_verificationSuccess => 'Account verified';

  @override
  String get bankLinking_verificationTitle => 'Verify Account';

  @override
  String get bankLinking_verified => 'Verified';

  @override
  String get bankLinking_verify => 'Verify';

  @override
  String get bankLinking_verifyAccount => 'Verify Account';

  @override
  String get bankLinking_withdraw => 'Withdraw';

  @override
  String bankLinking_withdrawConfirmation(String amount) {
    return 'Withdraw $amount to your bank?';
  }

  @override
  String get bankLinking_withdrawInfo =>
      'Funds will arrive in 1-3 business days';

  @override
  String get bankLinking_withdrawSuccess => 'Withdrawal successful';

  @override
  String get bankLinking_withdrawTime => 'Processing time: 1-3 business days';

  @override
  String get bankLinking_withdrawToBank => 'Withdraw to Bank';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get expenses_totalAmount => 'Total Amount';

  @override
  String get kyc_additionalDocs_title => 'Additional Documents';

  @override
  String get kyc_additionalDocs_description =>
      'Provide additional information for verification';

  @override
  String get kyc_additionalDocs_employment_title => 'Employment Information';

  @override
  String get kyc_additionalDocs_occupation => 'Occupation';

  @override
  String get kyc_additionalDocs_employer => 'Employer';

  @override
  String get kyc_additionalDocs_monthlyIncome => 'Monthly Income';

  @override
  String get kyc_additionalDocs_sourceOfFunds_title => 'Source of Funds';

  @override
  String get kyc_additionalDocs_sourceOfFunds_description =>
      'Tell us about your source of funds';

  @override
  String get kyc_additionalDocs_sourceDetails => 'Source Details';

  @override
  String get kyc_additionalDocs_supportingDocs_title => 'Supporting Documents';

  @override
  String get kyc_additionalDocs_supportingDocs_description =>
      'Upload documents to verify your information';

  @override
  String get kyc_additionalDocs_takePhoto => 'Take Photo';

  @override
  String get kyc_additionalDocs_uploadFile => 'Upload File';

  @override
  String get kyc_additionalDocs_error => 'Failed to submit documents';

  @override
  String get kyc_additionalDocs_info_title => 'Why we need this';

  @override
  String get kyc_additionalDocs_info_description =>
      'This helps us verify your identity';

  @override
  String get kyc_additionalDocs_submit => 'Submit Documents';

  @override
  String get kyc_additionalDocs_sourceType_salary => 'Salary';

  @override
  String get kyc_additionalDocs_sourceType_business => 'Business Income';

  @override
  String get kyc_additionalDocs_sourceType_investments => 'Investments';

  @override
  String get kyc_additionalDocs_sourceType_savings => 'Savings';

  @override
  String get kyc_additionalDocs_sourceType_inheritance => 'Inheritance';

  @override
  String get kyc_additionalDocs_sourceType_gift => 'Gift';

  @override
  String get kyc_additionalDocs_sourceType_other => 'Other';

  @override
  String get kyc_additionalDocs_suggestion_paySlip => 'Pay slip';

  @override
  String get kyc_additionalDocs_suggestion_bankStatement => 'Bank statement';

  @override
  String get kyc_additionalDocs_suggestion_businessReg =>
      'Business registration';

  @override
  String get kyc_additionalDocs_suggestion_taxReturn => 'Tax return';

  @override
  String get kyc_address_title => 'Address Verification';

  @override
  String get kyc_address_description => 'Verify your residential address';

  @override
  String get kyc_address_form_title => 'Your Address';

  @override
  String get kyc_address_addressLine1 => 'Address Line 1';

  @override
  String get kyc_address_addressLine2 => 'Address Line 2';

  @override
  String get kyc_address_city => 'City';

  @override
  String get kyc_address_state => 'State/Region';

  @override
  String get kyc_address_postalCode => 'Postal Code';

  @override
  String get kyc_address_country => 'Country';

  @override
  String get kyc_address_proofDocument_title => 'Proof of Address';

  @override
  String get kyc_address_proofDocument_description =>
      'Upload a document showing your address';

  @override
  String get kyc_address_takePhoto => 'Take Photo';

  @override
  String get kyc_address_retakePhoto => 'Retake Photo';

  @override
  String get kyc_address_chooseFile => 'Choose File';

  @override
  String get kyc_address_changeFile => 'Change File';

  @override
  String get kyc_address_uploadDocument => 'Upload Document';

  @override
  String get kyc_address_submit => 'Submit Address';

  @override
  String get kyc_address_error => 'Failed to submit address';

  @override
  String get kyc_address_info_title => 'Accepted Documents';

  @override
  String get kyc_address_info_description =>
      'Documents must be dated within 3 months';

  @override
  String get kyc_address_docType_utilityBill => 'Utility Bill';

  @override
  String get kyc_address_docType_utilityBill_description =>
      'Electricity, water, or gas bill';

  @override
  String get kyc_address_docType_bankStatement => 'Bank Statement';

  @override
  String get kyc_address_docType_bankStatement_description =>
      'Recent bank statement';

  @override
  String get kyc_address_docType_governmentLetter => 'Government Letter';

  @override
  String get kyc_address_docType_governmentLetter_description =>
      'Official government correspondence';

  @override
  String get kyc_address_docType_rentalAgreement => 'Rental Agreement';

  @override
  String get kyc_address_docType_rentalAgreement_description =>
      'Signed rental or lease agreement';

  @override
  String get kyc_video_title => 'Video Verification';

  @override
  String get kyc_video_instructions_title => 'Before You Start';

  @override
  String get kyc_video_instructions_description =>
      'Follow these guidelines for best results';

  @override
  String get kyc_video_instruction_lighting_title => 'Good Lighting';

  @override
  String get kyc_video_instruction_lighting_description =>
      'Find a well-lit area';

  @override
  String get kyc_video_instruction_position_title => 'Face Position';

  @override
  String get kyc_video_instruction_position_description =>
      'Keep your face in the frame';

  @override
  String get kyc_video_instruction_quiet_title => 'Quiet Environment';

  @override
  String get kyc_video_instruction_quiet_description => 'Find a quiet place';

  @override
  String get kyc_video_instruction_solo_title => 'Be Alone';

  @override
  String get kyc_video_instruction_solo_description =>
      'Only you should be in the frame';

  @override
  String get kyc_video_actions_title => 'Follow Instructions';

  @override
  String get kyc_video_actions_description =>
      'Complete each action as prompted';

  @override
  String get kyc_video_action_lookStraight => 'Look straight';

  @override
  String get kyc_video_action_turnLeft => 'Turn left';

  @override
  String get kyc_video_action_turnRight => 'Turn right';

  @override
  String get kyc_video_action_smile => 'Smile';

  @override
  String get kyc_video_action_blink => 'Blink';

  @override
  String get kyc_video_startRecording => 'Start Recording';

  @override
  String get kyc_video_continue => 'Continue';

  @override
  String get kyc_video_preview_title => 'Preview';

  @override
  String get kyc_video_preview_description => 'Review your video';

  @override
  String get kyc_video_preview_videoRecorded => 'Video recorded';

  @override
  String get kyc_video_retake => 'Retake';

  @override
  String get kyc_upgrade_title => 'Upgrade Verification';

  @override
  String get kyc_upgrade_selectTier => 'Select Tier';

  @override
  String get kyc_upgrade_selectTier_description =>
      'Choose your verification level';

  @override
  String get kyc_upgrade_currentTier => 'Current Tier';

  @override
  String get kyc_upgrade_recommended => 'Recommended';

  @override
  String get kyc_upgrade_perTransaction => 'Per Transaction';

  @override
  String get kyc_upgrade_dailyLimit => 'Daily Limit';

  @override
  String get kyc_upgrade_monthlyLimit => 'Monthly Limit';

  @override
  String get kyc_upgrade_andMore => 'and more';

  @override
  String get kyc_upgrade_requirements_title => 'Requirements';

  @override
  String get kyc_upgrade_requirement_idDocument => 'ID Document';

  @override
  String get kyc_upgrade_requirement_selfie => 'Selfie';

  @override
  String get kyc_upgrade_requirement_addressProof => 'Address Proof';

  @override
  String get kyc_upgrade_requirement_sourceOfFunds => 'Source of Funds';

  @override
  String get kyc_upgrade_requirement_videoVerification => 'Video Verification';

  @override
  String get kyc_upgrade_startVerification => 'Start Verification';

  @override
  String get kyc_upgrade_reason_title => 'Why upgrade?';

  @override
  String get settings_deviceTrustedSuccess => 'Device marked as trusted';

  @override
  String get settings_deviceTrustError => 'Failed to trust device';

  @override
  String get settings_deviceRemovedSuccess => 'Device removed successfully';

  @override
  String get settings_deviceRemoveError => 'Failed to remove device';

  @override
  String get settings_help => 'Help & Support';

  @override
  String get settings_rateApp => 'Rate Korido';

  @override
  String get settings_rateAppDescription =>
      'Enjoying Korido? Rate us on the App Store';

  @override
  String get action_copiedToClipboard => 'Copied to clipboard';

  @override
  String get transfer_successTitle => 'Transfer Successful!';

  @override
  String transfer_successMessage(String amount) {
    return 'Your transfer of $amount was successful';
  }

  @override
  String get transactions_transactionId => 'Transaction ID';

  @override
  String get common_amount => 'Amount';

  @override
  String get transactions_status => 'Status';

  @override
  String get transactions_completed => 'Completed';

  @override
  String get transactions_noAccountTitle => 'No Wallet Found';

  @override
  String get transactions_noAccountMessage =>
      'Create your wallet to start tracking your transactions and payment history.';

  @override
  String get transactions_connectionErrorTitle => 'Unable to Load';

  @override
  String get transactions_connectionErrorMessage =>
      'Please check your internet connection and try again.';

  @override
  String get transactions_emptyStateTitle => 'No Transactions Yet';

  @override
  String get transactions_emptyStateMessage =>
      'Once you make your first deposit or transfer, your transaction history will appear here.';

  @override
  String get transactions_emptyStateAction => 'Make First Deposit';

  @override
  String get common_note => 'Note';

  @override
  String get action_shareReceipt => 'Share Receipt';

  @override
  String get withdraw_mobileMoney => 'Mobile Money';

  @override
  String get withdraw_bankTransfer => 'Bank Transfer';

  @override
  String get withdraw_crypto => 'Crypto Wallet';

  @override
  String get withdraw_mobileMoneyDesc => 'Withdraw to Orange Money, MTN, Wave';

  @override
  String get withdraw_bankDesc => 'Transfer to your bank account';

  @override
  String get withdraw_cryptoDesc => 'Send to external wallet';

  @override
  String get navigation_withdraw => 'Withdraw';

  @override
  String get withdraw_method => 'Withdrawal Method';

  @override
  String get withdraw_processingInfo => 'Processing times vary by method';

  @override
  String get withdraw_amountLabel => 'Amount to Withdraw';

  @override
  String get withdraw_mobileNumber => 'Mobile Money Number';

  @override
  String get withdraw_bankDetails => 'Bank Details';

  @override
  String get withdraw_walletAddress => 'Wallet Address';

  @override
  String get withdraw_networkWarning =>
      'Make sure you are sending to a Solana USDC address';

  @override
  String get legal_cookiePolicy => 'Cookie Policy';

  @override
  String get legal_effectiveDate => 'Effective';

  @override
  String get legal_whatsNew => 'What\'s New';

  @override
  String get legal_contactUs => 'Contact Us';

  @override
  String get legal_cookieContactDescription =>
      'If you have questions about our cookie policy, please contact us:';

  @override
  String get legal_cookieCategories => 'Cookie Categories';

  @override
  String get legal_essential => 'Essential';

  @override
  String get legal_functional => 'Functional';

  @override
  String get legal_analytics => 'Analytics';

  @override
  String get legal_required => 'Required';

  @override
  String get legal_cookiePolicyDescription => 'View our cookie usage policy';

  @override
  String get legal_legalDocuments => 'Legal Documents';

  @override
  String get error_loadFailed => 'Failed to load';

  @override
  String get error_tryAgainLater => 'Please try again later';

  @override
  String get error_timeout =>
      'Request timed out. Please check your connection and try again.';

  @override
  String get error_noInternet =>
      'No internet connection. Please check your network and try again.';

  @override
  String get error_requestCancelled => 'Request was cancelled';

  @override
  String get error_sslError => 'Connection security error. Please try again.';

  @override
  String get error_otpExpired =>
      'Verification code has expired. Request a new code.';

  @override
  String get error_tooManyOtpAttempts =>
      'Too many failed attempts. Please wait before trying again.';

  @override
  String get error_invalidCredentials =>
      'Invalid credentials. Please check and try again.';

  @override
  String get error_accountLocked =>
      'Your account has been locked. Please contact support.';

  @override
  String get error_accountSuspended =>
      'Your account has been suspended. Please contact support for assistance.';

  @override
  String get error_sessionExpired =>
      'Your session has expired. Please log in again.';

  @override
  String get error_kycRequired =>
      'Identity verification required to continue. Complete verification in settings.';

  @override
  String get error_kycPending =>
      'Your identity verification is being reviewed. Please wait.';

  @override
  String get error_kycRejected =>
      'Your identity verification was rejected. Please resubmit with valid documents.';

  @override
  String get error_kycExpired =>
      'Your identity verification has expired. Please verify again.';

  @override
  String get error_amountTooLow =>
      'Amount is below minimum. Please enter a higher amount.';

  @override
  String get error_amountTooHigh =>
      'Amount exceeds maximum. Please enter a lower amount.';

  @override
  String get error_dailyLimitExceeded =>
      'Daily transaction limit reached. Try again tomorrow or upgrade your account.';

  @override
  String get error_monthlyLimitExceeded =>
      'Monthly transaction limit reached. Please wait or upgrade your account.';

  @override
  String get error_transactionLimitExceeded =>
      'Transaction limit exceeded for this operation.';

  @override
  String get error_duplicateTransaction =>
      'This transaction was already processed. Please check your history.';

  @override
  String get error_pinLocked =>
      'PIN locked due to too many incorrect attempts. Reset your PIN to continue.';

  @override
  String get error_pinTooWeak =>
      'PIN is too simple. Please choose a stronger PIN.';

  @override
  String get error_beneficiaryNotFound =>
      'Beneficiary not found. Please check and try again.';

  @override
  String get error_beneficiaryLimitReached =>
      'Maximum number of beneficiaries reached. Remove one to add a new beneficiary.';

  @override
  String get error_providerUnavailable =>
      'Service provider is currently unavailable. Please try again later.';

  @override
  String get error_providerTimeout =>
      'Service provider is not responding. Please try again.';

  @override
  String get error_providerMaintenance =>
      'Service provider is under maintenance. Please try again later.';

  @override
  String get error_rateLimited =>
      'Too many requests. Please slow down and try again in a moment.';

  @override
  String get error_invalidAddress =>
      'Invalid wallet address. Please check and try again.';

  @override
  String get error_invalidCountry => 'Service not available in your country.';

  @override
  String get error_deviceNotTrusted =>
      'This device is not trusted. Please verify your identity.';

  @override
  String get error_deviceLimitReached =>
      'Maximum number of devices reached. Remove a device to add this one.';

  @override
  String get error_biometricRequired =>
      'Biometric authentication is required for this action.';

  @override
  String get error_badRequest =>
      'Invalid request. Please check your information and try again.';

  @override
  String get error_unauthorized =>
      'Authentication required. Please log in again.';

  @override
  String get error_accessDenied =>
      'You don\'t have permission to perform this action.';

  @override
  String get error_notFound => 'Requested resource not found.';

  @override
  String get error_conflict =>
      'Request conflicts with current state. Please refresh and try again.';

  @override
  String get error_validationFailed =>
      'Please check the information you provided and try again.';

  @override
  String get error_serverError =>
      'Server error. Our team has been notified. Please try again later.';

  @override
  String get error_serviceUnavailable =>
      'Service temporarily unavailable. Please try again in a few moments.';

  @override
  String get error_gatewayTimeout =>
      'Service is taking too long to respond. Please try again.';

  @override
  String get error_authenticationFailed =>
      'Authentication failed. Please try again.';

  @override
  String get error_suggestion_checkConnection =>
      'Check your internet connection';

  @override
  String get error_suggestion_tryAgain => 'Try again';

  @override
  String get error_suggestion_loginAgain => 'Log in again';

  @override
  String get error_suggestion_completeKyc => 'Complete verification';

  @override
  String get error_suggestion_addFunds => 'Add funds to your wallet';

  @override
  String get error_suggestion_waitOrUpgrade => 'Wait or upgrade your account';

  @override
  String get error_suggestion_tryLater => 'Try again later';

  @override
  String get error_suggestion_resetPin => 'Reset your PIN';

  @override
  String get error_suggestion_slowDown => 'Slow down and wait a moment';

  @override
  String get error_offline_title => 'You\'re Offline';

  @override
  String get error_offline_message =>
      'You\'re not connected to the internet. Some features may not be available.';

  @override
  String get error_offline_retry => 'Retry Connection';

  @override
  String get action_skip => 'Skip';

  @override
  String get action_next => 'Next';

  @override
  String get onboarding_page1_title => 'Your Money, Your Way';

  @override
  String get onboarding_page1_description =>
      'Store, send, and receive USDC securely. Your digital wallet built for West Africa.';

  @override
  String get onboarding_page1_feature1 => 'Store USDC safely in your wallet';

  @override
  String get onboarding_page1_feature2 => 'Send money to anyone instantly';

  @override
  String get onboarding_page1_feature3 => 'Access your funds 24/7';

  @override
  String get onboarding_page2_title => 'Lightning-Fast Transfers';

  @override
  String get onboarding_page2_description =>
      'Transfer funds to friends and family in seconds. No borders, no delays.';

  @override
  String get onboarding_page2_feature1 => 'Instant transfers within Korido';

  @override
  String get onboarding_page2_feature2 => 'Send to any mobile money account';

  @override
  String get onboarding_page2_feature3 => 'Real-time transaction updates';

  @override
  String get onboarding_page3_title => 'Easy Deposits & Withdrawals';

  @override
  String get onboarding_page3_description =>
      'Add money via Mobile Money. Cash out to your local account anytime.';

  @override
  String get onboarding_page3_feature1 =>
      'Deposit with Orange Money, MTN, Wave';

  @override
  String get onboarding_page3_feature2 => 'Low transaction fees (1%)';

  @override
  String get onboarding_page3_feature3 => 'Withdraw anytime to your account';

  @override
  String get onboarding_page4_title => 'Bank-Level Security';

  @override
  String get onboarding_page4_description =>
      'Your funds are protected with state-of-the-art encryption and biometric authentication.';

  @override
  String get onboarding_page4_feature1 => 'PIN and biometric protection';

  @override
  String get onboarding_page4_feature2 => 'End-to-end encryption';

  @override
  String get onboarding_page4_feature3 => '24/7 fraud monitoring';

  @override
  String welcome_title(String name) {
    return 'Welcome, $name!';
  }

  @override
  String get welcome_subtitle =>
      'Your Korido wallet is ready. Start sending and receiving money today!';

  @override
  String get welcome_addFunds => 'Add Funds';

  @override
  String get welcome_exploreDashboard => 'Explore Dashboard';

  @override
  String get welcome_stat_wallet => 'Secure Wallet';

  @override
  String get welcome_stat_wallet_desc => 'Your funds are safe with us';

  @override
  String get welcome_stat_instant => 'Instant Transfers';

  @override
  String get welcome_stat_instant_desc => 'Send money in seconds';

  @override
  String get welcome_stat_secure => 'Bank-Level Security';

  @override
  String get welcome_stat_secure_desc => 'Protected by advanced encryption';

  @override
  String get onboarding_deposit_prompt_title =>
      'Get Started with Your First Deposit';

  @override
  String get onboarding_deposit_prompt_subtitle =>
      'Add funds to start sending and receiving money';

  @override
  String get onboarding_deposit_benefit1 => 'Instant deposits via Mobile Money';

  @override
  String get onboarding_deposit_benefit2 => 'Only 1% transaction fee';

  @override
  String get onboarding_deposit_benefit3 => 'Funds available immediately';

  @override
  String get onboarding_deposit_cta => 'Add Money Now';

  @override
  String get help_whatIsUsdc => 'What is USDC?';

  @override
  String get help_usdc_title => 'USDC: Digital Dollar';

  @override
  String get help_usdc_subtitle => 'The stable digital currency';

  @override
  String get help_usdc_what_title => 'What is USDC?';

  @override
  String get help_usdc_what_description =>
      'USDC (USD Coin) is a digital currency that\'s always worth exactly \$1 USD. It combines the stability of the US dollar with the speed and efficiency of blockchain technology.';

  @override
  String get help_usdc_why_title => 'Why Use USDC?';

  @override
  String get help_usdc_benefit1_title => 'Stable Value';

  @override
  String get help_usdc_benefit1_description =>
      'Always worth \$1 USD - no volatility';

  @override
  String get help_usdc_benefit2_title => 'Secure & Transparent';

  @override
  String get help_usdc_benefit2_description =>
      'Backed 1:1 by real US dollars held in reserve';

  @override
  String get help_usdc_benefit3_title => 'Global Access';

  @override
  String get help_usdc_benefit3_description =>
      'Send money anywhere in the world instantly';

  @override
  String get help_usdc_benefit4_title => '24/7 Availability';

  @override
  String get help_usdc_benefit4_description =>
      'Access your money anytime, anywhere';

  @override
  String get help_usdc_how_title => 'How It Works';

  @override
  String get help_usdc_how_description =>
      'When you deposit money, it\'s converted to USDC at a 1:1 rate with USD. You can then send USDC to anyone or convert it back to your local currency anytime.';

  @override
  String get help_usdc_safety_title => 'Is it Safe?';

  @override
  String get help_usdc_safety_description =>
      'Yes! USDC is issued by Circle, a regulated financial institution. Every USDC is backed by real US dollars held in reserve accounts.';

  @override
  String get help_howDepositsWork => 'How Deposits Work';

  @override
  String get help_deposits_header => 'Adding Money to Your Wallet';

  @override
  String get help_deposits_intro =>
      'Depositing funds into your Korido wallet is quick and easy using Mobile Money services available across West Africa.';

  @override
  String get help_deposits_steps_title => 'How to Deposit';

  @override
  String get help_deposits_step1_title => 'Choose Amount';

  @override
  String get help_deposits_step1_description =>
      'Enter how much you want to add to your wallet';

  @override
  String get help_deposits_step2_title => 'Select Provider';

  @override
  String get help_deposits_step2_description =>
      'Choose your Mobile Money provider (Orange Money, MTN, etc.)';

  @override
  String get help_deposits_step3_title => 'Complete Payment';

  @override
  String get help_deposits_step3_description =>
      'Follow the USSD prompt on your phone to authorize the payment';

  @override
  String get help_deposits_step4_title => 'Funds Added';

  @override
  String get help_deposits_step4_description =>
      'Your USDC balance updates within seconds';

  @override
  String get help_deposits_providers_title => 'Supported Providers';

  @override
  String get help_deposits_time_title => 'Processing Time';

  @override
  String get help_deposits_time_description =>
      'Most deposits are processed within 1-2 minutes';

  @override
  String get help_deposits_faq_title => 'Common Questions';

  @override
  String get help_deposits_faq1_question => 'What\'s the minimum deposit?';

  @override
  String get help_deposits_faq1_answer =>
      'The minimum deposit is 1,000 XOF (approximately \$1.60 USD)';

  @override
  String get help_deposits_faq2_question => 'Are there fees?';

  @override
  String get help_deposits_faq2_answer =>
      'Yes, there\'s a 1% transaction fee on deposits';

  @override
  String get help_deposits_faq3_question => 'What if my deposit fails?';

  @override
  String get help_deposits_faq3_answer =>
      'Your money will be automatically refunded to your Mobile Money account within 24 hours';

  @override
  String get help_transactionFees => 'Transaction Fees';

  @override
  String get help_fees_no_hidden_title => 'No Hidden Fees';

  @override
  String get help_fees_no_hidden_description =>
      'We believe in transparency. Here\'s exactly what you pay.';

  @override
  String get help_fees_breakdown_title => 'Fee Breakdown';

  @override
  String get help_fees_internal_transfers => 'Transfers to Korido Users';

  @override
  String get help_fees_free => 'FREE';

  @override
  String get help_fees_internal_description =>
      'Send money to other Korido users with zero fees';

  @override
  String get help_fees_deposits => 'Mobile Money Deposits';

  @override
  String get help_fees_deposits_amount => '1%';

  @override
  String get help_fees_deposits_description =>
      '1% fee when adding funds via Mobile Money';

  @override
  String get help_fees_withdrawals => 'Withdrawals to Mobile Money';

  @override
  String get help_fees_withdrawals_amount => '1%';

  @override
  String get help_fees_withdrawals_description =>
      '1% fee when cashing out to Mobile Money';

  @override
  String get help_fees_external_transfers => 'External Crypto Transfers';

  @override
  String get help_fees_external_amount => 'Network Fee';

  @override
  String get help_fees_external_description =>
      'Blockchain network fee applies (varies by network)';

  @override
  String get help_fees_why_title => 'Why Do We Charge Fees?';

  @override
  String get help_fees_why_description => 'Our fees help us:';

  @override
  String get help_fees_why_point1 =>
      'Maintain secure infrastructure and compliance';

  @override
  String get help_fees_why_point2 => 'Provide 24/7 customer support';

  @override
  String get help_fees_why_point3 => 'Cover Mobile Money provider charges';

  @override
  String get help_fees_why_point4 => 'Continue improving our services';

  @override
  String get help_fees_comparison_title => 'How We Compare';

  @override
  String get help_fees_comparison_description =>
      'Our fees are significantly lower than traditional money transfer services:';

  @override
  String get help_fees_comparison_traditional => 'Traditional Services';

  @override
  String get help_fees_comparison_joonapay => 'Korido';

  @override
  String get offline_banner_title => 'You\'re offline';

  @override
  String offline_banner_last_sync(String time) {
    return 'Last synced $time';
  }

  @override
  String get offline_banner_syncing => 'Syncing pending operations...';

  @override
  String get offline_banner_reconnected => 'Back online! All synced.';

  @override
  String get state_otpExpired => 'OTP code has expired';

  @override
  String get state_otpExpiredDescription =>
      'Your one-time password has expired. Please request a new code.';

  @override
  String get state_tokenRefreshing => 'Refreshing your access...';

  @override
  String get state_accountLocked => 'Account locked';

  @override
  String get state_accountLockedDescription =>
      'Your account has been locked due to multiple failed attempts. Please try again later.';

  @override
  String get state_accountSuspended => 'Account suspended';

  @override
  String get state_accountSuspendedDescription =>
      'Your account has been suspended. Please contact support for more information.';

  @override
  String get state_walletFrozen => 'Wallet frozen';

  @override
  String get state_walletFrozenDescription =>
      'Your wallet has been frozen for security reasons. Please contact support.';

  @override
  String get state_walletUnderReview => 'Wallet under review';

  @override
  String get state_walletUnderReviewDescription =>
      'Your wallet is currently under review. Transactions are temporarily restricted.';

  @override
  String get state_walletLimited => 'Wallet limited';

  @override
  String get state_walletLimitedDescription =>
      'Your wallet has reached its transaction or balance limit. Upgrade your account to increase limits.';

  @override
  String get state_kycExpired => 'KYC verification expired';

  @override
  String get state_kycExpiredDescription =>
      'Your identity verification has expired. Please update your information to continue.';

  @override
  String get state_kycManualReview => 'KYC manual review pending';

  @override
  String get state_kycManualReviewDescription =>
      'Your identity verification is being manually reviewed. This may take 24-48 hours.';

  @override
  String get state_kycUpgrading => 'KYC level upgrading';

  @override
  String get state_kycUpgradingDescription =>
      'Your identity verification level is being upgraded. Please wait.';

  @override
  String get state_biometricPrompt => 'Biometric authentication required';

  @override
  String get state_biometricPromptDescription =>
      'Please use your fingerprint or face to authenticate.';

  @override
  String get state_deviceChanged => 'Device verification required';

  @override
  String get state_deviceChangedDescription =>
      'This appears to be a new device. Please verify your identity to continue.';

  @override
  String get state_sessionConflict => 'Another session is active';

  @override
  String get state_sessionConflictDescription =>
      'You are logged in on another device. Please log out there or continue here.';

  @override
  String get auth_lockedReason =>
      'Your account has been temporarily locked due to multiple failed attempts';

  @override
  String get auth_accountLocked => 'Account Temporarily Locked';

  @override
  String get auth_tryAgainIn => 'Try again in';

  @override
  String get common_backToLogin => 'Back to Login';

  @override
  String get auth_suspendedReason =>
      'Your account has been suspended. Please contact support for more information.';

  @override
  String get auth_accountSuspended => 'Account Suspended';

  @override
  String get auth_suspendedUntil => 'Suspended until';

  @override
  String get auth_contactSupport => 'Need Help?';

  @override
  String get auth_suspendedContactMessage =>
      'If you believe this is a mistake, please contact our support team for assistance.';

  @override
  String get common_contactSupport => 'Contact Support';

  @override
  String get biometric_authenticateReason => 'Authenticate to continue';

  @override
  String get biometric_promptReason =>
      'Please use your fingerprint or face to authenticate';

  @override
  String get biometric_promptTitle => 'Biometric Authentication';

  @override
  String get biometric_tryAgain => 'Try Again';

  @override
  String get biometric_usePinInstead => 'Use PIN Instead';

  @override
  String get auth_otpExpired => 'OTP Code Expired';

  @override
  String get auth_otpExpiredMessage =>
      'Your verification code has expired. Please request a new code.';

  @override
  String get session_locked => 'Session Locked';

  @override
  String get session_lockedMessage =>
      'Your session has been locked. Please enter your PIN to continue.';

  @override
  String get session_enterPinToUnlock => 'Enter PIN to Unlock';

  @override
  String get session_useBiometric => 'Use Biometric';

  @override
  String get session_unlockReason => 'Unlock your session to continue';

  @override
  String get session_expiring => 'Session Expiring';

  @override
  String session_expiringMessage(int seconds) {
    return 'Your session will expire in $seconds seconds due to inactivity.';
  }

  @override
  String get session_stayLoggedIn => 'Stay Logged In';

  @override
  String get device_newDeviceDetected => 'New Device Detected';

  @override
  String get device_verificationRequired =>
      'We detected a new device. Please verify your identity to continue using Korido.';

  @override
  String get device_deviceId => 'Device ID';

  @override
  String get device_verificationOptions => 'Verification Options';

  @override
  String get device_verificationOptionsDesc =>
      'Choose how you\'d like to verify this device';

  @override
  String get device_verifyWithOtp => 'Verify with SMS Code';

  @override
  String get device_verifyWithEmail => 'Verify with Email';

  @override
  String get session_conflict => 'Active Session Detected';

  @override
  String get session_conflictMessage =>
      'You are currently logged in on another device. You can continue here, which will log you out from the other device.';

  @override
  String get session_otherDevice => 'Other Device';

  @override
  String get session_forceLogoutWarning =>
      'Continuing here will end your session on the other device.';

  @override
  String get session_continueHere => 'Continue Here';

  @override
  String get wallet_frozenReason =>
      'Your wallet has been frozen. Please contact support for more information.';

  @override
  String get wallet_frozen => 'Wallet Frozen';

  @override
  String get wallet_frozenTitle => 'Wallet Temporarily Frozen';

  @override
  String get wallet_frozenUntil => 'Frozen until';

  @override
  String get wallet_frozenContactSupport => 'Contact Support';

  @override
  String get wallet_frozenContactMessage =>
      'Our support team can help you understand why your wallet was frozen and what steps to take next.';

  @override
  String get common_backToHome => 'Back to Home';

  @override
  String get wallet_underReviewReason =>
      'Your wallet is under compliance review. You\'ll be notified once the review is complete.';

  @override
  String get wallet_underReview => 'Under Review';

  @override
  String get wallet_underReviewTitle => 'Wallet Under Review';

  @override
  String get wallet_reviewStatus => 'Review Status';

  @override
  String get wallet_reviewStarted => 'Started';

  @override
  String get wallet_estimatedTime => 'Estimated Time';

  @override
  String get wallet_reviewEstimate => '24-48 hours';

  @override
  String get wallet_whileUnderReview => 'While Under Review';

  @override
  String get wallet_reviewRestriction1 => 'Deposits are temporarily disabled';

  @override
  String get wallet_reviewRestriction2 =>
      'Withdrawals are temporarily disabled';

  @override
  String get wallet_reviewRestriction3 =>
      'You can view your balance and transaction history';

  @override
  String get wallet_checkStatus => 'Check Status';

  @override
  String get kyc_expired => 'KYC Expired';

  @override
  String get kyc_expiredTitle => 'Identity Documents Expired';

  @override
  String get kyc_expiredMessage =>
      'Your identity verification documents have expired. Please renew them to continue using all features.';

  @override
  String get kyc_expiredOn => 'Expired on';

  @override
  String get kyc_renewalRequired => 'Renewal Required';

  @override
  String get kyc_renewalMessage =>
      'To restore full access to your wallet, please update your identity documents.';

  @override
  String get kyc_currentRestrictions => 'Current Restrictions';

  @override
  String get kyc_restriction1 => 'Limited transaction amounts';

  @override
  String get kyc_restriction2 => 'Some features may be unavailable';

  @override
  String get kyc_restriction3 => 'Withdrawals may be restricted';

  @override
  String get kyc_renewDocuments => 'Renew Documents';

  @override
  String get kyc_remindLater => 'Remind Me Later';

  @override
  String get action_backToHome => 'Back to Home';

  @override
  String get action_checkStatus => 'Check Status';

  @override
  String get action_ok => 'OK';

  @override
  String get common_errorTryAgain => 'Something went wrong. Please try again.';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_unknownError => 'An unknown error occurred';

  @override
  String get deposit_amount => 'Amount';

  @override
  String get deposit_approveOnPhone =>
      'Approve the payment on your phone by entering your PIN';

  @override
  String get deposit_balanceUpdated => 'Your balance has been updated';

  @override
  String get deposit_cardPaymentComingSoon => 'Card payment coming soon';

  @override
  String get deposit_choosePaymentMethod => 'Choose Payment Method';

  @override
  String get deposit_dialUSSD => 'Dial the USSD code below to get your OTP';

  @override
  String get deposit_enterOTP => 'Enter OTP';

  @override
  String deposit_errorReason(String reason) {
    return 'Error: $reason';
  }

  @override
  String get deposit_failedDesc => 'Your deposit could not be completed';

  @override
  String get deposit_failedTitle => 'Deposit Failed';

  @override
  String get deposit_noDepositData => 'No deposit data available';

  @override
  String get deposit_noProvidersAvailable => 'No Providers Available';

  @override
  String get deposit_noProvidersAvailableDesc =>
      'No deposit providers are currently available. Please try again later.';

  @override
  String get deposit_openInWave => 'Open in Wave';

  @override
  String get deposit_orScanQR => 'Or scan the QR code below';

  @override
  String get deposit_payment => 'Payment';

  @override
  String get deposit_processingDesc =>
      'We are processing your deposit. This may take a moment.';

  @override
  String get deposit_processingSubtitle =>
      'Please wait while we verify your payment';

  @override
  String get deposit_processingTitle => 'Processing Deposit';

  @override
  String get deposit_scanQRCode => 'Scan QR Code';

  @override
  String get deposit_selectHowToDeposit => 'Select how you want to deposit';

  @override
  String get deposit_submitOTP => 'Submit OTP';

  @override
  String get deposit_successDesc =>
      'Your deposit has been completed successfully';

  @override
  String get deposit_successTitle => 'Deposit Successful';

  @override
  String get deposit_waitingForApproval => 'Waiting for approval on your phone';

  @override
  String get deposit_waitingForPayment => 'Waiting for payment';

  @override
  String get deposit_youPay => 'You Pay';

  @override
  String get deposit_youReceive => 'You Receive';

  @override
  String airtime_billPaymentSuccess(Object amount) {
    return 'Bill payment of \\\$$amount successful!';
  }

  @override
  String airtime_providerSelected(Object provider) {
    return 'Selected $provider';
  }

  @override
  String airtime_purchaseSuccess(Object amount) {
    return 'Airtime of \\\$$amount purchased successfully!';
  }

  @override
  String get analytics_failedToLoad => 'Failed to load analytics';

  @override
  String get analytics_monthlyTotal => 'Monthly total';

  @override
  String get bankLinking_accounts => 'Bank Accounts';

  @override
  String get bankLinking_enterCode => 'Enter Verification Code';

  @override
  String get bankLinking_linkSuccess => 'Bank account linked successfully';

  @override
  String get beneficiaries_addError =>
      'Unable to add beneficiary. Please try again.';

  @override
  String get beneficiaries_deleteConfirm => 'Delete Recipient?';

  @override
  String get beneficiaries_failedToAdd => 'Failed to add recipient';

  @override
  String get beneficiaries_failedToDelete => 'Failed to delete contact';

  @override
  String get beneficiaries_failedToUpdateFavorite =>
      'Failed to update favorite';

  @override
  String get beneficiaries_recipientAdded => 'Recipient added';

  @override
  String get beneficiaries_recipientRemoved => 'Recipient removed';

  @override
  String get billPayments_category => 'Category';

  @override
  String get billPayments_paymentComplete => 'Payment Complete';

  @override
  String get budget_categoryAdded => 'Category added';

  @override
  String get budget_deleteCategory => 'Delete Category?';

  @override
  String get budget_tapCategoryToEdit => 'Tap any category to edit its budget';

  @override
  String bulkPayments_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get bulkPayments_fileLoadError =>
      'Unable to load file. Please try again.';

  @override
  String get cards_blockError => 'Unable to block card. Please try again.';

  @override
  String get cards_cardCreated => 'Card created successfully';

  @override
  String get cards_cardType => 'Card Type';

  @override
  String get cards_createCard => 'Create Card';

  @override
  String get cards_createError => 'Unable to create card. Please try again.';

  @override
  String cards_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get cards_myCards => 'My Cards';

  @override
  String get cards_newCard => 'New Card';

  @override
  String get common_copy => 'Copy';

  @override
  String get common_default => 'Default';

  @override
  String common_errorFormat(Object error) {
    return 'Error: $error';
  }

  @override
  String get common_genericError => 'An error occurred. Please try again.';

  @override
  String get common_recent => 'Recent';

  @override
  String get common_seeAll => 'See All';

  @override
  String get common_status => 'Status';

  @override
  String get common_tooManyAttempts =>
      'Too many incorrect attempts. Please try again later.';

  @override
  String get common_type => 'Type';

  @override
  String get contacts_allContacts => 'All Contacts';

  @override
  String contacts_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get contacts_favorites => 'Favorites';

  @override
  String get deviceVerification_failed => 'Verification failed';

  @override
  String get expenses_captureError => 'Error capturing. Please try again.';

  @override
  String get expenses_receiptProcessError =>
      'Error processing receipt. Please try again.';

  @override
  String expenses_reportError(Object error) {
    return 'Error: $error';
  }

  @override
  String get expenses_saveError => 'Unable to save expense. Please try again.';

  @override
  String insights_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get kyc_cameraInitFailed => 'Camera initialization failed';

  @override
  String get kyc_completeLivenessFirst =>
      'Please complete liveness check first';

  @override
  String kyc_completeVerification(Object limit) {
    return 'Complete verification to increase your daily limit to \\\$$limit';
  }

  @override
  String get kyc_documentType => 'Document Type';

  @override
  String get kyc_documentsSubmitted => 'Documents Submitted';

  @override
  String get kyc_failedToPickImage => 'Failed to pick image';

  @override
  String get kyc_failedToSubmit => 'Failed to submit KYC';

  @override
  String get kyc_failedToTakeSelfie => 'Failed to take selfie';

  @override
  String kyc_livenessCheckFailed(Object reason) {
    return 'Liveness check failed: $reason';
  }

  @override
  String get kyc_livenessCheckPassed =>
      'Liveness check passed! You can now take your selfie.';

  @override
  String get kyc_submit => 'Submit';

  @override
  String get kyc_takeSelfie => 'Take a Selfie';

  @override
  String get kyc_verificationProcessing =>
      'Your verification will be processed within 24-48 hours.';

  @override
  String get kyc_verify => 'Verify';

  @override
  String limits_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get limits_maxPerTransaction => 'Max per transaction';

  @override
  String get limits_transactionLimits => 'Transaction Limits';

  @override
  String get liveness_goBack => 'Go Back';

  @override
  String get liveness_title => 'Liveness Check';

  @override
  String get liveness_tryAgain => 'Try Again';

  @override
  String get merchant_dashboard => 'Merchant Dashboard';

  @override
  String get merchant_myQrCode => 'My QR Code';

  @override
  String get merchant_requestPayment => 'Request Payment';

  @override
  String get merchant_scanToPay => 'Scan to pay me';

  @override
  String get merchant_shareQr => 'Share QR Code';

  @override
  String get paymentLinks_copied => 'Link copied';

  @override
  String get paymentLinks_create => 'Create a Payment Link';

  @override
  String paymentLinks_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get paymentLinks_generate => 'Generate Link';

  @override
  String get paymentLinks_ready => 'Payment Link Ready';

  @override
  String get paymentLinks_singleUse => 'Single use';

  @override
  String get paymentLinks_singleUseDescription =>
      'Link expires after one payment';

  @override
  String get profile_completion => 'Profile completion';

  @override
  String get profile_setName => 'Set your name';

  @override
  String get qr_failedToScan => 'Failed to scan QR from image';

  @override
  String get qr_failedToShare => 'Failed to share QR code';

  @override
  String get qr_myCode => 'My QR Code';

  @override
  String get qr_noCodeFound => 'No QR code found in image';

  @override
  String get qr_receive => 'Receive';

  @override
  String get qr_scanToPay => 'Scan to pay me';

  @override
  String get qr_shareCode => 'Share QR Code';

  @override
  String get receipts_enterEmailAddress => 'Enter Email Address';

  @override
  String get receipts_receiptView => 'Receipt';

  @override
  String get receipts_referenceNumberCopied => 'Reference number copied';

  @override
  String get recurringTransfers_createTransfer => 'Create Transfer';

  @override
  String get recurringTransfers_created => 'Recurring transfer created';

  @override
  String referrals_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get referrals_yourReferrals => 'Your Referrals';

  @override
  String get savingsGoals_created => 'Goal created successfully!';

  @override
  String get savingsGoals_deleteConfirm => 'Delete Goal?';

  @override
  String get savingsGoals_deleted => 'Goal deleted';

  @override
  String get savingsGoals_setTargetDate => 'Set target date (optional)';

  @override
  String get savingsGoals_totalSavings => 'Total Savings';

  @override
  String get savingsPots_createPot => 'Create Pot';

  @override
  String savingsPots_error(Object error) {
    return 'Error: $error';
  }

  @override
  String get scheduledTransfers_created => 'Schedule created successfully!';

  @override
  String get scheduledTransfers_deleted => 'Schedule deleted';

  @override
  String get security_account => 'Account';

  @override
  String get security_autoLock => 'Auto-lock';

  @override
  String get security_autoLockAfter => 'Auto-Lock After';

  @override
  String security_autoLockMinutes(Object minutes) {
    return 'After $minutes minutes of inactivity';
  }

  @override
  String get security_manageDevices => 'Manage Devices';

  @override
  String security_minutesFormat(Object minutes) {
    return '$minutes minutes';
  }

  @override
  String get security_pinOnAppOpen => 'Require PIN on App Open';

  @override
  String get security_pinOnAppOpenSubtitle =>
      'Require PIN every time the app opens';

  @override
  String get security_screenshotProtection => 'Screenshot Protection';

  @override
  String get security_screenshotProtectionSubtitle =>
      'Prevent screenshots on sensitive screens';

  @override
  String get security_transactionAlerts => 'Transaction Alerts';

  @override
  String get security_transactionAlertsSubtitle =>
      'Get notified for every transaction';

  @override
  String get send_searchRecipient => 'Search recipient';

  @override
  String get settings_activeDevices => 'Active Devices';

  @override
  String get settings_approve => 'Approve';

  @override
  String get settings_chooseFromGallery => 'Choose from gallery';

  @override
  String get settings_connectingToSupport => 'Connecting to support agent...';

  @override
  String get settings_copiedToClipboard => 'Copied to clipboard';

  @override
  String get settings_failedToUpdateProfile => 'Failed to update profile';

  @override
  String get settings_improveAnswer => 'We\'ll improve this answer';

  @override
  String get settings_openingLiveChat => 'Opening live chat...';

  @override
  String settings_openingUrl(Object url) {
    return 'Opening: $url';
  }

  @override
  String get settings_openingWhatsApp => 'Opening WhatsApp...';

  @override
  String get settings_performanceMonitor => 'Performance Monitor';

  @override
  String get settings_problemReported =>
      'Problem reported. We\'ll get back to you soon.';

  @override
  String get settings_profileUpdated => 'Profile updated successfully';

  @override
  String get settings_takePhoto => 'Take a photo';

  @override
  String get settings_thanksFeedback => 'Thanks for your feedback!';

  @override
  String get settings_verificationFailed =>
      'Verification failed. Please try again.';

  @override
  String splitBill_requestsSent(Object count) {
    return 'Payment requests sent to $count people';
  }

  @override
  String get subBusiness_view => 'View';

  @override
  String get transactions_export => 'Export Transactions';

  @override
  String get transactions_exportAsCsv => 'Export as CSV';

  @override
  String transactions_exported(Object format) {
    return 'Transactions exported as $format';
  }

  @override
  String get transactions_noTransactionsYet => 'No transactions yet';

  @override
  String get transactions_viewTransaction => 'View Transaction';

  @override
  String get wallet_insufficientBalance => 'Insufficient balance';

  @override
  String wallet_pending(Object amount) {
    return 'Pending: \\\$$amount';
  }

  @override
  String get withdraw_comingSoon => 'Withdraw feature coming soon';

  @override
  String get withdraw_failed => 'Withdrawal failed. Please try again.';

  @override
  String get withdraw_initiated => 'Withdrawal initiated';

  @override
  String get auth_useBiometric => 'Use biometric login';

  @override
  String get security_accountSecurity => 'Account Security';

  @override
  String get security_wellProtected => 'Your account is well protected';

  @override
  String get security_scoreGoodDesc => 'Good security, but you can improve';

  @override
  String get security_scoreModerateDesc =>
      'Moderate security. Enable more protections';

  @override
  String get security_scoreLowDesc =>
      'Low security. Take action to protect your account';

  @override
  String get verification_accountVerification => 'Account Verification';

  @override
  String get verification_phoneNumber => 'Phone Number';

  @override
  String get verification_verified => 'Verified';

  @override
  String get verification_personalInfo => 'Personal Information';

  @override
  String get verification_complete => 'Complete';

  @override
  String get verification_toComplete => 'To complete';

  @override
  String get verification_identityDocument => 'Identity Document';

  @override
  String get verification_verifyIdentity => 'Verify your identity';

  @override
  String get verification_selfie => 'Verification Selfie';

  @override
  String get verification_confirmIdentity => 'Confirm your identity';

  @override
  String get verification_continue => 'Continue Verification';

  @override
  String verification_step(int step) {
    return 'Step $step';
  }

  @override
  String get delete_accountTitle => 'Delete My Account';

  @override
  String get delete_warningMessage =>
      'Warning: this action is irreversible. All your data will be permanently deleted.';

  @override
  String get delete_consequencesTitle =>
      'What happens when you delete your account:';

  @override
  String get delete_consequenceBalance => 'Your remaining balance will be lost';

  @override
  String get delete_consequenceHistory => 'Transaction history deleted';

  @override
  String get delete_consequenceIrreversible =>
      'Impossible to recover your account';

  @override
  String get delete_consequenceKyc => 'KYC data erased within 30 days';

  @override
  String get delete_contactSupportTitle => 'Contact Support';

  @override
  String get delete_contactSupportDescription =>
      'To delete your account, please contact our support team. They will guide you through the process.';

  @override
  String get delete_contactSupportButton => 'Contact Support';
}
