import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_service.dart';
import '../user/user_service.dart';
import '../wallet/wallet_service.dart';
import '../transactions/transactions_service.dart';
import '../transfers/transfers_service.dart';
import '../notifications/notifications_service.dart';
import '../referrals/referrals_service.dart';

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

  const UsdcWalletSdk({
    required this.auth,
    required this.user,
    required this.wallet,
    required this.transactions,
    required this.transfers,
    required this.notifications,
    required this.referrals,
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
  );
});
