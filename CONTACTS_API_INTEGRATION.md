# Contacts API Integration

This document describes how the mobile app integrates with the backend contacts API.

## Architecture

### Backend API
- **Location**: `/usdc-wallet/src/modules/contacts/`
- **Controller**: `contact.controller.ts`
- **Endpoints**:
  - `GET /contacts` - Get all saved contacts
  - `GET /contacts/favorites` - Get favorite contacts
  - `GET /contacts/recents` - Get recent contacts (based on last transaction)
  - `GET /contacts/search?query=<query>` - Search contacts by name or username
  - `POST /contacts` - Create a new contact
  - `PUT /contacts/:id` - Update contact
  - `PUT /contacts/:id/favorite` - Toggle favorite status
  - `DELETE /contacts/:id` - Delete contact

### Mobile Implementation

#### 1. Contact Model
**File**: `/mobile/lib/domain/entities/contact.dart`

```dart
class Contact {
  final String id;
  final String name;
  final String? phone;
  final String? walletAddress;
  final String? username;
  final bool isFavorite;
  final int transactionCount;
  final DateTime? lastTransactionAt;
  final bool isJoonaPayUser;
}
```

#### 2. Contacts Service
**File**: `/mobile/lib/services/contacts/contacts_service.dart`

The `JoonaPayContactsService` class provides methods to interact with the backend API:
- `getContacts()` - Fetch all contacts
- `getFavorites()` - Fetch favorite contacts
- `getRecents()` - Fetch recent contacts
- `searchContacts(String query)` - Search contacts
- `createContact()` - Create new contact
- `updateContact()` - Update existing contact
- `toggleFavorite()` - Toggle favorite status
- `deleteContact()` - Delete contact

#### 3. Contacts Provider
**File**: `/mobile/lib/features/wallet/providers/contacts_provider.dart`

Riverpod providers for state management with automatic caching:
- `contactsProvider` - All contacts (30s TTL)
- `favoritesProvider` - Favorite contacts (30s TTL)
- `recentsProvider` - Recent contacts (30s TTL)
- `searchContactsProvider` - Search results (no cache)
- `contactProvider` - Mutation state (create, update, delete)

**Features**:
- Automatic cache invalidation after 30 seconds
- Auto-refresh on mutations
- Error handling with ApiException
- Loading states

#### 4. Saved Recipients View
**File**: `/mobile/lib/features/wallet/views/saved_recipients_view.dart`

Features:
- Three tabs: All, Favorites, Recent
- Real-time search (client-side + server-side)
- Pull-to-refresh
- Swipe-to-delete with confirmation
- Add new recipients (phone, username, or wallet)
- Toggle favorite status
- Direct send to recipient

#### 5. Send View Integration
**File**: `/mobile/lib/features/wallet/views/send_view.dart`

Enhanced features:
- "Saved" button to select from saved recipients
- Auto-populate recipient details when selected
- Automatic contact saving after successful transfer
- Support for phone, username, and wallet transfers

## Usage Examples

### Fetching Contacts

```dart
// In a ConsumerWidget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final contactsAsync = ref.watch(contactsProvider);

  return contactsAsync.when(
    data: (contacts) => ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          title: Text(contact.name),
          subtitle: Text(contact.displayIdentifier),
        );
      },
    ),
    loading: () => CircularProgressIndicator(),
    error: (error, stack) => Text('Error: $error'),
  );
}
```

### Creating a Contact

```dart
final success = await ref.read(contactProvider.notifier).createContact(
  name: 'John Doe',
  phone: '+2250701234567',
  username: 'johndoe',
);

if (success) {
  // Contact created successfully
  // Contacts list will auto-refresh
} else {
  final error = ref.read(contactProvider).error;
  // Handle error
}
```

### Searching Contacts

