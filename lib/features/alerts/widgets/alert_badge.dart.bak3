/// Alert Badge Widget
/// Displays unread alert count badge
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/index.dart';
import '../providers/index.dart';

class AlertBadge extends ConsumerWidget {
  const AlertBadge({
    super.key,
    this.child,
    this.showZero = false,
    this.offset = const Offset(8, -8),
    this.backgroundColor,
    this.textColor,
    this.size = 18,
  });

  final Widget? child;
  final bool showZero;
  final Offset offset;
  final Color? backgroundColor;
  final Color? textColor;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(alertsUnreadCountProvider);

    if (unreadCount == 0 && !showZero) {
      return child ?? const SizedBox.shrink();
    }

    if (child == null) {
      return _buildBadge(unreadCount);
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          right: offset.dx,
          top: offset.dy,
          child: _buildBadge(unreadCount),
        ),
      ],
    );
  }

  Widget _buildBadge(int count) {
    final displayCount = count > 99 ? '99+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? 4 : 2,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.errorBase,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: (backgroundColor ?? AppColors.errorBase).withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayCount,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Simple alert icon with badge
class AlertIconWithBadge extends ConsumerWidget {
  const AlertIconWithBadge({
    super.key,
    this.onTap,
    this.iconColor,
    this.iconSize = 24,
    this.badgeBackgroundColor,
  });

  final VoidCallback? onTap;
  final Color? iconColor;
  final double iconSize;
  final Color? badgeBackgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AlertBadge(
        backgroundColor: badgeBackgroundColor,
        offset: const Offset(2, -4),
        size: 16,
        child: Icon(
          Icons.notifications_outlined,
          color: iconColor ?? colors.textPrimary,
          size: iconSize,
        ),
      ),
    );
  }
}

/// Alert badge for app bar
class AlertAppBarBadge extends ConsumerWidget {
  const AlertAppBarBadge({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return IconButton(
      onPressed: onTap,
      icon: AlertBadge(
        offset: const Offset(6, -6),
        size: 16,
        child: Icon(
          Icons.notifications_outlined,
          color: colors.textPrimary,
        ),
      ),
    );
  }
}

/// Pulsing alert indicator for critical alerts
class CriticalAlertIndicator extends ConsumerWidget {
  const CriticalAlertIndicator({
    super.key,
    this.size = 12,
  });

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(alertsProvider);
    final hasCritical = state.statistics?.critical != null &&
        state.statistics!.critical > 0;

    if (!hasCritical) {
      return const SizedBox.shrink();
    }

    return _PulsingDot(size: size);
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.size});

  final double size;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AppColors.errorBase.withValues(alpha: _animation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.errorBase.withValues(alpha: _animation.value * 0.5),
                blurRadius: widget.size * _animation.value,
                spreadRadius: widget.size * 0.2 * _animation.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
