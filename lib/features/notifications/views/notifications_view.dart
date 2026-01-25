import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';

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
}

/// Mock notifications for demo
final _mockNotifications = [
  NotificationItem(
    id: '1',
    type: NotificationType.transactionComplete,
    title: 'Deposit Successful',
    message: 'Your deposit of \$50.00 has been credited to your wallet.',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: false,
    actionRoute: '/transactions/1',
  ),
  NotificationItem(
    id: '2',
    type: NotificationType.promotion,
    title: 'Refer & Earn',
    message: 'Invite friends and earn \$5 for each successful referral!',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    actionRoute: '/referrals',
  ),
  NotificationItem(
    id: '3',
    type: NotificationType.transactionComplete,
    title: 'Transfer Received',
    message: 'You received \$25.00 from +225 07 XX XX XX',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    isRead: true,
    actionRoute: '/transactions/2',
  ),
  NotificationItem(
    id: '4',
    type: NotificationType.securityAlert,
    title: 'New Login Detected',
    message: 'A new login was detected on iPhone 16e',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  NotificationItem(
    id: '5',
    type: NotificationType.lowBalance,
    title: 'Low Balance Alert',
    message: 'Your wallet balance is below \$10.00. Top up now!',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    actionRoute: '/deposit',
  ),
];

class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _notifications = List.from(_mockNotifications);
      _isLoading = false;
    });
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
            const AppText(
              'Notifications',
              variant: AppTextVariant.titleLarge,
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
                  color: AppColors.obsidian,
                ),
              ),
            ],
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: const AppText(
                'Mark all read',
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
          const AppText(
            'No Notifications',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            "You're all caught up!",
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read
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

    // Navigate if action route exists
    if (notification.actionRoute != null) {
      context.push(notification.actionRoute!);
    }
  }

  void _dismissNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n.id == id);
    });
  }

  void _markAllAsRead() {
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
                  : AppColors.gold500.withValues(alpha: 0.3),
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
