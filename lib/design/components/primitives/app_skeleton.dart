import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Skeleton loading placeholder with shimmer animation.
/// Use for content placeholders while data is loading.
class AppSkeleton extends StatefulWidget {
  /// Creates a rectangular skeleton.
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  }) : isCircle = false;

  /// Creates a circular skeleton (for avatars).
  const AppSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = null,
        isCircle = true;

  /// Creates a text line skeleton.
  const AppSkeleton.text({
    super.key,
    this.width,
  })  : height = 14,
        borderRadius = null,
        isCircle = false;

  /// Creates a card skeleton.
  const AppSkeleton.card({
    super.key,
    this.width,
    this.height = 80,
  })  : borderRadius = AppRadius.lg,
        isCircle = false;

  final double? width;
  final double height;
  final double? borderRadius;
  final bool isCircle;

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
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
    final colors = context.colors;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.isCircle
                ? null
                : BorderRadius.circular(widget.borderRadius ?? AppRadius.sm),
            shape: widget.isCircle ? BoxShape.circle : BoxShape.rectangle,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                colors.container,
                colors.elevated,
                colors.container,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built skeleton layouts for common UI patterns.
class SkeletonLayouts {
  SkeletonLayouts._();

  /// Skeleton for a list item with avatar and text.
  static Widget listItem() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 48),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton.text(width: 120),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 80),
              ],
            ),
          ),
          const AppSkeleton.text(width: 60),
        ],
      ),
    );
  }

  /// Skeleton for transaction list items.
  static Widget transactionItem() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 44),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton.text(width: 140),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 100),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const AppSkeleton.text(width: 70),
              SizedBox(height: AppSpacing.xs),
              AppSkeleton.text(width: 50),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton for balance card.
  static Widget balanceCard(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppSkeleton.text(width: 80),
          SizedBox(height: AppSpacing.md),
          const AppSkeleton(width: 160, height: 36),
          SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              const AppSkeleton.text(width: 100),
              const Spacer(),
              const AppSkeleton.text(width: 60),
            ],
          ),
        ],
      ),
    );
  }

  /// Skeleton for beneficiary card.
  static Widget beneficiaryCard(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 48),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton.text(width: 120),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 160),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.iconSecondary,
          ),
        ],
      ),
    );
  }

  /// Skeleton for session item.
  static Widget sessionItem(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 40),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton.text(width: 140),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 100),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Skeleton for a settings item.
  static Widget settingsItem(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          const AppSkeleton.circle(size: 40),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppSkeleton.text(width: 120),
                SizedBox(height: AppSpacing.xs),
                AppSkeleton.text(width: 180),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colors.iconSecondary,
          ),
        ],
      ),
    );
  }

  /// Skeleton for payment link card.
  static Widget paymentLinkCard(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      padding: EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AppSkeleton.text(width: 140),
              const Spacer(),
              const AppSkeleton(width: 60, height: 24, borderRadius: AppRadius.full),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          const AppSkeleton.text(width: double.infinity),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const AppSkeleton.text(width: 80),
              const Spacer(),
              const AppSkeleton.text(width: 100),
            ],
          ),
        ],
      ),
    );
  }
}
