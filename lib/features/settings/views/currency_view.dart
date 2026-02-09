import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/currency/currency_service.dart';
import '../../../services/currency/currency_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

class CurrencyView extends ConsumerWidget {
  const CurrencyView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final currencyState = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.settings_defaultCurrency,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Primary Currency (always USDC)
            AppText(
              l10n.currency_primary,
              variant: AppTextVariant.labelMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              variant: AppCardVariant.elevated,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.goldGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Center(
                      child: AppText(
                        '\$',
                        variant: AppTextVariant.titleLarge,
                        color: AppColors.textInverse,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'USDC',
                          variant: AppTextVariant.titleMedium,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          'USD Coin (1 USDC = 1 USD)',
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: colors.gold,
                    size: 24,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Reference Currency Toggle
            AppCard(
              variant: AppCardVariant.subtle,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          l10n.currency_showReference,
                          variant: AppTextVariant.bodyLarge,
                          color: colors.textPrimary,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          l10n.currency_showReferenceDescription,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: currencyState.showReference,
                    onChanged: (value) {
                      ref.read(currencyProvider.notifier).toggleShowReference(value);
                    },
                    activeTrackColor: colors.gold.withValues(alpha: 0.5),
                    activeColor: colors.gold,
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Reference Currency Selection (only show if enabled)
            AnimatedOpacity(
              opacity: currencyState.showReference ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: !currencyState.showReference,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.currency_reference,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.currency_referenceDescription,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...ref.read(currencyProvider.notifier).getSupportedCurrencies().map(
                          (currency) => _CurrencyOption(
                            currency: currency,
                            isSelected: currencyState.referenceCurrency == currency,
                            onTap: () {
                              ref.read(currencyProvider.notifier).setReferenceCurrency(currency);
                            },
                          ),
                        ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Example preview
            if (currencyState.shouldShowReference) ...[
              AppText(
                l10n.currency_preview,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.goldAccent,
                child: Column(
                  children: [
                    AppText(
                      '100.00 USDC',
                      variant: AppTextVariant.headlineMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      ref.read(currencyProvider.notifier).getFormattedReference(100),
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}

class _CurrencyOption extends ConsumerWidget {
  const _CurrencyOption({
    required this.currency,
    required this.isSelected,
    required this.onTap,
  });

  final ReferenceCurrency currency;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isSelected ? colors.gold : colors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Flag
                AppText(
                  currency.flag,
                  variant: AppTextVariant.titleLarge,
                ),
                const SizedBox(width: AppSpacing.md),
                // Currency info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        currency.name,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        '1 USDC \u2248 ${currency.symbol} ${_formatRate(currency.approximateRate)}',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                // Check mark
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colors.gold,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRate(double rate) {
    if (rate >= 100) {
      return rate.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]} ',
          );
    }
    return rate.toStringAsFixed(2);
  }
}
