import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/auth/providers/login_provider.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/features/pin/models/pin_reset_route_context.dart';
import 'package:usdc_wallet/features/pin/providers/pin_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/services/security/client_risk_score_service.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';
import 'package:usdc_wallet/utils/verification_cooldown.dart';

/// Reset PIN View
/// Multi-step flow to reset PIN via OTP
class ResetPinView extends ConsumerStatefulWidget {
  const ResetPinView({super.key, this.initialContext});

  final PinResetRouteContext? initialContext;

  @override
  ConsumerState<ResetPinView> createState() => _ResetPinViewState();
}

enum _PinRecoveryStep {
  requestOtp,
  enterOtp,
  newPin,
  confirmPin,
  liveness,
  manualReview,
}

class _ResetPinViewState extends ConsumerState<ResetPinView> {
  static const _pinResetRecoveryScope = 'pin_reset';

  _PinRecoveryStep _recoveryStep = _PinRecoveryStep.requestOtp;
  final _otpController = TextEditingController();
  final _phoneController = TextEditingController();
  PhoneNumberValue? _recoveryPhone;
  late CountryConfig _selectedRecoveryCountry;
  String _newPin = '';
  String _confirmPin = '';
  bool _showError = false;
  String? _errorMessage;
  String? _otpNoticeMessage;
  int _otpResendCountdown = 0;
  String? _otpCooldownReason;
  Timer? _otpResendTimer;
  bool _isLoading = false;
  StepUpDecision? _riskDecision;
  String? _stepUpChallengeToken;
  String? _pendingNewPinHash;
  String? _manualReviewTicketId;
  String? _manualReviewStatus;
  String? _manualReviewSlaLabel;
  String? _manualReviewResolutionDueAt;
  String? _manualReviewReason;
  String? _lastManualReviewReason;
  bool _manualReviewCreating = false;
  bool _manualReviewPinQueued = false;
  bool _manualReviewPinApplied = false;
  bool _manualReviewCreationFailed = false;

  @override
  void initState() {
    super.initState();
    _selectedRecoveryCountry = ref.read(selectedCountryProvider);
    _setRecoveryPhone(widget.initialContext?.phoneValue);
    unawaited(_prefillRecoveryPhone());
  }

