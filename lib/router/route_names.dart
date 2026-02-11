/// Centralized route name constants for GoRouter navigation.
/// Prevents hardcoded route strings throughout the app.
library;

abstract final class RouteNames {
  // Root
  static const splash = 'splash';
  static const home = 'home';

  // Auth
  static const login = 'login';
  static const loginOtp = 'login-otp';
  static const loginPin = 'login-pin';
  static const otp = 'otp';

  // Onboarding
  static const onboarding = 'onboarding';
  static const welcome = 'welcome';
  static const phoneInput = 'phone-input';
  static const otpVerification = 'otp-verification';
  static const profileSetup = 'profile-setup';
  static const createPin = 'create-pin';
  static const confirmPin = 'confirm-pin';
  static const onboardingSuccess = 'onboarding-success';
  static const kycPrompt = 'kyc-prompt';
  static const firstDeposit = 'first-deposit';

  // Wallet
  static const wallet = 'wallet';
  static const send = 'send';
  static const sendAmount = 'send-amount';
  static const sendConfirm = 'send-confirm';
  static const sendResult = 'send-result';
  static const sendExternal = 'send-external';
  static const receive = 'receive';
  static const deposit = 'deposit';
  static const depositAmount = 'deposit-amount';
  static const depositProvider = 'deposit-provider';
  static const depositInstructions = 'deposit-instructions';
  static const depositStatus = 'deposit-status';
  static const withdraw = 'withdraw';
  static const scan = 'scan';
  static const requestMoney = 'request-money';

  // Transactions
  static const transactions = 'transactions';
  static const transactionDetail = 'transaction-detail';
  static const exportTransactions = 'export-transactions';

  // Cards
  static const cards = 'cards';
  static const cardDetail = 'card-detail';
  static const requestCard = 'request-card';
  static const cardSettings = 'card-settings';
  static const cardTransactions = 'card-transactions';

  // Bill Payments
  static const billPayments = 'bill-payments';
  static const billPayCategory = 'bill-pay-category';
  static const billPayProvider = 'bill-pay-provider';
  static const billPayConfirm = 'bill-pay-confirm';

  // Savings Pots
  static const savingsPots = 'savings-pots';
  static const createPot = 'create-pot';
  static const potDetail = 'pot-detail';
  static const editPot = 'edit-pot';

  // Payment Links
  static const paymentLinks = 'payment-links';
  static const createPaymentLink = 'create-payment-link';
  static const paymentLinkDetail = 'payment-link-detail';
  static const payLink = 'pay-link';

  // Recurring Transfers
  static const recurringTransfers = 'recurring-transfers';
  static const createRecurring = 'create-recurring';
  static const recurringDetail = 'recurring-detail';

  // KYC
  static const kyc = 'kyc';
  static const kycStatus = 'kyc-status';
  static const kycDocumentType = 'kyc-document-type';
  static const kycDocumentCapture = 'kyc-document-capture';
  static const kycPersonalInfo = 'kyc-personal-info';
  static const kycAddress = 'kyc-address';
  static const kycSelfie = 'kyc-selfie';
  static const kycLiveness = 'kyc-liveness';
  static const kycReview = 'kyc-review';
  static const kycSubmitted = 'kyc-submitted';
  static const kycUpgrade = 'kyc-upgrade';

  // Settings
  static const settings = 'settings';
  static const profile = 'profile';
  static const editProfile = 'edit-profile';
  static const security = 'security';
  static const changePin = 'change-pin';
  static const biometric = 'biometric';
  static const biometricEnrollment = 'biometric-enrollment';
  static const notificationSettings = 'notification-settings';
  static const language = 'language';
  static const theme = 'theme';
  static const currency = 'currency';
  static const devices = 'devices';
  static const sessions = 'sessions';
  static const limits = 'limits';
  static const help = 'help';
  static const about = 'about';
  static const deleteAccount = 'delete-account';
  static const exportData = 'export-data';
  static const cookiePolicy = 'cookie-policy';

  // Features
  static const beneficiaries = 'beneficiaries';
  static const addBeneficiary = 'add-beneficiary';
  static const bankAccounts = 'bank-accounts';
  static const linkBank = 'link-bank';
  static const referrals = 'referrals';
  static const notifications = 'notifications';
  static const insights = 'insights';
  static const expenses = 'expenses';
  static const contacts = 'contacts';
  static const bulkPayments = 'bulk-payments';
  static const merchantPay = 'merchant-pay';
  static const subBusinesses = 'sub-businesses';
  static const qrReceive = 'qr-receive';
  static const qrScan = 'qr-scan';
  static const receipt = 'receipt';
  static const alerts = 'alerts';

  // Pin
  static const enterPin = 'enter-pin';
  static const setPin = 'set-pin';
  static const resetPin = 'reset-pin';

  // Debug (dev only)
  static const debug = 'debug';
  static const featureFlagsDebug = 'feature-flags-debug';
  static const networkInspector = 'network-inspector';
  static const mockData = 'mock-data';
}
