import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// États d'authentification possibles.
enum AuthState {
  unauthenticated,
  authenticating,
  mfaRequired,
  stepUpRequired,
  authenticated,
  locked,
  expired,
}

/// Manages auth state transitions.
class AuthStateMachine extends StateNotifier<AuthState> {
  static const _tag = 'AuthStateMachine';
  final AppLogger _log = AppLogger(_tag);

  AuthStateMachine() : super(AuthState.unauthenticated);

  static const _validTransitions = {
    AuthState.unauthenticated: [AuthState.authenticating],
    AuthState.authenticating: [
      AuthState.authenticated,
      AuthState.mfaRequired,
      AuthState.unauthenticated,
    ],
    AuthState.mfaRequired: [
      AuthState.authenticated,
      AuthState.unauthenticated,
      AuthState.locked,
    ],
    AuthState.stepUpRequired: [AuthState.authenticated],
    AuthState.authenticated: [
      AuthState.stepUpRequired,
      AuthState.expired,
      AuthState.unauthenticated,
      AuthState.locked,
    ],
    AuthState.locked: [AuthState.unauthenticated],
    AuthState.expired: [AuthState.unauthenticated, AuthState.authenticating],
  };

  bool canTransition(AuthState to) {
    return _validTransitions[state]?.contains(to) ?? false;
  }

  bool transition(AuthState to) {
    if (!canTransition(to)) {
      _log.warn('Invalid transition: ${state.name} -> ${to.name}');
      return false;
    }
    _log.debug('Auth: ${state.name} -> ${to.name}');
    state = to;
    return true;
  }
}

final authStateMachineProvider =
    StateNotifierProvider<AuthStateMachine, AuthState>((ref) {
  return AuthStateMachine();
});
