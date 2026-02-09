import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Animated theme switcher widget that wraps MaterialApp
/// Provides smooth transitions when theme changes occur
class AnimatedThemeSwitcher extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final ThemeData theme;
  final ThemeData? darkTheme;
  final ThemeMode themeMode;

  const AnimatedThemeSwitcher({
    super.key,
    required this.child,
    required this.theme,
    this.darkTheme,
    this.themeMode = ThemeMode.system,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedThemeSwitcher> createState() => _AnimatedThemeSwitcherState();

  /// Trigger a theme change with optional circular reveal animation
  static void of(BuildContext context, {
    required ThemeData newTheme,
    Offset? revealCenter,
    bool withCircularReveal = false,
  }) {
    final state = context.findAncestorStateOfType<_AnimatedThemeSwitcherState>();
    if (state == null) return;

    if (withCircularReveal && revealCenter != null) {
      state._performCircularReveal(newTheme, revealCenter);
    } else {
      state._performFadeTransition(newTheme);
    }
  }
}

class _AnimatedThemeSwitcherState extends State<AnimatedThemeSwitcher>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  ThemeData? _previousTheme;
  ThemeData? _nextTheme;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedThemeSwitcher oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-detect theme changes
    if (oldWidget.theme != widget.theme ||
        oldWidget.darkTheme != widget.darkTheme ||
        oldWidget.themeMode != widget.themeMode) {
      _performFadeTransition(_getCurrentTheme());
    }

    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  ThemeData _getCurrentTheme() {
    final brightness = MediaQuery.platformBrightnessOf(context);

    switch (widget.themeMode) {
      case ThemeMode.light:
        return widget.theme;
      case ThemeMode.dark:
        return widget.darkTheme ?? widget.theme;
      case ThemeMode.system:
        return brightness == Brightness.dark
            ? (widget.darkTheme ?? widget.theme)
            : widget.theme;
    }
  }

  void _performFadeTransition(ThemeData newTheme) {
    if (_isTransitioning) return;

    setState(() {
      _previousTheme = _getCurrentTheme();
      _nextTheme = newTheme;
      _isTransitioning = true;
    });

    _controller.forward(from: 0.0).then((_) {
      setState(() {
        _isTransitioning = false;
        _previousTheme = null;
        _nextTheme = null;
      });
    });
  }

  void _performCircularReveal(ThemeData newTheme, Offset center) {
    // Note: Circular reveal requires custom painter
    // For now, fall back to fade transition
    _performFadeTransition(newTheme);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isTransitioning) {
      return widget.child;
    }

    return Stack(
      children: [
        // Previous theme (fading out)
        if (_previousTheme != null)
          FadeTransition(
            opacity: ReverseAnimation(_fadeAnimation),
            child: widget.child,
          ),

        // Next theme (fading in)
        if (_nextTheme != null)
          FadeTransition(
            opacity: _fadeAnimation,
            child: widget.child,
          ),
      ],
    );
  }
}

/// Theme transition utilities for custom transition effects
class ThemeTransition {
  ThemeTransition._();

