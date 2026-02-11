/// Route guards for authentication and KYC checks.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/route_names.dart';

/// Routes that do not require authentication.
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

/// Routes that require KYC tier 2+.
const _kycRequiredRoutes = {
  RouteNames.sendExternal,
  RouteNames.withdraw,
  RouteNames.bulkPayments,
  RouteNames.requestCard,
};

/// Check if a route requires authentication.
bool isPublicRoute(String routeName) => _publicRoutes.contains(routeName);

/// Check if a route requires KYC verification.
bool requiresKyc(String routeName) => _kycRequiredRoutes.contains(routeName);

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
    if (!_isPublicPath(currentRoute)) {
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

bool _isPublicPath(String path) {
  const publicPaths = [
    '/login',
    '/onboarding',
    '/splash',
    '/pay/',
  ];
  return publicPaths.any((p) => path.startsWith(p));
}
