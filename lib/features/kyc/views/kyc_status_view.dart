import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../../../design/components/primitives/app_card.dart';
import '../providers/kyc_provider.dart';
import '../models/kyc_status.dart';

class KycStatusView extends ConsumerStatefulWidget {
  const KycStatusView({super.key});

  @override
  ConsumerState<KycStatusView> createState() => _KycStatusViewState();
}

class _KycStatusViewState extends ConsumerState<KycStatusView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(kycProvider.notifier).loadStatus());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildContent(context, l10n, state),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    KycState state,
  ) {
    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: AppSpacing.xl),
                  _buildStatusIcon(state.status),
                  SizedBox(height: AppSpacing.lg),
                  AppText(
                    _getStatusTitle(l10n, state.status),
                    variant: AppTextVariant.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppText(
                    _getStatusDescription(l10n, state.status),
                    variant: AppTextVariant.bodyLarge,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  if (state.status.isRejected && state.rejectionReason != null)
                    ...[
                      SizedBox(height: AppSpacing.lg),
                      AppCard(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                l10n.kyc_rejectionReason,
                                variant: AppTextVariant.labelMedium,
                                color: AppColors.errorText,
                              ),
                              SizedBox(height: AppSpacing.sm),
                              AppText(
                                state.rejectionReason!,
                                variant: AppTextVariant.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  SizedBox(height: AppSpacing.xl),
                  _buildInfoCards(l10n),
                ],
              ),
            ),
          ),
          if (state.canStartVerification) ...[
            SizedBox(height: AppSpacing.md),
            AppButton(
              label: state.status.isRejected
                  ? l10n.kyc_tryAgain
                  : l10n.kyc_startVerification,
              onPressed: () => _handleStartVerification(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon(KycStatus status) {
    IconData icon;
    Color color;

    switch (status) {
      case KycStatus.pending:
      case KycStatus.additionalInfoNeeded:
        icon = Icons.verified_user_outlined;
        color = AppColors.gold500;
        break;
      case KycStatus.submitted:
        icon = Icons.hourglass_empty;
        color = AppColors.warningBase;
        break;
      case KycStatus.approved:
        icon = Icons.check_circle;
        color = AppColors.successBase;
        break;
      case KycStatus.rejected:
        icon = Icons.cancel;
        color = AppColors.errorBase;
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
      case KycStatus.pending:
        return l10n.kyc_status_pending_title;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_title;
      case KycStatus.approved:
        return l10n.kyc_status_approved_title;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_title;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_title;
    }
  }

  String _getStatusDescription(AppLocalizations l10n, KycStatus status) {
    switch (status) {
      case KycStatus.pending:
        return l10n.kyc_status_pending_description;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_description;
      case KycStatus.approved:
        return l10n.kyc_status_approved_description;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_description;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_description;
    }
  }

  Widget _buildInfoCards(AppLocalizations l10n) {
    return Column(
      children: [
        _buildInfoCard(
          Icons.security,
          l10n.kyc_info_security_title,
          l10n.kyc_info_security_description,
        ),
        SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          Icons.timer,
          l10n.kyc_info_time_title,
          l10n.kyc_info_time_description,
        ),
        SizedBox(height: AppSpacing.md),
        _buildInfoCard(
          Icons.document_scanner,
          l10n.kyc_info_documents_title,
          l10n.kyc_info_documents_description,
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String description) {
    return AppCard(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold500.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.gold500),
            ),
            SizedBox(width: AppSpacing.md),
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
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleStartVerification(BuildContext context) {
    ref.read(kycProvider.notifier).resetFlow();
    context.push('/kyc/document-type');
  }
}
