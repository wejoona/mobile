import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';

class BuyAirtimeView extends ConsumerStatefulWidget {
  const BuyAirtimeView({super.key});

  @override
  ConsumerState<BuyAirtimeView> createState() => _BuyAirtimeViewState();
}

class _BuyAirtimeViewState extends ConsumerState<BuyAirtimeView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedProvider;
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  bool _buyForSelf = true;

  final List<_AirtimeProvider> _providers = [
    _AirtimeProvider('Orange', Colors.orange, 'assets/orange.png'),
    _AirtimeProvider('MTN', Colors.yellow.shade700, 'assets/mtn.png'),
    _AirtimeProvider('Moov', Colors.blue, 'assets/moov.png'),
    _AirtimeProvider('Wave', Colors.cyan, 'assets/wave.png'),
  ];

  final List<int> _quickAmounts = [1, 2, 5, 10, 20, 50];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedProvider = _providers.first.name;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final walletState = ref.watch(walletStateMachineProvider);
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Buy Airtime',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colors.gold,
          labelColor: colors.gold,
          unselectedLabelColor: colors.textSecondary,
          tabs: const [
            Tab(text: 'Airtime'),
            Tab(text: 'Data Bundles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAirtimeTab(walletState, userState, colors),
          _buildDataTab(walletState, userState, colors),
        ],
      ),
    );
  }

  Widget _buildAirtimeTab(WalletState walletState, UserState userState, ThemeColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(walletState, colors),

          const SizedBox(height: AppSpacing.xxl),

          // Provider Selection
          AppText(
            'Select Network',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProviderGrid(colors),

          const SizedBox(height: AppSpacing.xxl),

          // Buy for self/other toggle
          _buildRecipientToggle(userState, colors),

          const SizedBox(height: AppSpacing.xxl),

          // Phone Number
          if (!_buyForSelf) ...[
            AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _phoneController,
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Amount
          AppText(
            'Amount',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickAmounts(colors),

          const SizedBox(height: AppSpacing.lg),

          // Custom Amount
          _buildCustomAmountInput(colors),

          const SizedBox(height: AppSpacing.xxxl),

          // Buy Button
          AppButton(
            label: _isLoading ? 'Processing...' : 'Buy Airtime',
            onPressed: _canBuy() ? _buyAirtime : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Recent Purchases
          _buildRecentPurchases(colors),
        ],
      ),
    );
  }

  Widget _buildDataTab(WalletState walletState, UserState userState, ThemeColors colors) {
    final dataBundles = [
      _DataBundle('1GB', '24 hours', 1.50),
      _DataBundle('2GB', '7 days', 3.00),
      _DataBundle('5GB', '30 days', 7.50),
      _DataBundle('10GB', '30 days', 12.00),
      _DataBundle('20GB', '30 days', 20.00),
      _DataBundle('Unlimited', '24 hours', 5.00),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(walletState, colors),

          const SizedBox(height: AppSpacing.xxl),

          // Provider Selection
          AppText(
            'Select Network',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProviderGrid(colors),

          const SizedBox(height: AppSpacing.xxl),

          // Buy for self/other toggle
          _buildRecipientToggle(userState, colors),

          const SizedBox(height: AppSpacing.xxl),

          // Phone Number
          if (!_buyForSelf) ...[
            AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _phoneController,
              hint: 'Enter phone number',
              keyboardType: TextInputType.phone,
              prefixIcon: Icons.phone,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Data Bundles
          AppText(
            'Select Bundle',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),

          ...dataBundles.map((bundle) => _buildDataBundleItem(bundle, colors)),

          const SizedBox(height: AppSpacing.xxl),
        ],
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

  Widget _buildProviderGrid(ThemeColors colors) {
    return Row(
      children: _providers.map((provider) {
        final isSelected = _selectedProvider == provider.name;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedProvider = provider.name),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: isSelected ? provider.color.withValues(alpha: 0.1) : colors.container,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isSelected ? provider.color : colors.borderSubtle,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: provider.color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: AppText(
                        provider.name[0],
                        variant: AppTextVariant.labelLarge,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppText(
                    provider.name,
                    variant: AppTextVariant.labelSmall,
                    color: isSelected ? provider.color : colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecipientToggle(UserState userState, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _buyForSelf = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: _buyForSelf ? colors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      color: _buyForSelf ? colors.canvas : colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      'For Myself',
                      variant: AppTextVariant.labelSmall,
                      color: _buyForSelf ? colors.canvas : colors.textSecondary,
                    ),
                    if (_buyForSelf && userState.phone != null)
                      AppText(
                        userState.phone!,
                        variant: AppTextVariant.bodySmall,
                        color: colors.canvas.withValues(alpha: 0.7),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _buyForSelf = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                decoration: BoxDecoration(
                  color: !_buyForSelf ? colors.gold : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: !_buyForSelf ? colors.canvas : colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      'For Someone Else',
                      variant: AppTextVariant.labelSmall,
                      color: !_buyForSelf ? colors.canvas : colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmounts(ThemeColors colors) {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _quickAmounts.map((amount) {
        final isSelected = _amountController.text == amount.toString();
        return GestureDetector(
          onTap: () => setState(() => _amountController.text = amount.toString()),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? colors.gold : colors.container,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected ? colors.gold : colors.borderSubtle,
              ),
            ),
            child: Center(
              child: AppText(
                '\$$amount',
                variant: AppTextVariant.labelLarge,
                color: isSelected ? colors.canvas : colors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountInput(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Or enter custom amount',
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
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
                variant: AppTextVariant.titleMedium,
                color: colors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppInput(
                  controller: _amountController,
                  variant: AppInputVariant.amount,
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPurchases(ThemeColors colors) {
    final recentPurchases = <_RecentPurchase>[
      // Recent purchases will be loaded from API/local storage
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Recent Purchases',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...recentPurchases.map((purchase) => _buildRecentPurchaseItem(purchase, colors)),
      ],
    );
  }

  Widget _buildRecentPurchaseItem(_RecentPurchase purchase, ThemeColors colors) {
    final provider = _providers.firstWhere(
      (p) => p.name == purchase.provider,
      orElse: () => _providers.first,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () {
          setState(() {
            _selectedProvider = purchase.provider;
            _phoneController.text = purchase.phone;
            _amountController.text = purchase.amount.toStringAsFixed(0);
            _buyForSelf = false;
          });
        },
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: provider.color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppText(
                  provider.name[0],
                  variant: AppTextVariant.labelLarge,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    purchase.provider,
                    variant: AppTextVariant.labelMedium,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    purchase.phone,
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
                  '\$${purchase.amount.toStringAsFixed(2)}',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textPrimary,
                ),
                AppText(
                  _formatDate(purchase.date),
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

  Widget _buildDataBundleItem(_DataBundle bundle, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () => _buyDataBundle(bundle),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(Icons.data_usage, color: colors.gold),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    bundle.name,
                    variant: AppTextVariant.labelLarge,
                    color: colors.textPrimary,
                  ),
                  AppText(
                    'Valid for ${bundle.validity}',
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              '\$${bundle.price.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: colors.gold,
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(Icons.chevron_right, color: colors.textTertiary),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}';
  }

  bool _canBuy() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    return _selectedProvider != null &&
        amount > 0 &&
        (_buyForSelf || _phoneController.text.length >= 10);
  }

  Future<void> _buyAirtime() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Airtime of \$${_amountController.text} purchased successfully!'),
          backgroundColor: context.colors.success,
        ),
      );
      ref.read(walletStateMachineProvider.notifier).refresh();
      ref.read(transactionStateMachineProvider.notifier).refresh();
      context.pop();
    }
  }

  Future<void> _buyDataBundle(_DataBundle bundle) async {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.container,
        title: const AppText(
          'Confirm Purchase',
          variant: AppTextVariant.titleMedium,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              '${bundle.name} Data Bundle',
              variant: AppTextVariant.labelLarge,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Valid for ${bundle.validity}',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'Price: \$${bundle.price.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: colors.gold,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Cancel', color: colors.textSecondary),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await Future.delayed(const Duration(seconds: 2));
              setState(() => _isLoading = false);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${bundle.name} data bundle purchased successfully!'),
                    backgroundColor: context.colors.success,
                  ),
                );
                ref.read(walletStateMachineProvider.notifier).refresh();
              }
            },
            child: AppText('Buy Now', color: colors.gold),
          ),
        ],
      ),
    );
  }
}

class _AirtimeProvider {
  final String name;
  final Color color;
  final String logo;

  _AirtimeProvider(this.name, this.color, this.logo);
}

class _RecentPurchase {
  final String provider;
  final String phone;
  final double amount;
  final DateTime date;

  _RecentPurchase(this.provider, this.phone, this.amount, this.date);
}

class _DataBundle {
  final String name;
  final String validity;
  final double price;

  _DataBundle(this.name, this.validity, this.price);
}
