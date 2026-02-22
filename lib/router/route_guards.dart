/// Route guards for authentication and KYC checks.
library;

import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/route_names.dart';

/// Single source of truth: routes that do not require authentication.
/// NOTE: /pin/setup and /pin/confirm require auth (removed from public).
const _publicRoutes = {
  RouteNames.splash,
  RouteNames.login,
  RouteNames.loginOtp,
  RouteNames.onboarding,
  RouteNames.welcome,
  RouteNames.phoneInput,
  RouteNames.otpVerification,
  RouteNames.payLink,
};

/// Public route paths (derived from names for path-based checks).
const _publicPaths = [
  '/',
  '/login',
  '/onboarding',
  '/splash',
  '/pay/',
];

/// Routes that require KYC tier 2+.
const _kycRequiredRoutes = {
  RouteNames.sendExternal,
  RouteNames.withdraw,
  RouteNames.bulkPayments,
  RouteNames.requestCard,
};

/// Check if a route name is public (no auth required).
bool isPublicRoute(String routeName) => _publicRoutes.contains(routeName);

/// Check if a route requires KYC verification.
bool requiresKyc(String routeName) => _kycRequiredRoutes.contains(routeName);

/// Check if a path is public (for path-based redirect logic).
bool isPublicPath(String path) {
  return _publicPaths.any((p) => path.startsWith(p));
}

/// GoRouter redirect function for auth guards.
String? authRedirect({
  required GoRouterState state,
  required bool isAuthenticated,
  required bool hasCompletedOnboarding,
  required bool isAppLocked,
}) {
  final currentRoute = state.matchedLocation;

  // If app is locked, redirect to PIN
  if (isAppLocked && !currentRoute.contains('pin')) {
    return '/enter-pin';
  }

  // If not authenticated and trying to access protected route
  if (!isAuthenticated) {
    if (!isPublicPath(currentRoute)) {
      return '/login';
    }
    return null;
  }

  // If authenticated but hasn't completed onboarding
  if (!hasCompletedOnboarding && !currentRoute.startsWith('/onboarding')) {
    return '/onboarding';
  }

  // If authenticated and on login page, redirect to home
  if (isAuthenticated && currentRoute == '/login') {
    return '/';
  }

  return null;
}
