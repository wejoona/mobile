import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          _getTitle(),
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () {
            if (_currentStep == PinStep.current) {
              context.pop();
            } else {
              _goBack();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const Spacer(),

              // Lock Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.container,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentStep == PinStep.current ? Icons.lock : Icons.lock_open,
                  color: colors.gold,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              AppText(
                _getStepTitle(),
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                _getStepSubtitle(),
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // PIN Dots
              _buildPinDots(colors),

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

  String _getTitle() {
    switch (_currentStep) {
      case PinStep.current:
        return 'Change PIN';
      case PinStep.newPin:
        return 'New PIN';
      case PinStep.confirm:
        return 'Confirm PIN';
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case PinStep.current:
        return 'Enter Current PIN';
      case PinStep.newPin:
        return 'Create New PIN';
      case PinStep.confirm:
        return 'Confirm Your PIN';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case PinStep.current:
        return 'Enter your current 4-digit PIN to continue';
      case PinStep.newPin:
        return 'Choose a new 4-digit PIN for your account';
      case PinStep.confirm:
        return 'Re-enter your new PIN to confirm';
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

  Widget _buildPinDots(ThemeColors colors) {
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
                ? (hasError ? AppColors.errorBase : colors.gold)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasError
                  ? AppColors.errorBase
                  : (isFilled ? colors.gold : colors.borderSubtle),
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
    setState(() => _isLoading = true);

    try {
      // First require biometric confirmation if enabled
      final biometricGuard = ref.read(biometricGuardProvider);
      final biometricConfirmed = await biometricGuard.guardPinChange();

      if (!biometricConfirmed) {
        setState(() {
          _error = 'Biometric confirmation required';
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
          _error = result.message ?? 'Incorrect PIN. Please try again.';
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
        _error = 'Unable to verify PIN. Please try again.';
        _currentPin = '';
        _isLoading = false;
      });
    }
  }

  void _validateNewPin() {
    // Check for weak PINs
    if (_isWeakPin(_newPin)) {
      setState(() {
        _error = 'PIN is too simple. Choose a stronger PIN.';
        _newPin = '';
      });
      return;
    }

    // Check not same as current
    if (_newPin == _currentPin) {
      setState(() {
        _error = 'New PIN must be different from current PIN.';
        _newPin = '';
      });
      return;
    }

    setState(() {
      _currentStep = PinStep.confirm;
    });
  }

  void _validateConfirmPin() {
    if (_confirmPin == _newPin) {
      _saveNewPin();
    } else {
      setState(() {
        _error = 'PINs do not match. Try again.';
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
    setState(() => _isLoading = true);

    try {
      final pinService = ref.read(pinServiceProvider);
      final success = await pinService.setPin(_newPin);

      setState(() => _isLoading = false);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PIN changed successfully!'),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        } else {
          setState(() {
            _error = 'Failed to set new PIN. Please try a different PIN.';
            _confirmPin = '';
            _newPin = '';
            _currentStep = PinStep.newPin;
          });
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to save PIN. Please try again.';
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
