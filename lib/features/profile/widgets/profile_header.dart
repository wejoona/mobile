import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Profile header with avatar, name, and completion progress.
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditProfile;

  const ProfileHeader({super.key, required this.user, this.onEditAvatar, this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
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
                  lastName: user.displayName.split(' ').length > 1 ? user.displayName.split(' ').last : null,
                  size: UserAvatar.sizeXLarge,
                ),
                Positioned(
                  right: 0, bottom: 0,
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Name
          Text(user.fullName.isNotEmpty ? user.fullName : AppLocalizations.of(context)!.profile_setName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(user.phone, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Profile completion
          if (user.profileCompletion < 1.0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.profile_completion, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                Text('${(user.profileCompletion * 100).round()}%', style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 4),
            ProgressBar(value: user.profileCompletion, height: 6),
            if (user.missingProfileFields.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                children: user.missingProfileFields.take(3).map((field) {
                  return Chip(
                    label: Text(field, style: const TextStyle(fontSize: 11)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      return 'data:image/jpeg;base64,${user.avatarBase64}';
    }
    return user.avatarUrl;
  }
}
