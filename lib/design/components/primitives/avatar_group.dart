import 'package:flutter/material.dart';

/// Overlapping avatar group (like GitHub collaborators).
class AvatarGroup extends StatelessWidget {
  final List<AvatarData> avatars;
  final double size;
  final double overlap;
  final int maxDisplay;
  final Color? borderColor;

  const AvatarGroup({
    super.key,
    required this.avatars,
    this.size = 32,
    this.overlap = 8,
    this.maxDisplay = 4,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = borderColor ?? theme.colorScheme.surface;
    final display = avatars.take(maxDisplay).toList();
    final remaining = avatars.length - maxDisplay;

    return SizedBox(
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < display.length; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: 2),
                ),
                child: ClipOval(
                  child: display[i].imageUrl != null
                      ? Image.network(
                          display[i].imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _InitialsAvatar(display[i].initials, size),
                        )
                      : _InitialsAvatar(display[i].initials, size),
                ),
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: display.length * (size - overlap),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primaryContainer,
                  border: Border.all(color: border, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$remaining',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;
  final double size;

  const _InitialsAvatar(this.initials, this.size);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: size,
      height: size,
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Data for a single avatar.
class AvatarData {
  final String? imageUrl;
  final String initials;
  final String? name;

  const AvatarData({
    this.imageUrl,
    required this.initials,
    this.name,
  });
}
