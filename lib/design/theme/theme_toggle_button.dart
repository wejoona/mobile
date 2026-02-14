import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/design/theme/theme_transition.dart';

/// Theme toggle button with smooth animations
/// Provides multiple visual styles for theme switching
class ThemeToggleButton extends ConsumerWidget {
  final ThemeToggleStyle style;
  final bool showLabel;
  final String? lightLabel;
  final String? darkLabel;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool withRipple;

  const ThemeToggleButton({
    super.key,
    this.style = ThemeToggleStyle.iconButton,
    this.showLabel = false,
    this.lightLabel,
    this.darkLabel,
    this.size,
    this.padding,
    this.withRipple = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final isDark = themeState.isDark(systemBrightness);

    switch (style) {
      case ThemeToggleStyle.iconButton:
        return _IconButtonStyle(
          isDark: isDark,
          size: size,
          onToggle: () => _handleToggle(context, ref),
        );
      case ThemeToggleStyle.switchButton:
        return _SwitchStyle(
          isDark: isDark,
          showLabel: showLabel,
          lightLabel: lightLabel ?? 'Light',
          darkLabel: darkLabel ?? 'Dark',
          onToggle: () => _handleToggle(context, ref),
        );
      case ThemeToggleStyle.segmentedControl:
        return _SegmentedControlStyle(
          themeMode: themeState.mode,
          onChanged: (mode) => _handleModeChange(context, ref, mode),
        );
      case ThemeToggleStyle.fab:
        return _FabStyle(
          isDark: isDark,
          size: size,
          onToggle: () => _handleToggle(context, ref),
        );
    }
  }

  Future<void> _handleToggle(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(themeProvider.notifier);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    // Get the position of the button for ripple effect
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero);
    final size = renderBox?.size;
    final center = offset != null && size != null
        ? Offset(offset.dx + size.width / 2, offset.dy + size.height / 2)
        : null;

    if (withRipple && center != null) {
      // Show ripple overlay
      _showRippleOverlay(context, center);
    }

    await notifier.toggleTheme(
      systemBrightness: systemBrightness,
      animated: true,
    );
  }

  void _showRippleOverlay(BuildContext context, Offset center) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final rippleColor = isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05);

        return ThemeTransition.ripple(
          context: context,
          center: center,
          rippleColor: rippleColor,
          duration: const Duration(milliseconds: 600),
          child: Container(),
        );
      },
    );

    overlay.insert(entry);

    // Remove overlay after animation completes
    Future.delayed(const Duration(milliseconds: 600), () {
      entry.remove();
    });
  }

  Future<void> _handleModeChange(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode mode,
  ) async {
    final notifier = ref.read(themeProvider.notifier);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    await notifier.setThemeMode(
      mode,
      systemBrightness: systemBrightness,
      animated: true,
    );
  }
}

/// Icon button style (default)
class _IconButtonStyle extends StatelessWidget {
  final bool isDark;
  final double? size;
  final VoidCallback onToggle;

  const _IconButtonStyle({
    required this.isDark,
    this.size,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onToggle,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return RotationTransition(
            turns: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          size: size ?? 24,
        ),
      ),
    );
  }
}

/// Switch style toggle
class _SwitchStyle extends StatelessWidget {
  final bool isDark;
  final bool showLabel;
  final String lightLabel;
  final String darkLabel;
  final VoidCallback onToggle;

  const _SwitchStyle({
    required this.isDark,
    required this.showLabel,
    required this.lightLabel,
    required this.darkLabel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Text(
                isDark ? darkLabel : lightLabel,
                style: theme.textTheme.bodyMedium,
              ),
              SizedBox(width: AppSpacing.sm),
            ],
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: 48,
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? AppColors.gold500 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: isDark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    size: 14,
                    color: isDark ? AppColors.gold500 : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Segmented control style (System/Light/Dark)
class _SegmentedControlStyle extends StatelessWidget {
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode> onChanged;

  const _SegmentedControlStyle({
    required this.themeMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.charcoal : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSegment(
            context,
            label: 'System',
            icon: Icons.phone_android,
            mode: AppThemeMode.system,
            isSelected: themeMode == AppThemeMode.system,
          ),
          _buildSegment(
            context,
            label: 'Light',
            icon: Icons.light_mode,
            mode: AppThemeMode.light,
            isSelected: themeMode == AppThemeMode.light,
          ),
          _buildSegment(
            context,
            label: 'Dark',
            icon: Icons.dark_mode,
            mode: AppThemeMode.dark,
            isSelected: themeMode == AppThemeMode.dark,
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
    BuildContext context, {
    required String label,
    required IconData icon,
    required AppThemeMode mode,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.graphite : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(mode),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating action button style
class _FabStyle extends StatelessWidget {
  final bool isDark;
  final double? size;
  final VoidCallback onToggle;

  const _FabStyle({
    required this.isDark,
    this.size,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return ScaleTransition(
            scale: animation,
            child: RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.5).animate(animation),
              child: child,
            ),
          );
        },
        child: Icon(
          isDark ? Icons.light_mode : Icons.dark_mode,
          key: ValueKey(isDark),
          size: size ?? 24,
        ),
      ),
    );
  }
}

/// Available styles for theme toggle button
enum ThemeToggleStyle {
  /// Simple icon button (moon/sun icons)
  iconButton,

  /// iOS-style switch with labels
  switchButton,

  /// Segmented control (System/Light/Dark)
  segmentedControl,

  /// Floating action button
  fab,
}
