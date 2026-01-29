import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../domain/enums/index.dart';
import '../../../l10n/app_localizations.dart';
import '../../../state/index.dart';
import '../../../services/currency/currency_provider.dart';
import '../../../services/api/api_client.dart';

/// Enhanced Wallet Home Screen
///
/// Features:
/// - Time-based greeting (Good morning/afternoon/evening/night)
/// - Balance display with hide/show toggle
/// - 4 Quick actions (Send, Receive, Deposit, History)
/// - KYC verification banner (conditional)
/// - Recent transactions (3-5 items)
/// - Pull-to-refresh
/// - Balance count-up animation
/// - Settings and notification icons
class WalletHomeScreen extends ConsumerStatefulWidget {
  const WalletHomeScreen({super.key});

  @override
  ConsumerState<WalletHomeScreen> createState() => _WalletHomeScreenState();
}

class _WalletHomeScreenState extends ConsumerState<WalletHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isBalanceHidden = false;
  late AnimationController _balanceAnimationController;
  late Animation<double> _balanceAnimation;
  double _displayedBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadBalanceVisibilityPreference();
    _balanceAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _balanceAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _balanceAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _balanceAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadBalanceVisibilityPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = prefs.getBool('balance_hidden') ?? false;
    });
  }

  Future<void> _toggleBalanceVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isBalanceHidden = !_isBalanceHidden;
    });
    await prefs.setBool('balance_hidden', _isBalanceHidden);
  }

  String _getGreeting(AppLocalizations l10n) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return l10n.home_goodMorning;
    } else if (hour >= 12 && hour < 17) {
      return l10n.home_goodAfternoon;
    } else if (hour >= 17 && hour < 21) {
      return l10n.home_goodEvening;
    } else {
      return l10n.home_goodNight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateMachineProvider);
    final txState = ref.watch(transactionStateMachineProvider);
    final userName = ref.watch(userDisplayNameProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // Trigger balance animation when loaded
    if (walletState.status == WalletStatus.loaded &&
        _displayedBalance != walletState.usdcBalance) {
      _displayedBalance = walletState.usdcBalance;
      _balanceAnimationController.forward(from: 0);
    }

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
                // Header with greeting and icons
                _buildHeader(context, l10n, userName, colors),
                const SizedBox(height: AppSpacing.xxl),

                // Balance Card
                _buildBalanceCard(context, ref, walletState, l10n, colors),
                const SizedBox(height: AppSpacing.xxl),

                // Quick Actions Row (4 buttons)
                _buildQuickActions(context, l10n, colors),
                const SizedBox(height: AppSpacing.xxl),

                // KYC Banner (conditional)
                _buildKycBanner(context, ref, l10n, colors),

                // Recent Transactions
                _buildTransactionList(context, txState, l10n, colors),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    String userName,
    ThemeColors colors,
  ) {
    // Format display name - if it's a phone number, just show greeting
    final isPhoneNumber = userName.startsWith('+') ||
                          RegExp(r'^\d+$').hasMatch(userName);
    final displayName = isPhoneNumber ? null : userName;
    final greeting = _getGreeting(l10n);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                greeting,
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
              tooltip: 'Notifications',
            ),
            IconButton(
              onPressed: () => context.go('/settings'),
              icon: Icon(
                Icons.settings_outlined,
                color: colors.textSecondary,
              ),
              tooltip: 'Settings',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceCard(
    BuildContext context,
    WidgetRef ref,
    WalletState walletState,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    // Handle null/empty wallet state
    if (walletState.status == WalletStatus.initial) {
      return _buildLoadingCard(context, l10n, colors);
    }

    if (walletState.hasError) {
      return _buildErrorCard(
        context,
        walletState.error ?? l10n.error_failedToLoadBalance,
        l10n,
        colors,
        onRetry: () {
          ref.read(walletStateMachineProvider.notifier).refresh();
        },
      );
    }

    // Check if wallet exists
    final hasWallet = walletState.walletId.isNotEmpty;

    if (!hasWallet && !walletState.isLoading) {
      return _buildCreateWalletCard(context, ref, l10n, colors);
    }

    // Primary balance is USDC
    final primaryBalance = walletState.usdcBalance;

    // Get reference currency display if enabled
    final currencyState = ref.watch(currencyProvider);
    String? referenceAmount;
    if (currencyState.shouldShowReference && !walletState.isLoading) {
      referenceAmount = ref.read(currencyProvider.notifier).getFormattedReference(
        primaryBalance,
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.container,
            colors.container.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: colors.borderGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold500.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
        child: Column(
          children: [
            // Header with label and hide/show toggle
            Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.gold500,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                AppText(
                  l10n.home_totalBalance,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
                const Spacer(),
                // Hide/Show balance toggle
                IconButton(
                  onPressed: _toggleBalanceVisibility,
                  icon: Icon(
                    _isBalanceHidden
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: colors.textTertiary,
                    size: 20,
                  ),
                  tooltip: _isBalanceHidden
                      ? l10n.home_showBalance
                      : l10n.home_hideBalance,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: AppSpacing.xs),
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

            // Primary Balance - CENTERED, ANIMATED
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
                child: AnimatedBuilder(
                  animation: _balanceAnimation,
                  builder: (context, child) {
                    final animatedValue = primaryBalance * _balanceAnimation.value;
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      child: AppText(
                        _isBalanceHidden
                            ? '••••••'
                            : '\$${_formatBalanceCompact(animatedValue)}',
                        variant: AppTextVariant.displayLarge,
                        color: AppColors.gold500,
                      ),
                    );
                  },
                ),
              ),
              // Reference currency (informative only)
              if (!_isBalanceHidden &&
                  referenceAmount != null &&
                  referenceAmount.isNotEmpty) ...[
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
              if (!_isBalanceHidden && walletState.pendingBalance > 0) ...[
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
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionButton(
            icon: Icons.send_rounded,
            label: l10n.home_quickAction_send,
            onTap: () => context.push('/send'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.qr_code_2_rounded,
            label: l10n.home_quickAction_receive,
            onTap: () => context.push('/receive'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.add_circle_outline_rounded,
            label: l10n.home_quickAction_deposit,
            onTap: () => context.push('/deposit'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickActionButton(
            icon: Icons.history_rounded,
            label: l10n.home_quickAction_history,
            onTap: () => context.push('/transactions'),
          ),
        ),
      ],
    );
  }

  Widget _buildKycBanner(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    final userState = ref.watch(userStateMachineProvider);

    // Only show if user is authenticated and KYC is not verified
    if (!userState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    final kycStatus = userState.kycStatus;

    // Don't show banner if already verified
    if (kycStatus == KycStatus.verified) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        GestureDetector(
          onTap: () => context.push('/kyc'),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            margin: const EdgeInsets.only(bottom: AppSpacing.xxl),
            decoration: BoxDecoration(
              color: colors.warningBase.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: colors.warningBase.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: colors.warningBase,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        l10n.home_kycBanner_title,
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        l10n.home_kycBanner_action,
                        variant: AppTextVariant.bodySmall,
                        color: colors.warningBase,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colors.warningBase,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionList(
    BuildContext context,
    TransactionListState txState,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    if (txState.status == TransactionListStatus.error) {
      return _buildErrorCard(
        context,
        txState.error ?? l10n.error_failedToLoadTransactions,
        l10n,
        colors,
      );
    }

    if (txState.isLoading && txState.transactions.isEmpty) {
      return const TransactionList(
        transactions: [],
        isLoading: true,
      );
    }

    if (txState.transactions.isEmpty) {
      return _buildEmptyTransactions(context, l10n, colors);
    }

    // Show only 3-5 recent transactions
    return TransactionList(
      title: l10n.home_recentActivity,
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

  Widget _buildEmptyTransactions(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
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
              l10n.home_noTransactionsYet,
              variant: AppTextVariant.titleMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.home_transactionsWillAppear,
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
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
            l10n.wallet_loadingWallet,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateWalletCard(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
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
              onPressed: () => _activateWallet(context, ref, l10n, colors),
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

  Future<void> _activateWallet(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) async {
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

  Widget _buildErrorCard(
    BuildContext context,
    String error,
    AppLocalizations l10n,
    ThemeColors colors, {
    VoidCallback? onRetry,
  }) {
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
                child: AppText(
                  l10n.action_retry,
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

  /// Format balance with commas
  String _formatBalance(double amount) {
    final parts = amount.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];

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
  String _formatBalanceCompact(double amount) {
    if (amount < 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount < 1000000) {
      final kValue = amount / 1000;
      return '${kValue.toStringAsFixed(1)}K';
    } else if (amount < 1000000000) {
      final mValue = amount / 1000000;
      return '${mValue.toStringAsFixed(1)}M';
    } else {
      final bValue = amount / 1000000000;
      return '${bValue.toStringAsFixed(1)}B';
    }
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

/// Quick action button component
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
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.lg,
          horizontal: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colors.gold.withValues(alpha: 0.2),
                    colors.gold.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: colors.gold, size: 24),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
