import 'package:flutter/material.dart';

/// A shimmer loading placeholder widget for skeleton screens.
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 8,
    this.isCircle = false,
  });

  /// Square avatar placeholder.
  const ShimmerLoading.circle({
    super.key,
    double size = 40,
  })  : width = size,
        height = size,
        borderRadius = 0,
        isCircle = true;

  /// Text line placeholder.
  const ShimmerLoading.line({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  })  : borderRadius = 4,
        isCircle = false;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor =
        isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A list of shimmer lines for loading state.
class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double spacing;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: Row(
            children: [
              const ShimmerLoading.circle(size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLoading.line(
                      width: index.isEven ? 160 : 120,
                      height: 14,
                    ),
                    const SizedBox(height: 8),
                    const ShimmerLoading.line(width: 80, height: 12),
                  ],
                ),
              ),
              const ShimmerLoading.line(width: 60, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
