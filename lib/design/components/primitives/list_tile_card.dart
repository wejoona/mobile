import 'package:flutter/material.dart';

/// An elevated list tile with card styling — for settings, menus, etc.
class ListTileCard extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final bool showChevron;

  const ListTileCard({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    this.backgroundColor,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: Material(
        color: backgroundColor ?? theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (trailing == null && showChevron && onTap != null)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A group of list tile cards with a header.
class ListTileGroup extends StatelessWidget {
  final String? header;
  final List<ListTileCard> tiles;
  final EdgeInsetsGeometry margin;

  const ListTileGroup({
    super.key,
    this.header,
    required this.tiles,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 4),
              child: Text(
                header!.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withOpacity(0.5),
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  ListTileCard(
                    leading: tiles[i].leading,
                    title: tiles[i].title,
                    subtitle: tiles[i].subtitle,
                    trailing: tiles[i].trailing,
                    onTap: tiles[i].onTap,
                    margin: EdgeInsets.zero,
                    showChevron: tiles[i].showChevron,
                  ),
                  if (i < tiles.length - 1)
                    Divider(
                      height: 0.5,
                      indent: tiles[i].leading != null ? 56 : 16,
                      color: theme.colorScheme.outlineVariant.withOpacity(0.3),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
