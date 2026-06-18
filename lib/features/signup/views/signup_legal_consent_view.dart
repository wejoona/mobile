import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/views/legal_document_view.dart';
import 'package:usdc_wallet/features/auth/widgets/auth_screen_chrome.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/legal/legal_documents_service.dart';

/// Explicit signup consent step.
///
/// Phone capture stays free of legal acceptance UI. This screen owns consent,
/// records the accepted document versions, then submits registration to send OTP.
class SignupLegalConsentView extends ConsumerStatefulWidget {
  const SignupLegalConsentView({super.key});

  @override
  ConsumerState<SignupLegalConsentView> createState() =>
      _SignupLegalConsentViewState();
}

class _SignupLegalConsentViewState
    extends ConsumerState<SignupLegalConsentView> {
  bool _termsRead = false;
  bool _privacyRead = false;
  bool _isSubmitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(signupFlowProvider);
    final termsAsync = ref.watch(termsOfServiceProvider);
    final privacyAsync = ref.watch(privacyPolicyProvider);
    final canAccept =
        _termsRead &&
        _privacyRead &&
        state.phoneNumber != null &&
        !_isSubmitting &&
        !state.isLoading;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            const SizedBox(height: AppSpacing.giant),
            AuthScreenHeader(
              appName: l10n.appName,
              title: AppStrings.legalAgreements,
              subtitle: AppStrings.reviewTermsPrompt,
              markSize: 52,
            ),
            const SizedBox(height: AppSpacing.xxl),
            _DocumentConsentTile(
              title: AppStrings.termsOfService,
              version: termsAsync.maybeWhen(
                data: (doc) => 'v${doc.version}',
                orElse: () => null,
              ),
              isRead: _termsRead,
              onTap: () => _openDocument(LegalDocumentType.termsOfService),
            ),
            const SizedBox(height: AppSpacing.md),
            _DocumentConsentTile(
              title: AppStrings.privacyPolicy,
              version: privacyAsync.maybeWhen(
                data: (doc) => 'v${doc.version}',
                orElse: () => null,
              ),
              isRead: _privacyRead,
              onTap: () => _openDocument(LegalDocumentType.privacyPolicy),
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: colors.gold,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: AppText(
                      AppStrings.acceptTermsDisclaimer,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (_error != null || state.error != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colors.errorBg,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(color: colors.error),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: colors.errorText),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppText(
                        _error ?? state.error!,
                        variant: AppTextVariant.bodySmall,
                        color: colors.errorText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: MediaQuery.sizeOf(context).height * 0.18),
            AppButton(
              label: AppStrings.acceptAndContinue,
              onPressed: canAccept ? _handleAcceptAndSubmit : null,
              isLoading: _isSubmitting || state.isLoading,
              isFullWidth: true,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: _isSubmitting || state.isLoading
                    ? null
                    : () => context.go('/signup'),
                child: AppText(
                  'Use a different phone number',
                  color: colors.gold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDocument(LegalDocumentType type) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LegalDocumentView(documentType: type),
      ),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      if (type == LegalDocumentType.termsOfService) {
        _termsRead = true;
      } else {
        _privacyRead = true;
      }
      _error = null;
    });
  }

  Future<void> _handleAcceptAndSubmit() async {
    final state = ref.read(signupFlowProvider);
    if (state.phoneNumber == null) {
      context.go('/signup');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final service = ref.read(legalDocumentsServiceProvider);
      final terms = await ref.read(termsOfServiceProvider.future);
      final privacy = await ref.read(privacyPolicyProvider.future);
      await service.recordAllConsents(terms: terms, privacy: privacy);
      await ref
          .read(signupFlowProvider.notifier)
          .submitPhoneNumber(acceptedTerms: true);

      if (!mounted) {
        return;
      }
      if (ref.read(signupFlowProvider).error == null) {
        context.go('/signup/verify-phone');
      }
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _DocumentConsentTile extends StatelessWidget {
  const _DocumentConsentTile({
    required String title,
    required String? version,
    required bool isRead,
    required VoidCallback onTap,
  }) : _title = title,
       _version = version,
       _isRead = isRead,
       _onTap = onTap;

  final String _title;
  final String? _version;
  final bool _isRead;
  final VoidCallback _onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = _isRead ? colors.successText : colors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: _isRead
                  ? colors.success.withValues(alpha: 0.45)
                  : colors.borderSubtle,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _isRead
                      ? colors.success.withValues(alpha: 0.14)
                      : colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _isRead ? Icons.check_rounded : Icons.article_outlined,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      _title,
                      variant: AppTextVariant.bodyLarge,
                      color: colors.textPrimary,
                    ),
                    if (_version != null && _version.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      AppText(
                        _version,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                _isRead ? Icons.check_circle_rounded : Icons.chevron_right,
                color: statusColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
