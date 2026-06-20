import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Écran de vérification de présence (liveness) — défi caméra uniquement.
/// Les instructions sont affichées sur un écran séparé (KycLivenessInstructionsView)
/// avant la navigation vers cet écran.
class KycLivenessView extends ConsumerStatefulWidget {
  const KycLivenessView({super.key});

  @override
  ConsumerState<KycLivenessView> createState() => _KycLivenessViewState();
}

class _KycLivenessViewState extends ConsumerState<KycLivenessView> {
  bool _isComplete = false;
  bool _hasFailed = false;
  bool _isCreatingManualReview = false;
  String? _errorMessage;
  String? _manualReviewKycReviewId;
  String? _manualReviewSlaLabel;
  Timer? _navigationTimer;

  LivenessDecision? _decision;

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _onLivenessComplete(LivenessResult result) {
    debugPrint(
      '[KYC Liveness] Complete: isLive=${result.isLive}, confidence=${result.confidence}, decision=${result.decision}',
    );

    final decision = result.decision;
    _decision = decision;
    _navigationTimer?.cancel();

    switch (decision) {
      case LivenessDecision.autoApprove:
        // High score — auto-approve, proceed to review
        setState(() => _isComplete = true);
        _navigationTimer = Timer(const Duration(seconds: 2), () {
          if (mounted) {
            context.fsmGo('/kyc/review');
          }
        });

      case LivenessDecision.manualReview:
        unawaited(
          _routeKycToManualReview(
            LivenessManualReviewRequest(
              reason: 'liveness_manual_review_confidence',
              message:
                  'Automated liveness verification needs manual review. '
                  'Confidence: ${result.confidence.toStringAsFixed(2)}. '
                  'Flow: kyc_liveness.',
            ),
          ),
        );

      case LivenessDecision.decline:
        // Low score — decline, allow retry
        setState(() {
          _hasFailed = true;
          _errorMessage =
              result.failureReason ??
              AppLocalizations.of(context)!.liveness_failed;
        });
    }
  }

  void _onCancel() {
    // Go back to selfie capture
    context.fsmPop();
  }

  void _retry() {
    _navigationTimer?.cancel();
    setState(() {
      _hasFailed = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // Afficher le widget de vérification de présence (les instructions sont sur un écran séparé)
    if (!_isComplete && !_hasFailed) {
      return LivenessCheckWidget(
        onComplete: _onLivenessComplete,
        onManualReviewRequired: _routeKycToManualReview,
        onManualReviewAcknowledged: _acknowledgeManualReview,
        onCancel: _onCancel,
      );
    }

    // Show failure screen with retry
    if (_hasFailed) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _onCancel,
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.face_retouching_off, size: 80, color: colors.error),
                const SizedBox(height: AppSpacing.xxl),
                AppText(
                  l10n.liveness_verificationFailed,
                  variant: AppTextVariant.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  _errorMessage ?? l10n.liveness_tryAgain,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: l10n.liveness_tryAgain,
                  onPressed: _retry,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.liveness_goBack,
                  variant: AppButtonVariant.secondary,
                  onPressed: _onCancel,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Success - auto-navigating based on decision
    final isManualReview = _decision == LivenessDecision.manualReview;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isCreatingManualReview
                    ? Icons.support_agent
                    : isManualReview
                    ? Icons.hourglass_top
                    : Icons.check_circle,
                size: 80,
                color: isManualReview || _isCreatingManualReview
                    ? colors.warning
                    : colors.success,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                isManualReview
                    ? l10n.liveness_verificationInProgress
                    : l10n.liveness_identityVerified,
                variant: AppTextVariant.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                isManualReview
                    ? _manualReviewKycReviewId == null
                          ? l10n.liveness_manualReviewMessage
                          : '${l10n.liveness_manualReviewMessage}\nReference $_manualReviewKycReviewId'
                    : l10n.liveness_proceedingToVerification,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              if (isManualReview && _manualReviewSlaLabel != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppText(
                  _manualReviewSlaLabel!,
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),
              CircularProgressIndicator(color: colors.gold),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _routeKycToManualReview(
    LivenessManualReviewRequest request,
  ) async {
    if (!mounted || _isCreatingManualReview) {
      return;
    }

    setState(() {
      _isCreatingManualReview = true;
      _isComplete = true;
      _hasFailed = false;
      _decision = LivenessDecision.manualReview;
      _errorMessage = null;
      _manualReviewKycReviewId = request.backendReviewId;
      _manualReviewSlaLabel = request.slaLabel;
    });

    if (request.backendReviewAlreadyCreated) {
      await _refreshKycManualReviewState();
      if (!mounted) {
        return;
      }
      setState(() => _isCreatingManualReview = false);
      _scheduleManualReviewNavigation();
      return;
    }

    try {
      await _submitKycEvidenceForManualReview();

      final review = await ref
          .read(kycServiceProvider)
          .routeToManualReview(
            reason: request.reason,
            featureReason: request.reason,
            metadata: {
              'flow': 'kyc_liveness',
              'message': request.message,
              'evidenceGraph': [
                'identity_document',
                'profile_photo',
                'reference_selfie',
                'liveness_evidence',
              ],
            },
          );
      await _refreshKycManualReviewState();

      if (!mounted) {
        return;
      }
      setState(() {
        _decision = review.status.isVerified
            ? LivenessDecision.autoApprove
            : LivenessDecision.manualReview;
        _manualReviewKycReviewId = review.id;
        _manualReviewSlaLabel = review.slaLabel ?? _manualReviewSlaLabel;
        _isCreatingManualReview = false;
      });
      _scheduleManualReviewNavigation();
    } on DioException catch (error) {
      if (!mounted) {
        return;
      }
      final apiError = ApiException.fromDioError(error);
      setState(() {
        _isCreatingManualReview = false;
        _isComplete = false;
        _hasFailed = true;
        _decision = null;
        _errorMessage =
            'We could not securely create your manual review. ${apiError.message}';
      });
    } on Object catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isCreatingManualReview = false;
        _isComplete = false;
        _hasFailed = true;
        _decision = null;
        _errorMessage =
            'We could not securely create your manual review. Please try again.';
      });
    }
  }

  Future<void> _submitKycEvidenceForManualReview() async {
    await ref.read(kycProvider.notifier).submitKyc();
    final flowState = ref.read(kycProvider);
    if (flowState.error?.isNotEmpty ?? false) {
      throw StateError(flowState.error!);
    }
  }

  Future<void> _refreshKycManualReviewState() async {
    try {
      ref.invalidate(kycProfileProvider);
      await ref.read(kycProvider.notifier).loadVerificationStatus();
    } on Object catch (_) {
      ref.invalidate(kycProfileProvider);
    }
  }

  void _scheduleManualReviewNavigation() {
    _navigationTimer?.cancel();
    _navigationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.fsmGo('/kyc/submitted');
      }
    });
  }

  void _acknowledgeManualReview() {
    if (!mounted) {
      return;
    }
    _navigationTimer?.cancel();
    setState(() {
      _isCreatingManualReview = false;
      _isComplete = true;
      _decision = LivenessDecision.manualReview;
    });
    if (_manualReviewKycReviewId == null) {
      setState(() {
        _isComplete = false;
        _hasFailed = true;
        _errorMessage =
            'Manual review was not confirmed. Please retry so Korido can create a secure review record.';
      });
      return;
    }
    setState(() {
      _hasFailed = false;
      _errorMessage = null;
    });
    _navigationTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        context.fsmGo('/kyc/submitted');
      }
    });
  }
}