  @override
  void dispose() {
    _otpResendTimer?.cancel();
    _otpController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              AuthTopBar(
                onBack: _canNavigateBackDuringRecovery
                    ? _handleRecoveryBack
                    : null,
              ),
              Expanded(child: _buildStepContent(l10n)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n) {
    switch (_recoveryStep) {
      case _PinRecoveryStep.requestOtp:
        return _buildRequestOtpStep(l10n);
      case _PinRecoveryStep.enterOtp:
        return _buildEnterOtpStep(l10n);
      case _PinRecoveryStep.newPin:
        return _buildNewPinStep(l10n);
      case _PinRecoveryStep.confirmPin:
        return _buildConfirmPinStep(l10n);
      case _PinRecoveryStep.liveness:
        return _buildRiskStep(l10n);
      case _PinRecoveryStep.manualReview:
        return _buildManualReviewStep(l10n);
    }
  }

  bool get _canNavigateBackDuringRecovery =>
      !_isLoading &&
      _recoveryStep != _PinRecoveryStep.liveness &&
      _recoveryStep != _PinRecoveryStep.manualReview;

  void _transitionTo(_PinRecoveryStep nextStep) {
    _recoveryStep = nextStep;
  }

  String? get _recoveryReturnTo => widget.initialContext?.returnTo;

  String get _resetSuccessRoute => _recoveryReturnTo ?? '/home';

  String get _loginRouteAfterRecoveryExit {
    final returnTo = _recoveryReturnTo;
    if (returnTo == null) {
      return '/login';
    }
    return '/login?returnTo=${Uri.encodeComponent(returnTo)}';
  }

  void _handleRecoveryBack() {
    unawaited(_clearRecoveryAuthorization());
    context.fsmSafePop(fallbackRoute: _loginRouteAfterRecoveryExit);
  }

  bool get _isOtpResendCoolingDown => _otpResendCountdown > 0;

  Widget _buildRequestOtpStep(AppLocalizations l10n) {
    final sendOtpLabel = _isOtpResendCoolingDown
        ? l10n.login_resendIn(_otpResendCountdown)
        : l10n.pin_reset_sendOtp;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AuthScreenHeader(
          appName: 'Korido',
          title: l10n.pin_reset_requestTitle,
          subtitle: l10n.pin_reset_requestMessage,
          markSize: 52,
          titleVariant: AppTextVariant.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildRecoveryPhoneFields(l10n),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.error_outline,
            title: _errorMessage!,
            tone: InfoCalloutTone.danger,
          ),
        ],
        if (_otpNoticeMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.schedule_rounded,
            title: _otpNoticeMessage!,
            tone: InfoCalloutTone.info,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: sendOtpLabel,
          onPressed: _isOtpResendCoolingDown || _isLoading ? null : _requestOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildRecoveryPhoneFields(AppLocalizations l10n) {
    if (_recoveryPhone != null) {
      return AppInput(
        fieldKey: const ValueKey('pin_reset_phone_field'),
        label: l10n.auth_phoneNumber,
        controller: _phoneController,
        hint: l10n.error_phoneRequired,
        prefixIcon: Icons.phone_iphone_rounded,
        keyboardType: TextInputType.phone,
        textInputAction: TextInputAction.done,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s()-]')),
        ],
        readOnly: _recoveryPhone != null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRecoveryCountrySelector(l10n),
        const SizedBox(height: AppSpacing.md),
        AppInput(
          fieldKey: const ValueKey('pin_reset_phone_field'),
          label: l10n.auth_phoneNumber,
          controller: _phoneController,
          hint:
              _selectedRecoveryCountry.phoneFormat ??
              List.filled(_selectedRecoveryCountry.phoneLength, '0').join(),
          prefixIcon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            LocalPhoneInputFormatter(
              dialCode: _selectedRecoveryCountry.fullPrefix,
              maxLocalDigits: _selectedRecoveryCountry.phoneLength,
              displayFormat: _selectedRecoveryCountry.phoneFormat,
            ),
          ],
          readOnly: _recoveryPhone != null,
          onChanged: (_) {
            if (_errorMessage != null || _otpNoticeMessage != null) {
              setState(() {
                _errorMessage = null;
                _otpNoticeMessage = null;
              });
            } else {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.auth_enterDigits(_selectedRecoveryCountry.phoneLength),
          variant: AppTextVariant.bodySmall,
          color: context.colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildRecoveryCountrySelector(AppLocalizations l10n) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.auth_country,
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: _showRecoveryCountryPicker,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colors.elevated,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Row(
              children: [
                Text(
                  _selectedRecoveryCountry.flag,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _selectedRecoveryCountry.name,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        _selectedRecoveryCountry.fullPrefix,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.unfold_more_rounded,
                  color: colors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRecoveryCountryPicker() {
    final countriesAsync = ref.read(countriesProvider);
    final countries = countriesAsync.value ?? SupportedCountries.all;

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => _RecoveryCountryPickerSheet(
          countries: countries,
          selectedCountry: _selectedRecoveryCountry,
          onSelect: (country) {
            setState(() {
              _selectedRecoveryCountry = country;
              _phoneController.clear();
              _errorMessage = null;
            });
            ref.read(selectedCountryProvider.notifier).select(country);
          },
        ),
      ),
    );
  }

  Widget _buildRiskStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        AuthScreenHeader(
          appName: 'Korido',
          title: 'Extra verification required',
          subtitle:
              'The risk check for this PIN reset requires a face and liveness check before your new PIN can be applied.',
          markSize: 44,
          titleVariant: AppTextVariant.titleLarge,
        ),
        if (_riskDecision?.reason != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.verified_user_outlined,
            title: _riskDecision!.reason!,
            tone: InfoCalloutTone.info,
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: LivenessCheckWidget(
              onComplete: _handleLivenessComplete,
              onManualReviewRequired: _routeLivenessManualReview,
              onManualReviewAcknowledged: _openManualReviewStepFromLiveness,
              useRecoveryToken: true,
              showHeader: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualReviewStep(AppLocalizations l10n) {
    final title = _manualReviewCreating
        ? 'Starting manual review'
        : _manualReviewCreationFailed
        ? 'Manual review not sent'
        : _manualReviewPinApplied
        ? 'PIN reset approved'
        : _manualReviewStatus == 'expired'
        ? 'Manual review expired'
        : _manualReviewStatus == 'rejected'
        ? 'Manual review not approved'
        : 'Manual review started';
    final body = _manualReviewCreating
        ? 'We are securely staging your new PIN for review.'
        : _manualReviewCreationFailed
        ? 'We could not securely send this recovery request. Retry from here so your new PIN can be staged for review.'
        : _manualReviewPinApplied
        ? 'Your new PIN is now active. Return to sign in and unlock Korido with the PIN you created.'
        : _manualReviewStatus == 'expired'
        ? 'This recovery review expired before the new PIN could be applied. Start PIN recovery again if you still need access.'
        : _manualReviewStatus == 'rejected'
        ? 'This recovery review could not be approved. Start PIN recovery again or contact support if this looks wrong.'
        : 'We could not safely complete the automated identity check. A Korido reviewer will verify this PIN reset request.';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: context.colors.goldSubtle,
            shape: BoxShape.circle,
            border: Border.all(color: context.colors.borderGold),
          ),
          child: _manualReviewCreating
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.gold,
                    ),
                  ),
                )
              : Icon(
                  _manualReviewCreationFailed
                      ? Icons.error_outline_rounded
                      : Icons.manage_accounts_rounded,
                  color: _manualReviewCreationFailed
                      ? context.colors.error
                      : context.colors.gold,
                  size: 36,
                ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          title,
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          body,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        if (_manualReviewPinQueued) ...[
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Your new PIN is securely queued and will become active after approval. We will notify you by app notification and SMS.',
            variant: AppTextVariant.bodySmall,
            color: context.colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        InfoCallout(
          icon: _manualReviewCreationFailed
              ? Icons.wifi_off_rounded
              : Icons.schedule_rounded,
          title: _manualReviewCreationFailed
              ? 'This request is not queued yet. Please retry when your connection is available.'
              : _manualReviewCreating
              ? 'Sending secure recovery request...'
              : _manualReviewSlaLabel ??
                    'Expected first response: within 30 minutes for locked account recovery.',
          tone: _manualReviewCreationFailed
              ? InfoCalloutTone.danger
              : InfoCalloutTone.info,
        ),
        if (_manualReviewResolutionDueAt != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Target resolution: ${_manualReviewResolutionDueAt!}',
            variant: AppTextVariant.bodySmall,
            color: context.colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
        if (_manualReviewTicketId != null) ...[
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Reference ${_manualReviewTicketId!}${_manualReviewStatus == null ? '' : ' - ${_manualReviewStatus!.replaceAll('_', ' ')}'}',
            variant: AppTextVariant.bodySmall,
            color: context.colors.textTertiary,
            textAlign: TextAlign.center,
          ),
        ],
        if (_manualReviewReason != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.verified_user_outlined,
            title: 'Reason: ${_manualReviewReason!.replaceAll('_', ' ')}',
            tone: InfoCalloutTone.info,
          ),
        ],
        const SizedBox(height: AppSpacing.xxxl),
        AppButton(
          label: _manualReviewCreationFailed
              ? 'Retry manual review'
              : _manualReviewCreating
              ? 'Starting review...'
              : 'Return to sign in',
          onPressed: _manualReviewCreationFailed
              ? _retryManualReview
              : _manualReviewCreating
              ? null
              : _returnToSignInFromManualReview,
          isLoading: _manualReviewCreating,
          isFullWidth: true,
        ),
        if (_manualReviewCreationFailed) ...[
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: 'Return to sign in',
            onPressed: _returnToSignInFromManualReview,
            variant: AppButtonVariant.secondary,
            isFullWidth: true,
          ),
        ],
      ],
    );
  }

  Widget _buildEnterOtpStep(AppLocalizations l10n) {
    final resendLabel = _isOtpResendCoolingDown
        ? l10n.login_resendIn(_otpResendCountdown)
        : l10n.auth_resendOtp;

    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        AuthScreenHeader(
          appName: 'Korido',
          title: l10n.pin_resetTitle,
          subtitle: l10n.pin_reset_enterOtp,
          markSize: 44,
          titleVariant: AppTextVariant.titleLarge,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        AppInput(
          label: l10n.auth_otp,
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.error_outline,
            title: _errorMessage!,
            tone: InfoCalloutTone.danger,
          ),
        ],
        if (_otpNoticeMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.schedule_rounded,
            title: _otpNoticeMessage!,
            tone: InfoCalloutTone.info,
          ),
        ],
        const Spacer(),
        AppButton(
          label: l10n.common_continue,
          onPressed: _verifyOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: _isOtpResendCoolingDown || _isLoading ? null : _requestOtp,
          child: AppText(
            resendLabel,
            variant: AppTextVariant.labelLarge,
            color: _isOtpResendCoolingDown
                ? context.colors.textTertiary
                : context.colors.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildNewPinStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.pin_enterNewPin,
          variant: AppTextVariant.bodyLarge,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        PinDots(length: 6, filled: _newPin.length, error: _showError),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.error_outline,
            title: _errorMessage!,
            tone: InfoCalloutTone.danger,
          ),
        ],
        const Spacer(),
        PinPad(
          onDigitPressed: _handleNewPinNumber,
          onDeletePressed: _handleNewPinBackspace,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  Widget _buildConfirmPinStep(AppLocalizations l10n) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        AppText(
          l10n.pin_confirmNewPin,
          variant: AppTextVariant.bodyLarge,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xxxl),
        PinDots(length: 6, filled: _confirmPin.length, error: _showError),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.error_outline,
            title: _errorMessage!,
            tone: InfoCalloutTone.danger,
          ),
        ],
        const Spacer(),
        if (_isLoading)
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(context.colors.gold),
          )
        else
          PinPad(
            onDigitPressed: _handleConfirmPinNumber,
            onDeletePressed: _handleConfirmPinBackspace,
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  /// Request OTP for PIN reset.
  /// Calls POST /auth/recovery/request-otp so VerifyHQ receives a PIN reset
  /// purpose instead of a normal login purpose.
  Future<void> _requestOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_isOtpResendCoolingDown) {
      setState(() {
        _errorMessage = null;
        _otpNoticeMessage = _cooldownMessage(
          l10n,
          _otpResendCountdown,
          reason: _otpCooldownReason,
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _otpNoticeMessage = null;
    });

    try {
      final phone = await _resolveRecoveryPhone();

      if (phone == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = _phoneController.text.trim().isEmpty
                ? l10n.error_phoneRequired
                : l10n.auth_enterDigits(_selectedRecoveryCountry.phoneLength);
          });
        }
        return;
      }

