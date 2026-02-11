import 'package:flutter/material.dart';

/// Run 369: Custom hero flight shuttle builders for smooth page transitions
class KoridoHeroTransitions {
  KoridoHeroTransitions._();

  /// Fade transition for hero widgets during route changes
  static Widget fadeHeroFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    return FadeTransition(
      opacity: animation.drive(CurveTween(curve: Curves.easeInOut)),
      child: toHeroContext.widget,
    );
  }

  /// Scale and fade transition
  static Widget scaleHeroFlightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCubic,
    );
    return ScaleTransition(
      scale: Tween(begin: 0.85, end: 1.0).animate(curvedAnimation),
      child: FadeTransition(
        opacity: curvedAnimation,
        child: toHeroContext.widget,
      ),
    );
  }
}

/// Shared element page route with custom hero animation
class SharedElementPageRoute<T> extends PageRouteBuilder<T> {
  SharedElementPageRoute({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) : super(
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
        );
}

/// Bottom-to-top modal route for detail views
class BottomSheetRoute<T> extends PageRouteBuilder<T> {
  BottomSheetRoute({required Widget page})
      : super(
          opaque: false,
          barrierColor: Colors.black54,
          barrierDismissible: true,
          transitionDuration: const Duration(milliseconds: 350),
          reverseTransitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ));
            return SlideTransition(position: slide, child: child);
          },
        );
}
