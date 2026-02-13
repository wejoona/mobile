import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_instruction_screen.dart';

/// KYC Liveness verification step
/// Uses the reusable LivenessCheckWidget for face verification
class KycLivenessView extends ConsumerStatefulWidget {
  const KycLivenessView({super.key});

  @override
  ConsumerState<KycLivenessView> createState() => _KycLivenessViewState();
}

class _KycLivenessViewState extends ConsumerState<KycLivenessView> {
  bool _showInstructions = true;
  bool _isComplete = false;
  bool _hasFailed = false;
  String? _errorMessage;

  LivenessDecision? _decision;

  void _onLivenessComplete(LivenessResult result) {
    debugPrint('[KYC Liveness] Complete: isLive=${result.isLive}, confidence=${result.confidence}, decision=${result.decision}');

    final decision = result.decision;
    _decision = decision;

    switch (decision) {
      case LivenessDecision.autoApprove:
        // High score — auto-approve, proceed to review
        setState(() => _isComplete = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/kyc/review');
        });

      case LivenessDecision.manualReview:
        // Medium score — submit for manual review, show pending screen
        setState(() => _isComplete = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) context.go('/kyc/submitted');
        });

      case LivenessDecision.decline:
        // Low score — decline, allow retry
        setState(() {
          _hasFailed = true;
          _errorMessage = result.failureReason ?? 'La vérification a échoué. Veuillez réessayer.';
        });
    }
  }

  void _onLivenessError(String error) {
    debugPrint('[KYC Liveness] Error: $error');
    setState(() {
      _hasFailed = true;
      _errorMessage = error;
    });
  }

  void _onCancel() {
    // Go back to selfie capture
    context.pop();
  }

  void _retry() {
    setState(() {
      _showInstructions = true;
      _hasFailed = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // Show instruction screen first
    if (_showInstructions) {
      return KycInstructionScreen(
        title: 'Liveness Check',
        description: 'We need to verify you\'re a real person by checking your live presence.',
        icon: Icons.videocam_outlined,
        instructions: KycInstructions.liveness,
        buttonLabel: l10n.common_continue,
        onContinue: () => setState(() => _showInstructions = false),
        onBack: _onCancel,
      );
    }

    // Show liveness check widget
    if (!_isComplete && !_hasFailed) {
      return LivenessCheckWidget(
        onComplete: _onLivenessComplete,
        onCancel: _onCancel,
      );
    }

    // Show failure screen with retry
    if (_hasFailed) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(
            l10n.kyc_title,
            variant: AppTextVariant.headlineSmall,
          ),
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
                Icon(
                  Icons.face_retouching_off,
                  size: 80,
                  color: colors.error,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppText(
                  'Liveness Check Failed',
                  variant: AppTextVariant.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  _errorMessage ?? 'Please try again',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Try Again',
                  onPressed: _retry,
                  isFullWidth: true,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Go Back',
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
                isManualReview ? Icons.hourglass_top : Icons.check_circle,
                size: 80,
                color: isManualReview ? colors.warning : colors.success,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                isManualReview
                    ? 'Vérification en cours'
                    : 'Identité vérifiée',
                variant: AppTextVariant.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                isManualReview
                    ? 'Votre vérification sera examinée manuellement...'
                    : 'Passage à la vérification...',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),
              CircularProgressIndicator(color: colors.gold),
            ],
          ),
        ),
      ),
    );
  }
}
