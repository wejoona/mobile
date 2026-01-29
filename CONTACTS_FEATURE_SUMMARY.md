# Contact Sync Feature - Quick Reference

## Feature Overview
Privacy-preserving contact synchronization that finds JoonaPay users among phone contacts using SHA-256 hashing.

## Key Files

### Models
- `lib/features/contacts/models/synced_contact.dart` - Contact with JoonaPay status
- `lib/features/contacts/models/contact_sync_result.dart` - Sync result

### Services
- `lib/services/contacts/contacts_service.dart` - Extended with hashing & sync

### Providers
- `lib/features/contacts/providers/contacts_provider.dart` - State management

### Views
- `lib/features/contacts/views/contacts_permission_screen.dart` - Permission request
- `lib/features/contacts/views/contacts_list_screen.dart` - Contact list with sync

### Widgets
- `lib/features/contacts/widgets/contact_card.dart` - Contact display card
- `lib/features/contacts/widgets/invite_sheet.dart` - Invite bottom sheet

### Mocks
- `lib/mocks/services/contacts/contacts_sync_mock.dart` - 10 sample contacts (3 users)

### Localization
- Added 30+ strings to `app_en.arb` and `app_fr.arb`

## Routes to Add

Add to `lib/router/app_router.dart`:

```dart
GoRoute(
  path: '/contacts/permission',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const ContactsPermissionScreen(),
  ),
),
GoRoute(
  path: '/contacts/list',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const ContactsListScreen(),
  ),
),
```

## Usage Examples

### Request Permission
```dart
// Navigate to permission screen
context.push('/contacts/permission');

// Or programmatically
final granted = await ref.read(contactsProvider.notifier).requestPermission();
```

### Access Contacts
```dart
final state = ref.watch(contactsProvider);

// All contacts
final allContacts = state.contacts;

// JoonaPay users only
final joonaPayUsers = state.joonaPayUsers;

// Non-users
final nonUsers = state.nonJoonaPayUsers;

// Search
final results = state.searchContacts('Amadou');
```

### Sync Contacts
```dart
// Manual sync
await ref.read(contactsProvider.notifier).syncContacts();

// Auto-sync on permission grant
final granted = await ref.read(contactsProvider.notifier).requestPermission();
// Automatically syncs if granted
```

### Invite Contact
```dart
showModalBottomSheet(
  context: context,
  backgroundColor: Colors.transparent,
  builder: (context) => InviteSheet(contact: contact),
);
```

## Privacy Implementation

### Hashing Flow
```
Phone: "+225 07 01 23 45 67"
  ↓ Normalize
"+2250701234567"
  ↓ Hash (SHA-256)
"5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"
  ↓ Send to Server
Server compares hashes, returns matches
```

### What's Sent to Server
- ✅ SHA-256 hashes only
- ❌ NO raw phone numbers
- ❌ NO contact names
- ❌ NO contact photos

## API Endpoints

### POST /contacts/sync
Accepts phone hashes, returns JoonaPay user matches.

### POST /contacts/invite
Sends invite to contact via SMS.

## Testing

### Mock Data (10 Contacts)
**JoonaPay Users (3):**
1. Amadou Diallo
2. Fatou Traoré
3. Koffi Kouassi

**Non-Users (7):**
4-10. Various West African names

### Run with Mocks
```dart
MockConfig.useMocks = true;
```

## Integration Points

### Send Flow
```dart
// From contact card
context.push('/send', extra: {
  'recipientId': contact.joonaPayUserId
});
```

### Background Sync (Optional)
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(contactsProvider.notifier).loadAndSyncContacts();
  });
}
```

## Dependencies
All already in `pubspec.yaml`:
- `flutter_contacts: ^1.1.9+2`
- `permission_handler: ^11.3.1`
- `crypto: ^3.0.5`
- `share_plus: ^10.0.0`
- `url_launcher: ^6.3.0`

## Localization Keys

All strings prefixed with `contacts_`:
```dart
l10n.contacts_title
l10n.contacts_search
l10n.contacts_on_joonapay
l10n.contacts_invite_to_joonapay
l10n.contacts_permission_title
l10n.contacts_invite_title(name)
// ... and more
```

## Next Steps

1. **Add routes** to `app_router.dart`
2. **Add navigation button** in send/transfer flow
3. **Test permission flow** on real device
4. **Verify hashing** matches backend implementation
5. **Add analytics** for sync events
6. **Backend implementation** of `/contacts/sync` endpoint

## Backend Requirements

The backend must implement:

```typescript
POST /contacts/sync
{
  phoneHashes: string[] // SHA-256 hashes
}
→ {
  matches: [{
    phoneHash: string,
    userId: string,
    avatarUrl?: string
  }]
}

POST /contacts/invite
{
  phone: string,  // E.164 format
  name: string
}
→ { success: boolean }
```

## Files Summary

```
lib/features/contacts/
├── models/
│   ├── synced_contact.dart          ← Contact model
│   └── contact_sync_result.dart     ← Sync result
├── providers/
│   └── contacts_provider.dart       ← State management
├── views/
│   ├── contacts_permission_screen.dart  ← Permission UI
│   └── contacts_list_screen.dart        ← Contact list UI
├── widgets/
│   ├── contact_card.dart            ← Contact card widget
│   └── invite_sheet.dart            ← Invite bottom sheet
├── README.md                        ← Feature documentation
└── IMPLEMENTATION.md                ← Implementation details

lib/services/contacts/
└── contacts_service.dart            ← Extended service

lib/mocks/services/contacts/
└── contacts_sync_mock.dart          ← Mock data

lib/l10n/
├── app_en.arb                       ← English strings (updated)
└── app_fr.arb                       ← French strings (updated)
```

## Complete Implementation ✓

All files created and ready for integration. Just add routes and test!
