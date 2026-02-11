import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom page transitions for GoRouter.
class FadePageTransition extends CustomTransitionPage<void> {
  FadePageTransition({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        );
}

class SlideUpPageTransition extends CustomTransitionPage<void> {
  SlideUpPageTransition({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

class SlideLeftPageTransition extends CustomTransitionPage<void> {
  SlideLeftPageTransition({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final tween = Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}

class ScalePageTransition extends CustomTransitionPage<void> {
  ScalePageTransition({required super.child, super.key})
      : super(
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final scale = Tween(begin: 0.95, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOutCubic));

            return ScaleTransition(
              scale: animation.drive(scale),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 250),
        );
}
