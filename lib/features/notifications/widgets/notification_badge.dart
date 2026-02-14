import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 358: Notification badge widget with animated count
class NotificationBadge extends StatefulWidget {
  final int count;
  final Widget child;
  final Color? badgeColor;
  final bool showZero;

  const NotificationBadge({
    super.key,
    required this.count,
    required this.child,
    this.badgeColor,
    this.showZero = false,
  });

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  int _previousCount = 0;

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(NotificationBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.count != _previousCount && widget.count > 0) {
      _controller.forward(from: 0);
      _previousCount = widget.count;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = widget.count > 0 || widget.showZero;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        widget.child,
        if (show)
          Positioned(
            right: -6,
            top: -4,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Semantics(
                label: '${widget.count} notifications non lues',
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: widget.badgeColor ?? context.colors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Center(
                    child: Text(
                      widget.count > 99 ? '99+' : '${widget.count}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
