import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension on BuildContext for safe navigation operations
extension SafeNavigation on BuildContext {
  /// Safely pops the current route if possible, otherwise navigates to fallback.
  ///
  /// Use this instead of `context.pop()` to avoid GoError when there's nothing to pop.
  ///
  /// [fallbackRoute] - Route to navigate to if there's nothing to pop (default: '/home')
  void safePop({String fallbackRoute = '/home'}) {
    if (canPop()) {
      pop();
    } else {
      go(fallbackRoute);
    }
  }

  /// Safely pops with a result if possible, otherwise navigates to fallback.
  void safePopWithResult<T>(T result, {String fallbackRoute = '/home'}) {
    if (canPop()) {
      pop(result);
    } else {
      go(fallbackRoute);
    }
  }
}