  /// Circular reveal transition from a specific point
  /// Typically used when triggered from a settings button
  static Widget circularReveal({
    required BuildContext context,
    required Offset center,
    required Widget child,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return ClipPath(
          clipper: _CircularRevealClipper(
            center: center,
            radius: value,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Fade transition for color changes
  static Widget fade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  /// Slide and fade transition
  static Widget slideAndFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 400),
    Curve curve = Curves.easeInOutCubic,
    Offset begin = const Offset(0, 0.05),
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            begin.dx * (1 - value),
            begin.dy * (1 - value),
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Scale and fade transition
  static Widget scaleAndFade({
    required Widget child,
    Duration duration = const Duration(milliseconds: 350),
    Curve curve = Curves.easeInOutCubic,
    double beginScale = 0.98,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final scale = beginScale + (1 - beginScale) * value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Animated color transition for smooth color changes
  static Widget animatedColor({
    required Widget child,
    required Color fromColor,
    required Color toColor,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return TweenAnimationBuilder<Color?>(
      tween: ColorTween(begin: fromColor, end: toColor),
      duration: duration,
      curve: curve,
      builder: (context, color, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            color ?? toColor,
            BlendMode.modulate,
          ),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Ripple effect transition from a point (like Material ripple)
  /// Perfect for theme toggle buttons
  static Widget ripple({
    required BuildContext context,
    required Widget child,
    required Offset center,
    Duration duration = const Duration(milliseconds: 500),
    Color? rippleColor,
  }) {
    final theme = Theme.of(context);
    final color = rippleColor ?? theme.primaryColor.withOpacity(0.3);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return CustomPaint(
          painter: _RipplePainter(
            center: center,
            radius: value,
            color: color,
          ),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Clipper for circular reveal animation
class _CircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircularRevealClipper({
    required this.center,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    // Calculate max radius to cover entire screen
    final maxRadius = _getMaxRadius(size);
    final currentRadius = maxRadius * radius;

    final path = Path();
    path.addOval(
      Rect.fromCircle(
        center: center,
        radius: currentRadius,
      ),
    );

    return path;
  }

  double _getMaxRadius(Size size) {
    // Distance from center to farthest corner using Pythagorean theorem
    final dx1 = center.dx;
    final dy1 = center.dy;
    final dx2 = size.width - center.dx;
    final dy2 = size.height - center.dy;

    // Calculate distance to each corner
    final distances = [
      math.sqrt(dx1 * dx1 + dy1 * dy1),           // Top-left
      math.sqrt(dx2 * dx2 + dy1 * dy1),           // Top-right
      math.sqrt(dx1 * dx1 + dy2 * dy2),           // Bottom-left
      math.sqrt(dx2 * dx2 + dy2 * dy2),           // Bottom-right
    ];

    // Return the maximum distance
    return distances.reduce(math.max);
  }

  @override
  bool shouldReclip(_CircularRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}

/// Painter for ripple effect
class _RipplePainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _RipplePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final maxRadius = _getMaxRadius(size);
    final currentRadius = maxRadius * radius;

    // Fade out as it expands
    final opacity = (1 - radius).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, currentRadius, paint);
  }

  double _getMaxRadius(Size size) {
    final dx1 = center.dx;
    final dy1 = center.dy;
    final dx2 = size.width - center.dx;
    final dy2 = size.height - center.dy;

    final distances = [
      math.sqrt(dx1 * dx1 + dy1 * dy1),
      math.sqrt(dx2 * dx2 + dy1 * dy1),
      math.sqrt(dx1 * dx1 + dy2 * dy2),
      math.sqrt(dx2 * dx2 + dy2 * dy2),
    ];

    return distances.reduce(math.max);
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.center != center ||
        oldDelegate.color != color;
  }
}

/// Smooth status bar transition controller
/// Handles animated transitions between light and dark status bar styles
class StatusBarTransition {
  StatusBarTransition._();

  static SystemUiOverlayStyle? _previousStyle;
  static bool _isTransitioning = false;

  /// Smoothly transition status bar style with color interpolation
  static Future<void> animate({
    required SystemUiOverlayStyle from,
    required SystemUiOverlayStyle to,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    if (_isTransitioning) return;
    _isTransitioning = true;

    try {
      // For smooth transitions, we'll use multiple steps
      // This creates a perceived smooth transition on both iOS and Android
      const steps = 10;
      final stepDuration = duration.inMilliseconds ~/ steps;

      for (int i = 0; i <= steps; i++) {
        final t = i / steps;

        // Interpolate colors
        final statusBarColor = Color.lerp(
          from.statusBarColor,
          to.statusBarColor,
          t,
        );

        final systemNavBarColor = Color.lerp(
          from.systemNavigationBarColor,
          to.systemNavigationBarColor,
          t,
        );

        // Switch icon brightness at halfway point for smoother transition
        final statusBarIconBrightness = t < 0.5
            ? from.statusBarIconBrightness
            : to.statusBarIconBrightness;

        final systemNavIconBrightness = t < 0.5
            ? from.systemNavigationBarIconBrightness
            : to.systemNavigationBarIconBrightness;

        final interpolatedStyle = SystemUiOverlayStyle(
          statusBarColor: statusBarColor,
          statusBarIconBrightness: statusBarIconBrightness,
          statusBarBrightness: t < 0.5
              ? from.statusBarBrightness
              : to.statusBarBrightness,
          systemNavigationBarColor: systemNavBarColor,
          systemNavigationBarIconBrightness: systemNavIconBrightness,
          systemNavigationBarDividerColor: Color.lerp(
            from.systemNavigationBarDividerColor,
            to.systemNavigationBarDividerColor,
            t,
          ),
        );

        SystemChrome.setSystemUIOverlayStyle(interpolatedStyle);

        if (i < steps) {
          await Future.delayed(Duration(milliseconds: stepDuration));
        }
      }

      _previousStyle = to;
    } finally {
      _isTransitioning = false;
    }
  }

  /// Set status bar for theme with smooth transition
  static Future<void> setForTheme({
    required bool isDark,
    Duration duration = const Duration(milliseconds: 300),
    Color? customStatusBarColor,
    Color? customNavBarColor,
  }) async {
    final newStyle = isDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: customStatusBarColor ?? Colors.transparent,
            systemNavigationBarColor: customNavBarColor ?? const Color(0xFF1A1D21),
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: customStatusBarColor ?? Colors.transparent,
            systemNavigationBarColor: customNavBarColor ?? Colors.white,
          );

    // Animate from previous style if available
    if (_previousStyle != null) {
      await animate(from: _previousStyle!, to: newStyle, duration: duration);
    } else {
      SystemChrome.setSystemUIOverlayStyle(newStyle);
      _previousStyle = newStyle;
    }
  }

  /// Instantly set status bar style without animation
  static void setImmediate(SystemUiOverlayStyle style) {
    SystemChrome.setSystemUIOverlayStyle(style);
    _previousStyle = style;
    _isTransitioning = false;
  }

  /// Reset transition state (useful for app initialization)
  static void reset() {
    _previousStyle = null;
    _isTransitioning = false;
  }
}

/// Widget that animates its children when theme changes
class ThemeAwareAnimatedBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, ThemeData theme) builder;
  final Duration duration;
  final Curve curve;

  const ThemeAwareAnimatedBuilder({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<ThemeAwareAnimatedBuilder> createState() =>
      _ThemeAwareAnimatedBuilderState();
}

class _ThemeAwareAnimatedBuilderState extends State<ThemeAwareAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  ThemeData? _previousTheme;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _controller.value = 1.0; // Start fully visible
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final currentTheme = Theme.of(context);
    if (_previousTheme != null && _previousTheme != currentTheme) {
      // Animate on theme change
      _controller.forward(from: 0.0);
    }
    _previousTheme = currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: widget.curve,
          ),
          child: widget.builder(context, theme),
        );
      },
    );
  }
}

/// Wrapper widget for screens that need theme transition effects
/// Automatically animates when theme changes
class ThemeTransitionWrapper extends StatelessWidget {
  final Widget child;
  final ThemeTransitionType type;
  final Duration duration;

  const ThemeTransitionWrapper({
    super.key,
    required this.child,
    this.type = ThemeTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ThemeAwareAnimatedBuilder(
      duration: duration,
      builder: (context, theme) {
        switch (type) {
          case ThemeTransitionType.fade:
            return child;
          case ThemeTransitionType.slideAndFade:
            return ThemeTransition.slideAndFade(
              duration: duration,
              child: child,
            );
          case ThemeTransitionType.scaleAndFade:
            return ThemeTransition.scaleAndFade(
              duration: duration,
              child: child,
            );
        }
      },
    );
  }
}

/// Types of theme transitions available
enum ThemeTransitionType {
  fade,
  slideAndFade,
  scaleAndFade,
}
