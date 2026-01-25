# Push Notification System

This directory contains the complete push notification implementation for JoonaPay mobile app.

## Architecture Overview

```
+-------------------+     +------------------+     +------------------+
|   Firebase Cloud  |---->| Mobile App       |---->| Backend API      |
|   Messaging (FCM) |     | (Flutter)        |     | (NestJS)         |
+-------------------+     +------------------+     +------------------+
                                 |                        |
                                 v                        v
                          +-------------+          +-------------+
                          | Local       |          | Database    |
                          | Notifications|          | (PostgreSQL)|
                          +-------------+          +-------------+
```

## Files

### Mobile (Flutter)

- `push_notification_service.dart` - Core FCM service
- `local_notification_service.dart` - Local notification display
- `notification_handler.dart` - App integration widget
- `notifications_service.dart` - API client for notifications
- `rich_notification_helper.dart` - UI helpers and in-app display

### Backend (NestJS)

- `infrastructure/fcm/` - FCM token management
- `application/controllers/push-notification.controller.ts` - API endpoints
- `application/domain/services/push-notification.service.ts` - Push sending logic
- `application/domain/event-listeners/` - Event-driven notifications

## Setup

### 1. Firebase Project Setup

1. Create a Firebase project at https://console.firebase.google.com
2. Add Android app with package name `com.joonapay.usdc_wallet`
3. Add iOS app with bundle ID
4. Download `google-services.json` for Android
5. Download `GoogleService-Info.plist` for iOS

### 2. Android Setup

Place `google-services.json` in:
```
android/app/google-services.json
```

### 3. iOS Setup

Place `GoogleService-Info.plist` in:
```
ios/Runner/GoogleService-Info.plist
```

Enable Push Notifications capability in Xcode:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target > Signing & Capabilities
3. Add "Push Notifications" capability
4. Add "Background Modes" > "Remote notifications"

### 4. Backend Environment Variables

```env
FCM_PROJECT_ID=your-firebase-project-id
FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FCM_USE_MOCK=false
```

## Usage

### Initialize in main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### After Authentication

```dart
// In your auth flow, after successful login
final pushService = ref.read(pushNotificationServiceProvider);
await pushService.initialize();
await pushService.registerWithBackend();
```

### On Logout

```dart
final pushService = ref.read(pushNotificationServiceProvider);
await pushService.unregisterFromBackend();
```

### Handle Notifications with NotificationHandler

```dart
// Wrap your authenticated app
NotificationHandler(
  child: AuthenticatedAppContent(),
)
```

## Notification Types

| Type | Trigger | Priority |
|------|---------|----------|
| `transaction` | Transfer sent/received | High |
| `security` | New device login, large transaction | High |
| `kyc` | KYC status change | Normal |
| `balance` | Low balance alert | Normal |
| `promotion` | Marketing | Low |

## Backend Event Integration

The backend listens for domain events and sends push notifications:

```typescript
// In any service, emit events
this.eventEmitter.emit('transfer.received', {
  userId: recipientId,
  amount: 100,
  currency: 'USDC',
  transactionId: '...',
});
```

The `NotificationEventListener` handles these events and:
1. Checks user notification preferences
2. Creates in-app notification record
3. Sends push notification via FCM

## Testing

### Backend Mock Mode

Set `FCM_USE_MOCK=true` to log notifications instead of sending them.

### Mobile Testing

Use the Firebase Console to send test notifications:
1. Go to Cloud Messaging
2. Send your first message
3. Enter FCM token from app logs

## Security Considerations

1. FCM tokens should be stored securely on the backend
2. Token rotation is handled automatically
3. Invalid tokens are deactivated after repeated failures
4. User preferences are always checked before sending
