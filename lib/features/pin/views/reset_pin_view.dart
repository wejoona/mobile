import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_input.dart';
import '../../../services/api/api_client.dart';
import '../../../services/pin/pin_service.dart';
import '../widgets/pin_dots.dart';
import '../widgets/pin_pad.dart';
import '../providers/pin_provider.dart';

/// Reset PIN View
/// Multi-step flow to reset PIN via OTP
class ResetPinView extends ConsumerStatefulWidget {
  const ResetPinView({super.key});

  @override
  ConsumerState<ResetPinView> createState() => _ResetPinViewState();
}

class _ResetPinViewState extends ConsumerState<ResetPinView> {
  int _step = 1; // 1: request OTP, 2: enter OTP, 3: new PIN, 4: confirm PIN
  final _otpController = TextEditingController();
  String _newPin = '';
  String _confirmPin = '';
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: Text(
          l10n.pin_resetTitle,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: _buildStepContent(l10n),
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_step) {
      case 1:
        return _buildRequestOtpStep(l10n);
      case 2:
        return _buildEnterOtpStep(l10n);
      case 3:
        return _buildNewPinStep(l10n);
      case 4:
        return _buildConfirmPinStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRequestOtpStep(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lock_reset,
          size: 80,
          color: AppColors.gold500,
        ),
        SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.pin_reset_requestTitle,
          style: AppTypography.headlineMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.md),
        Text(
          l10n.pin_reset_requestMessage,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxxl),
        AppButton(
          label: l10n.pin_reset_sendOtp,
          onPressed: _requestOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildEnterOtpStep(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.pin_reset_enterOtp,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxxl),
        AppInput(
          label: l10n.auth_otp,
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage!,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.errorText,
            ),
          ),
        ],
        const Spacer(),
        AppButton(
          label: l10n.common_continue,
          onPressed: _verifyOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
        SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: _requestOtp,
          child: Text(
            l10n.auth_resendOtp,
            style: AppTypography.labelLarge.copyWith(
              color: AppColors.gold500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewPinStep(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.pin_enterNewPin,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxxl),
        PinDots(
          filledCount: _newPin.length,
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
        PinPad(
          onNumberPressed: _handleNewPinNumber,
          onBackspace: _handleNewPinBackspace,
        ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildConfirmPinStep(AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(height: AppSpacing.xxl),
        Text(
          l10n.pin_confirmNewPin,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppSpacing.xxxl),
        PinDots(
          filledCount: _confirmPin.length,
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
            onNumberPressed: _handleConfirmPinNumber,
            onBackspace: _handleConfirmPinBackspace,
          ),
        SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Request OTP for PIN reset
  /// Calls POST /auth/login to send OTP to user's phone
  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = ref.read(dioProvider);
      // The user is authenticated, get their phone from profile
      final profileResponse = await dio.get('/user/profile');
      final profileData = profileResponse.data as Map<String, dynamic>;
      final phone = profileData['phone'] as String?;

      if (phone == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Could not retrieve phone number';
          });
        }
        return;
      }

      // Request OTP via login endpoint
      await dio.post('/auth/login', data: {'phone': phone});

      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 2;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = ApiException.fromDioError(e).message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Verify OTP entered by user
  /// OTP is validated server-side during PIN reset call
  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = l10n.auth_error_invalidOtp;
      });
      return;
    }

    // OTP will be verified server-side when we submit the reset
    // Just proceed to PIN entry step
    setState(() {
      _step = 3;
      _errorMessage = null;
    });
  }

  void _handleNewPinNumber(String number) {
    if (_newPin.length < 6) {
      setState(() {
        _newPin += number;
        _showError = false;
        _errorMessage = null;
      });

      if (_newPin.length == 6) {
        _validateNewPin();
      }
    }
  }

  void _handleNewPinBackspace() {
    if (_newPin.isNotEmpty) {
      setState(() {
        _newPin = _newPin.substring(0, _newPin.length - 1);
        _showError = false;
        _errorMessage = null;
      });
    }
  }

  void _validateNewPin() {
    final l10n = AppLocalizations.of(context)!;

    if (_isSequential(_newPin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_sequential;
      });
      _resetNewPin();
      return;
    }

    if (_isRepeated(_newPin)) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_repeated;
      });
      _resetNewPin();
      return;
    }

    setState(() => _step = 4);
  }

  void _handleConfirmPinNumber(String number) {
    if (_confirmPin.length < 6) {
      setState(() {
        _confirmPin += number;
        _showError = false;
        _errorMessage = null;
      });

      if (_confirmPin.length == 6) {
        _submitReset();
      }
    }
  }

  void _handleConfirmPinBackspace() {
    if (_confirmPin.isNotEmpty) {
      setState(() {
        _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
        _showError = false;
        _errorMessage = null;
      });
    }
  }

  /// Submit PIN reset to backend
  /// Calls POST /user/pin/reset { otp, newPinHash }
  Future<void> _submitReset() async {
    final l10n = AppLocalizations.of(context)!;

    if (_confirmPin != _newPin) {
      setState(() {
        _showError = true;
        _errorMessage = l10n.pin_error_noMatch;
      });
      _resetConfirmPin();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dio = ref.read(dioProvider);
      final pinService = ref.read(pinServiceProvider);

      // Hash the new PIN for transmission (same method as PinService)
      // We need to call the backend reset endpoint with OTP + hashed PIN
      await dio.post('/user/pin/reset', data: {
        'otp': _otpController.text,
        'newPinHash': _hashPinForBackend(_newPin),
      });

      // Also update local PIN storage
      await pinService.setPin(_newPin);

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pin_success_reset),
            backgroundColor: AppColors.successBase,
          ),
        );
        context.go('/home');
      }
    } on DioException catch (e) {
      if (mounted) {
        final message = ApiException.fromDioError(e).message;
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorMessage = message;
        });
        _resetConfirmPin();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorMessage = l10n.pin_error_resetFailed;
        });
        _resetConfirmPin();
      }
    }
  }

  /// Hash PIN using SHA256 for backend transmission
  /// Backend expects 64-char hex SHA256 hash
  String _hashPinForBackend(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  void _resetNewPin() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _newPin = '';
          _showError = false;
          _errorMessage = null;
        });
      }
    });
  }

  void _resetConfirmPin() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _confirmPin = '';
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
