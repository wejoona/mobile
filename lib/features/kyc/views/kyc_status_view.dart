import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/theme_colors.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_card.dart';
import '../providers/kyc_provider.dart';
import '../models/kyc_status.dart';
import '../../../services/kyc/kyc_service.dart';
import '../../../state/fsm/fsm_provider.dart';
import '../../../state/fsm/kyc_fsm.dart' as fsm;

class KycStatusView extends ConsumerStatefulWidget {
  const KycStatusView({super.key});

  @override
  ConsumerState<KycStatusView> createState() => _KycStatusViewState();
}

class _KycStatusViewState extends ConsumerState<KycStatusView> {
  @override
  void initState() {
    super.initState();
    // Load real verification status from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kycProvider.notifier).loadVerificationStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        // Always show content - don't block on loading for initial view
        child: _buildContent(context, l10n, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    KycState state,
  ) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.xxl),
                  _buildStatusIcon(context, state.status),
                  SizedBox(height: AppSpacing.xxl),
                  AppText(
                    _getStatusTitle(l10n, state.status),
                    variant: AppTextVariant.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.lg),
                  AppText(
                    _getStatusDescription(l10n, state.status),
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  if (state.status.isRejected && state.rejectionReason != null)
                    ...[
                      SizedBox(height: AppSpacing.xxl),
                      AppCard(
                        variant: AppCardVariant.elevated,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              l10n.kyc_rejectionReason,
                              variant: AppTextVariant.labelMedium,
                              color: colors.errorText,
                            ),
                            SizedBox(height: AppSpacing.sm),
                            AppText(
                              state.rejectionReason!,
                              variant: AppTextVariant.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  // Verification details when available
                  if (state.verificationStatus?.verification != null) ...[
                    SizedBox(height: AppSpacing.xxl),
                    _buildVerificationDetails(state.verificationStatus!.verification!, colors),
                  ],
                  SizedBox(height: AppSpacing.xxl),
                  _buildInfoCards(l10n),
                ],
              ),
            ),
          ),
          if (state.canStartVerification) ...[
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: state.status.isRejected
                  ? l10n.kyc_tryAgain
                  : l10n.kyc_startVerification,
              onPressed: () => _handleStartVerification(context),
              isFullWidth: true,
            ),
          ],
          if (state.status == KycStatus.submitted) ...[
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.common_continue,
              onPressed: () => _handleContinueToHome(context),
              isFullWidth: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, KycStatus status) {
    final colors = context.colors;
    IconData icon;
    Color color;

    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
      case KycStatus.additionalInfoNeeded:
        icon = Icons.verified_user_outlined;
        color = colors.gold;
        break;
      case KycStatus.submitted:
        icon = Icons.hourglass_empty;
        color = colors.warning;
        break;
      case KycStatus.verified:
        icon = Icons.check_circle;
        color = colors.success;
        break;
      case KycStatus.rejected:
        icon = Icons.cancel;
        color = colors.error;
        break;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.1),
      ),
      child: Icon(
        icon,
        size: 64,
        color: color,
      ),
    );
  }

  String _getStatusTitle(AppLocalizations l10n, KycStatus status) {
    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return l10n.kyc_status_pending_title;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_title;
      case KycStatus.verified:
        return l10n.kyc_status_approved_title;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_title;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_title;
    }
  }

  String _getStatusDescription(AppLocalizations l10n, KycStatus status) {
    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return l10n.kyc_status_pending_description;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_description;
      case KycStatus.verified:
        return l10n.kyc_status_approved_description;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_description;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_description;
    }
  }

  Widget _buildVerificationDetails(VerifyHqStatus verification, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            'Verification Details',
            variant: AppTextVariant.titleMedium,
            color: colors.gold,
          ),
          SizedBox(height: AppSpacing.lg),
          if (verification.overallStatus != null)
            _buildDetailRow('Overall', verification.overallStatus!, colors),
          if (verification.livenessCheckId != null)
            _buildDetailRow('Liveness', 'Completed', colors),
          if (verification.documentVerificationId != null)
            _buildDetailRow('Document', 'Submitted', colors),
          if (verification.faceMatchScore != null)
            _buildDetailRow(
              'Face Match',
              '${(verification.faceMatchScore! * 100).toStringAsFixed(0)}%',
              colors,
            ),
          if (verification.tier != null)
            _buildDetailRow('Tier', verification.tier!, colors),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(label, variant: AppTextVariant.bodyMedium, color: colors.textSecondary),
          AppText(value, variant: AppTextVariant.labelMedium),
        ],
      ),
    );
  }

  Widget _buildInfoCards(AppLocalizations l10n) {
    return Column(
      children: [
        _buildInfoCard(
          Icons.security,
          l10n.kyc_info_security_title,
          l10n.kyc_info_security_description,
        ),
        SizedBox(height: AppSpacing.lg),
        _buildInfoCard(
          Icons.timer,
          l10n.kyc_info_time_title,
          l10n.kyc_info_time_description,
        ),
        SizedBox(height: AppSpacing.lg),
        _buildInfoCard(
          Icons.document_scanner,
          l10n.kyc_info_documents_title,
          l10n.kyc_info_documents_description,
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.gold),
          ),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.labelLarge,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  description,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleStartVerification(BuildContext context) {
    debugPrint('[KYC] v4 - Start Verification tapped');
    ref.read(kycProvider.notifier).resetFlow();
    debugPrint('[KYC] v4 - Navigating to /kyc/document-type');
    context.push('/kyc/document-type');
    debugPrint('[KYC] v4 - Navigation called');
  }

  void _handleContinueToHome(BuildContext context) {
    // Sync FSM state to allow navigation to home
    // KYC is submitted (pending review), so user can proceed
    ref.read(appFsmProvider.notifier).onKycStatusLoaded(
      tier: fsm.KycTier.none,
      status: 'pending',
    );
    context.go('/home');
  }
}
