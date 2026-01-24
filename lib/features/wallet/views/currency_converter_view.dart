import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class CurrencyConverterView extends ConsumerStatefulWidget {
  const CurrencyConverterView({super.key});

  @override
  ConsumerState<CurrencyConverterView> createState() => _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends ConsumerState<CurrencyConverterView> {
  final _fromController = TextEditingController(text: '100');
  String _fromCurrency = 'USDC';
  String _toCurrency = 'USD';
  bool _isLoading = false;

  // Mock exchange rates (in production, fetch from API)
  final Map<String, double> _exchangeRates = {
    'USD': 1.0,
    'USDC': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'NGN': 1580.0,
    'KES': 129.0,
    'ZAR': 18.50,
    'GHS': 15.80,
    'INR': 83.40,
    'BRL': 4.97,
    'MXN': 17.15,
    'CAD': 1.36,
    'AUD': 1.53,
    'JPY': 149.50,
    'CNY': 7.24,
  };

  final Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'USDC': 'USD Coin',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'NGN': 'Nigerian Naira',
    'KES': 'Kenyan Shilling',
    'ZAR': 'South African Rand',
    'GHS': 'Ghanaian Cedi',
    'INR': 'Indian Rupee',
    'BRL': 'Brazilian Real',
    'MXN': 'Mexican Peso',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
  };

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'USDC': '\$',
    'EUR': '\u20AC',
    'GBP': '\u00A3',
    'NGN': '\u20A6',
    'KES': 'KSh',
    'ZAR': 'R',
    'GHS': 'GH\u20B5',
    'INR': '\u20B9',
    'BRL': 'R\$',
    'MXN': 'MX\$',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'JPY': '\u00A5',
    'CNY': '\u00A5',
  };

  double get _fromAmount => double.tryParse(_fromController.text) ?? 0;

  double get _convertedAmount {
    final fromRate = _exchangeRates[_fromCurrency] ?? 1;
    final toRate = _exchangeRates[_toCurrency] ?? 1;
    return (_fromAmount / fromRate) * toRate;
  }

  double get _exchangeRate {
    final fromRate = _exchangeRates[_fromCurrency] ?? 1;
    final toRate = _exchangeRates[_toCurrency] ?? 1;
    return toRate / fromRate;
  }

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Currency Converter',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshRates,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // From Currency
            _buildCurrencyInput(
              label: 'From',
              controller: _fromController,
              currency: _fromCurrency,
              onCurrencyChanged: (currency) {
                setState(() => _fromCurrency = currency);
              },
              isEditable: true,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Swap Button
            Center(
              child: GestureDetector(
                onTap: _swapCurrencies,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gold500,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold500.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.swap_vert,
                    color: AppColors.obsidian,
                    size: 24,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // To Currency
            _buildCurrencyInput(
              label: 'To',
              amount: _convertedAmount,
              currency: _toCurrency,
              onCurrencyChanged: (currency) {
                setState(() => _toCurrency = currency);
              },
              isEditable: false,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Exchange Rate Info
            _buildExchangeRateCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Quick Amount Buttons
            const AppText(
              'Quick Amounts',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildQuickAmountButton(10),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(50),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(100),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(500),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Popular Currencies
            const AppText(
              'Popular Currencies',
              variant: AppTextVariant.titleMedium,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPopularCurrencies(),

            const SizedBox(height: AppSpacing.xxl),

            // Disclaimer
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.infoBase, size: 20),
                      SizedBox(width: AppSpacing.sm),
                      AppText(
                        'Rate Information',
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const AppText(
                    'Exchange rates are for informational purposes only and may differ from actual transaction rates. Rates are updated every hour.',
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String label,
    TextEditingController? controller,
    double? amount,
    required String currency,
    required ValueChanged<String> onCurrencyChanged,
    required bool isEditable,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: isEditable
                    ? TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: AppColors.textTertiary),
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : AppText(
                        _formatAmount(amount ?? 0),
                        variant: AppTextVariant.headlineMedium,
                        color: AppColors.gold500,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => _showCurrencyPicker(currency, onCurrencyChanged),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      _buildCurrencyFlag(currency),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        currency,
                        variant: AppTextVariant.labelLarge,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      const Icon(
                        Icons.expand_more,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            '${_currencySymbols[currency] ?? ''}${_currencyNames[currency] ?? currency}',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyFlag(String currency) {
    // Simple colored circle as placeholder for actual flags
    final colors = {
      'USD': Colors.green,
      'USDC': AppColors.gold500,
      'EUR': Colors.blue,
      'GBP': Colors.purple,
      'NGN': Colors.green.shade800,
      'KES': Colors.red,
      'ZAR': Colors.orange,
      'GHS': Colors.yellow.shade700,
      'INR': Colors.orange.shade800,
      'BRL': Colors.green.shade700,
      'MXN': Colors.green.shade600,
      'CAD': Colors.red.shade700,
      'AUD': Colors.blue.shade800,
      'JPY': Colors.red.shade400,
      'CNY': Colors.red.shade600,
    };

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: colors[currency] ?? AppColors.textTertiary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: AppText(
          currency.substring(0, 1),
          variant: AppTextVariant.labelSmall,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildExchangeRateCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold500.withValues(alpha: 0.15),
            AppColors.gold600.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                '1 $_fromCurrency = ${_formatAmount(_exchangeRate)} $_toCurrency',
                variant: AppTextVariant.titleMedium,
                color: AppColors.gold500,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Updated just now',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _fromController.text = amount.toString();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Center(
            child: AppText(
              '\$$amount',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCurrencies() {
    final popularCurrencies = ['USD', 'EUR', 'GBP', 'NGN', 'KES'];

    return Column(
      children: popularCurrencies.map((currency) {
        final rate = _exchangeRates[currency] ?? 1;
        final usdcRate = rate / (_exchangeRates['USDC'] ?? 1);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            variant: AppCardVariant.subtle,
            onTap: () {
              setState(() => _toCurrency = currency);
            },
            child: Row(
              children: [
                _buildCurrencyFlag(currency),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        currency,
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textPrimary,
                      ),
                      AppText(
                        _currencyNames[currency] ?? currency,
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
                      '${_currencySymbols[currency]}${_formatAmount(usdcRate)}',
                      variant: AppTextVariant.labelMedium,
                      color: AppColors.textPrimary,
                    ),
                    const AppText(
                      'per USDC',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCurrencyPicker(String currentCurrency, ValueChanged<String> onChanged) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  const AppText(
                    'Select Currency',
                    variant: AppTextVariant.titleMedium,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _exchangeRates.length,
                itemBuilder: (context, index) {
                  final currency = _exchangeRates.keys.elementAt(index);
                  final isSelected = currency == currentCurrency;

                  return ListTile(
                    leading: _buildCurrencyFlag(currency),
                    title: AppText(
                      currency,
                      variant: AppTextVariant.labelMedium,
                      color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                    ),
                    subtitle: AppText(
                      _currencyNames[currency] ?? currency,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.gold500)
                        : null,
                    onTap: () {
                      onChanged(currency);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
    });
  }

  Future<void> _refreshRates() async {
    setState(() => _isLoading = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exchange rates updated'),
          backgroundColor: AppColors.successBase,
        ),
      );
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      return amount.toStringAsFixed(2);
    } else if (amount >= 1) {
      return amount.toStringAsFixed(2);
    } else {
      return amount.toStringAsFixed(4);
    }
  }
}
