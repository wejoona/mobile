import 'package:flutter/material.dart';

/// Scale in animation with optional fade
/// Perfect for success states, badges, and pop-in elements
///
/// Usage:
/// ```dart
/// ScaleIn(
///   child: Icon(Icons.check_circle),
///   scaleType: ScaleType.bounceIn,
/// )
/// ```
class ScaleIn extends StatefulWidget {
  final Widget child;
  final ScaleType scaleType;
  final Duration duration;
  final Duration delay;
  final bool withFade;
  final double initialScale;

  const ScaleIn({
    super.key,
    required this.child,
    this.scaleType = ScaleType.smooth,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.withFade = true,
    this.initialScale = 0.0,
  });

  @override
  State<ScaleIn> createState() => _ScaleInState();
}

class _ScaleInState extends State<ScaleIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final Curve curve = _getCurveForType(widget.scaleType);

    _scaleAnimation = Tween<double>(
      begin: widget.initialScale,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: curve,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: widget.withFade ? 0.0 : 1.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  Curve _getCurveForType(ScaleType type) {
    switch (type) {
      case ScaleType.smooth:
        return Curves.easeOutCubic;
      case ScaleType.bounceIn:
        return Curves.elasticOut;
      case ScaleType.spring:
        return Curves.bounceOut;
      case ScaleType.snap:
        return Curves.easeOutBack;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Types of scale animations
enum ScaleType {
  smooth,    // Standard ease out
  bounceIn,  // Elastic bounce effect
  spring,    // Spring-like bounce
  snap,      // Back ease with overshoot
}

/// Pulse animation - continuous scale effect
/// Good for attention grabbing elements
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool repeat;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
    this.repeat = true,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.repeat) {
      _controller.repeat(reverse: true);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// Pop animation - quick scale up and down
/// Perfect for button presses and interactions
class PopAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;

  const PopAnimation({
    super.key,
    required this.child,
    this.onPressed,
    this.duration = const Duration(milliseconds: 150),
  });

  @override
  State<PopAnimation> createState() => _PopAnimationState();
}

class _PopAnimationState extends State<PopAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPressed != null ? _handleTap : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
