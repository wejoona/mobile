import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Profile header with avatar, name, and completion progress.
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditProfile;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onEditAvatar,
    this.onEditProfile,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final name = user.fullName.isNotEmpty
        ? user.fullName
        : l10n.profile_setName;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onEditAvatar,
            child: Stack(
              children: [
                UserAvatar(
                  imageUrl: _getAvatarUrl(user),
                  firstName: user.displayName.split(' ').first,
                  lastName: user.displayName.split(' ').length > 1
                      ? user.displayName.split(' ').last
                      : null,
                  size: UserAvatar.sizeXLarge,
                  showBorder: true,
                  borderColor: colors.gold,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: colors.gold,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.canvas, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.textInverse,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Name
          AppText(
            name,
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            user.phone,
            variant: AppTextVariant.monoSmall,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              StatusPill(
                label: user.isPhoneVerified
                    ? l10n.common_verified
                    : l10n.kyc_notStarted,
                tone: user.isPhoneVerified
                    ? StatusTone.success
                    : StatusTone.warning,
                icon: user.isPhoneVerified
                    ? Icons.verified_user_rounded
                    : Icons.warning_amber_rounded,
                compact: true,
              ),
              StatusPill(
                label: user.status.name,
                tone: user.status == UserStatus.active
                    ? StatusTone.info
                    : StatusTone.warning,
                compact: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Profile completion
          if (user.profileCompletion < 1.0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.profile_completion,
                  variant: AppTextVariant.labelSmall,
                  color: colors.textSecondary,
                ),
                AppText(
                  '${(user.profileCompletion * 100).round()}%',
                  variant: AppTextVariant.labelSmall,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ProgressBar(value: user.profileCompletion, height: 6),
            if (user.missingProfileFields.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: user.missingProfileFields.take(3).map((field) {
                  return StatusPill(
                    label: field,
                    tone: StatusTone.neutral,
                    compact: true,
                  );
                }).toList(),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String? _getAvatarUrl(User user) {
    if (user.avatarBase64 != null && user.avatarBase64!.isNotEmpty) {
      final avatarBase64 = user.avatarBase64!;
      if (avatarBase64.startsWith('data:image/')) {
        return avatarBase64;
      }
      return 'data:image/jpeg;base64,$avatarBase64';
    }
    return user.avatarUrl;
  }
}
