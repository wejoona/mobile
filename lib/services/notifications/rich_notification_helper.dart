import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/notification.dart';
import '../../domain/enums/index.dart';
import '../../design/tokens/index.dart';

/// Rich Notification Helper - provides formatted display data for notifications
class RichNotificationHelper {
  /// Get icon for notification type
  static IconData getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.transactionComplete:
        return Icons.check_circle_rounded;
      case NotificationType.transactionFailed:
        return Icons.error_rounded;
      case NotificationType.securityAlert:
        return Icons.security_rounded;
      case NotificationType.promotion:
        return Icons.local_offer_rounded;
      case NotificationType.lowBalance:
        return Icons.account_balance_wallet_rounded;
      case NotificationType.newDeviceLogin:
        return Icons.devices_rounded;
      case NotificationType.largeTransaction:
        return Icons.trending_up_rounded;
      case NotificationType.withdrawalPending:
        return Icons.access_time_rounded;
      case NotificationType.addressWhitelisted:
        return Icons.verified_user_rounded;
      case NotificationType.priceAlert:
        return Icons.currency_exchange_rounded;
      case NotificationType.weeklySpendingSummary:
        return Icons.insights_rounded;
      case NotificationType.general:
      default:
        return Icons.notifications_rounded;
    }
  }

  /// Get color for notification type
  static Color getColor(NotificationType type) {
    switch (type) {
      case NotificationType.transactionComplete:
      case NotificationType.addressWhitelisted:
        return AppColors.successBase;
      case NotificationType.transactionFailed:
        return AppColors.errorBase;
      case NotificationType.securityAlert:
      case NotificationType.newDeviceLogin:
      case NotificationType.largeTransaction:
        return AppColors.warningBase;
      case NotificationType.promotion:
        return AppColors.gold500;
      case NotificationType.lowBalance:
        return AppColors.warningBase;
      case NotificationType.priceAlert:
        return AppColors.infoBase;
      case NotificationType.withdrawalPending:
        return AppColors.infoBase;
      case NotificationType.weeklySpendingSummary:
        return AppColors.gold500;
      case NotificationType.general:
      default:
        return AppColors.textSecondary;
    }
  }

  /// Get priority level (higher = more important)
  static int getPriority(NotificationType type) {
    switch (type) {
      case NotificationType.securityAlert:
      case NotificationType.newDeviceLogin:
        return 100;
      case NotificationType.largeTransaction:
      case NotificationType.transactionFailed:
        return 80;
      case NotificationType.transactionComplete:
      case NotificationType.withdrawalPending:
        return 60;
      case NotificationType.lowBalance:
      case NotificationType.addressWhitelisted:
        return 40;
      case NotificationType.priceAlert:
      case NotificationType.weeklySpendingSummary:
        return 30;
      case NotificationType.promotion:
        return 20;
      case NotificationType.general:
      default:
        return 10;
    }
  }

  /// Format notification for rich display
  static RichNotificationData format(AppNotification notification) {
    final data = notification.data ?? {};

    // Extract amount if present
    final amount = data['amount'] as num?;
    final currency = data['currency'] as String? ?? 'USDC';
    final formattedAmount = amount != null ? '$amount $currency' : null;

    // Extract recipient/sender info
    final recipientName = data['recipientName'] as String?;

    // Build subtitle based on notification type
    String? subtitle;
    switch (notification.type) {
      case NotificationType.transactionComplete:
        if (formattedAmount != null) {
          subtitle = recipientName != null
              ? 'Sent $formattedAmount to $recipientName'
              : 'Received $formattedAmount';
        }
        break;
      case NotificationType.transactionFailed:
        subtitle = data['reason'] as String?;
        break;
      case NotificationType.newDeviceLogin:
        final deviceName = data['deviceName'] as String?;
        final location = data['location'] as String?;
        subtitle = deviceName != null ? 'Device: $deviceName' : null;
        if (location != null) {
          subtitle = subtitle != null ? '$subtitle • $location' : location;
        }
        break;
      case NotificationType.largeTransaction:
        subtitle = formattedAmount;
        break;
      case NotificationType.priceAlert:
        final rate = data['rate'] as String?;
        subtitle = rate != null ? 'Current rate: $rate' : null;
        break;
      case NotificationType.weeklySpendingSummary:
        final totalSpent = data['totalSpent'] as num?;
        final comparison = data['comparison'] as String?;
        subtitle = totalSpent != null ? 'Total spent: $totalSpent $currency' : null;
        if (comparison != null) {
          subtitle = subtitle != null ? '$subtitle ($comparison)' : comparison;
        }
        break;
      default:
        break;
    }

    // Determine quick actions based on type
    List<RichNotificationAction> actions = [];
    switch (notification.type) {
      case NotificationType.transactionComplete:
      case NotificationType.transactionFailed:
        final transactionId = data['transactionId'] as String?;
        if (transactionId != null) {
          actions.add(RichNotificationAction(
            label: 'View Details',
            route: '/transactions/$transactionId',
          ));
        }
        break;
      case NotificationType.securityAlert:
      case NotificationType.newDeviceLogin:
        actions.add(RichNotificationAction(
          label: 'Review',
          route: '/settings/security',
        ));
        break;
      case NotificationType.lowBalance:
        actions.add(RichNotificationAction(
          label: 'Deposit',
          route: '/deposit',
        ));
        break;
      case NotificationType.addressWhitelisted:
        actions.add(RichNotificationAction(
          label: 'View Addresses',
          route: '/settings/security/addresses',
        ));
        break;
      default:
        break;
    }

    return RichNotificationData(
      notification: notification,
      icon: getIcon(notification.type),
      color: getColor(notification.type),
      priority: getPriority(notification.type),
      formattedAmount: formattedAmount,
      subtitle: subtitle,
      actions: actions,
    );
  }

  /// Format time ago for display
  static String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

/// Rich notification display data
class RichNotificationData {
  final AppNotification notification;
  final IconData icon;
  final Color color;
  final int priority;
  final String? formattedAmount;
  final String? subtitle;
  final List<RichNotificationAction> actions;

  const RichNotificationData({
    required this.notification,
    required this.icon,
    required this.color,
    required this.priority,
    this.formattedAmount,
    this.subtitle,
    this.actions = const [],
  });
}

/// Quick action for notification
class RichNotificationAction {
  final String label;
  final String route;
  final Map<String, dynamic>? params;

  const RichNotificationAction({
    required this.label,
    required this.route,
    this.params,
  });
}

/// In-app notification helper for showing banners when app is in foreground
class InAppNotificationHelper {
  /// Show an in-app notification banner
  void showInAppNotification(
    BuildContext context, {
    required String title,
    required String body,
    Map<String, dynamic>? data,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        title: title,
        body: body,
        data: data,
        onTap: () {
          overlayEntry.remove();
          onTap?.call();
        },
        onDismiss: () => overlayEntry.remove(),
        duration: duration,
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _InAppNotificationBanner extends StatefulWidget {
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final Duration duration;

  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    this.data,
    required this.onTap,
    required this.onDismiss,
    required this.duration,
  });

  @override
  State<_InAppNotificationBanner> createState() => _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: widget.onTap,
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity!.abs() > 100) {
                _dismiss();
              }
            },
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              shadowColor: Colors.black26,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications_rounded,
                        color: AppColors.gold500,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.7),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _dismiss,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Provider for rich notification helper
final richNotificationHelperProvider = Provider<InAppNotificationHelper>((ref) {
  return InAppNotificationHelper();
});
