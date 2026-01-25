/// Alerts List View
/// Displays all transaction alerts
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';
import '../providers/index.dart';
import '../widgets/index.dart';

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
    final state = ref.watch(alertsProvider);
    final filteredAlerts = _filterAlerts(state.alerts);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Row(
          children: [
            const AppText(
              'Alerts',
              variant: AppTextVariant.titleLarge,
            ),
            if (state.unreadCount > 0) ...[
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
                  '${state.unreadCount}',
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
          if (state.unreadCount > 0)
            TextButton(
              onPressed: () => ref.read(alertsProvider.notifier).markAllAsRead(),
              child: const AppText(
                'Mark all read',
                variant: AppTextVariant.labelMedium,
                color: AppColors.gold500,
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
          if (state.statistics != null) _buildStatisticsSummary(state.statistics!),

          // Filter chips
          _buildFilterChips(),

          // Alerts list
          Expanded(
            child: state.isLoading && state.alerts.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.gold500),
                  )
                : filteredAlerts.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () => ref.read(alertsProvider.notifier).loadAlerts(refresh: true),
                        color: AppColors.gold500,
                        backgroundColor: AppColors.slate,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(AppSpacing.screenPadding),
                          itemCount: filteredAlerts.length + (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredAlerts.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(AppSpacing.lg),
                                  child: CircularProgressIndicator(
                                    color: AppColors.gold500,
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

  Widget _buildStatisticsSummary(AlertStatistics stats) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.screenPadding),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', stats.total, AppColors.textSecondary),
          _buildStatItem('Unread', stats.unread, AppColors.gold500),
          _buildStatItem('Critical', stats.critical, AppColors.errorBase),
          _buildStatItem('Action', stats.actionRequired, AppColors.warningBase),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
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
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
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
              ? (color ?? AppColors.gold500).withValues(alpha: 0.2)
              : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected
                ? (color ?? AppColors.gold500)
                : AppColors.borderSubtle,
          ),
        ),
        child: AppText(
          label,
          variant: AppTextVariant.labelMedium,
          color: isSelected
              ? (color ?? AppColors.gold500)
              : AppColors.textSecondary,
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
            'No Alerts',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _filterSeverity != null || _filterType != null
                ? 'No alerts match your filter'
                : "You're all caught up!",
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
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
              child: const AppText(
                'Clear filters',
                variant: AppTextVariant.labelMedium,
                color: AppColors.gold500,
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
