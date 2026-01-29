# Push Notifications Implementation

## Overview
Complete push notification system using Firebase Cloud Messaging (FCM) with deep linking, preferences, and local storage.

## Architecture

### Services (`/lib/services/notifications/`)
- **`push_notification_service.dart`** - FCM token management, permission requests
- **`local_notification_service.dart`** - Foreground notification display
- **`notifications_service.dart`** - Backend API integration, preferences
- **`notification_handler.dart`** - Message processing
- **`notification_navigation_handler.dart`** - Deep linking router
- **`rich_notification_helper.dart`** - Rich notification formatting

### Screens (`/lib/features/notifications/views/`)
- **`notifications_view.dart`** - Main notification list
- **`notification_permission_screen.dart`** - Permission request UI
- **`notification_preferences_screen.dart`** - User preferences

### Providers (`/lib/features/notifications/providers/`)
- **`notification_permission_provider.dart`** - Permission state
- **`notification_preferences_notifier_provider.dart`** - Preferences management

### Entities (`/lib/domain/entities/`)
- **`notification.dart`** - AppNotification model
- **`notification_preferences.dart`** - User preferences model

### Enums (`/lib/domain/enums/`)
- **NotificationType** - All notification types (transaction, security, etc.)

## Notification Types

### Transaction Alerts
- `transactionComplete` - Payment sent/received successfully
- `transactionFailed` - Payment failed
- `withdrawalPending` - Withdrawal being processed

### Security Alerts
- `securityAlert` - General security warning
- `newDeviceLogin` - Login from new device
- `largeTransaction` - Transaction above threshold
- `addressWhitelisted` - New address approved

### Monitoring Alerts
- `unusualLocation` - Access from unusual location
- `rapidTransactions` - Multiple quick transactions
- `suspiciousPattern` - Detected suspicious activity
- `failedAttempts` - Multiple failed login attempts

### Other
- `promotion` - Marketing/promotional
- `lowBalance` - Balance below threshold
- `priceAlert` - USDC price movement
- `weeklySpendingSummary` - Weekly report

## User Flow

### First Launch
1. App initializes Firebase
2. Show `NotificationPermissionScreen` after onboarding
3. User grants/denies permission
4. If granted, register FCM token with backend

### Notification Received
1. FCM delivers message to device
2. **App in foreground**: Show in-app banner via `local_notification_service`
3. **App in background**: System displays notification
4. User taps notification
5. `notification_navigation_handler` routes to appropriate screen

### Managing Preferences
1. User navigates to Settings → Notifications
2. Opens `NotificationPreferencesScreen`
3. Toggle notification types on/off
4. Set custom thresholds (large transaction, low balance)
5. Preferences saved to secure storage

## Deep Linking Routes

| Notification Type | Default Route |
|------------------|---------------|
| `transaction*` | `/transactions/:id` |
| `security*` | `/settings/security` |
| `deposit*` | `/home` |
| `lowBalance` | `/deposit` |
| `promotion` | `/referrals` |
| `kyc*` | `/settings/kyc` |

Custom routes can be included in notification `data` payload:
```json
{
  "data": {
    "route": "/custom/path"
  }
}
```

## Backend Integration

### Register FCM Token
```http
POST /notifications/push/token
Content-Type: application/json
Authorization: Bearer <token>

{
  "token": "FCM_TOKEN_HERE",
  "platform": "ios" | "android",
  "deviceId": "device-uuid",
  "deviceName": "iPhone 15 Pro",
  "appVersion": "1.0.0",
  "osVersion": "iOS 17.0"
}
```

### Send Notification (Backend)
```javascript
// Using Firebase Admin SDK
await admin.messaging().send({
  token: user.fcmToken,
  notification: {
    title: 'Payment Received',
    body: 'You received $50 from John Doe'
  },
  data: {
    type: 'transactionComplete',
    transactionId: 'txn-123',
    amount: '50.00',
    from: '+225071234567'
  },
  apns: {
    payload: {
      aps: {
        badge: 1,
        sound: 'default'
      }
    }
  },
  android: {
    priority: 'high',
    notification: {
      channelId: 'high_importance_channel',
      priority: 'high'
    }
  }
});
```

