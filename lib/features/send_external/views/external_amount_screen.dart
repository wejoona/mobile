import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:usdc_wallet/features/send_external/models/external_transfer_request.dart';
import 'package:usdc_wallet/features/send_external/providers/external_transfer_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

class ExternalAmountScreen extends ConsumerStatefulWidget {
  const ExternalAmountScreen({super.key});

  @override
  ConsumerState<ExternalAmountScreen> createState() =>
      _ExternalAmountScreenState();
}

class _ExternalAmountScreenState extends ConsumerState<ExternalAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    unawaited(Future.microtask(_loadBalanceIfNeeded));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(externalTransferProvider);

    if (!state.hasValidAddress) {
      // Navigate back if no address
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.fsmGo('/send-external');
        }
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.sendExternal_enterAmount,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Recipient address card (truncated)
                    AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: context.colors.gold.withValues(
                              alpha: 0.2,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: context.colors.gold,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  l10n.sendExternal_recipientAddress,
                                  variant: AppTextVariant.bodySmall,
                                  color: context.colors.textSecondary,
                                ),
                                AppText(
                                  _truncateAddress(state.address!),
                                  variant: AppTextVariant.monoMedium,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Available balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: AppText(
                            l10n.wallet_availableBalance,
                            variant: AppTextVariant.bodyMedium,
                            color: context.colors.textSecondary,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _buildBalanceValue(state),
                      ],
                    ),
                    if (!state.hasVerifiedBalance && !state.isBalanceLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.sm),
                        child: AppCard(
                          variant: AppCardVariant.subtle,
                          child: Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: context.colors.warningText,
                                size: 18,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: AppText(
                                  state.balanceError ??
                                      _externalAmountCopy(
                                        en: 'Available balance could not be verified. Please go back and try again.',
                                        fr: 'Le solde disponible n’a pas pu etre verifie. Revenez en arriere puis reessayez.',
                                      ),
                                  variant: AppTextVariant.bodySmall,
                                  color: context.colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: AppSpacing.lg),

                    // Amount input
                    AppInput(
                      label: l10n.sendExternal_amount,
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefix: Padding(
                        padding: EdgeInsets.only(left: AppSpacing.sm),
                        child: AppText(
                          '\$ ',
                          variant: AppTextVariant.bodyLarge,
                        ),
                      ),
                      validator: _validateAmount,
                      onChanged: _onAmountChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      suffix: TextButton(
                        onPressed: state.hasVerifiedBalance
                            ? _setMaxAmount
                            : null,
                        child: AppText(
                          l10n.send_max,
                          variant: AppTextVariant.labelMedium,
                          color: context.colors.gold,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xxl),

                    // Network selection
                    AppText(
                      l10n.sendExternal_selectNetwork,
                      variant: AppTextVariant.labelLarge,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkOption(NetworkOption.polygon, l10n),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkOption(NetworkOption.ethereum, l10n),
                    SizedBox(height: AppSpacing.xxl),

                    // Fee preview
                    if (state.amount != null && state.amount! > 0) ...[
                      AppCard(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.sendExternal_amount,
                                  variant: AppTextVariant.bodyMedium,
                                  color: context.colors.textSecondary,
                                ),
                                AmountText.fromText(
                                  '\$${Formatters.formatCurrency(state.amount!)}',
                                  size: AmountTextSize.small,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    AppText(
                                      l10n.sendExternal_networkFee,
                                      variant: AppTextVariant.bodyMedium,
                                      color: context.colors.textSecondary,
                                    ),
                                    if (state.isEstimatingFee) ...[
                                      SizedBox(width: AppSpacing.xs),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: context.colors.gold,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                AmountText.fromText(
                                  '\$${Formatters.formatCurrency(state.estimatedFee)}',
                                  size: AmountTextSize.small,
                                ),
                              ],
                            ),
                            Divider(
                              height: AppSpacing.lg * 2,
                              color: context.colors.textSecondary.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.sendExternal_total,
                                  variant: AppTextVariant.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                ),
                                AmountText.fromText(
                                  '\$${Formatters.formatCurrency(state.total)}',
                                  size: AmountTextSize.medium,
                                  color: context.colors.gold,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Error message
              if (state.error != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: context.colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: context.colors.error,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppText(
                            state.error!,
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom button
              Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: AppButton(
                  label: l10n.action_continue,
                  onPressed:
                      state.canProceedToConfirm && state.hasSufficientBalance
                      ? _handleContinue
                      : null,
                  isLoading: _isLoading,
                  isFullWidth: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkOption(NetworkOption network, AppLocalizations l10n) {
    final state = ref.watch(externalTransferProvider);
    final isSelected = state.selectedNetwork == network;

    return GestureDetector(
      onTap: () =>
          ref.read(externalTransferProvider.notifier).setNetwork(network),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? context.colors.gold.withValues(alpha: 0.1)
              : context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected
                ? context.colors.gold.withValues(alpha: 0.3)
                : context.colors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? context.colors.gold
                  : context.colors.textSecondary,
            ),
            SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AppText(
                        network.displayName,
                        variant: AppTextVariant.bodyMedium,
                        fontWeight: FontWeight.w600,
                      ),
                      if (network == NetworkOption.polygon) ...[
                        SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.success.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            l10n.sendExternal_recommended,
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.success,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppText(
                    '${l10n.sendExternal_fee}: ~\$${Formatters.formatCurrency(network.estimatedFee)} • ${network.estimatedTime}',
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 8)}';
  }

  void _loadBalanceIfNeeded() {
    final state = ref.read(externalTransferProvider);
    if (!state.hasVerifiedBalance && !state.isBalanceLoading) {
      unawaited(ref.read(externalTransferProvider.notifier).loadBalance());
    }
  }

  Widget _buildBalanceValue(ExternalTransferState state) {
    if (state.isBalanceLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: context.colors.gold,
        ),
      );
    }

    if (!state.hasVerifiedBalance) {
      return AppText(
        _externalAmountCopy(en: 'Unavailable', fr: 'Indisponible'),
        variant: AppTextVariant.labelMedium,
        color: context.colors.warningText,
      );
    }

    return AmountText.fromText(
      '\$${Formatters.formatCurrency(state.availableBalance)}',
      size: AmountTextSize.small,
      color: context.colors.gold,
    );
  }

  String? _validateAmount(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.error_amountRequired;
    }
    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return l10n.error_amountInvalid;
    }
    final state = ref.read(externalTransferProvider);
    if (!state.hasVerifiedBalance) {
      return _externalAmountCopy(
        en: 'Available balance could not be verified. Please try again.',
        fr: 'Le solde disponible n’a pas pu etre verifie. Reessayez.',
      );
    }
    if (state.total > state.availableBalance) {
      return l10n.error_insufficientBalance;
    }
    return null;
  }

  void _onAmountChanged(String value) {
    final amount = double.tryParse(value);
    if (amount != null && amount > 0) {
      ref.read(externalTransferProvider.notifier).setAmount(amount);
    }
  }

  void _setMaxAmount() {
    final state = ref.read(externalTransferProvider);
    if (!state.hasVerifiedBalance) {
      return;
    }
    // Max amount is balance minus estimated fee
    final maxAmount = (state.availableBalance - state.estimatedFee).clamp(
      0.0,
      double.infinity,
    );
    setState(() {
      _amountController.text = maxAmount.toStringAsFixed(2);
    });
    _onAmountChanged(_amountController.text);
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      if (mounted) {
        await context.fsmPush('/send-external/confirm');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _externalAmountCopy({required String en, required String fr}) {
    return Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
  }
}
