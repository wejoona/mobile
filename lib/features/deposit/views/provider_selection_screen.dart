import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:usdc_wallet/features/deposit/models/provider_data.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
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
    final availabilityAsync = ref.watch(depositProvidersAvailabilityProvider);
    final country = _effectiveCountry(ref);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(l10n.deposit_title, variant: AppTextVariant.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.fsmSafePop(fallbackRoute: '/deposit/amount'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Summary Card
              if (_hasSourceAmount(depositState)) ...[
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
                child: availabilityAsync.when(
                  data: (availability) => _buildAvailabilityState(
                    context,
                    availability,
                    colors,
                    l10n,
                    ref,
                    country.code,
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

  Widget _buildAvailabilityState(
    BuildContext context,
    DepositProvidersAvailability availability,
    ThemeColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
    String selectedCountryCode,
    bool isLoading,
  ) {
    final providers = availability.providers;
    if (providers.isEmpty) {
      return _buildUnavailableState(
        context,
        availability,
        colors,
        l10n,
        ref,
        selectedCountryCode,
      );
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
            onPressed: () => ref.refresh(depositProvidersAvailabilityProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableState(
    BuildContext context,
    DepositProvidersAvailability availability,
    ThemeColors colors,
    AppLocalizations l10n,
    WidgetRef ref,
    String selectedCountryCode,
  ) {
    final isReviewState = availability.supportReviewRequired;
    final canRetry = availability.retryable;
    return Center(
      child: AppCard(
        variant: AppCardVariant.flat,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                isReviewState
                    ? Icons.verified_user_outlined
                    : Icons.account_balance_wallet_outlined,
                size: 32,
                color: colors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              isReviewState
                  ? l10n.deposit_reviewRequiredTitle
                  : l10n.deposit_railsUnavailableTitle,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              isReviewState
                  ? l10n.deposit_reviewRequiredDesc(selectedCountryCode)
                  : l10n.deposit_railsUnavailableDesc(selectedCountryCode),
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (availability.reason != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.deposit_capabilityReason(
                  _humanizeCapabilityReason(availability.reason!),
                ),
                variant: AppTextVariant.bodySmall,
                color: colors.textTertiary,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.deposit_notifyWhenAvailable,
              onPressed: () => _subscribeToDepositAvailability(
                context,
                ref,
                l10n,
                availability,
                selectedCountryCode,
              ),
              variant: AppButtonVariant.primary,
            ),
            if (canRetry) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.action_retry,
                onPressed: () =>
                    ref.refresh(depositProvidersAvailabilityProvider),
                variant: AppButtonVariant.ghost,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _subscribeToDepositAvailability(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    DepositProvidersAvailability availability,
    String selectedCountryCode,
  ) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: 'deposit_${selectedCountryCode.toLowerCase()}',
              source: 'deposit_provider_selection',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: 'Korido deposits',
              requestedFeature: 'deposit_rails',
              countryCode: availability.country ?? selectedCountryCode,
              locale: user?.preferredLocale,
              metadata: {
                'surface': 'deposit_provider_selection',
                'status': availability.status,
                if (availability.reason != null) 'reason': availability.reason,
                'retryable': availability.retryable,
                'supportReviewRequired': availability.supportReviewRequired,
              },
            ),
          );
      if (!context.mounted) return;
      context.showSnack(l10n.deposit_notifySuccess, tone: AppSnackTone.success);
    } catch (e) {
      if (!context.mounted) return;
      context.showSnack(
        l10n.common_errorFormat(e.toString()),
        tone: AppSnackTone.error,
      );
    }
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

    if (!context.mounted) return;

    // Navigate to payment instructions if successful, passing response as extra
    final response = ref.read(depositProvider).response;
    if (response != null) {
      unawaited(context.fsmPush('/deposit/instructions', extra: response));
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
    switch (provider.brandKey) {
      case 'orange_money':
        return const Color(0xFFFF6B35);
      case 'mtn_momo':
        return const Color(0xFFFFCB05);
      case 'moov_money':
        return const Color(0xFF0066CC);
      case 'wave':
        return const Color(0xFF4A148C);
      case 'card':
        return const Color(0xFF2563EB);
      case 'ach':
        return const Color(0xFF047857);
      case 'crypto':
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
      case 'MOBILE_MONEY':
        return Icons.notifications_active;
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
      case 'MOBILE_MONEY':
        return l10n.deposit_approveOnPhone;
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

bool _hasSourceAmount(DepositState depositState) {
  final currency = depositState.sourceCurrency ?? 'XOF';
  if (currency == 'USD') {
    return (depositState.amountUSD ?? 0) > 0;
  }
  return (depositState.amountXOF ?? 0) > 0;
}

String _humanizeCapabilityReason(String reason) {
  return reason.replaceAll('_', ' ');
}

CountryConfig _effectiveCountry(WidgetRef ref) {
  final selectedCountry = ref.watch(selectedCountryProvider);
  final userCountryCode = ref.watch(
    userStateMachineProvider.select((state) => state.countryCode),
  );
  return SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
}
