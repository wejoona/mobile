/// Centralized API endpoint constants.
/// Prevents typos and enables easy endpoint discovery.
library;

abstract final class ApiEndpoints {
  // Auth
  static const authLogin = '/auth/login';
  static const authVerifyOtp = '/auth/verify-otp';
  static const authRefresh = '/auth/refresh';
  static const authLogout = '/auth/logout';
  static const authRegister = '/auth/register';

  // User
  static const userProfile = '/user/profile';
  static const userUpdate = '/user/profile';
  static const userDelete = '/user/account';
  static const userExportData = '/user/export';

  // Wallet
  static const walletBalance = '/wallet/balance';
  static const walletAddress = '/wallet/address';
  static const walletTransactions = '/wallet/transactions';

  // Transfers
  static const transfersSend = '/transfers/send';
  static const transfersEstimateFee = '/transfers/estimate-fee';
  static const transfersExternal = '/transfers/external';

  // Deposit
  static const depositInitiate = '/deposit/initiate';
  static const depositStatus = '/deposit/status';
  static const depositProviders = '/deposit/providers';
  static const depositHistory = '/deposit/history';

  // Withdraw
  static const withdrawInitiate = '/withdraw/initiate';
  static const withdrawStatus = '/withdraw/status';

  // Cards
  static const cards = '/cards';
  static String cardById(String id) => '/cards/$id';
  static String cardFreeze(String id) => '/cards/$id/freeze';
  static String cardUnfreeze(String id) => '/cards/$id/unfreeze';
  static String cardTransactions(String id) => '/cards/$id/transactions';

  // Bill Payments
  static const billProviders = '/bill-payments/providers';
  static const billCategories = '/bill-payments/categories';
  static const billValidate = '/bill-payments/validate';
  static const billPay = '/bill-payments/pay';
  static const billHistory = '/bill-payments/history';
  static String billReceipt(String id) => '/bill-payments/$id/receipt';

  // Payment Links
  static const paymentLinks = '/payment-links';
  static String paymentLinkById(String id) => '/payment-links/$id';
  static String paymentLinkPay(String id) => '/payment-links/$id/pay';
  static String paymentLinkDeactivate(String id) => '/payment-links/$id/deactivate';

  // Savings Pots
  static const savingsPots = '/savings-pots';
  static String savingsPotById(String id) => '/savings-pots/$id';
  static String savingsPotDeposit(String id) => '/savings-pots/$id/deposit';
  static String savingsPotWithdraw(String id) => '/savings-pots/$id/withdraw';

  // Recurring Transfers
  static const recurringTransfers = '/recurring-transfers';
  static String recurringTransferById(String id) => '/recurring-transfers/$id';
  static String recurringTransferPause(String id) => '/recurring-transfers/$id/pause';
  static String recurringTransferResume(String id) => '/recurring-transfers/$id/resume';

  // KYC
  static const kycStatus = '/kyc/status';
  static const kycSubmit = '/kyc/submit';
  static const kycUpload = '/kyc/upload';

  // Beneficiaries
  static const beneficiaries = '/beneficiaries';
  static String beneficiaryById(String id) => '/beneficiaries/$id';

  // Referrals
  static const referrals = '/referrals';
  static const referralCode = '/referrals/code';
  static const referralLeaderboard = '/referrals/leaderboard';

  // Bank Linking
  static const bankAccounts = '/bank-accounts';
  static String bankAccountById(String id) => '/bank-accounts/$id';
  static const banksList = '/banks';

  // Bulk Payments
  static const bulkPayments = '/bulk-payments';
  static String bulkPaymentById(String id) => '/bulk-payments/$id';

  // Sub-businesses
  static const subBusinesses = '/sub-businesses';
  static String subBusinessById(String id) => '/sub-businesses/$id';
  static String subBusinessStaff(String id) => '/sub-businesses/$id/staff';

  // Expenses
  static const expenses = '/expenses';
  static String expenseById(String id) => '/expenses/$id';
  static const expenseCategories = '/expenses/categories';
  static const expenseReport = '/expenses/report';

  // Notifications
  static const notifications = '/notifications';
  static String notificationById(String id) => '/notifications/$id';
  static const notificationPreferences = '/notifications/preferences';

  // Limits
  static const limits = '/limits';

  // Insights
  static const insights = '/insights';
  static const insightsSummary = '/insights/summary';
  static const insightsCategories = '/insights/categories';
  static const insightsRecipients = '/insights/top-recipients';
  static const insightsTrend = '/insights/trend';

  // Contacts
  static const contacts = '/contacts';
  static const contactsSync = '/contacts/sync';

  // Merchant Pay
  static const merchantPayments = '/merchant/payments';
  static const merchantQr = '/merchant/qr';
  static const merchantDashboard = '/merchant/dashboard';
}
