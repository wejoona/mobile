import 'package:flutter/material.dart';

/// Run 368: Count-up animation for displaying changing numeric values
class CountUpAnimation extends StatefulWidget {
  final double endValue;
  final double startValue;
  final Duration duration;
  final String prefix;
  final String suffix;
  final int decimalPlaces;
  final TextStyle? style;
  final Curve curve;

  const CountUpAnimation({
    super.key,
    required this.endValue,
    this.startValue = 0,
    this.duration = const Duration(milliseconds: 1200),
    this.prefix = '',
    this.suffix = '',
    this.decimalPlaces = 2,
    this.style,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<CountUpAnimation> createState() => _CountUpAnimationState();
}

class _CountUpAnimationState extends State<CountUpAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.startValue,
      end: widget.endValue,
    ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUpAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.endValue != widget.endValue) {
      _animation = Tween<double>(
        begin: oldWidget.endValue,
        end: widget.endValue,
      ).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
      _controller.forward(from: 0);
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
      builder: (context, _) {
        final value = _animation.value.toStringAsFixed(widget.decimalPlaces);
        return Semantics(
          label: '${widget.prefix}$value${widget.suffix}',
          child: Text(
            '${widget.prefix}$value${widget.suffix}',
            style: widget.style,
          ),
        );
      },
    );
  }
}
