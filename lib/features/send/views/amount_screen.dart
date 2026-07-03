import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/utils/money_flow_limit_errors.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_warning_banner.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

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
    final sendState = ref.read(sendMoneyProvider);
    final initialAmount = sendState.amount;
    if (initialAmount != null && initialAmount > 0) {
      _amountController.text = initialAmount.toStringAsFixed(2);
      _draftAmount = initialAmount;
    }
    final initialNote = sendState.note?.trim();
    if (initialNote != null && initialNote.isNotEmpty) {
      _noteController.text = initialNote;
    }
    Future.microtask(() {
      ref.read(limitsProvider.notifier).fetchLimits();
      final sendState = ref.read(sendMoneyProvider);
      if (!sendState.hasVerifiedBalance && !sendState.isBalanceLoading) {
        ref.read(sendMoneyProvider.notifier).loadBalance();
      }
    });
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
      Future.microtask(() => context.fsmGo('/send'));
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
                                    state.recipient!.displayIdentifier,
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
                                            state.recipient!.displayIdentifier,
                                        variant: AppTextVariant.bodyLarge,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                if (state.recipient!.name != null)
                                  AppText(
                                    state.recipient!.displayIdentifier,
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
                                  color: colors.gold,
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
                          state.isBalanceLoading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.gold,
                                  ),
                                )
                              : AmountText.fromText(
                                  _balanceStatusText(context, state),
                                  size: AmountTextSize.small,
                                  color: _balanceStatusColor(colors, state),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (!state.isBalanceLoading &&
                        !state.hasVerifiedBalance) ...[
                      SendCallout(
                        icon: Icons.sync_problem_rounded,
                        title: localizedSendCopy(
                          context,
                          en: 'Balance not verified',
                          fr: 'Solde non vérifié',
                        ),
                        body: _balanceUnavailableMessage(context, state),
                        tone: SendCalloutTone.warning,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

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
                    if (limitsState.limits?.hasActiveOverride == true) ...[
                      SendCallout(
                        icon: Icons.verified_user_outlined,
                        title: localizedSendCopy(
                          context,
                          en: 'Special limits active',
                          fr: 'Limites speciales actives',
                        ),
                        body: _specialLimitMessage(
                          context,
                          limitsState.limits!,
                        ),
                        tone: SendCalloutTone.success,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    if (_shouldShowVerificationLimitCallout(
                      limitsState.limits,
                    )) ...[
                      SendCallout(
                        icon: Icons.verified_user_outlined,
                        title: localizedSendCopy(
                          context,
                          en: '${limitsState.limits!.tierName} limits active',
                          fr: 'Limites ${limitsState.limits!.tierName} actives',
                        ),
                        body: _verificationLimitMessage(
                          context,
                          limitsState.limits!,
                        ),
                        tone: SendCalloutTone.info,
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],

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
                              onPressed: state.hasVerifiedBalance
                                  ? _setMaxAmount
                                  : null,
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
                  onPressed: state.hasVerifiedBalance ? _handleContinue : null,
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

  bool _shouldShowVerificationLimitCallout(TransactionLimits? limits) {
    if (limits == null) return false;
    final status = limits.kycStatus?.toLowerCase();
    return limits.kycTier <= 1 ||
        status == 'pending' ||
        status == 'manual_review' ||
        status == 'submitted';
  }

  String _verificationLimitMessage(
    BuildContext context,
    TransactionLimits limits,
  ) {
    final message = limits.upgradeMessage;
    final language = Localizations.localeOf(context).languageCode;
    if (language != 'fr' && message != null && message.trim().isNotEmpty) {
      return message.trim();
    }
    final status = limits.kycStatus?.toLowerCase();
    if (status == 'manual_review' || status == 'submitted') {
      return localizedSendCopy(
        context,
        en: 'Your verification is under review. You can keep using Korido within the limits shown here.',
        fr: 'Votre vérification est en cours de revue. Vous pouvez continuer à utiliser Korido dans les limites affichées ici.',
      );
    }
    return localizedSendCopy(
      context,
      en: 'These limits come from your current verification level and update automatically after approval.',
      fr: 'Ces limites dépendent de votre niveau de vérification actuel et seront mises à jour après approbation.',
    );
  }

  String _specialLimitMessage(BuildContext context, TransactionLimits limits) {
    final reason = limits.overrideReason?.trim();
    final expiresAt = limits.overrideExpiresAt;
    if (reason != null && reason.isNotEmpty) {
      return reason;
    }
    if (expiresAt != null) {
      final formatted = MaterialLocalizations.of(
        context,
      ).formatShortDate(expiresAt);
      return localizedSendCopy(
        context,
        en: 'A support-approved limit is active until $formatted.',
        fr: 'Une limite approuvee par le support est active jusqu au $formatted.',
      );
    }
    return localizedSendCopy(
      context,
      en: 'A support-approved limit is active for this account.',
      fr: 'Une limite approuvee par le support est active pour ce compte.',
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
    if (!state.hasVerifiedBalance) {
      return localizedSendCopy(
        context,
        en: 'Korido could not verify your available balance. Refresh and try again.',
        fr: 'Korido ne peut pas vérifier votre solde disponible. Actualisez puis réessayez.',
      );
    }
    if (amount > state.availableBalance) {
      return l10n.error_insufficientBalance;
    }

    // Check against daily limit
    final limitsState = ref.read(limitsProvider);
    if (limitsState.limits != null) {
      final limits = limitsState.limits!;
      final hit = limits.limitHitByFor(TransactionLimitOperation.send, amount);
      switch (hit) {
        case 'manual_review_required':
        case 'kyc_required':
          return moneyFlowLimitErrorFor(
            hit!,
            limits,
            TransactionLimitOperation.send,
          );
        case 'single_transaction':
          return '${localizedSendCopy(context, en: 'Maximum per transfer', fr: 'Maximum par transfert')}: ${formatUsdc(limits.singleTransactionLimit)}';
        case 'daily':
          if (limits.isDailyAtLimitFor(TransactionLimitOperation.send)) {
            return '${l10n.limits_dailyLimitReached} ${formatUsdc(limits.dailyLimitFor(TransactionLimitOperation.send))}';
          }
          return '${l10n.limits_remaining}: ${formatUsdc(limits.dailyRemainingFor(TransactionLimitOperation.send))}';
        case 'monthly':
          if (limits.isMonthlyAtLimit) {
            return '${l10n.limits_monthlyLimitReached} ${formatUsdc(limits.monthlyLimit)}';
          }
          return '${l10n.limits_remaining}: ${formatUsdc(limits.monthlyRemaining)}';
        default:
          break;
      }
    }

    return null;
  }

  void _setMaxAmount() {
    final state = ref.read(sendMoneyProvider);
    if (!state.hasVerifiedBalance) {
      return;
    }
    final limits = ref.read(limitsProvider).limits;
    final maxAmount = limits == null
        ? state.availableBalance
        : [
            state.availableBalance,
            if (limits.effectiveMaxFor(TransactionLimitOperation.send) > 0)
              limits.effectiveMaxFor(TransactionLimitOperation.send),
          ].reduce((a, b) => a < b ? a : b);
    _amountController.text = maxAmount.toStringAsFixed(2);
    _updateDraftAmount(_amountController.text);
  }

  Future<void> _handleContinue() async {
    final state = ref.read(sendMoneyProvider);
    if (!state.hasVerifiedBalance) {
      return;
    }
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
        context.fsmPush('/send/confirm');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _balanceStatusText(BuildContext context, SendMoneyState state) {
    if (state.hasVerifiedBalance) {
      return formatUsdc(state.availableBalance);
    }
    return localizedSendCopy(context, en: 'Unavailable', fr: 'Indisponible');
  }

  Color _balanceStatusColor(ThemeColors colors, SendMoneyState state) {
    return state.hasVerifiedBalance ? colors.textPrimary : colors.warningText;
  }

  String _balanceUnavailableMessage(
    BuildContext context,
    SendMoneyState state,
  ) {
    final error = state.balanceError?.trim();
    if (error != null && error.isNotEmpty) {
      return localizedSendCopy(
        context,
        en: 'We could not confirm your wallet balance. You can retry from the previous screen or pull to refresh on Home.',
        fr: 'Nous ne pouvons pas confirmer le solde de votre wallet. Réessayez depuis l’écran précédent ou actualisez l’accueil.',
      );
    }
    return localizedSendCopy(
      context,
      en: 'Checking your wallet balance before continuing.',
      fr: 'Vérification du solde du wallet avant de continuer.',
    );
  }
}
