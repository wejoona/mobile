# Push Notifications - Quick Start Guide

## 1. Verify Installation ✓

All files are created and dependencies are already in `pubspec.yaml`. No `flutter pub get` needed.

## 2. Configure Firebase (Required)

### Create Firebase Project
1. Go to https://console.firebase.google.com
2. Click "Add project"
3. Name: "JoonaPay Wallet" (or your preference)
4. Disable Google Analytics (optional)
5. Click "Create project"

### Add Android App
1. In Firebase Console, click "Add app" → Android
2. Android package name: `com.joonapay.wallet`
3. App nickname: "JoonaPay Android" (optional)
4. Click "Register app"
5. Download `google-services.json`
6. Save to: `/Users/macbook/JoonaPay/USDC-Wallet/mobile/android/app/google-services.json`

### Add iOS App
1. In Firebase Console, click "Add app" → iOS
2. iOS bundle ID: `com.joonapay.wallet`
3. App nickname: "JoonaPay iOS" (optional)
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Open Xcode: `open /Users/macbook/JoonaPay/USDC-Wallet/mobile/ios/Runner.xcworkspace`
7. Drag `GoogleService-Info.plist` into Runner folder
8. Ensure "Copy items if needed" is checked
9. Target: Runner

### Configure iOS Capabilities (Xcode)
1. In Xcode, select "Runner" target
2. Go to "Signing & Capabilities"
3. Click "+ Capability"
4. Add "Push Notifications"
5. Click "+ Capability" again
6. Add "Background Modes"
7. Check:
   - ☑ Remote notifications
   - ☑ Background fetch

### Upload APNs Key (iOS Only)
1. Go to https://developer.apple.com/account
2. Certificates, Identifiers & Profiles → Keys
3. Click "+" to create new key
4. Name: "JoonaPay APNs Key"
5. Check "Apple Push Notifications service (APNs)"
6. Download the `.p8` file (save it securely!)
7. Note your **Key ID** and **Team ID**
8. Go to Firebase Console → Project Settings → Cloud Messaging
9. Under "Apple app configuration"
10. Click "Upload" for APNs Authentication Key
11. Upload the `.p8` file
12. Enter your Team ID and Key ID

## 3. Update Android Configuration

Edit `/Users/macbook/JoonaPay/USDC-Wallet/mobile/android/app/src/main/AndroidManifest.xml`:

Add these permissions (inside `<manifest>`, before `<application>`):
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Add these metadata entries (inside `<application>`):
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@mipmap/ic_launcher" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
```

Create `/Users/macbook/JoonaPay/USDC-Wallet/mobile/android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#C9A962</color>
</resources>
```

## 4. Update iOS Configuration

Edit `/Users/macbook/JoonaPay/USDC-Wallet/mobile/ios/Runner/Info.plist`:

Add before closing `</dict>`:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## 5. Initialize Firebase in App

The app should already initialize Firebase. Verify in your `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(ProviderScope(child: MyApp()));
}
```

If not present, add the Firebase initialization.

## 6. Test on Device

### iOS (Must use real device)
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter run -d <your-iphone-name>
```

### Android (Can use emulator or device)
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter run -d <your-device-id>
```

## 7. Test Notifications

### Using Mock Data (Works Immediately)
1. Run the app
2. Login
3. Navigate to `/notifications`
4. You'll see 5 sample notifications
5. Test features:
   - Tap notification → navigates to detail
   - Swipe to delete
   - Mark all as read

### Using Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Notification title: "Test Notification"
4. Notification text: "This is a test from Firebase"
5. Click "Send test message"
6. Get FCM token from app logs (check console)
7. Paste token and send

### Get FCM Token
Add this to see your token in logs:
```dart
// In your app initialization
final pushService = ref.read(pushNotificationServiceProvider);
await pushService.initialize();
print('FCM Token: ${pushService.currentToken}');
```

### Test Deep Linking
Send notification with custom data:
```json
{
  "notification": {
    "title": "Payment Received",
    "body": "You got $50"
  },
  "data": {
    "type": "transactionComplete",
    "transactionId": "txn-123"
  }
}
```

Tap notification → Should navigate to `/transactions/txn-123`

## 8. Test Permission Flow

1. Fresh install app (or clear data)
2. Complete onboarding/login
3. Navigate to `/notifications/permission`
4. Tap "Enable Notifications"
5. Grant permission when prompted
6. Should see success message

## 9. Test Preferences

1. Navigate to Settings → Notifications
2. Open notification preferences
3. Toggle notification types
4. Set custom thresholds
5. Changes save automatically

## 10. Backend Integration (Optional)

Your backend needs to:

### Store FCM Tokens
```sql
-- Already exists in auth.devices table
ALTER TABLE auth.devices ADD COLUMN fcm_token VARCHAR(255);
```

### Send Notifications
```javascript
// Using Firebase Admin SDK
const admin = require('firebase-admin');

