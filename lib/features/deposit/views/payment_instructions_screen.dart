// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/core/utils/formatters.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';
import 'package:usdc_wallet/features/qr_payment/widgets/branded_qr_image.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Payment Instructions Screen
///
/// Receives DepositResponse with token + paymentMethodType:
/// - OTP flow: Shows provider instructions + lets the user refresh status
/// - PUSH flow: Shows "Approve the payment on your phone" + waiting spinner + auto-polls status
/// - QR_LINK flow: Shows QR code + "Open in Wave" deep link button + auto-polls status
class PaymentInstructionsScreen extends ConsumerStatefulWidget {
  const PaymentInstructionsScreen({super.key, DepositResponse? initialResponse})
    : _initialResponse = initialResponse;

  final DepositResponse? _initialResponse;

  @override
  ConsumerState<PaymentInstructionsScreen> createState() =>
      _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState
    extends ConsumerState<PaymentInstructionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final response = widget._initialResponse;
      if (response == null) {
        return;
      }
      final currentId = ref.read(depositProvider).activeDepositId;
      final incomingId = response.transactionId.isNotEmpty
          ? response.transactionId
          : response.depositId;
      if (currentId != incomingId) {
        ref.read(depositProvider.notifier).hydrateFromResponse(response);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(depositProvider);
    final response = state.response ?? widget._initialResponse;

    ref.listen<DepositState>(depositProvider, (previous, current) {
      final isNewError =
          current.error != null && current.error != previous?.error;
      if (isNewError &&
          current.step != DepositFlowStep.failed &&
          current.step != DepositFlowStep.statusUnknown) {
        _showErrorDialog(context, current.error!, colors, l10n);
      }

      final didReachTerminalStep =
          current.step != previous?.step &&
          (current.step == DepositFlowStep.completed ||
              current.step == DepositFlowStep.failed ||
              current.step == DepositFlowStep.statusUnknown);
      if (didReachTerminalStep) {
        unawaited(context.fsmPush('/deposit/status'));
      }
    });

    if (response == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: AppText(
            l10n.deposit_payment,
            variant: AppTextVariant.titleLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () =>
                context.fsmSafePop(fallbackRoute: '/deposit/amount'),
          ),
        ),
        body: SafeArea(
          child: _DepositInstructionsRecovery(
            title: l10n.deposit_noDepositData,
            primaryLabel: l10n.deposit_amount,
            onPrimary: () => context.fsmGo('/deposit/amount'),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.deposit_payment,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _handleBack(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAmountCard(state, response, colors, l10n),
                      const SizedBox(height: AppSpacing.xl),

                      if (response.instructions.isNotEmpty) ...[
                        AppCard(
                          variant: AppCardVariant.flat,
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: colors.gold,
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppText(
                                  response.instructions,
                                  variant: AppTextVariant.bodyMedium,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                      ],

                      _buildPaymentReferenceCard(response, colors),
                      const SizedBox(height: AppSpacing.xl),

                      _buildTypeSpecificContent(state, response, colors, l10n),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Action button (only for OTP flow)
              if (response.paymentMethodType.requiresOtp)
                _buildActionButton(state, response, colors, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentReferenceCard(
    DepositResponse response,
    ThemeColors colors,
  ) {
    final paymentReference = response.paymentReference.isNotEmpty
        ? response.paymentReference
        : response.token;
    final paymentRail = response.railProvider.isNotEmpty
        ? response.railProvider
        : response.providerCode;
    final executionProvider = response.executionProvider.trim();
    final shouldShowExecutionProvider =
        executionProvider.isNotEmpty &&
        executionProvider != paymentRail &&
        executionProvider != response.providerCode;

    final rows = <Widget>[
      if (paymentReference.isNotEmpty)
        _ReferenceRow(
          label: 'Payment reference',
          value: paymentReference,
          copyValue: paymentReference,
          colors: colors,
        ),
      _ReferenceRow(
        label: 'Expires',
        value: Formatters.formatDateTime(response.expiresAt),
        colors: colors,
      ),
      if (paymentRail.isNotEmpty)
        _ReferenceRow(
          label: 'Payment rail',
          value: paymentRail,
          colors: colors,
        ),
      if (shouldShowExecutionProvider)
        _ReferenceRow(
          label: 'Processed by',
          value: executionProvider,
          colors: colors,
        ),
      if (response.supportReference.isNotEmpty)
        _ReferenceRow(
          label: 'Support reference',
          value: response.supportReference,
          copyValue: response.supportReference,
          colors: colors,
        ),
    ];

    return AppCard(
      key: const ValueKey('deposit_reference_card'),
      variant: AppCardVariant.flat,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            rows[index],
            if (index < rows.length - 1)
              Divider(
                height: AppSpacing.xl,
                color: colors.border.withValues(alpha: 0.45),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    DepositState state,
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return AppCard(
      variant: AppCardVariant.flat,
      child: Row(
        children: [
          Expanded(
            child: _AmountSummaryColumn(
              label: l10n.deposit_youPay,
              value: _formatSourceAmount(state, response),
              valueColor: colors.textPrimary,
              alignEnd: false,
              colors: colors,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(Icons.arrow_forward, color: colors.textTertiary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _AmountSummaryColumn(
              label: l10n.deposit_youReceive,
              value: formatUsdc(
                state.amountUSD ?? response.convertedAmount ?? 0,
              ),
              valueColor: colors.gold,
              alignEnd: true,
              colors: colors,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent(
    DepositState state,
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    switch (response.paymentMethodType) {
      case PaymentMethodType.otp:
        return _buildOtpContent(response, colors, l10n);
      case PaymentMethodType.push:
        return _buildPushContent(response, colors, l10n);
      case PaymentMethodType.qrLink:
        return _buildQrLinkContent(response, colors, l10n);
      case PaymentMethodType.card:
        return _buildStaticInstructionContent(
          colors,
          Icons.credit_card,
          l10n.deposit_cardPayment,
          response.instructions,
        );
      case PaymentMethodType.bankTransfer:
        return _buildStaticInstructionContent(
          colors,
          Icons.account_balance,
          l10n.deposit_bankTransfer,
          response.instructions,
        );
      case PaymentMethodType.crypto:
        return _buildStaticInstructionContent(
          colors,
          Icons.account_balance_wallet,
          l10n.deposit_cryptoTransfer,
          response.instructions,
        );
      case PaymentMethodType.unsupported:
        return _buildStaticInstructionContent(
          colors,
          Icons.error_outline_rounded,
          'Payment method unavailable',
          response.instructions.isNotEmpty
              ? response.instructions
              : 'This deposit method is not available in this version of Korido. Choose another method or contact support.',
        );
    }
  }

  /// OTP flow: provider action happens outside Korido; mobile checks status.
  Widget _buildOtpContent(
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // Dial instruction
        AppCard(
          variant: AppCardVariant.flat,
          child: Column(
            children: [
              Icon(Icons.dialpad, size: 48, color: colors.gold),
              const SizedBox(height: AppSpacing.md),
              AppText(
                response.instructions.isNotEmpty
                    ? response.instructions
                    : l10n.deposit_dialUSSD,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// PUSH flow: Shows "Approve the payment on your phone" + waiting spinner + auto-polls status
  Widget _buildPushContent(
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        AppCard(
          variant: AppCardVariant.flat,
          child: Column(
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: colors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppText(
                l10n.deposit_waitingForApproval,
                variant: AppTextVariant.titleLarge,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.deposit_approveOnPhone,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Countdown timer
        if (response.expiresAt.isAfter(DateTime.now()))
          _CountdownTimer(
            expiresAt: response.expiresAt,
            colors: colors,
            l10n: l10n,
          ),
      ],
    );
  }

  /// QR_LINK flow: Shows QR code + provider deep link button + auto-polls status
  Widget _buildQrLinkContent(
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    return Column(
      children: [
        // QR Code
        if (response.qrCodeData?.isNotEmpty == true) ...[
          AppCard(
            variant: AppCardVariant.flat,
            child: Column(
              children: [
                AppText(
                  l10n.deposit_scanQRCode,
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.canvas,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: BrandedQrImage(
                    data: response.qrCodeData!,
                    size: 200.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        // Deep link button
        if (response.deepLinkUrl?.isNotEmpty == true) ...[
          AppButton(
            label: l10n.deposit_openPaymentApp,
            icon: Icons.open_in_new,
            onPressed: () => _openDeepLink(response.deepLinkUrl!),
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.deposit_orScanQR,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
        ],

        const SizedBox(height: AppSpacing.xl),

        // Status polling indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            AppText(
              l10n.deposit_waitingForPayment,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStaticInstructionContent(
    ThemeColors colors,
    IconData icon,
    String title,
    String instructions,
  ) {
    return Center(
      child: AppCard(
        variant: AppCardVariant.flat,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: colors.textTertiary),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),
            if (instructions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              AppText(
                instructions,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    DepositState state,
    DepositResponse response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    final canCheckStatus =
        state.response?.transactionId.isNotEmpty == true ||
        state.response?.depositId.isNotEmpty == true ||
        state.result?.id.isNotEmpty == true ||
        response.transactionId.isNotEmpty ||
        response.depositId.isNotEmpty;

    return AppButton(
      label: l10n.deposit_completedPayment,
      onPressed: state.isLoading || !canCheckStatus
          ? null
          : () => ref.read(depositProvider.notifier).checkStatus(),
      isLoading: state.isLoading,
      isFullWidth: true,
    );
  }

  void _showErrorDialog(
    BuildContext context,
    String error,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(
          l10n.common_error,
          variant: AppTextVariant.titleMedium,
          color: colors.error,
        ),
        content: AppText(
          error,
          variant: AppTextVariant.bodyMedium,
          color: colors.textPrimary,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(depositProvider.notifier).clearError();
              Navigator.of(context).pop();
            },
            child: AppText(
              l10n.action_ok,
              variant: AppTextVariant.labelMedium,
              color: colors.gold,
            ),
          ),
        ],
      ),
    ).whenComplete(() {
      if (!mounted) return;
      if (ref.read(depositProvider).error == error) {
        ref.read(depositProvider.notifier).clearError();
      }
    });
  }

  Future<void> _openDeepLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently or show a message
    }
  }

  void _handleBack() {
    final state = ref.read(depositProvider);
    if (state.hasUnresolvedDeposit) {
      context.fsmGo('/deposit/status');
      return;
    }

    ref.read(depositProvider.notifier).goBack();
    context.fsmSafePop(fallbackRoute: '/deposit/provider');
  }
}

String _formatSourceAmount(DepositState state, DepositResponse response) {
  final currency = (state.sourceCurrency ?? 'XOF').toUpperCase();
  if (currency == 'USD' || currency == 'USDC') {
    return '\$${(state.amountUSD ?? response.amount).toStringAsFixed(2)}';
  }
  return formatXof(state.amountXOF ?? response.amount);
}

class _DepositInstructionsRecovery extends StatelessWidget {
  const _DepositInstructionsRecovery({
    required String title,
    required String primaryLabel,
    required VoidCallback onPrimary,
  }) : _title = title,
       _primaryLabel = primaryLabel,
       _onPrimary = onPrimary;

  final String _title;
  final String _primaryLabel;
  final VoidCallback _onPrimary;

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
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: _primaryLabel,
                onPressed: _onPrimary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReferenceRow extends StatelessWidget {
  const _ReferenceRow({
    required this.label,
    required this.value,
    required this.colors,
    this.copyValue,
  });

  final String label;
  final String value;
  final String? copyValue;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 3,
          child: AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: colors.textPrimary,
            fontWeight: FontWeight.w600,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
        if (copyValue != null) ...[
          const SizedBox(width: AppSpacing.xs),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.copy_rounded, color: colors.gold, size: 18),
            onPressed: () => Clipboard.setData(ClipboardData(text: copyValue!)),
          ),
        ],
      ],
    );
  }
}

class _AmountSummaryColumn extends StatelessWidget {
  const _AmountSummaryColumn({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.alignEnd,
    required this.colors,
  });

  final String label;
  final String value;
  final Color valueColor;
  final bool alignEnd;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: colors.textSecondary,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Align(
          alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
            child: AmountText.fromText(
              value,
              size: AmountTextSize.medium,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Countdown timer widget for expiration
class _CountdownTimer extends StatefulWidget {
  final DateTime expiresAt;
  final ThemeColors colors;
  final AppLocalizations l10n;

  const _CountdownTimer({
    required this.expiresAt,
    required this.colors,
    required this.l10n,
  });

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.expiresAt.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _remaining = widget.expiresAt.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining.isNegative) {
      return AppText(
        widget.l10n.deposit_expired,
        variant: AppTextVariant.bodyMedium,
        color: widget.colors.error,
      );
    }

    final minutes = _remaining.inMinutes;
    final seconds = _remaining.inSeconds % 60;
    final timeString =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return AppText(
      widget.l10n.deposit_expiresIn(timeString),
      variant: AppTextVariant.bodyMedium,
      color: widget.colors.textSecondary,
    );
  }
}
