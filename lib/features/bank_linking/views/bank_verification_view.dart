/// Bank Verification View
library;
import 'package:usdc_wallet/design/tokens/index.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/features/bank_linking/providers/bank_linking_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BankVerificationView extends ConsumerStatefulWidget {
  const BankVerificationView({super.key, this.accountId});

  final String? accountId;

  @override
  ConsumerState<BankVerificationView> createState() =>
      _BankVerificationViewState();
}

class _BankVerificationViewState extends ConsumerState<BankVerificationView> {
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _canResend = false;
  int _resendCountdown = 60;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startResendCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _canResend = false;
      _resendCountdown = 60;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown > 1) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
        setState(() {
          _resendCountdown = 0;
          _canResend = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // ignore: unused_local_variable
    final __state = ref.watch(bankLinkingProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.bankLinking_verifyAccount,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.md),
                children: [
                  // Header
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.colors.gold.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 40,
                        color: context.colors.gold,
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppText(
                    l10n.bankLinking_verificationTitle,
                    style: AppTypography.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  AppText(
                    l10n.bankLinking_verificationDesc,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xl),
                  // OTP Input
                  AppInput(
                    label: l10n.bankLinking_otpCode,
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    hint: '123456',
                    onChanged: (value) {
                      if (value.length == 6) {
                        _handleVerify();
                      }
                    },
                  ),
                  SizedBox(height: AppSpacing.md),
                  // Resend button
                  Center(
                    child: TextButton(
                      onPressed: _canResend ? _handleResendOtp : null,
                      child: AppText(
                        _canResend
                            ? l10n.bankLinking_resendOtp
                            : l10n.bankLinking_resendOtpIn(_resendCountdown),
                        style: AppTypography.bodyMedium.copyWith(
                          color: _canResend
                              ? context.colors.gold
                              : context.colors.textTertiary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),
                  // Info box
                  _buildInfoBox(l10n),
                ],
              ),
            ),
            _buildBottomButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: context.colors.textSecondary,
            size: 20,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              l10n.bankLinking_devOtpHint,
              style: AppTypography.bodySmall.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border(
          top: BorderSide(
            color: context.colors.elevated,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: l10n.bankLinking_verify,
          onPressed: _handleVerify,
          isLoading: _isLoading,
        ),
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: AppText(
            AppLocalizations.of(context)!.bankLinking_invalidOtp,
            style: AppTypography.bodyMedium,
          ),
          backgroundColor: context.colors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await ref.read(bankLinkingProvider.notifier).verifyWithOtp(otp);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              AppLocalizations.of(context)!.bankLinking_verificationSuccess,
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: context.colors.success,
          ),
        );
        // Navigate back to linked accounts
        context.go('/bank-linking');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(
              AppLocalizations.of(context)!.bankLinking_verificationFailed,
              style: AppTypography.bodyMedium,
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    // In real app, call API to resend OTP
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: AppText(
          AppLocalizations.of(context)!.bankLinking_otpResent,
          style: AppTypography.bodyMedium,
        ),
        backgroundColor: context.colors.success,
      ),
    );
    _startResendCountdown();
  }
}
