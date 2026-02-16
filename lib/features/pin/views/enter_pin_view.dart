import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';

/// Enter PIN View — reusable PIN verification screen.
/// Uses design system PinDots + PinPad for consistency with OTP/lock screens.
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
  bool _hasError = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinState = ref.watch(pinStateProvider);
    final colors = context.colors;

    if (pinState.isLocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/pin/locked');
      });
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          widget.title,
          variant: AppTextVariant.headlineSmall,
          color: colors.textPrimary,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const Spacer(flex: 1),

                        // Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: colors.container,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.border),
                          ),
                          child: Icon(
                            Icons.dialpad,
                            color: colors.gold,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        if (widget.subtitle != null) ...[
                          AppText(
                            widget.subtitle!,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xxxl),
                        ],

                        // PIN Dots
                        PinDots(
                          length: 6,
                          filled: _pin.length,
                          error: _hasError,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        if (pinState.remainingAttempts < PinService.maxAttempts)
                          AppText(
                            l10n.pin_attemptsRemaining(pinState.remainingAttempts),
                            variant: AppTextVariant.bodyMedium,
                            color: colors.warningText,
                          ),

                        const Spacer(flex: 1),

                        // PIN Pad
                        PinPad(
                          onDigitPressed: _handleDigitPressed,
                          onDeletePressed: _handleDeletePressed,
                          showBiometric: widget.showBiometric,
                          onBiometricPressed: widget.showBiometric ? _handleBiometric : null,
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        TextButton(
                          onPressed: () => context.push('/pin/reset'),
                          child: AppText(
                            l10n.pin_forgotPin,
                            variant: AppTextVariant.bodyMedium,
                            color: colors.gold,
                          ),
                        ),

                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleDigitPressed(int digit) {
    if (_pin.length >= 6) return;

    setState(() {
      _pin += digit.toString();
      _hasError = false;
    });

    if (_pin.length == 6) {
      _verifyPin();
    }
  }

  void _handleDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
      });
    }
  }

  Future<void> _handleBiometric() async {
    final biometricService = ref.read(biometricServiceProvider);
    final result = await biometricService.authenticate(
      localizedReason: 'Authenticate to continue',
    );
    if (result.success && mounted) {
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
        setState(() => _hasError = true);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _pin = '';
              _hasError = false;
            });
          }
        });
      }
    }
  }
}
