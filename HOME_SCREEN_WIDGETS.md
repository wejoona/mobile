# Home Screen Widgets

JoonaPay provides native home screen widgets for both iOS and Android platforms, allowing users to view their balance and access quick actions without opening the app.

## Features

### Widget Sizes

**iOS (WidgetKit)**
- **Small (2x2)**: Balance display only
- **Medium (4x2)**: Balance + Quick action buttons (Send/Receive)

**Android (AppWidget)**
- **Small (2x1)**: Balance display only
- **Medium (4x1)**: Balance + Quick action buttons (Send/Receive)

### Displayed Information

1. **Current Balance**: USDC balance formatted according to currency
2. **User Name**: Display name from user profile
3. **Quick Actions** (medium widget only):
   - Send button (opens send flow)
   - Receive button (opens receive QR code)
4. **Last Updated**: Automatic refresh every 15 minutes

### Security & Privacy

- **No sensitive data on lock screen**: Widgets respect device security settings
- **Secure data sharing**: Uses iOS Keychain (App Groups) and Android encrypted shared preferences
- **Auto-clear on logout**: Widget data is cleared when user logs out
- **Background refresh limits**: Updates are throttled to preserve battery

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Flutter App                        │
│  ┌──────────────────────────────────────────────┐   │
│  │  WidgetUpdateManager                          │   │
│  │  - Watches wallet state changes               │   │
│  │  - Updates shared data                        │   │
│  │  - Notifies native widgets                    │   │
│  └──────────────────────────────────────────────┘   │
│                      ↓                               │
│  ┌──────────────────────────────────────────────┐   │
│  │  WidgetDataService                            │   │
│  │  - Stores data in secure storage              │   │
│  │  - iOS: Keychain with App Group              │   │
│  │  - Android: Encrypted SharedPreferences       │   │
│  └──────────────────────────────────────────────┘   │
│                      ↓                               │
└─────────────────────────────────────────────────────┘
                       ↓
         ┌─────────────┴─────────────┐
         ↓                           ↓
┌────────────────┐          ┌────────────────┐
│  iOS Widget    │          │ Android Widget │
│  (WidgetKit)   │          │ (AppWidget)    │
│                │          │                │
│  - Swift UI    │          │  - Kotlin      │
│  - App Groups  │          │  - RemoteViews │
└────────────────┘          └────────────────┘
```

## Setup Instructions

### iOS Setup

#### 1. Add Widget Extension Target

1. In Xcode, open `ios/Runner.xcworkspace`
2. File → New → Target → Widget Extension
3. Name: `BalanceWidget`
4. Bundle ID: `com.joonapay.usdcwallet.BalanceWidget`
5. Uncheck "Include Configuration Intent"

#### 2. Configure App Groups

1. Select Runner target → Signing & Capabilities
2. Click "+ Capability" → App Groups
3. Add group: `group.com.joonapay.usdcwallet`
4. Select BalanceWidget target → Signing & Capabilities
5. Click "+ Capability" → App Groups
6. Add same group: `group.com.joonapay.usdcwallet`

#### 3. Update Info.plist

Add App Group identifier to Runner's `Info.plist`:

```xml
<key>AppGroupIdentifier</key>
<string>group.com.joonapay.usdcwallet</string>
```

#### 4. Add Widget Files

The widget files are already created in `ios/BalanceWidget/`:
- `BalanceWidget.swift` - Widget implementation
- `Info.plist` - Widget configuration

#### 5. Register Method Channel

In `ios/Runner/AppDelegate.swift`, add:

```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var widgetChannel: WidgetMethodChannel?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController

        // Setup widget channel
        widgetChannel = WidgetMethodChannel(
            binaryMessenger: controller.binaryMessenger
        )

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### 6. Build & Run

```bash
cd ios
pod install
cd ..
flutter build ios
```

### Android Setup

#### 1. Update AndroidManifest.xml

