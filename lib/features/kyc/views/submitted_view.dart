import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_status.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/utils/kyc_return_route.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';

class SubmittedView extends ConsumerStatefulWidget {
  const SubmittedView({super.key, this.intent, this.returnTo});

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
  ConsumerState<SubmittedView> createState() => _SubmittedViewState();
}

class _SubmittedViewState extends ConsumerState<SubmittedView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(kycProfileProvider);
      unawaited(ref.read(kycProvider.notifier).loadVerificationStatus());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final durableStatus = ref.watch(kycStateMachineProvider).status;
    final flow = ref.watch(kycProvider);
    final wizardStatus = flow.verificationStatus;
    final status = wizardStatus ?? durableStatus;
    final isManualReview =
        durableStatus == KycStatus.manualReview ||
        wizardStatus == KycStatus.manualReview;
    final isVerified = status.isVerified;
    final returnTo = isVerified ? _safeReturnTo(flow) : null;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildStatusAnimation(
                context,
                isManualReview: isManualReview,
                isVerified: isVerified,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                isVerified
                    ? l10n.kyc_status_approved_title
                    : isManualReview
                    ? l10n.kyc_status_manualReview_title
                    : l10n.kyc_submitted_title,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppText(
                  isVerified
                      ? l10n.kyc_status_approved_description
                      : isManualReview
                      ? l10n.kyc_status_manualReview_description
                      : l10n.kyc_submitted_description,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: colors.info.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isVerified
                          ? Icons.check_circle
                          : isManualReview
                          ? Icons.manage_accounts_outlined
                          : Icons.access_time,
                      color: isVerified ? colors.successText : colors.infoText,
                      size: 28,
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: AppText(
                        isVerified
                            ? l10n.kyc_status_approved_description
                            : isManualReview
                            ? l10n.kyc_info_manualReview_description
                            : l10n.kyc_submitted_timeEstimate,
                        variant: AppTextVariant.bodyLarge,
                        color: isVerified
                            ? colors.successText
                            : colors.infoText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: isVerified && returnTo != null
                    ? _continueLabel(context, l10n, flow)
                    : l10n.common_done,
                onPressed: () => _handleDone(context, returnTo),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDone(BuildContext context, String? returnTo) {
    if (returnTo != null) {
      context.fsmGo(returnTo);
      return;
    }

    context.fsmGo('/home');
  }

  String? _safeReturnTo(KycFlowState flow) {
    final candidate = (widget.returnTo?.trim().isNotEmpty ?? false)
        ? widget.returnTo!.trim()
        : flow.returnTo?.trim();
    if (candidate == null || !candidate.startsWith('/')) {
      return null;
    }
    return safeKycReturnRoute(
      raw: candidate,
      intent: widget.intent ?? flow.returnIntent,
    );
  }

  String _continueLabel(
    BuildContext context,
    AppLocalizations l10n,
    KycFlowState flow,
  ) {
    final intent = widget.intent ?? flow.returnIntent;
    if (intent == 'deposit') {
      return Localizations.localeOf(context).languageCode == 'fr'
          ? 'Continuer le dépôt'
          : 'Continue deposit';
    }
    return l10n.common_continue;
  }

  Widget _buildStatusAnimation(
    BuildContext context, {
    required bool isManualReview,
    required bool isVerified,
  }) {
    final colors = context.colors;
    final color = isVerified
        ? colors.success
        : isManualReview
        ? colors.gold
        : colors.info;
    final icon = isVerified
        ? Icons.check_circle
        : isManualReview
        ? Icons.manage_accounts_outlined
        : Icons.access_time;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) => Transform.scale(
        scale: value,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.1),
          ),
          child: Icon(icon, size: 64, color: color),
        ),
      ),
    );
  }
}
