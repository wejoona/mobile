import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../domain/enums/index.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/index.dart';
import '../../../services/currency/currency_provider.dart';
import '../../../services/api/api_client.dart';

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
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(walletStateMachineProvider.notifier).refresh();
            await ref.read(transactionStateMachineProvider.notifier).refresh();
          },
          color: colors.gold,
          backgroundColor: colors.container,
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
                _buildBalanceCard(context, ref, walletState),
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
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Format display name - if it's a phone number, just show "Welcome back"
    final isPhoneNumber = userName.startsWith('+') || RegExp(r'^\d+$').hasMatch(userName);
    final displayName = isPhoneNumber ? null : userName;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.home_welcomeBack,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              if (displayName != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  displayName,
                  variant: AppTextVariant.headlineSmall,
                  color: colors.textPrimary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: Icon(
                Icons.notifications_outlined,
                color: colors.textSecondary,
              ),
            ),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, WalletState walletState) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final currencyState = ref.watch(currencyProvider);

    // Handle null/empty wallet state
    if (walletState.status == WalletStatus.initial) {
      return _buildLoadingCard(context);
    }

    if (walletState.hasError) {
      return _buildErrorCard(
        context,
        walletState.error ?? l10n.error_failedToLoadBalance,
        onRetry: () {
          ref.read(walletStateMachineProvider.notifier).refresh();
        },
      );
    }

    // Check if wallet exists (wallet ID is not empty)
    final hasWallet = walletState.walletId.isNotEmpty;

    if (!hasWallet && !walletState.isLoading) {
      return _buildCreateWalletCard(context, ref);
    }

    // Primary balance is USDC (the stablecoin)
    final primaryBalance = walletState.usdcBalance;

    // Get reference currency display if enabled (informative only)
    String? referenceAmount;
    if (currencyState.shouldShowReference && !walletState.isLoading) {
      referenceAmount = ref.read(currencyProvider.notifier).getFormattedReference(
        primaryBalance,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.borderSubtle,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Column(
            children: [
              // Header with label and subtle USDC badge
              Row(
                children: [
                  const Icon(
                    Icons.menu,
                    color: AppColors.gold500,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AppText(
                    'Total Balance',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  const Spacer(),
                  // Subtle USDC badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold500.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const AppText(
                      'USDC',
                      variant: AppTextVariant.labelSmall,
                      color: AppColors.gold500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Primary Balance - CENTERED, VIBRANT GOLD, SCALABLE
              if (walletState.isLoading)
                SizedBox(
                  height: 56,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.gold500,
                      strokeWidth: 2,
                    ),
                  ),
                )
              else ...[
                Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: AppText(
                      '\$${_formatBalanceCompact(primaryBalance)}',
                      variant: AppTextVariant.displayLarge,
                      color: AppColors.gold500,
                    ),
                  ),
                ),
                // Reference currency (informative only)
                if (referenceAmount != null && referenceAmount.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    child: AppText(
                      '\u2248 $referenceAmount',
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
                // Pending balance indicator
                if (walletState.pendingBalance > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: colors.warningText,
                        ),
                        const SizedBox(width: AppSpacing.xxs),
                        AppText(
                          '+\$${_formatBalance(walletState.pendingBalance)} pending',
                          variant: AppTextVariant.bodySmall,
                          color: colors.warningText,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Format balance with commas (e.g., 142850.00 -> 142,850.00)
  String _formatBalance(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // Add commas to integer part
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    return '${buffer.toString()}.$decPart';
  }

  /// Format balance with K/M/B notation for large amounts
  /// < 1000: show full amount (e.g., 999.00)
  /// >= 1000: show K format (e.g., 1.2K)
  /// >= 1,000,000: show M format (e.g., 1.2M)
  /// >= 1,000,000,000: show B format (e.g., 1.2B)
  String _formatBalanceCompact(double amount) {
    if (amount < 1000) {
      // Show full amount with 2 decimals
      return amount.toStringAsFixed(2);
    } else if (amount < 1000000) {
      // Show in K format with 1 decimal
      final kValue = amount / 1000;
      return '${kValue.toStringAsFixed(1)}K';
    } else if (amount < 1000000000) {
      // Show in M format with 1 decimal
      final mValue = amount / 1000000;
      return '${mValue.toStringAsFixed(1)}M';
    } else {
      // Show in B format with 1 decimal
      final bValue = amount / 1000000000;
      return '${bValue.toStringAsFixed(1)}B';
    }
  }

  Widget _buildLoadingCard(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colors.gold,
            strokeWidth: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Loading wallet...',
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateWalletCard(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.goldGradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: AppColors.textInverse,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.wallet_activateTitle,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.wallet_activateDescription,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _activateWallet(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.gold,
                foregroundColor: colors.textInverse,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: AppText(
                l10n.wallet_activateButton,
                variant: AppTextVariant.labelLarge,
                color: colors.textInverse,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _activateWallet(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.container,
        content: Row(
          children: [
            CircularProgressIndicator(color: colors.gold),
            const SizedBox(width: AppSpacing.lg),
            AppText(
              l10n.wallet_activating,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );

    try {
      // Call wallet creation endpoint
      final dio = ref.read(dioProvider);
      await dio.post('/wallet/create');

      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Refresh wallet state
      await ref.read(walletStateMachineProvider.notifier).fetch();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) Navigator.of(context).pop();

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wallet_activateFailed),
            backgroundColor: colors.error,
          ),
        );
      }
    }
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
    final colors = context.colors;
    return GestureDetector(
      onTap: () => context.push('/services'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.apps,
                color: colors.gold,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    'All Services',
                    variant: AppTextVariant.labelLarge,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    'View all available features',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colors.textTertiary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(BuildContext context, TransactionListState txState) {
    if (txState.status == TransactionListStatus.error) {
      return _buildErrorCard(context, txState.error ?? 'Failed to load transactions');
    }

    if (txState.isLoading && txState.transactions.isEmpty) {
      return const TransactionList(
        transactions: [],
        isLoading: true,
      );
    }

    if (txState.transactions.isEmpty) {
      return _buildEmptyTransactions(context);
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

  Widget _buildEmptyTransactions(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colors.textTertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              color: colors.textTertiary,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            'No Transactions Yet',
            variant: AppTextVariant.titleMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Your recent transactions will appear here',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error, {VoidCallback? onRetry}) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: colors.error,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
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
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 22),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