Add widget receiver and service in `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- Existing activity declaration -->

    <!-- Widget Provider -->
    <receiver
        android:name=".widget.BalanceWidgetProvider"
        android:exported="false">
        <intent-filter>
            <action android:name="android.appwidget.action.APPWIDGET_UPDATE" />
            <action android:name="com.joonapay.usdc_wallet.UPDATE_WIDGET" />
        </intent-filter>
        <meta-data
            android:name="android.appwidget.provider"
            android:resource="@xml/balance_widget_info" />
    </receiver>

    <!-- Widget Update Service -->
    <service
        android:name=".widget.WidgetUpdateService"
        android:exported="false" />
</application>
```

#### 2. Add WorkManager Dependency

In `android/app/build.gradle`:

```gradle
dependencies {
    // Existing dependencies

    // WorkManager for widget updates
    implementation "androidx.work:work-runtime-ktx:2.8.1"
}
```

#### 3. Add Widget Strings

In `android/app/src/main/res/values/strings.xml`:

```xml
<resources>
    <!-- Existing strings -->

    <string name="widget_description">View your JoonaPay balance and quick actions</string>
</resources>
```

#### 4. Register Method Channel

Update `android/app/src/main/java/com/joonapay/usdc_wallet/MainActivity.kt`:

```kotlin
package com.joonapay.usdc_wallet

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var widgetChannel: WidgetMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup widget channel
        widgetChannel = WidgetMethodChannel(this, flutterEngine)
    }
}
```

#### 5. Build & Run

```bash
flutter build apk --debug
```

## Flutter Integration

### Initialize Widget Auto-Updater

In your main app widget, initialize the auto-updater:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/widget_data/widget_update_manager.dart';

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize widget auto-updater
    ref.watch(widgetAutoUpdaterProvider);

    return MaterialApp(
      // Your app configuration
    );
  }
}
```

### Manual Widget Updates

You can manually trigger widget updates:

```dart
// Update balance
final widgetManager = ref.read(widgetUpdateManagerProvider);
await widgetManager.updateFromState(
  balance: 1234.56,
  currency: 'USD',
  userName: 'Amadou Diallo',
);

// Update last transaction
await widgetManager.updateLastTransaction(
  type: 'send',
  amount: 50.0,
  currency: 'USD',
  status: 'completed',
  recipientName: 'Fatou Traore',
);

// Clear on logout
await widgetManager.clearWidgetData();
```

## Design Tokens

Widgets use the same design system as the app:

### Colors

```dart
// Dark mode (primary)
obsidian: #0A0A0C      // Background gradient start
graphite: #111115      // Background gradient end
slate: #1A1A1F         // Button backgrounds
gold500: #C9A962       // Accent color
textPrimary: #F5F5F0   // Balance text
textSecondary: #9A9A9E // Labels
```

### Typography

- App name: 11-12sp, Medium weight
- Balance: 18-24sp, Bold weight
- Labels: 10-11sp, Regular weight
- Button text: 9sp, Medium weight

### Spacing

- Widget padding: 16dp
- Element spacing: 8dp
- Button height: 60dp (small), dynamic (medium)
- Border radius: 8-16dp

## Deep Linking

Widgets use deep links to open specific app sections:

| Action | Deep Link | Destination |
|--------|-----------|-------------|
| Tap widget | `joonapay://home` | Home screen |
| Send button | `joonapay://send` | Send flow |
| Receive button | `joonapay://receive` | Receive QR |

Ensure deep linking is configured in your app router.

## Privacy Considerations

### Data Minimization

- Only store essential data (balance, currency, name)
- No transaction history stored
- No account numbers or wallet addresses
- No authentication credentials

### User Control

- Users can remove widgets anytime
- Data is cleared on logout
- Widgets respect system privacy settings
- No data collection or analytics in widgets

### Lock Screen

- iOS: Widgets respect "Show on Lock Screen" setting
- Android: Widgets use `initialKeyguardLayout` for lock screen display
- Consider privacy when deciding what to show on lock screen

## Testing

### iOS Widget Testing

1. Run app in simulator
2. Long press home screen → "+" button
3. Find "JoonaPay" in widget gallery
4. Add small or medium widget
5. Verify balance displays correctly
6. Test quick action buttons (medium widget)
7. Force quit app and verify widget persists

