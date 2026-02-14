/// Bank Selection View
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_linking_provider.dart';
import 'package:usdc_wallet/features/bank_linking/models/bank.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BankSelectionView extends ConsumerStatefulWidget {
  const BankSelectionView({super.key});

  @override
  ConsumerState<BankSelectionView> createState() => _BankSelectionViewState();
}

class _BankSelectionViewState extends ConsumerState<BankSelectionView> {
  @override
  void initState() {
    super.initState();
    // Load available banks
    Future.microtask(
      () => ref.read(bankLinkingProvider.notifier).loadBanks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bankLinkingProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.bankLinking_selectBank,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: state.isLoading
            ? _buildLoadingState()
            : _buildBanksList(l10n, state),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
      ),
    );
  }

  Widget _buildBanksList(AppLocalizations l10n, BankLinkingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.bankLinking_selectBankTitle,
                style: AppTypography.headlineMedium,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                l10n.bankLinking_selectBankDesc,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(AppSpacing.md),
            itemCount: state.availableBanks.length,
            separatorBuilder: (context, index) =>
                SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final bank = state.availableBanks[index];
              return _buildBankCard(bank);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBankCard(Bank bank) {
    return GestureDetector(
      onTap: () => _handleBankSelected(bank),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: context.colors.elevated,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Bank logo placeholder
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Center(
                child: AppText(
                  bank.name.substring(0, 1),
                  style: AppTypography.headlineMedium.copyWith(
                    color: context.colors.gold,
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    bank.name,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      if (bank.supportsBalanceCheck)
                        _buildFeatureBadge(
                          AppLocalizations.of(context)!
                              .bankLinking_balanceCheck,
                          Icons.account_balance_wallet,
                        ),
                      if (bank.supportsDirectDebit) ...[
                        if (bank.supportsBalanceCheck)
                          SizedBox(width: AppSpacing.xs),
                        _buildFeatureBadge(
                          AppLocalizations.of(context)!
                              .bankLinking_directDebit,
                          Icons.swap_horiz,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: context.colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: context.colors.gold.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: context.colors.gold),
          SizedBox(width: 4),
          AppText(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: context.colors.gold,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _handleBankSelected(Bank bank) {
    ref.read(bankLinkingProvider.notifier).selectBank(bank);
    context.push('/bank-linking/link');
  }
}
