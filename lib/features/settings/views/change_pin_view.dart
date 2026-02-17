import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/composed/index.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_instruction_screen.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

enum ChangePinPhase { livenessExplanation, livenessCheck, pinEntry }
enum PinStep { current, newPin, confirm }

class ChangePinView extends ConsumerStatefulWidget {
  const ChangePinView({super.key});

  @override
  ConsumerState<ChangePinView> createState() => _ChangePinViewState();
}

class _ChangePinViewState extends ConsumerState<ChangePinView> {
  ChangePinPhase _phase = ChangePinPhase.livenessExplanation;
  PinStep _currentStep = PinStep.current;
  String _currentPin = '';
  String _newPin = '';
  String _confirmPin = '';
  String? _error;
  bool _isLoading = false;

  static const int _pinLength = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_phase) {
      case ChangePinPhase.livenessExplanation:
        return KycInstructionScreen(
          title: 'Vérification d\'identité',
          description: 'Pour changer votre PIN, nous devons d\'abord vérifier votre identité par reconnaissance faciale.',
          icon: Icons.face,
          instructions: const [
            KycInstruction(
              icon: Icons.videocam_outlined,
              title: 'Vérification vidéo',
              subtitle: 'Nous vous demanderons d\'effectuer des actions simples',
            ),
            KycInstruction(
              icon: Icons.security,
              title: 'Sécurité renforcée',
              subtitle: 'Cela protège votre compte contre les changements non autorisés',
            ),
            KycInstruction(
              icon: Icons.timer_outlined,
              title: 'Environ 30 secondes',
              subtitle: 'Restez dans le cadre pendant toute la durée',
            ),
          ],
          buttonLabel: l10n.common_continue,
          onContinue: () => setState(() => _phase = ChangePinPhase.livenessCheck),
          onBack: () => context.safePop(fallbackRoute: '/settings/security'),
        );

      case ChangePinPhase.livenessCheck:
        return LivenessCheckWidget(
          onComplete: _onLivenessComplete,
          onCancel: () => setState(() => _phase = ChangePinPhase.livenessExplanation),
        );

      case ChangePinPhase.pinEntry:
        return _buildPinEntryScreen(l10n);
    }
  }

  void _onLivenessComplete(LivenessResult result) {
    if (result.isLive && result.decision != LivenessDecision.decline) {
      setState(() => _phase = ChangePinPhase.pinEntry);
    } else {
      // Liveness failed — go back to explanation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settings_verificationFailed),
          backgroundColor: context.colors.error,
        ),
      );
      setState(() => _phase = ChangePinPhase.livenessExplanation);
    }
  }

  Widget _buildPinEntryScreen(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          _getTitle(l10n),
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.gold),
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
                decoration: BoxDecoration(
                  color: context.colors.container,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _currentStep == PinStep.current ? Icons.lock : Icons.lock_open,
                  color: context.colors.gold,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Title
              AppText(
                _getStepTitle(l10n),
                variant: AppTextVariant.titleMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                _getStepSubtitle(l10n),
                variant: AppTextVariant.bodyMedium,
                color: context.colors.textSecondary,
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
                    color: context.colors.error,
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
      children: List.generate(_pinLength, (index) {
        final isFilled = index < pin.length;
        final hasError = _error != null;

        return Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: isFilled
                ? (hasError ? context.colors.error : context.colors.gold)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: hasError
                  ? context.colors.error
                  : (isFilled ? context.colors.gold : context.colors.textSecondary),
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
          if (_currentPin.length < _pinLength) {
            _currentPin += number;
            if (_currentPin.length == _pinLength) {
              _validateCurrentPin();
            }
          }
          break;
        case PinStep.newPin:
          if (_newPin.length < _pinLength) {
            _newPin += number;
            if (_newPin.length == _pinLength) {
              _validateNewPin();
            }
          }
          break;
        case PinStep.confirm:
          if (_confirmPin.length < _pinLength) {
            _confirmPin += number;
            if (_confirmPin.length == _pinLength) {
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
    // Check for sequential digits (ascending)
    bool ascending = true;
    bool descending = true;
    for (int i = 1; i < pin.length; i++) {
      final curr = int.parse(pin[i]);
      final prev = int.parse(pin[i - 1]);
      if (curr != prev + 1) ascending = false;
      if (curr != prev - 1) descending = false;
    }
    if (ascending || descending) return true;

    // Check for repeated digits
    if (pin.split('').toSet().length == 1) return true;

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
              backgroundColor: context.colors.success,
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
