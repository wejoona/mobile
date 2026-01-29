# Push Notifications - Implementation Checklist

## Code Implementation ✅

- [x] NotificationPermissionScreen created
- [x] NotificationPreferencesScreen created
- [x] NotificationNavigationHandler created
- [x] Notification providers created
- [x] Mock data created (5 notifications)
- [x] Routes added to router
- [x] Mock registry updated
- [x] English localization added (37 strings)
- [x] French localization added (37 strings)
- [x] Localizations generated

## Firebase Configuration ⬜

### Create Firebase Project
- [ ] Go to https://console.firebase.google.com
- [ ] Create new project "JoonaPay Wallet"
- [ ] Note Project ID: `________________`

### Android Setup
- [ ] Add Android app to Firebase
- [ ] Package name: `com.joonapay.wallet`
- [ ] Download `google-services.json`
- [ ] Place at: `android/app/google-services.json`
- [ ] Update `AndroidManifest.xml`:
  - [ ] Add `POST_NOTIFICATIONS` permission
  - [ ] Add Firebase metadata (3 entries)
- [ ] Create `colors.xml` with notification color
- [ ] Test build: `flutter build apk --debug`

### iOS Setup
- [ ] Add iOS app to Firebase
- [ ] Bundle ID: `com.joonapay.wallet`
- [ ] Download `GoogleService-Info.plist`
- [ ] Add to Xcode project (Runner folder)
- [ ] Update `Info.plist`:
  - [ ] Add `FirebaseAppDelegateProxyEnabled` = false
- [ ] Open Xcode: `open ios/Runner.xcworkspace`
- [ ] Add capabilities:
  - [ ] Push Notifications
  - [ ] Background Modes (Remote notifications, Background fetch)
- [ ] Test build: `flutter build ios --debug`

### APNs Configuration (iOS Only)
- [ ] Go to https://developer.apple.com/account
- [ ] Create APNs Auth Key
- [ ] Download `.p8` file
- [ ] Note Key ID: `________________`
- [ ] Note Team ID: `________________`
- [ ] Upload to Firebase Console
- [ ] Enter Key ID and Team ID

## Testing ⬜

### Mock Data Testing
- [ ] Run app: `flutter run`
- [ ] Login to app
- [ ] Navigate to `/notifications`
- [ ] Verify 5 mock notifications appear
- [ ] Test swipe to delete
- [ ] Test mark all as read
- [ ] Test unread count badge
- [ ] Tap notification → verify navigation

### Permission Flow
- [ ] Fresh install (or clear app data)
- [ ] Complete onboarding/login
- [ ] Navigate to `/notifications/permission`
- [ ] Tap "Enable Notifications"
- [ ] Grant permission
- [ ] Verify success message
- [ ] Check FCM token in logs

### Preferences
- [ ] Navigate to Settings → Notifications
- [ ] Open notification preferences
- [ ] Toggle transaction alerts
- [ ] Try to toggle security alerts (should be locked)
- [ ] Toggle promotions
- [ ] Toggle price alerts
- [ ] Toggle weekly summary
- [ ] Change large transaction threshold
- [ ] Change low balance threshold
- [ ] Navigate away and return
- [ ] Verify preferences persisted

### Firebase Console Testing
- [ ] Get FCM token from app logs
- [ ] Go to Firebase Console → Cloud Messaging
- [ ] Click "Send test message"
- [ ] Enter token
- [ ] Send notification
- [ ] Verify notification received (device)
- [ ] Tap notification
- [ ] Verify app opens

### Deep Linking
Test each notification type routes correctly:
- [ ] `transactionComplete` → `/transactions/:id`
- [ ] `securityAlert` → `/settings/security`
- [ ] `newDeviceLogin` → `/settings/security`
- [ ] `deposit` → `/home`
- [ ] `lowBalance` → `/deposit`
- [ ] `promotion` → `/referrals`
- [ ] Custom route in data works

### Foreground Notifications
- [ ] Open app
- [ ] Send notification from Firebase Console
- [ ] Verify in-app banner appears
- [ ] Verify auto-dismisses after 4s
- [ ] Tap banner → verify navigation

### Background Notifications
- [ ] Minimize app (home screen)
- [ ] Send notification from Firebase Console
- [ ] Verify notification appears in tray
- [ ] Tap notification
- [ ] Verify app opens to correct screen

### Terminated State
- [ ] Force quit app
- [ ] Send notification from Firebase Console
- [ ] Tap notification
- [ ] Verify app launches to correct screen

## Backend Integration ⬜

### Database
- [ ] Verify `auth.devices` table has `fcmToken` column
- [ ] Test token storage on login

