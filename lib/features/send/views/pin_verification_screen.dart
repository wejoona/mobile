import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/pin/pin_service.dart';
import '../../../services/biometric/biometric_service.dart';
import '../providers/send_provider.dart';
import '../widgets/pin_input_widget.dart';

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
      backgroundColor: AppColors.obsidian,
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
                  color: AppColors.gold500.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.gold500,
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
                  color: AppColors.textSecondary,
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
                    color: AppColors.errorBase,
                  textAlign: TextAlign.center,
                ),

              const Spacer(),

              // Biometric option
              if (_biometricAvailable)
                TextButton.icon(
                  onPressed: _handleBiometric,
                  icon: Icon(
                    Icons.fingerprint,
                    color: AppColors.gold500,
                  ),
                  label: AppText(
                    l10n.send_useBiometric,
                    variant: AppTextVariant.bodyMedium,
                      color: AppColors.gold500,
                  ),
                ),

              SizedBox(height: AppSpacing.md),

              // Loading indicator
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
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
      final authenticated = await biometricService.authenticate(
        reason: l10n.send_biometricReason,
      );

      if (!authenticated) {
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
