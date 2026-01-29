# Contact Sync Feature - Integration Checklist

## ✅ Completed (Ready to Use)

- [x] Models created
  - [x] `SyncedContact` model
  - [x] `ContactSyncResult` model
- [x] Service extended
  - [x] Phone normalization (E.164)
  - [x] SHA-256 hashing
  - [x] Contact sync logic
- [x] Provider implemented
  - [x] Permission state management
  - [x] Contact list state
  - [x] Sync operations
- [x] UI Views created
  - [x] Permission screen
  - [x] Contacts list screen
- [x] Widgets created
  - [x] Contact card
  - [x] Invite bottom sheet
- [x] Mock data added
  - [x] 10 sample contacts
  - [x] Mock API endpoints
  - [x] Registered in mock registry
- [x] Localization completed
  - [x] 30+ English strings
  - [x] 30+ French translations
  - [x] Localizations generated
- [x] Documentation written
  - [x] README
  - [x] Implementation guide
  - [x] Usage examples

## 📋 TODO: Integration Steps

### 1. Add Routes to Router

**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/router/app_router.dart`

Add these routes to the routes list:

```dart
// Contacts feature
GoRoute(
  path: '/contacts/permission',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const ContactsPermissionScreen(),
  ),
),
GoRoute(
  path: '/contacts/list',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context,
    state,
    const ContactsListScreen(),
  ),
),
```

**Import statement to add:**
```dart
import '../features/contacts/views/contacts_permission_screen.dart';
import '../features/contacts/views/contacts_list_screen.dart';
```

### 2. Add Navigation Button in Send Flow

**Option A:** Add to recipient selection screen

```dart
ListTile(
  leading: const Icon(Icons.contacts),
  title: AppText(l10n.contacts_title),
  subtitle: AppText('Find JoonaPay users'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () async {
    final state = ref.read(contactsProvider);
    if (state.permissionState == PermissionState.granted) {
      context.push('/contacts/list');
    } else {
      context.push('/contacts/permission');
    }
  },
)
```

**Option B:** Add floating action button

```dart
floatingActionButton: FloatingActionButton.extended(
  onPressed: () => context.push('/contacts/permission'),
  icon: const Icon(Icons.contacts),
  label: const Text('Contacts'),
),
```

### 3. Optional: Background Sync on App Launch

**File:** Main app initialization (e.g., `main.dart` or app wrapper)

```dart
class AppInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const AppInitializer({super.key, required this.child});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeContacts();
  }

  Future<void> _initializeContacts() async {
    final notifier = ref.read(contactsProvider.notifier);
    await notifier.checkPermission();

    final state = ref.read(contactsProvider);
    if (state.permissionState == PermissionState.granted) {
      // Background sync (fire and forget)
      notifier.loadAndSyncContacts();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
```

### 4. iOS: Add Permission Description

**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/ios/Runner/Info.plist`

Add this key (if not already present):

```xml
<key>NSContactsUsageDescription</key>
<string>We need access to your contacts to help you find friends on JoonaPay and send money quickly.</string>
```

### 5. Android: Add Permission

**File:** `/Users/macbook/JoonaPay/USDC-Wallet/mobile/android/app/src/main/AndroidManifest.xml`

Add this permission (if not already present):

```xml
<uses-permission android:name="android.permission.READ_CONTACTS" />
```

### 6. Backend: Implement API Endpoints

The backend must implement:

#### POST /contacts/sync

```typescript
interface SyncRequest {
  phoneHashes: string[]; // SHA-256 hashes
}

interface SyncResponse {
  matches: Array<{
    phoneHash: string;
    userId: string;
    avatarUrl?: string;
  }>;
  totalChecked: number;
  matchesFound: number;
}
```

**Implementation notes:**
- Store phone hashes in user table (indexed)
- Compare request hashes with database
- Return matches with user info
- Rate limit: 1 request per 60 seconds per user
- Max hashes per request: 1000

#### POST /contacts/invite

```typescript
interface InviteRequest {
  phone: string;  // E.164 format
  name: string;
}

interface InviteResponse {
  success: boolean;
  message: string;
}
```

**Implementation notes:**
- Send SMS invite
- Track invite conversions
- Prevent spam (rate limit)

### 7. Testing Checklist

- [ ] Test permission request on iOS
- [ ] Test permission request on Android
- [ ] Test with mock data (3 JoonaPay users should appear)
- [ ] Test search functionality
- [ ] Test pull-to-refresh sync
- [ ] Test invite sheet (SMS, WhatsApp, Copy)
- [ ] Test navigation to send screen
- [ ] Test permission denied flow
- [ ] Test with real device contacts
- [ ] Test with 0 contacts
- [ ] Test with 500+ contacts (performance)

### 8. Analytics to Add (Optional)

```dart
// Track events
analytics.logEvent('contacts_permission_requested');
analytics.logEvent('contacts_permission_granted');
analytics.logEvent('contacts_synced', {
  'total_contacts': state.contacts.length,
  'joonapay_users_found': state.joonaPayUsers.length,
});
analytics.logEvent('contact_invited', {
  'method': 'sms', // or 'whatsapp', 'copy'
});
analytics.logEvent('contact_send_tapped', {
  'user_id': contact.joonaPayUserId,
});
```

## 🔍 Verification Steps

After integration, verify:

1. **Permission Flow**
   - [ ] Permission screen shows clear explanation
   - [ ] "Allow Access" button works
   - [ ] "Maybe Later" button dismisses screen
   - [ ] Permission dialog appears (iOS/Android)
   - [ ] Contacts load after granting permission

2. **Contacts List**
   - [ ] Shows "On JoonaPay" section with verified badge
   - [ ] Shows "Invite to JoonaPay" section
   - [ ] Search filters contacts
   - [ ] Pull-to-refresh syncs contacts
   - [ ] Last synced timestamp appears
   - [ ] Empty state shows when no contacts

3. **Contact Card**
   - [ ] Shows avatar (initials or photo)
   - [ ] Shows verified badge for JoonaPay users
   - [ ] "Send" button navigates to send screen
   - [ ] "Invite" button opens invite sheet

4. **Invite Sheet**
   - [ ] SMS option opens Messages app
   - [ ] WhatsApp option opens WhatsApp
   - [ ] Copy link copies to clipboard
   - [ ] Invite message is localized

5. **Privacy**
   - [ ] No raw phone numbers in network requests
   - [ ] Only SHA-256 hashes sent to server
   - [ ] Contact names not sent to server

## 🚀 Launch Checklist

Before releasing to production:

- [ ] Backend API endpoints deployed
- [ ] Backend stores phone hashes (indexed)
- [ ] Rate limiting configured
- [ ] Privacy policy updated
- [ ] Terms of service updated
- [ ] Legal compliance verified (GDPR/CCPA)
- [ ] Analytics tracking configured
- [ ] Error monitoring configured
- [ ] Feature flag created (optional)
- [ ] A/B test configured (optional)
- [ ] User education materials prepared
- [ ] Support team trained
- [ ] Rollback plan prepared

## 📊 Success Metrics

Track these metrics after launch:

- Permission grant rate
- Contacts synced per user
- JoonaPay users found per sync
- Invite conversion rate
- Send money from contacts usage
- Search usage
- Performance (sync time)
- Error rate
- User retention (users who grant permission)

## 🐛 Known Issues / Limitations

- **Contact Avatars**: Only available for JoonaPay users (from server)
- **Duplicate Detection**: Based on exact phone number match
- **Sync Frequency**: Manual sync only (no auto-sync on contact changes)
- **Offline Mode**: Requires network connection for sync
- **Contact Groups**: Not supported (future enhancement)

## 📞 Support

For issues or questions:
- See `lib/features/contacts/README.md` for detailed docs
- See `lib/features/contacts/USAGE_EXAMPLE.dart` for code examples
- Check mock data in `lib/mocks/services/contacts/contacts_sync_mock.dart`

## 🎉 You're Done!

Once all items are checked, the contact sync feature is fully integrated and ready for testing!
