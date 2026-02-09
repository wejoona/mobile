import 'package:usdc_wallet/state/fsm/fsm_base.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │                        WALLET FSM                                │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  ┌──────────────┐     FETCH      ┌──────────────┐               │
/// │  │              │ ──────────────▶│              │               │
/// │  │    None      │                │   Loading    │               │
/// │  │              │                │              │               │
/// │  └──────────────┘                └──────┬───────┘               │
/// │         ▲                               │                        │
/// │         │                     ┌─────────┼─────────┐             │
/// │       RESET                   │         │         │             │
/// │         │              NOT_FOUND     LOADED     FAIL            │
/// │         │                   │         │         │               │
/// │         │                   ▼         ▼         ▼               │
/// │         │            ┌──────────┐ ┌──────┐ ┌───────┐            │
/// │         │            │NotCreated│ │Ready │ │ Error │            │
/// │         │            └────┬─────┘ └──┬───┘ └───────┘            │
/// │         │                 │          │                          │
/// │         │              CREATE     REFRESH                       │
/// │         │                 │          │                          │
/// │         │                 ▼          │                          │
/// │         │            ┌──────────┐    │                          │
/// │         │            │ Creating │    │                          │
/// │         │            └────┬─────┘    │                          │
/// │         │                 │          │                          │
/// │         │              SUCCESS       │                          │
/// │         │                 │          │                          │
/// │         │                 ▼          │                          │
/// │         └─────────────┌──────────┐◀──┘                          │
/// │                       │  Ready   │                              │
/// │                       │          │──▶ REFRESH ──▶ Loading       │
/// │                       └──────────┘                              │
/// │                                                                  │
/// │  GLOBAL: RESET ──▶ None                                         │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

// ═══════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════

sealed class WalletState extends FsmState {
  const WalletState();

  /// Whether the wallet is ready for transactions
  bool get canTransact => false;
}

/// Initial state - no wallet data
class WalletNone extends WalletState {
  const WalletNone();

  @override
  String get name => 'NONE';
}

/// Loading wallet data from API
class WalletLoading extends WalletState {
  const WalletLoading({this.isRefresh = false});

  final bool isRefresh;

  @override
  String get name => isRefresh ? 'REFRESHING' : 'LOADING';

  @override
  bool get isTransitioning => true;
}

/// User doesn't have a wallet yet - needs to create one
class WalletNotCreated extends WalletState {
  const WalletNotCreated();

  @override
  String get name => 'NOT_CREATED';
}

/// Creating a new wallet
class WalletCreating extends WalletState {
  const WalletCreating();

  @override
  String get name => 'CREATING';

  @override
  bool get isTransitioning => true;
}

/// Wallet is ready for use
class WalletReady extends WalletState {
  const WalletReady({
    required this.walletId,
    this.walletAddress,
    this.blockchain = 'polygon',
    required this.usdcBalance,
    this.pendingBalance = 0,
    required this.lastUpdated,
  });

  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final double usdcBalance;
  final double pendingBalance;
  final DateTime lastUpdated;

  @override
  String get name => 'READY';

  @override
  bool get canTransact => true;

  double get totalBalance => usdcBalance + pendingBalance;

  String get shortAddress {
    if (walletAddress == null || walletAddress!.length < 12) {
      return walletAddress ?? '';
    }
    return '${walletAddress!.substring(0, 6)}...${walletAddress!.substring(walletAddress!.length - 4)}';
  }

