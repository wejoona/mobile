import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';

/// Shimmer loading effect for skeleton screens
///
/// Usage:
/// ```dart
/// ShimmerEffect(
///   child: Container(
///     height: 100,
///     decoration: BoxDecoration(
///       color: AppColors.slate,
///       borderRadius: BorderRadius.circular(12),
///     ),
///   ),
/// )
/// ```
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color? baseColor;
  final Color? highlightColor;
  final ShimmerDirection direction;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor,
    this.highlightColor,
    this.direction = ShimmerDirection.leftToRight,
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    _animation = Tween<double>(
      begin: -2.0,
      end: 2.0,
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

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppColors.slate;
    final highlightColor = widget.highlightColor ?? AppColors.elevated;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final gradient = LinearGradient(
              begin: _getGradientBegin(),
              end: _getGradientEnd(),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: const [
                0.0,
                0.5,
                1.0,
              ],
              transform: _SlidingGradientTransform(
                slidePercent: _animation.value,
              ),
            );

            return gradient.createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }

  Alignment _getGradientBegin() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerLeft;
      case ShimmerDirection.topToBottom:
        return Alignment.topCenter;
      case ShimmerDirection.diagonal:
        return Alignment.topLeft;
    }
  }

  Alignment _getGradientEnd() {
    switch (widget.direction) {
      case ShimmerDirection.leftToRight:
        return Alignment.centerRight;
      case ShimmerDirection.topToBottom:
        return Alignment.bottomCenter;
      case ShimmerDirection.diagonal:
        return Alignment.bottomRight;
    }
  }
}

enum ShimmerDirection {
  leftToRight,
  topToBottom,
  diagonal,
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({
    required this.slidePercent,
  });

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Pre-built skeleton components
class SkeletonLine extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const SkeletonLine({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;

  const SkeletonCircle({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.slate,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.height = 100,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// Skeleton for transaction list item
class SkeletonTransactionItem extends StatelessWidget {
  const SkeletonTransactionItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          const SkeletonCircle(size: 44),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonLine(height: 16, width: 120),
                SizedBox(height: AppSpacing.xs),
                const SkeletonLine(height: 12, width: 80),
              ],
            ),
          ),
          SizedBox(width: AppSpacing.md),
          const SkeletonLine(height: 16, width: 60),
        ],
      ),
    );
  }
}

/// Skeleton for balance card
class SkeletonBalanceCard extends StatelessWidget {
  const SkeletonBalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Container(
        margin: EdgeInsets.all(AppSpacing.screenPadding),
        padding: EdgeInsets.all(AppSpacing.cardPaddingLarge),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonLine(height: 14, width: 100),
            SizedBox(height: AppSpacing.md),
            const SkeletonLine(height: 32, width: 200),
            SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(height: 12, width: 60),
                      SizedBox(height: AppSpacing.xs),
                      const SkeletonLine(height: 16, width: 80),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SkeletonLine(height: 12, width: 60),
                      SizedBox(height: AppSpacing.xs),
                      const SkeletonLine(height: 16, width: 80),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
