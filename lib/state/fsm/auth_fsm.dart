import 'package:usdc_wallet/state/fsm/fsm_base.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │                        AUTH FSM                                  │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  ┌──────────────┐     LOGIN      ┌──────────────┐               │
/// │  │              │ ──────────────▶│              │               │
/// │  │ Unauthenticated               │  Submitting  │               │
/// │  │              │◀──────────────│              │               │
/// │  └──────────────┘     FAIL       └──────┬───────┘               │
/// │         ▲                               │                        │
/// │         │                          SUCCESS                       │
/// │         │                               │                        │
/// │         │                               ▼                        │
/// │         │                        ┌──────────────┐               │
/// │         │         RESEND         │              │               │
/// │         │    ┌──────────────────▶│   OtpSent    │◀──┐           │
/// │         │    │                   │              │   │           │
/// │         │    │                   └──────┬───────┘   │           │
/// │         │    │                          │           │           │
/// │      LOGOUT  │                     VERIFY_OTP       │ FAIL      │
/// │         │    │                          │           │           │
/// │         │    │                          ▼           │           │
/// │         │    │                   ┌──────────────┐   │           │
/// │         │    │                   │              │   │           │
/// │         │    └───────────────────│  Verifying   │───┘           │
/// │         │                        │              │               │
/// │         │                        └──────┬───────┘               │
/// │         │                               │                        │
/// │         │                          SUCCESS                       │
/// │         │                               │                        │
/// │         │                               ▼                        │
/// │         │                        ┌──────────────┐               │
/// │         │                        │              │               │
/// │         └────────────────────────│ Authenticated│               │
/// │                                  │              │               │
/// │                                  └──────────────┘               │
/// │                                                                  │
/// │  GLOBAL: RESET ──▶ Unauthenticated                              │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

// ═══════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════

sealed class AuthState extends FsmState {
  const AuthState();
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();

  @override
  String get name => 'UNAUTHENTICATED';
}

/// Login/register request in progress
class AuthSubmitting extends AuthState {
  const AuthSubmitting({required this.phone});

  final String phone;

  @override
  String get name => 'SUBMITTING';

  @override
  bool get isTransitioning => true;
}

/// OTP has been sent, waiting for user input
class AuthOtpSent extends AuthState {
  const AuthOtpSent({
    required this.phone,
    this.expiresIn,
    this.attemptsRemaining,
  });

  final String phone;
  final int? expiresIn;
  final int? attemptsRemaining;

  @override
  String get name => 'OTP_SENT';
}

/// OTP verification in progress
class AuthVerifying extends AuthState {
  const AuthVerifying({required this.phone});

  final String phone;

  @override
  String get name => 'VERIFYING';

  @override
  bool get isTransitioning => true;
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.phone,
    required this.accessToken,
    this.refreshToken,
  });

  final String userId;
  final String phone;
  final String accessToken;
  final String? refreshToken;

  @override
  String get name => 'AUTHENTICATED';
}

/// OTP has expired
class AuthOtpExpired extends AuthState {
  const AuthOtpExpired({required this.phone});

  final String phone;

  @override
  String get name => 'OTP_EXPIRED';
}

/// Token refresh in progress
class AuthTokenRefreshing extends AuthState {
  const AuthTokenRefreshing({
    required this.userId,
    required this.phone,
  });

  final String userId;
  final String phone;

  @override
  String get name => 'TOKEN_REFRESHING';

  @override
  bool get isTransitioning => true;
}

/// Account temporarily locked (too many attempts)
class AuthLocked extends AuthState {
  const AuthLocked({
    required this.phone,
    required this.lockedAt,
    required this.lockDuration,
    required this.reason,
  });

  final String phone;
  final DateTime lockedAt;
  final Duration lockDuration;
  final String reason;

  @override
  String get name => 'LOCKED';

  /// Time remaining until unlock
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(lockedAt);
    final remaining = lockDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  bool get isUnlocked => remainingTime == Duration.zero;
}

/// Account suspended by admin
class AuthSuspended extends AuthState {
  const AuthSuspended({
    required this.userId,
    required this.phone,
    required this.reason,
    required this.suspendedAt,
    this.suspendedUntil,
  });

  final String userId;
  final String phone;
  final String reason;
  final DateTime suspendedAt;
  final DateTime? suspendedUntil;

  @override
  String get name => 'SUSPENDED';

  bool get isPermanent => suspendedUntil == null;
}

/// Authentication error occurred
class AuthError extends AuthState with FsmStateError {
  const AuthError({
    required this.errorMessage,
    this.errorData,
    required this.previousState,
  });

  @override
  final String errorMessage;
  @override
  final dynamic errorData;
  final AuthState previousState;

  @override
  String get name => 'ERROR';
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════

sealed class AuthEvent extends FsmEvent {
  const AuthEvent();
}

/// User initiates login/register
class AuthLogin extends AuthEvent {
  const AuthLogin({required this.phone, required this.countryCode});

