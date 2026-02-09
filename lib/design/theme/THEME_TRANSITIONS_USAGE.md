# Theme Transition System - Usage Guide

Enhanced theme transition system with smooth animations, status bar transitions, and multiple visual effects.

## Features

1. **Smooth animated transitions** when switching between themes
2. **Status bar color animation** with interpolation during theme changes
3. **Circular reveal animation** option for theme toggle
4. **Ripple effect** for theme toggle buttons
5. **System brightness change detection** with smooth transitions
6. **Multiple toggle button styles**

## Quick Start

### 1. Basic Theme Toggle Button

```dart
// In your settings screen
ThemeToggleButton(
  style: ThemeToggleStyle.iconButton,
)
```

### 2. Switch Style Toggle

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.switchButton,
  showLabel: true,
  lightLabel: l10n.settings_lightMode,
  darkLabel: l10n.settings_darkMode,
)
```

### 3. Segmented Control (System/Light/Dark)

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.segmentedControl,
)
```

### 4. Programmatic Theme Toggle

```dart
// Simple toggle
final notifier = ref.read(themeProvider.notifier);
await notifier.toggleTheme(
  systemBrightness: MediaQuery.platformBrightnessOf(context),
  animated: true,
);

// Set specific mode
await notifier.setThemeMode(
  AppThemeMode.dark,
  systemBrightness: MediaQuery.platformBrightnessOf(context),
  animated: true,
);
```

## Advanced Usage

### Circular Reveal Animation

```dart
// Wrap a widget with circular reveal effect
ThemeTransition.circularReveal(
  context: context,
  center: Offset(screenWidth / 2, screenHeight / 2),
  child: MyWidget(),
)
```

### Ripple Effect

```dart
// Show ripple from a specific point
ThemeTransition.ripple(
  context: context,
  center: tapPosition,
  child: MyWidget(),
  rippleColor: Colors.blue.withOpacity(0.3),
)
```

### Theme-Aware Animated Builder

```dart
// Automatically animate when theme changes
ThemeAwareAnimatedBuilder(
  duration: Duration(milliseconds: 300),
  builder: (context, theme) {
    return Container(
      color: theme.colorScheme.background,
      child: MyContent(),
    );
  },
)
```

### Theme Transition Wrapper

```dart
// Wrap screens that should animate on theme change
ThemeTransitionWrapper(
  type: ThemeTransitionType.slideAndFade,
  child: MyScreen(),
)
```

## Status Bar Transitions

### Automatic (Recommended)

Status bar transitions happen automatically when you toggle the theme using `themeProvider.notifier`.

### Manual Control

```dart
// Smooth transition
await StatusBarTransition.setForTheme(
  isDark: true,
  duration: Duration(milliseconds: 300),
);

// Immediate transition
StatusBarTransition.setImmediate(
  SystemUiOverlayStyle.light,
);

// Custom animated transition
await StatusBarTransition.animate(
  from: previousStyle,
  to: newStyle,
  duration: Duration(milliseconds: 400),
);
```

## Available Transition Types

### 1. Fade (Default)

```dart
ThemeTransition.fade(
  child: myWidget,
  duration: Duration(milliseconds: 300),
)
```

### 2. Slide and Fade

```dart
ThemeTransition.slideAndFade(
  child: myWidget,
  duration: Duration(milliseconds: 400),
  begin: Offset(0, 0.05), // Slight upward slide
)
```

### 3. Scale and Fade

```dart
ThemeTransition.scaleAndFade(
  child: myWidget,
  duration: Duration(milliseconds: 350),
  beginScale: 0.98,
)
```

### 4. Circular Reveal

```dart
ThemeTransition.circularReveal(
  context: context,
  center: buttonPosition,
  child: myWidget,
  duration: Duration(milliseconds: 600),
)
```

## Theme Toggle Button Styles

### Icon Button

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.iconButton,
  size: 24,
)
```

### Switch Button

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.switchButton,
  showLabel: true,
  lightLabel: 'Light',
  darkLabel: 'Dark',
)
```

### Segmented Control

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.segmentedControl,
)
```

### Floating Action Button

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.fab,
  size: 28,
)
```

## System Brightness Handling

The system automatically detects when the device switches between light/dark mode and applies smooth transitions.

### Initialize on App Start

```dart
// In main.dart, after theme is loaded
WidgetsBinding.instance.addPostFrameCallback((_) {
  final systemBrightness = MediaQuery.platformBrightnessOf(context);
  ref.read(themeProvider.notifier).initializeStatusBar(systemBrightness);
});
```

### Manual Reset

```dart
// Reset to system theme
await ref.read(themeProvider.notifier).resetToSystem(
  systemBrightness: MediaQuery.platformBrightnessOf(context),
);
```

## Performance Considerations

- Transitions are optimized with `TweenAnimationBuilder` for smooth 60fps animations
- Status bar color interpolation uses 10 steps for perceived smoothness
- Ripple effects automatically clean up after animation completes
- All animations are hardware-accelerated

## Customization

### Custom Transition Duration

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.iconButton,
  // Duration is controlled in theme_transition.dart
  // Default: 300-400ms for most transitions
)
```

### Disable Ripple Effect

```dart
ThemeToggleButton(
  style: ThemeToggleStyle.iconButton,
  withRipple: false,
)
```

### Custom Status Bar Colors

```dart
await StatusBarTransition.setForTheme(
  isDark: true,
  customStatusBarColor: Colors.black,
  customNavBarColor: Color(0xFF1A1D21),
)
```

## Example: Settings Screen with Theme Toggle

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../design/theme/theme_toggle_button.dart';

class SettingsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_title),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: Icon(Icons.brightness_6),
            title: Text(l10n.settings_theme),
            trailing: ThemeToggleButton(
              style: ThemeToggleStyle.switchButton,
              showLabel: false,
            ),
          ),
          // Or use segmented control for full theme picker
          Padding(
            padding: EdgeInsets.all(16),
            child: ThemeToggleButton(
              style: ThemeToggleStyle.segmentedControl,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Troubleshooting

### Status bar not animating

Make sure you're passing `systemBrightness` when toggling theme:

```dart
await ref.read(themeProvider.notifier).toggleTheme(
  systemBrightness: MediaQuery.platformBrightnessOf(context),
  animated: true,
);
```

### Ripple not showing

Ensure the button has a valid render box before triggering ripple. The system automatically handles this, but if creating custom buttons, wait for layout:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  // Trigger ripple after layout
});
```

### System brightness changes not detected

Make sure `SystemBrightnessObserver` is wrapping your app (already included in theme_provider.dart).

## Files

- `/lib/design/theme/theme_transition.dart` - Core transition animations
- `/lib/design/theme/theme_provider.dart` - Theme state management with transitions
- `/lib/design/theme/theme_toggle_button.dart` - Reusable toggle button component
