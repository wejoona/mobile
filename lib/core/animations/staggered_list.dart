import 'package:flutter/material.dart';

/// Run 366: Staggered list animation for items appearing sequentially
class StaggeredList extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;

  const StaggeredList({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 400),
    this.offsetY = 30,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<StaggeredList> createState() => _StaggeredListState();
}

class _StaggeredListState extends State<StaggeredList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _fadeAnimations = _controllers.map((c) {
      return CurvedAnimation(parent: c, curve: widget.curve);
    }).toList();

    _slideAnimations = _controllers.map((c) {
      return Tween<Offset>(
        begin: Offset(0, widget.offsetY),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: c, curve: widget.curve));
    }).toList();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (!mounted) return;
      await Future.delayed(widget.delay);
      if (mounted) _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Transform.translate(
              offset: _slideAnimations[index].value,
              child: Opacity(
                opacity: _fadeAnimations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

/// Wrapper for individual staggered item
class StaggeredItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration staggerDelay;

  const StaggeredItem({
    super.key,
    required this.child,
    required this.index,
    this.staggerDelay = const Duration(milliseconds: 80),
  });

  @override
  State<StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<StaggeredItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _offset = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(widget.staggerDelay * widget.index, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offset,
      child: FadeTransition(
        opacity: _opacity,
        child: widget.child,
      ),
    );
  }
}
