/// Centralized API endpoint constants.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verifyOtp = '/auth/verify-otp';
  static const refreshToken = '/auth/refresh';
  static const logout = '/auth/logout';

  // User
  static const userProfile = '/user/profile';
  static const userAvatar = '/user/avatar';
  static const userLocale = '/user/locale';
  static const userLimits = '/user/limits';

  // PIN
  static const pinSet = '/user/pin/set';
  static const pinVerify = '/user/pin/verify';
  static const pinChange = '/user/pin/change';

  // Wallet
  static const walletBalance = '/wallet/balance';
  static const walletTransactions = '/wallet/transactions';
  static const transactionStats = '/wallet/transactions/stats';

  // Transfers
  static const transferInternal = '/transfers/internal';
  static const transferExternal = '/transfers/external';

  // Contacts
  static const contacts = '/contacts';
  static const contactsSync = '/contacts/sync';
  static const contactInvite = '/contacts/invite';

  // Cards
  static const cards = '/cards';

  // Savings
  static const savingsPots = '/savings-pots';

  // Payment Links
  static const paymentLinks = '/payment-links';

  // Recurring Transfers
  static const recurringTransfers = '/recurring-transfers';

  // Bank Accounts
  static const bankAccounts = '/bank-accounts';

  // Deposits
  static const deposits = '/deposit';
  static const depositInitiate = '/deposit/initiate';
  static const depositConfirm = '/deposit/confirm';

  // Bill Payments
  static const billPayments = '/bill-payments';

  // Bulk Payments
  static const bulkPayments = '/bulk-payments';

  // KYC
  static const kycStatus = '/kyc/status';
  static const kycSubmitBasic = '/kyc/submit/basic';
  static const kycSubmitDocument = '/kyc/submit/document';
  static const kycSubmitSelfie = '/kyc/submit/selfie';

  // Devices
  static const devices = '/devices';
  static const deviceRegister = '/devices/register';

  // Sessions
  static const sessions = '/sessions';

  // Referrals
  static const referrals = '/referrals';

  // Notifications
  static const notifications = '/notifications';
  static const notificationPreferences = '/notifications/preferences';

  // Health
  static const healthCheck = '/health';
  static const healthTime = '/health/time';
  static const healthVersion = '/health/version';

  // Whitelisted Addresses
  static const whitelistedAddresses = '/whitelisted-addresses';
}
