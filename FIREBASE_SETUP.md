# Firebase Push Notifications Setup

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com
2. Add your iOS and Android apps to the project

## Android Setup

### 1. Download google-services.json
1. Go to Firebase Console → Project Settings → Your Apps
2. Click on your Android app
3. Download `google-services.json`
4. Place it at: `android/app/google-services.json`

### 2. Update AndroidManifest.xml
Add the following to `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Add inside <manifest> tag, before <application> -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

<!-- Add inside <application> tag -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_icon"
    android:resource="@drawable/notification_icon" />

<meta-data
    android:name="com.google.firebase.messaging.default_notification_color"
    android:resource="@color/notification_color" />
```

### 3. Create notification icon
Place a notification icon at:
`android/app/src/main/res/drawable/notification_icon.png`

### 4. Add notification color
In `android/app/src/main/res/values/colors.xml`:
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="notification_color">#C9A962</color>
</resources>
```

## iOS Setup

### 1. Download GoogleService-Info.plist
1. Go to Firebase Console → Project Settings → Your Apps
2. Click on your iOS app
3. Download `GoogleService-Info.plist`
4. Add it to your Xcode project (Runner folder)

### 2. Update Info.plist
Add to `ios/Runner/Info.plist`:

```xml
<!-- Add before closing </dict> -->
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### 3. Enable Push Notifications capability
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes" and enable:
   - Remote notifications
   - Background fetch

### 4. Configure APNs (Apple Push Notification service)
1. Go to https://developer.apple.com/account
2. Create an APNs Auth Key:
   - Certificates, Identifiers & Profiles → Keys
   - Click "+" to create a new key
   - Enable "Apple Push Notifications service (APNs)"
   - Download the .p8 file
3. Upload to Firebase:
   - Firebase Console → Project Settings → Cloud Messaging
   - Under "Apple app configuration"
   - Upload APNs Auth Key
   - Enter your Team ID and Key ID

## App Initialization

The app is already configured to initialize Firebase. Just add your config files:

```dart
// This is already done in main.dart
await Firebase.initializeApp();

// Push notifications will auto-initialize
final pushService = ref.read(pushNotificationServiceProvider);
await pushService.initialize();
```

## Testing Notifications

### Using Firebase Console
1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and body
4. Select your app
5. Send test message

### Using Backend API
The backend `/notifications/push/token` endpoint registers FCM tokens.
Use your backend notification system to send via Firebase Admin SDK.

## Troubleshooting

### Android
- Verify `google-services.json` is in `android/app/`
- Run `./gradlew clean` in android folder
- Check logcat for Firebase initialization logs

### iOS
- Verify `GoogleService-Info.plist` is added to Xcode project
- Check provisioning profile includes Push Notifications
- Test on real device (push doesn't work on simulator)
- Check Xcode console for Firebase initialization logs

### Permission Issues
- Ensure you're requesting permission: `await pushService.initialize()`
- Check device settings: Settings → JoonaPay → Notifications
- On iOS, permission can only be requested once per install

## Security Notes

1. **Never commit** `google-services.json` or `GoogleService-Info.plist` to version control
2. Add them to `.gitignore`:
   ```
   android/app/google-services.json
   ios/Runner/GoogleService-Info.plist
   ```
3. Use different Firebase projects for development/staging/production
4. Rotate FCM server keys periodically
5. Validate tokens server-side before sending notifications

## Production Checklist

- [ ] Firebase project created for production
- [ ] APNs Auth Key uploaded to Firebase
- [ ] Android `google-services.json` configured
- [ ] iOS `GoogleService-Info.plist` configured
- [ ] Push notification capability enabled in Xcode
- [ ] Notification permissions tested on both platforms
- [ ] Backend FCM integration tested
- [ ] Deep linking tested for all notification types
- [ ] Notification preferences saved and respected
- [ ] Unread count badge working
- [ ] Foreground notifications displaying correctly
