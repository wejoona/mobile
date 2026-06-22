import 'dart:async';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/send_flow_visuals.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _showSaveOption = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    unawaited(_controller.forward());

    unawaited(
      Future<void>.microtask(() {
        _checkBeneficiaryStatus();
        _triggerResultHaptic();
      }),
    );
  }

  void _triggerResultHaptic() {
    final state = ref.read(sendMoneyProvider);
    if (state.result == null) {
      return;
    }
    final isSuccess =
        state.result != null && state.result!.status == 'completed';

    if (isSuccess) {
      unawaited(hapticService.paymentConfirmed());
    } else {
      unawaited(hapticService.error());
    }
  }

  void _checkBeneficiaryStatus() {
    final state = ref.read(sendMoneyProvider);
    if (state.recipient != null &&
        state.recipient!.hasPhone &&
        !state.recipient!.isBeneficiary) {
      setState(() => _showSaveOption = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(sendMoneyProvider);
    final colors = context.colors;

    if (state.result == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: SafeArea(
          child: _MissingTransferResultState(
            title: localizedSendCopy(
              context,
              en: 'Transfer details unavailable',
              fr: 'Détails du transfert indisponibles',
            ),
            body: localizedSendCopy(
              context,
              en: 'Start a new transfer so Korido can confirm the recipient, amount, and final status.',
              fr: 'Démarrez un nouveau transfert afin que Korido confirme le destinataire, le montant et le statut final.',
            ),
            primaryLabel: l10n.send_title,
            secondaryLabel: l10n.action_backToHome,
            onPrimary: _handleStartNewTransfer,
            onSecondary: _handleDone,
          ),
        ),
      );
    }

    final isSuccess =
        state.result != null && state.result!.status == 'completed';

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final minHeight =
                constraints.maxHeight > AppSpacing.screenPadding * 2
                ? constraints.maxHeight - AppSpacing.screenPadding * 2
                : 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      _buildResultContent(l10n, state, colors, isSuccess),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.sm),
                      _buildActions(l10n, isSuccess),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultContent(
    AppLocalizations l10n,
    SendMoneyState state,
    ThemeColors colors,
    bool isSuccess,
  ) => Column(
    children: [
      const SizedBox(height: AppSpacing.xs),
      ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              (isSuccess ? colors.success : colors.error).withValues(
                alpha: colors.isDark ? 0.16 : 0.10,
              ),
              colors.container,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xxxl),
            border: Border.all(
              color: (isSuccess ? colors.success : colors.error).withValues(
                alpha: 0.28,
              ),
            ),
          ),
          child: Icon(
            isSuccess ? Icons.check_circle : Icons.error,
            size: 36,
            color: isSuccess ? colors.success : colors.error,
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.md),
      AppText(
        isSuccess ? l10n.send_transferSuccess : l10n.send_transferFailed,
        variant: AppTextVariant.titleLarge,
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: AppSpacing.xs),
      if (isSuccess)
        AppText(
          l10n.send_transferSuccessMessage,
          color: colors.textSecondary,
          textAlign: TextAlign.center,
        )
      else
        AppText(
          state.error ?? l10n.error_transferFailed,
          color: colors.error,
          textAlign: TextAlign.center,
        ),
      const SizedBox(height: AppSpacing.md),
      if (isSuccess && state.result != null) ...[
        AppCard(
          variant: AppCardVariant.elevated,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              AppText(
                l10n.send_amount,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: AmountText.fromText(
                  formatUsdc(state.result!.amount),
                  size: AmountTextSize.medium,
                  color: colors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: AppText(
                      state.recipient?.name ??
                          state.recipient?.displayIdentifier ??
                          '',
                      variant: AppTextVariant.bodyLarge,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (state.recipient?.isKoridoUser ?? false) ...[
                    const SizedBox(width: AppSpacing.xs),
                    const KoridoAccountBadge(),
                  ],
                ],
              ),
              if (state.recipient?.name != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  state.recipient!.displayIdentifier,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
              const SizedBox(height: AppSpacing.xs),
              Divider(color: colors.borderSubtle),
              const SizedBox(height: AppSpacing.xs),
              SendDetailRow(
                label: l10n.send_date,
                value: Formatters.formatDateTime(state.result!.createdAt),
              ),
              const SizedBox(height: AppSpacing.sm),
              SendDetailRow(
                label: l10n.send_reference,
                value: '',
                valueWidget: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: AppText(
                        _truncateReference(state.result!.reference),
                        variant: AppTextVariant.bodyMedium,
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    IconButton(
                      tooltip: l10n.common_copy,
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      icon: Icon(
                        Icons.copy_rounded,
                        size: 17,
                        color: colors.gold,
                      ),
                      onPressed: () =>
                          _copyToClipboard(state.result!.reference),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
      if (!isSuccess) ...[
        const SizedBox(height: AppSpacing.md),
        SendCallout(
          icon: Icons.support_agent_outlined,
          title: localizedSendCopy(
            context,
            en: 'No money left your wallet',
            fr: 'Aucun argent n’a quitté votre wallet',
          ),
          body: localizedSendCopy(
            context,
            en: 'Please retry once the connection is stable. If the issue continues, share the error with support.',
            fr: 'Réessayez quand la connexion est stable. Si le problème continue, partagez l’erreur avec le support.',
          ),
          tone: SendCalloutTone.info,
        ),
      ],
    ],
  );

  Widget _buildActions(AppLocalizations l10n, bool isSuccess) {
    if (isSuccess) {
      return Column(
        children: [
          if (_showSaveOption)
            AppButton(
              label: l10n.send_saveAsBeneficiary,
              variant: AppButtonVariant.secondary,
              icon: Icons.bookmark_add_outlined,
              onPressed: _handleSaveBeneficiary,
              isFullWidth: true,
            ),
          if (_showSaveOption) const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.send_shareReceipt,
            variant: AppButtonVariant.secondary,
            icon: Icons.share_outlined,
            onPressed: _handleShareReceipt,
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: l10n.action_done,
            onPressed: _handleDone,
            isFullWidth: true,
          ),
        ],
      );
    }

    return Column(
      children: [
        AppButton(
          label: l10n.action_retry,
          onPressed: () => context.fsmGo('/send/confirm'),
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.action_cancel,
          variant: AppButtonVariant.secondary,
          onPressed: _handleDone,
          isFullWidth: true,
        ),
      ],
    );
  }

  Future<void> _copyToClipboard(String text) async {
    final l10n = AppLocalizations.of(context)!;
    unawaited(hapticService.lightTap());
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      context.showSnack(
        l10n.common_copiedToClipboard,
        tone: AppSnackTone.success,
      );
    }
  }

  String _truncateReference(String reference) {
    if (reference.length <= 18) {
      return reference;
    }
    return '${reference.substring(0, 8)}...${reference.substring(reference.length - 6)}';
  }

  Future<void> _handleSaveBeneficiary() async {
    final state = ref.read(sendMoneyProvider);
    if (state.recipient == null || !state.recipient!.hasPhone) {
      return;
    }

    // Navigate to add beneficiary screen or show dialog
    // For now, we'll add directly
    try {
      final request = CreateBeneficiaryRequest(
        name: state.recipient!.name ?? state.recipient!.displayIdentifier,
        phoneE164: state.recipient!.phoneNumber,
        accountType: AccountType.joonapayUser,
      );

      await ref.read(beneficiariesProvider.notifier).createBeneficiary(request);

      setState(() => _showSaveOption = false);

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        context.showSnack(
          l10n.send_beneficiarySaved,
          tone: AppSnackTone.success,
        );
      }
    } on Object {
      if (mounted) {
        context.showSnack(
          AppLocalizations.of(context)!.common_genericError,
          tone: AppSnackTone.error,
        );
      }
    }
  }

  Future<void> _handleShareReceipt() async {
    final state = ref.read(sendMoneyProvider);
    if (state.result == null) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final text =
        '''
${l10n.send_transferReceipt}

${l10n.send_amount}: ${formatUsdc(state.result!.amount)}
${l10n.send_recipient}: ${state.recipient?.name ?? state.recipient?.displayIdentifier}
${l10n.send_reference}: ${state.result!.reference}
${l10n.send_date}: ${Formatters.formatDateTime(state.result!.createdAt)}

${l10n.appName}
''';

    await SharePlus.instance.share(ShareParams(text: text));
  }

  void _handleDone() {
    // Reset the send state
    ref.read(sendMoneyProvider.notifier).reset();
    // Navigate to home
    context.fsmGo('/home');
  }

  void _handleStartNewTransfer() {
    ref.read(sendMoneyProvider.notifier).reset();
    context.fsmGo('/send');
  }
}

class _MissingTransferResultState extends StatelessWidget {
  const _MissingTransferResultState({
    required String title,
    required String body,
    required String primaryLabel,
    required String secondaryLabel,
    required VoidCallback onPrimary,
    required VoidCallback onSecondary,
  }) : _title = title,
       _body = body,
       _primaryLabel = primaryLabel,
       _secondaryLabel = secondaryLabel,
       _onPrimary = onPrimary,
       _onSecondary = onSecondary;

  final String _title;
  final String _body;
  final String _primaryLabel;
  final String _secondaryLabel;
  final VoidCallback _onPrimary;
  final VoidCallback _onSecondary;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Center(
        child: AppCard(
          variant: AppCardVariant.flat,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: colors.gold),
              const SizedBox(height: AppSpacing.lg),
              AppText(
                _title,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                _body,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _primaryLabel,
                onPressed: _onPrimary,
                isFullWidth: true,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: _secondaryLabel,
                variant: AppButtonVariant.secondary,
                onPressed: _onSecondary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
