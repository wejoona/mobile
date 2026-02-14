import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';

/// Invite Sheet Bottom Sheet
///
/// Shows invite options for a non-JoonaPay contact
class InviteSheet extends ConsumerWidget {
  final SyncedContact contact;

  const InviteSheet({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              SizedBox(height: AppSpacing.lg),

              // Title
              AppText(
                l10n.contacts_invite_title(contact.name),
                variant: AppTextVariant.headlineSmall,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.sm),

              // Subtitle
              AppText(
                l10n.contacts_invite_subtitle,
                variant: AppTextVariant.bodyMedium,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),

              SizedBox(height: AppSpacing.xl),

              // Share via SMS
              _buildShareOption(
                context,
                l10n,
                icon: Icons.message,
                title: l10n.contacts_invite_via_sms,
                subtitle: l10n.contacts_invite_via_sms_desc,
                onTap: () => _shareViaSMS(context, contact),
              ),

              SizedBox(height: AppSpacing.sm),

              // Share via WhatsApp
              _buildShareOption(
                context,
                l10n,
                icon: Icons.chat,
                title: l10n.contacts_invite_via_whatsapp,
                subtitle: l10n.contacts_invite_via_whatsapp_desc,
                onTap: () => _shareViaWhatsApp(context, contact),
              ),

              SizedBox(height: AppSpacing.sm),

              // Copy link
              _buildShareOption(
                context,
                l10n,
                icon: Icons.link,
                title: l10n.contacts_invite_copy_link,
                subtitle: l10n.contacts_invite_copy_link_desc,
                onTap: () => _copyInviteLink(context),
              ),

              SizedBox(height: AppSpacing.md),

              // Cancel button
              AppButton(
                label: l10n.action_cancel,
                variant: AppButtonVariant.secondary,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShareOption(
    BuildContext context,
    AppLocalizations l10n, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: context.colors.elevated,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.colors.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  icon,
                  color: context.colors.gold,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      variant: AppTextVariant.bodyLarge,
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      subtitle,
                      variant: AppTextVariant.bodySmall,
                      color: context.colors.textSecondary,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: context.colors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _shareViaSMS(BuildContext context, SyncedContact contact) async {
    final l10n = AppLocalizations.of(context)!;
    final message = _getInviteMessage(l10n);
    final phone = contact.phone.replaceAll(RegExp(r'\D'), '');

    final uri = Uri(
      scheme: 'sms',
      path: phone,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _shareViaWhatsApp(
      BuildContext context, SyncedContact contact) async {
    final l10n = AppLocalizations.of(context)!;
    final message = _getInviteMessage(l10n);
    final phone = contact.phone.replaceAll(RegExp(r'\D'), '');

    final uri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (context.mounted) Navigator.pop(context);
    }
  }

  Future<void> _copyInviteLink(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final message = _getInviteMessage(l10n);

    await Share.share(message);

    if (context.mounted) Navigator.pop(context);
  }

  String _getInviteMessage(AppLocalizations l10n) {
    return l10n.contacts_invite_message;
  }
}
