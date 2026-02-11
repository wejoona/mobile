import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';
import 'package:usdc_wallet/state/fsm/kyc_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │               FSM + RIVERPOD INTEGRATION                         │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │  This file connects the FSM system to Riverpod providers.       │
/// │                                                                  │
/// │  Architecture:                                                  │
/// │  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐    │
/// │  │   UI/Widgets │────▶│  FSMNotifier │────▶│    FSM       │    │
/// │  └──────────────┘     └──────┬───────┘     └──────────────┘    │
/// │         ▲                    │                                  │
/// │         │                    ▼                                  │
/// │         │             ┌──────────────┐                          │
/// │         └─────────────│EffectHandler │                          │
/// │                       └──────────────┘                          │
/// │                                                                  │
/// │  Benefits:                                                      │
/// │  • FSM is pure logic (easily testable)                          │
/// │  • Effects are handled separately (API calls, navigation)       │
/// │  • State changes trigger UI updates via Riverpod                │
/// │  • All transitions are logged for debugging                     │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

final _logger = AppLogger('FSM');

// ═══════════════════════════════════════════════════════════════════
// FSM NOTIFIER BASE
// ═══════════════════════════════════════════════════════════════════

/// Base class for FSM-backed Riverpod notifiers
abstract class FsmNotifier<S extends FsmState, E extends FsmEvent>
    extends Notifier<S> {
  /// The FSM definition
  FsmDefinition<S, E> get fsm;

  /// Handle side effects from transitions
  void handleEffects(List<FsmEffect> effects);

  @override
  S build() => fsm.initialState;

  /// Dispatch an event to the FSM
  void dispatch(E event) {
    _logger.debug('Dispatching: ${event.name} in state: ${state.name}');

    final result = fsm.process(state, event);

    switch (result) {
      case TransitionSuccess<S>():
        _logger.info(
          'Transition: ${state.name} -> ${result.newState.name} via ${event.name}',
        );
        state = result.newState;
        if (result.effects != null && result.effects!.isNotEmpty) {
          handleEffects(result.effects!);
        }

      case TransitionDenied<S>():
        _logger.warn('Transition denied: ${event.name} - ${result.reason}');

      case TransitionNotApplicable<S>():
        _logger.debug(
          'Event not applicable: ${event.name} in state: ${state.name}',
        );
    }
  }

  /// Dispatch a global event (reset, logout)
  void dispatchGlobal(GlobalFsmEvent event) {
    _logger.debug('Dispatching global: ${event.name}');

    final result = fsm.handleGlobal(state, event);

    if (result is TransitionSuccess<S>) {
      _logger.info('Global transition: ${state.name} -> ${result.newState.name}');
      state = result.newState;
      if (result.effects != null && result.effects!.isNotEmpty) {
        handleEffects(result.effects!);
      }
    }
  }

  /// Reset to initial state
  void reset() => dispatchGlobal(const ResetEvent());
}

// ═══════════════════════════════════════════════════════════════════
// APP FSM NOTIFIER
// ═══════════════════════════════════════════════════════════════════

/// Main app FSM notifier that orchestrates all sub-FSMs
class AppFsmNotifier extends FsmNotifier<AppState, AppEvent> {
  final _appFsm = AppFsm();

  @override
  FsmDefinition<AppState, AppEvent> get fsm => _appFsm;

  @override
  void handleEffects(List<FsmEffect> effects) {
    for (final effect in effects) {
      _handleEffect(effect);
    }
  }

  void _handleEffect(FsmEffect effect) {
    _logger.debug('Handling effect: ${effect.name}');

    switch (effect) {
      case FetchEffect():
        _handleFetch(effect.resource);

      case NavigateEffect():
        _handleNavigate(effect.route);

      case ClearEffect():
        _handleClear(effect.target);

      case NotifyEffect():
        _handleNotify(effect.message, effect.type);
    }
  }

  void _handleFetch(String resource) {
    _logger.debug('Fetch effect: $resource');

    // Use a microtask to avoid calling during build
    Future.microtask(() {
      try {
        if (resource == 'wallet/create') {
          // Wallet creation request
          ref.read(walletStateMachineProvider.notifier).createWallet();
        } else if (resource == 'wallet' || resource.startsWith('wallet')) {
          // Wallet fetch request
          ref.read(walletStateMachineProvider.notifier).fetch();
        } else if (resource == 'kyc/status' || resource.startsWith('kyc')) {
          // KYC status fetch request
          ref.read(kycStateMachineProvider.notifier).fetch();
        }
      } catch (e) {
        _logger.error('Failed to trigger fetch for $resource', e);
      }
    });
  }

  void _handleNavigate(String route) {
    _logger.debug('Navigate effect: $route');
    // Navigation is handled via RouterRefreshNotifier
  }

  void _handleClear(String target) {
    _logger.debug('Clear effect: $target');
    // Clear data from storage/cache
  }

  void _handleNotify(String message, NotifyType type) {
    _logger.debug('Notify effect: $message ($type)');
    // Show snackbar or toast
  }

  // ─────────────────────────────────────────────────────────────────
  // Convenience methods for dispatching sub-FSM events
  // ─────────────────────────────────────────────────────────────────

  /// Auth events
  void login(String phone, String countryCode) {
    dispatch(AppAuthEvent(AuthLogin(phone: phone, countryCode: countryCode)));
  }

  void verifyOtp(String otp) {
    dispatch(AppAuthEvent(AuthVerifyOtp(otp: otp)));
  }

