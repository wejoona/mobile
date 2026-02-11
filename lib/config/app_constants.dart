/// Application-wide constants for Korido.
class AppConstants {
  const AppConstants._();

  /// Application name.
  static const String appName = 'Korido';

  /// Default currency.
  static const String defaultCurrency = 'USDC';

  /// Default local currency for West Africa.
  static const String defaultLocalCurrency = 'XOF';

  /// Minimum transfer amount in USDC.
  static const double minTransferAmount = 0.01;

  /// Maximum transfer amount in USDC (before KYC).
  static const double maxTransferAmountBasic = 500.0;

  /// Maximum transfer amount in USDC (after KYC).
  static const double maxTransferAmountVerified = 10000.0;

  /// PIN length.
  static const int pinLength = 6;

  /// OTP length.
  static const int otpLength = 6;

  /// OTP expiry in seconds.
  static const int otpExpiry = 120;

  /// Maximum recent transactions to show on home.
  static const int maxRecentTransactions = 5;

  /// Maximum recent beneficiaries to show.
  static const int maxRecentBeneficiaries = 10;

  /// Session timeout in minutes.
  static const int sessionTimeout = 30;

  /// Support email.
  static const String supportEmail = 'support@korido.app';

  /// Support phone (West Africa).
  static const String supportPhone = '+225 XX XX XX XX XX';

  /// Terms of service URL.
  static const String termsUrl = 'https://korido.app/terms';

  /// Privacy policy URL.
  static const String privacyUrl = 'https://korido.app/privacy';
}
