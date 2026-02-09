# Theme System Usage Examples

Quick reference for using the JoonaPay theme system in your widgets.

## Basic Setup

The theme is already configured in `main.dart`:

```dart
MaterialApp.router(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: _getThemeMode(themeState.mode),
  // ...
)
```

## 1. Using Material Theme Colors

```dart
import 'package:flutter/material.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      color: colorScheme.primary, // Gold
      child: Text(
        'Hello',
        style: textTheme.headlineMedium,
      ),
    );
  }
}
```

## 2. Using Custom Color Extension

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class GoldCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Context extension (recommended)
    final colors = context.appColors;

    return Container(
      decoration: BoxDecoration(
        color: colors.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.borderGold),
      ),
      child: Text(
        'Balance',
        style: TextStyle(color: colors.textSecondary),
      ),
    );
  }
}
```

## 3. Using Gradients

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class GradientButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final gradients = context.appGradients;

    return Container(
      decoration: BoxDecoration(
        gradient: gradients.goldGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16),
      child: Text('Premium Feature'),
    );
  }
}
```

## 4. Using Shadows

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class ElevatedCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final shadows = context.appShadows;

    return Container(
      decoration: BoxDecoration(
        color: context.appColors.backgroundTertiary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadows.goldGlow,
      ),
      child: Text('Highlighted'),
    );
  }
}
```

## 5. Theme-Aware Widget

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class ThemedIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Icon(
      Icons.star,
      color: isDark
        ? context.appColors.gold500
        : context.appColors.gold600,
    );
  }
}
```

## 6. Theme Toggle Button

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';

class ThemeToggle extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return IconButton(
      icon: Icon(
        themeState.mode == AppThemeMode.dark
          ? Icons.light_mode
          : Icons.dark_mode,
      ),
      onPressed: () {
        ref.read(themeProvider.notifier).toggleTheme();
      },
    );
  }
}
```

## 7. Theme Settings Screen

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';

class ThemeSettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Theme')),
      body: ListView(
        children: [
          RadioListTile<AppThemeMode>(
            title: Text('System Default'),
            value: AppThemeMode.system,
            groupValue: themeState.mode,
            onChanged: (mode) {
              ref.read(themeProvider.notifier).setThemeMode(mode!);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: Text('Light'),
            value: AppThemeMode.light,
            groupValue: themeState.mode,
            onChanged: (mode) {
              ref.read(themeProvider.notifier).setThemeMode(mode!);
            },
          ),
          RadioListTile<AppThemeMode>(
            title: Text('Dark'),
            value: AppThemeMode.dark,
            groupValue: themeState.mode,
            onChanged: (mode) {
              ref.read(themeProvider.notifier).setThemeMode(mode!);
            },
          ),
        ],
      ),
    );
  }
}
```

## 8. Complete Card Example

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';

class BalanceCard extends StatelessWidget {
  final String balance;
  final String currency;

  const BalanceCard({
    required this.balance,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final gradients = context.appGradients;
    final shadows = context.appShadows;

    return Container(
      padding: EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: gradients.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: shadows.goldGlow,
        border: Border.all(
          color: colors.borderGoldStrong,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colors.textInverse.withOpacity(0.8),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            balance,
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: colors.textInverse,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            currency,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: colors.textInverse.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 9. Shimmer Loading Effect

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class ShimmerPlaceholder extends StatefulWidget {
  final double width;
  final double height;

  const ShimmerPlaceholder({
    required this.width,
    required this.height,
  });

  @override
  State<ShimmerPlaceholder> createState() => _ShimmerPlaceholderState();
}

class _ShimmerPlaceholderState extends State<ShimmerPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradients = context.appGradients;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: gradients.shimmerGradient,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
```

## 10. Glass Morphism Effect

```dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class GlassCard extends StatelessWidget {
  final Widget child;

  const GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final gradients = context.appGradients;
    final colors = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradients.glassGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.borderSubtle,
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## 11. Status Badge

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

enum BadgeStatus { success, warning, error, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeStatus status;

  const StatusBadge({
    required this.label,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final backgroundColor = switch (status) {
      BadgeStatus.success => colors.successLight,
      BadgeStatus.warning => colors.warningLight,
      BadgeStatus.error => colors.errorLight,
      BadgeStatus.info => colors.infoLight,
    };

    final textColor = switch (status) {
      BadgeStatus.success => colors.successText,
      BadgeStatus.warning => colors.warningText,
      BadgeStatus.error => colors.errorText,
      BadgeStatus.info => colors.infoText,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

## 12. Semantic Color Usage

```dart
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final double amount;
  final bool isIncome;

  const TransactionTile({
    required this.title,
    required this.amount,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      title: Text(title),
      trailing: Text(
        '${isIncome ? '+' : '-'}\$$amount',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isIncome ? colors.successText : colors.errorText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

## Pro Tips

1. **Always use context extensions** for cleaner code:
   ```dart
   // Good
   color: context.appColors.gold500

   // Verbose
   color: Theme.of(context).extension<AppColorsExtension>()!.gold500
   ```

2. **Prefer semantic colors** over hardcoded values:
   ```dart
   // Good - adapts to theme
   color: context.appColors.successText

   // Bad - always the same
   color: Color(0xFF7DD3A8)
   ```

3. **Use Material theme when possible**:
   ```dart
   // Good - uses ColorScheme
   color: Theme.of(context).colorScheme.primary

   // OK but less flexible
   color: context.appColors.gold500
   ```

4. **Check theme brightness** for conditional styling:
   ```dart
   final opacity = context.isDarkMode ? 0.8 : 0.6;
   ```

5. **Leverage theme transitions** - all color changes animate smoothly (400ms)

## Common Patterns

### Gold Accent Pattern
```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: context.appColors.borderGold),
    boxShadow: context.appShadows.goldGlow,
  ),
)
```

### Card Elevation Pattern
```dart
Container(
  decoration: BoxDecoration(
    color: context.appColors.backgroundTertiary,
    borderRadius: BorderRadius.circular(16),
    boxShadow: context.appShadows.card,
  ),
)
```

### Text Hierarchy Pattern
```dart
Column(
  children: [
    Text('Title', style: context.appColors.textPrimary),
    Text('Subtitle', style: context.appColors.textSecondary),
    Text('Caption', style: context.appColors.textTertiary),
  ],
)
```