  void logout() {
    dispatchGlobal(const AppLogout());
  }

  /// Called when OTP is received from API
  void onOtpReceived({int? expiresIn}) {
    dispatch(AppAuthEvent(AuthOtpReceived(expiresIn: expiresIn)));
  }

  /// Called when auth verification succeeds
  void onAuthVerified({
    required String userId,
    required String accessToken,
    String? refreshToken,
  }) {
    dispatch(AppAuthEvent(AuthVerified(
      userId: userId,
      accessToken: accessToken,
      refreshToken: refreshToken,
    )));
  }

  /// Called when auth fails
  void onAuthFailed(String message, {dynamic data}) {
    dispatch(AppAuthEvent(AuthFailed(message: message, data: data)));
  }

  /// Wallet events
  void fetchWallet() {
    dispatch(const AppWalletEvent(WalletFetch()));
  }

  void createWallet() {
    dispatch(const AppWalletEvent(WalletCreate()));
  }

  /// Called when wallet is loaded from API
  void onWalletLoaded({
    required String walletId,
    String? walletAddress,
    String blockchain = 'polygon',
    required double usdcBalance,
    double pendingBalance = 0,
  }) {
    dispatch(AppWalletEvent(WalletLoaded(
      walletId: walletId,
      walletAddress: walletAddress,
      blockchain: blockchain,
      usdcBalance: usdcBalance,
      pendingBalance: pendingBalance,
    )));
  }

  /// Called when wallet is not found (404)
  void onWalletNotFound() {
    dispatch(const AppWalletEvent(WalletNotFound()));
  }

  /// Called when wallet is created
  void onWalletCreated({
    required String walletId,
    String? walletAddress,
    String blockchain = 'polygon',
  }) {
    dispatch(AppWalletEvent(WalletCreated(
      walletId: walletId,
      walletAddress: walletAddress,
      blockchain: blockchain,
    )));
  }

  /// Called when wallet operation fails
  void onWalletFailed(String message, {dynamic data}) {
    dispatch(AppWalletEvent(WalletFailed(message: message, data: data)));
  }

  /// KYC events
  void fetchKyc() {
    dispatch(const AppKycEvent(KycFetch()));
  }

  void startKyc({KycTier targetTier = KycTier.tier1}) {
    dispatch(AppKycEvent(KycStart(targetTier: targetTier)));
  }

  /// Called when KYC status is loaded
  void onKycStatusLoaded({
    required KycTier tier,
    required String status,
    String? rejectionReason,
    DateTime? verifiedAt,
  }) {
    dispatch(AppKycEvent(KycStatusLoaded(
      tier: tier,
      status: status,
      rejectionReason: rejectionReason,
      verifiedAt: verifiedAt,
    )));
  }

  // ─────────────────────────────────────────────────────────────────
  // Route guards
  // ─────────────────────────────────────────────────────────────────

  /// Check if a route is accessible
  GuardResult canAccessRoute(String route) {
    return AppGuards(state).canAccessRoute(route);
  }

  /// Get redirect for current state (for router)
  String? getRedirect(String currentRoute) {
    final targetScreen = state.currentScreen;
    if (currentRoute != targetScreen.route) {
      return targetScreen.route;
    }
    return null;
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════

/// Main app FSM provider
final appFsmProvider = NotifierProvider<AppFsmNotifier, AppState>(
  AppFsmNotifier.new,
);

/// Convenience providers for derived state
final isAuthenticatedFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).isAuthenticated;
});

final hasWalletFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).hasWallet;
});

final needsWalletCreationFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).needsWalletCreation;
});

final kycTierFsmProvider = Provider<KycTier>((ref) {
  return ref.watch(appFsmProvider).kycTier;
});

final canDepositFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).canDeposit;
});

final canWithdrawFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).canWithdraw;
});

final currentScreenFsmProvider = Provider<AppScreen>((ref) {
  return ref.watch(appFsmProvider).currentScreen;
});

final isLoadingFsmProvider = Provider<bool>((ref) {
  return ref.watch(appFsmProvider).isLoading;
});

// ═══════════════════════════════════════════════════════════════════
// ROUTER INTEGRATION
// ═══════════════════════════════════════════════════════════════════

/// Router refresh notifier that listens to FSM state changes
class FsmRouterRefreshNotifier extends ChangeNotifier {
  FsmRouterRefreshNotifier(Ref ref) {
    ref.listen(appFsmProvider, (previous, next) {
      // Only notify if the target screen changed
      if (previous?.currentScreen != next.currentScreen) {
        _logger.debug(
          'Router refresh: ${previous?.currentScreen} -> ${next.currentScreen}',
        );
        notifyListeners();
      }
    });
  }
}

final fsmRouterRefreshProvider = Provider<FsmRouterRefreshNotifier>((ref) {
  return FsmRouterRefreshNotifier(ref);
});

/// Get redirect for GoRouter based on FSM state
String? fsmRedirect(BuildContext context, GoRouterState routerState) {
  final container = ProviderScope.containerOf(context);
  final appState = container.read(appFsmProvider);
  final currentRoute = routerState.matchedLocation;

  // Check guards
  final guardResult = AppGuards(appState).canAccessRoute(currentRoute);

  if (guardResult is GuardDenied) {
    _logger.debug(
      'Route guard denied: $currentRoute -> ${guardResult.redirectTo} (${guardResult.reason})',
    );
    return guardResult.redirectTo;
  }

  return null;
}
