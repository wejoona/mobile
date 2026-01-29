import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/formatters.dart';
import '../providers/external_transfer_provider.dart';
import '../models/external_transfer_request.dart';

class ExternalAmountScreen extends ConsumerStatefulWidget {
  const ExternalAmountScreen({super.key});

  @override
  ConsumerState<ExternalAmountScreen> createState() => _ExternalAmountScreenState();
}

class _ExternalAmountScreenState extends ConsumerState<ExternalAmountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;

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
      Future.microtask(() => context.go('/send-external'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
                  padding: EdgeInsets.all(AppSpacing.md),
                  children: [
                    // Recipient address card (truncated)
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.gold500.withOpacity(0.2),
                                child: Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: AppColors.gold500,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText(
                                      l10n.sendExternal_recipientAddress,
                                      variant: AppTextVariant.bodySmall,
                                      color: AppColors.textSecondary,
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
                        ],
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Available balance
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(
                          l10n.wallet_availableBalance,
                          variant: AppTextVariant.bodyMedium,
                          color: AppColors.textSecondary,
                        ),
                        AppText(
                          '\$${Formatters.formatCurrency(state.availableBalance)}',
                          variant: AppTextVariant.bodyLarge,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold500,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.md),

                    // Amount input
                    AppInput(
                      label: l10n.send_amount,
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      prefix: Padding(
                        padding: EdgeInsets.only(left: AppSpacing.sm),
                        child: AppText('\$ ', variant: AppTextVariant.bodyLarge),
                      ),
                      validator: _validateAmount,
                      onChanged: _onAmountChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      suffix: TextButton(
                        onPressed: _setMaxAmount,
                        child: AppText(
                          l10n.send_max,
                          variant: AppTextVariant.labelMedium,
                          color: AppColors.gold500,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Network selection
                    AppText(
                      l10n.sendExternal_selectNetwork,
                      variant: AppTextVariant.labelLarge,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkOption(NetworkOption.polygon, l10n),
                    SizedBox(height: AppSpacing.sm),
                    _buildNetworkOption(NetworkOption.ethereum, l10n),
                    SizedBox(height: AppSpacing.xl),

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
                                  color: AppColors.textSecondary,
                                ),
                                AppText(
                                  '\$${Formatters.formatCurrency(state.amount!)}',
                                  variant: AppTextVariant.bodyMedium,
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
                                      color: AppColors.textSecondary,
                                    ),
                                    if (state.isEstimatingFee) ...[
                                      SizedBox(width: AppSpacing.xs),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.gold500,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                AppText(
                                  '\$${Formatters.formatCurrency(state.estimatedFee)}',
                                  variant: AppTextVariant.bodyMedium,
                                ),
                              ],
                            ),
                            Divider(
                              height: AppSpacing.md * 2,
                              color: AppColors.textSecondary.withOpacity(0.2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.sendExternal_total,
                                  variant: AppTextVariant.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                ),
                                AppText(
                                  '\$${Formatters.formatCurrency(state.total)}',
                                  variant: AppTextVariant.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.gold500,
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
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.errorBase.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.errorBase,
                          size: 20,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppText(
                            state.error!,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.errorBase,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Bottom button
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: l10n.action_continue,
                  onPressed: state.canProceedToConfirm && state.hasSufficientBalance
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
      onTap: () => ref.read(externalTransferProvider.notifier).setNetwork(network),
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500.withOpacity(0.1) : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.gold500.withOpacity(0.3) : AppColors.borderDefault,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
            ),
            SizedBox(width: AppSpacing.md),
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
                            color: AppColors.successBase.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: AppText(
                            l10n.sendExternal_recommended,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.successBase,
                          ),
                        ),
                      ],
                    ],
                  ),
                  AppText(
                    '${l10n.sendExternal_fee}: ~\$${Formatters.formatCurrency(network.estimatedFee)} • ${network.estimatedTime}',
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

  String _truncateAddress(String address) {
    if (address.length <= 20) return address;
    return '${address.substring(0, 10)}...${address.substring(address.length - 8)}';
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
    // Max amount is balance minus estimated fee
    final maxAmount = (state.availableBalance - state.estimatedFee).clamp(0.0, double.infinity);
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
        context.push('/send-external/confirm');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
