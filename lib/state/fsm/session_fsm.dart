import 'package:usdc_wallet/state/fsm/fsm_base.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │                       SESSION FSM                                │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  Manages session lifecycle: timeouts, locks, expiry             │
/// │                                                                  │
/// │  ┌──────────────┐                                               │
/// │  │    None      │◀────────────────────────────────────┐         │
/// │  │  (No session)│                                     │         │
/// │  └──────┬───────┘                                     │         │
/// │         │                                             │         │
/// │       START                                        LOGOUT       │
/// │         │                                             │         │
/// │         ▼                                             │         │
/// │  ┌──────────────┐     BACKGROUND    ┌──────────────┐  │         │
/// │  │              │ ─────────────────▶│              │  │         │
/// │  │    Active    │                   │ Backgrounded │  │         │
/// │  │              │◀─────────────────│              │  │         │
/// │  └──────┬───────┘    FOREGROUND    └──────┬───────┘  │         │
/// │         │                                  │          │         │
/// │      TIMEOUT                           TIMEOUT        │         │
/// │         │                                  │          │         │
/// │         ▼                                  │          │         │
/// │  ┌──────────────┐                          │          │         │
/// │  │              │◀─────────────────────────┘          │         │
/// │  │   Expiring   │                                     │         │
/// │  │  (warning)   │                                     │         │
/// │  └──────┬───────┘                                     │         │
/// │         │                                             │         │
/// │    ┌────┴────┐                                        │         │
/// │    │         │                                        │         │
/// │ EXTEND    EXPIRE                                      │         │
/// │    │         │                                        │         │
/// │    ▼         ▼                                        │         │
/// │  Active  ┌──────────────┐     UNLOCK   ┌───────────┐  │         │
/// │          │              │ ────────────▶│           │  │         │
/// │          │   Locked     │              │  Active   │──┘         │
/// │          │              │◀────────────│           │            │
/// │          └──────┬───────┘    LOCK     └───────────┘            │
/// │                 │                                               │
/// │              EXPIRE                                             │
/// │                 │                                               │
/// │                 ▼                                               │
/// │          ┌──────────────┐                                       │
/// │          │   Expired    │─────────────▶ None                    │
/// │          └──────────────┘                                       │
/// │                                                                  │
/// │  GLOBAL: LOGOUT ──▶ None                                        │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

// ═══════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════

sealed class SessionState extends FsmState {
  const SessionState();

  /// Whether session is active and usable
  bool get isActive => false;

  /// Whether session needs user attention (locked/expiring)
  bool get needsAttention => false;
}

/// No active session
class SessionNone extends SessionState {
  const SessionNone();

  @override
  String get name => 'NONE';
}

/// Session is active
class SessionActive extends SessionState {
  const SessionActive({
    required this.startedAt,
    required this.lastActivity,
    required this.timeout,
  });

  final DateTime startedAt;
  final DateTime lastActivity;
  final Duration timeout;

  @override
  String get name => 'ACTIVE';

  @override
  bool get isActive => true;

  /// Time remaining before timeout
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(lastActivity);
    final remaining = timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  SessionActive recordActivity() {
    return SessionActive(
      startedAt: startedAt,
      lastActivity: DateTime.now(),
      timeout: timeout,
    );
  }
}

/// Session is in background (app minimized)
class SessionBackgrounded extends SessionState {
  const SessionBackgrounded({
    required this.startedAt,
    required this.backgroundedAt,
    required this.timeout,
  });

  final DateTime startedAt;
  final DateTime backgroundedAt;
  final Duration timeout;

  @override
  String get name => 'BACKGROUNDED';

