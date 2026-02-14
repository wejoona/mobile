import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Contact Card Widget
///
/// Displays a contact with Korido status and action buttons
class ContactCard extends StatelessWidget {
  final SyncedContact contact;
  final VoidCallback? onTap;
  final VoidCallback? onSend;
  final VoidCallback? onInvite;

  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onSend,
    this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.container,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: contact.isKoridoUser
              ? context.colors.gold.withValues(alpha: 0.3)
              : Colors.transparent,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Avatar
                _buildAvatar(),

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
                              color: context.colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (contact.isKoridoUser) ...[
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.verified,
                              size: 16,
                              color: context.colors.gold,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        contact.phone,
                        variant: AppTextVariant.bodySmall,
                        color: context.colors.textSecondary,
                      ),
                    ],
                  ),
                ),

                SizedBox(width: AppSpacing.sm),

                // Action button
                if (contact.isKoridoUser && onSend != null)
                  _buildSendButton()
                else if (!contact.isKoridoUser && onInvite != null)
                  _buildInviteButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (contact.avatarUrl != null) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(contact.avatarUrl!),
        backgroundColor: AppColors.charcoal,
      );
    }

    // Generate color from name
    final color = _getColorFromName(contact.name);

    return CircleAvatar(
      radius: 24,
      backgroundColor: color.withValues(alpha: 0.2),
      child: AppText(
        _getInitials(contact.name),
        variant: AppTextVariant.bodyLarge,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.gold500,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.send,
            size: 16,
            color: AppColors.textInverse,
          ),
          SizedBox(width: AppSpacing.xs),
          AppText(
            'Send',
            variant: AppTextVariant.bodySmall,
            color: AppColors.textInverse,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildInviteButton() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gold500),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        'Invite',
        variant: AppTextVariant.bodySmall,
        color: AppColors.gold500,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _getColorFromName(String name) {
    final colors = [
      AppColors.gold500,
      AppColors.successLight,
      AppColors.infoLight,
      AppColors.warningLight,
    ];

    final hash = name.hashCode.abs();
    return colors[hash % colors.length];
  }
}
