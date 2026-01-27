import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final merchantAsync = ref.watch(merchantProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        actions: [
          IconButton(
            onPressed: () => context.push('/merchant-settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: merchantAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Error loading merchant profile',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(merchantProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (merchant) {
          if (merchant == null) {
            return _buildNotMerchantView(context);
          }
          return _buildDashboard(context, merchant);
        },
      ),
    );
  }

  Widget _buildNotMerchantView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            const Text(
              'Become a Merchant',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Accept USDC payments from customers with QR codes',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.push('/merchant-register'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Register as Merchant'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, MerchantResponse merchant) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(merchantProfileProvider);
        ref.invalidate(merchantAnalyticsProvider(MerchantAnalyticsParams(
          merchantId: merchant.merchantId,
          period: _selectedPeriod,
        )));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status banner
            if (!merchant.isVerified)
              _buildStatusBanner(theme, merchant),

            // Quick stats
            _buildQuickStats(theme, merchant),
            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(context, merchant),
            const SizedBox(height: 24),

            // Analytics section
            _buildAnalyticsSection(context, merchant),
            const SizedBox(height: 24),

            // Recent transactions
            _buildRecentTransactions(context, merchant),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBanner(ThemeData theme, MerchantResponse merchant) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    if (merchant.isPending) {
      bgColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      icon = Icons.pending;
      message = 'Your merchant account is pending verification';
    } else if (!merchant.isActive) {
      bgColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.warning;
      message = 'Your merchant account is ${merchant.status}';
    } else {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.info;
      message = 'Complete verification to start accepting payments';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ThemeData theme, MerchantResponse merchant) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.primaryColor, theme.primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      merchant.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (merchant.isVerified)
                      Row(
                        children: [
                          const Icon(Icons.verified, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  merchant.status.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
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
                color: Colors.white.withOpacity(0.3),
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
          const SizedBox(height: 16),
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
                color: Colors.white.withOpacity(0.3),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, MerchantResponse merchant) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.qr_code,
            label: 'Show QR',
            onTap: () => context.push(
              '/merchant-qr',
              extra: merchant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.add_card,
            label: 'Request Payment',
            onTap: () => context.push(
              '/create-payment-request',
              extra: merchant,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.history,
            label: 'Transactions',
            onTap: () => context.push(
              '/merchant-transactions',
              extra: merchant.merchantId,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.primaryColor),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, MerchantResponse merchant) {
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
            const AppText(
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
        const SizedBox(height: 16),
        analyticsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Failed to load analytics'),
          ),
          data: (analytics) => _buildAnalyticsCards(context, analytics),
        ),
      ],
    );
  }

  Widget _buildAnalyticsCards(BuildContext context, MerchantAnalyticsResponse analytics) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildAnalyticsCard(
          'Total Volume',
          currencyFormat.format(analytics.totalVolume),
          Icons.attach_money,
          Colors.green,
        ),
        _buildAnalyticsCard(
          'Total Fees',
          currencyFormat.format(analytics.totalFees),
          Icons.receipt,
          Colors.orange,
        ),
        _buildAnalyticsCard(
          'Transactions',
          analytics.totalTransactions.toString(),
          Icons.swap_horiz,
          Colors.blue,
        ),
        _buildAnalyticsCard(
          'Unique Customers',
          analytics.uniqueCustomers.toString(),
          Icons.people,
          Colors.purple,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions(BuildContext context, MerchantResponse merchant) {
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
            const Text(
              'Recent Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push(
                '/merchant-transactions',
                extra: merchant.merchantId,
              ),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        transactionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Failed to load transactions'),
          ),
          data: (response) {
            if (response.transactions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_downward,
              color: Colors.green.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.reference,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, HH:mm').format(tx.createdAt),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+\$${tx.netAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.green.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Fee: \$${tx.fee.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