### Android Widget Testing

1. Run app on emulator/device
2. Long press home screen → "Widgets"
3. Find "JoonaPay Balance Widget"
4. Drag to home screen
5. Resize to test different layouts
6. Verify balance displays correctly
7. Test quick action buttons
8. Restart device and verify widget persists

### Data Update Testing

```dart
// Trigger manual update
final widgetManager = ref.read(widgetUpdateManagerProvider);
await widgetManager.updateFromState(
  balance: 9999.99,
  currency: 'USD',
  userName: 'Test User',
);

// Wait a moment
await Future.delayed(Duration(seconds: 2));

// Check widget reflects new balance
```

## Troubleshooting

### iOS Issues

**Widget not updating**
- Check App Group is enabled for both targets
- Verify App Group ID matches in code and entitlements
- Check UserDefaults is using correct suite name
- Force reload: `WidgetCenter.shared.reloadAllTimelines()`

**Build errors**
- Clean build folder: Product → Clean Build Folder
- Update pods: `cd ios && pod install`
- Check Swift version compatibility

### Android Issues

**Widget not appearing**
- Verify receiver is registered in AndroidManifest.xml
- Check resource files exist (@xml/balance_widget_info)
- Verify min/target SDK versions

**Data not updating**
- Check SharedPreferences key names match
- Verify widget provider is receiving broadcasts
- Check WorkManager is scheduled correctly

**Layout issues**
- Test on different screen sizes
- Verify dimension values (dp vs sp)
- Check resource IDs match layout files

## Performance

### Battery Impact

- **iOS**: WidgetKit manages timeline updates efficiently
- **Android**: Updates limited to 15-minute intervals
- Background updates use WorkManager with battery constraints
- No continuous background processes

### Memory Usage

- Small footprint: < 5MB per widget instance
- Shared data cached in memory
- No image caching (uses vector graphics)

### Network Usage

- Widgets display cached data only
- No direct network requests from widgets
- Updates triggered by main app

## Future Enhancements

Potential widget improvements:

1. **Large Widget**: Show recent transactions list
2. **Customization**: Allow users to choose displayed currency
3. **Interactive Elements**: In-widget amount input (iOS 17+)
4. **Dynamic Island**: Quick balance view (iOS 16+)
5. **Complications**: Apple Watch support
6. **Android 12+ Dynamic Colors**: Adapt to system theme
7. **Smart Refresh**: Update on specific events (transaction completed)

## Files Reference

### Flutter Files

```
lib/services/widget_data/
├── widget_data_service.dart       # Data storage service
├── widget_update_manager.dart     # Update management & auto-updater
└── README.md                      # Service documentation
```

### iOS Files

```
ios/
├── BalanceWidget/
│   ├── BalanceWidget.swift        # Widget implementation
│   └── Info.plist                 # Widget configuration
└── Runner/
    └── WidgetMethodChannel.swift  # Flutter-iOS bridge
```

### Android Files

```
android/app/src/main/
├── java/com/joonapay/usdc_wallet/
│   ├── WidgetMethodChannel.kt                          # Flutter-Android bridge
│   └── widget/
│       ├── BalanceWidgetProvider.kt                    # Widget provider
│       └── WidgetUpdateService.kt                      # Background updates
└── res/
    ├── layout/
    │   ├── widget_balance_small.xml                    # 2x1 layout
    │   └── widget_balance_medium.xml                   # 4x1 layout
    ├── drawable/
    │   ├── widget_background.xml                       # Gradient background
    │   ├── widget_button_background.xml                # Button style
    │   ├── ic_send.xml                                 # Send icon
    │   └── ic_receive.xml                              # Receive icon
    └── xml/
        └── balance_widget_info.xml                     # Widget metadata
```

## Resources

- [iOS WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Android App Widgets Guide](https://developer.android.com/guide/topics/appwidgets)
- [Flutter Platform Channels](https://docs.flutter.dev/development/platform-integration/platform-channels)
- [iOS App Groups](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)
- [Android WorkManager](https://developer.android.com/topic/libraries/architecture/workmanager)
