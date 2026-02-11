import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_dots.dart';
import 'package:usdc_wallet/features/pin/widgets/pin_pad.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';

/// Change PIN View
/// Multi-step flow to change existing PIN
class ChangePinView extends ConsumerStatefulWidget {
  const ChangePinView({super.key});

  @override
  ConsumerState<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends ConsumerState<ChangePinView> {
  int _step = 1; // 1: current, 2: new, 3: confirm
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;

  String get _activePin {
    switch (_step) {
      case 1:
        return _currentPin;
      case 2:
        return _newPin;
      case 3:
        return _confirmPin;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          l10n.pin_changeTitle,
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
              _buildProgressIndicator(),
              SizedBox(height: AppSpacing.xxl),
              Text(
                _getStepTitle(l10n),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xxxl),
              PinDots(
                filledCount: _activePin.length,
                showError: _showError,
              ),
              if (_errorMessage != null) ...[
                SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.errorText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const Spacer(),
              if (_isLoading)
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
                )
              else
                PinPad(
                  onNumberPressed: _handleNumberPressed,
                  onBackspace: _handleBackspace,
                ),
              SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index + 1 == _step;
        final isCompleted = index + 1 < _step;

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Container(
            width: isActive ? 32 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isCompleted || isActive
                  ? AppColors.gold500
                  : AppColors.borderDefault,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
        );
      }),
    );
  }

  String _getStepTitle(AppLocalizations l10n) {
    switch (_step) {
      case 1:
        return l10n.pin_enterCurrentPin;
      case 2:
        return l10n.pin_enterNewPin;
      case 3:
        return l10n.pin_confirmNewPin;
      default:
        return '';
    }
  }

  void _handleNumberPressed(String number) {
    if (_activePin.length < 6) {
      setState(() {
        switch (_step) {
          case 1:
            _currentPin += number;
            break;
          case 2:
            _newPin += number;
            break;
          case 3:
            _confirmPin += number;
            break;
        }
        _showError = false;
        _errorMessage = null;
      });

      if (_activePin.length == 6) {
        _processStep();
      }
    }
  }

  void _handleBackspace() {
    if (_activePin.isNotEmpty) {
      setState(() {
        switch (_step) {
          case 1:
            _currentPin = _currentPin.substring(0, _currentPin.length - 1);
            break;
          case 2:
            _newPin = _newPin.substring(0, _newPin.length - 1);
            break;
          case 3:
            _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
            break;
        }
        _showError = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _processStep() async {
    final l10n = AppLocalizations.of(context)!;

    switch (_step) {
      case 1:
        // Verify current PIN
        final success = await ref.read(pinStateProvider.notifier).verifyPin(_currentPin);
        if (success) {
          setState(() => _step = 2);
        } else {
          setState(() {
            _showError = true;
            _errorMessage = l10n.pin_error_wrongCurrent;
          });
          _resetCurrentStep();
        }
        break;

      case 2:
        // Validate new PIN
        if (_isSequential(_newPin)) {
          setState(() {
            _showError = true;
            _errorMessage = l10n.pin_error_sequential;
          });
          _resetCurrentStep();
          return;
        }
        if (_isRepeated(_newPin)) {
          setState(() {
            _showError = true;
            _errorMessage = l10n.pin_error_repeated;
          });
          _resetCurrentStep();
          return;
        }
        setState(() => _step = 3);
        break;

      case 3:
        // Confirm new PIN
        if (_confirmPin != _newPin) {
          setState(() {
            _showError = true;
            _errorMessage = l10n.pin_error_noMatch;
          });
          _resetCurrentStep();
          return;
        }

        // Save new PIN
        setState(() => _isLoading = true);
        final success = await ref.read(pinStateProvider.notifier).changePin(_currentPin, _newPin);
        setState(() => _isLoading = false);

        if (mounted) {
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.pin_success_changed),
                backgroundColor: AppColors.successBase,
              ),
            );
            context.pop();
          } else {
            setState(() {
              _showError = true;
              _errorMessage = l10n.pin_error_changeFailed;
            });
            _resetCurrentStep();
          }
        }
        break;
    }
  }

  void _resetCurrentStep() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          switch (_step) {
            case 1:
              _currentPin = '';
              break;
            case 2:
              _newPin = '';
              break;
            case 3:
              _confirmPin = '';
              break;
          }
          _showError = false;
          _errorMessage = null;
        });
      }
    });
  }

  bool _isSequential(String pin) {
    if (pin.length < 6) return false;
    final digits = pin.split('').map(int.parse).toList();

    bool ascending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] + 1) {
        ascending = false;
        break;
      }
    }
    if (ascending) return true;

    bool descending = true;
    for (int i = 1; i < digits.length; i++) {
      if (digits[i] != digits[i - 1] - 1) {
        descending = false;
        break;
      }
    }
    return descending;
  }

  bool _isRepeated(String pin) {
    if (pin.length < 6) return false;
    return pin.split('').toSet().length == 1;
  }
}
