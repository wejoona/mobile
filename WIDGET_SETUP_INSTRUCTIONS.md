# Widget Setup Instructions

Quick start guide for setting up JoonaPay home screen widgets.

## Prerequisites

- Flutter 3.10.7 or higher
- iOS deployment target: 14.0+
- Android minSdkVersion: 23+
- Xcode 14+ (for iOS development)
- Android Studio or VS Code with Flutter plugin

## Quick Setup

### 1. Update Dependencies

No additional Flutter dependencies needed. The widget uses existing packages:
- `flutter_secure_storage` (already in pubspec.yaml)
- `shared_preferences` (already in pubspec.yaml)

For Android, add WorkManager to `android/app/build.gradle`:

```gradle
dependencies {
    // Existing dependencies
    implementation "androidx.work:work-runtime-ktx:2.8.1"
}
```

### 2. iOS Setup (5 minutes)

#### A. Create Widget Extension in Xcode

```bash
# Open iOS project
cd ios
open Runner.xcworkspace
```

In Xcode:
1. File → New → Target
2. Select "Widget Extension"
3. Product Name: `BalanceWidget`
4. Language: Swift
5. Uncheck "Include Configuration Intent"
6. Click Finish
7. When prompted "Activate scheme?", click Activate

#### B. Configure App Groups

**For Runner target:**
1. Select Runner in project navigator
2. Select Runner target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability"
5. Select "App Groups"
6. Click "+" to add new group
7. Enter: `group.com.joonapay.usdcwallet`
8. Check the checkbox

**For BalanceWidget target:**
1. Select BalanceWidget target
2. Go to "Signing & Capabilities" tab
3. Click "+ Capability"
4. Select "App Groups"
5. Check `group.com.joonapay.usdcwallet`

#### C. Copy Widget Files

Replace the auto-generated widget files:

```bash
# From mobile directory
cp ios/BalanceWidget/BalanceWidget.swift ios/BalanceWidget/
cp ios/BalanceWidget/Info.plist ios/BalanceWidget/
```

Or manually copy the contents from the provided files.

#### D. Update AppDelegate

Edit `ios/Runner/AppDelegate.swift`:

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

        // Setup widget method channel
        widgetChannel = WidgetMethodChannel(
            binaryMessenger: controller.binaryMessenger
        )

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

#### E. Add WidgetMethodChannel.swift

Copy `ios/Runner/WidgetMethodChannel.swift` to your project in Xcode:
1. Right-click Runner folder in Xcode
2. New File → Swift File
3. Name: `WidgetMethodChannel`
4. Copy contents from provided file

#### F. Update Info.plist

Add to `ios/Runner/Info.plist`:

```xml
<key>AppGroupIdentifier</key>
<string>group.com.joonapay.usdcwallet</string>
```

### 3. Android Setup (5 minutes)

#### A. Copy Widget Files

```bash
# Create directory structure
mkdir -p android/app/src/main/java/com/joonapay/usdc_wallet/widget

# Copy Kotlin files (already created)
# - BalanceWidgetProvider.kt
# - WidgetUpdateService.kt
# - WidgetMethodChannel.kt
```

#### B. Copy Resource Files

The following files should already be in place:
```
android/app/src/main/res/
├── layout/
│   ├── widget_balance_small.xml
│   └── widget_balance_medium.xml
├── drawable/
│   ├── widget_background.xml
│   ├── widget_button_background.xml
│   ├── ic_send.xml
│   └── ic_receive.xml
├── xml/
│   └── balance_widget_info.xml
└── values/
    └── widget_strings.xml
```

#### C. Update AndroidManifest.xml

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Existing <activity> tag -->

        <!-- Add Widget Provider -->
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
</manifest>
```

#### D. Update MainActivity.kt

Edit `android/app/src/main/java/com/joonapay/usdc_wallet/MainActivity.kt`:

```kotlin
package com.joonapay.usdc_wallet

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    private lateinit var widgetChannel: WidgetMethodChannel

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup widget method channel
        widgetChannel = WidgetMethodChannel(this, flutterEngine)
    }
}
```

#### E. Add placeholder preview image

Create a simple preview image at:
```
android/app/src/main/res/drawable/widget_preview.png
```

Or create an XML drawable:
```xml
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#0A0A0C"/>
    <corners android:radius="16dp"/>
