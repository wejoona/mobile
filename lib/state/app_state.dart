import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';

/// Wallet Balance State Machine
enum WalletStatus {
  initial,
  loading,
  loaded,
  error,
  refreshing,
}

class WalletState {
  final WalletStatus status;
  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final double usdBalance;
  final double usdcBalance;
  final double pendingBalance;
  final String? error;
  final DateTime? lastUpdated;

  const WalletState({
    this.status = WalletStatus.initial,
    this.walletId = '',
    this.walletAddress,
    this.blockchain = 'polygon',
    this.usdBalance = 0,
    this.usdcBalance = 0,
    this.pendingBalance = 0,
    this.error,
    this.lastUpdated,
  });

  double get totalBalance => usdBalance + usdcBalance;
  double get availableBalance => usdBalance;

  bool get isLoading =>
      status == WalletStatus.loading || status == WalletStatus.refreshing;
  bool get hasError => status == WalletStatus.error;
  bool get isLoaded => status == WalletStatus.loaded;
  bool get hasWallet => walletId.isNotEmpty && status == WalletStatus.loaded;
  bool get hasWalletAddress => walletAddress != null && walletAddress!.isNotEmpty;

  /// Short display version of wallet address
  String get shortAddress {
    if (walletAddress == null || walletAddress!.length < 12) {
      return walletAddress ?? '';
    }
    return '${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 4)}';
  }

  WalletState copyWith({
    WalletStatus? status,
    String? walletId,
    String? walletAddress,
    String? blockchain,
    double? usdBalance,
    double? usdcBalance,
    double? pendingBalance,
    String? error,
    DateTime? lastUpdated,
  }) {
    return WalletState(
      status: status ?? this.status,
      walletId: walletId ?? this.walletId,
      walletAddress: walletAddress ?? this.walletAddress,
      blockchain: blockchain ?? this.blockchain,
      usdBalance: usdBalance ?? this.usdBalance,
      usdcBalance: usdcBalance ?? this.usdcBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// User/Auth State Machine
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpSent,
  error,
}

class UserState {
  final AuthStatus status;
  final String? userId;
  final String? phone;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? avatarUrl;
  final String countryCode;
  final KycStatus kycStatus;
  final bool canTransact;
  final bool canWithdraw;
  final String? accessToken;
  final String? error;

  const UserState({
    this.status = AuthStatus.initial,
    this.userId,
    this.phone,
    this.firstName,
    this.lastName,
    this.email,
    this.avatarUrl,
    this.countryCode = 'CI',
    this.kycStatus = KycStatus.none,
    this.canTransact = false,
    this.canWithdraw = false,
    this.accessToken,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
  String get displayName =>
      firstName != null ? '$firstName ${lastName ?? ''}' : phone ?? 'User';

  UserState copyWith({
    AuthStatus? status,
    String? userId,
    String? phone,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? countryCode,
    KycStatus? kycStatus,
    bool? canTransact,
    bool? canWithdraw,
    String? accessToken,
    String? error,
  }) {
    return UserState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      phone: phone ?? this.phone,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      countryCode: countryCode ?? this.countryCode,
      kycStatus: kycStatus ?? this.kycStatus,
      canTransact: canTransact ?? this.canTransact,
      canWithdraw: canWithdraw ?? this.canWithdraw,
      accessToken: accessToken ?? this.accessToken,
      error: error,
    );
  }
}

/// Transaction State Machine
enum TransactionListStatus {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  refreshing,
}

class TransactionListState {
  final TransactionListStatus status;
  final List<Transaction> transactions;
  final int total;
  final int page;
  final bool hasMore;
  final String? error;

  const TransactionListState({
    this.status = TransactionListStatus.initial,
    this.transactions = const [],
    this.total = 0,
    this.page = 1,
    this.hasMore = false,
    this.error,
  });

  bool get isLoading =>
      status == TransactionListStatus.loading ||
      status == TransactionListStatus.refreshing;

  bool get isLoadingMore => status == TransactionListStatus.loadingMore;

  TransactionListState copyWith({
    TransactionListStatus? status,
    List<Transaction>? transactions,
    int? total,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      total: total ?? this.total,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

/// Notification State
class NotificationState {
  final int unreadCount;
  final List<dynamic> notifications;
  final bool hasNewNotifications;

  const NotificationState({
    this.unreadCount = 0,
    this.notifications = const [],
    this.hasNewNotifications = false,
  });

  NotificationState copyWith({
    int? unreadCount,
    List<dynamic>? notifications,
    bool? hasNewNotifications,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      notifications: notifications ?? this.notifications,
      hasNewNotifications: hasNewNotifications ?? this.hasNewNotifications,
    );
  }
}
