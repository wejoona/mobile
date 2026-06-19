import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/notification.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/notifications/widgets/notification_tile.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Notifications list screen.
class NotificationsView extends ConsumerStatefulWidget {
  const NotificationsView({super.key});

  @override
  ConsumerState<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends ConsumerState<NotificationsView> {
  bool _markingAllRead = false;
  final Set<String> _markingReadIds = {};

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);
    final cachedNotifications = ref.watch(lastKnownNotificationsProvider);
    final cachedUnreadCount = ref.watch(
      lastKnownUnreadNotificationCountProvider,
    );
    final unreadCount = unreadCountAsync.value ?? cachedUnreadCount;
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.notifications_title,
          variant: AppTextVariant.titleLarge,
          fontWeight: FontWeight.w700,
        ),
        backgroundColor: colors.canvas,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: AppSpacing.sm),
              child: IconButton(
                tooltip: l10n.notifications_markAllRead,
                icon: Icon(Icons.done_all_rounded, color: colors.gold),
                onPressed: _markingAllRead ? null : _markAllAsRead,
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => cachedNotifications.isNotEmpty
            ? _buildNotificationsFeed(
                cachedNotifications,
                unreadCount,
                colors,
                l10n,
              )
            : _buildLoadingState(colors),
        error: (e, _) => cachedNotifications.isNotEmpty
            ? _buildNotificationsFeed(
                cachedNotifications,
                unreadCount,
                colors,
                l10n,
                staleError: e.toString(),
              )
            : _buildErrorState(e.toString(), l10n),
        data: (notifications) =>
            _buildNotificationsFeed(notifications, unreadCount, colors, l10n),
      ),
    );
  }

  Widget _buildLoadingState(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        children: List.generate(
          5,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: const Row(
                children: [
                  ShimmerLoading.circle(size: 42),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoading(width: 180, height: 14),
                        SizedBox(height: AppSpacing.xs),
                        ShimmerLoading(width: 220, height: 12),
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

  Widget _buildErrorState(String error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            EmptyState(
              icon: Icons.notifications_off_outlined,
              title: l10n.notifications_loadError,
              subtitle: error,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.action_retry,
              icon: Icons.refresh_rounded,
              onPressed: _refreshNotifications,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsFeed(
    List<AppNotification> notifications,
    int unreadCount,
    ThemeColors colors,
    AppLocalizations l10n, {
    String? staleError,
  }) {
    if (notifications.isEmpty) {
      return RefreshIndicator(
        color: colors.gold,
        onRefresh: _refreshNotifications,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.xxl,
            AppSpacing.screenPadding,
            AppSpacing.xxl,
          ),
          children: [
            _NotificationsEmptyState(
              title: l10n.notifications_emptyTitle,
              subtitle: l10n.notifications_emptyMessage,
              onPreferences: () => context.fsmPush('/settings/notifications'),
            ),
          ],
        ),
      );
    }

    final extraRows = 1 + (staleError == null ? 0 : 1);
    return RefreshIndicator(
      color: colors.gold,
      onRefresh: _refreshNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xxl,
        ),
        itemCount: notifications.length + extraRows,
        itemBuilder: (_, i) {
          if (staleError != null && i == 0) {
            return _NotificationsStaleBanner(
              message: l10n.notifications_loadError,
              onRetry: _refreshNotifications,
            );
          }

          final contentIndex = staleError == null ? i : i - 1;
          if (contentIndex == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _NotificationsSummary(
                unreadCount: unreadCount,
                totalCount: notifications.length,
              ),
            );
          }

          final notification = notifications[contentIndex - 1];
          final isMarkingRead = _markingReadIds.contains(notification.id);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: NotificationTile(
              notification: notification,
              isBusy: isMarkingRead,
              onTap: isMarkingRead
                  ? null
                  : () => _openNotification(notification),
            ),
          );
        },
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    if (_markingAllRead) {
      return;
    }
    setState(() => _markingAllRead = true);
    try {
      await ref.read(notificationActionsProvider).markAllAsRead();
    } finally {
      if (mounted) {
        setState(() => _markingAllRead = false);
      }
    }
  }

  Future<void> _refreshNotifications() async {
    await Future.wait<Object>([
      ref.refresh(notificationsProvider.future),
      ref.refresh(unreadNotificationCountProvider.future),
    ]);
  }

  Future<void> _openNotification(AppNotification notification) async {
    if (!notification.isRead) {
      setState(() => _markingReadIds.add(notification.id));
      try {
        await ref.read(notificationActionsProvider).markAsRead(notification.id);
      } finally {
        if (mounted) {
          setState(() => _markingReadIds.remove(notification.id));
        }
      }
    }

    final route = notification.navigationRoute;
    if (route != null && mounted) {
      await context.fsmPush(route);
    }
  }
}

class _NotificationsEmptyState extends StatelessWidget {
  const _NotificationsEmptyState({
    required this.title,
    required this.subtitle,
    required this.onPreferences,
  });

  final String title;
  final String subtitle;
  final VoidCallback onPreferences;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
      variant: AppCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colors.goldSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderGold),
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              color: colors.gold,
              size: 34,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            title,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            subtitle,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.notifications_preferences_title,
            icon: Icons.tune_rounded,
            isFullWidth: true,
            onPressed: onPreferences,
          ),
        ],
      ),
    );
  }
}

class _NotificationsStaleBanner extends StatelessWidget {
  const _NotificationsStaleBanner({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.warningBg,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: colors.warning.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: colors.warningText,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppText(
                message,
                variant: AppTextVariant.bodySmall,
                color: colors.warningText,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: onRetry,
              child: AppText(
                l10n.action_retry,
                variant: AppTextVariant.labelMedium,
                color: colors.warningText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationsSummary extends StatelessWidget {
  const _NotificationsSummary({
    required this.unreadCount,
    required this.totalCount,
  });

  final int unreadCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUnread = unreadCount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: hasUnread
                  ? colors.goldSubtle
                  : colors.infoBg.withValues(alpha: colors.isDark ? 0.55 : 0.8),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              hasUnread
                  ? Icons.mark_email_unread_outlined
                  : Icons.mark_email_read_outlined,
              color: hasUnread ? colors.gold : colors.info,
              size: 21,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  hasUnread
                      ? _localizedSummary(
                          context,
                          unreadCount,
                          enSingular: 'unread notification',
                          enPlural: 'unread notifications',
                          frSingular: 'notification non lue',
                          frPlural: 'notifications non lues',
                        )
                      : _localizedText(
                          context,
                          en: 'All notifications are read',
                          fr: 'Toutes les notifications sont lues',
                        ),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  _localizedSummary(
                    context,
                    totalCount,
                    enSingular: 'total update',
                    enPlural: 'total updates',
                    frSingular: 'mise à jour au total',
                    frPlural: 'mises à jour au total',
                  ),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _localizedSummary(
  BuildContext context,
  int count, {
  required String enSingular,
  required String enPlural,
  required String frSingular,
  required String frPlural,
}) {
  final isFrench = Localizations.localeOf(context).languageCode == 'fr';
  final label = count == 1
      ? (isFrench ? frSingular : enSingular)
      : (isFrench ? frPlural : enPlural);
  return '$count $label';
}

String _localizedText(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}
