import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/sub_business/providers/sub_business_provider.dart';
import 'package:usdc_wallet/features/sub_business/widgets/sub_business_card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Main screen showing list of sub-businesses
class SubBusinessesView extends ConsumerStatefulWidget {
  const SubBusinessesView({super.key});

  @override
  ConsumerState<SubBusinessesView> createState() => _SubBusinessesViewState();
}

class _SubBusinessesViewState extends ConsumerState<SubBusinessesView> {
  @override
  void initState() {
    super.initState();
    // Load sub-businesses on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(subBusinessProvider.notifier).loadSubBusinesses());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subBusinessProvider);
    // ignore: unused_local_variable

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.subBusiness_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(subBusinessProvider.notifier).loadSubBusinesses(),
        color: context.colors.gold,
        backgroundColor: context.colors.container,
        child: state.isLoading && state.subBusinesses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.requiresBusinessProfile
            ? _buildBusinessSetupState(l10n)
            : state.error != null && state.subBusinesses.isEmpty
            ? _buildErrorState(state.error!, l10n)
            : state.subBusinesses.isEmpty
            ? _buildEmptyState(l10n)
            : _buildSubBusinessesList(state, l10n),
      ),
      floatingActionButton: state.requiresBusinessProfile
          ? null
          : FloatingActionButton(
              onPressed: () => context.fsmPush('/sub-businesses/create'),
              backgroundColor: context.colors.gold,
              child: Icon(Icons.add, color: context.colors.canvas),
            ),
    );
  }

  Widget _buildBusinessSetupState(AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Icon(Icons.storefront_outlined, size: 64, color: context.colors.gold),
        const SizedBox(height: AppSpacing.lg),
        AppText(
          l10n.business_setupTitle,
          variant: AppTextVariant.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.business_setupDescription,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.business_setupNow,
          onPressed: () => context.fsmPush('/settings/business-setup'),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message, AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        Icon(Icons.error_outline, size: 64, color: context.colors.error),
        const SizedBox(height: AppSpacing.lg),
        AppText(
          message,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: l10n.common_retry,
          variant: AppButtonVariant.secondary,
          onPressed: () => unawaited(
            ref.read(subBusinessProvider.notifier).loadSubBusinesses(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: context.colors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.subBusiness_emptyTitle,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.subBusiness_emptyMessage,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.subBusiness_createFirst,
              onPressed: () => context.fsmPush('/sub-businesses/create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBusinessesList(
    SubBusinessState state,
    AppLocalizations l10n,
  ) {
    final totalBalanceLabel = _formatTotalBalance(state, l10n);

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Total balance card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                context.colors.gold,
                context.colors.gold.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.subBusiness_totalBalance,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.canvas,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                totalBalanceLabel,
                variant: AppTextVariant.displaySmall,
                color: context.colors.canvas,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                '${state.subBusinesses.length} ${state.subBusinesses.length == 1 ? l10n.subBusiness_unit : l10n.subBusiness_units}',
                variant: AppTextVariant.bodyMedium,
                color: context.colors.canvas.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Sub-businesses list
        AppText(
          l10n.subBusiness_listTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),

        ...state.subBusinesses.map((subBusiness) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SubBusinessCard(
              subBusiness: subBusiness,
              onTap: () =>
                  context.fsmPush('/sub-businesses/detail/${subBusiness.id}'),
            ),
          );
        }),
      ],
    );
  }

  String _formatTotalBalance(SubBusinessState state, AppLocalizations l10n) {
    if (state.subBusinesses.isEmpty) return formatCurrency(0, 'USDC');

    final firstCurrency = state.subBusinesses.first.currency;
    final hasSingleCurrency = state.subBusinesses.every(
      (subBusiness) => subBusiness.currency == firstCurrency,
    );

    if (!hasSingleCurrency) {
      return '${state.subBusinesses.length} ${state.subBusinesses.length == 1 ? l10n.subBusiness_unit : l10n.subBusiness_units}';
    }

    final totalBalance = state.subBusinesses.fold<double>(
      0,
      (sum, subBusiness) => sum + subBusiness.balance,
    );
    return formatCurrency(totalBalance, firstCurrency);
  }
}