  final String phone;
  final String countryCode;

  @override
  String get name => 'LOGIN';
}

/// OTP request succeeded
class AuthOtpReceived extends AuthEvent {
  const AuthOtpReceived({this.expiresIn});

  final int? expiresIn;

  @override
  String get name => 'OTP_RECEIVED';
}

/// User submits OTP
class AuthVerifyOtp extends AuthEvent {
  const AuthVerifyOtp({required this.otp});

  final String otp;

  @override
  String get name => 'VERIFY_OTP';
}

/// OTP verification succeeded
class AuthVerified extends AuthEvent {
  const AuthVerified({
    required this.userId,
    required this.accessToken,
    this.refreshToken,
  });

  final String userId;
  final String accessToken;
  final String? refreshToken;

  @override
  String get name => 'VERIFIED';
}

/// User requests OTP resend
class AuthResendOtp extends AuthEvent {
  const AuthResendOtp();

  @override
  String get name => 'RESEND_OTP';
}

/// User logs out
class AuthLogout extends GlobalFsmEvent {
  const AuthLogout();

  @override
  String get name => 'LOGOUT';
}

/// Error occurred
class AuthFailed extends AuthEvent {
  const AuthFailed({required this.message, this.data});

  final String message;
  final dynamic data;

  @override
  String get name => 'FAILED';
}

/// Clear error and return to previous state
class AuthClearError extends AuthEvent {
  const AuthClearError();

  @override
  String get name => 'CLEAR_ERROR';
}

/// OTP expired event
class AuthOtpExpiredEvent extends AuthEvent {
  const AuthOtpExpiredEvent();

  @override
  String get name => 'OTP_EXPIRED';
}

/// Refresh token event
class AuthRefreshToken extends AuthEvent {
  const AuthRefreshToken();

  @override
  String get name => 'REFRESH_TOKEN';
}

/// Token refreshed successfully
class AuthTokenRefreshed extends AuthEvent {
  const AuthTokenRefreshed({
    required this.accessToken,
    this.refreshToken,
  });

  final String accessToken;
  final String? refreshToken;

  @override
  String get name => 'TOKEN_REFRESHED';
}

/// Account locked event
class AuthAccountLocked extends AuthEvent {
  const AuthAccountLocked({
    required this.lockDuration,
    required this.reason,
  });

  final Duration lockDuration;
  final String reason;

  @override
  String get name => 'ACCOUNT_LOCKED';
}

/// Account suspended event
class AuthAccountSuspended extends AuthEvent {
  const AuthAccountSuspended({
    required this.reason,
    this.suspendedUntil,
  });

  final String reason;
  final DateTime? suspendedUntil;

  @override
  String get name => 'ACCOUNT_SUSPENDED';
}

// ═══════════════════════════════════════════════════════════════════
// FSM DEFINITION
// ═══════════════════════════════════════════════════════════════════

class AuthFsm extends FsmDefinition<AuthState, AuthEvent> {
  @override
  AuthState get initialState => const AuthUnauthenticated();

  @override
  TransitionResult<AuthState> handleGlobal(
    AuthState currentState,
    GlobalFsmEvent event,
  ) {
    if (event is AuthLogout) {
      return TransitionSuccess(
        const AuthUnauthenticated(),
        effects: [
          const ClearEffect('tokens'),
          const ClearEffect('user'),
          const NavigateEffect('/login'),
        ],
      );
    }
    return super.handleGlobal(currentState, event);
  }

  @override
  TransitionResult<AuthState> handle(AuthState currentState, AuthEvent event) {
    return switch (currentState) {
      AuthUnauthenticated() => _handleUnauthenticated(currentState, event),
      AuthSubmitting() => _handleSubmitting(currentState, event),
      AuthOtpSent() => _handleOtpSent(currentState, event),
      AuthOtpExpired() => _handleOtpExpired(currentState, event),
      AuthVerifying() => _handleVerifying(currentState, event),
      AuthAuthenticated() => _handleAuthenticated(currentState, event),
      AuthTokenRefreshing() => _handleTokenRefreshing(currentState, event),
      AuthLocked() => _handleLocked(currentState, event),
      AuthSuspended() => _handleSuspended(currentState, event),
      AuthError() => _handleError(currentState, event),
    };
  }

