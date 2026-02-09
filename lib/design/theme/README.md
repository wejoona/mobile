# Theme System Documentation

## Overview

JoonaPay's theme system provides a robust, reactive theming solution with support for light, dark, and system-based themes. The system automatically responds to device theme changes in real-time when system mode is active.

## Features

- **Three theme modes**: Light, Dark, System (follows device settings)
- **Real-time updates**: Instantly responds to system theme changes
- **Persistent preferences**: Saves user's theme choice securely
- **Smooth transitions**: Animated theme switching with status bar updates
- **System UI integration**: Automatic status bar and navigation bar styling

## Architecture

### Core Components

1. **ThemeProvider** (`theme_provider.dart`)
   - State management via Riverpod
   - Persistent storage via flutter_secure_storage
   - Theme mode control (system/light/dark)

2. **SystemBrightnessObserver** (`theme_provider.dart`)
   - WidgetsBindingObserver mixin
   - Listens for platform brightness changes
   - Automatically updates UI when system theme changes

3. **ThemeState** (`theme_provider.dart`)
   - Immutable state class
   - Methods to resolve theme based on mode and system brightness
   - System UI overlay style generation

## Usage

### Basic Setup (Already configured in main.dart)

```dart
class JoonaPayApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    return SystemBrightnessObserver(
      child: MaterialApp.router(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _getThemeMode(themeState.mode),
        // ... other config
      ),
    );
  }
}
```

### Changing Theme Mode

```dart
// Set to light mode
ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.light);

// Set to dark mode
ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.dark);

// Set to system mode (follows device settings)
ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system);

// Toggle between light and dark
ref.read(themeProvider.notifier).toggleTheme();
```

### Reading Current Theme

```dart
// Get current theme mode
final themeState = ref.watch(themeProvider);
final mode = themeState.mode; // AppThemeMode.system, .light, or .dark

// Check if current theme is dark
final systemBrightness = MediaQuery.platformBrightnessOf(context);
final isDark = themeState.isDark(systemBrightness);

// Get theme data
final theme = themeState.getTheme(systemBrightness);

// Get system UI style
final uiStyle = themeState.getSystemUiStyle(systemBrightness);
```

### Theme Settings UI

See `features/settings/views/theme_settings_view.dart` for a complete implementation with:
- Visual theme previews
- Animated selection indicators
- Haptic feedback
- Localized labels

## How System Theme Changes Work

### 1. Device Theme Change Detection

When the user changes their device's theme (iOS Settings > Display, Android Settings > Display):

```dart
class _SystemBrightnessObserverState extends ConsumerState<SystemBrightnessObserver>
    with WidgetsBindingObserver {
  
  @override
  void didChangePlatformBrightness() {
    // Called automatically by Flutter when device theme changes
    final currentBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    
    // Update system UI overlay
    final themeState = ref.read(themeProvider);
    SystemChrome.setSystemUIOverlayStyle(
      themeState.getSystemUiStyle(currentBrightness),
    );
    
    // Trigger rebuild
    setState(() {});
  }
}
```

### 2. Automatic Theme Switching

When `AppThemeMode.system` is active:

1. User changes device theme (Settings app)
2. Flutter calls `didChangePlatformBrightness()`
3. SystemBrightnessObserver updates system UI overlay
4. MaterialApp automatically switches theme via `themeMode: ThemeMode.system`
5. All widgets rebuild with new theme

### 3. Status Bar & Navigation Bar

Status bar and navigation bar colors update automatically:

```dart
SystemUiOverlayStyle getSystemUiStyle(Brightness systemBrightness) {
  final isDark = mode == AppThemeMode.dark ||
      (mode == AppThemeMode.system && systemBrightness == Brightness.dark);

  if (isDark) {
    return SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.graphite,
      // ...
    );
  } else {
    return SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColorsLight.container,
      // ...
    );
  }
}
```

## Theme Persistence

Theme preferences are stored securely using `flutter_secure_storage`:

```dart
// Saved when theme changes
await _storage.write(key: 'app_theme_mode', value: mode.name);

// Loaded on app start
final savedMode = await _storage.read(key: 'app_theme_mode');
```

- **Android**: Uses EncryptedSharedPreferences
- **iOS**: Uses Keychain (accessible after first unlock)

## Performance Considerations

### Optimizations

1. **Change Detection**: Only updates when brightness actually changes
   ```dart
   if (_lastBrightness != currentBrightness) {
     _lastBrightness = currentBrightness;
     // Update logic
   }
   ```

2. **Widget Rebuild Scope**: SystemBrightnessObserver wraps the entire MaterialApp, so theme changes rebuild the whole app tree (necessary for theme updates)

3. **Smooth Transitions**: MaterialApp has built-in theme animation
   ```dart
   themeAnimationDuration: const Duration(milliseconds: 400),
   themeAnimationCurve: Curves.easeInOut,
   ```

4. **Lazy Loading**: Theme is loaded asynchronously on app start without blocking UI

## Testing System Theme Changes

### iOS Simulator
1. Run app with system mode: `ref.read(themeProvider.notifier).setThemeMode(AppThemeMode.system)`
2. Open iOS Settings > Developer > Dark Appearance
3. Toggle on/off to see instant theme updates

### Android Emulator
1. Run app with system mode
2. Open Settings > Display > Dark theme
3. Toggle to see instant theme updates

