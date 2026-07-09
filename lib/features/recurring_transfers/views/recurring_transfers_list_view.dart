import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/shimmer_loading.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/recurring_transfers/providers/recurring_transfers_provider.dart';
import 'package:usdc_wallet/features/recurring_transfers/widgets/recurring_transfer_card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Recurring transfers list screen.
class RecurringTransfersListView extends ConsumerWidget {
  const RecurringTransfersListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersAsync = ref.watch(recurringTransfersProvider);
    final monthlyAmount = ref.watch(monthlyRecurringAmountProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.recurringTransfers_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Nouveau virement récurrent',
            onPressed: () => context.fsmPush('/recurring-transfers/create'),
          ),
        ],
      ),
      body: transfersAsync.when(
        loading: () =>
            const Padding(padding: EdgeInsets.all(16), child: ShimmerList()),
        error: (e, _) => Center(
          child: Text(
            AppLocalizations.of(context)!.common_errorFormat(UserFacingErrors.message(e)),
          ),
        ),
        data: (transfers) {
          if (transfers.isEmpty) {
            return EmptyState(
              icon: Icons.repeat_rounded,
              title: 'No recurring transfers',
              subtitle:
                  'Set up automatic transfers to save time on regular payments',
              actionLabel: 'Create Recurring',
              onAction: () => context.fsmPush('/recurring-transfers/create'),
            );
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(recurringTransfersProvider.future),
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppText(
                            AppLocalizations.of(
                              context,
                            )!.analytics_monthlyTotal,
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.textSecondary,
                          ),
                        ),
                        AmountText(
                          amount: monthlyAmount,
                          size: AmountTextSize.medium,
                          showCurrencyCode: true,
                          color: context.colors.textPrimary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        AppText(
                          '/mo',
                          variant: AppTextVariant.bodySmall,
                          color: context.colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                ...transfers.map(
                  (t) => RecurringTransferCard(
                    transfer: t,
                    onTap: () =>
                        context.fsmPush('/recurring-transfers/detail/${t.id}'),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
