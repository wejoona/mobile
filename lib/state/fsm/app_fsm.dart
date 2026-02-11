import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';
import 'package:usdc_wallet/state/fsm/kyc_fsm.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │                    APP FSM (ORCHESTRATOR)                        │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  This FSM composes Auth, Wallet, and KYC FSMs to determine      │
/// │  the overall app state and which screen to show.                │
/// │                                                                  │
/// │  ┌──────────────────────────────────────────────────────────┐   │
/// │  │                    DECISION TREE                         │   │
/// │  ├──────────────────────────────────────────────────────────┤   │
/// │  │                                                          │   │
/// │  │  Is Authenticated?                                       │   │
/// │  │       │                                                  │   │
/// │  │       ├── NO ──▶ Show LOGIN                              │   │
/// │  │       │                                                  │   │
/// │  │       └── YES                                            │   │
/// │  │            │                                             │   │
/// │  │            ▼                                             │   │
/// │  │      Has Wallet?                                         │   │
/// │  │            │                                             │   │
/// │  │            ├── LOADING ──▶ Show LOADING                  │   │
/// │  │            │                                             │   │
/// │  │            ├── NO ──▶ Show CREATE_WALLET                 │   │
/// │  │            │                                             │   │
/// │  │            └── YES                                       │   │
/// │  │                 │                                        │   │
/// │  │                 ▼                                        │   │
/// │  │           KYC Status?                                    │   │
/// │  │                 │                                        │   │
/// │  │                 ├── NONE ──▶ Show HOME (with KYC banner) │   │
/// │  │                 │                                        │   │
/// │  │                 ├── PENDING ──▶ Show HOME (with status)  │   │
/// │  │                 │                                        │   │
/// │  │                 └── VERIFIED ──▶ Show HOME (full access) │   │
/// │  │                                                          │   │
/// │  └──────────────────────────────────────────────────────────┘   │
/// │                                                                  │
/// │  GUARDS:                                                        │
/// │  • Cannot access HOME without authentication                    │
/// │  • Cannot access WALLET features without wallet                 │
/// │  • Cannot access DEPOSIT/WITHDRAW without KYC tier 1            │
/// │  • Cannot access HIGH_LIMIT features without KYC tier 2         │
/// │                                                                  │
/// │  GLOBAL ACTIONS:                                                │
/// │  • LOGOUT ──▶ Resets ALL FSMs, navigates to LOGIN               │
/// │  • RESET ──▶ Resets ALL FSMs to initial state                   │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

// ═══════════════════════════════════════════════════════════════════
// COMPOSITE STATE
// ═══════════════════════════════════════════════════════════════════

/// Composite state containing all FSM states
class AppState extends FsmState {
  final AuthState auth;
  final WalletState wallet;
  final KycState kyc;
  final SessionState session;

  const AppState({
    required this.auth,
    required this.wallet,
    required this.kyc,
    required this.session,
  });

  const AppState.initial()
      : auth = const AuthUnauthenticated(),
        wallet = const WalletNone(),
        kyc = const KycInitial(),
        session = const SessionNone();

  @override
  String get name => 'App(${auth.name}, ${wallet.name}, ${kyc.name}, ${session.name})';

  // ─────────────────────────────────────────────────────────────────
  // Derived properties
  // ─────────────────────────────────────────────────────────────────

  /// Is user authenticated?
  bool get isAuthenticated => auth is AuthAuthenticated || auth is AuthTokenRefreshing;

  /// Is any FSM in a loading/transitioning state?
  bool get isLoading =>
      auth.isTransitioning || wallet.isTransitioning || kyc.isTransitioning || session.isTransitioning;

  /// Has any FSM encountered an error?
  bool get hasError => auth.isError || wallet.isError || kyc.isError;

  /// Is session active and usable?
  bool get hasActiveSession => session.isActive;

  /// Does session need user attention (locked/expiring)?
  bool get needsSessionAttention => session.needsAttention;

  /// Is wallet ready for transactions?
  bool get hasWallet => wallet is WalletReady;

