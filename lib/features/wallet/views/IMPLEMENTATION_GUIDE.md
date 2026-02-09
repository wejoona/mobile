# Wallet Card Theme Implementation Guide

## For Developers: How to Work with Theme-Aware Components

### Quick Start

Always use `context.colors` and `context.isDarkMode` instead of hardcoded colors:

```dart
// ❌ DON'T DO THIS
Container(
  color: AppColors.obsidian,
  child: Text('Balance', style: TextStyle(color: AppColors.gold500)),
)

// ✅ DO THIS
final colors = context.colors;
Container(
  color: colors.canvas,
  child: AppText('Balance', color: colors.gold),
)
```

### Common Patterns

#### 1. Different Widgets for Different Themes

```dart
if (context.isDarkMode) {
  // Dark theme version
  return ShaderMask(
    shaderCallback: (bounds) => context.appGradients.goldGradient.createShader(bounds),
    child: Text(balance),
  );
} else {
  // Light theme version
  return Text(
    balance,
    style: TextStyle(
      color: AppColorsLight.gold700,
      shadows: [Shadow(...)],
    ),
  );
}
```

#### 2. Conditional Colors

```dart
color: context.isDarkMode
    ? colors.textSecondary
    : colors.textSecondary.withValues(alpha: 0.9)
```

#### 3. Conditional Gradients

```dart
final cardGradient = context.isDarkMode
    ? LinearGradient(colors: [darkColor1, darkColor2])
    : LinearGradient(colors: [lightColor1, lightColor2]);
```

#### 4. Conditional Shadows

```dart
boxShadow: context.isDarkMode
    ? [BoxShadow(...darkShadow)]
    : [BoxShadow(...lightShadow)]
```

### Available Theme Helpers

#### From `context.colors` (ThemeColors)

```dart
// Backgrounds
colors.canvas       // Main screen bg
colors.container    // Card bg
colors.elevated     // Elevated surface
colors.surface      // Secondary surface

// Text
colors.textPrimary   // High emphasis
colors.textSecondary // Medium emphasis
colors.textTertiary  // Low emphasis
colors.textInverse   // On gold/light bg

// Brand
colors.gold          // Primary gold (auto-switches)
colors.goldLight     // Gold for text/icons
colors.goldSubtle    // Gold for backgrounds

// Semantic
colors.success       // Green
colors.error         // Red
colors.warning       // Orange
colors.info          // Blue

// Borders
colors.border        // Default border
colors.borderSubtle  // Light border
colors.borderStrong  // Strong border
colors.borderGold    // Gold border
```

#### From `context.appGradients` (AppGradientsExtension)

```dart
context.appGradients.goldGradient          // Main gold gradient
context.appGradients.goldGradientVertical  // Vertical variant
context.appGradients.shimmerGradient       // Loading shimmer
context.appGradients.glassGradient         // Glassmorphism
context.appGradients.goldRadialGradient    // Radial effect
context.appGradients.goldSweepGradient     // Sweep effect
```

#### From `context.appShadows` (AppShadowsExtension)

```dart
context.appShadows.sm              // Small shadow
context.appShadows.md              // Medium shadow
context.appShadows.lg              // Large shadow
context.appShadows.xl              // Extra large
context.appShadows.card            // Card shadow
context.appShadows.cardHover       // Card hover state
context.appShadows.goldGlow        // Subtle gold glow
context.appShadows.goldGlowStrong  // Strong gold glow
```

### Creating Theme-Aware Widgets

#### Example: Custom Card

```dart
class MyCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isDark
              ? colors.borderSubtle
              : colors.border,
        ),
        boxShadow: context.appShadows.card,
      ),
      child: Column(
        children: [
          // Header with theme-aware icon
          Icon(
            Icons.wallet,
            color: colors.gold,
          ),
          // Theme-aware text
          AppText(
            'My Balance',
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}
```

#### Example: Gradient Text

```dart
Widget buildGradientText(BuildContext context, String text) {
  if (context.isDarkMode) {
    // Gradient in dark mode
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          colors: [
            AppColors.gold300,
            AppColors.gold500,
            AppColors.gold400,
          ],
        ).createShader(bounds);
      },
      child: Text(
        text,
        style: TextStyle(color: AppColors.white),
      ),
    );
  } else {
    // Solid color in light mode
    return Text(
      text,
      style: TextStyle(
        color: AppColorsLight.gold700,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
```

