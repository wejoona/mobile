import 'package:flutter/material.dart';

/// A horizontally scrollable row of action chips (filter, sort, etc.).
class ActionChipRow extends StatelessWidget {
  final List<ChipItem> items;
  final String? selected;
  final ValueChanged<String> onSelected;
  final EdgeInsetsGeometry padding;

  const ActionChipRow({
    super.key,
    required this.items,
    this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item.id == selected;
          return FilterChip(
            label: Text(item.label),
            selected: isSelected,
            onSelected: (_) => onSelected(item.id),
            avatar: item.icon != null ? Icon(item.icon, size: 16) : null,
            selectedColor: theme.colorScheme.primaryContainer,
            checkmarkColor: theme.colorScheme.onPrimaryContainer,
            labelStyle: TextStyle(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          );
        },
      ),
    );
  }
}

/// Data model for a chip item.
class ChipItem {
  final String id;
  final String label;
  final IconData? icon;
  final int? count;

  const ChipItem({
    required this.id,
    required this.label,
    this.icon,
    this.count,
  });
}
