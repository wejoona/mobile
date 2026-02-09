import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../domain/entities/index.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/logger.dart';
import '../../../design/tokens/theme_colors.dart';

/// Notification item model
class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String? actionRoute;
  final Map<String, dynamic>? metadata;

  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.actionRoute,
    this.metadata,
  });

  /// Create NotificationItem from AppNotification entity
  factory NotificationItem.fromAppNotification(AppNotification notification) {
    // Extract action route from notification data if available
    String? actionRoute;
    if (notification.data != null) {
      // Check for transaction-related notifications
      if (notification.data!.containsKey('transactionId')) {
        actionRoute = '/transactions/${notification.data!['transactionId']}';
      }
      // Check for custom route in data
      else if (notification.data!.containsKey('route')) {
        actionRoute = notification.data!['route'] as String?;
      }
    }

    // Fallback to default routes based on type
    actionRoute ??= _defaultActionRoute(notification.type);

    return NotificationItem(
      id: notification.id,
      type: notification.type,
      title: notification.title,
      message: notification.body,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      actionRoute: actionRoute,
      metadata: notification.data,
    );
  }

  /// Get default action route based on notification type
  static String? _defaultActionRoute(NotificationType type) {
    switch (type) {
      case NotificationType.transactionComplete:
      case NotificationType.transactionFailed:
      case NotificationType.withdrawalPending:
      case NotificationType.largeTransaction:
        return '/transactions';
      case NotificationType.promotion:
        return '/referrals';
      case NotificationType.lowBalance:
        return '/deposit';
      default:
        return null;
    }
  }
}

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final sdk = ref.read(sdkProvider);
      final apiNotifications = await sdk.notifications.getNotifications();

      if (mounted) {
        setState(() {
          _notifications = apiNotifications
              .map((n) => NotificationItem.fromAppNotification(n))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            AppText(
              AppLocalizations.of(context)!.notifications_title,
              variant: AppTextVariant.titleLarge,
              color: colors.textPrimary,
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colors.gold,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  '$unreadCount',
                  variant: AppTextVariant.labelSmall,
                  color: colors.textInverse,
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: AppText(
                AppLocalizations.of(context)!.notifications_markAllRead,
                variant: AppTextVariant.labelMedium,
                color: colors.gold,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: colors.gold),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: colors.gold,
                      backgroundColor: colors.container,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.screenPadding),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _NotificationCard(
                            notification: notification,
                            onTap: () => _handleNotificationTap(notification),
                            onDismiss: () => _dismissNotification(notification.id),
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyState() {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              color: colors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            AppLocalizations.of(context)!.notifications_emptyTitle,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            AppLocalizations.of(context)!.notifications_emptyMessage,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final colors = context.colors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: Icon(
              Icons.error_outline,
              color: colors.error,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            AppLocalizations.of(context)!.notifications_errorTitle,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _errorMessage ?? AppLocalizations.of(context)!.notifications_errorGeneric,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: AppLocalizations.of(context)!.action_retry,
            variant: AppButtonVariant.primary,
            onPressed: _loadNotifications,
          ),
        ],
      ),
    );
  }

  Future<void> _handleNotificationTap(NotificationItem notification) async {
    // Mark as read locally first for instant UI feedback
    if (!notification.isRead) {
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = NotificationItem(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            message: notification.message,
            createdAt: notification.createdAt,
            isRead: true,
            actionRoute: notification.actionRoute,
            metadata: notification.metadata,
          );
        }
      });

      // Mark as read on backend
      try {
        final sdk = ref.read(sdkProvider);
        await sdk.notifications.markAsRead(notification.id);
      } catch (e) {
        // Silent fail - notification is already marked as read locally
        AppLogger('Failed to mark notification as read').error('Failed to mark notification as read', e);
      }
    }

    // Navigate if action route exists
    if (notification.actionRoute != null && mounted) {
      context.push(notification.actionRoute!);
    }
  }

  Future<void> _dismissNotification(String id) async {
    // Remove from UI immediately
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });

    // Note: Backend doesn't have a delete endpoint yet
    // When available, add: await sdk.notifications.deleteNotification(id);
  }

  Future<void> _markAllAsRead() async {
    try {
      final sdk = ref.read(sdkProvider);
      await sdk.notifications.markAllAsRead();

      // Update local state
      if (mounted) {
        setState(() {
          _notifications = _notifications.map((n) {
            return NotificationItem(
              id: n.id,
              type: n.type,
              title: n.title,
              message: n.message,
              createdAt: n.createdAt,
              isRead: true,
              actionRoute: n.actionRoute,
              metadata: n.metadata,
            );
          }).toList();
        });
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        final colors = context.colors;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: colors.error,
          ),
        );
      }
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final NotificationItem notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(Icons.delete, color: colors.textInverse),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: notification.isRead ? colors.container : colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: notification.isRead
                  ? colors.borderSubtle
                  : colors.borderGold,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(context),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            notification.title,
                            variant: AppTextVariant.bodyLarge,
                            color: notification.isRead
                                ? colors.textSecondary
                                : colors.textPrimary,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: colors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      notification.message,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      _formatTime(context, notification.createdAt),
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ),
              if (notification.actionRoute != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    Icons.chevron_right,
                    color: colors.textTertiary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colors = context.colors;
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.transactionComplete:
        icon = Icons.check_circle;
        color = colors.success;
        break;
      case NotificationType.transactionFailed:
        icon = Icons.error;
        color = colors.error;
        break;
      case NotificationType.securityAlert:
        icon = Icons.security;
        color = colors.warning;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer;
        color = colors.gold;
        break;
      case NotificationType.lowBalance:
        icon = Icons.account_balance_wallet;
        color = colors.warning;
        break;
      case NotificationType.general:
        icon = Icons.info;
        color = colors.info;
        break;
      case NotificationType.newDeviceLogin:
        icon = Icons.devices;
        color = colors.warning;
        break;
      case NotificationType.largeTransaction:
        icon = Icons.attach_money;
        color = colors.info;
        break;
      case NotificationType.withdrawalPending:
        icon = Icons.hourglass_empty;
        color = colors.warning;
        break;
      case NotificationType.addressWhitelisted:
        icon = Icons.verified_user;
        color = colors.success;
        break;
      case NotificationType.priceAlert:
        icon = Icons.trending_up;
        color = colors.gold;
        break;
      case NotificationType.weeklySpendingSummary:
        icon = Icons.bar_chart;
        color = colors.info;
        break;
      // Transaction monitoring alert types
      case NotificationType.unusualLocation:
        icon = Icons.location_off;
        color = colors.warning;
        break;
      case NotificationType.rapidTransactions:
        icon = Icons.speed;
        color = colors.warning;
        break;
      case NotificationType.newRecipient:
        icon = Icons.person_add;
        color = colors.info;
        break;
      case NotificationType.suspiciousPattern:
        icon = Icons.warning_amber;
        color = colors.error;
        break;
      case NotificationType.failedAttempts:
        icon = Icons.error_outline;
        color = colors.error;
        break;
      case NotificationType.accountChange:
        icon = Icons.manage_accounts;
        color = colors.warning;
        break;
      case NotificationType.balanceThreshold:
        icon = Icons.account_balance;
        color = colors.warning;
        break;
      case NotificationType.externalWithdrawal:
        icon = Icons.output;
        color = colors.info;
        break;
      case NotificationType.timeAnomaly:
        icon = Icons.access_time;
        color = colors.warning;
        break;
      case NotificationType.roundAmount:
        icon = Icons.monetization_on;
        color = colors.info;
        break;
      case NotificationType.cumulativeDaily:
        icon = Icons.today;
        color = colors.warning;
        break;
      case NotificationType.velocityLimit:
        icon = Icons.speed;
        color = colors.error;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final l10n = AppLocalizations.of(context)!;

    if (diff.inMinutes < 1) {
      return l10n.notifications_timeJustNow;
    } else if (diff.inMinutes < 60) {
      return l10n.notifications_timeMinutesAgo(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.notifications_timeHoursAgo(diff.inHours);
    } else if (diff.inDays < 7) {
      return l10n.notifications_timeDaysAgo(diff.inDays);
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
