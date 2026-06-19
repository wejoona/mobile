import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
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
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Reset PIN View
/// Multi-step flow to reset PIN via OTP
class ResetPinView extends ConsumerStatefulWidget {
  const ResetPinView({super.key, this.initialContext});

  final PinResetRouteContext? initialContext;

  @override
  ConsumerState<ResetPinView> createState() => _ResetPinViewState();
}

class _ResetPinViewState extends ConsumerState<ResetPinView> {
  int _step =
      1; // 1: request OTP, 2: enter OTP, 5: liveness, 3/4: PIN, 6: review
  final _otpController = TextEditingController();
  final _phoneController = TextEditingController();
  PhoneNumberValue? _recoveryPhone;
  String _newPin = '';
  String _confirmPin = '';
  bool _showError = false;
  String? _errorMessage;
  bool _isLoading = false;
  StepUpDecision? _riskDecision;
  String? _stepUpChallengeToken;
  String? _manualReviewTicketId;
  String? _manualReviewStatus;
  String? _manualReviewSlaLabel;
  String? _manualReviewResolutionDueAt;
  String? _manualReviewReason;
  String? _lastManualReviewReason;

  @override
  void initState() {
    super.initState();
    _setRecoveryPhone(widget.initialContext?.phoneValue);
    unawaited(_prefillRecoveryPhone());
  }

  @override
  void dispose() {
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
    switch (_step) {
      case 1:
        return _buildRequestOtpStep(l10n);
      case 2:
        return _buildEnterOtpStep(l10n);
      case 5:
        return _buildRiskStep(l10n);
      case 3:
        return _buildNewPinStep(l10n);
      case 4:
        return _buildConfirmPinStep(l10n);
      case 6:
        return _buildManualReviewStep(l10n);
      default:
        return const SizedBox.shrink();
    }
  }

  bool get _canNavigateBackDuringRecovery =>
      !_isLoading && _step != 5 && _step != 6;

  void _handleRecoveryBack() {
    unawaited(_clearRecoveryAuthorization());
    context.fsmSafePop(fallbackRoute: '/login');
  }

  Widget _buildRequestOtpStep(AppLocalizations l10n) {
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
        AppInput(
          fieldKey: const ValueKey('pin_reset_phone_field'),
          label: l10n.auth_phoneNumber,
          controller: _phoneController,
          hint: l10n.error_phoneRequired,
          prefixIcon: Icons.phone_iphone_rounded,
          keyboardType: TextInputType.phone,
          readOnly: true,
        ),
        if (_errorMessage != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoCallout(
            icon: Icons.error_outline,
            title: _errorMessage!,
            tone: InfoCalloutTone.danger,
          ),
        ],
        const SizedBox(height: AppSpacing.xxl),
        AppButton(
          label: l10n.pin_reset_sendOtp,
          onPressed: _requestOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
      ],
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
              'The risk check for this PIN reset requires a face and liveness check before you create a new PIN.',
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
              onManualReviewRequired: _routePinResetToManualReview,
              onManualReviewAcknowledged: _openManualReviewStepFromLiveness,
              useRecoveryToken: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManualReviewStep(AppLocalizations l10n) {
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
          child: Icon(
            Icons.manage_accounts_rounded,
            color: context.colors.gold,
            size: 36,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppText(
          'Manual review started',
          variant: AppTextVariant.titleLarge,
          color: context.colors.textPrimary,
          textAlign: TextAlign.center,
          fontWeight: FontWeight.w700,
        ),
        const SizedBox(height: AppSpacing.md),
        AppText(
          'We could not safely complete the automated identity check. A Korido reviewer will verify this PIN reset request.',
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.lg),
        InfoCallout(
          icon: Icons.schedule_rounded,
          title:
              _manualReviewSlaLabel ??
              'Expected first response: within 30 minutes for locked account recovery.',
          tone: InfoCalloutTone.info,
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
          label: 'Return to sign in',
          onPressed: _returnToSignInFromManualReview,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildEnterOtpStep(AppLocalizations l10n) {
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
        const Spacer(),
        AppButton(
          label: l10n.common_continue,
          onPressed: _verifyOtp,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.md),
        TextButton(
          onPressed: _requestOtp,
          child: AppText(
            l10n.auth_resendOtp,
            variant: AppTextVariant.labelLarge,
            color: context.colors.gold,
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

  /// Request OTP for PIN reset
  /// Calls POST /auth/login to send OTP to user's phone
  Future<void> _requestOtp() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _ensureRecoveryAuthorization();
      final phone = await _resolveRecoveryPhone();

      if (phone == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = l10n.error_phoneRequired;
          });
        }
        return;
      }

      if (mounted) {
        setState(() => _setRecoveryPhone(phone));
      }

      final hasActiveReview = await _loadActiveAccountRecoveryReview();
      if (hasActiveReview) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _step = 6;
          });
        }
        return;
      }