      if (mounted) {
        setState(() => _setRecoveryPhone(phone));
      }

      if (await _hasRecoveryAuthorizationCandidate(phone)) {
        await _ensureRecoveryAuthorization(phone);
        final hasActiveReview = await _loadActiveAccountRecoveryReview();
        if (hasActiveReview) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _transitionTo(_PinRecoveryStep.manualReview);
            });
          }
          return;
        }
      }

      final response = await ref
          .read(authServiceProvider)
          .requestRecoveryOtp(
            phone: phone.apiPhone,
            countryCode: phone.apiCountryCode,
          );

      _startOtpResendCooldown(
        response.resendAvailableIn,
        reason: response.reused ? 'otp_reused' : 'otp_sent',
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpNoticeMessage = response.reused
              ? _cooldownMessage(
                  l10n,
                  response.resendAvailableIn > 0
                      ? response.resendAvailableIn
                      : _otpResendCountdown,
                  reason: 'otp_reused',
                )
              : null;
          _transitionTo(_PinRecoveryStep.enterOtp);
        });
      }
    } on DioException catch (e) {
      final apiError = ApiException.fromDioError(e);
      final retryAfterSeconds =
          apiError.resendAvailableIn ?? apiError.retryAfterSeconds;
      final cooldownReason = verificationCooldownReason(apiError.data);
      if (retryAfterSeconds != null) {
        _startOtpResendCooldown(retryAfterSeconds, reason: cooldownReason);
      }
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (retryAfterSeconds != null) {
            _errorMessage = null;
            _otpNoticeMessage = _cooldownMessage(
              l10n,
              retryAfterSeconds,
              reason: cooldownReason,
            );
          } else {
            _otpNoticeMessage = null;
            _errorMessage = apiError.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _otpNoticeMessage = null;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _startOtpResendCooldown(int seconds, {String? reason}) {
    _otpResendTimer?.cancel();
    final normalizedSeconds = seconds <= 0
        ? 0
        : normalizeVerificationCooldownSeconds(seconds);

    if (!mounted) {
      return;
    }

    setState(() {
      _otpResendCountdown = normalizedSeconds;
      _otpCooldownReason = normalizedSeconds > 0 ? reason : null;
    });
    if (normalizedSeconds == 0) {
      return;
    }

    _otpResendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_otpResendCountdown <= 1) {
        timer.cancel();
        setState(() {
          _otpResendCountdown = 0;
          _otpCooldownReason = null;
          _otpNoticeMessage = null;
        });
        return;
      }

      setState(() => _otpResendCountdown -= 1);
    });
  }

  String _cooldownMessage(
    AppLocalizations l10n,
    int seconds, {
    String? reason,
  }) {
    final waitSeconds = seconds > 0 ? seconds : _otpResendCountdown;
    return verificationCooldownMessage(
      seconds: waitSeconds,
      reason: reason,
      formatWait: l10n.login_resendIn,
    );
  }

  Future<bool> _hasRecoveryAuthorizationCandidate(
    PhoneNumberValue phone,
  ) async {
    final scopedRecoveryToken = await _readScopedRecoveryToken(phone);
    if (scopedRecoveryToken != null && scopedRecoveryToken.isNotEmpty) {
      return true;
    }

    final routeToken = _routeRecoveryTokenFor(phone);
    if (routeToken != null && routeToken.isNotEmpty) {
      return true;
    }

    return false;
  }

  Future<PhoneNumberValue?> _resolveRecoveryPhone() async {
    final routePhone = widget.initialContext?.phoneValue;
    if (routePhone != null) {
      return routePhone;
    }

    final cachedPhone = _recoveryPhone;
    if (cachedPhone != null) {
      return cachedPhone;
    }

    final loginPhone = ref.read(loginProvider).phoneValue;
    if (loginPhone != null) {
      return loginPhone;
    }

    final authState = ref.read(authProvider);
    final inMemoryPhone = authState.user?.phone ?? authState.phone;
    if (inMemoryPhone != null && inMemoryPhone.isNotEmpty) {
      final phoneValue = PhoneNumberValue.tryFromAny(
        phoneNumber: inMemoryPhone,
        countryCode: authState.user?.countryCode ?? authState.countryCode,
      );
      if (phoneValue != null) {
        return phoneValue;
      }
    }

    final manuallyEnteredPhone = _manualRecoveryPhoneFromInput();
    if (manuallyEnteredPhone != null) {
      return manuallyEnteredPhone;
    }
    if (_phoneController.text.trim().isNotEmpty) {
      return null;
    }

    final rememberedPhone = await ref
        .read(secureStorageProvider)
        .read(key: StorageKeys.rememberedPhone);
    final rememberedPhoneValue = PhoneNumberValue.tryFromStorageValue(
      rememberedPhone,
    );
    if (rememberedPhoneValue != null) {
      return rememberedPhoneValue;
    }

    final storage = ref.read(secureStorageProvider);
    final storedDialCode = await storage.read(key: StorageKeys.userDialCode);
    final storedLocalPhone = await storage.read(
      key: StorageKeys.userLocalPhone,
    );
    final storedParts = storedDialCode != null && storedLocalPhone != null
        ? PhoneNumberValue.tryFromAny(
            phoneNumber: storedLocalPhone,
            countryCode: storedDialCode,
          )
        : null;
    if (storedParts != null) {
      return storedParts;
    }

    final storedE164 = await storage.read(key: StorageKeys.userPhoneE164);
    final storedE164Value = PhoneNumberValue.tryFromAny(
      phoneNumber: storedE164,
    );
    if (storedE164Value != null) {
      return storedE164Value;
    }

    final legacyStoredPhone = await storage.read(key: StorageKeys.userPhone);
    final legacyValue = PhoneNumberValue.tryFromAny(
      phoneNumber: legacyStoredPhone,
    );
    if (legacyValue != null) {
      return legacyValue;
    }

    final token = await storage.read(key: StorageKeys.accessToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    final profileResponse = await ref.read(dioProvider).get('/user/profile');
    final rawProfileData = profileResponse.data;
    final profileData = rawProfileData is Map<String, dynamic>
        ? (rawProfileData['data'] is Map<String, dynamic>
              ? rawProfileData['data'] as Map<String, dynamic>
              : rawProfileData)
        : const <String, dynamic>{};
    final profilePhone = profileData['phone'] as String?;
    if (profilePhone == null || profilePhone.isEmpty) {
      return null;
    }
    final profileCountry = profileData['countryCode'] as String?;
    return PhoneNumberValue.tryFromAny(
      phoneNumber: profilePhone,
      countryCode: profileCountry,
    );
  }

  Future<void> _prefillRecoveryPhone() async {
    final phone = await _resolveRecoveryPhone();
    if (!mounted || phone == null) {
      return;
    }

    setState(() => _setRecoveryPhone(phone));
  }

  void _setRecoveryPhone(PhoneNumberValue? phone) {
    if (phone == null) {
      return;
    }

    _recoveryPhone = phone;
    _phoneController.text = phone.displayInternational;
    _selectedRecoveryCountry =
        SupportedCountries.findByCode(phone.isoCountryCode) ??
        SupportedCountries.findByPrefix(phone.dialCode) ??
        _selectedRecoveryCountry;
  }

  PhoneNumberValue? _manualRecoveryPhoneFromInput() {
    final input = _phoneController.text.trim();
    if (input.isEmpty) {
      return null;
    }

    return PhoneNumberValue.tryFromAny(
      phoneNumber: input,
      countryCode: _selectedRecoveryCountry.fullPrefix,
    );
  }

  /// Verify OTP entered by user and create a scoped recovery session.
  Future<void> _verifyOtp() async {
    final l10n = AppLocalizations.of(context)!;

    if (_otpController.text.length != 6) {
      setState(() {
        _errorMessage = l10n.auth_error_invalidOtp;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _createRecoveryAuthorizationFromOtp();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _transitionTo(_PinRecoveryStep.newPin);
        });
      }
    } on ApiException catch (e) {
      final retryAfterSeconds = e.resendAvailableIn ?? e.retryAfterSeconds;
      final cooldownReason = verificationCooldownReason(e.data);
      if (retryAfterSeconds != null) {
        _startOtpResendCooldown(retryAfterSeconds, reason: cooldownReason);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          if (retryAfterSeconds != null) {
            _errorMessage = null;
            _otpNoticeMessage = _cooldownMessage(
              l10n,
              retryAfterSeconds,
              reason: cooldownReason,
            );
          } else {
            _otpNoticeMessage = null;
            _errorMessage =
                'We could not verify this recovery code. Please try again.';
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'We could not verify this recovery code. Please try again.';
        });
      }
    }
  }

  Future<void> _createRecoveryAuthorizationFromOtp() async {
    final phone = await _resolveRecoveryPhone();
    if (phone == null) {
      throw StateError('Phone number is required');
    }

    if (mounted) {
      setState(() => _setRecoveryPhone(phone));
    }

    final recovery = await ref
        .read(authServiceProvider)
        .verifyRecoveryOtp(
          phone: phone.apiPhone,
          countryCode: phone.apiCountryCode,
          otp: _otpController.text,
        );

    await _storeRecoveryAuthorization(recovery.recoveryAccessToken, phone);
  }

  Future<Map<String, dynamic>> _accountRecoveryRiskMetadata() async {
    final metadata = <String, dynamic>{
      'flow': 'pin_reset',
      'otpLength': _otpController.text.length,
    };

    try {
      final fingerprint = await ref
          .read(deviceFingerprintServiceProvider)
          .collect();
      metadata.addAll({
        'deviceId': fingerprint.deviceId,
        'fingerprintHash': fingerprint.fingerprintHash,
        'platform': fingerprint.platform,
        'isPhysicalDevice': fingerprint.isPhysicalDevice,
        'biometricsAvailable': fingerprint.biometricsAvailable,
        'deviceCompromised': fingerprint.isCompromised,
      });
    } on Object {
      metadata['deviceSignalsUnavailable'] = true;
    }

    try {
      metadata['serverObservedClientRiskScore'] = await ref
          .read(clientRiskScoreServiceProvider)
          .calculateRiskScore(action: RiskAction.accountRecovery);
    } on Object {
      metadata['clientRiskScoreUnavailable'] = true;
    }

    return metadata;
  }

  Future<Map<String, dynamic>> _manualReviewContext({
    required String reason,
    StepUpDecision? decision,
    LivenessManualReviewRequest? livenessRequest,
  }) async {
    final context = await _accountRecoveryRiskMetadata();
    context.addAll({
      'reason': reason,
      'source': 'pin_recovery_fsm',
      'hasStepUpChallengeToken': _stepUpChallengeToken != null,
    });

    if (decision != null) {
      context['riskDecision'] = {
        'flow': decision.flow.name,
        'riskScore': decision.riskScore,
        'riskLevel': decision.riskLevel,
        'stepUpRequired': decision.stepUpRequired,
        'stepUpType': decision.stepUpType.name,
        'supportReviewRequired': decision.supportReviewRequired,
        'nextAction': decision.nextAction,
        'nextEndpoint': decision.nextEndpoint,
        'requiresPendingPinReset': decision.requiresPendingPinReset,
        'factors': decision.factors,
        if (decision.reason != null) 'reason': decision.reason,
        if (decision.reviewSla != null)
          'reviewSla': {
            'label': decision.reviewSla!.label,
            'firstResponseMinutes': decision.reviewSla!.firstResponseMinutes,
            'resolutionMinutes': decision.reviewSla!.resolutionMinutes,
            'manualReview': decision.reviewSla!.manualReview,
          },
      };
    }

    if (livenessRequest != null) {
      context['livenessFallback'] = {
        'reason': livenessRequest.reason,
        'message': livenessRequest.message,
        'title': livenessRequest.title,
        'slaLabel': livenessRequest.slaLabel,
        'backendReviewId': livenessRequest.backendReviewId,
        'backendReviewStatus': livenessRequest.backendReviewStatus,
        'backendReviewAlreadyCreated':
            livenessRequest.backendReviewAlreadyCreated,
      };
    }

    return context;
  }

  bool _requiresManualReview(StepUpDecision decision) {
    return decision.stepUpType == StepUpType.manualReview;
  }

  bool _requiresFaceAndLiveness(StepUpDecision decision) {
    final riskLevel = decision.riskLevel.toLowerCase();
    return decision.flow == RiskFlow.red ||
        riskLevel == 'high' ||
        riskLevel == 'critical' ||
        decision.stepUpType == StepUpType.liveness ||
        decision.stepUpType == StepUpType.biometricAndLiveness;
  }

  Future<bool> _prepareRecoveryDecisionForConfirmedPin(
    String newPinHash,
  ) async {
    try {
      final riskService = ref.read(riskBasedSecurityServiceProvider);
      final decision = await riskService.evaluateOperation(
        operation: 'account_recovery',
        metadata: await _accountRecoveryRiskMetadata(),
        useRecoveryToken: true,
      );

      if (!mounted) return false;

      _riskDecision = decision;
      _stepUpChallengeToken = decision.challengeToken;

      if (_requiresManualReview(decision)) {
        await _routePinResetToManualReview(
          decision.nextAction ?? 'risk_manual_review',
          newPinHash: newPinHash,
          decision: decision,
        );
        return false;
      }

      if (_requiresFaceAndLiveness(decision)) {
        if (decision.challengeToken == null) {
          await _routePinResetToManualReview(
            'step_up_challenge_unavailable',
            newPinHash: newPinHash,
          );
          return false;
        }

        setState(() {
          _pendingNewPinHash = newPinHash;
          _isLoading = false;
          _transitionTo(_PinRecoveryStep.liveness);
        });
        return false;
      }

      if (decision.stepUpRequired) {
        if (decision.challengeToken == null) {
          await _routePinResetToManualReview(
            'step_up_challenge_unavailable',
            newPinHash: newPinHash,
          );
          return false;
        }

        final verified = await riskService.executeStepUp(decision);
        if (!mounted) return false;
        if (!verified) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'We could not verify this PIN reset.';
          });
          return false;
        }

        final validated = await riskService.validateStepUp(
          challengeToken: decision.challengeToken!,
          biometricVerified:
              decision.stepUpType == StepUpType.biometric ||
              decision.stepUpType == StepUpType.biometricAndLiveness,
          useRecoveryToken: true,
        );
        if (!mounted) return false;
        if (!validated) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'We could not validate this security check.';
          });
          return false;
        }
        _stepUpChallengeToken = decision.challengeToken;
      }

      if (_stepUpChallengeToken == null) {
        await _routePinResetToManualReview(
          'step_up_challenge_unavailable',
          newPinHash: newPinHash,
        );
        return false;
      }

      return true;
    } catch (_) {
      if (mounted) {
        await _routePinResetToManualReview(
          'risk_or_provider_unavailable',
          newPinHash: newPinHash,
        );
      }
      return false;
    }
  }

  Future<void> _handleLivenessComplete(LivenessResult result) async {
    if (!mounted) return;

    final pendingPinHash = _pendingNewPinHash;
    if (pendingPinHash == null) {
      setState(() {
        _transitionTo(_PinRecoveryStep.newPin);
        _showError = true;
        _errorMessage =
            'Please choose the new PIN again before identity verification.';
      });
      return;
    }

    final faceScore = result.faceMatchScore ?? 1.0;
    if (!result.isLive || result.confidence < 0.50 || faceScore < 0.50) {
      await _routePinResetToManualReview(
        'liveness_low_confidence',
        newPinHash: pendingPinHash,
      );
      return;
    }
    if (result.decision != LivenessDecision.autoApprove || faceScore < 0.85) {
      await _routePinResetToManualReview(
        'liveness_manual_review_confidence',
        newPinHash: pendingPinHash,
      );
      return;
    }

    final challengeToken = _riskDecision?.challengeToken;
    if (challengeToken == null) {
      await _routePinResetToManualReview(
        'liveness_challenge_unavailable',
        newPinHash: pendingPinHash,
      );
      return;
    }

    late final bool valid;
    try {
      valid = await ref
          .read(riskBasedSecurityServiceProvider)
          .validateStepUp(
            challengeToken: challengeToken,
            livenessSessionId: result.stepUpProofId,
            useRecoveryToken: true,
          );
    } on ManualReviewRequiredException {
      await _routePinResetToManualReview(
        'liveness_step_up_provider_unavailable',
        newPinHash: pendingPinHash,
      );
      return;
    }
    if (!mounted) return;
    if (!valid) {
      await _routePinResetToManualReview(
        'liveness_step_up_validation_failed',
        newPinHash: pendingPinHash,
      );
      return;
    }

    _stepUpChallengeToken = challengeToken;
    setState(() {
      _isLoading = true;
      _transitionTo(_PinRecoveryStep.confirmPin);
      _showError = false;
      _errorMessage = null;
    });
    await _finalizeConfirmedPinReset(pendingPinHash);
  }

  Future<void> _routePinResetToManualReview(
    String reason, {
    String? newPinHash,
    StepUpDecision? decision,
    LivenessManualReviewRequest? livenessRequest,
  }) async {
    if (!mounted) return;
    _lastManualReviewReason = reason;
    final pendingPinHash =
        newPinHash ??
        _pendingNewPinHash ??
        (_newPin.length == 6 && _confirmPin == _newPin
            ? _hashPinForBackend(_newPin)
            : null);

    if (pendingPinHash == null) {
      setState(() {
        _isLoading = false;
        _transitionTo(_PinRecoveryStep.newPin);
        _showError = true;
        _errorMessage =
            'Choose and confirm your new PIN before manual review can start.';
      });
      return;
    }

    _pendingNewPinHash = pendingPinHash;

    setState(() {
      _markManualReviewCreating(
        reason,
        reviewSla: decision?.reviewSla,
        fallbackSlaLabel: livenessRequest?.slaLabel,
      );
      _isLoading = false;
      _showError = false;
      _errorMessage = null;
      _transitionTo(_PinRecoveryStep.manualReview);
    });

    try {
      final phone = await _resolveRecoveryPhone();
      if (phone == null) {
        throw StateError('Phone number is required');
      }
      await _ensureRecoveryAuthorization(phone);
      final reviewContext = await _manualReviewContext(
        reason: reason,
        decision: decision,
        livenessRequest: livenessRequest,
      );
      final response = await ref
          .read(dioProvider)
          .post(
            ApiEndpoints.userPinResetManualReview,
            data: {
              'newPinHash': pendingPinHash,
              'reason': reason,
              'context': reviewContext,
              if (_stepUpChallengeToken != null)
                'stepUpChallengeToken': _stepUpChallengeToken,
            },
            options: _recoveryOptions(),
          );
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;

      if (!mounted) return;
      setState(() {
        _applyManualReviewTicket(data);
        _manualReviewReason = reason;
        _isLoading = false;
        _transitionTo(_PinRecoveryStep.manualReview);
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _markManualReviewCreationFailed(reason);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _markManualReviewCreationFailed(reason);
      });
    }
  }

  void _routeLivenessManualReview(LivenessManualReviewRequest request) {
    unawaited(
      _routePinResetToManualReview(
        request.reason,
        newPinHash: _pendingNewPinHash,
        livenessRequest: request,
      ),
    );
  }

  void _openManualReviewStepFromLiveness() {
    if (!mounted) return;
    final pendingPinHash = _pendingNewPinHash;
    if (pendingPinHash == null) {
      setState(() {
        _transitionTo(_PinRecoveryStep.newPin);
        _showError = true;
        _errorMessage =
            'Choose and confirm your new PIN before manual review can start.';
      });
      return;
    }

    unawaited(
      _routePinResetToManualReview(
        _lastManualReviewReason ?? 'liveness_manual_review_required',
        newPinHash: pendingPinHash,
      ),
    );
  }

  Future<bool> _loadActiveAccountRecoveryReview() async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            ApiEndpoints.userPinResetReviewCurrent,
            options: _recoveryOptions(),
          );
      final body = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : const <String, dynamic>{};
      final data = body['data'] is Map
          ? Map<String, dynamic>.from(body['data'] as Map)
          : body;
      final status = data['status']?.toString();
      if (status == null || status == 'none') {
        return false;
      }

      _applyManualReviewTicket(data);
      return true;
    } on Object {
      return false;
    }
  }

  void _applyManualReviewTicket(Map<String, dynamic> data) {
    _manualReviewTicketId = (data['ticketId'] ?? data['id'])?.toString();
    _manualReviewStatus = data['status']?.toString();
    _manualReviewPinApplied =
        data['pinResetApplied'] == true || _manualReviewStatus == 'approved';
    _manualReviewPinQueued =
        data['hasPendingPinReset'] == true && !_manualReviewPinApplied;
    _manualReviewCreating = false;
    _manualReviewCreationFailed =
        !_manualReviewPinQueued &&
        !_manualReviewPinApplied &&
        _manualReviewStatus != 'rejected' &&
        _manualReviewStatus != 'expired' &&
        _manualReviewStatus != 'closed';

    final reviewSla = data['reviewSla'];
    if (reviewSla is Map) {
      _manualReviewSlaLabel = reviewSla['label']?.toString();
      _manualReviewResolutionDueAt = _formatReviewDueAt(
        reviewSla['resolutionDueAt']?.toString(),
      );
    }
  }

  void _markManualReviewCreating(
    String reason, {
    StepUpReviewSla? reviewSla,
    String? fallbackSlaLabel,
  }) {
    _manualReviewStatus = 'creating_manual_review';
    _manualReviewCreating = true;
    _manualReviewCreationFailed = false;
    _manualReviewPinQueued = false;
    _manualReviewPinApplied = false;
    _manualReviewSlaLabel = reviewSla?.label ?? fallbackSlaLabel;
    _manualReviewResolutionDueAt = null;
    _manualReviewReason = reason;
  }

  void _markManualReviewCreationFailed(String reason) {
    _manualReviewStatus = 'not_sent';
    _manualReviewCreating = false;
    _manualReviewCreationFailed = true;
    _manualReviewPinQueued = false;
    _manualReviewPinApplied = false;
    _manualReviewSlaLabel ??=
        'Expected first response: within 30 minutes for locked account recovery.';
    _manualReviewResolutionDueAt = null;
    _manualReviewReason = reason;
    _isLoading = false;
    _showError = false;
    _errorMessage = null;
    _transitionTo(_PinRecoveryStep.manualReview);
  }

  void _retryManualReview() {
    final pendingPinHash = _pendingNewPinHash;
    if (pendingPinHash == null) {
      setState(() {
        _transitionTo(_PinRecoveryStep.newPin);
        _showError = true;
        _errorMessage =
            'Choose and confirm your new PIN before manual review can start.';
      });
      return;
    }

    unawaited(
      _routePinResetToManualReview(
        _lastManualReviewReason ??
            _manualReviewReason ??
            'manual_review_required',
        newPinHash: pendingPinHash,
      ),
    );
  }

  Future<void> _returnToSignInFromManualReview() async {
    await _clearRecoveryAuthorization();
    try {
      await ref.read(authProvider.notifier).clearLocalSession();
    } catch (_) {}
    if (!mounted) return;
    context.fsmGo(_loginRouteAfterRecoveryExit);
  }

  String? _formatReviewDueAt(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} $hour:$minute';
  }

  void _handleNewPinNumber(int digit) {
    if (_newPin.length < 6) {
      setState(() {
        _newPin += digit.toString();
        _pendingNewPinHash = null;
        _riskDecision = null;
        _stepUpChallengeToken = null;
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
        _pendingNewPinHash = null;
        _riskDecision = null;
        _stepUpChallengeToken = null;
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

    setState(() => _transitionTo(_PinRecoveryStep.confirmPin));
  }

  void _handleConfirmPinNumber(int digit) {
    if (_confirmPin.length < 6) {
      setState(() {
        _confirmPin += digit.toString();
        _showError = false;
        _errorMessage = null;
      });

      if (_confirmPin.length == 6) {
        unawaited(_submitReset());
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

  /// Submit confirmed PIN reset through the recovery decision flow.
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

    final newPinHash = _hashPinForBackend(_newPin);
    _pendingNewPinHash = newPinHash;

    setState(() => _isLoading = true);

    final canApply = await _prepareRecoveryDecisionForConfirmedPin(newPinHash);
    if (!canApply) {
      return;
    }

    await _finalizeConfirmedPinReset(newPinHash);
  }

  /// Calls POST /user/pin/reset { otp, newPinHash, stepUpChallengeToken }
  Future<void> _finalizeConfirmedPinReset(String newPinHash) async {
    final l10n = AppLocalizations.of(context)!;

    try {
      final phone = await _resolveRecoveryPhone();
      if (phone == null) {
        throw StateError('Phone number is required');
      }
      await _ensureRecoveryAuthorization(phone);
      final dio = ref.read(dioProvider);
      final stepUpChallengeToken = _stepUpChallengeToken;

      if (stepUpChallengeToken == null) {
        await _routePinResetToManualReview(
          'step_up_challenge_unavailable',
          newPinHash: newPinHash,
        );
        return;
      }

      await dio.post(
        ApiEndpoints.userPinReset,
        data: {
          'otp': _otpController.text,
          'newPinHash': newPinHash,
          'stepUpChallengeToken': stepUpChallengeToken,
        },
        options: _recoveryOptions(),
      );

      // Also update local PIN storage and in-memory PIN state.
      final pinUpdated = await ref
          .read(pinStateProvider.notifier)
          .cacheConfirmedPin(_newPin);
      if (!pinUpdated) {
        throw StateError('Local PIN update failed after backend reset');
      }

      final unlocked = await _unlockAfterReset();
      if (!mounted) return;

      setState(() => _isLoading = false);
      await _clearRecoveryAuthorization();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pin_success_reset),
          backgroundColor: context.colors.success,
        ),
      );
      if (unlocked) {
        context.fsmEnterAuthenticatedApp(route: _resetSuccessRoute);
      } else {
        context.fsmGo(_loginRouteAfterRecoveryExit);
      }
    } on DioException catch (e) {
      if (mounted) {
        final apiError = ApiException.fromDioError(e);
        if (_applyBackendManualReview(apiError)) {
          return;
        }
        final message = apiError.message;
        if (_isVerificationProviderUnavailable(e, message)) {
          await _routePinResetToManualReview(
            'otp_verification_provider_unavailable',
            newPinHash: newPinHash,
          );
          return;
        }
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

  Future<void> _ensureRecoveryAuthorization(PhoneNumberValue phone) async {
    final routeToken = _routeRecoveryTokenFor(phone);
    if (routeToken != null && routeToken.isNotEmpty) {
      await _storeRecoveryAuthorization(routeToken, phone);
      return;
    }

    final existingRecoveryToken = await _readScopedRecoveryToken(phone);
    if (existingRecoveryToken != null && existingRecoveryToken.isNotEmpty) {
      return;
    }

    await _clearRecoveryAuthorization();
  }

  Future<void> _clearRecoveryAuthorization() async {
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: StorageKeys.recoveryAccessToken);
    await storage.delete(key: StorageKeys.recoveryAccessTokenPhone);
    await storage.delete(key: StorageKeys.recoveryAccessTokenScope);
    await storage.delete(key: StorageKeys.recoveryAccessTokenCreatedAt);
  }

  Future<void> _storeRecoveryAuthorization(
    String token,
    PhoneNumberValue phone,
  ) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: StorageKeys.recoveryAccessToken, value: token);
    await storage.write(
      key: StorageKeys.recoveryAccessTokenPhone,
      value: phone.storageValue,
    );
    await storage.write(
      key: StorageKeys.recoveryAccessTokenScope,
      value: _pinResetRecoveryScope,
    );
    await storage.write(
      key: StorageKeys.recoveryAccessTokenCreatedAt,
      value: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<String?> _readScopedRecoveryToken(PhoneNumberValue phone) async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: StorageKeys.recoveryAccessToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    final storedScope = await storage.read(
      key: StorageKeys.recoveryAccessTokenScope,
    );
    final storedPhone = PhoneNumberValue.tryFromStorageValue(
      await storage.read(key: StorageKeys.recoveryAccessTokenPhone),
    );
    if (storedScope != _pinResetRecoveryScope ||
        storedPhone?.e164 != phone.e164) {
      await _clearRecoveryAuthorization();
      return null;
    }

    return token;
  }

  String? _routeRecoveryTokenFor(PhoneNumberValue phone) {
    final routeToken = widget.initialContext?.recoveryAccessToken;
    if (routeToken == null || routeToken.isEmpty) {
      return null;
    }

    if (!_isScopedPinResetRecoveryToken(routeToken)) {
      return null;
    }

    final routePhone = widget.initialContext?.phoneValue;
    if (routePhone != null && routePhone.e164 != phone.e164) {
      return null;
    }

    return routeToken;
  }

  bool _isScopedPinResetRecoveryToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) {
        return false;
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic>) {
        return false;
      }

      return payload['type'] == 'account_recovery' &&
          payload['scope'] == _pinResetRecoveryScope;
    } catch (_) {
      return false;
    }
  }

  bool _applyBackendManualReview(ApiException error) {
    final payload = _apiErrorPayload(error.data);
    final code =
        (error.code ?? payload['code']?.toString())?.toUpperCase() ?? '';
    final supportReviewRequired = payload['supportReviewRequired'] == true;

    if (code != 'E2007' && !supportReviewRequired) {
      return false;
    }

    final supportTicketId = payload['supportTicketId'] ?? payload['ticketId'];
    setState(() {
      _applyManualReviewTicket({
        'id': supportTicketId,
        'status': payload['status'] ?? 'open',
        'hasPendingPinReset': payload['hasPendingPinReset'] ?? true,
        'pendingPinExpiresAt': payload['pendingPinExpiresAt'],
        'reviewSla': payload['reviewSla'],
      });
      _isLoading = false;
      _showError = false;
      _errorMessage = null;
      _transitionTo(_PinRecoveryStep.manualReview);
    });
    return true;
  }

  Map<String, dynamic> _apiErrorPayload(Object? data) {
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final error = map['error'];
      if (error is Map) {
        return {...map, ...Map<String, dynamic>.from(error)};
      }
      return map;
    }
    return const <String, dynamic>{};
  }

  bool _isVerificationProviderUnavailable(DioException error, String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('verification service temporarily unavailable') ||
        normalized.contains('verification provider') ||
        normalized.contains('provider is currently unavailable')) {
      return true;
    }

    final data = error.response?.data;
    if (data is Map) {
      final code = ApiException.errorCode(data)?.toLowerCase();
      if (code != null &&
          (code.contains('verification') || code.contains('provider')) &&
          (code.contains('unavailable') || code.contains('timeout'))) {
        return true;
      }
    }

    return error.response?.statusCode == 503;
  }

  Options _recoveryOptions() {
    return Options(extra: {ApiRequestExtra.useRecoveryToken: true});
  }

  /// Hash PIN using SHA256 for backend transmission
  /// Backend expects 64-char hex SHA256 hash
  String _hashPinForBackend(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> _unlockAfterReset() async {
    final pendingLoginCompleted = await _completePendingLoginAfterPinReset();
    if (!pendingLoginCompleted) {
      try {
        final unlocked = await ref
            .read(authProvider.notifier)
            .unlockAfterAccountRecovery();
        if (!unlocked || !mounted) {
          return false;
        }
      } on Object {
        return false;
      }
    }

    try {
      ref.read(authProvider.notifier).unlock();
    } on Object {
      // Auth may already be active after account recovery.
    }
    try {
      ref.read(sessionServiceProvider.notifier).unlockSession();
    } on Object {
      // Session may already be active after account recovery.
    }
    try {
      ref.read(appFsmProvider.notifier).unlockSession();
    } on Object {
      // FSM may already have transitioned after account recovery.
    }

    final authState = ref.read(authProvider);
    final sessionState = ref.read(sessionServiceProvider);

    return authState.isAuthenticated &&
        !authState.isLocked &&
        !sessionState.isLocked;
  }

  Future<bool> _completePendingLoginAfterPinReset() async {
    final loginState = ref.read(loginProvider);
    final accessToken = loginState.sessionToken;
    if (accessToken == null || accessToken.isEmpty) {
      return false;
    }

    return ref
        .read(authProvider.notifier)
        .completePinLogin(
          accessToken: accessToken,
          refreshToken: loginState.refreshToken,
          user: loginState.user,
          phone: loginState.phoneNumber,
          countryCode: loginState.dialCode,
          kycStatus: loginState.kycStatus,
          expiresIn: loginState.sessionExpiresIn,
        );
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

class _RecoveryCountryPickerSheet extends StatelessWidget {
  const _RecoveryCountryPickerSheet({
    required List<CountryConfig> countries,
    required CountryConfig selectedCountry,
    required ValueChanged<CountryConfig> onSelect,
  }) : _countries = countries,
       _selectedCountry = selectedCountry,
       _onSelect = onSelect;

  final List<CountryConfig> _countries;
  final CountryConfig _selectedCountry;
  final ValueChanged<CountryConfig> _onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderSubtle,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              AppLocalizations.of(context)!.auth_country,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _countries.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  final isSelected = country.code == _selectedCountry.code;
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    onTap: () {
                      _onSelect(country);
                      context.fsmPop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.goldSubtle : colors.elevated,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected
                              ? colors.borderGold
                              : colors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            country.flag,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  country.name,
                                  variant: AppTextVariant.bodyLarge,
                                  color: colors.textPrimary,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                                const SizedBox(height: 2),
                                AppText(
                                  country.fullPrefix,
                                  variant: AppTextVariant.bodySmall,
                                  color: colors.textTertiary,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              color: colors.gold,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
