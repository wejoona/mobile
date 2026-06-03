import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Provider Selection Screen
///
/// Fetches country-aware providers from API.
/// Each shows its PaymentMethodType (OTP, PUSH, QR_LINK, CARD, ACH, CRYPTO)
/// User selects → calls initiate API → navigates to payment instructions
class ProviderSelectionScreen extends ConsumerWidget {
  const ProviderSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final depositState = ref.watch(depositProvider);
    final providersAsync = ref.watch(providersListProvider);
    final country = ref.watch(selectedCountryProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(l10n.deposit_title, variant: AppTextVariant.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Summary Card
              if ((depositState.amountXOF ?? 0) > 0) ...[
                AppCard(
                  variant: AppCardVariant.flat,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              '${l10n.deposit_amount} · ${country.code}',
                              variant: AppTextVariant.bodySmall,
                              color: colors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: AmountText.fromText(
                                  _formatSourceAmount(depositState),
                                  size: AmountTextSize.small,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            AppText(
                              l10n.deposit_youWillReceive,
                              variant: AppTextVariant.bodySmall,
                              color: colors.textSecondary,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerRight,
                                child: AmountText.fromText(
                                  formatUsdc(depositState.amountUSD ?? 0),
                                  size: AmountTextSize.small,
                                  color: colors.gold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Title
              AppText(
                l10n.deposit_choosePaymentMethod,
                variant: AppTextVariant.headlineSmall,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.deposit_selectHowToDeposit,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xl),

              // Providers List
              Expanded(
                child: providersAsync.when(
                  data: (providers) => _buildProvidersList(
                    providers,
                    colors,
                    l10n,
                    ref,
                    depositState.isLoading,
                  ),
                  loading: () => _buildLoadingState(colors, l10n),
                  error: (err, stack) => _buildErrorState(colors, l10n, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProvidersList(
    List<ProviderData> providers,
    ThemeColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
    bool isLoading,
  ) {
    if (providers.isEmpty) {
      return _buildEmptyState(colors, l10n);
    }

    return ListView.separated(
      itemCount: providers.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final provider = providers[index];
        return _ProviderTile(
          provider: provider,
          colors: colors,
          l10n: l10n,
          isLoading: isLoading,
          onTap: () => _selectProvider(context, provider, ref),
        );
      },
    );
  }

  Widget _buildLoadingState(ThemeColors colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.gold),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.common_loading,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    ThemeColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.error),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.common_error,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.common_errorTryAgain,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.action_retry,
            onPressed: () => ref.refresh(providersListProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.payment_outlined, size: 64, color: colors.textTertiary),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.deposit_noProvidersAvailable,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.deposit_noProvidersAvailableDesc,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectProvider(
    BuildContext context,
    ProviderData provider,
    WidgetRef ref,
  ) async {
    // Select the provider
    ref.read(depositProvider.notifier).selectProviderData(provider);

    // Initiate the deposit immediately
    await ref.read(depositProvider.notifier).initiateDeposit();

    // Navigate to payment instructions if successful, passing response as extra
    final response = ref.read(depositProvider).response;
    if (response != null && context.mounted) {
      context.push('/deposit/instructions', extra: response);
    }
  }
}

class _ProviderTile extends StatelessWidget {
  final ProviderData provider;
  final ThemeColors colors;
  final AppLocalizations l10n;
  final bool isLoading;
  final VoidCallback onTap;

  const _ProviderTile({
    required this.provider,
    required this.colors,
    required this.l10n,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      key: ValueKey('deposit_provider_${provider.id}'),
      variant: AppCardVariant.flat,
      borderRadius: AppRadius.lg,
      onTap: isLoading ? null : onTap,
      child: Row(
        children: [
          // Provider Logo/Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _getProviderColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Center(child: _buildProviderIcon()),
          ),
          const SizedBox(width: AppSpacing.lg),

          // Provider Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  provider.name,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      _getPaymentMethodIcon(),
                      size: 16,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: AppText(
                        _getPaymentMethodDescription(),
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Loading or Arrow
          if (isLoading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.gold,
              ),
            )
          else
            Icon(Icons.chevron_right, color: colors.textTertiary),
        ],
      ),
    );
  }

  Color _getProviderColor() {
    switch (provider.id.toUpperCase()) {
      case 'OMCI':
      case 'ORANGE_MONEY':
        return const Color(0xFFFF6B35);
      case 'MTNCI':
      case 'MTN_MOMO':
        return const Color(0xFFFFCB05);
      case 'MOOVCI':
      case 'MOOV_MONEY':
        return const Color(0xFF0066CC);
      case 'WAVECI':
      case 'WAVE':
        return const Color(0xFF4A148C);
      case 'US_CARD':
        return const Color(0xFF2563EB);
      case 'US_ACH':
        return const Color(0xFF047857);
      case 'USDC_CRYPTO':
        return const Color(0xFF2775CA);
      default:
        return colors.gold;
    }
  }

  Widget _buildProviderIcon() {
    return _getGenericIcon();
  }

  Widget _getGenericIcon() {
    return Icon(_getPaymentMethodIcon(), color: _getProviderColor(), size: 32);
  }

  IconData _getPaymentMethodIcon() {
    switch (provider.paymentMethodType?.toUpperCase()) {
      case 'OTP':
        return Icons.dialpad;
      case 'PUSH':
        return Icons.notifications_active;
      case 'QR_LINK':
        return Icons.qr_code;
      case 'CARD':
        return Icons.credit_card;
      case 'ACH':
      case 'BANK_TRANSFER':
        return Icons.account_balance;
      case 'CRYPTO':
        return Icons.account_balance_wallet;
      default:
        return Icons.payment;
    }
  }

  String _getPaymentMethodDescription() {
    switch (provider.paymentMethodType?.toUpperCase()) {
      case 'OTP':
        return l10n.deposit_enterOTP;
      case 'PUSH':
        return l10n.deposit_approveOnPhone;
      case 'QR_LINK':
        return l10n.deposit_scanQRCode;
      case 'CARD':
        return l10n.deposit_cardPayment;
      case 'ACH':
      case 'BANK_TRANSFER':
        return l10n.deposit_bankTransfer;
      case 'CRYPTO':
        return l10n.deposit_cryptoTransfer;
      default:
        return '';
    }
  }
}

String _formatSourceAmount(DepositState depositState) {
  final currency = depositState.sourceCurrency ?? 'XOF';
  if (currency == 'USD') {
    return '\$${(depositState.amountUSD ?? 0).toStringAsFixed(2)}';
  }
  return formatXof(depositState.amountXOF ?? 0);
}
