import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Shimmer skeleton loader for both light and dark themes
/// Shows animated placeholder while content is loading
///
/// Usage:
/// ```dart
/// SkeletonLoader.rectangle(width: 200, height: 100)
/// SkeletonLoader.circle(size: 48)
/// SkeletonLoader.text(lines: 3)
/// SkeletonLoader.card()
/// ```
class SkeletonLoader extends StatefulWidget {
  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  const SkeletonLoader.rectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  }) : shape = BoxShape.rectangle;

  const SkeletonLoader.circle({
    super.key,
    required double size,
    this.borderRadius,
  })  : width = size,
        height = size,
        shape = BoxShape.circle;

  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
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

    _animation = Tween<double>(begin: -2, end: 2).animate(
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

    // Dark theme: lighter shimmer on dark base
    // Light theme: darker shimmer on light base
    final baseColor = isDark
        ? const Color(0xFF2A2A30) // Slightly lighter than slate
        : const Color(0xFFE8E8E8); // Light gray

    final shimmerColor = isDark
        ? const Color(0xFF3A3A40) // Even lighter for shimmer
        : const Color(0xFFF5F5F5); // Almost white for shimmer

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor,
            shape: widget.shape,
            borderRadius: widget.shape == BoxShape.rectangle
                ? widget.borderRadius ?? BorderRadius.circular(AppRadius.md)
                : null,
            gradient: LinearGradient(
              begin: Alignment(_animation.value, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: [
                baseColor,
                shimmerColor,
                baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built skeleton patterns for common use cases
class SkeletonPattern extends StatelessWidget {
  const SkeletonPattern._({
    required this.child,
    super.key,
  });

  /// Text skeleton with multiple lines
  factory SkeletonPattern.text({
    Key? key,
    int lines = 3,
    double? lineHeight = 12,
    double spacing = 8,
  }) {
    return SkeletonPattern._(
      key: key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          final isLast = index == lines - 1;
          final width = isLast ? 0.6 : 1.0;

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : spacing),
            child: SkeletonLoader.rectangle(
              width: double.infinity,
              height: lineHeight!,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          );
        }),
      ),
    );
  }

  /// Transaction list item skeleton
  factory SkeletonPattern.transaction({Key? key}) {
    return SkeletonPattern._(
      key: key,
      child: Row(
        children: [
          // Avatar
          const SkeletonLoader.circle(size: 40),
          const SizedBox(width: AppSpacing.md),

          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader.rectangle(
                  width: 120,
                  height: 14,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
                const SizedBox(height: AppSpacing.xs),
                SkeletonLoader.rectangle(
                  width: 80,
                  height: 12,
                  borderRadius: BorderRadius.circular(AppRadius.xs),
                ),
              ],
            ),
          ),

          // Amount
          SkeletonLoader.rectangle(
            width: 60,
            height: 16,
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
        ],
      ),
    );
  }

  /// Card skeleton
  factory SkeletonPattern.card({
    Key? key,
    double? height = 120,
  }) {
    return SkeletonPattern._(
      key: key,
      child: SkeletonLoader.rectangle(
        width: double.infinity,
        height: height!,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
    );
  }

  /// Balance card skeleton
  factory SkeletonPattern.balanceCard({Key? key}) {
    return SkeletonPattern._(
      key: key,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            SkeletonLoader.rectangle(
              width: 100,
              height: 12,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
            const SizedBox(height: AppSpacing.md),

            // Balance
            SkeletonLoader.rectangle(
              width: 180,
              height: 32,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Subtitle
            SkeletonLoader.rectangle(
              width: 120,
              height: 10,
              borderRadius: BorderRadius.circular(AppRadius.xs),
            ),
          ],
        ),
      ),
    );
  }

  /// List with multiple transaction items
  factory SkeletonPattern.transactionList({
    Key? key,
    int count = 5,
  }) {
    return SkeletonPattern._(
      key: key,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
        itemBuilder: (context, index) => SkeletonPattern.transaction(),
      ),
    );
  }

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
