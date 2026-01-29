# Contacts Sync Feature

Privacy-preserving contact synchronization that finds JoonaPay users among your phone contacts.

## Overview

The contacts sync feature allows users to:
- Find which contacts are already on JoonaPay
- Send money quickly to JoonaPay users
- Invite non-users via SMS/WhatsApp
- Maintain privacy with phone number hashing

## Architecture

### Models (`models/`)
- `SyncedContact` - Contact with JoonaPay status
- `ContactSyncResult` - Sync operation result

### Providers (`providers/`)
- `ContactsProvider` - State management for contacts
  - Permission state
  - Contact list with sync status
  - Search functionality

### Views (`views/`)
- `ContactsPermissionScreen` - Permission request with privacy explanation
- `ContactsListScreen` - List of contacts with JoonaPay status

### Widgets (`widgets/`)
- `ContactCard` - Contact display with action buttons
- `InviteSheet` - Bottom sheet for invite options

## Privacy Implementation

### Phone Number Hashing
```dart
// Client-side hashing before sending to server
String normalizePhone(String phone) {
  // E.164 format: +2250700000000
  return phone.replaceAll(RegExp(r'\D'), '');
}

String hashPhone(String phone) {
  final normalized = normalizePhone(phone);
  final bytes = utf8.encode(normalized);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

### Sync Flow
```
1. Get device contacts → ["John", "+225 07 00 00 00"]
2. Normalize phones → ["+2250700000000"]
3. Hash phones → ["a3b2c1..."]
4. Send to server → POST /contacts/sync {phoneHashes: [...]}
5. Receive matches → [{phoneHash: "a3b2c1...", userId: "user123"}]
6. Mark contacts → John is a JoonaPay user
```

### What's NOT Stored
- Raw phone numbers on server
- Contact names
- Contact avatars (from device)

### What's Stored
- Phone number hashes (SHA-256)
- Match status (is JoonaPay user)
- JoonaPay user info (if matched)

## Usage

### Request Permission
```dart
final granted = await ref.read(contactsProvider.notifier).requestPermission();
if (granted) {
  // Automatically loads and syncs contacts
}
```

### Sync Contacts
```dart
// Manual sync (pull-to-refresh)
await ref.read(contactsProvider.notifier).syncContacts();

// Access synced contacts
final state = ref.watch(contactsProvider);
final joonaPayUsers = state.joonaPayUsers;
final nonUsers = state.nonJoonaPayUsers;
```

### Invite Contact
```dart
final contact = SyncedContact(
  id: '123',
  name: 'John Doe',
  phone: '+2250700000000',
);

// Show invite sheet
showModalBottomSheet(
  context: context,
  builder: (context) => InviteSheet(contact: contact),
);
```

## Localization

All strings are localized in English and French:
- `contacts_*` - Screen titles, labels
- `contacts_permission_*` - Permission screen
- `contacts_invite_*` - Invite sheet

## Mock Data

Mock includes 10 sample contacts:
- 3 JoonaPay users (will match)
- 7 non-users (won't match)

Test data in `lib/mocks/services/contacts/contacts_sync_mock.dart`

## API Endpoints

### POST /contacts/sync
Send hashed phone numbers, receive matches.

**Request:**
```json
{
  "phoneHashes": [
    "a3b2c1d4e5f6...",
    "b4c5d6e7f8a9..."
  ]
}
```

**Response:**
```json
{
  "matches": [
    {
      "phoneHash": "a3b2c1d4e5f6...",
      "userId": "user_123",
      "avatarUrl": "https://..."
    }
  ],
  "totalChecked": 2,
  "matchesFound": 1
}
```

### POST /contacts/invite
Send invite to contact.

**Request:**
```json
{
  "phone": "+2250700000000",
  "name": "John Doe"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invitation sent successfully"
}
```

## Integration Points

### Send Money Flow
```dart
// From contacts list → send screen
context.push('/send', extra: {
  'recipientId': contact.joonaPayUserId
});
```

### Background Sync
Optionally sync contacts on app launch:
```dart
@override
void initState() {
  super.initState();
  Future.microtask(() {
    ref.read(contactsProvider.notifier).loadAndSyncContacts();
  });
}
```

## Accessibility

- Search input with keyboard navigation
- Contact cards with tap targets ≥48px
- Screen reader labels on all interactive elements
- High contrast mode support

## Performance

- Lazy loading of contact avatars
- Efficient search with local filtering
- Pull-to-refresh debouncing
- Cached sync results with timestamp

## Testing

```bash
# Run contact sync tests
flutter test test/features/contacts/

# Test with mock data
MockConfig.useMocks = true;
```

## Future Enhancements

- [ ] Contact groups/favorites
- [ ] Bulk invite
- [ ] Invite tracking/rewards
- [ ] Contact profile preview
- [ ] Recent contacts widget
