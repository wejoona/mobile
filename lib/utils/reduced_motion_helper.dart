import 'package:flutter/material.dart';

/// Helper for respecting user's reduced motion preferences (WCAG 2.1 - 2.3.3)
///
/// Usage:
/// ```dart
/// AnimatedContainer(
///   duration: ReducedMotionHelper.getDuration(context),
///   // ...
/// )
/// ```
class ReducedMotionHelper {
  ReducedMotionHelper._();

  /// Get animation duration respecting reduced motion setting
  ///
  /// Returns Duration.zero if reduced motion is enabled, otherwise returns normal duration
  static Duration getDuration(
    BuildContext context, {
    Duration normal = const Duration(milliseconds: 300),
    Duration? reduced,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return reduced ?? Duration.zero;
    }

    return normal;
  }

  /// Check if reduced motion is enabled
  static bool isReducedMotionEnabled(BuildContext context) {
    return MediaQuery.disableAnimationsOf(context);
  }

  /// Get curve respecting reduced motion setting
  ///
  /// Returns linear curve if reduced motion enabled, otherwise returns normal curve
  static Curve getCurve(
    BuildContext context, {
    Curve normal = Curves.easeInOut,
    Curve? reduced,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return reduced ?? Curves.linear;
    }

    return normal;
  }

  /// Create animated builder respecting reduced motion
  ///
  /// Skips animation if reduced motion is enabled
  static Widget animatedBuilder({
    required BuildContext context,
    required Widget Function(BuildContext, Animation<double>) builder,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      // Return static widget at end state
      return builder(context, const AlwaysStoppedAnimation(1.0));
    }

    // Return animated widget
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return builder(context, AlwaysStoppedAnimation(value));
      },
    );
  }

  /// Page transition respecting reduced motion
  ///
  /// Returns instant transition if reduced motion enabled
  static PageRoute<T> pageRoute<T>({
    required BuildContext context,
    required Widget page,
    PageTransitionType type = PageTransitionType.slide,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      // Instant transition
      return PageRouteBuilder<T>(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      );
    }

    // Animated transition
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _buildTransition(
          type: type,
          animation: animation,
          child: child,
        );
      },
    );
  }

  /// Build transition animation based on type
  static Widget _buildTransition({
    required PageTransitionType type,
    required Animation<double> animation,
    required Widget child,
  }) {
    switch (type) {
      case PageTransitionType.fade:
        return FadeTransition(
          opacity: animation,
          child: child,
        );

      case PageTransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case PageTransitionType.scale:
        return ScaleTransition(
          scale: animation,
          child: child,
        );

      case PageTransitionType.rotation:
        return RotationTransition(
          turns: animation,
          child: child,
        );
    }
  }

  /// Animated opacity respecting reduced motion
  static Widget animatedOpacity({
    required BuildContext context,
    required Widget child,
    required bool visible,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: getDuration(context, normal: duration),
      curve: getCurve(context, normal: curve),
      child: child,
    );
  }

  /// Animated container respecting reduced motion
  static Widget animatedContainer({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    Color? color,
    Decoration? decoration,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    AlignmentGeometry? alignment,
  }) {
    return AnimatedContainer(
      duration: getDuration(context, normal: duration),
      curve: getCurve(context, normal: curve),
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      alignment: alignment,
      child: child,
    );
  }

  /// Fade in animation respecting reduced motion
  static Widget fadeIn({
    required BuildContext context,
    required Widget child,
    Duration duration = const Duration(milliseconds: 500),
    Duration delay = Duration.zero,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide in animation respecting reduced motion
  static Widget slideIn({
    required BuildContext context,
    required Widget child,
    Offset begin = const Offset(0.0, 0.2),
    Duration duration = const Duration(milliseconds: 500),
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return child;
    }

    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: Offset.zero),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Scale in animation respecting reduced motion
  static Widget scaleIn({
    required BuildContext context,
    required Widget child,
    double begin = 0.8,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: 1.0),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Stagger animation for list items
  ///
  /// Skips stagger if reduced motion enabled
  static Duration getStaggerDelay({
    required BuildContext context,
    required int index,
    Duration baseDelay = const Duration(milliseconds: 50),
    int maxDelay = 5,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      return Duration.zero;
    }

    final actualIndex = index.clamp(0, maxDelay);
    return baseDelay * actualIndex;
  }

  /// Loading spinner respecting reduced motion
  ///
  /// Slows down animation if reduced motion enabled (not stopped, as it's functional)
  static Duration getSpinnerDuration(BuildContext context) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      // Slower but still visible to indicate loading
      return const Duration(milliseconds: 2000);
    }

    return const Duration(milliseconds: 1000);
  }

  /// Shimmer loading effect respecting reduced motion
  ///
  /// Returns static placeholder if reduced motion enabled
  static Widget shimmer({
    required BuildContext context,
    required Widget child,
    Color? baseColor,
    Color? highlightColor,
  }) {
    final disableAnimations =
        MediaQuery.disableAnimationsOf(context);

    if (disableAnimations) {
      // Return static placeholder
      return Opacity(
        opacity: 0.5,
        child: child,
      );
    }

    // Return shimmer effect (implementation would use shimmer package or custom)
    return child; // Placeholder - actual shimmer implementation needed
  }
}

/// Page transition types
enum PageTransitionType {
  fade,
  slide,
  scale,
  rotation,
}

/// Extension for easier access to reduced motion helper
extension ReducedMotionContext on BuildContext {
  /// Check if reduced motion is enabled
  bool get isReducedMotionEnabled {
    return ReducedMotionHelper.isReducedMotionEnabled(this);
  }

  /// Get duration respecting reduced motion
  Duration reducedMotionDuration({
    Duration normal = const Duration(milliseconds: 300),
    Duration? reduced,
  }) {
    return ReducedMotionHelper.getDuration(
      this,
      normal: normal,
      reduced: reduced,
    );
  }

  /// Get curve respecting reduced motion
  Curve reducedMotionCurve({
    Curve normal = Curves.easeInOut,
    Curve? reduced,
  }) {
    return ReducedMotionHelper.getCurve(
      this,
      normal: normal,
      reduced: reduced,
    );
  }
}
