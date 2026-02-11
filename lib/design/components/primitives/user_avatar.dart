import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_skeleton.dart';

/// UserAvatar - Displays user profile picture with fallback
///
/// Features:
/// - Circular profile picture from URL with caching
/// - Fallback to initials when no image
/// - Loading state with shimmer skeleton
/// - Error state with icon fallback
/// - Multiple sizes (small, medium, large, xlarge)
/// - Optional border/ring (gold for premium users)
/// - Optional online indicator dot
/// - Tap handler for profile navigation
///
/// Usage:
/// ```dart
/// // Basic avatar with image URL
/// UserAvatar(
///   imageUrl: 'https://example.com/avatar.jpg',
///   firstName: 'Amadou',
///   lastName: 'Diallo',
/// )
///
/// // Small avatar with gold border (premium user)
/// UserAvatar(
///   imageUrl: user.avatarUrl,
///   firstName: user.firstName,
///   lastName: user.lastName,
///   size: UserAvatar.sizeSmall,
///   showBorder: true,
///   borderColor: AppColors.gold500,
/// )
///
/// // Large avatar with online indicator
/// UserAvatar(
///   imageUrl: user.avatarUrl,
///   firstName: user.firstName,
///   size: UserAvatar.sizeLarge,
///   showOnlineIndicator: true,
///   isOnline: true,
///   onTap: () => context.push('/profile/${user.id}'),
/// )
///
/// // Initials only (no image)
/// UserAvatar(
///   firstName: 'Fatou',
///   lastName: 'Traore',
///   size: UserAvatar.sizeMedium,
/// )
/// ```
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.firstName,
    this.lastName,
    this.size = sizeMedium,
    this.showBorder = false,
    this.borderColor,
    this.showOnlineIndicator = false,
    this.isOnline = false,
    this.onTap,
  });

  /// Image URL for the avatar
  final String? imageUrl;

  /// User's first name (used for initials fallback)
  final String? firstName;

  /// User's last name (used for initials fallback)
  final String? lastName;

  /// Size of the avatar (use predefined constants)
  final double size;

  /// Whether to show a border around the avatar
  final bool showBorder;

  /// Color of the border (defaults to gold)
  final Color? borderColor;

  /// Whether to show the online indicator dot
  final bool showOnlineIndicator;

  /// Whether the user is online (green dot)
  final bool isOnline;

  /// Tap handler for navigation to profile
  final VoidCallback? onTap;

  // Predefined sizes
  static const double sizeSmall = 32;
  static const double sizeMedium = 48;
  static const double sizeLarge = 64;
  static const double sizeXLarge = 96;

  @override
  Widget build(BuildContext context) {
    final widget = Stack(
      children: [
        _buildAvatar(context),
        if (showOnlineIndicator) _buildOnlineIndicator(context),
      ],
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildAvatar(BuildContext context) {
    final borderWidth = _getBorderWidth();
    final effectiveSize = size - (borderWidth * 2);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? context.colors.gold,
                width: borderWidth,
              )
            : null,
      ),
      child: ClipOval(
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? _buildNetworkImage()
            : _buildInitialsFallback(context),
      ),
    );
  }

  Widget _buildNetworkImage() {
    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.cover,
      placeholder: (context, url) => AppSkeleton.circle(size: size),
      errorWidget: (context, url, error) => _buildInitialsFallback(context),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 200),
      memCacheWidth: (size * 2).toInt(), // 2x for retina
      memCacheHeight: (size * 2).toInt(),
    );
  }

  Widget _buildInitialsFallback(BuildContext context) {
    final initials = _getInitials();
    final hasInitials = initials.isNotEmpty;
    final gradientColors = _getGradientColors();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: hasInitials
            ? Text(
                initials,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: _getInitialsFontSize(),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              )
            : Icon(
                Icons.person,
                color: context.colors.textSecondary,
                size: size * 0.5,
              ),
      ),
    );
  }

  Widget _buildOnlineIndicator(BuildContext context) {
    final indicatorSize = _getIndicatorSize();

    return Positioned(
      right: 0,
      bottom: 0,
      child: Container(
        width: indicatorSize,
        height: indicatorSize,
        decoration: BoxDecoration(
          color: isOnline ? context.colors.success : context.colors.textDisabled,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.colors.canvas,
            width: indicatorSize > 10 ? 2 : 1.5,
          ),
        ),
      ),
    );
  }

  // Helper methods

  String _getInitials() {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';

    if (first.isEmpty && last.isEmpty) return '';
    if (first.isEmpty) return last[0].toUpperCase();
    if (last.isEmpty) return first[0].toUpperCase();

    return '${first[0]}${last[0]}'.toUpperCase();
  }

  double _getInitialsFontSize() {
    if (size <= sizeSmall) return 14;
    if (size <= sizeMedium) return 18;
    if (size <= sizeLarge) return 24;
    return 36;
  }

  double _getBorderWidth() {
    if (!showBorder) return 0;
    if (size <= sizeSmall) return 1.5;
    if (size <= sizeMedium) return 2;
    if (size <= sizeLarge) return 2.5;
    return 3;
  }

  double _getIndicatorSize() {
    if (size <= sizeSmall) return 8;
    if (size <= sizeMedium) return 12;
    if (size <= sizeLarge) return 14;
    return 18;
  }

  /// Generate gradient colors based on name hash for consistent colors
  List<Color> _getGradientColors() {
    final nameHash = _hashName();

    // Predefined gradient pairs that work well with dark theme
    final gradients = [
      [const Color(0xFF4A5568), const Color(0xFF2D3748)], // Cool Gray
      [const Color(0xFF4C51BF), const Color(0xFF2D3748)], // Indigo
      [const Color(0xFF38B2AC), const Color(0xFF2D3748)], // Teal
      [const Color(0xFFED8936), const Color(0xFF744210)], // Orange
      [const Color(0xFF9F7AEA), const Color(0xFF553C9A)], // Purple
      [const Color(0xFFE53E3E), const Color(0xFF742A2A)], // Red
      [const Color(0xFF48BB78), const Color(0xFF22543D)], // Green
      [const Color(0xFF4299E1), const Color(0xFF2C5282)], // Blue
      [AppColors.gold600, AppColors.gold800], // Gold
      [const Color(0xFFED64A6), const Color(0xFF702459)], // Pink
    ];

    return gradients[nameHash % gradients.length];
  }

  int _hashName() {
    final name = '${firstName ?? ''}${lastName ?? ''}'.toLowerCase();
    if (name.isEmpty) return 0;

    int hash = 0;
    for (int i = 0; i < name.length; i++) {
      hash = name.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs();
  }
}

