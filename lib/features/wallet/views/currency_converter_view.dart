import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class CurrencyConverterView extends ConsumerStatefulWidget {
  const CurrencyConverterView({super.key});

  @override
  ConsumerState<CurrencyConverterView> createState() =>
      _CurrencyConverterViewState();
}

class _CurrencyConverterViewState extends ConsumerState<CurrencyConverterView> {
  final _fromController = TextEditingController(text: '100');
  String _fromCurrency = 'USDC';
  String _toCurrency = 'XOF';
  // ignore: unused_field
  bool _isLoading = false;
  String? _rateError;

  // Exchange rates fetched from API (rates relative to USD)
  Map<String, double> _exchangeRates = {'USD': 1.0, 'USDC': 1.0};

  // Initial markets: US/USDC plus Abidjan/UEMOA rails.
  static const List<String> _supportedCurrencies = [
    'USD',
    'USDC',
    'EUR',
    'XOF',
  ];

  @override
  void initState() {
    super.initState();
    _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      _isLoading = true;
      _rateError = null;
    });

    try {
      final walletService = ref.read(walletServiceProvider);
      final rates = <String, double>{'USD': 1.0, 'USDC': 1.0};

      // Fetch rates for each currency relative to USD
      for (final currency in _supportedCurrencies) {
        if (currency == 'USD' || currency == 'USDC') continue;
        try {
          final rate = await walletService.getRate(
            sourceCurrency: 'USD',
            targetCurrency: currency,
            amount: 1.0,
          );
          // rate.targetAmount is how much of target currency you get for 1 USD
          rates[currency] = rate.targetAmount;
        } catch (_) {
          // Skip currencies that fail — may not be supported by backend
        }
      }

      if (mounted) {
        setState(() {
          _exchangeRates = rates;
          _fromCurrency = rates.containsKey(_fromCurrency)
              ? _fromCurrency
              : 'USDC';
          _toCurrency = rates.containsKey(_toCurrency) ? _toCurrency : 'USD';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _rateError = 'Failed to load exchange rates';
        });
      }
    }
  }

  Map<String, String> _getCurrencyNames(AppLocalizations l10n) => {
    'USD': l10n.currency_usd,
    'USDC': l10n.currency_usdc,
    'EUR': l10n.currency_eur,
    'XOF': l10n.currency_xof,
  };

  final Map<String, String> _currencySymbols = {
    'USD': '\$',
    'USDC': '\$',
    'EUR': '\u20AC',
    'XOF': 'F CFA',
  };

  double get _fromAmount => double.tryParse(_fromController.text) ?? 0;

  bool get _canConvert =>
      _exchangeRates.containsKey(_fromCurrency) &&
      _exchangeRates.containsKey(_toCurrency);

  double? get _convertedAmount {
    if (!_canConvert) return null;
    final fromRate = _exchangeRates[_fromCurrency]!;
    final toRate = _exchangeRates[_toCurrency]!;
    return (_fromAmount / fromRate) * toRate;
  }

  double? get _exchangeRate {
    if (!_canConvert) return null;
    final fromRate = _exchangeRates[_fromCurrency]!;
    final toRate = _exchangeRates[_toCurrency]!;
    return toRate / fromRate;
  }

  @override
  void dispose() {
    _fromController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final currencyNames = _getCurrencyNames(l10n);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.converter_title,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.fsmPop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshRates(context, l10n),
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
              label: l10n.converter_from,
              controller: _fromController,
              currency: _fromCurrency,
              onCurrencyChanged: (currency) {
                setState(() => _fromCurrency = currency);
              },
              isEditable: true,
              colors: colors,
              currencyNames: currencyNames,
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
                    color: colors.gold,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.gold.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.swap_vert, color: colors.canvas, size: 24),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // To Currency
            _buildCurrencyInput(
              label: l10n.converter_to,
              amount: _convertedAmount,
              currency: _toCurrency,
              onCurrencyChanged: (currency) {
                setState(() => _toCurrency = currency);
              },
              isEditable: false,
              colors: colors,
              currencyNames: currencyNames,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Exchange Rate Info
            _buildExchangeRateCard(colors, l10n),

            const SizedBox(height: AppSpacing.xxl),

            // Quick Amount Buttons
            AppText(
              l10n.converter_quickAmounts,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _buildQuickAmountButton(10, colors),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(50, colors),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(100, colors),
                const SizedBox(width: AppSpacing.sm),
                _buildQuickAmountButton(500, colors),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Popular Currencies
            AppText(
              l10n.converter_popularCurrencies,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildPopularCurrencies(colors, currencyNames, l10n),

            const SizedBox(height: AppSpacing.xxl),

            // Disclaimer
            AppCard(
              variant: AppCardVariant.subtle,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: context.colors.info,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        l10n.converter_rateInfo,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textPrimary,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    l10n.converter_rateDisclaimer,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
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
    required ThemeColors colors,
    required Map<String, String> currencyNames,
  }) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            variant: AppTextVariant.labelSmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: isEditable
                    ? TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        style: AppTypography.headlineMedium.copyWith(
                          color: colors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '0.00',
                          hintStyle: TextStyle(color: colors.textTertiary),
                        ),
                        onChanged: (_) => setState(() {}),
                      )
                    : AppText(
                        amount == null
                            ? _localizedText(
                                context,
                                en: 'Rate unavailable',
                                fr: 'Taux indisponible',
                              )
                            : _formatAmount(amount),
                        variant: AppTextVariant.headlineMedium,
                        color: amount == null
                            ? colors.warningText
                            : colors.gold,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              GestureDetector(
                onTap: () => _showCurrencyPicker(
                  currency,
                  onCurrencyChanged,
                  colors,
                  currencyNames,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      _buildCurrencyFlag(currency, colors),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        currency,
                        variant: AppTextVariant.labelLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      Icon(
                        Icons.expand_more,
                        color: colors.textTertiary,
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
            '${_currencySymbols[currency] ?? ''}${currencyNames[currency] ?? currency}',
            variant: AppTextVariant.bodySmall,
            color: colors.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyFlag(String currency, ThemeColors colors) {
    // Simple colored circle as placeholder for actual flags
    final flagColors = {
      'USD': Colors.green,
      'USDC': colors.gold,
      'EUR': Colors.blue,
      'XOF': colors.gold,
    };

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: flagColors[currency] ?? colors.textTertiary,
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

  Widget _buildExchangeRateCard(ThemeColors colors, AppLocalizations l10n) {
    final rate = _exchangeRate;
    final hasRate = rate != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.gold.withValues(alpha: 0.15),
            colors.gold.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.gold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppText(
                hasRate
                    ? l10n.converter_exchangeRate(
                        _fromCurrency,
                        _formatAmount(rate),
                        _toCurrency,
                      )
                    : _localizedText(
                        context,
                        en: 'Exchange rate unavailable',
                        fr: 'Taux de change indisponible',
                      ),
                variant: AppTextVariant.titleMedium,
                color: hasRate ? colors.gold : colors.warningText,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            _rateError ??
                (hasRate
                    ? l10n.converter_updatedJustNow
                    : _localizedText(
                        context,
                        en: 'Refresh or choose another supported currency.',
                        fr: 'Actualisez ou choisissez une devise prise en charge.',
                      )),
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAmountButton(int amount, ThemeColors colors) {
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
            color: colors.container,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Center(
            child: AppText(
              '${_currencySymbols[_fromCurrency] ?? ''}$amount',
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopularCurrencies(
    ThemeColors colors,
    Map<String, String> currencyNames,
    AppLocalizations l10n,
  ) {
    final popularCurrencies = ['XOF', 'USD', 'EUR', 'USDC'];

    return Column(
      children: popularCurrencies.map((currency) {
        final rate = _exchangeRates[currency];
        final usdcRate = rate != null && _exchangeRates.containsKey('USDC')
            ? rate / _exchangeRates['USDC']!
            : null;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppCard(
            variant: AppCardVariant.subtle,
            onTap: () {
              setState(() => _toCurrency = currency);
            },
            child: Row(
              children: [
                _buildCurrencyFlag(currency, colors),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        currency,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textPrimary,
                      ),
                      AppText(
                        currencyNames[currency] ?? currency,
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
                      usdcRate == null
                          ? _localizedText(
                              context,
                              en: 'Unavailable',
                              fr: 'Indisponible',
                            )
                          : '${_currencySymbols[currency] ?? ''}${_formatAmount(usdcRate)}',
                      variant: AppTextVariant.labelMedium,
                      color: usdcRate == null
                          ? colors.warningText
                          : colors.textPrimary,
                    ),
                    AppText(
                      usdcRate == null ? '' : l10n.converter_perUsdc,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
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

  void _showCurrencyPicker(
    String currentCurrency,
    ValueChanged<String> onChanged,
    ThemeColors colors,
    Map<String, String> currencyNames,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
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
                  AppText(
                    l10n.converter_selectCurrency,
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
            Divider(color: colors.borderSubtle),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _exchangeRates.length,
                itemBuilder: (context, index) {
                  final currencies = _exchangeRates.keys.toList()..sort();
                  final currency = currencies.elementAt(index);
                  final isSelected = currency == currentCurrency;

                  return ListTile(
                    leading: _buildCurrencyFlag(currency, colors),
                    title: AppText(
                      currency,
                      variant: AppTextVariant.labelMedium,
                      color: isSelected ? colors.gold : colors.textPrimary,
                    ),
                    subtitle: AppText(
                      currencyNames[currency] ?? currency,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check, color: colors.gold)
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

  Future<void> _refreshRates(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    await _fetchExchangeRates();

    if (mounted && _rateError == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.converter_ratesUpdated),
          backgroundColor: context.colors.success,
        ),
      );
    } else if (mounted && _rateError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_rateError!),
          backgroundColor: context.colors.error,
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

String _localizedText(
  BuildContext context, {
  required String en,
  required String fr,
}) {
  return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}
