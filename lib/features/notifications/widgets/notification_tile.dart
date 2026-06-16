import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/swipe_action_cell.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/utils/date_utils.dart';

/// Individual notification list tile.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    required this.notification,
    super.key,
    this.onTap,
    this.onDismiss,
    this.isBusy = false,
  });

  final AppNotification notification;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;
  final bool isBusy;

  IconData get _icon => switch (notification.type) {
    NotificationType.transfer ||
    NotificationType.transactionComplete ||
    NotificationType.largeTransaction => Icons.swap_horiz_rounded,
    NotificationType.transactionFailed => Icons.error_outline_rounded,
    NotificationType.deposit => Icons.south_west_rounded,
    NotificationType.withdrawal ||
    NotificationType.withdrawalPending => Icons.north_east_rounded,
    NotificationType.security ||
    NotificationType.securityAlert ||
    NotificationType.newDeviceLogin => Icons.shield_outlined,
    NotificationType.kyc => Icons.verified_user_outlined,
    NotificationType.promotion => Icons.local_offer_outlined,
    NotificationType.lowBalance ||
    NotificationType.balanceThreshold => Icons.account_balance_wallet_outlined,
    NotificationType.addressWhitelisted => Icons.fact_check_outlined,
    NotificationType.priceAlert => Icons.show_chart_rounded,
    NotificationType.weeklySpendingSummary => Icons.insights_outlined,
    NotificationType.unusualLocation => Icons.location_on_outlined,
    NotificationType.rapidTransactions ||
    NotificationType.velocityLimit => Icons.bolt_outlined,
    NotificationType.newRecipient => Icons.person_add_alt_outlined,
    NotificationType.suspiciousPattern ||
    NotificationType.failedAttempts => Icons.warning_amber_rounded,
    NotificationType.accountChange => Icons.manage_accounts_outlined,
    NotificationType.externalWithdrawal => Icons.outbound_outlined,
    NotificationType.timeAnomaly => Icons.schedule_outlined,
    NotificationType.roundAmount ||
    NotificationType.cumulativeDaily ||
    NotificationType.general => Icons.notifications_outlined,
  };

  _NotificationTone _tone(ThemeColors colors) {
    final severityTone = _severityTone(colors);
    if (severityTone != null) {
      return severityTone;
    }

    switch (notification.type) {
      case NotificationType.transactionComplete:
      case NotificationType.transfer:
      case NotificationType.deposit:
        return _NotificationTone(
          accent: colors.success,
          background: colors.successBg,
          foreground: colors.successText,
        );
      case NotificationType.transactionFailed:
      case NotificationType.withdrawal:
      case NotificationType.withdrawalPending:
      case NotificationType.lowBalance:
      case NotificationType.largeTransaction:
      case NotificationType.balanceThreshold:
      case NotificationType.priceAlert:
      case NotificationType.externalWithdrawal:
        return _NotificationTone(
          accent: colors.warning,
          background: colors.warningBg,
          foreground: colors.warningText,
        );
      case NotificationType.securityAlert:
      case NotificationType.security:
      case NotificationType.suspiciousPattern:
      case NotificationType.failedAttempts:
        return _NotificationTone(
          accent: colors.error,
          background: colors.errorBg,
          foreground: colors.errorText,
        );
      case NotificationType.newDeviceLogin:
      case NotificationType.unusualLocation:
      case NotificationType.rapidTransactions:
      case NotificationType.accountChange:
      case NotificationType.timeAnomaly:
      case NotificationType.velocityLimit:
        return _NotificationTone(
          accent: colors.info,
          background: colors.infoBg,
          foreground: colors.infoText,
        );
      case NotificationType.kyc:
      case NotificationType.addressWhitelisted:
      case NotificationType.newRecipient:
        return _NotificationTone(
          accent: colors.gold,
          background: colors.goldSubtle,
          foreground: colors.gold,
        );
      case NotificationType.promotion:
      case NotificationType.weeklySpendingSummary:
      case NotificationType.roundAmount:
      case NotificationType.cumulativeDaily:
      case NotificationType.general:
        return _NotificationTone(
          accent: colors.info,
          background: colors.surface,
          foreground: colors.infoText,
        );
    }
  }

  _NotificationTone? _severityTone(ThemeColors colors) {
    switch (notification.severity) {
      case 'critical':
        return _NotificationTone(
          accent: colors.error,
          background: colors.errorBg,
          foreground: colors.errorText,
        );
      case 'warning':
        return _NotificationTone(
          accent: colors.warning,
          background: colors.warningBg,
          foreground: colors.warningText,
        );
      case 'success':
        return _NotificationTone(
          accent: colors.success,
          background: colors.successBg,
          foreground: colors.successText,
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = _tone(colors);
    final unread = !notification.isRead;

    return Semantics(
      label: '${notification.title}: ${notification.body}',
      button: onTap != null,
      child: SwipeActionCell(
        actions: [
          if (onDismiss != null)
            SwipeAction(
              label: _localizedText(context, en: 'Delete', fr: 'Supprimer'),
              icon: Icons.delete_outline_rounded,
              color: colors.error,
              onTap: onDismiss!,
            ),
        ],
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppRadius.md),
            onTap: isBusy ? null : onTap,
            child: Container(
              decoration: BoxDecoration(
                color: unread ? tone.background : colors.container,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: unread
                      ? tone.accent.withValues(
                          alpha: colors.isDark ? 0.35 : 0.28,
                        )
                      : colors.borderSubtle,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 4,
                      decoration: BoxDecoration(
                        color: unread ? tone.accent : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: unread
                                    ? colors.container.withValues(
                                        alpha: colors.isDark ? 0.78 : 0.88,
                                      )
                                    : tone.background.withValues(
                                        alpha: colors.isDark ? 0.28 : 0.5,
                                      ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: tone.accent.withValues(alpha: 0.22),
                                ),
                              ),
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 160),
                                child: isBusy
                                    ? SizedBox(
                                        key: const ValueKey('busy'),
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: tone.accent,
                                        ),
                                      )
                                    : Icon(
                                        _icon,
                                        key: const ValueKey('icon'),
                                        color: tone.accent,
                                        size: 21,
                                      ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          notification.title,
                                          variant: AppTextVariant.bodyMedium,
                                          color: colors.textPrimary,
                                          fontWeight: unread
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      _TimeChip(
                                        label: AppDateUtils.relativeTimeFromNow(
                                          notification.createdAt,
                                        ),
                                        unread: unread,
                                        tone: tone,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  AppText(
                                    notification.body,
                                    variant: AppTextVariant.bodySmall,
                                    color: unread
                                        ? colors.textSecondary
                                        : colors.textTertiary,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (unread) ...[
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: tone.accent,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        AppText(
                                          _localizedText(
                                            context,
                                            en: 'New',
                                            fr: 'Nouveau',
                                          ),
                                          variant: AppTextVariant.labelSmall,
                                          color: tone.foreground,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
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

String _localizedText(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}

class _TimeChip extends StatelessWidget {
  const _TimeChip({
    required this.label,
    required this.unread,
    required this.tone,
  });

  final String label;
  final bool unread;
  final _NotificationTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(maxWidth: 88),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: unread
            ? tone.accent.withValues(alpha: colors.isDark ? 0.16 : 0.12)
            : colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        label,
        variant: AppTextVariant.labelSmall,
        color: unread ? tone.foreground : colors.textSecondary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _NotificationTone {
  const _NotificationTone({
    required this.accent,
    required this.background,
    required this.foreground,
  });

  final Color accent;
  final Color background;
  final Color foreground;
}
