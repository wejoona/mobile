import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/components/composed/index.dart';
import '../../../services/pin/pin_service.dart';
import '../../../services/biometric/biometric_service.dart';

enum PinStep { current, newPin, confirm }

class ChangePinView extends ConsumerStatefulWidget {
  const ChangePinView({super.key});

  @override
  ConsumerState<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends ConsumerState<ChangePinView> {
  PinStep _currentStep = PinStep.current;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _error;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          _getTitle(l10n),
          variant: AppTextVariant.titleLarge,
          color: AppColors.textPrimary,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gold500),
          onPressed: () {
            if (_currentStep == PinStep.current) {
              context.safePop(fallbackRoute: '/settings/security');
            } else {
              _goBack();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              const Spacer(),

              // Lock Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: AppColors.slate,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentStep == PinStep.current ? Icons.lock : Icons.lock_open,
                  color: AppColors.gold500,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              AppText(
                _getStepTitle(l10n),
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                _getStepSubtitle(l10n),
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // PIN Dots
              _buildPinDots(),

              // Error
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: AppText(
                    _error!,
                    variant: AppTextVariant.bodyMedium,
                    color: AppColors.errorBase,
                    textAlign: TextAlign.center,
                  ),
                ),

              const Spacer(),

              // PIN Pad
              PinPad(
                onDigitPressed: _onDigitPressed,
                onDeletePressed: _onDeletePressed,
                showBiometric: false,
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case PinStep.current:
        return l10n.changePin_title;
      case PinStep.newPin:
        return l10n.changePin_newPinTitle;
      case PinStep.confirm:
        return l10n.changePin_confirmTitle;
    }
  }

  String _getStepTitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case PinStep.current:
        return l10n.changePin_enterCurrentPinTitle;
      case PinStep.newPin:
        return l10n.changePin_createNewPinTitle;
      case PinStep.confirm:
        return l10n.changePin_confirmPinTitle;
    }
  }

  String _getStepSubtitle(AppLocalizations l10n) {
    switch (_currentStep) {
      case PinStep.current:
        return l10n.changePin_enterCurrentPinSubtitle;
      case PinStep.newPin:
        return l10n.changePin_createNewPinSubtitle;
      case PinStep.confirm:
        return l10n.changePin_confirmPinSubtitle;
    }
  }

  String get _currentEnteredPin {
    switch (_currentStep) {
      case PinStep.current:
        return _currentPin;
      case PinStep.newPin:
        return _newPin;
      case PinStep.confirm:
        return _confirmPin;
    }
  }

  Widget _buildPinDots() {
    final pin = _currentEnteredPin;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        final isFilled = index < pin.length;
        final hasError = _error != null;

        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isFilled
                ? (hasError ? AppColors.errorBase : AppColors.gold500)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasError
                  ? AppColors.errorBase
                  : (isFilled ? AppColors.gold500 : AppColors.textSecondary),
              width: 2,
            ),
          ),
        );
      }),
    );
  }

  void _onDigitPressed(int digit) {
    if (_isLoading) return;

    setState(() {
      _error = null;
      final number = digit.toString();

      switch (_currentStep) {
        case PinStep.current:
          if (_currentPin.length < 4) {
            _currentPin += number;
            if (_currentPin.length == 4) {
              _validateCurrentPin();
            }
          }
          break;
        case PinStep.newPin:
          if (_newPin.length < 4) {
            _newPin += number;
            if (_newPin.length == 4) {
              _validateNewPin();
            }
          }
          break;
        case PinStep.confirm:
          if (_confirmPin.length < 4) {
            _confirmPin += number;
            if (_confirmPin.length == 4) {
              _validateConfirmPin();
            }
          }
          break;
      }
    });
  }

  void _onDeletePressed() {
    if (_isLoading) return;

    setState(() {
      _error = null;

      switch (_currentStep) {
        case PinStep.current:
          if (_currentPin.isNotEmpty) {
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
          }
          break;
        case PinStep.newPin:
          if (_newPin.isNotEmpty) {
            _newPin = _newPin.substring(0, _newPin.length - 1);
          }
          break;
        case PinStep.confirm:
          if (_confirmPin.isNotEmpty) {
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
          }
          break;
      }
    });
  }

  Future<void> _validateCurrentPin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      // First require biometric confirmation if enabled
      final biometricGuard = ref.read(biometricGuardProvider);
      final biometricConfirmed = await biometricGuard.guardPinChange();

      if (!biometricConfirmed) {
        setState(() {
          _error = l10n.changePin_errorBiometricRequired;
          _currentPin = '';
          _isLoading = false;
        });
        return;
      }

      // Then verify current PIN
      final pinService = ref.read(pinServiceProvider);
      final result = await pinService.verifyPinLocally(_currentPin);

      if (result.success) {
        setState(() {
          _currentStep = PinStep.newPin;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = result.message ?? l10n.changePin_errorIncorrectPin;
          _currentPin = '';
          _isLoading = false;
        });
      }
    } on BiometricRequiredException catch (e) {
      setState(() {
        _error = e.message;
        _currentPin = '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = l10n.changePin_errorUnableToVerify;
        _currentPin = '';
        _isLoading = false;
      });
    }
  }

  void _validateNewPin() {
    final l10n = AppLocalizations.of(context)!;
    // Check for weak PINs
    if (_isWeakPin(_newPin)) {
      setState(() {
        _error = l10n.changePin_errorWeakPin;
        _newPin = '';
      });
      return;
    }

    // Check not same as current
    if (_newPin == _currentPin) {
      setState(() {
        _error = l10n.changePin_errorSameAsCurrentPin;
        _newPin = '';
      });
      return;
    }

    setState(() {
      _currentStep = PinStep.confirm;
    });
  }

  void _validateConfirmPin() {
    final l10n = AppLocalizations.of(context)!;
    if (_confirmPin == _newPin) {
      _saveNewPin();
    } else {
      setState(() {
        _error = l10n.changePin_errorPinMismatch;
        _confirmPin = '';
      });
    }
  }

  bool _isWeakPin(String pin) {
    // Check for sequential digits
    const sequential = ['0123', '1234', '2345', '3456', '4567', '5678', '6789'];
    const reverseSequential = ['9876', '8765', '7654', '6543', '5432', '4321', '3210'];

    if (sequential.contains(pin) || reverseSequential.contains(pin)) {
      return true;
    }

    // Check for repeated digits
    if (pin.split('').toSet().length == 1) {
      return true;
    }

    return false;
  }

  Future<void> _saveNewPin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    try {
      final pinService = ref.read(pinServiceProvider);
      final success = await pinService.setPin(_newPin);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.changePin_successMessage),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.safePop(fallbackRoute: '/settings/security');
        } else {
          setState(() {
            _error = l10n.changePin_errorFailedToSet;
            _confirmPin = '';
            _newPin = '';
            _currentStep = PinStep.newPin;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = l10n.changePin_errorFailedToSave;
      });
    }
  }

  void _goBack() {
    setState(() {
      _error = null;
      switch (_currentStep) {
        case PinStep.current:
          break;
        case PinStep.newPin:
          _currentStep = PinStep.current;
          _newPin = '';
          break;
        case PinStep.confirm:
          _currentStep = PinStep.newPin;
          _confirmPin = '';
          break;
      }
    });
  }
}
