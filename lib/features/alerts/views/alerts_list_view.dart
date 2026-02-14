/// Alerts List View
/// Displays all transaction alerts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/alerts/models/index.dart';
import 'package:usdc_wallet/features/alerts/providers/index.dart' hide AlertType;
import 'package:usdc_wallet/features/alerts/widgets/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class AlertsListView extends ConsumerStatefulWidget {
  const AlertsListView({super.key});

  @override
  ConsumerState<AlertsListView> createState() => _AlertsListViewState();
}

class _AlertsListViewState extends ConsumerState<AlertsListView> {
  final ScrollController _scrollController = ScrollController();
  AlertSeverity? _filterSeverity;
  AlertType? _filterType;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load alerts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(alertsProvider.notifier).loadAlerts(refresh: true);
      ref.read(alertsProvider.notifier).loadStatistics();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(alertsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(alertsProvider);
    final filteredAlerts = _filterAlerts(state.alerts);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: AppText(
                'Alerts',
                variant: AppTextVariant.titleLarge,
              ),
            ),
            if (state.unreadCount > 0) ...[
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
                  '${state.unreadCount}',
                  variant: AppTextVariant.labelSmall,
                  color: colors.canvas,
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
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(alertsProvider.notifier).markAllAsRead(),
              child: AppText(
                'Mark all read',
                variant: AppTextVariant.labelMedium,
                color: colors.gold,
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/alerts/preferences'),
            tooltip: 'Alert Preferences',
          ),
        ],
      ),
      body: Column(
        children: [
          // Statistics summary
          if (state.statistics != null) _buildStatisticsSummary(state.statistics!, colors),

          // Filter chips
          _buildFilterChips(colors),

          // Alerts list
          Expanded(
            child: state.isLoading && state.alerts.isEmpty
                ? Center(
                    child: CircularProgressIndicator(color: colors.gold),
                  )
                : filteredAlerts.isEmpty
                    ? _buildEmptyState(colors)
                    : RefreshIndicator(
                        onRefresh: () => ref.read(alertsProvider.notifier).loadAlerts(refresh: true),
                        color: colors.gold,
                        backgroundColor: colors.container,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.screenPadding),
                          itemCount: filteredAlerts.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredAlerts.length) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.lg),
                                  child: CircularProgressIndicator(
                                    color: colors.gold,
                                  ),
                                ),
                              );
                            }

                            final alert = filteredAlerts[index];
                            return AlertCard(
                              alert: alert,
                              onTap: () => _openAlertDetail(alert),
                              onDismiss: alert.isRead
                                  ? null
                                  : () => ref.read(alertsProvider.notifier).markAsRead(alert.alertId),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary(AlertStatistics stats, ThemeColors colors) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', stats.total, colors.textSecondary, colors),
          _buildStatItem('Unread', stats.unread, colors.gold, colors),
          _buildStatItem('Critical', stats.critical, context.colors.error, colors),
          _buildStatItem('Action', stats.actionRequired, context.colors.warning, colors),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color, ThemeColors colors) {
    return Column(
      children: [
        AppText(
          value.toString(),
          variant: AppTextVariant.titleLarge,
          color: color,
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeColors colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _buildFilterChip(
            label: 'All',
            isSelected: _filterSeverity == null && _filterType == null,
            onTap: () {
              setState(() {
                _filterSeverity = null;
                _filterType = null;
              });
            },
            colors: colors,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Critical',
            isSelected: _filterSeverity == AlertSeverity.critical,
            color: AlertSeverity.critical.color,
            onTap: () {
              setState(() {
                _filterSeverity = _filterSeverity == AlertSeverity.critical
                    ? null
                    : AlertSeverity.critical;
              });
            },
            colors: colors,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Warning',
            isSelected: _filterSeverity == AlertSeverity.warning,
            color: AlertSeverity.warning.color,
            onTap: () {
              setState(() {
                _filterSeverity = _filterSeverity == AlertSeverity.warning
                    ? null
                    : AlertSeverity.warning;
              });
            },
            colors: colors,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Transactions',
            isSelected: _filterType == AlertType.largeTransaction,
            onTap: () {
              setState(() {
                _filterType = _filterType == AlertType.largeTransaction
                    ? null
                    : AlertType.largeTransaction;
              });
            },
            colors: colors,
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildFilterChip(
            label: 'Security',
            isSelected: _filterType == AlertType.loginNewDevice,
            onTap: () {
              setState(() {
                _filterType = _filterType == AlertType.loginNewDevice
                    ? null
                    : AlertType.loginNewDevice;
              });
            },
            colors: colors,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeColors colors,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? colors.gold).withValues(alpha: 0.2)
              : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? (color ?? colors.gold)
                : colors.borderSubtle,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected
              ? (color ?? colors.gold)
              : colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.container,
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
            'No Alerts',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _filterSeverity != null || _filterType != null
                ? 'No alerts match your filter'
                : "You're all caught up!",
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          if (_filterSeverity != null || _filterType != null) ...[
            const SizedBox(height: AppSpacing.lg),
            TextButton(
              onPressed: () {
                setState(() {
                  _filterSeverity = null;
                  _filterType = null;
                });
              },
              child: AppText(
                'Clear filters',
                variant: AppTextVariant.labelMedium,
                color: colors.gold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<TransactionAlert> _filterAlerts(List<TransactionAlert> alerts) {
    return alerts.where((alert) {
      if (_filterSeverity != null && alert.severity != _filterSeverity) {
        return false;
      }
      if (_filterType != null && alert.alertType != _filterType) {
        return false;
      }
      return true;
    }).toList();
  }

  void _openAlertDetail(TransactionAlert alert) {
    // Mark as read when opening
    if (!alert.isRead) {
      ref.read(alertsProvider.notifier).markAsRead(alert.alertId);
    }
    context.push('/alerts/${alert.alertId}');
  }
}
