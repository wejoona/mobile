import 'package:flutter/material.dart';

/// Animation utility functions and helpers
class AnimationUtils {
  AnimationUtils._();

  /// Standard animation duration for micro-interactions
  static const Duration microDuration = Duration(milliseconds: 150);

  /// Standard animation duration for element transitions
  static const Duration standardDuration = Duration(milliseconds: 300);

  /// Standard animation duration for page transitions
  static const Duration pageDuration = Duration(milliseconds: 400);

  /// Long animation duration for complex animations
  static const Duration longDuration = Duration(milliseconds: 600);

  /// Standard easing curve (Material Design)
  static const Curve standardCurve = Curves.easeInOut;

  /// Deceleration curve (ease out)
  static const Curve decelerationCurve = Curves.easeOut;

  /// Acceleration curve (ease in)
  static const Curve accelerationCurve = Curves.easeIn;

  /// Sharp curve for quick transitions
  static const Curve sharpCurve = Curves.easeInOutCubic;

  /// Emphasized curve for hero elements
  static const Curve emphasizedCurve = Curves.easeOutBack;

  /// Bounce curve for playful interactions
  static const Curve bounceCurve = Curves.bounceOut;

  /// Elastic curve for attention-grabbing animations
  static const Curve elasticCurve = Curves.elasticOut;

  /// Creates a delayed animation with automatic disposal
  static Future<void> delayedAnimation({
    required Duration delay,
    required VoidCallback callback,
  }) async {
    await Future.delayed(delay);
    callback();
  }

  /// Stagger animations for list items
  static Duration getStaggerDelay(int index, {Duration baseDelay = const Duration(milliseconds: 50)}) {
    return baseDelay * index;
  }

  /// Create a curve that respects reduced motion preferences
  static Curve getAccessibleCurve(bool respectReducedMotion) {
    if (respectReducedMotion) {
      return Curves.linear;
    }
    return standardCurve;
  }

  /// Create a duration that respects reduced motion preferences
  static Duration getAccessibleDuration(
    Duration duration,
    bool respectReducedMotion,
  ) {
    if (respectReducedMotion) {
      return Duration.zero;
    }
    return duration;
  }
}

/// Animation controller extension for common patterns
extension AnimationControllerExtensions on AnimationController {
  /// Play animation forward then reverse
  Future<void> playAndReverse() async {
    await forward();
    await reverse();
  }

  /// Loop animation with a specific number of times
  Future<void> loopTimes(int times) async {
    for (int i = 0; i < times; i++) {
      await forward();
      await reverse();
    }
  }

  /// Shake animation pattern
  Future<void> shake({int times = 3}) async {
    for (int i = 0; i < times; i++) {
      await forward();
      await reverse();
    }
  }
}

/// Tween builder helpers
class TweenUtils {
  TweenUtils._();

  /// Create a color tween
  static ColorTween colorTween({
    required Color begin,
    required Color end,
  }) {
    return ColorTween(begin: begin, end: end);
  }

  /// Create an offset tween for slide animations
  static Tween<Offset> slideTween({
    required Offset begin,
    Offset end = Offset.zero,
  }) {
    return Tween<Offset>(begin: begin, end: end);
  }

  /// Create a double tween
  static Tween<double> doubleTween({
    required double begin,
    required double end,
  }) {
    return Tween<double>(begin: begin, end: end);
  }

  /// Create a size tween
  static Tween<Size> sizeTween({
    required Size begin,
    required Size end,
  }) {
    return Tween<Size>(begin: begin, end: end);
  }
}

/// Implicit animation wrapper
class ImplicitAnimationWrapper extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ImplicitAnimationWrapper({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      child: child,
    );
  }
}

/// Cross-fade transition between two widgets
class CrossFadeTransition extends StatelessWidget {
  final bool showFirst;
  final Widget firstChild;
  final Widget secondChild;
  final Duration duration;

  const CrossFadeTransition({
    super.key,
    required this.showFirst,
    required this.firstChild,
    required this.secondChild,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: firstChild,
      secondChild: secondChild,
      crossFadeState:
          showFirst ? CrossFadeState.showFirst : CrossFadeState.showSecond,
      duration: duration,
    );
  }
}

/// Animated visibility wrapper
class AnimatedVisibility extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedVisibility({
    super.key,
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: duration,
      curve: curve,
      child: visible ? child : const SizedBox.shrink(),
    );
  }
}

/// Slide and fade combined transition
class SlideFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final Offset slideOffset;

  const SlideFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.slideOffset = const Offset(0, 0.1),
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: slideOffset,
        end: Offset.zero,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}

/// Rotation fade transition
class RotationFadeTransition extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double turns;

  const RotationFadeTransition({
    super.key,
    required this.animation,
    required this.child,
    this.turns = 0.125,
  });

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: Tween<double>(
        begin: turns,
        end: 0.0,
      ).animate(animation),
      child: FadeTransition(
        opacity: animation,
        child: child,
      ),
    );
  }
}