  WalletReady copyWith({
    String? walletId,
    String? walletAddress,
    String? blockchain,
    double? usdcBalance,
    double? pendingBalance,
    DateTime? lastUpdated,
  }) {
    return WalletReady(
      walletId: walletId ?? this.walletId,
      walletAddress: walletAddress ?? this.walletAddress,
      blockchain: blockchain ?? this.blockchain,
      usdcBalance: usdcBalance ?? this.usdcBalance,
      pendingBalance: pendingBalance ?? this.pendingBalance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// Wallet frozen by compliance
class WalletFrozen extends WalletState {
  const WalletFrozen({
    required this.walletId,
    required this.reason,
    required this.frozenAt,
    this.frozenUntil,
  });

  final String walletId;
  final String reason;
  final DateTime frozenAt;
  final DateTime? frozenUntil;

  @override
  String get name => 'FROZEN';

  bool get isPermanent => frozenUntil == null;
}

/// Wallet under compliance review
class WalletUnderReview extends WalletState {
  const WalletUnderReview({
    required this.walletId,
    required this.reason,
    required this.reviewStartedAt,
  });

  final String walletId;
  final String reason;
  final DateTime reviewStartedAt;

  @override
  String get name => 'UNDER_REVIEW';
}

/// Wallet has transaction limits
class WalletLimited extends WalletState {
  const WalletLimited({
    required this.walletId,
    this.walletAddress,
    this.blockchain = 'polygon',
    required this.usdcBalance,
    this.pendingBalance = 0,
    required this.lastUpdated,
    required this.limitReason,
    this.maxTransactionAmount,
    this.dailyLimit,
  });

  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final double usdcBalance;
  final double pendingBalance;
  final DateTime lastUpdated;
  final String limitReason;
  final double? maxTransactionAmount;
  final double? dailyLimit;

  @override
  String get name => 'LIMITED';

  @override
  bool get canTransact => true; // Can transact but with limits

  double get totalBalance => usdcBalance + pendingBalance;
}

/// Error loading or creating wallet
class WalletError extends WalletState with FsmStateError {
  const WalletError({
    required this.errorMessage,
    this.errorData,
    required this.previousState,
  });

  @override
  final String errorMessage;
  @override
  final dynamic errorData;
  final WalletState previousState;

  @override
  String get name => 'ERROR';
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════

sealed class WalletEvent extends FsmEvent {
  const WalletEvent();
}

/// Fetch wallet data
class WalletFetch extends WalletEvent {
  const WalletFetch();

  @override
  String get name => 'FETCH';
}

/// Refresh wallet data (keeps showing old data while loading)
class WalletRefresh extends WalletEvent {
  const WalletRefresh();

  @override
  String get name => 'REFRESH';
}

/// Wallet data loaded successfully
class WalletLoaded extends WalletEvent {
  const WalletLoaded({
    required this.walletId,
    this.walletAddress,
    this.blockchain = 'polygon',
    required this.usdcBalance,
    this.pendingBalance = 0,
  });

  final String walletId;
  final String? walletAddress;
  final String blockchain;
  final double usdcBalance;
  final double pendingBalance;

  @override
  String get name => 'LOADED';
}

/// Wallet not found (404) - user needs to create one
class WalletNotFound extends WalletEvent {
  const WalletNotFound();

  @override
  String get name => 'NOT_FOUND';
}

/// User initiates wallet creation
class WalletCreate extends WalletEvent {
  const WalletCreate();

  @override
  String get name => 'CREATE';
}

/// Wallet created successfully
class WalletCreated extends WalletEvent {
  const WalletCreated({
    required this.walletId,
    this.walletAddress,
    this.blockchain = 'polygon',
  });

  final String walletId;
  final String? walletAddress;
  final String blockchain;

  @override
  String get name => 'CREATED';
}

/// Error occurred
class WalletFailed extends WalletEvent {
  const WalletFailed({required this.message, this.data});

  final String message;
  final dynamic data;

  @override
  String get name => 'FAILED';
}

/// Optimistic balance update after transaction
class WalletBalanceUpdate extends WalletEvent {
  const WalletBalanceUpdate({
    this.addAmount,
    this.subtractAmount,
    this.addPending,
  });

  final double? addAmount;
  final double? subtractAmount;
  final double? addPending;

  @override
  String get name => 'BALANCE_UPDATE';
}

/// Wallet frozen by compliance
class WalletFrozenEvent extends WalletEvent {
  const WalletFrozenEvent({
    required this.reason,
    this.frozenUntil,
  });

  final String reason;
  final DateTime? frozenUntil;

  @override
  String get name => 'FROZEN';
}

/// Wallet under review
class WalletUnderReviewEvent extends WalletEvent {
  const WalletUnderReviewEvent({required this.reason});

  final String reason;

  @override
  String get name => 'UNDER_REVIEW';
}

/// Wallet limits imposed
class WalletLimitedEvent extends WalletEvent {
  const WalletLimitedEvent({
    required this.reason,
    this.maxTransactionAmount,
    this.dailyLimit,
  });

  final String reason;
  final double? maxTransactionAmount;
  final double? dailyLimit;

  @override
  String get name => 'LIMITED';
}

/// Review completed, wallet restored
class WalletReviewCompleted extends WalletEvent {
  const WalletReviewCompleted();

  @override
  String get name => 'REVIEW_COMPLETED';
}

/// Wallet unfrozen
class WalletUnfrozen extends WalletEvent {
  const WalletUnfrozen();

  @override
  String get name => 'UNFROZEN';
}

// ═══════════════════════════════════════════════════════════════════
// FSM DEFINITION
// ═══════════════════════════════════════════════════════════════════

class WalletFsm extends FsmDefinition<WalletState, WalletEvent> {
  @override
  WalletState get initialState => const WalletNone();

  @override
  TransitionResult<WalletState> handle(
    WalletState currentState,
    WalletEvent event,
  ) {
    return switch (currentState) {
      WalletNone() => _handleNone(currentState, event),
      WalletLoading() => _handleLoading(currentState, event),
      WalletNotCreated() => _handleNotCreated(currentState, event),
      WalletCreating() => _handleCreating(currentState, event),
      WalletReady() => _handleReady(currentState, event),
      WalletFrozen() => _handleFrozen(currentState, event),
      WalletUnderReview() => _handleUnderReview(currentState, event),
      WalletLimited() => _handleLimited(currentState, event),
      WalletError() => _handleError(currentState, event),
    };
  }

  TransitionResult<WalletState> _handleNone(
    WalletNone state,
    WalletEvent event,
  ) {
    if (event is WalletFetch) {
      return TransitionSuccess(
        const WalletLoading(),
        effects: [const FetchEffect('wallet')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleLoading(
    WalletLoading state,
    WalletEvent event,
  ) {
    if (event is WalletLoaded) {
      return TransitionSuccess(
        WalletReady(
          walletId: event.walletId,
          walletAddress: event.walletAddress,
          blockchain: event.blockchain,
          usdcBalance: event.usdcBalance,
          pendingBalance: event.pendingBalance,
          lastUpdated: DateTime.now(),
        ),
      );
    }
    if (event is WalletNotFound) {
      return const TransitionSuccess(WalletNotCreated());
    }
    if (event is WalletFailed) {
      return TransitionSuccess(
        WalletError(
          errorMessage: event.message,
          errorData: event.data,
          previousState: const WalletNone(),
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleNotCreated(
    WalletNotCreated state,
    WalletEvent event,
  ) {
    if (event is WalletCreate) {
      return TransitionSuccess(
        const WalletCreating(),
        effects: [const FetchEffect('wallet/create')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleCreating(
    WalletCreating state,
    WalletEvent event,
  ) {
    if (event is WalletCreated) {
      return TransitionSuccess(
        WalletReady(
          walletId: event.walletId,
          walletAddress: event.walletAddress,
          blockchain: event.blockchain,
          usdcBalance: 0,
          pendingBalance: 0,
          lastUpdated: DateTime.now(),
        ),
        effects: [
          const NotifyEffect('Wallet created successfully!', type: NotifyType.success),
        ],
      );
    }
    if (event is WalletFailed) {
      return TransitionSuccess(
        WalletError(
          errorMessage: event.message,
          errorData: event.data,
          previousState: const WalletNotCreated(),
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleReady(
    WalletReady state,
    WalletEvent event,
  ) {
    if (event is WalletRefresh) {
      return TransitionSuccess(
        const WalletLoading(isRefresh: true),
        effects: [const FetchEffect('wallet')],
      );
    }
    if (event is WalletLoaded) {
      // Direct update from refresh
      return TransitionSuccess(
        state.copyWith(
          usdcBalance: event.usdcBalance,
          pendingBalance: event.pendingBalance,
          lastUpdated: DateTime.now(),
        ),
      );
    }
    if (event is WalletBalanceUpdate) {
      // Optimistic update
      return TransitionSuccess(
        state.copyWith(
          usdcBalance: state.usdcBalance +
              (event.addAmount ?? 0) -
              (event.subtractAmount ?? 0),
          pendingBalance: state.pendingBalance + (event.addPending ?? 0),
        ),
      );
    }
    if (event is WalletFrozenEvent) {
      return TransitionSuccess(
        WalletFrozen(
          walletId: state.walletId,
          reason: event.reason,
          frozenAt: DateTime.now(),
          frozenUntil: event.frozenUntil,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.error),
        ],
      );
    }
    if (event is WalletUnderReviewEvent) {
      return TransitionSuccess(
        WalletUnderReview(
          walletId: state.walletId,
          reason: event.reason,
          reviewStartedAt: DateTime.now(),
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.warning),
        ],
      );
    }
    if (event is WalletLimitedEvent) {
      return TransitionSuccess(
        WalletLimited(
          walletId: state.walletId,
          walletAddress: state.walletAddress,
          blockchain: state.blockchain,
          usdcBalance: state.usdcBalance,
          pendingBalance: state.pendingBalance,
          lastUpdated: DateTime.now(),
          limitReason: event.reason,
          maxTransactionAmount: event.maxTransactionAmount,
          dailyLimit: event.dailyLimit,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.warning),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleFrozen(
    WalletFrozen state,
    WalletEvent event,
  ) {
    if (event is WalletUnfrozen) {
      return TransitionSuccess(
        const WalletLoading(),
        effects: [
          const FetchEffect('wallet'),
          const NotifyEffect('Wallet unfrozen', type: NotifyType.success),
        ],
      );
    }
    if (event is WalletRefresh) {
      // Allow refresh to check if still frozen
      return TransitionSuccess(
        const WalletLoading(isRefresh: true),
        effects: [const FetchEffect('wallet')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleUnderReview(
    WalletUnderReview state,
    WalletEvent event,
  ) {
    if (event is WalletReviewCompleted) {
      return TransitionSuccess(
        const WalletLoading(),
        effects: [
          const FetchEffect('wallet'),
          const NotifyEffect('Review completed', type: NotifyType.success),
        ],
      );
    }
    if (event is WalletRefresh) {
      // Allow refresh to check review status
      return TransitionSuccess(
        const WalletLoading(isRefresh: true),
        effects: [const FetchEffect('wallet')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleLimited(
    WalletLimited state,
    WalletEvent event,
  ) {
    if (event is WalletRefresh) {
      return TransitionSuccess(
        const WalletLoading(isRefresh: true),
        effects: [const FetchEffect('wallet')],
      );
    }
    if (event is WalletLoaded) {
      // Check if limits still apply - if not, transition to Ready
      // This would be determined by backend response
      return TransitionSuccess(
        WalletReady(
          walletId: state.walletId,
          walletAddress: state.walletAddress,
          blockchain: state.blockchain,
          usdcBalance: event.usdcBalance,
          pendingBalance: event.pendingBalance,
          lastUpdated: DateTime.now(),
        ),
      );
    }
    if (event is WalletFrozenEvent) {
      return TransitionSuccess(
        WalletFrozen(
          walletId: state.walletId,
          reason: event.reason,
          frozenAt: DateTime.now(),
          frozenUntil: event.frozenUntil,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.error),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<WalletState> _handleError(
    WalletError state,
    WalletEvent event,
  ) {
    if (event is WalletFetch) {
      return TransitionSuccess(
        const WalletLoading(),
        effects: [const FetchEffect('wallet')],
      );
    }
    // Allow retry of wallet creation from error state
    if (event is WalletCreate) {
      return TransitionSuccess(
        const WalletCreating(),
        effects: [const FetchEffect('wallet/create')],
      );
    }
    return const TransitionNotApplicable();
  }
}
