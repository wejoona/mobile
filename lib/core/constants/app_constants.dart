/// Application-wide constants.
class AppConstants {
  AppConstants._();

  // App info
  static const appName = 'Korido';
  static const appTagline = 'Send money, simplified';
  static const defaultCurrency = 'USDC';
  static const defaultCountryCode = '+225';
  static const defaultLocale = 'fr';

  // Timeouts
  static const apiTimeoutMs = 30000;
  static const connectionTimeoutMs = 15000;
  static const uploadTimeoutMs = 60000;

  // Limits
  static const maxPinAttempts = 5;
  static const pinLockoutMinutes = 30;
  static const otpLength = 6;
  static const pinLength = 4;
  static const maxTransferNote = 200;
  static const maxBulkPaymentItems = 100;
  static const maxFileUploadMb = 10;

  // Cache TTLs
  static const balanceCacheTtlSeconds = 30;
  static const transactionsCacheTtlSeconds = 60;
  static const contactsCacheTtlSeconds = 300;
  static const profileCacheTtlSeconds = 600;

  // Retry
  static const maxRetries = 2;
  static const retryBaseDelayMs = 1000;
  static const retryMaxDelayMs = 5000;

  // UI
  static const animationDurationFast = Duration(milliseconds: 150);
  static const animationDurationNormal = Duration(milliseconds: 300);
  static const animationDurationSlow = Duration(milliseconds: 600);
  static const bottomSheetRadius = 16.0;
  static const cardRadius = 12.0;
  static const inputRadius = 12.0;
  static const pageHorizontalPadding = 16.0;

  // Feature flags
  static const enableBiometric = true;
  static const enableQrPayments = true;
  static const enableBulkPayments = true;
  static const enableRecurringTransfers = true;
  static const enableCards = true;

  // Supported currencies
  static const supportedCurrencies = ['USDC', 'XOF', 'USD'];

  // UEMOA countries
  static const uemoaCountries = [
    'CI', 'SN', 'ML', 'BF', 'NE', 'TG', 'BJ', 'GW',
  ];
}