  TransitionResult<AuthState> _handleUnauthenticated(
    AuthUnauthenticated state,
    AuthEvent event,
  ) {
    if (event is AuthLogin) {
      return TransitionSuccess(
        AuthSubmitting(phone: event.phone),
        effects: [FetchEffect('auth/login:${event.phone}')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleSubmitting(
    AuthSubmitting state,
    AuthEvent event,
  ) {
    if (event is AuthOtpReceived) {
      return TransitionSuccess(
        AuthOtpSent(phone: state.phone, expiresIn: event.expiresIn),
      );
    }
    if (event is AuthAccountLocked) {
      return TransitionSuccess(
        AuthLocked(
          phone: state.phone,
          lockedAt: DateTime.now(),
          lockDuration: event.lockDuration,
          reason: event.reason,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.error),
        ],
      );
    }
    if (event is AuthAccountSuspended) {
      return TransitionSuccess(
        AuthSuspended(
          userId: '',
          phone: state.phone,
          reason: event.reason,
          suspendedAt: DateTime.now(),
          suspendedUntil: event.suspendedUntil,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.error),
        ],
      );
    }
    if (event is AuthFailed) {
      return TransitionSuccess(
        AuthError(
          errorMessage: event.message,
          errorData: event.data,
          previousState: const AuthUnauthenticated(),
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleOtpSent(
    AuthOtpSent state,
    AuthEvent event,
  ) {
    if (event is AuthVerifyOtp) {
      return TransitionSuccess(
        AuthVerifying(phone: state.phone),
        effects: [FetchEffect('auth/verify:${event.otp}')],
      );
    }
    if (event is AuthResendOtp) {
      return TransitionSuccess(
        AuthSubmitting(phone: state.phone),
        effects: [FetchEffect('auth/resend:${state.phone}')],
      );
    }
    if (event is AuthOtpExpiredEvent) {
      return TransitionSuccess(
        AuthOtpExpired(phone: state.phone),
        effects: [
          const NotifyEffect('OTP expired', type: NotifyType.warning),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleOtpExpired(
    AuthOtpExpired state,
    AuthEvent event,
  ) {
    if (event is AuthResendOtp) {
      return TransitionSuccess(
        AuthSubmitting(phone: state.phone),
        effects: [FetchEffect('auth/resend:${state.phone}')],
      );
    }
    if (event is AuthLogin) {
      return TransitionSuccess(
        AuthSubmitting(phone: event.phone),
        effects: [FetchEffect('auth/login:${event.phone}')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleVerifying(
    AuthVerifying state,
    AuthEvent event,
  ) {
    if (event is AuthVerified) {
      return TransitionSuccess(
        AuthAuthenticated(
          userId: event.userId,
          phone: state.phone,
          accessToken: event.accessToken,
          refreshToken: event.refreshToken,
        ),
        effects: [
          const ClearEffect('previous_session'),
          const FetchEffect('wallet'),
          const FetchEffect('user/profile'),
        ],
      );
    }
    if (event is AuthFailed) {
      return TransitionSuccess(
        AuthError(
          errorMessage: event.message,
          errorData: event.data,
          previousState: AuthOtpSent(phone: state.phone),
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleAuthenticated(
    AuthAuthenticated state,
    AuthEvent event,
  ) {
    if (event is AuthRefreshToken) {
      return TransitionSuccess(
        AuthTokenRefreshing(
          userId: state.userId,
          phone: state.phone,
        ),
        effects: [const FetchEffect('auth/refresh')],
      );
    }
    if (event is AuthAccountSuspended) {
      return TransitionSuccess(
        AuthSuspended(
          userId: state.userId,
          phone: state.phone,
          reason: event.reason,
          suspendedAt: DateTime.now(),
          suspendedUntil: event.suspendedUntil,
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.error),
          const NavigateEffect('/suspended'),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleTokenRefreshing(
    AuthTokenRefreshing state,
    AuthEvent event,
  ) {
    if (event is AuthTokenRefreshed) {
      return TransitionSuccess(
        AuthAuthenticated(
          userId: state.userId,
          phone: state.phone,
          accessToken: event.accessToken,
          refreshToken: event.refreshToken,
        ),
      );
    }
    if (event is AuthFailed) {
      // Token refresh failed - logout required
      return TransitionSuccess(
        const AuthUnauthenticated(),
        effects: [
          const ClearEffect('tokens'),
          const NavigateEffect('/login'),
          const NotifyEffect('Session expired. Please log in again.', type: NotifyType.warning),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleLocked(
    AuthLocked state,
    AuthEvent event,
  ) {
    if (event is AuthLogin && state.isUnlocked) {
      return TransitionSuccess(
        AuthSubmitting(phone: event.phone),
        effects: [FetchEffect('auth/login:${event.phone}')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleSuspended(
    AuthSuspended state,
    AuthEvent event,
  ) {
    // Suspended state is mostly terminal - only logout/reset can escape
    return const TransitionNotApplicable();
  }

  TransitionResult<AuthState> _handleError(
    AuthError state,
    AuthEvent event,
  ) {
    if (event is AuthClearError) {
      return TransitionSuccess(state.previousState);
    }
    if (event is AuthLogin) {
      return TransitionSuccess(
        AuthSubmitting(phone: event.phone),
        effects: [FetchEffect('auth/login:${event.phone}')],
      );
    }
    return const TransitionNotApplicable();
  }
}
