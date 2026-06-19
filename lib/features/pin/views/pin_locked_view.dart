import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/pin/models/pin_reset_route_context.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// PIN Locked View — consistent with lock/OTP screen design.
class PinLockedView extends ConsumerStatefulWidget {
  const PinLockedView({super.key});

  @override
  ConsumerState<PinLockedView> createState() => _PinLockedViewState();
}

class _PinLockedViewState extends ConsumerState<PinLockedView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinState = ref.watch(pinStateProvider);
    final colors = context.colors;

    if (!pinState.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.fsmPop();
      });
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.container,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.border),
                ),
                child: Icon(Icons.lock_clock, color: colors.error, size: 40),
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.pin_locked_title,
                variant: AppTextVariant.headlineMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                l10n.pin_locked_message,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    AppText(
                      l10n.pin_locked_tryAgainIn,
                      variant: AppTextVariant.labelMedium,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      _formatDuration(pinState.lockoutSeconds),
                      variant: AppTextVariant.displaySmall,
                      color: colors.gold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.pin_resetViaOtp,
                onPressed: _openPinReset,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _openPinReset() {
    final authState = ref.read(authProvider);
    final phone = PhoneNumberValue.tryFromAny(
      phoneNumber: authState.user?.phone ?? authState.phone,
      countryCode: authState.user?.countryCode ?? authState.countryCode,
    );

    context.fsmOpenPinReset(
      extra: PinResetRouteContext.fromOptionalPhoneValue(phone: phone),
    );
  }
}
