import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';

enum BillCategory { electricity, water, internet, tv, phone, insurance, tax, other }

class BillPayView extends ConsumerStatefulWidget {
  const BillPayView({super.key});

  @override
  ConsumerState<BillPayView> createState() => _BillPayViewState();
}

class _BillPayViewState extends ConsumerState<BillPayView> {
  BillCategory? _selectedCategory;
  String? _selectedProvider;
  final _accountController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _verifiedName;

  final Map<BillCategory, List<String>> _providers = {
    BillCategory.electricity: ['KPLC', 'REA', 'Stima', 'UMEME'],
    BillCategory.water: ['Nairobi Water', 'Mombasa Water', 'Kisumu Water'],
    BillCategory.internet: ['Safaricom Home', 'Zuku', 'Faiba', 'JTL'],
    BillCategory.tv: ['DSTV', 'GOtv', 'StarTimes', 'Showmax'],
    BillCategory.phone: ['Safaricom', 'Airtel', 'Telkom', 'Equitel'],
    BillCategory.insurance: ['Jubilee', 'AAR', 'Britam', 'CIC'],
    BillCategory.tax: ['KRA', 'County Government', 'NHIF', 'NSSF'],
    BillCategory.other: ['School Fees', 'Rent', 'Other'],
  };

  final Map<BillCategory, IconData> _categoryIcons = {
    BillCategory.electricity: Icons.bolt,
    BillCategory.water: Icons.water_drop,
    BillCategory.internet: Icons.wifi,
    BillCategory.tv: Icons.tv,
    BillCategory.phone: Icons.phone_android,
    BillCategory.insurance: Icons.shield,
    BillCategory.tax: Icons.account_balance,
    BillCategory.other: Icons.receipt,
  };

  @override
  void dispose() {
    _accountController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletStateMachineProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Pay Bills',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Available Balance
            _buildBalanceCard(walletState, colors),

            const SizedBox(height: AppSpacing.xxl),

            // Bill Categories
            AppText(
              'Select Category',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildCategoryGrid(colors),

            if (_selectedCategory != null) ...[
              const SizedBox(height: AppSpacing.xxl),

              // Provider Selection
              AppText(
                'Select Provider',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildProviderList(colors),

              if (_selectedProvider != null) ...[
                const SizedBox(height: AppSpacing.xxl),

                // Account Number
                AppText(
                  'Account/Meter Number',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: AppInput(
                        controller: _accountController,
                        hint: 'Enter account number',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _verifyAccount(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (_isVerifying)
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.gold,
                        ),
                      )
                    else if (_verifiedName != null)
                      const Icon(Icons.check_circle, color: AppColors.successBase, size: 24),
                  ],
                ),
                if (_verifiedName != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    'Account: $_verifiedName',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.successBase,
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                // Amount
                AppText(
                  'Amount',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                _buildAmountInput(colors),

                const SizedBox(height: AppSpacing.lg),

                // Quick Amounts
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    _buildQuickAmountChip(500, colors),
                    _buildQuickAmountChip(1000, colors),
                    _buildQuickAmountChip(2000, colors),
                    _buildQuickAmountChip(5000, colors),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Pay Button
                AppButton(
                  label: _isLoading ? 'Processing...' : 'Pay Bill',
                  onPressed: _canPay() ? _payBill : null,
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Recent Bills
            if (_selectedCategory == null) ...[
              _buildRecentBills(colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(WalletState walletState, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.account_balance_wallet, color: colors.gold),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'Available Balance',
                variant: AppTextVariant.labelSmall,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${walletState.availableBalance.toStringAsFixed(2)}',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(ThemeColors colors) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 0.9,
      children: BillCategory.values.map((category) {
        final isSelected = _selectedCategory == category;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = category;
              _selectedProvider = null;
              _verifiedName = null;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected ? colors.gold : colors.borderSubtle,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _categoryIcons[category],
                  color: isSelected ? colors.gold : colors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  _getCategoryName(category),
                  variant: AppTextVariant.labelSmall,
                  color: isSelected ? colors.gold : colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProviderList(ThemeColors colors) {
    final providers = _providers[_selectedCategory] ?? [];
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: providers.map((provider) {
        final isSelected = _selectedProvider == provider;
        return GestureDetector(
          onTap: () => setState(() {
            _selectedProvider = provider;
            _verifiedName = null;
          }),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected ? colors.gold : colors.container,
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: isSelected ? colors.gold : colors.borderSubtle,
              ),
            ),
            child: AppText(
              provider,
              variant: AppTextVariant.labelSmall,
              color: isSelected ? colors.canvas : colors.textSecondary,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAmountInput(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        children: [
          AppText(
            '\$',
            variant: AppTextVariant.headlineMedium,
            color: colors.textTertiary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: AppTypography.headlineMedium,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0.00',
                hintStyle: TextStyle(color: colors.textTertiary),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountChip(int amount, ThemeColors colors) {
    return GestureDetector(
      onTap: () => setState(() => _amountController.text = amount.toString()),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: AppText(
          '\$$amount',
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildRecentBills(ThemeColors colors) {
    final recentBills = [
      _RecentBill('KPLC', 'Electricity', 45.50, DateTime.now().subtract(const Duration(days: 5))),
      _RecentBill('Safaricom', 'Internet', 30.00, DateTime.now().subtract(const Duration(days: 12))),
      _RecentBill('DSTV', 'TV', 25.00, DateTime.now().subtract(const Duration(days: 20))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Recent Bills',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...recentBills.map((bill) => _buildRecentBillItem(bill, colors)),
      ],
    );
  }

  Widget _buildRecentBillItem(_RecentBill bill, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () {
          // Pre-fill from recent bill
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected ${bill.provider}'),
              backgroundColor: AppColors.infoBase,
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.receipt, color: colors.gold, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    bill.provider,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    bill.category,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '\$${bill.amount.toStringAsFixed(2)}',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  _formatDate(bill.date),
                  variant: AppTextVariant.bodySmall,
                  color: colors.textTertiary,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.refresh, color: colors.gold, size: 20),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(BillCategory category) {
    switch (category) {
      case BillCategory.electricity:
        return 'Electric';
      case BillCategory.water:
        return 'Water';
      case BillCategory.internet:
        return 'Internet';
      case BillCategory.tv:
        return 'TV';
      case BillCategory.phone:
        return 'Phone';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.tax:
        return 'Tax';
      case BillCategory.other:
        return 'Other';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}';
  }

  Future<void> _verifyAccount() async {
    if (_accountController.text.length < 6) {
      setState(() => _verifiedName = null);
      return;
    }

    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isVerifying = false;
      _verifiedName = 'John Doe - Account #${_accountController.text}';
    });
  }

  bool _canPay() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedCategory != null &&
        _selectedProvider != null &&
        _accountController.text.length >= 6 &&
        amount > 0 &&
        _verifiedName != null;
  }

  Future<void> _payBill() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill payment of \$${_amountController.text} successful!'),
          backgroundColor: AppColors.successBase,
        ),
      );
      ref.read(walletStateMachineProvider.notifier).refresh();
      ref.read(transactionStateMachineProvider.notifier).refresh();
      context.pop();
    }
  }
}

class _RecentBill {
  final String provider;
  final String category;
  final double amount;
  final DateTime date;

  _RecentBill(this.provider, this.category, this.amount, this.date);
}
