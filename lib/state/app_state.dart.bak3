import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/index.dart';
import '../domain/enums/index.dart';

/// Navigation Tab State
enum NavTab {
  wallet,
  activity,
  services,
  settings,
}

extension NavTabExt on NavTab {
  String get route {
    switch (this) {
      case NavTab.wallet:
        return '/home';
      case NavTab.activity:
        return '/transactions';
      case NavTab.services:
        return '/services';
      case NavTab.settings:
        return '/settings';
    }
  }

  int get index {
    switch (this) {
      case NavTab.wallet:
        return 0;
      case NavTab.activity:
        return 1;
      case NavTab.services:
        return 2;
      case NavTab.settings:
        return 3;
    }
  }

  static NavTab fromIndex(int index) {
    switch (index) {
      case 0:
        return NavTab.wallet;
      case 1:
        return NavTab.activity;
      case 2:
        return NavTab.services;
      case 3:
        return NavTab.settings;
      default:
        return NavTab.wallet;
    }
  }

  static NavTab fromRoute(String route) {
    if (route.startsWith('/home')) return NavTab.wallet;
    if (route.startsWith('/transactions')) return NavTab.activity;
    if (route.startsWith('/services')) return NavTab.services;
    if (route.startsWith('/settings')) return NavTab.settings;
    return NavTab.wallet;
  }
}

/// Navigation State Machine
class NavigationState {
  final NavTab currentTab;
  final String? subRoute;
  final bool isInFullScreenMode;

  const NavigationState({
    this.currentTab = NavTab.wallet,
    this.subRoute,
    this.isInFullScreenMode = false,
  });

  NavigationState copyWith({
    NavTab? currentTab,
    String? subRoute,
    bool? isInFullScreenMode,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      subRoute: subRoute,
      isInFullScreenMode: isInFullScreenMode ?? this.isInFullScreenMode,
    );
  }
}

class NavigationNotifier extends Notifier<NavigationState> {
  @override
  NavigationState build() => const NavigationState();

  void setTab(NavTab tab) {
    state = state.copyWith(currentTab: tab, isInFullScreenMode: false);
  }

  void setTabFromIndex(int index) {
    setTab(NavTabExt.fromIndex(index));
  }

  void setTabFromRoute(String route) {
    final tab = NavTabExt.fromRoute(route);
    final isFullScreen = _isFullScreenRoute(route);
    state = state.copyWith(
      currentTab: tab,
      subRoute: route,
      isInFullScreenMode: isFullScreen,
    );
  }

  void enterFullScreen(String route) {
    state = state.copyWith(subRoute: route, isInFullScreenMode: true);
  }

  void exitFullScreen() {
    state = state.copyWith(isInFullScreenMode: false, subRoute: null);
  }

  bool _isFullScreenRoute(String route) {
    const fullScreenRoutes = [
      '/deposit',
      '/send',
      '/withdraw',
      '/scan',
      '/notifications',
    ];
    return fullScreenRoutes.any((r) => route.startsWith(r));
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationState>(
  NavigationNotifier.new,
);

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
    this.blockchain = 'MATIC',
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