      await ref
          .read(authServiceProvider)
          .login(phone: phone.apiPhone, countryCode: phone.apiCountryCode);

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
      final riskService = ref.read(riskBasedSecurityServiceProvider);
      final decision = await riskService.evaluateOperation(
        operation: 'account_recovery',
        metadata: await _accountRecoveryRiskMetadata(),
        useRecoveryToken: true,
      );

      if (!mounted) return;

      _riskDecision = decision;
      _stepUpChallengeToken = decision.challengeToken;

      if (_requiresManualReview(decision)) {
        await _routePinResetToManualReview('risk_manual_review');
        return;
      }

      if (_requiresFaceAndLiveness(decision)) {
        if (decision.challengeToken == null) {
          await _routePinResetToManualReview('step_up_challenge_unavailable');
          return;
        }

        setState(() {
          _isLoading = false;
          _step = 5;
        });
        return;
      }

      if (decision.stepUpRequired) {
        if (decision.challengeToken == null) {
          await _routePinResetToManualReview('step_up_challenge_unavailable');
          return;
        }

        final verified = await riskService.executeStepUp(decision);
        if (!mounted) return;
        if (!verified) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'We could not verify this PIN reset.';
          });
          return;
        }

        final validated = await riskService.validateStepUp(
          challengeToken: decision.challengeToken!,
          biometricVerified:
              decision.stepUpType == StepUpType.biometric ||
              decision.stepUpType == StepUpType.biometricAndLiveness,
        );
        if (!mounted) return;
        if (!validated) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'We could not validate this security check.';
          });
          return;
        }
        _stepUpChallengeToken = decision.challengeToken;
      }

      if (_stepUpChallengeToken == null) {
        await _routePinResetToManualReview('step_up_challenge_unavailable');
        return;
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _step = 3;
        });
      }
    } catch (_) {
      if (mounted) {
        await _routePinResetToManualReview('risk_or_provider_unavailable');
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

    await ref
        .read(secureStorageProvider)
        .write(
          key: StorageKeys.recoveryAccessToken,
          value: recovery.recoveryAccessToken,
        );
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

  Future<void> _handleLivenessComplete(LivenessResult result) async {
    if (!mounted) return;

    final faceScore = result.faceMatchScore ?? 1.0;
    if (!result.isLive || result.confidence < 0.50 || faceScore < 0.50) {
      await _routePinResetToManualReview('liveness_low_confidence');
      return;
    }
    if (result.decision != LivenessDecision.autoApprove || faceScore < 0.85) {
      await _routePinResetToManualReview('liveness_manual_review_confidence');
      return;
    }

    final challengeToken = _riskDecision?.challengeToken;
    if (challengeToken == null) {
      setState(() {
        _showError = true;
        _errorMessage =
            'We could not validate this security check. Please try again.';
      });
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
      );
      return;
    }
    if (!mounted) return;
    if (!valid) {
      setState(() {
        _showError = true;
        _errorMessage = 'We could not validate this security check.';
      });
      return;
    }

    setState(() {
      _step = 3;
      _stepUpChallengeToken = challengeToken;
      _showError = false;
      _errorMessage = null;
    });
  }

  Future<void> _routePinResetToManualReview(String reason) async {
    if (!mounted) return;
    _lastManualReviewReason = reason;

    setState(() {
      _applyManualReviewFallback(reason);
      _isLoading = false;
      _showError = false;
      _errorMessage = null;
      _step = 6;
    });

    try {
      await _ensureRecoveryAuthorization();
      final response = await ref
          .read(dioProvider)
          .post(
            '/support/tickets',
            data: {
              'subject': 'Manual review required for PIN reset',
              'category': 'account_recovery',
              'priority': 'high',
              'message':
                  'A PIN reset could not complete automated verification. '
                  'Reason: $reason. Flow: pin_reset. '
                  'Please review identity evidence and approve or reject recovery.',
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
        _step = 6;
      });
    } on DioException {
      if (!mounted) return;
      setState(() {
        _applyManualReviewFallback(reason);
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _applyManualReviewFallback(reason);
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  void _openManualReviewStepFromLiveness() {
    if (!mounted) return;
    setState(() {
      _applyManualReviewFallback(
        _lastManualReviewReason ?? 'liveness_manual_review_required',
      );
      _isLoading = false;
      _showError = false;
      _errorMessage = null;
      _step = 6;
    });
  }

  Future<bool> _loadActiveAccountRecoveryReview() async {
    try {
      final response = await ref
          .read(dioProvider)
          .get(
            '/support/tickets/active',
            queryParameters: {'category': 'account_recovery'},
            options: _recoveryOptions(),
          );
      final body = response.data;
      final tickets = body is List
          ? body
          : body is Map && body['data'] is List
          ? body['data'] as List
          : const [];
      if (tickets.isEmpty) {
        return false;
      }

      final first = tickets.first;
      if (first is Map) {
        _applyManualReviewTicket(Map<String, dynamic>.from(first));
      }
      return true;
    } on Object {
      return false;
    }
  }

  void _applyManualReviewTicket(Map<String, dynamic> data) {
    _manualReviewTicketId = data['id']?.toString();
    _manualReviewStatus = data['status']?.toString();

    final reviewSla = data['reviewSla'];
    if (reviewSla is Map) {
      _manualReviewSlaLabel = reviewSla['label']?.toString();
      _manualReviewResolutionDueAt = _formatReviewDueAt(
        reviewSla['resolutionDueAt']?.toString(),
      );
    }
  }

  void _applyManualReviewFallback(String reason) {
    _manualReviewStatus ??= 'pending_manual_review';
    _manualReviewSlaLabel ??=
        'Expected first response: within 30 minutes for locked account recovery.';
    _manualReviewResolutionDueAt ??= null;
    _manualReviewReason = reason;
  }

  Future<void> _returnToSignInFromManualReview() async {
    await _clearRecoveryAuthorization();
    try {
      await ref.read(authProvider.notifier).clearLocalSession();
    } catch (_) {}
    if (!mounted) return;
    context.fsmGo('/login');
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

  /// Submit PIN reset to backend
  /// Calls POST /user/pin/reset { otp, newPinHash, stepUpChallengeToken }
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
      await _ensureRecoveryAuthorization();
      final dio = ref.read(dioProvider);
      final stepUpChallengeToken = _stepUpChallengeToken;

      if (stepUpChallengeToken == null) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorMessage =
              'We could not confirm this recovery decision. Please request a new code.';
        });
        _resetConfirmPin();
        return;
      }

      // Hash the new PIN for transmission (same method as PinService)
      // We need to call the backend reset endpoint with OTP + hashed PIN
      await dio.post(
        ApiEndpoints.userPinReset,
        data: {
          'otp': _otpController.text,
          'newPinHash': _hashPinForBackend(_newPin),
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

      if (!unlocked) {
        setState(() {
          _isLoading = false;
          _showError = true;
          _errorMessage = l10n.pin_error_resetFailed;
        });
        return;
      }

      setState(() => _isLoading = false);
      await _clearRecoveryAuthorization();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pin_success_reset),
          backgroundColor: context.colors.success,
        ),
      );
      context.fsmEnterAuthenticatedApp();
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

  Future<void> _ensureRecoveryAuthorization() async {
    final storage = ref.read(secureStorageProvider);
    final existingRecoveryToken = await storage.read(
      key: StorageKeys.recoveryAccessToken,
    );
    if (existingRecoveryToken != null && existingRecoveryToken.isNotEmpty) {
      return;
    }

    final routeToken = widget.initialContext?.recoveryAccessToken;
    if (routeToken != null && routeToken.isNotEmpty) {
      await storage.write(
        key: StorageKeys.recoveryAccessToken,
        value: routeToken,
      );
      return;
    }

    final pendingToken = ref.read(loginProvider).sessionToken;
    if (pendingToken != null && pendingToken.isNotEmpty) {
      await storage.write(
        key: StorageKeys.recoveryAccessToken,
        value: pendingToken,
      );
    }
  }

  Future<void> _clearRecoveryAuthorization() async {
    await ref
        .read(secureStorageProvider)
        .delete(key: StorageKeys.recoveryAccessToken);
  }

  bool _applyBackendManualReview(ApiException error) {
    final payload = _apiErrorPayload(error.data);
    final code =
        (error.code ?? payload['code']?.toString())?.toUpperCase() ?? '';
    final supportReviewRequired = payload['supportReviewRequired'] == true;

    if (code != 'E2007' && !supportReviewRequired) {
      return false;
    }

    setState(() {
      _applyManualReviewTicket({
        'id': payload['supportTicketId'] ?? payload['ticketId'],
        'status': payload['status'] ?? 'open',
        'reviewSla': payload['reviewSla'],
      });
      _isLoading = false;
      _showError = false;
      _errorMessage = null;
      _step = 6;
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
