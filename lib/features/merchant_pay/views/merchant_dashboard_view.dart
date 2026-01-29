import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/merchant_provider.dart';
import '../services/merchant_service.dart';

/// Merchant Dashboard View
/// Main dashboard for business users to manage their merchant account
class MerchantDashboardView extends ConsumerStatefulWidget {
  const MerchantDashboardView({super.key});

  static const String routeName = '/merchant-dashboard';

  @override
  ConsumerState<MerchantDashboardView> createState() => _MerchantDashboardViewState();
}

class _MerchantDashboardViewState extends ConsumerState<MerchantDashboardView> {
  String _selectedPeriod = 'month';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final merchantAsync = ref.watch(merchantProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText('Merchant Dashboard', variant: AppTextVariant.titleMedium),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => context.push('/merchant-settings'),
            icon: Icon(Icons.settings, color: AppColors.gold500),
          ),
        ],
      ),
      body: merchantAsync.when(
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.gold500),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.silver),
              SizedBox(height: AppSpacing.md),
              AppText(
                'Error loading merchant profile',
                color: AppColors.silver,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.action_retry,
                onPressed: () => ref.invalidate(merchantProfileProvider),
                variant: AppButtonVariant.secondary,
              ),
            ],
          ),
        ),
        data: (merchant) {
          if (merchant == null) {
            return _buildNotMerchantView(context, l10n);
          }
          return _buildDashboard(context, l10n, merchant);
        },
      ),
    );
  }

  Widget _buildNotMerchantView(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: AppColors.gold500.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              'Become a Merchant',
              variant: AppTextVariant.headlineMedium,
              color: AppColors.white,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              'Accept USDC payments from customers with QR codes',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.silver,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Register as Merchant',
              onPressed: () => context.push('/merchant-register'),
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, AppLocalizations l10n, MerchantResponse merchant) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(merchantProfileProvider);
        ref.invalidate(merchantAnalyticsProvider(MerchantAnalyticsParams(
          merchantId: merchant.merchantId,
          period: _selectedPeriod,
        )));
      },
      color: AppColors.gold500,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            if (!merchant.isVerified)
              _buildStatusBanner(merchant),

            // Quick stats card
            _buildQuickStats(merchant),
            SizedBox(height: AppSpacing.lg),

            // Quick actions
            _buildQuickActions(context, l10n, merchant),
            SizedBox(height: AppSpacing.lg),

            // Analytics section
            _buildAnalyticsSection(context, l10n, merchant),
            SizedBox(height: AppSpacing.lg),

            // Recent transactions
            _buildRecentTransactions(context, l10n, merchant),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(MerchantResponse merchant) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    if (merchant.isPending) {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      icon = Icons.pending;
      message = 'Your merchant account is pending verification';
    } else if (!merchant.isActive) {
      bgColor = AppColors.error.withValues(alpha: 0.1);
      textColor = AppColors.error;
      icon = Icons.warning;
      message = 'Your merchant account is ${merchant.status}';
    } else {
      bgColor = AppColors.warning.withValues(alpha: 0.1);
      textColor = AppColors.warning;
      icon = Icons.info;
      message = 'Complete verification to start accepting payments';
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: textColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(message, color: textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(MerchantResponse merchant) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return AppCard(
      variant: AppCardVariant.goldAccent,
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      merchant.displayName,
                      variant: AppTextVariant.titleLarge,
                      color: AppColors.white,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    if (merchant.isVerified)
                      Row(
                        children: [
                          Icon(Icons.verified, color: AppColors.white, size: 16),
                          SizedBox(width: AppSpacing.xs),
                          AppText(
                            'Verified',
                            variant: AppTextVariant.labelSmall,
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  merchant.status.toUpperCase(),
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Today\'s Sales',
                  currencyFormat.format(merchant.dailyVolume),
                  Icons.today,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Monthly Sales',
                  currencyFormat.format(merchant.monthlyVolume),
                  Icons.calendar_month,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Transactions',
                  merchant.totalTransactions.toString(),
                  Icons.receipt_long,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildStatItem(
                  'Fee Rate',
                  '${merchant.feePercent}%',
                  Icons.percent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.white.withValues(alpha: 0.7), size: 20),
          SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.white.withValues(alpha: 0.7),
                ),
                AppText(
                  value,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n, MerchantResponse merchant) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.qr_code,
            label: 'Show QR',
            onTap: () => context.push('/merchant-qr', extra: merchant),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionCard(
            icon: Icons.add_card,
            label: 'Request Payment',
            onTap: () => context.push('/create-payment-request', extra: merchant),
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildActionCard(
            icon: Icons.history,
            label: l10n.navigation_transactions,
            onTap: () => context.push('/merchant-transactions', extra: merchant.merchantId),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.gold500),
            ),
            SizedBox(height: AppSpacing.xs),
            AppText(
              label,
              variant: AppTextVariant.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, AppLocalizations l10n, MerchantResponse merchant) {
    final analyticsAsync = ref.watch(merchantAnalyticsProvider(
      MerchantAnalyticsParams(
        merchantId: merchant.merchantId,
        period: _selectedPeriod,
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              'Analytics',
              variant: AppTextVariant.titleMedium,
            ),
            SizedBox(
              width: 140,
              child: AppSelect<String>(
                value: _selectedPeriod,
                items: const [
                  AppSelectItem(value: 'day', label: 'Today', icon: Icons.today),
                  AppSelectItem(value: 'week', label: 'This Week', icon: Icons.date_range),
                  AppSelectItem(value: 'month', label: 'This Month', icon: Icons.calendar_month),
                  AppSelectItem(value: 'year', label: 'This Year', icon: Icons.calendar_today),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedPeriod = value);
                  }
                },
                showCheckmark: false,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        analyticsAsync.when(
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(color: AppColors.gold500),
            ),
          ),
          error: (_, __) => AppCard(
            variant: AppCardVariant.subtle,
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppText('Failed to load analytics', color: AppColors.error),
          ),
          data: (analytics) => _buildAnalyticsCards(analytics),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(MerchantAnalyticsResponse analytics) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.sm,
      childAspectRatio: 1.5,
      children: [
        _buildAnalyticsCard(
          'Total Volume',
          currencyFormat.format(analytics.totalVolume),
          Icons.attach_money,
          AppColors.success,
        ),
        _buildAnalyticsCard(
          'Total Fees',
          currencyFormat.format(analytics.totalFees),
          Icons.receipt,
          AppColors.warning,
        ),
        _buildAnalyticsCard(
          'Transactions',
          analytics.totalTransactions.toString(),
          Icons.swap_horiz,
          AppColors.gold500,
        ),
        _buildAnalyticsCard(
          'Unique Customers',
          analytics.uniqueCustomers.toString(),
          Icons.people,
          AppColors.gold500,
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          AppText(
            value,
            variant: AppTextVariant.titleLarge,
            color: color,
          ),
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: AppColors.silver,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, AppLocalizations l10n, MerchantResponse merchant) {
    final transactionsAsync = ref.watch(merchantTransactionsProvider(
      MerchantTransactionsParams(
        merchantId: merchant.merchantId,
        limit: 5,
      ),
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AppText(
              'Recent Transactions',
              variant: AppTextVariant.titleMedium,
            ),
            TextButton(
              onPressed: () => context.push('/merchant-transactions', extra: merchant.merchantId),
              child: AppText('See All', color: AppColors.gold500),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.sm),
        transactionsAsync.when(
          loading: () => Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(color: AppColors.gold500),
            ),
          ),
          error: (_, __) => AppCard(
            variant: AppCardVariant.subtle,
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppText('Failed to load transactions', color: AppColors.error),
          ),
          data: (response) {
            if (response.transactions.isEmpty) {
              return AppCard(
                variant: AppCardVariant.elevated,
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: AppColors.silver),
                      SizedBox(height: AppSpacing.sm),
                      AppText('No transactions yet', color: AppColors.silver),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: response.transactions
                  .map((tx) => _buildTransactionItem(tx))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTransactionItem(MerchantTransaction tx) {
    return AppCard(
      variant: AppCardVariant.subtle,
      padding: EdgeInsets.all(AppSpacing.md),
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_downward,
              color: AppColors.success,
              size: 20,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  tx.reference,
                  variant: AppTextVariant.bodyMedium,
                ),
                AppText(
                  DateFormat('MMM dd, HH:mm').format(tx.createdAt),
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.silver,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                '+\$${tx.netAmount.toStringAsFixed(2)}',
                variant: AppTextVariant.bodyLarge,
                color: AppColors.success,
              ),
              AppText(
                'Fee: \$${tx.fee.toStringAsFixed(2)}',
                variant: AppTextVariant.labelSmall,
                color: AppColors.silver,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
