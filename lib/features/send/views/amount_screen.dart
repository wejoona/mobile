import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../utils/formatters.dart';
import '../providers/send_provider.dart';

class AmountScreen extends ConsumerStatefulWidget {
  const AmountScreen({super.key});

  @override
  ConsumerState<AmountScreen> createState() => _AmountScreenState();
}

class _AmountScreenState extends ConsumerState<AmountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);

    if (state.recipient == null) {
      // Navigate back if no recipient
      Future.microtask(() => context.go('/send'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.send_enterAmount,
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
                    // Recipient info card
                    AppCard(
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.gold500.withOpacity(0.2),
                            child: Icon(
                              Icons.person_outline,
                              color: AppColors.gold500,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  state.recipient!.name ??
                                      state.recipient!.phoneNumber,
                                  variant: AppTextVariant.bodyLarge,
                                  fontWeight: FontWeight.w600,
                                ),
                                if (state.recipient!.name != null)
                                  AppText(
                                    state.recipient!.phoneNumber,
                                    variant: AppTextVariant.bodySmall,
                                    color: AppColors.textSecondary,
                                  ),
                              ],
                            ),
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
                      prefix: const Padding(
                        padding: EdgeInsets.only(left: 12),
                        child: Text('\$ ', style: TextStyle(color: AppColors.textPrimary)),
                      ),
                      validator: _validateAmount,
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
                    SizedBox(height: AppSpacing.md),

                    // Note/memo input (optional)
                    AppInput(
                      label: l10n.send_note,
                      controller: _noteController,
                      hint: l10n.send_noteOptional,
                      maxLines: 3,
                      maxLength: 200,
                    ),
                    SizedBox(height: AppSpacing.xl),

                    // Fee preview
                    if (state.fee > 0)
                      AppCard(
                        variant: AppCardVariant.subtle,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.send_amount,
                                  variant: AppTextVariant.bodyMedium,
                                ),
                                AppText(
                                  '\$${Formatters.formatCurrency(state.amount ?? 0)}',
                                  variant: AppTextVariant.bodyMedium,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.send_fee,
                                  variant: AppTextVariant.bodyMedium,
                                  color: AppColors.textSecondary,
                                ),
                                AppText(
                                  '\$${Formatters.formatCurrency(state.fee)}',
                                  variant: AppTextVariant.bodyMedium,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                            Divider(
                              height: AppSpacing.md,
                              color: AppColors.textSecondary.withOpacity(0.2),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                AppText(
                                  l10n.send_total,
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
                ),
              ),

              // Bottom button
              Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: AppButton(
                  label: l10n.action_continue,
                  onPressed: _handleContinue,
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

  String? _validateAmount(String? value) {
    final l10n = AppLocalizations.of(context)!;
    if (value == null || value.isEmpty) {
      return l10n.error_amountRequired;
    }

    final amount = double.tryParse(value);
    if (amount == null || amount <= 0) {
      return l10n.error_amountInvalid;
    }

    final state = ref.read(sendMoneyProvider);
    if (amount > state.availableBalance) {
      return l10n.error_insufficientBalance;
    }

    return null;
  }

  void _setMaxAmount() {
    final state = ref.read(sendMoneyProvider);
    _amountController.text = state.availableBalance.toStringAsFixed(2);
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      final note =
          _noteController.text.isEmpty ? null : _noteController.text.trim();

      ref.read(sendMoneyProvider.notifier).setAmount(amount);
      ref.read(sendMoneyProvider.notifier).setNote(note);

      if (mounted) {
        context.push('/send/confirm');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