  /// Does user need to create a wallet?
  bool get needsWalletCreation => wallet is WalletNotCreated;

  /// Is wallet currently being created?
  bool get isCreatingWallet => wallet is WalletCreating;

  /// Current KYC tier
  KycTier get kycTier => kyc.tier;

  /// Is KYC verified?
  bool get isKycVerified => kyc is KycVerified;

  /// Is KYC pending review?
  bool get isKycPending => kyc is KycPending;

  /// Can user perform deposits?
  bool get canDeposit => kyc.canDeposit && hasWallet;

  /// Can user perform withdrawals?
  bool get canWithdraw => kyc.canWithdraw && hasWallet;

  /// Can user send money?
  bool get canSend => kyc.canSend && hasWallet;

  /// Can user receive money?
  bool get canReceive => kyc.canReceive && hasWallet;

  /// Is auth locked or suspended?
  bool get isAuthBlocked => auth is AuthLocked || auth is AuthSuspended;

  /// Is wallet blocked (frozen/under review)?
  bool get isWalletBlocked => wallet is WalletFrozen || wallet is WalletUnderReview;

  /// Is wallet limited?
  bool get isWalletLimited => wallet is WalletLimited;

  /// Is KYC expired?
  bool get isKycExpired => kyc is KycExpired;

  /// Is KYC under manual review?
  bool get isKycUnderReview => kyc is KycManualReview;

  // ─────────────────────────────────────────────────────────────────
  // Screen determination
  // ─────────────────────────────────────────────────────────────────

  /// Determine which screen should be shown
  AppScreen get currentScreen {
    // Auth is locked - show locked screen
    if (auth is AuthLocked) {
      return AppScreen.authLocked;
    }

    // Auth is suspended - show suspended screen
    if (auth is AuthSuspended) {
      return AppScreen.authSuspended;
    }

    // OTP expired - show OTP expired screen
    if (auth is AuthOtpExpired) {
      return AppScreen.otpExpired;
    }

    // Session locked - show unlock screen
    if (session is SessionLocked) {
      return AppScreen.sessionLocked;
    }

    // Session biometric prompt
    if (session is SessionBiometricPrompt) {
      return AppScreen.biometricPrompt;
    }

    // Session device changed
    if (session is SessionDeviceChanged) {
      return AppScreen.deviceVerification;
    }

    // Session conflict
    if (session is SessionConflict) {
      return AppScreen.sessionConflict;
    }

    // Not authenticated - show login
    if (!isAuthenticated) {
      if (auth is AuthOtpSent || auth is AuthVerifying) {
        return AppScreen.otp;
      }
      if (auth is AuthSubmitting) {
        return AppScreen.loginLoading;
      }
      return AppScreen.login;
    }

    // Authenticated but wallet or KYC loading - show loading
    if (wallet is WalletLoading || wallet is WalletNone || kyc is KycInitial || kyc is KycLoading) {
      return AppScreen.loading;
    }

    // Authenticated but KYC not complete - redirect to KYC first
    // This ensures KYC is done before wallet creation
    // KycNone = never started OR documents_pending (mapped from API)
    if (kyc is KycNone) {
      return AppScreen.kyc;
    }

    // Needs to create wallet (only after KYC is submitted or verified)
    if (needsWalletCreation || isCreatingWallet) {
      return AppScreen.createWallet;
    }

    // Wallet frozen - show frozen screen
    if (wallet is WalletFrozen) {
      return AppScreen.walletFrozen;
    }

    // Wallet under review
    if (wallet is WalletUnderReview) {
      return AppScreen.walletUnderReview;
    }

    // KYC expired - show renewal prompt
    if (kyc is KycExpired) {
      return AppScreen.kycExpired;
    }

    // Has wallet - show home
    return AppScreen.home;
  }

  /// Get the route for the current screen
  String get currentRoute => currentScreen.route;

  // ─────────────────────────────────────────────────────────────────
  // Copy with
  // ─────────────────────────────────────────────────────────────────

