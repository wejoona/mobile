import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/utils/kyc_return_route.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';

class KycStatusView extends ConsumerStatefulWidget {
  const KycStatusView({super.key, this.intent, this.returnTo});

  final String? intent;
  final String? returnTo;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty('intent', intent))
      ..add(StringProperty('returnTo', returnTo));
  }

  @override
  ConsumerState<KycStatusView> createState() => _KycStatusViewState();
}

class _KycStatusViewState extends ConsumerState<KycStatusView> {
  bool get _isDepositIntent => widget.intent == 'deposit';

  bool get _hasReturnTo => _safeReturnTo() != null;

  @override
  void initState() {
    super.initState();
    // Load real verification status from backend
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(ref.read(kycProvider.notifier).loadVerificationStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);
    final durableState = ref.watch(kycStateMachineProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(child: _buildContent(context, l10n, state, durableState)),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    KycFlowState state,
    KycStateMachineState durableState,
  ) {
    final colors = context.colors;
    final status = state.verificationStatus ?? durableState.status;
    final hasAuthoritativeStatus =
        state.verificationStatus != null ||
        durableState.status.isNone ||
        durableState.status.isSubmitted ||
        durableState.status.isVerified ||
        durableState.status.isRejected ||
        durableState.status.needsAdditionalInfo;
    final shouldWaitForBackend =
        !hasAuthoritativeStatus &&
        state.error == null &&
        durableState.error == null;
    final canStartVerification =
        hasAuthoritativeStatus &&
        !state.isLoading &&
        !durableState.isLoading &&
        status.canSubmit;
    final canContinueToReturn = status.isVerified && _hasReturnTo;

    if ((state.isLoading && state.verificationStatus == null) ||
        shouldWaitForBackend) {
      return _buildStatusLoading(context, l10n);
    }

    if (!hasAuthoritativeStatus &&
        (state.error != null || durableState.error != null)) {
      return _buildStatusError(context, l10n);
    }

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  _buildStatusIcon(context, status),
                  const SizedBox(height: AppSpacing.xxl),
                  AppText(
                    _getStatusTitle(context, l10n, status),
                    variant: AppTextVariant.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppText(
                    _getStatusDescription(context, l10n, status),
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  if (status.isRejected && state.rejectionReason != null) ...[
                    const SizedBox(height: AppSpacing.xxl),
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
                          const SizedBox(height: AppSpacing.sm),
                          AppText(state.rejectionReason!),
                        ],
                      ),
                    ),
                  ],
                  // Verification details placeholder
                  const SizedBox(height: AppSpacing.xxl),
                  _buildInfoCards(l10n, status),
                ],
              ),
            ),
          ),
          if (canContinueToReturn) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _isDepositIntent
                  ? _localizedText(
                      context,
                      en: 'Continue deposit',
                      fr: 'Continuer le dépôt',
                    )
                  : l10n.common_continue,
              onPressed: () => _handleContinueToReturn(context),
              isFullWidth: true,
            ),
          ],
          if (canStartVerification) ...[
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: _verificationButtonLabel(context, l10n, status),
              onPressed: () => unawaited(_handleStartVerification(context)),
              isFullWidth: true,
            ),
          ],
          if (status.isInReview && !canContinueToReturn) ...[
            const SizedBox(height: AppSpacing.lg),
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

  String _verificationButtonLabel(
    BuildContext context,
    AppLocalizations l10n,
    KycStatus status,
  ) {
    if (status.isRejected) {
      return l10n.kyc_tryAgain;
    }

    if (_isDepositIntent) {
      return _localizedText(
        context,
        en: 'Verify to deposit',
        fr: 'Vérifier pour déposer',
      );
    }

    return l10n.kyc_startVerification;
  }

  Widget _buildStatusLoading(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: colors.gold),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.common_loading,
              variant: AppTextVariant.bodyLarge,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusError(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            variant: AppCardVariant.subtle,
            child: Column(
              children: [
                Icon(Icons.sync_problem, color: colors.error, size: 48),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  l10n.error_tryAgainLater,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.common_retry,
            onPressed: () => unawaited(_refreshStatus()),
            isFullWidth: true,
          ),
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
      case KycStatus.manualReview:
        icon = Icons.manage_accounts_outlined;
        color = colors.info;
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
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(icon, size: 64, color: color),
    );
  }

  String _getStatusTitle(
    BuildContext context,
    AppLocalizations l10n,
    KycStatus status,
  ) {
    if (_isDepositIntent) {
      switch (status) {
        case KycStatus.none:
        case KycStatus.pending:
        case KycStatus.documentsPending:
        case KycStatus.additionalInfoNeeded:
          return _localizedText(
            context,
            en: 'Verify to deposit',
            fr: 'Vérifiez pour déposer',
          );
        case KycStatus.verified:
          return _localizedText(
            context,
            en: 'Ready to deposit',
            fr: 'Prêt pour le dépôt',
          );
        case KycStatus.submitted:
        case KycStatus.manualReview:
        case KycStatus.rejected:
          break;
      }
    }

    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return l10n.kyc_status_pending_title;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_title;
      case KycStatus.manualReview:
        return l10n.kyc_status_manualReview_title;
      case KycStatus.verified:
        return l10n.kyc_status_approved_title;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_title;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_title;
    }
  }

  String _getStatusDescription(
    BuildContext context,
    AppLocalizations l10n,
    KycStatus status,
  ) {
    if (_isDepositIntent) {
      switch (status) {
        case KycStatus.none:
        case KycStatus.pending:
        case KycStatus.documentsPending:
        case KycStatus.additionalInfoNeeded:
          return _localizedText(
            context,
            en: 'Complete identity verification once, then continue your deposit.',
            fr: 'Complétez votre vérification une fois, puis continuez votre dépôt.',
          );
        case KycStatus.verified:
          return _localizedText(
            context,
            en: 'Your account is verified. Continue to choose your deposit method.',
            fr: 'Votre compte est vérifié. Continuez pour choisir votre méthode de dépôt.',
          );
        case KycStatus.submitted:
        case KycStatus.manualReview:
        case KycStatus.rejected:
          break;
      }
    }

    switch (status) {
      case KycStatus.none:
      case KycStatus.pending:
      case KycStatus.documentsPending:
        return l10n.kyc_status_pending_description;
      case KycStatus.submitted:
        return l10n.kyc_status_submitted_description;
      case KycStatus.manualReview:
        return l10n.kyc_status_manualReview_description;
      case KycStatus.verified:
        return l10n.kyc_status_approved_description;
      case KycStatus.rejected:
        return l10n.kyc_status_rejected_description;
      case KycStatus.additionalInfoNeeded:
        return l10n.kyc_status_additionalInfo_description;
    }
  }

  Widget _buildInfoCards(AppLocalizations l10n, KycStatus status) => Column(
    children: [
      _buildInfoCard(
        Icons.security,
        l10n.kyc_info_security_title,
        l10n.kyc_info_security_description,
      ),
      const SizedBox(height: AppSpacing.lg),
      if (status.isManualReview) ...[
        _buildInfoCard(
          Icons.manage_accounts_outlined,
          l10n.kyc_info_manualReview_title,
          l10n.kyc_info_manualReview_description,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
      _buildInfoCard(
        Icons.timer,
        l10n.kyc_info_time_title,
        l10n.kyc_info_time_description,
      ),
      const SizedBox(height: AppSpacing.lg),
      _buildInfoCard(
        Icons.document_scanner,
        l10n.kyc_info_documents_title,
        l10n.kyc_info_documents_description,
      ),
    ],
  );

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
              color: colors.gold.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: colors.gold),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(title, variant: AppTextVariant.labelLarge),
                const SizedBox(height: AppSpacing.xs),
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

  Future<void> _handleStartVerification(BuildContext context) async {
    await _refreshStatus();
    if (!context.mounted) {
      return;
    }

    final latestFlowStatus = ref.read(kycProvider).verificationStatus;
    final latestDurableStatus = ref.read(kycStateMachineProvider).status;
    final status = latestFlowStatus ?? latestDurableStatus;

    if (!status.canSubmit) {
      if (status.isVerified && _hasReturnTo) {
        _handleContinueToReturn(context);
        return;
      }
      if (status.isInReview) {
        context.fsmGo('/kyc/submitted');
      }
      return;
    }

    ref
        .read(kycProvider.notifier)
        .startFlowForIntent(intent: widget.intent, returnTo: _safeReturnTo());
    unawaited(context.fsmPush('/kyc/document-type'));
  }

  Future<void> _refreshStatus() async {
    ref.invalidate(kycProfileProvider);
    await ref.read(kycProvider.notifier).loadVerificationStatus();
  }

  void _handleContinueToHome(BuildContext context) {
    context.fsmGo('/home');
  }

  void _handleContinueToReturn(BuildContext context) {
    final returnTo = _safeReturnTo();
    if (returnTo == null || returnTo.isEmpty) {
      _handleContinueToHome(context);
      return;
    }

    context.fsmGo(returnTo);
  }

  String? _safeReturnTo() {
    final returnTo = widget.returnTo?.trim();
    if (returnTo == null || !returnTo.startsWith('/')) {
      return null;
    }
    return safeKycReturnRoute(raw: returnTo, intent: widget.intent);
  }

  String _localizedText(
    BuildContext context, {
    required String en,
    required String fr,
  }) => Localizations.localeOf(context).languageCode == 'fr' ? fr : en;
}
