import 'package:flutter/material.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Extension on BuildContext for safe navigation operations
extension SafeNavigation on BuildContext {
  /// Safely pops the current route if possible, otherwise navigates to fallback.
  ///
  /// Use this instead of `context.fsmPop()` to avoid GoError when there's nothing to pop.
  ///
  /// [fallbackRoute] - Route to navigate to if there's nothing to pop (default: '/home')
  void safePop({String fallbackRoute = '/home'}) {
    fsmSafePop(fallbackRoute: fallbackRoute);
  }

  /// Safely pops with a result if possible, otherwise navigates to fallback.
  void safePopWithResult<T>(T result, {String fallbackRoute = '/home'}) {
    fsmPopWithResult<T>(result, fallbackRoute: fallbackRoute);
  }

  /// Enters the authenticated app and clears any imperative auth pages left
  /// behind by OTP/PIN/biometric flows, so iOS edge-swipe cannot reveal login.
  void enterAuthenticatedApp({String route = '/home'}) {
    fsmEnterAuthenticatedApp(route: route);
  }
}
