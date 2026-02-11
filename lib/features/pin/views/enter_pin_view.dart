import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pin_pad.dart';
import '../providers/pin_provider.dart';
import '../../../services/biometric/biometric_service.dart';

/// Enter PIN View
/// Reusable PIN verification screen
class EnterPinView extends ConsumerStatefulWidget {
  final String title;
  final String? subtitle;
  final bool showBiometric;
  final Function(String pin)? onSuccess;

  const EnterPinView({
    super.key,
    required this.title,
    this.subtitle,
    this.showBiometric = false,
    this.onSuccess,
  });

  @override
  ConsumerState<EnterPinView> createState() => _EnterPinViewState();
}

class _EnterPinViewState extends ConsumerState<EnterPinView> {
  String _pin = '';
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinState = ref.watch(pinStateProvider);

    // Check if locked
    if (pinState.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/pin/locked');
      });
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          widget.title,
          variant: AppTextVariant.headlineSmall,
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
              if (widget.subtitle != null) ...[
                AppText(
                  widget.subtitle!,
                  variant: AppTextVariant.bodyLarge,
                  color: AppColors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppSpacing.xxxl),
              ],
              PinDots(
                filledCount: _pin.length,
                showError: _showError,
              ),
              SizedBox(height: AppSpacing.md),
              if (pinState.remainingAttempts < 5) ...[
                AppText(
                  l10n.pin_attemptsRemaining(pinState.remainingAttempts),
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.warningText,
                ),
              ],
              const Spacer(),
              AppButton(
                label: l10n.pin_forgotPin,
                onPressed: () => context.push('/pin/reset'),
                variant: AppButtonVariant.ghost,
              ),
              SizedBox(height: AppSpacing.md),
              PinPad(
                onNumberPressed: _handleNumberPressed,
                onBackspace: _handleBackspace,
                onBiometric: widget.showBiometric ? _handleBiometric : null,
              ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNumberPressed(String number) {
    if (_pin.length < 6) {
      setState(() {
        _pin += number;
        _showError = false;
      });

      if (_pin.length == 6) {
        _verifyPin();
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

  Future<void> _handleBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final success = await biometricService.authenticate(
      reason: 'Authenticate to continue',
    );
    if (success && mounted) {
      if (widget.onSuccess != null) {
        widget.onSuccess!('');
      } else {
        context.pop(true);
      }
    }
  }

  Future<void> _verifyPin() async {
    final success = await ref.read(pinStateProvider.notifier).verifyPin(_pin);

    if (mounted) {
      if (success) {
        if (widget.onSuccess != null) {
          widget.onSuccess!(_pin);
        } else {
          context.pop(true);
        }
      } else {
        setState(() {
          _showError = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _pin = '';
              _showError = false;
            });
          }
        });
      }
    }
  }
}
