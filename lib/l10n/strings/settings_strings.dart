/// User-facing strings for settings screens.
library;

abstract final class SettingsStrings {
  static const title = 'Settings';
  static const profile = 'Profile';
  static const editProfile = 'Edit Profile';
  static const fullName = 'Full Name';
  static const email = 'Email';
  static const phone = 'Phone Number';

  // Security
  static const security = 'Security';
  static const changePin = 'Change PIN';
  static const biometricAuth = 'Biometric Authentication';
  static const biometricDescription = 'Use fingerprint or face to unlock';
  static const twoFactorAuth = 'Two-Factor Authentication';
  static const activeSessions = 'Active Sessions';
  static const linkedDevices = 'Linked Devices';

  // Preferences
  static const preferences = 'Preferences';
  static const language = 'Language';
  static const theme = 'Theme';
  static const themeLight = 'Light';
  static const themeDark = 'Dark';
  static const themeSystem = 'System';
  static const currency = 'Display Currency';
  static const notifications = 'Notifications';
  static const notificationSettings = 'Notification Settings';

  // KYC
  static const kyc = 'Identity Verification';
  static const kycStatus = 'Verification Status';
  static const kycUpgrade = 'Upgrade Account';
  static const kycPending = 'Verification Pending';
  static const kycApproved = 'Verified';
  static const kycRejected = 'Verification Rejected';

  // Limits
  static const limits = 'Transaction Limits';
  static const dailyLimit = 'Daily Limit';
  static const monthlyLimit = 'Monthly Limit';
  static const perTransactionLimit = 'Per Transaction';

  // Support
  static const help = 'Help & Support';
  static const about = 'About Korido';
  static const privacyPolicy = 'Privacy Policy';
  static const termsOfService = 'Terms of Service';
  static const cookiePolicy = 'Cookie Policy';
  static const version = 'Version';

  // Account
  static const deleteAccount = 'Delete Account';
  static const deleteAccountWarning = 'This action is permanent and cannot be undone. All your data will be removed.';
  static const exportData = 'Export My Data';
}
