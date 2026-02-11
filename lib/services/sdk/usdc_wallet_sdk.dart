import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/services/transactions/transactions_service.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';
import 'package:usdc_wallet/services/notifications/notifications_service.dart';
import 'package:usdc_wallet/services/referrals/referrals_service.dart';
import 'package:usdc_wallet/services/beneficiaries/beneficiaries_service.dart';
import 'package:usdc_wallet/services/kyc/kyc_service.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/services/recurring_transfers/recurring_transfers_service.dart';
import 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/services/bank_linking/bank_linking_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// USDC Wallet SDK
///
/// Unified entry point for all API services.
/// Mirrors the backend API structure for clean, consistent access.
///
/// Usage:
/// ```dart
/// final sdk = ref.read(sdkProvider);
///
/// // Auth
/// await sdk.auth.login(phone: '+2250700000000');
/// await sdk.auth.verifyOtp(phone: phone, otp: '123456');
///
/// // Wallet
/// final balance = await sdk.wallet.getBalance();
/// await sdk.wallet.initiateDeposit(amount: 50000, ...);
///
/// // Transfers
/// await sdk.transfers.createInternalTransfer(recipientPhone: phone, amount: 100);
/// await sdk.transfers.createExternalTransfer(recipientAddress: '0x...', amount: 100);
///
/// // Transactions
/// final history = await sdk.transactions.getTransactions();
///
/// // User
/// final profile = await sdk.user.getProfile();
///
/// // Notifications
/// final notifications = await sdk.notifications.getNotifications();
///
/// // Referrals
/// final code = await sdk.referrals.getReferralCode();
///
/// // Deposits
/// final depositResponse = await sdk.deposits.initiateDeposit(...);
///
/// // Recurring Transfers
/// final recurring = await sdk.recurringTransfers.getRecurringTransfers();
///
/// // Bulk Payments
/// final batches = await sdk.bulkPayments.getBatches();
///
/// // Cards
/// final cards = await sdk.cards.getCards();
///
/// // Bank Linking
/// final accounts = await sdk.bankLinking.getLinkedAccounts();
/// ```
class UsdcWalletSdk {
  /// Authentication service
  /// - register, login, verifyOtp
  final AuthService auth;

  /// User profile service
  /// - getProfile, updateProfile
  final UserService user;

  /// Wallet service
  /// - getBalance, initiateDeposit, getRate
  /// - getKycStatus, submitKyc
  /// - internalTransfer, externalTransfer (legacy, prefer transfers service)
  final WalletService wallet;

  /// Transactions service
  /// - getTransactions, getTransaction
  /// - getDepositStatus
  final TransactionsService transactions;

  /// Transfers service
  /// - createInternalTransfer, createExternalTransfer
  /// - getTransfers, getTransfer
  final TransfersService transfers;

  /// Notifications service
  /// - getNotifications, getUnreadCount
  /// - markAsRead, markAllAsRead
  /// - registerDeviceToken, removeDeviceToken
  final NotificationsService notifications;

  /// Referrals service
  /// - getReferralCode, getStats, getHistory
  /// - applyReferralCode, getLeaderboard
  final ReferralsService referrals;

  /// Beneficiaries service
  /// - getBeneficiaries, createBeneficiary
  /// - updateBeneficiary, deleteBeneficiary, toggleFavorite
  final BeneficiariesService beneficiaries;

  /// KYC service
  /// - submitKyc, getKycStatus
  final KycService kyc;

  /// Deposit service
  /// - initiateDeposit, getDepositStatus, getExchangeRate
  final DepositService deposits;

  /// Recurring Transfers service
  /// - getRecurringTransfers, createRecurringTransfer
  /// - pauseRecurringTransfer, resumeRecurringTransfer
  final RecurringTransfersService recurringTransfers;

  /// Bulk Payments service
  /// - getBatches, submitBatch, getBatchStatus
  final BulkPaymentsService bulkPayments;

  /// Cards service
  /// - getCards, createCard, freezeCard, updateSpendingLimit
  final CardsService cards;

  /// Bank Linking service
  /// - getBanks, linkBankAccount, getLinkedAccounts
  /// - depositFromBank, withdrawToBank
  final BankLinkingService bankLinking;

  const UsdcWalletSdk({
    required this.auth,
    required this.user,
    required this.wallet,
    required this.transactions,
    required this.transfers,
    required this.notifications,
    required this.referrals,
    required this.beneficiaries,
    required this.kyc,
    required this.deposits,
    required this.recurringTransfers,
    required this.bulkPayments,
    required this.cards,
    required this.bankLinking,
  });
}

/// SDK Provider
///
/// Provides a single instance of UsdcWalletSdk with all services initialized.
/// All services share the same Dio instance with auth interceptor.
final sdkProvider = Provider<UsdcWalletSdk>((ref) {
  return UsdcWalletSdk(
    auth: ref.watch(authServiceProvider),
    user: ref.watch(userServiceProvider),
    wallet: ref.watch(walletServiceProvider),
    transactions: ref.watch(transactionsServiceProvider),
    transfers: ref.watch(transfersServiceProvider),
    notifications: ref.watch(notificationsServiceProvider),
    referrals: ref.watch(referralsServiceProvider),
    beneficiaries: ref.watch(beneficiariesServiceProvider),
    kyc: ref.watch(kycServiceProvider),
    deposits: ref.watch(depositServiceProvider),
    recurringTransfers: ref.watch(recurringTransfersServiceProvider),
    bulkPayments: ref.watch(bulkPaymentsServiceProvider),
    cards: ref.watch(cardsServiceProvider),
    bankLinking: ref.watch(bankLinkingServiceProvider),
  );
});

/// KYC Service Provider
final kycServiceProvider = Provider<KycService>((ref) {
  final dio = ref.watch(dioProvider);
  return KycService(dio);
});

/// Deposit Service Provider
final depositServiceProvider = Provider<DepositService>((ref) {
  final dio = ref.watch(dioProvider);
  return DepositService(dio);
});

/// Recurring Transfers Service Provider
final recurringTransfersServiceProvider = Provider<RecurringTransfersService>((ref) {
  final dio = ref.watch(dioProvider);
  return RecurringTransfersService(dio);
});

/// Bulk Payments Service Provider
final bulkPaymentsServiceProvider = Provider<BulkPaymentsService>((ref) {
  final dio = ref.watch(dioProvider);
  return BulkPaymentsService(dio);
});

/// Cards Service Provider
final cardsServiceProvider = Provider<CardsService>((ref) {
  final dio = ref.watch(dioProvider);
  return CardsService(dio);
});

/// Bank Linking Service Provider
final bankLinkingServiceProvider = Provider<BankLinkingService>((ref) {
  final dio = ref.watch(dioProvider);
  return BankLinkingService(dio);
});