/// UserAvatarGroup - Display multiple overlapping avatars
///
/// Usage:
/// ```dart
/// UserAvatarGroup(
///   users: [
///     UserAvatarData(firstName: 'Amadou', imageUrl: '...'),
///     UserAvatarData(firstName: 'Fatou', imageUrl: '...'),
///     UserAvatarData(firstName: 'Diallo', imageUrl: '...'),
///   ],
///   size: UserAvatar.sizeSmall,
///   maxAvatars: 3,
/// )
/// ```
class UserAvatarGroup extends StatelessWidget {
  const UserAvatarGroup({
    super.key,
    required this.users,
    this.size = UserAvatar.sizeSmall,
    this.maxAvatars = 3,
    this.showBorder = true,
    this.onTap,
  });

  final List<UserAvatarData> users;
  final double size;
  final int maxAvatars;
  final bool showBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(maxAvatars).toList();
    final remainingCount = users.length - maxAvatars;
    final overlap = size * 0.25; // 25% overlap

    final widget = SizedBox(
      height: size,
      width: size + (displayUsers.length - 1) * (size - overlap),
      child: Stack(
        children: [
          ...displayUsers.asMap().entries.map((entry) {
            final index = entry.key;
            final user = entry.value;
            return Positioned(
              left: index * (size - overlap),
              child: UserAvatar(
                imageUrl: user.imageUrl,
                firstName: user.firstName,
                lastName: user.lastName,
                size: size,
                showBorder: showBorder,
                borderColor: context.colors.canvas,
              ),
            );
          }),
          if (remainingCount > 0)
            Positioned(
              left: displayUsers.length * (size - overlap),
              child: _buildOverflowBadge(context, remainingCount),
            ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildOverflowBadge(BuildContext context, int count) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.colors.container,
        border: showBorder
            ? Border.all(
                color: context.colors.canvas,
                width: 2,
              )
            : null,
      ),
      child: Center(
        child: Text(
          '+$count',
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: size * 0.35,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Data class for UserAvatarGroup
class UserAvatarData {
  const UserAvatarData({
    this.imageUrl,
    this.firstName,
    this.lastName,
  });

  final String? imageUrl;
  final String? firstName;
  final String? lastName;
}
