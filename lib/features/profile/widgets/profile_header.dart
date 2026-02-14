import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/utils/color_utils.dart';
import 'package:usdc_wallet/design/components/primitives/progress_bar.dart';

/// Profile header with avatar, name, and completion progress.
class ProfileHeader extends StatelessWidget {
  final User user;
  final VoidCallback? onEditAvatar;
  final VoidCallback? onEditProfile;

  const ProfileHeader({super.key, required this.user, this.onEditAvatar, this.onEditProfile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // ignore: dead_null_aware_expression
    final initials = _getInitials(user.displayName ?? user.phone ); // ignore: dead_code
    // ignore: dead_null_aware_expression
    final avatarColor = ColorUtils.pastelFromString(user.displayName ?? user.id);

    // Avatar affiché depuis base64 (DB) en priorité, sinon URL, sinon initiales
    ImageProvider? avatarImage;
    if (user.avatarBase64 != null && user.avatarBase64!.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(user.avatarBase64!);
        avatarImage = MemoryImage(bytes);
      } catch (_) {
        // base64 invalide — fallback aux initiales
      }
    } else if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.avatarUrl!);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onEditAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: avatarColor,
                  backgroundImage: avatarImage,
                  child: avatarImage == null
                      ? Text(initials, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: ColorUtils.contrastingText(avatarColor)))
                      : null,
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
          // ignore: dead_null_aware_expression
          Text(user.displayName ?? 'Set your name', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          if (user.phone != null) // ignore: unnecessary_null_comparison
            Text(user.phone, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: 16),

          // Profile completion
          if (user.profileCompletion < 1.0) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Profile completion', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