### Programmatic Testing
```dart
// Simulate brightness change in tests
tester.binding.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
await tester.pumpAndSettle();
```

## Troubleshooting

### Theme not updating on device change
- Check that `SystemBrightnessObserver` wraps MaterialApp in main.dart
- Verify theme mode is set to `AppThemeMode.system`
- Ensure `themeMode` parameter uses `ThemeMode.system` for system mode

### Status bar colors not updating
- Check that `didChangePlatformBrightness()` calls `SystemChrome.setSystemUIOverlayStyle()`
- Verify colors are defined in `getSystemUiStyle()`
- On Android, ensure `SystemChrome.setSystemUIOverlayStyle()` is called in main widget's build

### Theme preference not persisting
- Check flutter_secure_storage permissions (Android manifest, iOS capabilities)
- Verify storage write happens in `setThemeMode()`
- Check for exceptions in storage operations (currently silently caught)

## Advanced Usage

### Custom Theme Transitions

For custom theme transitions (e.g., circular reveal), see `theme_transition.dart`:

```dart
await ref.read(themeProvider.notifier).toggleThemeWithReveal(
  context: context,
  revealCenter: tapPosition,
);
```

### Accessing Theme Colors

Use theme extensions for type-safe color access:

```dart
final colors = context.colors;
final goldColor = colors.gold;
final textPrimary = colors.textPrimary;
```

See `theme_extensions.dart` for all available color accessors.

## Related Files

- `app_theme.dart` - ThemeData definitions for light/dark themes
- `theme_extensions.dart` - Context extensions for easy theme access
- `theme_transition.dart` - Smooth status bar transitions
- `../tokens/colors.dart` - Color palette definitions
- `../../features/settings/views/theme_settings_view.dart` - Settings UI

## Architecture Decisions

### Why WidgetsBindingObserver?

- More reliable than MediaQuery polling
- System-level callback, not widget-level
- Called immediately when device theme changes
- No performance overhead from repeated checks

### Why Wrap Entire MaterialApp?

- MaterialApp's `themeMode` parameter handles theme switching
- Ensures all routes and dialogs get updated
- Simplifies implementation (no manual propagation)

### Why Secure Storage for Theme Preference?

- Consistency with other app preferences (PIN, auth tokens)
- Encrypted on Android
- Keychain-backed on iOS
- Simple API, no additional dependencies

## Example Implementation

Complete working example in `/features/settings/views/theme_settings_view.dart`:

- Beautiful theme selection cards
- Visual previews of each theme
- Animated selection states
- System mode shows split light/dark preview
- Haptic feedback on selection

---

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Device Settings                         │
│  (iOS: Settings > Display, Android: Settings > Display)    │
└──────────────────────┬──────────────────────────────────────┘
                       │ User changes theme
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              Flutter Platform Dispatcher                    │
│     WidgetsBinding.instance.platformDispatcher              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Fires platformBrightness change event
                       ▼
┌─────────────────────────────────────────────────────────────┐
│           SystemBrightnessObserver                          │
│        (WidgetsBindingObserver mixin)                       │
│                                                             │
│  didChangePlatformBrightness() {                            │
│    1. Get current brightness                                │
│    2. Compare with last brightness                          │
│    3. Update system UI overlay                              │
│    4. Trigger widget rebuild                                │
│  }                                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ Reads theme state
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  ThemeProvider                              │
│                  (Riverpod State)                           │
│                                                             │
│  ThemeState {                                               │
│    mode: AppThemeMode.system                                │
│    getTheme(brightness) → ThemeData                         │
│    getSystemUiStyle(brightness) → SystemUiOverlayStyle      │
│  }                                                          │
└──────────────────────┬──────────────────────────────────────┘
                       │ Applies theme
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  MaterialApp.router                         │
│                                                             │
│  theme: AppTheme.lightTheme                                 │
│  darkTheme: AppTheme.darkTheme                              │
│  themeMode: ThemeMode.system  ← Switches automatically      │
│  themeAnimationDuration: 400ms                              │
└──────────────────────┬──────────────────────────────────────┘
                       │ Rebuilds with new theme
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    App Widgets                              │
│         (All routes, screens, components)                   │
│                                                             │
│  - Status bar colors update                                 │
│  - Text colors update                                       │
│  - Background colors update                                 │
│  - Component colors update                                  │
│  - Smooth 400ms animation                                   │
└─────────────────────────────────────────────────────────────┘
```

## State Flow for Different Theme Modes

### System Mode (AppThemeMode.system)
```
Device: Dark Mode ON
        ↓
SystemBrightnessObserver: brightness = Brightness.dark
        ↓
ThemeState: mode = system, brightness = dark
        ↓
MaterialApp: Uses darkTheme
        ↓
UI: Dark colors rendered
```

### Light Mode (AppThemeMode.light)
```
Device: Dark Mode ON
        ↓
SystemBrightnessObserver: brightness = Brightness.dark (ignored)
        ↓
ThemeState: mode = light (overrides system)
        ↓
MaterialApp: Uses theme (light)
        ↓
UI: Light colors rendered
```

### Dark Mode (AppThemeMode.dark)
```
Device: Dark Mode OFF
        ↓
SystemBrightnessObserver: brightness = Brightness.light (ignored)
        ↓
ThemeState: mode = dark (overrides system)
        ↓
MaterialApp: Uses darkTheme
        ↓
UI: Dark colors rendered
```