  AppState copyWith({
    AuthState? auth,
    WalletState? wallet,
    KycState? kyc,
    SessionState? session,
  }) {
    return AppState(
      auth: auth ?? this.auth,
      wallet: wallet ?? this.wallet,
      kyc: kyc ?? this.kyc,
      session: session ?? this.session,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// SCREENS
// ═══════════════════════════════════════════════════════════════════

enum AppScreen {
  login('/login'),
  loginLoading('/login'),
  otp('/otp'),
  otpExpired('/otp-expired'),
  authLocked('/auth-locked'),
  authSuspended('/auth-suspended'),
  sessionLocked('/session-locked'),
  biometricPrompt('/biometric-prompt'),
  deviceVerification('/device-verification'),
  sessionConflict('/session-conflict'),
  loading('/loading'),
  createWallet('/create-wallet'),
  walletFrozen('/wallet-frozen'),
  walletUnderReview('/wallet-under-review'),
  kycExpired('/kyc-expired'),
  home('/home'),
  kyc('/kyc'),
  settings('/settings');

  final String route;
  const AppScreen(this.route);
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════

/// Wrapper for sub-FSM events
sealed class AppEvent extends FsmEvent {
  const AppEvent();
}

/// Auth-related event
class AppAuthEvent extends AppEvent {
  final AuthEvent event;

  const AppAuthEvent(this.event);

  @override
  String get name => 'AUTH:${event.name}';
}

/// Wallet-related event
class AppWalletEvent extends AppEvent {
  final WalletEvent event;

  const AppWalletEvent(this.event);

  @override
  String get name => 'WALLET:${event.name}';
}

/// KYC-related event
class AppKycEvent extends AppEvent {
  final KycEvent event;

  const AppKycEvent(this.event);

  @override
  String get name => 'KYC:${event.name}';
}

/// Session-related event
class AppSessionEvent extends AppEvent {
  final SessionEvent event;

  const AppSessionEvent(this.event);

  @override
  String get name => 'SESSION:${event.name}';
}

/// Global logout event
class AppLogout extends GlobalFsmEvent {
  const AppLogout();

  @override
  String get name => 'LOGOUT';
}

/// Global reset event
class AppReset extends GlobalFsmEvent {
  const AppReset();

  @override
  String get name => 'RESET';
}

// ═══════════════════════════════════════════════════════════════════
// GUARDS
// ═══════════════════════════════════════════════════════════════════

/// Route guards based on app state
class AppGuards {
  final AppState state;

  const AppGuards(this.state);

  /// Check if route is allowed
  GuardResult canAccessRoute(String route) {
    // Public routes - always allowed
    if (_isPublicRoute(route)) {
      return const GuardAllowed();
    }

    // Must be authenticated for all other routes
    if (!state.isAuthenticated) {
      return const GuardDenied('/login', 'Authentication required');
    }

    // Routes that require wallet
    if (_requiresWallet(route)) {
      if (!state.hasWallet) {
        if (state.needsWalletCreation) {
          return const GuardDenied('/create-wallet', 'Wallet required');
        }
        return const GuardDenied('/loading', 'Loading wallet');
      }
    }

    // Routes that require KYC tier 1
    if (_requiresKycTier1(route)) {
      if (!state.kyc.canPerform(KycTier.tier1)) {
        return const GuardDenied('/kyc', 'KYC verification required');
      }
    }

    // Routes that require KYC tier 2
    if (_requiresKycTier2(route)) {
      if (!state.kyc.canPerform(KycTier.tier2)) {
        return const GuardDenied('/kyc/upgrade', 'KYC upgrade required');
      }
    }

    return const GuardAllowed();
  }

  bool _isPublicRoute(String route) {
    const publicRoutes = ['/', '/login', '/otp', '/register'];
    return publicRoutes.any((r) => route.startsWith(r));
  }

  bool _requiresWallet(String route) {
    const walletRoutes = [
      '/home',
      '/send',
      '/receive',
      '/deposit',
      '/withdraw',
      '/transactions',
    ];
    return walletRoutes.any((r) => route.startsWith(r));
  }

  bool _requiresKycTier1(String route) {
    const tier1Routes = ['/deposit', '/withdraw'];
    return tier1Routes.any((r) => route.startsWith(r));
  }

  bool _requiresKycTier2(String route) {
    const tier2Routes = ['/international-transfer', '/high-value'];
    return tier2Routes.any((r) => route.startsWith(r));
  }
}

sealed class GuardResult {
  const GuardResult();
}

class GuardAllowed extends GuardResult {
  const GuardAllowed();
}

class GuardDenied extends GuardResult {
  final String redirectTo;
  final String reason;

  const GuardDenied(this.redirectTo, this.reason);
}

// ═══════════════════════════════════════════════════════════════════
// FSM DEFINITION
// ═══════════════════════════════════════════════════════════════════

class AppFsm extends FsmDefinition<AppState, AppEvent> {
  final AuthFsm _authFsm = AuthFsm();
  final WalletFsm _walletFsm = WalletFsm();
  final KycFsm _kycFsm = KycFsm();
  final SessionFsm _sessionFsm = SessionFsm();

  @override
  AppState get initialState => const AppState.initial();

  @override
  TransitionResult<AppState> handleGlobal(
    AppState currentState,
    GlobalFsmEvent event,
  ) {
    if (event is AppLogout || event is AppReset) {
      return TransitionSuccess(
        const AppState.initial(),
        effects: [
          const ClearEffect('tokens'),
          const ClearEffect('user'),
          const ClearEffect('wallet'),
          const ClearEffect('kyc'),
          const ClearEffect('session'),
          const NavigateEffect('/login'),
        ],
      );
    }
    return super.handleGlobal(currentState, event);
  }

  @override
  TransitionResult<AppState> handle(AppState currentState, AppEvent event) {
    return switch (event) {
      AppAuthEvent() => _handleAuthEvent(currentState, event),
      AppWalletEvent() => _handleWalletEvent(currentState, event),
      AppKycEvent() => _handleKycEvent(currentState, event),
      AppSessionEvent() => _handleSessionEvent(currentState, event),
    };
  }

  TransitionResult<AppState> _handleAuthEvent(
    AppState state,
    AppAuthEvent event,
  ) {
    final result = _authFsm.process(state.auth, event.event);

    if (result is TransitionSuccess<AuthState>) {
      final newState = state.copyWith(auth: result.newState);
      List<FsmEffect> effects = [...?result.effects];

      // If just authenticated, trigger wallet, KYC fetch, and start session
      if (result.newState is AuthAuthenticated &&
          state.auth is! AuthAuthenticated) {
        // Reset wallet and KYC to trigger fresh fetch
        final resetWallet = _walletFsm.process(state.wallet, const ResetEvent());
        final resetKyc = _kycFsm.process(state.kyc, const ResetEvent());

        // Start new session
        final sessionResult = _sessionFsm.process(
          state.session,
          const SessionStart(),
        );

        return TransitionSuccess(
          newState.copyWith(
            wallet: (resetWallet as TransitionSuccess<WalletState>).newState,
            kyc: (resetKyc as TransitionSuccess<KycState>).newState,
            session: (sessionResult as TransitionSuccess<SessionState>).newState,
          ),
          effects: [
            ...effects,
            const FetchEffect('wallet'),
            const FetchEffect('kyc/status'),
          ],
        );
      }

      // If auth is suspended, freeze wallet
      if (result.newState is AuthSuspended && state.wallet is WalletReady) {
        final walletResult = _walletFsm.process(
          state.wallet,
          WalletFrozenEvent(
            reason: 'Account suspended',
            frozenUntil: (result.newState as AuthSuspended).suspendedUntil,
          ),
        );

        if (walletResult is TransitionSuccess<WalletState>) {
          return TransitionSuccess(
            newState.copyWith(wallet: walletResult.newState),
            effects: [...effects, ...?walletResult.effects],
          );
        }
      }

      // If auth is locked, lock session
      if (result.newState is AuthLocked && state.session is SessionActive) {
        final sessionResult = _sessionFsm.process(
          state.session,
          SessionLock(reason: (result.newState as AuthLocked).reason),
        );

        if (sessionResult is TransitionSuccess<SessionState>) {
          return TransitionSuccess(
            newState.copyWith(session: sessionResult.newState),
            effects: [...effects, ...?sessionResult.effects],
          );
        }
      }

      return TransitionSuccess(newState, effects: effects);
    }

    if (result is TransitionDenied<AuthState>) {
      return TransitionDenied(result.reason);
    }

    return const TransitionNotApplicable();
  }

  TransitionResult<AppState> _handleWalletEvent(
    AppState state,
    AppWalletEvent event,
  ) {
    // Guard: Must be authenticated
    if (!state.isAuthenticated) {
      return const TransitionDenied('Not authenticated');
    }

    final result = _walletFsm.process(state.wallet, event.event);

    if (result is TransitionSuccess<WalletState>) {
      // If wallet gets frozen, ensure session awareness
      if (result.newState is WalletFrozen) {
        final sessionResult = _sessionFsm.process(
          state.session,
          const SessionLock(reason: 'Wallet frozen'),
        );

        if (sessionResult is TransitionSuccess<SessionState>) {
          return TransitionSuccess(
            state.copyWith(
              wallet: result.newState,
              session: sessionResult.newState,
            ),
            effects: [...?result.effects, ...?sessionResult.effects],
          );
        }
      }

      return TransitionSuccess(
        state.copyWith(wallet: result.newState),
        effects: result.effects,
      );
    }

    if (result is TransitionDenied<WalletState>) {
      return TransitionDenied(result.reason);
    }

    return const TransitionNotApplicable();
  }

  TransitionResult<AppState> _handleKycEvent(
    AppState state,
    AppKycEvent event,
  ) {
    // Guard: Must be authenticated
    if (!state.isAuthenticated) {
      return const TransitionDenied('Not authenticated');
    }

    final result = _kycFsm.process(state.kyc, event.event);

    if (result is TransitionSuccess<KycState>) {
      // If KYC expires, apply wallet limits
      if (result.newState is KycExpired && state.wallet is WalletReady) {
        final walletResult = _walletFsm.process(
          state.wallet,
          const WalletLimitedEvent(
            reason: 'KYC expired - limited transactions until renewal',
            maxTransactionAmount: 1000.0,
            dailyLimit: 5000.0,
          ),
        );

        if (walletResult is TransitionSuccess<WalletState>) {
          return TransitionSuccess(
            state.copyWith(
              kyc: result.newState,
              wallet: walletResult.newState,
            ),
            effects: [...?result.effects, ...?walletResult.effects],
          );
        }
      }

      return TransitionSuccess(
        state.copyWith(kyc: result.newState),
        effects: result.effects,
      );
    }

    if (result is TransitionDenied<KycState>) {
      return TransitionDenied(result.reason);
    }

    return const TransitionNotApplicable();
  }

  TransitionResult<AppState> _handleSessionEvent(
    AppState state,
    AppSessionEvent event,
  ) {
    final result = _sessionFsm.process(state.session, event.event);

    if (result is TransitionSuccess<SessionState>) {
      // If session expires, trigger logout
      if (result.newState is SessionExpired) {
        final authResult = _authFsm.process(state.auth, const AuthLogout());

        if (authResult is TransitionSuccess<AuthState>) {
          return TransitionSuccess(
            state.copyWith(
              session: result.newState,
              auth: authResult.newState,
            ),
            effects: [
              ...?result.effects,
              ...?authResult.effects,
            ],
          );
        }
      }

      return TransitionSuccess(
        state.copyWith(session: result.newState),
        effects: result.effects,
      );
    }

    if (result is TransitionDenied<SessionState>) {
      return TransitionDenied(result.reason);
    }

    return const TransitionNotApplicable();
  }
}