### Testing Your Theme-Aware Components

#### 1. Manual Theme Switch

```dart
// In your app, add a debug button
IconButton(
  icon: Icon(Icons.brightness_6),
  onPressed: () {
    // Toggle theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Update theme provider
  },
)
```

#### 2. Check Both Themes in Flutter DevTools

- Open DevTools
- Go to "Widget Inspector"
- Toggle theme mode
- Verify all colors update correctly

#### 3. Contrast Checker

Use online tools to verify contrast ratios:
- https://webaim.org/resources/contrastchecker/
- Target: AA (4.5:1 for normal text, 3:1 for large text)

### Common Mistakes to Avoid

#### ❌ Hardcoding Colors

```dart
// DON'T
Container(color: Color(0xFF1A1A1F))
Text('Hi', style: TextStyle(color: AppColors.gold500))
```

#### ✅ Use Theme Colors

```dart
// DO
Container(color: colors.container)
AppText('Hi', color: colors.gold)
```

#### ❌ Using Wrong Opacity Method

```dart
// DON'T (old API)
color.withOpacity(0.5)

// DO (new API)
color.withValues(alpha: 0.5)
```

#### ❌ Assuming Theme

```dart
// DON'T
final textColor = AppColors.textPrimary; // Always dark theme color

// DO
final textColor = colors.textPrimary; // Theme-aware
```

### Performance Tips

#### 1. Cache Theme Values

```dart
@override
Widget build(BuildContext context) {
  // Cache these at the top of build()
  final colors = context.colors;
  final isDark = context.isDarkMode;
  final gradients = context.appGradients;

  // Now use them without repeated lookups
  return Container(color: colors.canvas);
}
```

#### 2. Use `const` Where Possible

```dart
// If the color never changes
const BoxDecoration(
  color: AppColors.gold500,  // This is OK if intentional
)

// If it should adapt to theme
BoxDecoration(
  color: colors.gold,  // Cannot be const
)
```

#### 3. Avoid Rebuilding on Theme Change

```dart
// Use `Consumer` or `watch` only for parts that need theme
Consumer(
  builder: (context, ref, child) {
    final colors = context.colors;
    return Container(color: colors.canvas, child: child);
  },
  child: ExpensiveWidget(), // This won't rebuild
)
```

### Accessibility Checklist

- [ ] All text has sufficient contrast (use `colors` helper)
- [ ] Interactive elements are distinguishable
- [ ] Focus indicators are visible
- [ ] Color is not the only way to convey information
- [ ] Test with screen reader (VoiceOver/TalkBack)
- [ ] Support system theme preference

### Debugging Theme Issues

#### Issue: Colors not updating on theme change

**Solution:** Make sure you're using `context.colors`, not `AppColors` directly

```dart
// Wrong
color: AppColors.gold500  // Static, won't update

// Right
color: context.colors.gold  // Dynamic, updates with theme
```

#### Issue: Gradient looks wrong in light theme

**Solution:** Check if you're using the right gradient variant

```dart
// Use theme-aware gradients
final gradient = context.isDarkMode
    ? context.appGradients.goldGradient       // Dark variant
    : context.appGradients.goldGradient;      // Light variant (automatically switches)
```

#### Issue: Shadow not visible

**Solution:** Adjust opacity based on theme

```dart
BoxShadow(
  color: context.isDarkMode
      ? Colors.black.withValues(alpha: 0.3)   // Stronger in dark
      : Colors.black.withValues(alpha: 0.1),  // Lighter in light
)
```

### Quick Reference

| Need | Use |
|------|-----|
| Background color | `colors.canvas` or `colors.container` |
| Text color | `colors.textPrimary/Secondary/Tertiary` |
| Gold accent | `colors.gold` |
| Border | `colors.border` or `colors.borderGold` |
| Shadow | `context.appShadows.card` |
| Gradient | `context.appGradients.goldGradient` |
| Check theme | `context.isDarkMode` |

### Further Reading

- `/lib/design/tokens/theme_colors.dart` - Theme color system
- `/lib/design/theme/theme_extensions.dart` - Custom theme extensions
- `/lib/design/tokens/colors.dart` - Base color definitions
- `THEME_COLOR_REFERENCE.md` - All color values
- `WALLET_CARD_THEME_UPDATE.md` - Full implementation details
