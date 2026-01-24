import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';

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
    _AirtimeProvider('Safaricom', Colors.green, 'assets/safaricom.png'),
    _AirtimeProvider('Airtel', Colors.red, 'assets/airtel.png'),
    _AirtimeProvider('Telkom', Colors.blue, 'assets/telkom.png'),
    _AirtimeProvider('Equitel', Colors.orange, 'assets/equitel.png'),
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
    final walletState = ref.watch(walletStateMachineProvider);
    final userState = ref.watch(userStateMachineProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Airtime'),
            Tab(text: 'Data Bundles'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAirtimeTab(walletState, userState),
          _buildDataTab(walletState, userState),
        ],
      ),
    );
  }

  Widget _buildAirtimeTab(WalletState walletState, UserState userState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          _buildBalanceCard(walletState),

          const SizedBox(height: AppSpacing.xxl),

          // Provider Selection
          const AppText(
            'Select Network',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProviderGrid(),

          const SizedBox(height: AppSpacing.xxl),

          // Buy for self/other toggle
          _buildRecipientToggle(userState),

          const SizedBox(height: AppSpacing.xxl),

          // Phone Number
          if (!_buyForSelf) ...[
            const AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
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
          const AppText(
            'Amount',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildQuickAmounts(),

          const SizedBox(height: AppSpacing.lg),

          // Custom Amount
          _buildCustomAmountInput(),

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
          _buildRecentPurchases(),
        ],
      ),
    );
  }

  Widget _buildDataTab(WalletState walletState, UserState userState) {
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
          _buildBalanceCard(walletState),

          const SizedBox(height: AppSpacing.xxl),

          // Provider Selection
          const AppText(
            'Select Network',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildProviderGrid(),

          const SizedBox(height: AppSpacing.xxl),

          // Buy for self/other toggle
          _buildRecipientToggle(userState),

          const SizedBox(height: AppSpacing.xxl),

          // Phone Number
          if (!_buyForSelf) ...[
            const AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
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
          const AppText(
            'Select Bundle',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),

          ...dataBundles.map((bundle) => _buildDataBundleItem(bundle)),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(WalletState walletState) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.gold500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.gold500),
          ),
          const SizedBox(width: AppSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppText(
                'Available Balance',
                variant: AppTextVariant.labelSmall,
                color: AppColors.textSecondary,
              ),
              AppText(
                '\$${walletState.availableBalance.toStringAsFixed(2)}',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProviderGrid() {
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
                color: isSelected ? provider.color.withValues(alpha: 0.1) : AppColors.slate,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: isSelected ? provider.color : AppColors.borderSubtle,
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
                    color: isSelected ? provider.color : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecipientToggle(UserState userState) {
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
                  color: _buyForSelf ? AppColors.gold500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                      color: _buyForSelf ? AppColors.obsidian : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      'For Myself',
                      variant: AppTextVariant.labelSmall,
                      color: _buyForSelf ? AppColors.obsidian : AppColors.textSecondary,
                    ),
                    if (_buyForSelf && userState.phone != null)
                      AppText(
                        userState.phone!,
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.obsidian.withValues(alpha: 0.7),
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
                  color: !_buyForSelf ? AppColors.gold500 : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add,
                      color: !_buyForSelf ? AppColors.obsidian : AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      'For Someone Else',
                      variant: AppTextVariant.labelSmall,
                      color: !_buyForSelf ? AppColors.obsidian : AppColors.textSecondary,
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

  Widget _buildQuickAmounts() {
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
              color: isSelected ? AppColors.gold500 : AppColors.slate,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
              ),
            ),
            child: Center(
              child: AppText(
                '\$$amount',
                variant: AppTextVariant.labelLarge,
                color: isSelected ? AppColors.obsidian : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Or enter custom amount',
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              const AppText(
                '\$',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: AppTypography.titleMedium,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0.00',
                    hintStyle: TextStyle(color: AppColors.textTertiary),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentPurchases() {
    final recentPurchases = [
      _RecentPurchase('Safaricom', '+254712345678', 10.00, DateTime.now().subtract(const Duration(days: 2))),
      _RecentPurchase('Airtel', '+254723456789', 5.00, DateTime.now().subtract(const Duration(days: 7))),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Recent Purchases',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        ...recentPurchases.map((purchase) => _buildRecentPurchaseItem(purchase)),
      ],
    );
  }

  Widget _buildRecentPurchaseItem(_RecentPurchase purchase) {
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
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    purchase.phone,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
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
                  color: AppColors.textPrimary,
                ),
                AppText(
                  _formatDate(purchase.date),
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.refresh, color: AppColors.gold500, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBundleItem(_DataBundle bundle) {
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
                color: AppColors.gold500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.data_usage, color: AppColors.gold500),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    bundle.name,
                    variant: AppTextVariant.labelLarge,
                    color: AppColors.textPrimary,
                  ),
                  AppText(
                    'Valid for ${bundle.validity}',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            AppText(
              '\$${bundle.price.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: AppColors.gold500,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
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
          backgroundColor: AppColors.successBase,
        ),
      );
      ref.read(walletStateMachineProvider.notifier).refresh();
      ref.read(transactionStateMachineProvider.notifier).refresh();
      context.pop();
    }
  }

  Future<void> _buyDataBundle(_DataBundle bundle) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
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
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Valid for ${bundle.validity}',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'Price: \$${bundle.price.toStringAsFixed(2)}',
              variant: AppTextVariant.titleMedium,
              color: AppColors.gold500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', color: AppColors.textSecondary),
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
                    backgroundColor: AppColors.successBase,
                  ),
                );
                ref.read(walletStateMachineProvider.notifier).refresh();
              }
            },
            child: const AppText('Buy Now', color: AppColors.gold500),
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
