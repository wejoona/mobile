import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// OTP Expired View
/// Shown when OTP code has expired
class OtpExpiredView extends ConsumerWidget {
  const OtpExpiredView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(appFsmProvider).auth;

    String? phone;
    if (authState is AuthOtpExpired) {
      phone = authState.phone;
    }

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_off_outlined,
                size: 80,
                color: context.colors.warning,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.auth_otpExpired,
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.auth_otpExpiredMessage,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (phone != null) ...[
                SizedBox(height: AppSpacing.sm),
                AppText(
                  phone,
                  variant: AppTextVariant.bodyMedium,
                  color: context.colors.gold,
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.auth_resendOtp,
                onPressed: () {
                  ref.read(appFsmProvider.notifier).dispatch(
                        AppAuthEvent(const AuthResendOtp()),
                      );
                },
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.common_cancel,
                onPressed: () {
                  ref.read(appFsmProvider.notifier).logout();
                },
                variant: AppButtonVariant.ghost,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
