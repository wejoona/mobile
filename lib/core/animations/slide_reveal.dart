import 'package:flutter/material.dart';

/// Slide reveal animation for revealing content from edges
/// Useful for sliding panels, drawers, and reveals
///
/// Usage:
/// ```dart
/// SlideReveal(
///   revealDirection: RevealDirection.fromLeft,
///   isRevealed: showPanel,
///   child: Panel(),
/// )
/// ```
class SlideReveal extends StatefulWidget {
  final Widget child;
  final bool isRevealed;
  final RevealDirection revealDirection;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onRevealComplete;
  final VoidCallback? onHideComplete;

  const SlideReveal({
    super.key,
    required this.child,
    required this.isRevealed,
    this.revealDirection = RevealDirection.fromRight,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.onRevealComplete,
    this.onHideComplete,
  });

  @override
  State<SlideReveal> createState() => _SlideRevealState();
}

class _SlideRevealState extends State<SlideReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = _createSlideAnimation();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRevealComplete?.call();
      } else if (status == AnimationStatus.dismissed) {
        widget.onHideComplete?.call();
      }
    });

    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  Animation<Offset> _createSlideAnimation() {
    final Offset begin;
    switch (widget.revealDirection) {
      case RevealDirection.fromLeft:
        begin = const Offset(-1.0, 0.0);
        break;
      case RevealDirection.fromRight:
        begin = const Offset(1.0, 0.0);
        break;
      case RevealDirection.fromTop:
        begin = const Offset(0.0, -1.0);
        break;
      case RevealDirection.fromBottom:
        begin = const Offset(0.0, 1.0);
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
  void didUpdateWidget(SlideReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: widget.child,
    );
  }
}

enum RevealDirection {
  fromLeft,
  fromRight,
  fromTop,
  fromBottom,
}

/// Expandable content with smooth height animation
class ExpandableContent extends StatefulWidget {
  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;

  const ExpandableContent({
    super.key,
    required this.child,
    required this.isExpanded,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  State<ExpandableContent> createState() => _ExpandableContentState();
}

class _ExpandableContentState extends State<ExpandableContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _animation,
      axisAlignment: -1.0,
      child: widget.child,
    );
  }
}

/// Rotating reveal animation
class RotatingReveal extends StatefulWidget {
  final Widget child;
  final bool isRevealed;
  final Duration duration;
  final double turns;

  const RotatingReveal({
    super.key,
    required this.child,
    required this.isRevealed,
    this.duration = const Duration(milliseconds: 400),
    this.turns = 0.25,
  });

  @override
  State<RotatingReveal> createState() => _RotatingRevealState();
}

class _RotatingRevealState extends State<RotatingReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotationAnimation = Tween<double>(
      begin: widget.turns,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(RotatingReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
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
      child: RotationTransition(
        turns: _rotationAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Page curl reveal effect
class PageCurlReveal extends StatefulWidget {
  final Widget child;
  final bool isRevealed;
  final Duration duration;

  const PageCurlReveal({
    super.key,
    required this.child,
    required this.isRevealed,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<PageCurlReveal> createState() => _PageCurlRevealState();
}

class _PageCurlRevealState extends State<PageCurlReveal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isRevealed) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PageCurlReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRevealed != oldWidget.isRevealed) {
      if (widget.isRevealed) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateY(_animation.value * 3.14159);

        return Transform(
          transform: transform,
          alignment: Alignment.centerLeft,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
