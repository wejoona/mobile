import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/utils/date_utils.dart';

/// Run 359: Individual notification list tile widget
class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
    this.onDismiss,
  });

  IconData get _icon {
    switch (notification.type) {
      case NotificationType.transfer:
        return Icons.swap_horiz;
      case NotificationType.deposit:
        return Icons.arrow_downward;
      case NotificationType.withdrawal:
        return Icons.arrow_upward;
      case NotificationType.security:
        return Icons.shield_outlined;
      case NotificationType.kyc:
        return Icons.verified_user_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case NotificationType.transfer:
        return AppColors.gold;
      case NotificationType.deposit:
        return AppColors.success;
      case NotificationType.withdrawal:
        return AppColors.warning;
      case NotificationType.security:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${notification.title}: ${notification.body}',
      button: onTap != null,
      child: SwipeActionCell(
        onDismissed: onDismiss,
        child: Material(
          color: notification.isRead
              ? Colors.transparent
              : AppColors.gold.withOpacity(0.03),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _iconColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_icon, color: _iconColor, size: 20),
                  ),
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
                                style: AppTextStyle.labelMedium,
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
                                  color: AppColors.gold,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          notification.body,
                          style: AppTextStyle.bodySmall,
                          color: AppColors.textTertiary,
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        AppText(
                          AppDateUtils.relativeTime(notification.createdAt),
                          style: AppTextStyle.bodySmall,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
