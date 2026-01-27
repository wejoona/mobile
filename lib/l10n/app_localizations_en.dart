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
  String get language_english => 'English';

  @override
  String get language_french => 'French';

  @override
  String get language_selectLanguage => 'Select Language';

  @override
  String get language_changeLanguage => 'Change Language';
}
