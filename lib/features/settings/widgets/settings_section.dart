import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// A settings section with header and grouped items.
class SettingsSection extends StatelessWidget {
  final String? title;
  final List<Widget> items;
  final EdgeInsetsGeometry margin;

  const SettingsSection({
    super.key,
    this.title,
    required this.items,
    this.margin = const EdgeInsets.only(bottom: 24),
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 16, 8),
              child: AppText(
                title!.toUpperCase(),
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: colors.container,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.borderSubtle),
              boxShadow: colors.isDark ? null : AppShadows.lightCard,
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  items[i],
                  if (i < items.length - 1)
                    Divider(
                      height: 0.5,
                      indent: items[i] is ListTile ? 56 : 16,
                      color: colors.borderSubtle,
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

/// A single settings item.
class SettingsItem extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const SettingsItem({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textColor = isDestructive ? colors.errorText : colors.textPrimary;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 16)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.bodyLarge,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                  if (subtitle != null)
                    AppText(
                      subtitle!,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: colors.textTertiary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

/// Toggle settings item.
class SettingsToggle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggle({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsItem(
      leading: leading,
      title: title,
      subtitle: subtitle,
      trailing: Switch.adaptive(value: value, onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }
}