  /// Time remaining before auto-lock
  Duration get remainingTime {
    final elapsed = DateTime.now().difference(backgroundedAt);
    final remaining = timeout - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Session is about to expire (warning shown)
class SessionExpiring extends SessionState {
  const SessionExpiring({
    required this.remainingSeconds,
    required this.expiresAt,
  });

  final int remainingSeconds;
  final DateTime expiresAt;

  @override
  String get name => 'EXPIRING';

  @override
  bool get needsAttention => true;
}

/// Session is locked (requires PIN/biometric)
class SessionLocked extends SessionState {
  const SessionLocked({
    required this.lockedAt,
    this.reason,
  });

  final DateTime lockedAt;
  final String? reason;

  @override
  String get name => 'LOCKED';

  @override
  bool get needsAttention => true;
}

/// Session has expired
class SessionExpired extends SessionState {
  const SessionExpired({required this.expiredAt});

  final DateTime expiredAt;

  @override
  String get name => 'EXPIRED';

  @override
  bool get needsAttention => true;

  @override
  bool get isTerminal => true;
}

/// Awaiting biometric authentication
class SessionBiometricPrompt extends SessionState {
  const SessionBiometricPrompt({
    required this.promptedAt,
    required this.reason,
  });

  final DateTime promptedAt;
  final String reason;

  @override
  String get name => 'BIOMETRIC_PROMPT';

  @override
  bool get needsAttention => true;
}

/// New device detected
class SessionDeviceChanged extends SessionState {
  const SessionDeviceChanged({
    required this.deviceId,
    required this.detectedAt,
  });

  final String deviceId;
  final DateTime detectedAt;

  @override
  String get name => 'DEVICE_CHANGED';

  @override
  bool get needsAttention => true;
}

/// Session conflict (logged in elsewhere)
class SessionConflict extends SessionState {
  const SessionConflict({
    required this.conflictingDeviceId,
    required this.conflictDetectedAt,
  });

  final String conflictingDeviceId;
  final DateTime conflictDetectedAt;

  @override
  String get name => 'CONFLICT';

  @override
  bool get needsAttention => true;
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════

sealed class SessionEvent extends FsmEvent {
  const SessionEvent();
}

/// Start a new session
class SessionStart extends SessionEvent {
  const SessionStart({
    this.timeout = const Duration(minutes: 30),
    this.warningTime = const Duration(seconds: 30),
  });

  final Duration timeout;
  final Duration warningTime;

  @override
  String get name => 'START';
}

/// Record user activity
class SessionActivity extends SessionEvent {
  const SessionActivity();

  @override
  String get name => 'ACTIVITY';
}

/// App went to background
class SessionBackground extends SessionEvent {
  const SessionBackground();

  @override
  String get name => 'BACKGROUND';
}

/// App came to foreground
class SessionForeground extends SessionEvent {
  const SessionForeground();

  @override
  String get name => 'FOREGROUND';
}

/// Session timeout warning triggered
class SessionTimeoutWarning extends SessionEvent {
  const SessionTimeoutWarning({required this.remainingSeconds});

  final int remainingSeconds;

  @override
  String get name => 'TIMEOUT_WARNING';
}

/// User extended session
class SessionExtend extends SessionEvent {
  const SessionExtend();

  @override
  String get name => 'EXTEND';
}

/// Lock session (manual or auto)
class SessionLock extends SessionEvent {
  const SessionLock({this.reason});

  final String? reason;

  @override
  String get name => 'LOCK';
}

/// Unlock session with PIN/biometric
class SessionUnlock extends SessionEvent {
  const SessionUnlock();

  @override
  String get name => 'UNLOCK';
}

/// Session expired
class SessionExpire extends SessionEvent {
  const SessionExpire();

  @override
  String get name => 'EXPIRE';
}

/// End session (logout)
class SessionEnd extends GlobalFsmEvent {
  const SessionEnd();

  @override
  String get name => 'END';
}

/// Request biometric authentication
class SessionRequestBiometric extends SessionEvent {
  const SessionRequestBiometric({required this.reason});

  final String reason;

  @override
  String get name => 'REQUEST_BIOMETRIC';
}

/// Biometric authentication succeeded
class SessionBiometricSuccess extends SessionEvent {
  const SessionBiometricSuccess();

  @override
  String get name => 'BIOMETRIC_SUCCESS';
}

/// Biometric authentication failed
class SessionBiometricFailed extends SessionEvent {
  const SessionBiometricFailed();

  @override
  String get name => 'BIOMETRIC_FAILED';
}

/// Device changed detected
class SessionDeviceChangedEvent extends SessionEvent {
  const SessionDeviceChangedEvent({required this.deviceId});

  final String deviceId;

  @override
  String get name => 'DEVICE_CHANGED';
}

/// Device verified
class SessionDeviceVerified extends SessionEvent {
  const SessionDeviceVerified();

  @override
  String get name => 'DEVICE_VERIFIED';
}

/// Session conflict detected
class SessionConflictDetected extends SessionEvent {
  const SessionConflictDetected({required this.conflictingDeviceId});

  final String conflictingDeviceId;

  @override
  String get name => 'CONFLICT_DETECTED';
}

/// Resolve session conflict (force logout other session)
class SessionResolveConflict extends SessionEvent {
  const SessionResolveConflict();

  @override
  String get name => 'RESOLVE_CONFLICT';
}

// ═══════════════════════════════════════════════════════════════════
// FSM DEFINITION
// ═══════════════════════════════════════════════════════════════════

class SessionFsm extends FsmDefinition<SessionState, SessionEvent> {
  @override
  SessionState get initialState => const SessionNone();

  @override
  TransitionResult<SessionState> handleGlobal(
    SessionState currentState,
    GlobalFsmEvent event,
  ) {
    if (event is SessionEnd) {
      return TransitionSuccess(
        const SessionNone(),
        effects: [
          const ClearEffect('session'),
          const NavigateEffect('/login'),
        ],
      );
    }
    return super.handleGlobal(currentState, event);
  }

  @override
  TransitionResult<SessionState> handle(
    SessionState currentState,
    SessionEvent event,
  ) {
    return switch (currentState) {
      SessionNone() => _handleNone(currentState, event),
      SessionActive() => _handleActive(currentState, event),
      SessionBackgrounded() => _handleBackgrounded(currentState, event),
      SessionExpiring() => _handleExpiring(currentState, event),
      SessionLocked() => _handleLocked(currentState, event),
      SessionExpired() => _handleExpired(currentState, event),
      SessionBiometricPrompt() => _handleBiometricPrompt(currentState, event),
      SessionDeviceChanged() => _handleDeviceChanged(currentState, event),
      SessionConflict() => _handleConflict(currentState, event),
    };
  }

  TransitionResult<SessionState> _handleNone(
    SessionNone state,
    SessionEvent event,
  ) {
    if (event is SessionStart) {
      return TransitionSuccess(
        SessionActive(
          startedAt: DateTime.now(),
          lastActivity: DateTime.now(),
          timeout: event.timeout,
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<SessionState> _handleActive(
    SessionActive state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionActivity():
        return TransitionSuccess(state.recordActivity());

      case SessionBackground():
        return TransitionSuccess(
          SessionBackgrounded(
            startedAt: state.startedAt,
            backgroundedAt: DateTime.now(),
            timeout: const Duration(minutes: 5), // Shorter timeout in background
          ),
        );

      case SessionTimeoutWarning():
        return TransitionSuccess(
          SessionExpiring(
            remainingSeconds: event.remainingSeconds,
            expiresAt: DateTime.now().add(Duration(seconds: event.remainingSeconds)),
          ),
        );

      case SessionLock():
        return TransitionSuccess(
          SessionLocked(
            lockedAt: DateTime.now(),
            reason: event.reason,
          ),
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NotifyEffect('Session expired. Please log in again.', type: NotifyType.warning),
          ],
        );

      case SessionRequestBiometric():
        return TransitionSuccess(
          SessionBiometricPrompt(
            promptedAt: DateTime.now(),
            reason: event.reason,
          ),
        );

      case SessionDeviceChangedEvent():
        return TransitionSuccess(
          SessionDeviceChanged(
            deviceId: event.deviceId,
            detectedAt: DateTime.now(),
          ),
          effects: [
            const NotifyEffect('New device detected. Please verify your identity.', type: NotifyType.warning),
          ],
        );

      case SessionConflictDetected():
        return TransitionSuccess(
          SessionConflict(
            conflictingDeviceId: event.conflictingDeviceId,
            conflictDetectedAt: DateTime.now(),
          ),
          effects: [
            const NotifyEffect('Your account is logged in on another device.', type: NotifyType.warning),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleBackgrounded(
    SessionBackgrounded state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionForeground():
        // Check if we should lock
        final elapsed = DateTime.now().difference(state.backgroundedAt);
        if (elapsed > state.timeout) {
          return TransitionSuccess(
            SessionLocked(
              lockedAt: DateTime.now(),
              reason: 'App was in background too long',
            ),
          );
        }
        return TransitionSuccess(
          SessionActive(
            startedAt: state.startedAt,
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleExpiring(
    SessionExpiring state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionExtend():
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
        );

      case SessionActivity():
        // Activity also extends
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NavigateEffect('/login'),
            const NotifyEffect('Session expired', type: NotifyType.warning),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleLocked(
    SessionLocked state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionUnlock():
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NavigateEffect('/login'),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleExpired(
    SessionExpired state,
    SessionEvent event,
  ) {
    // Expired is terminal - only reset/logout can transition out
    return const TransitionNotApplicable();
  }

  TransitionResult<SessionState> _handleBiometricPrompt(
    SessionBiometricPrompt state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionBiometricSuccess():
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
        );

      case SessionBiometricFailed():
        return TransitionSuccess(
          SessionLocked(
            lockedAt: DateTime.now(),
            reason: 'Biometric authentication failed',
          ),
          effects: [
            const NotifyEffect('Biometric authentication failed', type: NotifyType.error),
          ],
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NavigateEffect('/login'),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleDeviceChanged(
    SessionDeviceChanged state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionDeviceVerified():
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
          effects: [
            const NotifyEffect('Device verified', type: NotifyType.success),
          ],
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NavigateEffect('/login'),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }

  TransitionResult<SessionState> _handleConflict(
    SessionConflict state,
    SessionEvent event,
  ) {
    switch (event) {
      case SessionResolveConflict():
        return TransitionSuccess(
          SessionActive(
            startedAt: DateTime.now(),
            lastActivity: DateTime.now(),
            timeout: const Duration(minutes: 30),
          ),
          effects: [
            const FetchEffect('session/force-logout-other'),
            const NotifyEffect('Other session logged out', type: NotifyType.success),
          ],
        );

      case SessionExpire():
        return TransitionSuccess(
          SessionExpired(expiredAt: DateTime.now()),
          effects: [
            const ClearEffect('session'),
            const NavigateEffect('/login'),
          ],
        );

      default:
        return const TransitionNotApplicable();
    }
  }
}
