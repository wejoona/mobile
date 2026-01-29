import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Page Transition Types
/// Defines contextual animations based on navigation hierarchy
enum TransitionType {
  /// Horizontal slide for same-level navigation (tabs, peer screens)
  horizontalSlide,

  /// Vertical slide up from bottom for modals and detail views
  verticalSlide,

  /// Fade for auth flows and settings sub-pages
  fade,

  /// No animation (instant)
  none,
}

/// Custom Page Transitions for GoRouter
///
/// Usage:
/// ```dart
/// GoRoute(
///   path: '/send',
///   pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
///     state: state,
///     child: const SendView(),
///   ),
/// ),
/// ```
class AppPageTransitions {
  AppPageTransitions._();

  // Animation durations
  static const Duration _slideTransitionDuration = Duration(milliseconds: 280);
  static const Duration _fadeTransitionDuration = Duration(milliseconds: 200);

  // Animation curves
  static const Curve _defaultCurve = Curves.fastOutSlowIn;

  /// Horizontal slide transition (left/right)
  /// Used for: Tab switching, same-level navigation
  static Page<dynamic> horizontalSlide({
    required GoRouterState state,
    required Widget child,
    bool slideFromRight = true,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: _slideTransitionDuration,
      reverseTransitionDuration: _slideTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = Offset(slideFromRight ? 1.0 : -1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: _defaultCurve,
        );

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }

  /// Vertical slide transition (up from bottom)
  /// Used for: Modals, detail views, bottom sheet-like pages
  static Page<dynamic> verticalSlide({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: _slideTransitionDuration,
      reverseTransitionDuration: _slideTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end);
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: _defaultCurve,
        );

        // Add fade for smoother appearance
        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition
  /// Used for: Auth flows, settings sub-pages
  static Page<dynamic> fade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: _fadeTransitionDuration,
      reverseTransitionDuration: _fadeTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale and fade transition for success/result screens
  /// Used for: Success screens, confirmation pages
  static Page<dynamic> scaleAndFade({
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: _slideTransitionDuration,
      reverseTransitionDuration: _slideTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: _defaultCurve,
        );

        return ScaleTransition(
          scale: Tween<double>(begin: 0.92, end: 1.0).animate(curvedAnimation),
          child: FadeTransition(
            opacity: curvedAnimation,
            child: child,
          ),
        );
      },
    );
  }

  /// No transition (instant)
  /// Used for: Initial routes, splash screens
  static Page<dynamic> none({
    required GoRouterState state,
    required Widget child,
  }) {
    return NoTransitionPage(
      key: state.pageKey,
      child: child,
    );
  }

  /// Shared axis transition (Material Design)
  /// Used for: Deep navigation hierarchies
  static Page<dynamic> sharedAxis({
    required GoRouterState state,
    required Widget child,
    bool isForward = true,
  }) {
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionDuration: _slideTransitionDuration,
      reverseTransitionDuration: _slideTransitionDuration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: _defaultCurve,
        );

        // Outgoing transition for secondary animation
        final secondaryCurved = CurvedAnimation(
          parent: secondaryAnimation,
          curve: _defaultCurve,
        );

        return Stack(
          children: [
            // Outgoing page (fade out)
            FadeTransition(
              opacity: Tween<double>(begin: 1.0, end: 0.0)
                  .animate(secondaryCurved),
              child: const SizedBox.expand(),
            ),
            // Incoming page (fade in + slide)
            SlideTransition(
              position: Tween<Offset>(
                begin: Offset(isForward ? 0.3 : -0.3, 0.0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(
                opacity: curvedAnimation,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Helper extension to determine transition type based on route
extension RouteTransitionHelper on String {
  /// Determines the appropriate transition type based on the route path
  TransitionType get transitionType {
    // No transition for splash/initial
    if (this == '/') return TransitionType.none;

    // Fade for auth flows
    if (this == '/login' ||
        this == '/otp' ||
        this == '/onboarding') {
      return TransitionType.fade;
    }

    // Horizontal slide for main tabs (same level)
    if (this == '/home' ||
        this == '/transactions' ||
        this == '/referrals' ||
        this == '/settings') {
      return TransitionType.horizontalSlide;
    }

    // Vertical slide for modals and action screens
    if (this == '/send' ||
        this == '/receive' ||
        this == '/withdraw' ||
        this == '/deposit' ||
        this == '/scan' ||
        this == '/scan-to-pay' ||
        this == '/request' ||
        this == '/split' ||
        this == '/airtime' ||
        this == '/bills' ||
        this == '/bill-payments' ||
        startsWith('/bill-payments/form')) {
      return TransitionType.verticalSlide;
    }

    // Vertical slide for detail views
    if (startsWith('/transactions/') ||
        this == '/notifications' ||
        this == '/deposit/instructions' ||
        startsWith('/alerts/')) {
      return TransitionType.verticalSlide;
    }

    // Fade for settings sub-pages
    if (startsWith('/settings/')) {
      return TransitionType.fade;
    }

    // Fade for service-related screens
    if (this == '/services' ||
        this == '/analytics' ||
        this == '/scheduled' ||
        this == '/recipients' ||
        this == '/converter' ||
        this == '/savings' ||
        this == '/card' ||
        this == '/budget' ||
        this == '/merchant-dashboard' ||
        startsWith('/merchant-')) {
      return TransitionType.fade;
    }

    // Default to horizontal slide
    return TransitionType.horizontalSlide;
  }

  /// Creates appropriate page transition based on route
  Page<dynamic> createTransitionPage({
    required GoRouterState state,
    required Widget child,
  }) {
    switch (transitionType) {
      case TransitionType.horizontalSlide:
        return AppPageTransitions.horizontalSlide(
          state: state,
          child: child,
        );
      case TransitionType.verticalSlide:
        return AppPageTransitions.verticalSlide(
          state: state,
          child: child,
        );
      case TransitionType.fade:
        return AppPageTransitions.fade(
          state: state,
          child: child,
        );
      case TransitionType.none:
        return AppPageTransitions.none(
          state: state,
          child: child,
        );
    }
  }
}

/// Success/confirmation screen transition helper
Page<dynamic> createSuccessTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return AppPageTransitions.scaleAndFade(
    state: state,
    child: child,
  );
}
