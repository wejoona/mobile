/// App-wide constants

const String appName = 'Korido';
const String appTagline = 'Send money. Instantly.';
const String appWebsite = 'https://korido.app';
const String supportEmail = 'support@korido.app';

/// API configuration
const Duration apiTimeout = Duration(seconds: 30);
const Duration apiConnectTimeout = Duration(seconds: 10);
const int apiMaxRetries = 2;

/// PIN configuration
const int pinLength = 4;
const int maxPinAttempts = 3;
const Duration pinLockoutDuration = Duration(minutes: 15);
const Duration pinTokenValidity = Duration(minutes: 5);

/// Cache durations
const Duration cacheBalanceDuration = Duration(seconds: 30);
const Duration cacheProfileDuration = Duration(minutes: 5);
const Duration cacheTransactionsDuration = Duration(minutes: 2);
const Duration cacheContactsDuration = Duration(minutes: 10);

/// Animation durations
const Duration animFast = Duration(milliseconds: 200);
const Duration animNormal = Duration(milliseconds: 350);
const Duration animSlow = Duration(milliseconds: 500);

/// Pagination defaults
const int defaultPageSize = 20;
const int maxPageSize = 100;

/// Feature flags (client-side defaults)
const bool enableBiometric = true;
const bool enableQrPayments = true;
const bool enableBillPayments = true;
const bool enableSavingsPots = true;
