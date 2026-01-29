import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../domain/entities/index.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';
import '../../../l10n/app_localizations.dart';

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

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            AppText(
              AppLocalizations.of(context)!.notifications_title,
              variant: AppTextVariant.titleLarge,
              color: AppColors.textPrimary,
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gold500,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  '$unreadCount',
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.textInverse,
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: AppText(
                AppLocalizations.of(context)!.notifications_markAllRead,
                variant: AppTextVariant.labelMedium,
                color: AppColors.gold500,
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.gold500),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _notifications.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      color: AppColors.gold500,
                      backgroundColor: AppColors.slate,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              color: AppColors.textTertiary,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            AppLocalizations.of(context)!.notifications_emptyTitle,
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            AppLocalizations.of(context)!.notifications_emptyMessage,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppColors.errorBase,
              size: 40,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            AppLocalizations.of(context)!.notifications_errorTitle,
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _errorMessage ?? AppLocalizations.of(context)!.notifications_errorGeneric,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
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
        debugPrint('Failed to mark notification as read: $e');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: AppColors.errorBase,
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
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.slate : AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: notification.isRead
                  ? AppColors.borderSubtle
                  : AppColors.borderGold,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
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
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.gold500,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      notification.message,
                      variant: AppTextVariant.bodyMedium,
                      color: AppColors.textSecondary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      _formatTime(notification.createdAt),
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ),
              if (notification.actionRoute != null)
                const Padding(
                  padding: EdgeInsets.only(left: AppSpacing.sm),
                  child: Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData icon;
    Color color;

    switch (notification.type) {
      case NotificationType.transactionComplete:
        icon = Icons.check_circle;
        color = AppColors.successBase;
        break;
      case NotificationType.transactionFailed:
        icon = Icons.error;
        color = AppColors.errorBase;
        break;
      case NotificationType.securityAlert:
        icon = Icons.security;
        color = AppColors.warningBase;
        break;
      case NotificationType.promotion:
        icon = Icons.local_offer;
        color = AppColors.gold500;
        break;
      case NotificationType.lowBalance:
        icon = Icons.account_balance_wallet;
        color = AppColors.warningBase;
        break;
      case NotificationType.general:
        icon = Icons.info;
        color = AppColors.infoBase;
        break;
      case NotificationType.newDeviceLogin:
        icon = Icons.devices;
        color = AppColors.warningBase;
        break;
      case NotificationType.largeTransaction:
        icon = Icons.attach_money;
        color = AppColors.infoBase;
        break;
      case NotificationType.withdrawalPending:
        icon = Icons.hourglass_empty;
        color = AppColors.warningBase;
        break;
      case NotificationType.addressWhitelisted:
        icon = Icons.verified_user;
        color = AppColors.successBase;
        break;
      case NotificationType.priceAlert:
        icon = Icons.trending_up;
        color = AppColors.gold500;
        break;
      case NotificationType.weeklySpendingSummary:
        icon = Icons.bar_chart;
        color = AppColors.infoBase;
        break;
      // Transaction monitoring alert types
      case NotificationType.unusualLocation:
        icon = Icons.location_off;
        color = AppColors.warningBase;
        break;
      case NotificationType.rapidTransactions:
        icon = Icons.speed;
        color = AppColors.warningBase;
        break;
      case NotificationType.newRecipient:
        icon = Icons.person_add;
        color = AppColors.infoBase;
        break;
      case NotificationType.suspiciousPattern:
        icon = Icons.warning_amber;
        color = AppColors.errorBase;
        break;
      case NotificationType.failedAttempts:
        icon = Icons.error_outline;
        color = AppColors.errorBase;
        break;
      case NotificationType.accountChange:
        icon = Icons.manage_accounts;
        color = AppColors.warningBase;
        break;
      case NotificationType.balanceThreshold:
        icon = Icons.account_balance;
        color = AppColors.warningBase;
        break;
      case NotificationType.externalWithdrawal:
        icon = Icons.output;
        color = AppColors.infoBase;
        break;
      case NotificationType.timeAnomaly:
        icon = Icons.access_time;
        color = AppColors.warningBase;
        break;
      case NotificationType.roundAmount:
        icon = Icons.monetization_on;
        color = AppColors.infoBase;
        break;
      case NotificationType.cumulativeDaily:
        icon = Icons.today;
        color = AppColors.warningBase;
        break;
      case NotificationType.velocityLimit:
        icon = Icons.speed;
        color = AppColors.errorBase;
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

  String _formatTime(DateTime dateTime) {
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
