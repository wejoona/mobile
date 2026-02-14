// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';
import 'package:usdc_wallet/features/deposit/providers/deposit_provider.dart';

/// Payment Instructions Screen
///
/// Receives DepositResponse with token + paymentMethodType:
/// - OTP flow: Shows "Dial #144*82# on your phone" + OTP input field + Confirm button
/// - PUSH flow: Shows "Approve the payment on your phone" + waiting spinner + auto-polls status
/// - QR_LINK flow: Shows QR code + "Open in Wave" deep link button + auto-polls status
class PaymentInstructionsScreen extends ConsumerStatefulWidget {
  const PaymentInstructionsScreen({super.key});

  @override
  ConsumerState<PaymentInstructionsScreen> createState() =>
      _PaymentInstructionsScreenState();
}

class _PaymentInstructionsScreenState
    extends ConsumerState<PaymentInstructionsScreen> {
  final _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start polling for push and QR flows
    final state = ref.read(depositProvider);
    // ignore: avoid_dynamic_calls
    if (state.response?['paymentMethodType'].isAsyncConfirmation == true ||
        // ignore: avoid_dynamic_calls
        state.response?['paymentMethodType'].hasQrOrLink == true) {
      // Polling is already started in the provider
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(depositProvider);
    final response = state.response;

    // Error handling
    if (state.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorDialog(context, state.error!, colors, l10n);
      });
    }

    // Auto-navigate on completion/failure
    ref.listen(depositProvider, (previous, current) {
      if (current.step == DepositFlowStep.completed ||
          current.step == DepositFlowStep.failed) {
        context.push('/deposit/status');
      }
    });

    if (response == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: Center(
          child: AppText(
            l10n.deposit_noDepositData,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
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
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Amount Summary Card
              _buildAmountCard(state, colors, l10n),
              const SizedBox(height: AppSpacing.xl),

              // Instructions
              if (((response['instructions'] as String?) ?? '').isNotEmpty) ...[
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
                          ((response['instructions'] as String?) ?? ''),
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Type-specific content
              Expanded(
                child: _buildTypeSpecificContent(state, response, colors, l10n),
              ),
              
              const SizedBox(height: AppSpacing.md),

              // Action button (only for OTP flow)
              // ignore: avoid_dynamic_calls
              if (response['paymentMethodType'].requiresOtp) 
                _buildActionButton(state, colors, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(
    DepositState state, 
    ThemeColors colors, 
    AppLocalizations l10n,
  ) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.deposit_youPay,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              AppText(
                '${(state.amountXOF ?? 0).toStringAsFixed(0)} XOF',
                variant: AppTextVariant.headlineSmall,
                color: colors.textPrimary,
              ),
            ],
          ),
          Icon(
            Icons.arrow_forward,
            color: colors.textTertiary,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppText(
                l10n.deposit_youReceive,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
              AppText(
                '\$${(state.amountUSD ?? 0).toStringAsFixed(2)}',
                variant: AppTextVariant.headlineSmall,
                color: colors.gold,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent(
    DepositState state,
    Map<String, dynamic> response,
    ThemeColors colors,
    AppLocalizations l10n,
  ) {
    switch (response['paymentMethodType']) {
      case PaymentMethodType.otp:
        return _buildOtpContent(state, colors, l10n);
      case PaymentMethodType.push:
        return _buildPushContent(state, response, colors, l10n);
      case PaymentMethodType.qrLink:
        return _buildQrLinkContent(state, response, colors, l10n);
      case PaymentMethodType.card:
        return _buildCardContent(colors, l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  /// OTP flow: Shows "Dial #144*82# on your phone" + OTP input field + Confirm button
  Widget _buildOtpContent(
    DepositState state, 
    ThemeColors colors, 
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dial instruction
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            children: [
              Icon(
                Icons.dialpad,
                size: 48,
                color: colors.gold,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.deposit_dialUSSD,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: AppText(
                  '#144*82#',
                  variant: AppTextVariant.headlineSmall,
                  color: colors.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // OTP Input
        AppText(
          l10n.deposit_enterOTP,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 8,
          style: AppTypography.headlineSmall.copyWith(
            color: colors.textPrimary,
            letterSpacing: 8,
            fontWeight: FontWeight.bold,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: AppTypography.headlineSmall.copyWith(
              color: colors.textTertiary,
            ),
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colors.gold),
            ),
          ),
          onChanged: (value) {
            ref.read(depositProvider.notifier).setOtp(value);
          },
        ),
      ],
    );
  }

  /// PUSH flow: Shows "Approve the payment on your phone" + waiting spinner + auto-polls status
  Widget _buildPushContent(
    DepositState state,
    Map<String, dynamic> response, 
    ThemeColors colors, 
    AppLocalizations l10n,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppCard(
          variant: AppCardVariant.elevated,
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
        // ignore: avoid_dynamic_calls
        if (response['expiresAt'].isAfter(DateTime.now()))
          _CountdownTimer(
            expiresAt: response['expiresAt'],
            colors: colors,
            l10n: l10n,
          ),
      ],
    );
  }

  /// QR_LINK flow: Shows QR code + "Open in Wave" deep link button + auto-polls status
  Widget _buildQrLinkContent(
    DepositState state,
    Map<String, dynamic> response, 
    ThemeColors colors, 
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR Code
          // ignore: avoid_dynamic_calls
          if (response['qrCodeData']?.isNotEmpty == true) ...[
            AppCard(
              variant: AppCardVariant.elevated,
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
                    child: QrImageView(
                      data: response['qrCodeData']!,
                      version: QrVersions.auto,
                      size: 200.0,
                      foregroundColor: colors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Deep link button
          // ignore: avoid_dynamic_calls
          if (response['deepLinkUrl']?.isNotEmpty == true) ...[
            AppButton(
              label: l10n.deposit_openInWave,
              icon: Icons.open_in_new,
              onPressed: () => _openDeepLink(response['deepLinkUrl']!),
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
      ),
    );
  }

  /// Card flow: Placeholder for card payments
  Widget _buildCardContent(ThemeColors colors, AppLocalizations l10n) {
    return Center(
      child: AppCard(
        variant: AppCardVariant.flat,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.credit_card,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.deposit_cardPaymentComingSoon,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    DepositState state, 
    ThemeColors colors, 
    AppLocalizations l10n,
  ) {
    final canSubmit = (state.otpInput?.length ?? 0) >= 4;

    return AppButton(
      label: l10n.deposit_submitOTP,
      onPressed: state.isLoading || !canSubmit
          ? null
          : () => ref.read(depositProvider.notifier).confirmDeposit(),
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
    showDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(
              l10n.action_ok,
              variant: AppTextVariant.labelMedium,
              color: colors.gold,
            ),
          ),
        ],
      ),
    );
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
    // Stop polling and go back
    ref.read(depositProvider.notifier).goBack();
    context.pop();
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
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return AppText(
      widget.l10n.deposit_expiresIn(timeString),
      variant: AppTextVariant.bodyMedium,
      color: widget.colors.textSecondary,
    );
  }
}