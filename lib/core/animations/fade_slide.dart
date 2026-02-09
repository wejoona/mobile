import 'package:flutter/material.dart';

/// Combined fade and slide animation for smooth element entrances
///
/// Usage:
/// ```dart
/// FadeSlide(
///   child: MyWidget(),
///   direction: SlideDirection.fromBottom,
/// )
/// ```
class FadeSlide extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double offset;

  const FadeSlide({
    super.key,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.offset = 20.0,
  });

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );

    _slideAnimation = _getSlideAnimation();

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

  Animation<Offset> _getSlideAnimation() {
    final Offset begin;
    switch (widget.direction) {
      case SlideDirection.fromTop:
        begin = Offset(0, -widget.offset / 100);
        break;
      case SlideDirection.fromBottom:
        begin = Offset(0, widget.offset / 100);
        break;
      case SlideDirection.fromLeft:
        begin = Offset(-widget.offset / 100, 0);
        break;
      case SlideDirection.fromRight:
        begin = Offset(widget.offset / 100, 0);
        break;
    }

    return Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: widget.curve,
      ),
    );
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
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Direction for slide animation
enum SlideDirection {
  fromTop,
  fromBottom,
  fromLeft,
  fromRight,
}

/// Staggered list animation helper
/// Automatically adds delay to each child
class StaggeredFadeSlide extends StatelessWidget {
  final List<Widget> children;
  final SlideDirection direction;
  final Duration itemDelay;
  final Duration itemDuration;
  final Curve curve;
  final double offset;

  const StaggeredFadeSlide({
    super.key,
    required this.children,
    this.direction = SlideDirection.fromBottom,
    this.itemDelay = const Duration(milliseconds: 80),
    this.itemDuration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOutCubic,
    this.offset = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        children.length,
        (index) => FadeSlide(
          direction: direction,
          duration: itemDuration,
          delay: itemDelay * index,
          curve: curve,
          offset: offset,
          child: children[index],
        ),
      ),
    );
  }
}
