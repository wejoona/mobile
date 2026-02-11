import 'package:flutter/material.dart';

/// Avatar widget that handles null URLs, loading, and errors gracefully.
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? fallbackText;
  final double size;
  final Color? backgroundColor;

  const CachedAvatar({
    super.key,
    this.imageUrl,
    this.fallbackText,
    this.size = 40,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.primaryContainer;
    final textColor = theme.colorScheme.onPrimaryContainer;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackCircle(bgColor, textColor),
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return _shimmerCircle(bgColor);
          },
        ),
      );
    }

    return _fallbackCircle(bgColor, textColor);
  }

  Widget _fallbackCircle(Color bgColor, Color textColor) {
    final initials = _getInitials();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bgColor),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: textColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _shimmerCircle(Color bgColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor.withValues(alpha: 0.3),
      ),
    );
  }

  String _getInitials() {
    if (fallbackText == null || fallbackText!.isEmpty) return '?';
    final parts = fallbackText!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
