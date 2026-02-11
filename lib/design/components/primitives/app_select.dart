import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'app_text.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';

/// Select/Dropdown Item Model
class AppSelectItem<T> {
  const AppSelectItem({
    required this.value,
    required this.label,
    this.icon,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final IconData? icon;
  final String? subtitle;
  final bool enabled;
}

/// Select State
enum AppSelectState {
  /// Default/idle state
  idle,

  /// Field is focused/opened
  focused,

  /// Field has error
  error,

  /// Field is disabled
  disabled,
}

/// Luxury Wallet Select/Dropdown Component
/// Matches design system with gold accents and dark theme
class AppSelect<T> extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.helper,
    this.enabled = true,
    this.prefixIcon,
    this.showCheckmark = true,
  });

  final List<AppSelectItem<T>> items;
  final T? value;
  final ValueChanged<T?> onChanged;
  final String? label;
  final String? hint;
  final String? error;
  final String? helper;
  final bool enabled;
  final IconData? prefixIcon;
  final bool showCheckmark;

  @override
  State<AppSelect<T>> createState() => _AppSelectState<T>();
}

class _AppSelectState<T> extends State<AppSelect<T>> {
  bool _isFocused = false;

  AppSelectState _getCurrentState() {
    if (!widget.enabled) return AppSelectState.disabled;
    if (widget.error != null) return AppSelectState.error;
    if (_isFocused) return AppSelectState.focused;
    return AppSelectState.idle;
  }

  AppSelectItem<T>? _getSelectedItem() {
    if (widget.value == null) return null;
    try {
      return widget.items.firstWhere((item) => item.value == widget.value);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final currentState = _getCurrentState();
    final selectedItem = _getSelectedItem();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          AppText(
            widget.label!,
            variant: AppTextVariant.labelMedium,
            color: _getLabelColor(currentState, colors),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        GestureDetector(
          onTap: widget.enabled ? _showDropdown : null,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: _getFillColor(currentState, colors),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: _getBorderColor(currentState, colors),
                width: currentState == AppSelectState.focused ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null ||
                    selectedItem?.icon != null) ...[
                  Icon(
                    selectedItem?.icon ?? widget.prefixIcon,
                    size: 20,
                    color: _getIconColor(currentState, colors),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                Expanded(
                  child: selectedItem != null
                      ? AppText(
                          selectedItem.label,
                          variant: AppTextVariant.bodyLarge,
                          color: _getTextColor(currentState, colors),
                        )
                      : AppText(
                          widget.hint ?? 'Select an option',
                          variant: AppTextVariant.bodyLarge,
                          color: colors.textTertiary,
                        ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 24,
                  color: _getIconColor(currentState, colors),
                ),
              ],
            ),
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            widget.error!,
            variant: AppTextVariant.bodySmall,
            color: colors.errorText,
          ),
        ],
        if (widget.helper != null && widget.error == null) ...[
          const SizedBox(height: AppSpacing.xs),
          AppText(
            widget.helper!,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
        ],
      ],
    );
  }

  /// Show dropdown menu as bottom sheet for better mobile UX
  void _showDropdown() {
    setState(() => _isFocused = true);

    final colors = context.colors;

    showModalBottomSheet<T>(
      context: context,
      backgroundColor: colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              ),
              // Title
              if (widget.label != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: AppText(
                    widget.label!,
                    variant: AppTextVariant.titleMedium,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Divider(color: colors.borderSubtle, height: 1),
              ],
              // Items
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.items.length,
                  itemBuilder: (context, index) {
                    final item = widget.items[index];
                    final isSelected = widget.value == item.value;

                    return _SelectMenuItem<T>(
                      item: item,
                      isSelected: isSelected,
                      showCheckmark: widget.showCheckmark,
                      colors: colors,
                      onTap: item.enabled
                          ? () {
                              hapticService.selection();
                              widget.onChanged(item.value);
                              Navigator.pop(context);
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isFocused = false);
      }
    });
  }

  Color _getFillColor(AppSelectState state, ThemeColors colors) {
    switch (state) {
      case AppSelectState.disabled:
        return colors.elevated.withValues(alpha: 0.5);
      case AppSelectState.error:
        return colors.error.withValues(alpha: 0.05);
      case AppSelectState.focused:
        return colors.elevated;
      case AppSelectState.idle:
        return colors.elevated;
    }
  }

  Color _getBorderColor(AppSelectState state, ThemeColors colors) {
    switch (state) {
      case AppSelectState.disabled:
        return colors.borderSubtle;
      case AppSelectState.error:
        return colors.error;
      case AppSelectState.focused:
        return colors.gold;
      case AppSelectState.idle:
        return colors.border;
    }
  }

  Color _getTextColor(AppSelectState state, ThemeColors colors) {
    switch (state) {
      case AppSelectState.disabled:
        return colors.textDisabled;
      default:
        return colors.textPrimary;
    }
  }

  Color _getLabelColor(AppSelectState state, ThemeColors colors) {
    switch (state) {
      case AppSelectState.disabled:
        return colors.textDisabled;
      case AppSelectState.error:
        return colors.errorText;
      case AppSelectState.focused:
        return colors.gold;
      default:
        return colors.textSecondary;
    }
  }

  Color _getIconColor(AppSelectState state, ThemeColors colors) {
    switch (state) {
      case AppSelectState.disabled:
        return colors.textDisabled;
      case AppSelectState.error:
        return colors.error;
      case AppSelectState.focused:
        return colors.gold;
      default:
        return colors.textTertiary;
    }
  }
}

/// Select Menu Item Widget
class _SelectMenuItem<T> extends StatelessWidget {
  const _SelectMenuItem({
    required this.item,
    required this.isSelected,
    required this.showCheckmark,
    required this.colors,
    required this.onTap,
  });

  final AppSelectItem<T> item;
  final bool isSelected;
  final bool showCheckmark;
  final ThemeColors colors;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.gold.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 20,
                  color: isSelected ? colors.gold : colors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      item.label,
                      variant: AppTextVariant.bodyLarge,
                      color: isSelected ? colors.gold : colors.textPrimary,
                    ),
                    if (item.subtitle != null) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        item.subtitle!,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
              if (showCheckmark && isSelected) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.check_circle, size: 20, color: colors.gold),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
