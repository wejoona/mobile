import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Account deletion view — backend endpoint not yet implemented.
/// Shows "Contact support" flow instead of a broken delete button.
class DeleteAccountView extends ConsumerWidget {
  const DeleteAccountView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.delete_accountTitle,
          style: AppTextStyle.headingSmall,
        ),
        backgroundColor: context.colors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AlertBanner(
            message: l10n.delete_warningMessage,
            type: AlertVariant.error,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            l10n.delete_consequencesTitle,
            style: AppTextStyle.labelLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          _ConsequenceItem(
            text: l10n.delete_consequenceBalance,
            icon: Icons.account_balance_wallet_outlined,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceHistory,
            icon: Icons.history,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceIrreversible,
            icon: Icons.no_accounts,
          ),
          _ConsequenceItem(
            text: l10n.delete_consequenceKyc,
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Contact support instead of broken delete
          Icon(Icons.support_agent, size: 48, color: context.colors.gold),
          const SizedBox(height: AppSpacing.md),
          AppText(
            l10n.delete_contactSupportTitle,
            style: AppTextStyle.headingSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.delete_contactSupportDescription,
            style: AppTextStyle.bodySmall,
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppButton(
            label: l10n.delete_contactSupportButton,
            variant: AppButtonVariant.primary,
            onPressed: () async {
              final uri = Uri.parse('mailto:support@joonapay.com?subject=Account%20Deletion%20Request');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: l10n.common_cancel,
            variant: AppButtonVariant.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _ConsequenceItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const _ConsequenceItem({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: context.colors.error, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              text,
              style: AppTextStyle.bodyMedium,
              color: context.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