```dart
final searchResults = ref.watch(searchContactsProvider('john'));

searchResults.when(
  data: (results) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

### Toggle Favorite

```dart
await ref.read(contactProvider.notifier).toggleFavorite(contactId);
// Favorites list will auto-refresh
```

### Delete Contact

```dart
await ref.read(contactProvider.notifier).deleteContact(contactId);
// All contact lists will auto-refresh
```

## Data Flow

1. **User Action** → Triggers provider method
2. **Provider** → Calls service method
3. **Service** → Makes HTTP request via Dio
4. **Backend** → Processes request and returns response
5. **Service** → Parses JSON to Contact objects
6. **Provider** → Updates state and invalidates cache
7. **UI** → Automatically rebuilds with new data

## Error Handling

All API calls wrap errors in `ApiException`:

```dart
try {
  final contacts = await service.getContacts();
  return contacts;
} on ApiException catch (e) {
  // e.message - User-friendly error message
  // e.statusCode - HTTP status code
  // e.data - Raw error data
}
```

## Caching Strategy

- **Contacts, Favorites, Recents**: 30-second TTL with auto-invalidation
- **Search Results**: No caching (fresh data on each search)
- **Mutations**: Invalidate all relevant caches on success

## Performance Optimizations

1. **TTL-based Caching**: Reduces unnecessary API calls
2. **Auto-invalidation**: Prevents stale data
3. **Debounced Search**: Server-side search only (no debounce needed on client)
4. **Lazy Loading**: Providers use `autoDispose` to clean up when not in use
5. **Pull-to-Refresh**: Manual refresh when needed

## Integration with Transfer Flow

When sending money:

1. User can select from saved recipients
2. Recipient details auto-populate
3. After successful transfer:
   - Transaction count increments (backend)
   - Last transaction date updates (backend)
   - Contact appears in "Recent" tab
   - If not saved, user is prompted to save

## Testing

To test the integration:

1. Start the backend server: `cd usdc-wallet && npm run start:dev`
2. Start the mobile app: `cd mobile && flutter run`
3. Login and navigate to Saved Recipients
4. Test CRUD operations:
   - Create contacts (phone, username, wallet)
   - Search contacts
   - Toggle favorites
   - Delete contacts
   - Send money to saved contacts

## API Response Examples

### GET /contacts
```json
{
  "contacts": [
    {
      "id": "uuid",
      "name": "John Doe",
      "phone": "+2250701234567",
      "walletAddress": null,
      "username": "johndoe",
      "isFavorite": true,
      "transactionCount": 5,
      "lastTransactionAt": "2026-01-20T12:00:00.000Z",
      "isJoonaPayUser": true
    }
  ],
  "total": 1
}
```

### POST /contacts
```json
{
  "name": "Jane Smith",
  "phone": "+2250709876543",
  "username": "janesmith"
}
```

Response:
```json
{
  "id": "uuid",
  "name": "Jane Smith",
  "phone": "+2250709876543",
  "walletAddress": null,
  "username": "janesmith",
  "isFavorite": false,
  "transactionCount": 0,
  "lastTransactionAt": null,
  "isJoonaPayUser": true
}
```

## Files Modified/Created

### Created
1. `/mobile/lib/features/wallet/providers/contacts_provider.dart` - Riverpod providers
2. `/mobile/CONTACTS_API_INTEGRATION.md` - This documentation

### Modified
1. `/mobile/lib/features/wallet/views/saved_recipients_view.dart` - Connected to API
2. `/mobile/lib/features/wallet/views/send_view.dart` - Added saved contacts integration
3. `/mobile/lib/features/wallet/providers/index.dart` - Export contacts provider

### Existing (Already in place)
1. `/mobile/lib/domain/entities/contact.dart` - Contact model
2. `/mobile/lib/services/contacts/contacts_service.dart` - API service

## Next Steps

1. Add contact photos/avatars
2. Implement contact sync with device contacts
3. Add contact grouping/categories
4. Implement contact sharing
5. Add contact notes/memo field
