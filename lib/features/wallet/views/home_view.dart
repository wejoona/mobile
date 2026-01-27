import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../domain/enums/index.dart';
import '../../../state/index.dart';

/// Simplified Home View - Focus on essential wallet features only
/// - Prominent balance display
/// - Quick actions (Send, Receive, Scan)
/// - Recent transactions preview
/// - Link to Services page for additional features
class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletStateMachineProvider);
    final txState = ref.watch(transactionStateMachineProvider);
    final userName = ref.watch(userDisplayNameProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(walletStateMachineProvider.notifier).refresh();
            await ref.read(transactionStateMachineProvider.notifier).refresh();
          },
          color: AppColors.gold500,
          backgroundColor: AppColors.slate,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(context, userName),
                const SizedBox(height: AppSpacing.xxl),

                // Balance Card
                _buildBalanceCard(context, walletState),
                const SizedBox(height: AppSpacing.xxl),

                // Quick Actions - Only 3 essential actions
                _buildQuickActions(context),
                const SizedBox(height: AppSpacing.xxl),

                // Services Link
                _buildServicesLink(context),
                const SizedBox(height: AppSpacing.xxl),

                // Recent Transactions Preview
                _buildTransactionList(context, txState),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              'Welcome back',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              userName,
              variant: AppTextVariant.headlineSmall,
              color: AppColors.textPrimary,
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppColors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletState walletState) {
    // Handle null/empty wallet state
    if (walletState.status == WalletStatus.initial) {
      return _buildLoadingCard();
    }

    if (walletState.hasError) {
      return _buildErrorCard(
        walletState.error ?? 'Failed to load balance',
        onRetry: () {
          // Access context through builder pattern if needed
        },
      );
    }

    // Check if wallet exists (wallet ID is not empty)
    final hasWallet = walletState.walletId.isNotEmpty;

    if (!hasWallet && !walletState.isLoading) {
      return _buildCreateWalletCard(context);
    }

    return Column(
      children: [
        // Total balance header
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Total Balance',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              if (walletState.isLoading)
                const SizedBox(
                  height: 40,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.gold500,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else
                AppText(
                  '\$${walletState.totalBalance.toStringAsFixed(2)}',
                  variant: AppTextVariant.displaySmall,
                  color: AppColors.textPrimary,
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // USD and USDC balances side by side
        Row(
          children: [
            // USD Balance
            Expanded(
              child: _BalanceCard(
                label: 'USD',
                balance: walletState.usdBalance,
                icon: Icons.attach_money,
                iconColor: AppColors.successBase,
                isLoading: walletState.isLoading,
                subtitle: 'Fiat Balance',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // USDC Balance
            Expanded(
              child: _BalanceCard(
                label: 'USDC',
                balance: walletState.usdcBalance,
                icon: Icons.currency_bitcoin,
                iconColor: AppColors.infoBase,
                isLoading: walletState.isLoading,
                subtitle: 'Stablecoin',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold500,
            strokeWidth: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppText(
            'Loading wallet...',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateWalletCard(BuildContext context) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.gold500,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const AppText(
            'No Wallet Found',
            variant: AppTextVariant.titleLarge,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            'Create your wallet to start sending and receiving money',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Navigate to wallet creation flow
                context.push('/settings/kyc');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold500,
                foregroundColor: AppColors.obsidian,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: const AppText(
                'Create Wallet',
                variant: AppTextVariant.labelLarge,
                color: AppColors.obsidian,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.send,
            label: 'Send',
            onTap: () => context.push('/send'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.call_received,
            label: 'Receive',
            onTap: () => context.push('/receive'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.qr_code_scanner,
            label: 'Scan',
            onTap: () => context.push('/scan'),
          ),
        ),
      ],
    );
  }

  Widget _buildServicesLink(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/services'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.apps,
                color: AppColors.gold500,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'All Services',
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(height: AppSpacing.xxs),
                  AppText(
                    'View all available features',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, TransactionListState txState) {
    if (txState.status == TransactionListStatus.error) {
      return _buildErrorCard(txState.error ?? 'Failed to load transactions');
    }

    if (txState.isLoading && txState.transactions.isEmpty) {
      return const TransactionList(
        transactions: [],
        isLoading: true,
      );
    }

    if (txState.transactions.isEmpty) {
      return _buildEmptyTransactions();
    }

    // Show only 3-5 recent transactions
    return TransactionList(
      title: 'Recent Transactions',
      onViewAllTap: () => context.push('/transactions'),
      transactions: txState.transactions.take(5).map((tx) {
        return TransactionRow(
          title: _getTransactionTitle(tx.type, tx.description),
          subtitle: tx.description ?? tx.type.name,
          amount: tx.amount,
          date: tx.createdAt,
          type: _mapTransactionType(tx.type),
          onTap: () => context.push('/transactions/${tx.id}', extra: tx),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyTransactions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: AppColors.textTertiary,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const AppText(
            'No Transactions Yet',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          const AppText(
            'Your recent transactions will appear here',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String error, {VoidCallback? onRetry}) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Center(
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.errorBase,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: onRetry,
                child: const AppText(
                  'Retry',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.gold500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getTransactionTitle(TransactionType type, String? description) {
    if (description != null && description.isNotEmpty) {
      return description;
    }
    switch (type) {
      case TransactionType.deposit:
        return 'Deposit';
      case TransactionType.withdrawal:
        return 'Withdrawal';
      case TransactionType.transferInternal:
        return 'Transfer Received';
      case TransactionType.transferExternal:
        return 'Transfer Sent';
    }
  }

  TransactionDisplayType _mapTransactionType(TransactionType type) {
    switch (type) {
      case TransactionType.deposit:
        return TransactionDisplayType.deposit;
      case TransactionType.withdrawal:
        return TransactionDisplayType.withdrawal;
      case TransactionType.transferInternal:
        return TransactionDisplayType.transferIn;
      case TransactionType.transferExternal:
        return TransactionDisplayType.transferOut;
    }
  }
}

/// Individual balance card for USD/USDC display
class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.label,
    required this.balance,
    required this.icon,
    required this.iconColor,
    required this.isLoading,
    this.subtitle,
  });

  final String label;
  final double balance;
  final IconData icon;
  final Color iconColor;
  final bool isLoading;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                label,
                variant: AppTextVariant.labelMedium,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (isLoading)
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: AppColors.gold500,
                strokeWidth: 2,
              ),
            )
          else
            AppText(
              '\$${balance.toStringAsFixed(2)}',
              variant: AppTextVariant.titleLarge,
              color: AppColors.textPrimary,
            ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              subtitle!,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textTertiary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick action button component - simplified
class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.gold500, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
