import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/recurring_transfers_provider.dart';
import '../widgets/recurring_transfer_card.dart';
import '../../../design/tokens/theme_colors.dart';

class RecurringTransfersListView extends ConsumerStatefulWidget {
  const RecurringTransfersListView({super.key});

  @override
  ConsumerState<RecurringTransfersListView> createState() =>
      _RecurringTransfersListViewState();
}

class _RecurringTransfersListViewState
    extends ConsumerState<RecurringTransfersListView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(recurringTransfersProvider.notifier).loadRecurringTransfers();
      ref.read(recurringTransfersProvider.notifier).loadUpcoming();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(recurringTransfersProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.recurringTransfers_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recurring-transfers/create'),
        backgroundColor: context.colors.gold,
        child: Icon(Icons.add, color: context.colors.textInverse),
      ),
      body: SafeArea(
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
                ),
              )
            : state.transfers.isEmpty
                ? _buildEmptyState(context, l10n)
                : _buildContent(context, l10n, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    RecurringTransfersState state,
  ) {
    return RefreshIndicator(
      color: context.colors.gold,
      backgroundColor: context.colors.container,
      onRefresh: () =>
          ref.read(recurringTransfersProvider.notifier).loadRecurringTransfers(),
      child: ListView(
        padding: EdgeInsets.all(AppSpacing.md),
        children: [
          if (state.upcoming.isNotEmpty) ...[
            _buildUpcomingSection(context, l10n, state),
            SizedBox(height: AppSpacing.lg),
          ],
          if (state.activeTransfers.isNotEmpty) ...[
            AppText(
              l10n.recurringTransfers_active,
              variant: AppTextVariant.headlineSmall,
            ),
            SizedBox(height: AppSpacing.md),
            ...state.activeTransfers.map((transfer) {
              return RecurringTransferCard(
                transfer: transfer,
                onTap: () => context.push(
                  '/recurring-transfers/detail/${transfer.id}',
                ),
              );
            }),
            SizedBox(height: AppSpacing.lg),
          ],
          if (state.pausedTransfers.isNotEmpty) ...[
            AppText(
              l10n.recurringTransfers_paused,
              variant: AppTextVariant.headlineSmall,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            ...state.pausedTransfers.map((transfer) {
              return RecurringTransferCard(
                transfer: transfer,
                onTap: () => context.push(
                  '/recurring-transfers/detail/${transfer.id}',
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingSection(
    BuildContext context,
    AppLocalizations l10n,
    RecurringTransfersState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.recurringTransfers_upcoming,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),
        AppCard(
          variant: AppCardVariant.goldAccent,
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: state.upcoming.map((upcoming) {
                return Padding(
                  padding: EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: context.colors.gold,
                        size: 20,
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              upcoming.recipientName,
                              variant: AppTextVariant.bodyMedium,
                              fontWeight: FontWeight.w600,
                            ),
                            AppText(
                              '${upcoming.amount.toStringAsFixed(0)} ${upcoming.currency}',
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      AppText(
                        upcoming.isToday
                            ? l10n.common_today
                            : upcoming.isTomorrow
                                ? l10n.common_tomorrow
                                : _formatDate(upcoming.scheduledDate),
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.repeat,
              size: 80,
              color: context.colors.textSecondary.withOpacity(0.3),
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.recurringTransfers_emptyTitle,
              variant: AppTextVariant.headlineMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.recurringTransfers_emptyMessage,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.recurringTransfers_createFirst,
              onPressed: () => context.push('/recurring-transfers/create'),
              icon: Icons.add,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff < 7) return 'In $diff days';

    return '${date.day}/${date.month}';
  }
}
