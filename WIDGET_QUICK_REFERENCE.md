# Widget Quick Reference Card

One-page reference for JoonaPay widget development.

## File Locations

```
Flutter:    lib/services/widget_data/
iOS:        ios/BalanceWidget/ + ios/Runner/WidgetMethodChannel.swift
Android:    android/app/src/main/java/.../widget/
Docs:       HOME_SCREEN_WIDGETS.md, WIDGET_SETUP_INSTRUCTIONS.md
```

## Quick Start

### Initialize in App
```dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(widgetAutoUpdaterProvider); // ← Add this line
    return MaterialApp(...);
  }
}
```

### Update Balance
```dart
// Automatic (recommended)
// Just update wallet state - auto-updater handles it

// Manual
final manager = ref.read(widgetUpdateManagerProvider);
await manager.updateFromState(
  balance: 1234.56,
  currency: 'USD',
  userName: 'Amadou Diallo',
);
```

### Clear on Logout
```dart
await ref.read(widgetUpdateManagerProvider).clearWidgetData();
```

## Providers

```dart
// Auto-updater (watches state changes)
ref.watch(widgetAutoUpdaterProvider);

// Manual updates
final manager = ref.read(widgetUpdateManagerProvider);
```

## Platform Setup

### iOS Checklist
- [ ] Create Widget Extension target
- [ ] Enable App Groups (group.com.joonapay.usdcwallet)
- [ ] Copy BalanceWidget.swift
- [ ] Add WidgetMethodChannel.swift
- [ ] Update AppDelegate
- [ ] Build and test

### Android Checklist
- [ ] Add WorkManager dependency
- [ ] Copy widget Kotlin files
- [ ] Copy resource XML files
- [ ] Update AndroidManifest.xml
- [ ] Update MainActivity
- [ ] Build and test

## Deep Links

| Link | Opens |
|------|-------|
| `joonapay://home` | Home screen |
| `joonapay://send` | Send flow |
| `joonapay://receive` | Receive QR |

## Design Tokens

```dart
Colors:
  Background:  obsidian (#0A0A0C) → graphite (#111115)
  Accent:      gold500 (#C9A962)
  Text:        textPrimary (#F5F5F0)
  Secondary:   textSecondary (#9A9A9E)
  Button BG:   slate (#1A1A1F)

Spacing:
  Widget padding: 16dp/pt
  Element spacing: 8dp/pt
  Border radius: 8-16dp/pt

Typography:
  App name: 11sp, SemiBold
  Balance: 18-24sp, Bold
  Label: 10-11sp, Regular
```

## Data Schema

```dart
// Stored keys
widget_balance        // Double
widget_currency       // String (USD, XOF)
widget_last_updated   // ISO 8601 String
widget_user_name      // String (optional)
widget_last_transaction // JSON
```

## Testing

### iOS Simulator
```bash
# Add widget to home screen
Long press → "+" → "JoonaPay" → Select size

# Force refresh
xcrun simctl ui booted refreshWidgets
```

### Android Emulator
```bash
# Add widget
Long press → "Widgets" → "JoonaPay Balance Widget"

# Force update
adb shell am broadcast -a com.joonapay.usdc_wallet.UPDATE_WIDGET
```

## Common Issues

| Issue | Solution |
|-------|----------|
| iOS widget not updating | Check App Group ID matches |
| Android widget blank | Verify SharedPreferences key names |
| Data not persisting | Enable encrypted SharedPreferences |
| Auto-updater not working | Ensure provider is watched in main app |

## Performance

- Update latency: <500ms
- Memory: <5MB per widget
- Battery: Minimal (15min intervals)
- Storage: ~2KB

## Security

- ✅ Encrypted storage
- ✅ Auto-clear on logout
- ✅ Minimal data (balance, name only)
- ❌ No credentials
- ❌ No private keys
- ❌ No transaction history

## Widget Sizes

**iOS:**
- Small: 2x2 cells (~158x158 points)
- Medium: 4x2 cells (~360x158 points)

**Android:**
- Small: 2x1 cells (110dp min width)
- Medium: 4x1 cells (250dp min width)

## API Reference

### WidgetDataService
```dart
// Update balance
await service.updateBalance(
  balance: double,
  currency: String,
  userName: String?,
);

// Update transaction
await service.updateLastTransaction(
  type: String,
  amount: double,
  currency: String,
  status: String,
  recipientName: String?,
);

// Get data
final data = await service.getWidgetData();

// Clear
await service.clearWidgetData();
```

### WidgetUpdateManager
```dart
// Update from state
await manager.updateFromState(
  balance: double,
  currency: String,
  userName: String?,
);

// Update transaction
await manager.updateLastTransaction(...);

// Clear
await manager.clearWidgetData();
```

## Build Commands

```bash
# iOS
cd ios && pod install && cd ..
flutter build ios

# Android
flutter build apk --debug

# Run
flutter run -d "iPhone 15 Pro"
flutter run -d emulator-5554

# Clean
flutter clean
```

## Dependencies

Already in pubspec.yaml:
- flutter_secure_storage (iOS Keychain)
- shared_preferences (Android storage)

Android only (add to build.gradle):
- androidx.work:work-runtime-ktx:2.8.1

## Platform Requirements

- iOS: 14.0+ (WidgetKit)
- Android: 6.0+ (API 23)
- Flutter: 3.10.7+

## Method Channel

```kotlin
// Android
channel.setMethodCallHandler { call, result ->
  when (call.method) {
    "updateWidget" -> {
      BalanceWidgetProvider.updateWidgets(context)
      result.success(null)
    }
  }
}
```

```swift
// iOS
channel.setMethodCallHandler { call, result in
  switch call.method {
  case "updateWidget":
    WidgetCenter.shared.reloadAllTimelines()
    result(nil)
  }
}
```

## Widget States

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Loading     │  │   Loaded     │  │    Error     │
│              │  │              │  │              │
│  ─────       │  │  $1,234.56   │  │ Unable to    │
│  ───         │  │  John Doe    │  │ load data    │
└──────────────┘  └──────────────┘  └──────────────┘
```

## Troubleshooting Steps

1. Check console logs
2. Verify method channel registered
3. Confirm App Group / SharedPreferences setup
4. Test data storage manually
5. Force widget refresh
6. Rebuild app
7. Check platform-specific logs

## Documentation Links

- Setup: WIDGET_SETUP_INSTRUCTIONS.md
- Full docs: HOME_SCREEN_WIDGETS.md
- Service: lib/services/widget_data/README.md
- Visual: WIDGET_VISUAL_REFERENCE.md
- Examples: lib/services/widget_data/integration_example.dart

## Support

Check documentation in this order:
1. WIDGET_QUICK_REFERENCE.md (this file)
2. WIDGET_SETUP_INSTRUCTIONS.md
3. HOME_SCREEN_WIDGETS.md
4. Platform-specific docs

---

**Last Updated**: January 29, 2026
**Version**: 1.0.0
