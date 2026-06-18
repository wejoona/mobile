import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/image_cache/image_cache_config.dart';
import 'package:usdc_wallet/design/components/primitives/app_skeleton.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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
      return GestureDetector(onTap: onTap, child: widget);
    }

    return widget;
  }

  Widget _buildAvatar(BuildContext context) {
    final borderWidth = _getBorderWidth();
    // ignore: unused_local_variable
    final __effectiveSize = size - (borderWidth * 2);

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
            ? (_isLocalFilePath(imageUrl!)
                  ? _buildLocalImage()
                  : _isBase64Image(imageUrl!)
                  ? _buildBase64Image(context)
                  : _buildNetworkImage())
            : _buildInitialsFallback(context),
      ),
    );
  }

  Widget _buildLocalImage() {
    return Image.file(
      File(imageUrl!),
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stack) => _buildInitialsFallback(context),
    );
  }

  /// True only for actual local file paths (e.g. /Users/..., /var/..., /data/...)
  /// False for relative API paths like /user/avatar/xxx
  bool _isLocalFilePath(String path) {
    if (!path.startsWith('/')) return false;
    // Local file paths from getApplicationDocumentsDirectory() start with these
    return path.startsWith('/Users/') ||
        path.startsWith('/var/') ||
        path.startsWith('/data/') ||
        path.startsWith('/private/') ||
        path.startsWith('/storage/');
  }

  /// Resolve URL: if it's a relative path like /user/avatar/xxx, prepend base URL
  String _resolveUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('data:image/')) {
      return trimmed;
    }

    final base = Uri.parse(ApiConfig.baseUrl);
    final relative = Uri.parse(trimmed);
    final origin = base.replace(path: '', query: null, fragment: null);

    if (relative.path.startsWith('/api/')) {
      return origin
          .replace(
            path: relative.path,
            query: relative.hasQuery ? relative.query : null,
          )
          .toString();
    }

    final baseSegments = base.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);
    final relativeSegments = relative.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList(growable: false);

    final resolvedSegments = _startsWithSegments(relativeSegments, baseSegments)
        ? relativeSegments
        : [...baseSegments, ...relativeSegments];

    return base
        .replace(
          pathSegments: resolvedSegments,
          query: relative.hasQuery ? relative.query : null,
          fragment: relative.hasFragment ? relative.fragment : null,
        )
        .toString();
  }

  bool _startsWithSegments(List<String> value, List<String> prefix) {
    if (prefix.isEmpty) return true;
    if (value.length < prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (value[i] != prefix[i]) return false;
    }
    return true;
  }

  bool _needsAuthHeaders(String url) {
    final resolvedPath = Uri.tryParse(_resolveUrl(url))?.path ?? url;
    return resolvedPath.endsWith('/user/avatar') ||
        resolvedPath.contains('/user/avatar/');
  }

  bool _isBase64Image(String value) {
    if (value.startsWith('data:image/')) return true;
    if (value.startsWith('http://') ||
        value.startsWith('https://') ||
        value.startsWith('/')) {
      return false;
    }
    if (value.length < 80) return false;

    final compact = value.replaceAll(RegExp(r'\s'), '');
    final hasImagePrefix =
        compact.startsWith('/9j/') ||
        compact.startsWith('iVBOR') ||
        compact.startsWith('R0lGOD') ||
        compact.startsWith('UklGR');
    if (!hasImagePrefix) return false;

    return RegExp(r'^[A-Za-z0-9+/]+={0,2}$').hasMatch(compact);
  }

  Widget _buildBase64Image(BuildContext context) {
    try {
      final raw = imageUrl!.startsWith('data:')
          ? imageUrl!.split(',').last
          : imageUrl!;
      final bytes = base64Decode(raw.replaceAll(RegExp(r'\s'), ''));
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, error, stack) => _buildInitialsFallback(ctx),
      );
    } catch (_) {
      return _buildInitialsFallback(context);
    }
  }

  Widget _buildNetworkImage() {
    final rawUrl = imageUrl!;
    if (!_needsAuthHeaders(rawUrl)) {
      return _buildCachedNetworkImage(_resolveUrl(rawUrl));
    }

    return Consumer(
      builder: (context, ref, _) {
        final storage = ref.watch(secureStorageProvider);
        return FutureBuilder<String?>(
          future: storage.read(key: StorageKeys.accessToken),
          builder: (context, snapshot) {
            final token = snapshot.data;
            if (snapshot.connectionState != ConnectionState.done) {
              return AppSkeleton.circle(size: size);
            }

            return _buildCachedNetworkImage(
              _resolveUrl(rawUrl),
              httpHeaders: token == null || token.isEmpty
                  ? null
                  : {'Authorization': 'Bearer $token'},
            );
          },
        );
      },
    );
  }

  Widget _buildCachedNetworkImage(
    String resolvedUrl, {
    Map<String, String>? httpHeaders,
  }) {
    return CachedNetworkImage(
      imageUrl: resolvedUrl,
      cacheManager: ImageCacheConfig.profilePhotos,
      httpHeaders: httpHeaders,
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
    final gradientColors = _getGradientColors(context);

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
                  color: _getInitialsColor(context),
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
          color: isOnline
              ? context.colors.success
              : context.colors.textDisabled,
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

  /// Generate fallback colors based on context and name hash.
  List<Color> _getGradientColors(BuildContext context) {
    if (showBorder || borderColor != null) {
      final accent = borderColor ?? context.colors.gold;
      return [
        Color.alphaBlend(
          accent.withValues(alpha: context.colors.isDark ? 0.22 : 0.16),
          context.colors.surface,
        ),
        Color.alphaBlend(
          accent.withValues(alpha: context.colors.isDark ? 0.12 : 0.07),
          context.colors.container,
        ),
      ];
    }

    final nameHash = _hashName();

    // Muted identity accents, kept softer than the brand gold surfaces.
    final gradients = [
      [const Color(0xFFF3E7CF), const Color(0xFFE6D3AC)], // Champagne
      [const Color(0xFFDCE9E5), const Color(0xFFB8D3CC)], // Sage
      [const Color(0xFFE7E4F1), const Color(0xFFCFC6E3)], // Soft indigo
      [const Color(0xFFF0DED5), const Color(0xFFDAB9A6)], // Clay
      [AppColors.gold100, AppColors.gold300], // Gold
    ];

    return gradients[nameHash % gradients.length];
  }

  Color _getInitialsColor(BuildContext context) {
    if (showBorder || borderColor != null) {
      return context.colors.textPrimary;
    }

    return context.colors.isDark
        ? AppColors.textInverse
        : AppColors.textPrimary;
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
      return GestureDetector(onTap: onTap, child: widget);
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
            ? Border.all(color: context.colors.canvas, width: 2)
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
  const UserAvatarData({this.imageUrl, this.firstName, this.lastName});

  final String? imageUrl;
  final String? firstName;
  final String? lastName;
}