</shape>
```

Save as `android/app/src/main/res/drawable/widget_preview.xml`.

### 4. Flutter Integration (2 minutes)

#### A. Initialize Widget Auto-Updater

Edit your main app file (e.g., `lib/main.dart`):

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
      // Your existing app configuration
    );
  }
}
```

#### B. Clear Widgets on Logout

In your logout handler:

```dart
Future<void> _handleLogout() async {
  // Clear widget data
  await ref.read(widgetUpdateManagerProvider).clearWidgetData();

  // Continue with logout
  await ref.read(authProvider.notifier).logout();
}
```

## Build & Test

### iOS

```bash
# Install pods
cd ios
pod install
cd ..

# Run on iOS simulator
flutter run -d "iPhone 15 Pro"

# Build for device
flutter build ios
```

**Test Widget:**
1. Long press home screen
2. Tap "+" button (top left)
3. Scroll to find "JoonaPay"
4. Select widget size (Small or Medium)
5. Tap "Add Widget"

### Android

```bash
# Build debug APK
flutter build apk --debug

# Install on device/emulator
flutter install

# Run app
flutter run
```

**Test Widget:**
1. Long press home screen
2. Tap "Widgets" button
3. Scroll to find "JoonaPay Balance Widget"
4. Long press and drag to home screen
5. Resize if needed

## Verification Checklist

### iOS
- [ ] Widget appears in widget gallery
- [ ] Small widget displays balance correctly
- [ ] Medium widget shows Send/Receive buttons
- [ ] Tapping widget opens app
- [ ] Balance updates when app is used
- [ ] Widget persists after app force quit
- [ ] Widget respects dark mode

### Android
- [ ] Widget appears in widgets list
- [ ] Small (2x1) widget displays correctly
- [ ] Medium (4x1) widget shows quick actions
- [ ] Tapping widget opens app
- [ ] Send/Receive buttons work
- [ ] Balance updates when app is used
- [ ] Widget persists after device restart

## Troubleshooting

### iOS Issues

**"No such module 'WidgetKit'"**
- Solution: Set deployment target to iOS 14.0+ in Podfile and project settings

**Widget not appearing in gallery**
- Solution: Clean build folder (Cmd+Shift+K), rebuild

**App Group errors**
- Solution: Verify group ID is identical in both targets
- Check: Runner and BalanceWidget have same group checked

**Data not updating**
- Solution: Verify WidgetMethodChannel is initialized in AppDelegate
- Check: UserDefaults is using correct suite name

### Android Issues

**Widget not in widgets list**
- Solution: Verify receiver is registered in AndroidManifest.xml
- Check: balance_widget_info.xml exists in res/xml/

**Build errors on resource files**
- Solution: Sync Gradle files (File → Sync Project with Gradle Files)
- Check: All XML files are valid

**Buttons not working**
- Solution: Verify PendingIntent flags include FLAG_IMMUTABLE
- Check: Deep links are configured in app router

**Widget shows blank**
- Solution: Add default values in WidgetData constructor
- Check: SharedPreferences permissions

## Next Steps

1. **Test on real devices** - Widgets behave differently than in simulators
2. **Add custom icons** - Replace placeholder icons with app icons
3. **Configure deep links** - Ensure routes handle widget deep links
4. **Monitor performance** - Check battery impact in settings
5. **User testing** - Get feedback on widget UX

## Advanced Configuration

### Custom Widget Sizes

**iOS**: Support additional widget families by updating `supportedFamilies` in BalanceWidget.swift

**Android**: Create additional layouts and update widget_info.xml

### Background Updates

**iOS**: Adjust timeline update frequency in Provider

**Android**: Modify WorkManager interval in WidgetUpdateService

### Localization

Add widget strings to app localizations and update widget text rendering.

## Resources

- [Full Documentation](HOME_SCREEN_WIDGETS.md)
- [Widget Data Service README](lib/services/widget_data/README.md)
- [iOS WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [Android App Widgets](https://developer.android.com/guide/topics/appwidgets)