### API Endpoints
- [ ] `POST /notifications/push/token` - Register token
- [ ] `DELETE /notifications/push/token` - Remove token
- [ ] `DELETE /notifications/push/tokens` - Remove all tokens
- [ ] `GET /notifications` - Fetch notifications
- [ ] `GET /notifications/unread/count` - Unread count
- [ ] `PUT /notifications/:id/read` - Mark as read
- [ ] `PUT /notifications/read-all` - Mark all as read

### Firebase Admin SDK
- [ ] Install Firebase Admin SDK in backend
- [ ] Initialize with service account
- [ ] Test sending notification
- [ ] Verify delivery

### Notification Triggers
Implement backend triggers for:
- [ ] Transaction complete
- [ ] Transaction failed
- [ ] Deposit complete
- [ ] Withdrawal pending
- [ ] Security alert (new device)
- [ ] Low balance
- [ ] Large transaction
- [ ] Promotional campaigns

## Platform-Specific Testing ⬜

### iOS
- [ ] Test on iPhone (real device required)
- [ ] Test on iPad
- [ ] Verify badge count updates
- [ ] Test notification sounds
- [ ] Test Do Not Disturb mode
- [ ] Test permission denial flow
- [ ] Test app in background
- [ ] Test app terminated
- [ ] Test silent notifications
- [ ] Verify APNs delivery

### Android
- [ ] Test on Android 13+ (permission required)
- [ ] Test on Android 12 and below
- [ ] Verify notification channel created
- [ ] Test notification sounds
- [ ] Test vibration
- [ ] Test notification LED
- [ ] Test app in background
- [ ] Test app terminated
- [ ] Test battery optimization
- [ ] Verify FCM delivery

## Localization Testing ⬜

### English
- [ ] Switch app to English
- [ ] Verify all notification screens in English
- [ ] Test permission screen
- [ ] Test preferences screen
- [ ] Test notification list

### French
- [ ] Switch app to French
- [ ] Verify all notification screens in French
- [ ] Test permission screen
- [ ] Test preferences screen
- [ ] Test notification list

## Accessibility Testing ⬜

- [ ] Test with VoiceOver (iOS)
- [ ] Test with TalkBack (Android)
- [ ] Test keyboard navigation
- [ ] Verify color contrast
- [ ] Test with large text size
- [ ] Test with reduced motion
- [ ] Verify haptic feedback

## Performance Testing ⬜

- [ ] Measure app startup time with Firebase init
- [ ] Test notification list with 100+ items
- [ ] Test rapid notification delivery
- [ ] Monitor memory usage
- [ ] Monitor battery usage
- [ ] Test offline behavior
- [ ] Test slow network

## Security Testing ⬜

- [ ] Verify tokens stored securely
- [ ] Test token refresh on expiry
- [ ] Test token removal on logout
- [ ] Verify deep links validated
- [ ] Test notification data sanitization
- [ ] Verify security alerts can't be disabled
- [ ] Test unauthorized notification rejection

## Edge Cases ⬜

- [ ] No network connection
- [ ] Airplane mode
- [ ] App force quit
- [ ] Battery saver mode
- [ ] Data saver mode
- [ ] Permission denied
- [ ] Permission revoked after grant
- [ ] FCM token expired
- [ ] Invalid notification data
- [ ] Missing notification fields
- [ ] Large notification body (> 4KB)
- [ ] Special characters in notification

## Production Readiness ⬜

### Configuration
- [ ] Firebase project for production created
- [ ] Production `google-services.json` configured
- [ ] Production `GoogleService-Info.plist` configured
- [ ] APNs certificate for production uploaded
- [ ] Firebase service account created for backend

### Environment Separation
- [ ] Development Firebase project
- [ ] Staging Firebase project
- [ ] Production Firebase project
- [ ] Environment-specific config files

### Monitoring
- [ ] Firebase Cloud Messaging analytics enabled
- [ ] Error tracking for notification failures
- [ ] Token registration success rate tracked
- [ ] Deep link success rate tracked
- [ ] User preference analytics

### Documentation
- [ ] Backend API documented
- [ ] Notification payload format documented
- [ ] Deep linking routes documented
- [ ] Troubleshooting guide created
- [ ] Team training completed

## Final Verification ⬜

- [ ] All code reviewed
- [ ] All tests passing
- [ ] No console errors
- [ ] No linting errors
- [ ] Firebase quotas checked
- [ ] Performance acceptable
- [ ] Battery usage acceptable
- [ ] Security audit passed
- [ ] Privacy policy updated
- [ ] App Store/Play Store compliance verified

## Known Issues ⬜

Document any issues found:
1. _____________________________________
2. _____________________________________
3. _____________________________________

## Notes

_____________________________________
_____________________________________
_____________________________________
_____________________________________

---

**Completed**: _____ / 200+ items
**Last Updated**: 2026-01-29
**Next Review**: _________________
