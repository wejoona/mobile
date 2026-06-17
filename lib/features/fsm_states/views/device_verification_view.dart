import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// Device Verification View
/// Shown when a new or changed device is detected
class DeviceVerificationView extends ConsumerStatefulWidget {
  const DeviceVerificationView({super.key});

  @override
  ConsumerState<DeviceVerificationView> createState() =>
      _DeviceVerificationViewState();
}

class _DeviceVerificationViewState
    extends ConsumerState<DeviceVerificationView> {
  bool _isVerifying = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sessionState = ref.watch(appFsmProvider).session;

    String? deviceId;
    if (sessionState is SessionDeviceChanged) {
      deviceId = sessionState.deviceId;
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
                Icons.phone_android,
                size: 80,
                color: context.colors.warning,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.device_newDeviceDetected,
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.device_verificationRequired,
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (deviceId != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: context.colors.gold),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              l10n.device_deviceId,
                              variant: AppTextVariant.labelSmall,
                              color: context.colors.textSecondary,
                            ),
                            AppText(
                              deviceId.substring(
                                0,
                                deviceId.length > 20 ? 20 : deviceId.length,
                              ),
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.textPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              AppCard(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    AppText(
                      l10n.device_verificationOptions,
                      variant: AppTextVariant.bodyMedium,
                      color: context.colors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.device_verificationOptionsDesc,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.device_verifyWithOtp,
                onPressed: _isVerifying ? null : _verifyWithOtp,
                isLoading: _isVerifying,
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.device_verifyWithEmail,
                onPressed: _isVerifying ? null : _verifyWithEmail,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
              ),
              SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.common_logout,
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
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

  Future<void> _verifyWithOtp() async {
    setState(() => _isVerifying = true);
    try {
      final phone = await _currentPhone();
      if (phone == null) {
        _showSnackBar('Phone number unavailable. Please log in again.');
        return;
      }

      await ref.read(authProvider.notifier).login(phone);
      if (!mounted) {
        return;
      }

      final loginState = ref.read(authProvider);
      if (loginState.status == AuthStatus.error) {
        _showSnackBar(loginState.error ?? _deviceVerificationFailedMessage());
        return;
      }

      final otp = await _showOtpDialog();
      if (otp == null || !mounted) {
        return;
      }

      final verified = await ref.read(authProvider.notifier).verifyOtp(otp);
      if (!mounted) {
        return;
      }

      if (!verified) {
        _showSnackBar(
          ref.read(authProvider).error ?? _deviceVerificationFailedMessage(),
        );
        return;
      }

      ref
          .read(appFsmProvider.notifier)
          .dispatch(const AppSessionEvent(SessionDeviceVerified()));
    } on Object catch (_) {
      if (mounted) {
        _showSnackBar(_deviceVerificationFailedMessage());
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  Future<String?> _showOtpDialog() async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.elevated,
        title: AppText(
          l10n.device_verifyWithOtp,
          variant: AppTextVariant.headlineSmall,
          color: context.colors.textPrimary,
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '000000',
            labelText: 'OTP Code',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              l10n.common_cancel,
              color: context.colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: AppText(l10n.action_confirm, color: context.colors.gold),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyWithEmail() async {
    _showSnackBar(
      'Email device verification is not available yet. Use SMS code.',
    );
  }

  Future<String?> _currentPhone() async {
    final authState = ref.read(authProvider);
    final authPhone = authState.user?.phone ?? authState.phone;
    if (_hasValue(authPhone)) {
      return authPhone!.trim();
    }

    final userPhone = ref.read(userStateMachineProvider).phone;
    if (_hasValue(userPhone)) {
      return userPhone!.trim();
    }

    final storedPhone = await ref
        .read(secureStorageProvider)
        .read(key: StorageKeys.userPhone);
    if (_hasValue(storedPhone)) {
      return storedPhone!.trim();
    }

    return null;
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  String _deviceVerificationFailedMessage() =>
      AppLocalizations.of(context)!.deviceVerification_failed;

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: context.colors.error),
    );
  }
}
