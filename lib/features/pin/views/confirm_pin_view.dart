import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';

/// Confirm PIN View
/// Used to confirm PIN entry during setup
class ConfirmPinView extends ConsumerStatefulWidget {
  final String originalPin;

  const ConfirmPinView({
    super.key,
    required this.originalPin,
  });

  @override
  ConsumerState<ConfirmPinView> createState() => _ConfirmPinViewState();
}

class _ConfirmPinViewState extends ConsumerState<ConfirmPinView> {
  String _pin = '';
  bool _showError = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: Text(
          l10n.pin_confirmTitle,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.pin_reenterPin,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              PinDots(length: 6,
                filled: _pin.length,
                error: _showError,
              ),
              if (_showError) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  l10n.pin_error_noMatch,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              if (_isLoading)
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                )
              else
                PinPad(
                  onDigitPressed: _handleNumberPressed,
                  onDeletePressed: _handleBackspace,
                ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNumberPressed(int digit) {
    if (_pin.length < 6) {
      setState(() {
        _pin += digit.toString();
        _showError = false;
      });

      if (_pin.length == 6) {
        _validateAndSubmit();
      }
    }
  }

  void _handleBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
      });
    }
  }

  Future<void> _validateAndSubmit() async {
    final l10n = AppLocalizations.of(context)!;

    if (_pin != widget.originalPin) {
      setState(() {
        _showError = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _pin = '';
            _showError = false;
          });
        }
      });
      return;
    }

    // PINs match, save to backend
    setState(() => _isLoading = true);

    final success = await ref.read(pinStateProvider.notifier).setPin(_pin);

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        // Show success and navigate to biometric enrollment
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pin_success_set),
            backgroundColor: context.colors.success,
          ),
        );
        // Prompt biometric enrollment before going home
        context.go('/settings/biometric/enrollment');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pin_error_saveFailed),
            backgroundColor: context.colors.error,
          ),
        );
        context.pop();
      }
    }
  }
}