### Fetch Notifications
```http
GET /notifications
Authorization: Bearer <token>

Response:
[
  {
    "id": "notif-123",
    "userId": "user-456",
    "type": "transactionComplete",
    "title": "Payment Received",
    "body": "You received $50",
    "data": { "transactionId": "txn-123" },
    "isRead": false,
    "createdAt": "2024-01-29T10:00:00Z",
    "readAt": null
  }
]
```

## Local Storage

### Notification Preferences
Stored in secure storage at key `notification_preferences`:
```json
{
  "transactionAlerts": true,
  "securityAlerts": true,
  "promotions": false,
  "priceAlerts": false,
  "weeklySummary": true,
  "largeTransactionThreshold": 1000.0,
  "lowBalanceThreshold": 100.0
}
```

### FCM Token
Stored by Firebase SDK, accessed via `FirebaseMessaging.instance.getToken()`

## Permission States

| State | iOS | Android |
|-------|-----|---------|
| Not Determined | First launch, never asked | First launch on Android 12- |
| Denied | User declined | User declined on Android 13+ |
| Authorized | User granted | User granted on Android 13+ |
| Provisional | Deliver quietly (iOS only) | N/A |

## Testing

### Mock Data
See `/lib/mocks/services/notifications/notifications_mock.dart` for 5 sample notifications.

### Local Testing
```dart
// In debug mode, simulate notification
final message = RemoteMessage(
  notification: RemoteNotification(
    title: 'Test Notification',
    body: 'This is a test',
  ),
  data: {
    'type': 'transactionComplete',
    'transactionId': 'txn-test-123',
  },
);

// Trigger handler
final handler = NotificationNavigationHandler(router);
handler.handleNotificationNavigation(message);
```

### Firebase Console Testing
1. Go to Firebase Console → Cloud Messaging
2. Click "Send test message"
3. Enter FCM token (check debug console)
4. Send notification

## Accessibility

- All screens support screen readers
- Icons have semantic labels
- Color contrast meets WCAG AA
- Keyboard navigation supported
- Haptic feedback on interactions

## Performance

- Notifications fetched on-demand (not polled)
- Unread count cached locally
- Images lazy-loaded in notification list
- Background message handler lightweight
- Token registration debounced

## Security

- FCM tokens stored securely
- Backend validates tokens before sending
- User ID embedded in token registration
- Tokens revoked on logout
- Deep links validated before navigation

## Future Enhancements

- [ ] In-app notification center with tabs (All, Unread, Archived)
- [ ] Rich notifications with images/actions
- [ ] Notification categories for grouping
- [ ] Scheduled local notifications (reminders)
- [ ] Email notification preferences
- [ ] SMS notification preferences (OTP only)
- [ ] Notification sound customization
- [ ] Do Not Disturb schedule
- [ ] Notification history export

## Troubleshooting

### Token Not Registering
- Check Firebase is initialized before push service
- Verify `google-services.json` / `GoogleService-Info.plist` present
- Ensure user granted permission
- Check backend endpoint is reachable

### Notifications Not Appearing
- iOS: Test on real device (simulator doesn't support push)
- Android: Check notification channel created
- Verify app is registered in Firebase Console
- Check APNs certificate uploaded (iOS)

### Deep Links Not Working
- Verify route exists in `app_router.dart`
- Check `notification_navigation_handler.dart` has case for type
- Ensure app is in foreground when testing `onMessageOpenedApp`

## Related Files

- `/lib/services/sdk/usdc_wallet_sdk.dart` - SDK notifications service
- `/lib/router/app_router.dart` - Route definitions
- `/lib/l10n/app_en.arb` - English strings
- `/lib/l10n/app_fr.arb` - French strings
- `/FIREBASE_SETUP.md` - Firebase configuration guide

## Dependencies

```yaml
firebase_core: ^3.8.1
firebase_messaging: ^15.1.6
flutter_local_notifications: ^18.0.1
device_info_plus: ^11.2.0
```

All dependencies already included in `pubspec.yaml`.
