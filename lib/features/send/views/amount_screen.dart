import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_warning_banner.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

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
  double? _draftAmount;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(limitsProvider.notifier).fetchLimits());
  }

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
    final limitsState = ref.watch(limitsProvider);
    final colors = context.colors;

    if (state.recipient == null) {
      // Navigate back if no recipient
      Future.microtask(() => context.go('/send'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.send_enterAmount,
          variant: AppTextVariant.titleLarge,
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
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  children: [
                    SendFlowHeader(
                      icon: Icons.payments_outlined,
                      title: l10n.send_enterAmount,
                      subtitle: localizedSendCopy(
                        context,
                        en: 'Enter a USDC amount. Fees and total stay visible before confirmation.',
                        fr: 'Saisissez un montant en USDC. Les frais et le total restent visibles avant confirmation.',
                      ),
                      currentStep: 1,
                      metaLabel: sendStepLabel(context, 2),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    AppCard(
                      variant: AppCardVariant.elevated,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              UserAvatar(
                                firstName:
                                    state.recipient!.name?.split(' ').first ??
                                    state.recipient!.phoneNumber,
                                lastName:
                                    state.recipient!.name != null &&
                                        state.recipient!.name!
                                                .split(' ')
                                                .length >
                                            1
                                    ? state.recipient!.name!.split(' ').last
                                    : null,
                                size: 40,
                                showBorder: state.recipient!.isKoridoUser,
                                borderColor: colors.gold,
                              ),
                              if (state.recipient!.isKoridoUser)
                                const Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: KoridoAccountBadge(compact: true),
                                ),
                            ],
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: AppText(
                                        state.recipient!.name ??
                                            state.recipient!.phoneNumber,
                                        variant: AppTextVariant.bodyLarge,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.recipient!.name != null)
                                  AppText(
                                    state.recipient!.phoneNumber,
                                    variant: AppTextVariant.bodySmall,
                                    color: colors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    AppCard(
                      variant: AppCardVariant.flat,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  color: colors.infoText,
                                  size: 20,
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: AppText(
                                    l10n.wallet_availableBalance,
                                    variant: AppTextVariant.bodyMedium,
                                    color: colors.textSecondary,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          AmountText.fromText(
                            formatUsdc(state.availableBalance),
                            size: AmountTextSize.small,
                            color: colors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    SendCallout(
                      icon: Icons.verified_outlined,
                      title: localizedSendCopy(
                        context,
                        en: 'Internal Korido transfer',
                        fr: 'Transfert interne Korido',
                      ),
                      body: localizedSendCopy(
                        context,
                        en: 'Transfers between Korido accounts are instant and currently have no fee.',
                        fr: 'Les transferts entre comptes Korido sont instantanés et sans frais pour le moment.',
                      ),
                      tone: SendCalloutTone.success,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Limits warning banner
                    if (limitsState.limits != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: LimitWarningBanner(limits: limitsState.limits!),
                      ),

                    AppCard(
                      variant: AppCardVariant.elevated,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          AppInput(
                            label: l10n.send_amount,
                            controller: _amountController,
                            variant: AppInputVariant.amount,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefix: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: AppText(
                                'USDC',
                                variant: AppTextVariant.labelMedium,
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            validator: _validateAmount,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}'),
                              ),
                            ],
                            onChanged: _updateDraftAmount,
                            suffix: TextButton(
                              onPressed: _setMaxAmount,
                              child: AppText(
                                localizedSendCopy(
                                  context,
                                  en: 'Max available',
                                  fr: 'Solde max',
                                ),
                                variant: AppTextVariant.labelMedium,
                                color: colors.gold,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppInput(
                            label: l10n.send_note,
                            controller: _noteController,
                            hint: l10n.send_noteOptional,
                            maxLines: 3,
                            maxLength: 200,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    if (_draftAmount != null && _draftAmount! > 0)
                      AppCard(
                        variant: AppCardVariant.flat,
                        child: Column(
                          children: [
                            SendDetailRow(
                              label: l10n.send_amount,
                              value: '',
                              valueWidget: AmountText.fromText(
                                formatUsdc(_draftAmount!),
                                size: AmountTextSize.small,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            SendDetailRow(
                              label: l10n.send_fee,
                              value: '',
                              valueWidget: AmountText.fromText(
                                formatUsdc(state.fee),
                                size: AmountTextSize.small,
                                color: colors.textSecondary,
                              ),
                            ),
                            Divider(
                              height: AppSpacing.xl,
                              color: colors.borderSubtle,
                            ),
                            SendDetailRow(
                              label: l10n.send_total,
                              value: '',
                              valueWidget: AmountText.fromText(
                                formatUsdc(_draftAmount! + state.fee),
                                size: AmountTextSize.small,
                                color: colors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom button
              Padding(
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: AppButton(
                  label: l10n.action_continue,
                  icon: Icons.arrow_forward_rounded,
                  iconPosition: IconPosition.right,
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

  void _updateDraftAmount(String value) {
    final parsed = double.tryParse(value);
    setState(() => _draftAmount = parsed);
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

    // Check against daily limit
    final limitsState = ref.read(limitsProvider);
    if (limitsState.limits != null) {
      final limits = limitsState.limits!;
      if (limits.isDailyAtLimit) {
        return '${l10n.limits_dailyLimitReached} ${formatUsdc(limits.dailyLimit)}';
      }
      if (amount > limits.dailyRemaining) {
        return '${l10n.limits_remaining}: ${formatUsdc(limits.dailyRemaining)}';
      }
      if (limits.isMonthlyAtLimit) {
        return '${l10n.limits_monthlyLimitReached} ${formatUsdc(limits.monthlyLimit)}';
      }
      if (amount > limits.monthlyRemaining) {
        return '${l10n.limits_remaining}: ${formatUsdc(limits.monthlyRemaining)}';
      }
    }

    return null;
  }

  void _setMaxAmount() {
    final state = ref.read(sendMoneyProvider);
    _amountController.text = state.availableBalance.toStringAsFixed(2);
    _updateDraftAmount(_amountController.text);
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text);
      final note = _noteController.text.isEmpty
          ? null
          : _noteController.text.trim();

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
