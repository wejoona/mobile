import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/widgets/pin_input_widget.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class PinVerificationScreen extends ConsumerStatefulWidget {
  const PinVerificationScreen({super.key});

  @override
  ConsumerState<PinVerificationScreen> createState() =>
      _PinVerificationScreenState();
}

class _PinVerificationScreenState
    extends ConsumerState<PinVerificationScreen> {
  bool _isLoading = false;
  String? _error;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.canCheckBiometrics();
    if (mounted) {
      setState(() => _biometricAvailable = available);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.send_verifyPin,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: AppSpacing.xl),

              // Icon
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: context.colors.gold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: context.colors.gold,
                ),
              ),
              SizedBox(height: AppSpacing.lg),

              // Title
              AppText(
                l10n.send_enterPinToConfirm,
                variant: AppTextVariant.headlineSmall,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                l10n.send_pinVerificationDescription,
                variant: AppTextVariant.bodyMedium,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),

              // PIN input
              PinInputWidget(
                length: 6,
                onChanged: (pin) {
                  setState(() {
                    _error = null;
                  });
                },
                onCompleted: _handlePinComplete,
                error: _error,
              ),
              SizedBox(height: AppSpacing.lg),

              // Error message
              if (_error != null)
                AppText(
                  _error!,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.error,
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Biometric option
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _handleBiometric,
                  icon: Icon(
                    Icons.fingerprint,
                    color: context.colors.gold,
                  ),
                  label: AppText(
                    l10n.send_useBiometric,
                    variant: AppTextVariant.bodyMedium,
                    color: context.colors.gold,
                  ),
                ),

              SizedBox(height: AppSpacing.md),

              // Loading indicator
              if (_isLoading)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handlePinComplete(String pin) async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Verify PIN
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinLocally(pin);

      if (!result.success) {
        setState(() {
          _error = result.message ?? l10n.error_pinIncorrect;
          _isLoading = false;
        });
        return;
      }

      // Execute transfer
      final success = await ref.read(sendMoneyProvider.notifier).executeTransfer();

      if (mounted) {
        if (success) {
          context.go('/send/result');
        } else {
          final state = ref.read(sendMoneyProvider);
          setState(() {
            _error = state.error ?? l10n.error_transferFailed;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleBiometric() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final biometricService = ref.read(biometricServiceProvider);
      final authenticatedBio = await biometricService.authenticate(
        localizedReason: l10n.send_biometricReason,
      );

      if (!authenticatedBio.success) {
        setState(() {
          _error = l10n.error_biometricFailed;
          _isLoading = false;
        });
        return;
      }

      // Execute transfer
      final success = await ref.read(sendMoneyProvider.notifier).executeTransfer();

      if (mounted) {
        if (success) {
          context.go('/send/result');
        } else {
          final state = ref.read(sendMoneyProvider);
          setState(() {
            _error = state.error ?? l10n.error_transferFailed;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }
}