// Initialize (once)
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

// Send notification
await admin.messaging().send({
  token: user.fcmToken,
  notification: {
    title: 'Payment Received',
    body: 'You received $50'
  },
  data: {
    type: 'transactionComplete',
    transactionId: 'txn-123'
  }
});
```

## Troubleshooting

### Android: Build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### iOS: Provisioning profile error
1. Open Xcode
2. Select Runner target
3. Signing & Capabilities
4. Enable "Automatically manage signing"
5. Select your team

### Notifications not appearing on iOS
- **Check**: Using real device (not simulator)
- **Check**: APNs key uploaded to Firebase
- **Check**: Push Notifications capability enabled
- **Check**: App not in Do Not Disturb mode

### Permission request not showing
- **Check**: First time requesting (can only ask once)
- **Check**: Uninstall and reinstall app
- **Check**: `FirebaseAppDelegateProxyEnabled` is false

### Token not registering with backend
- **Check**: Network connectivity
- **Check**: Authentication token valid
- **Check**: Backend endpoint correct
- **Check**: Console logs for errors

## Commands Cheatsheet

```bash
# Run app
flutter run

# Generate localizations (already done)
flutter gen-l10n

# Clean build
flutter clean && flutter pub get

# iOS: Open Xcode
open ios/Runner.xcworkspace

# Android: Clean Gradle
cd android && ./gradlew clean && cd ..

# Check Firebase config
flutter run --verbose | grep -i firebase

# Run tests
flutter test

# Build release
flutter build apk --release  # Android
flutter build ipa --release  # iOS
```

## Navigation Routes

Test these routes in your app:

| Route | Description |
|-------|-------------|
| `/notifications` | Notification list |
| `/notifications/permission` | Permission request screen |
| `/notifications/preferences` | Notification settings |
| `/settings/notifications` | General notification settings |

## File Locations Reference

| File Type | Location |
|-----------|----------|
| Screens | `/lib/features/notifications/views/` |
| Providers | `/lib/features/notifications/providers/` |
| Services | `/lib/services/notifications/` |
| Mocks | `/lib/mocks/services/notifications/` |
| Entities | `/lib/domain/entities/notification.dart` |
| Enums | `/lib/domain/enums/index.dart` |
| Localization | `/lib/l10n/app_en.arb`, `/lib/l10n/app_fr.arb` |
| Router | `/lib/router/app_router.dart` |

## Next Steps

1. ✅ Configure Firebase (see above)
2. ✅ Update Android manifest
3. ✅ Update iOS Info.plist
4. ✅ Configure iOS capabilities in Xcode
5. ✅ Upload APNs key
6. ✅ Test on real device
7. ✅ Send test notification from Firebase Console
8. ⬜ Integrate with your backend
9. ⬜ Test all notification types
10. ⬜ Test deep linking
11. ⬜ Test preferences
12. ⬜ Production testing

## Support

For detailed documentation:
- Implementation guide: `/lib/features/notifications/README.md`
- Firebase setup: `/FIREBASE_SETUP.md`
- Summary: `/NOTIFICATION_IMPLEMENTATION_SUMMARY.md`

For issues:
- Check Flutter console logs
- Check Xcode console (iOS)
- Check Logcat (Android)
- Review Firebase Console → Cloud Messaging

---

**Status**: Ready to configure Firebase and test! 🚀
