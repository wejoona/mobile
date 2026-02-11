/// Centralized route names to avoid string duplication.
class RouteNames {
  RouteNames._();

  // Auth
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const otpVerification = '/otp';
  static const pinSetup = '/pin/setup';

  // Main tabs
  static const home = '/home';
  static const wallet = '/wallet';
  static const activity = '/activity';
  static const profile = '/profile';

  // Send money
  static const send = '/send';
  static const sendAmount = '/send/amount';
  static const sendConfirm = '/send/confirm';
  static const sendResult = '/send/result';

  // Deposit
  static const deposit = '/deposit';
  static const depositMethod = '/deposit/method';

  // Cards
  static const cards = '/cards';
  static const cardDetail = '/cards/detail';
  static const cardSettings = '/cards/settings';

  // Savings
  static const savingsPots = '/savings';
  static const savingsPotDetail = '/savings/detail';
  static const createSavingsPot = '/savings/create';

  // Payment links
  static const paymentLinks = '/payment-links';
  static const createPaymentLink = '/payment-links/create';

  // Recurring transfers
  static const recurringTransfers = '/recurring';
  static const createRecurringTransfer = '/recurring/create';

  // Bank linking
  static const bankAccounts = '/bank-accounts';
  static const linkBankAccount = '/bank-accounts/link';

  // KYC
  static const kyc = '/kyc';
  static const kycDocument = '/kyc/document';
  static const kycSelfie = '/kyc/selfie';

  // Settings
  static const settings = '/settings';
  static const settingsDevices = '/settings/devices';
  static const settingsSecurity = '/settings/security';
  static const settingsNotifications = '/settings/notifications';
  static const settingsLanguage = '/settings/language';
  static const settingsTheme = '/settings/theme';

  // Misc
  static const qrScanner = '/qr/scan';
  static const qrDisplay = '/qr/display';
  static const transactionDetail = '/transaction';
  static const contacts = '/contacts';
  static const notifications = '/notifications';
  static const referrals = '/referrals';
  static const insights = '/insights';
  static const limits = '/limits';
  static const billPayments = '/bills';
  static const bulkPayments = '/bulk';
}
