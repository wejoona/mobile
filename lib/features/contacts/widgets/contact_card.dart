import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';

/// Contact Card Widget
///
/// Displays a contact with Korido status and action buttons
class ContactCard extends StatelessWidget {
  final SyncedContact contact;
  final VoidCallback? onTap;
  final VoidCallback? onSend;
  final VoidCallback? onInvite;

  const ContactCard({
    required this.contact,
    super.key,
    this.onTap,
    this.onSend,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: contact.isKoridoUser
              ? colors.gold.withValues(alpha: colors.isDark ? 0.34 : 0.24)
              : colors.borderSubtle,
        ),
        boxShadow: colors.isDark ? null : AppShadows.lightCard,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(colors),

                SizedBox(width: AppSpacing.md),

                // Name and phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: AppText(
                              contact.name,
                              variant: AppTextVariant.bodyLarge,
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isKoridoUser) ...[
                            SizedBox(width: AppSpacing.xs),
                            const KoridoAccountBadge(),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        contact.phone,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppSpacing.sm),

                // Action button
                if (contact.isKoridoUser && onSend != null)
                  _buildSendButton(onSend!, colors)
                else if (!contact.isKoridoUser && onInvite != null)
                  _buildInviteButton(onInvite!, colors),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeColors colors) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        UserAvatar(
          imageUrl: contact.avatarUrl,
          firstName: contact.name.split(' ').first,
          lastName: contact.name.split(' ').length > 1
              ? contact.name.split(' ').last
              : null,
          size: UserAvatar.sizeMedium,
          showBorder: contact.isKoridoUser,
          borderColor: colors.gold,
        ),
        if (contact.isKoridoUser)
          const Positioned(
            right: -2,
            bottom: -2,
            child: KoridoAccountBadge(compact: true),
          ),
      ],
    );
  }

  Widget _buildSendButton(VoidCallback onPressed, ThemeColors colors) {
    return Semantics(
      button: true,
      label: 'Send money to ${contact.name}',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: colors.goldGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.send, size: 16, color: colors.onGold),
              SizedBox(width: AppSpacing.xs),
              AppText(
                'Send',
                variant: AppTextVariant.bodySmall,
                color: colors.onGold,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteButton(VoidCallback onPressed, ThemeColors colors) {
    return Semantics(
      button: true,
      label: 'Invite ${contact.name} to Korido',
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.gold.withValues(alpha: colors.isDark ? 0.08 : 0.06),
            border: Border.all(color: colors.gold.withValues(alpha: 0.42)),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: AppText(
            'Invite',
            variant: AppTextVariant.bodySmall,
            color: colors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty<SyncedContact>('contact', contact))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onSend', onSend))
      ..add(ObjectFlagProperty<VoidCallback?>.has('onInvite', onInvite));
  }
}
