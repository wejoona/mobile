/// Linked Accounts View
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_button.dart';
import '../providers/bank_linking_provider.dart';
import '../widgets/linked_account_card.dart';

class LinkedAccountsView extends ConsumerStatefulWidget {
  const LinkedAccountsView({super.key});

  @override
  ConsumerState<LinkedAccountsView> createState() =>
      _LinkedAccountsViewState();
}

class _LinkedAccountsViewState extends ConsumerState<LinkedAccountsView> {
  @override
  void initState() {
    super.initState();
    // Load linked accounts on init
    Future.microtask(
      () => ref.read(bankLinkingProvider.notifier).loadLinkedAccounts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(bankLinkingProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.bankLinking_linkedAccounts,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: state.isLoading && state.linkedAccounts.isEmpty
                  ? _buildLoadingState()
                  : state.linkedAccounts.isEmpty
                      ? _buildEmptyState(l10n)
                      : _buildAccountsList(l10n, state),
            ),
            _buildBottomButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
      ),
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
              Icons.account_balance,
              size: 80,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.bankLinking_noLinkedAccounts,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.bankLinking_linkAccountDesc,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountsList(AppLocalizations l10n, BankLinkingState state) {
    return RefreshIndicator(
      onRefresh: () =>
          ref.read(bankLinkingProvider.notifier).loadLinkedAccounts(),
      color: AppColors.gold500,
      backgroundColor: AppColors.slate,
      child: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.md),
        itemCount: state.linkedAccounts.length,
        separatorBuilder: (context, index) => SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final account = state.linkedAccounts[index];
          return LinkedAccountCard(
            account: account,
            onTap: () => _handleAccountTap(account.id),
            onDeposit: () => _handleDeposit(account.id),
            onWithdraw: () => _handleWithdraw(account.id),
            onSetPrimary: () => _handleSetPrimary(account.id),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.graphite,
        border: Border(
          top: BorderSide(
            color: AppColors.elevated,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: l10n.bankLinking_linkNewAccount,
          onPressed: _handleLinkNewAccount,
          icon: Icons.add,
        ),
      ),
    );
  }

  void _handleAccountTap(String accountId) {
    // Navigate to account details or verification
    context.push('/bank-linking/verify/$accountId');
  }

  void _handleDeposit(String accountId) {
    // Navigate to deposit flow
    context.push('/bank-linking/transfer/$accountId', extra: 'deposit');
  }

  void _handleWithdraw(String accountId) {
    // Navigate to withdraw flow
    context.push('/bank-linking/transfer/$accountId', extra: 'withdraw');
  }

  Future<void> _handleSetPrimary(String accountId) async {
    final success = await ref
        .read(bankLinkingProvider.notifier)
        .setPrimaryAccount(accountId);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            AppLocalizations.of(context)!.bankLinking_primaryAccountSet,
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleLinkNewAccount() {
    context.push('/bank-linking/select');
  }
}
