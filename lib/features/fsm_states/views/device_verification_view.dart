import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Device Verification View
/// Shown when a new or changed device is detected
class DeviceVerificationView extends ConsumerStatefulWidget {
  const DeviceVerificationView({super.key});

  @override
  ConsumerState<DeviceVerificationView> createState() => _DeviceVerificationViewState();
}

class _DeviceVerificationViewState extends ConsumerState<DeviceVerificationView> {
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
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_android,
                size: 80,
                color: AppColors.warning,
              ),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.device_newDeviceDetected,
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.device_verificationRequired,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (deviceId != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.borderDefault),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.gold500),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              l10n.device_deviceId,
                              variant: AppTextVariant.labelSmall,
                              color: AppColors.textSecondary,
                            ),
                            AppText(
                              deviceId.substring(0, deviceId.length > 20 ? 20 : deviceId.length),
                              variant: AppTextVariant.bodySmall,
                              color: AppColors.textPrimary,
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
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.device_verificationOptionsDesc,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
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

  Future<void> _verifyWithOtp() async {
    setState(() => _isVerifying = true);
    try {
      final dio = ref.read(dioProvider);
      // Request OTP via the login endpoint (sends OTP to user's phone)
      await dio.post('/auth/login', data: {
        'phone': ref.read(appFsmProvider).session is SessionDeviceChanged
            ? null // Phone will be resolved from auth token
            : null,
      });

      if (!mounted) return;

      // Show OTP input dialog
      final otp = await _showOtpDialog();
      if (otp == null || !mounted) return;

      // Verify OTP with backend
      final response = await dio.post('/auth/verify-otp', data: {
        'otp': otp,
      });

      if (response.statusCode == 200 && mounted) {
        // Register device as trusted
        await dio.post('/devices/register', data: {
          'deviceIdentifier': (ref.read(appFsmProvider).session as SessionDeviceChanged).deviceId,
          'platform': 'mobile',
        });

        if (mounted) {
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionDeviceVerified()),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: AppColors.errorBase,
          ),
        );
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
        backgroundColor: AppColors.elevated,
        title: AppText(
          l10n.device_verifyWithOtp,
          variant: AppTextVariant.headlineSmall,
          color: AppColors.textPrimary,
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
            child: AppText(l10n.common_cancel, color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: AppText(l10n.action_confirm, color: AppColors.gold500),
          ),
        ],
      ),
    );
  }

  Future<void> _verifyWithEmail() async {
    setState(() => _isVerifying = true);
    try {
      final dio = ref.read(dioProvider);
      // Request email verification from backend
      await dio.post('/auth/login', data: {
        // Backend sends OTP to registered email
      });

      if (!mounted) return;

      final otp = await _showOtpDialog();
      if (otp == null || !mounted) return;

      final response = await dio.post('/auth/verify-otp', data: {
        'otp': otp,
      });

      if (response.statusCode == 200 && mounted) {
        await dio.post('/devices/register', data: {
          'deviceIdentifier': (ref.read(appFsmProvider).session as SessionDeviceChanged).deviceId,
          'platform': 'mobile',
        });

        if (mounted) {
          ref.read(appFsmProvider.notifier).dispatch(
                const AppSessionEvent(SessionDeviceVerified()),
              );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }
}
