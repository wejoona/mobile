# Contacts API - Quick Reference Guide

## Files Overview

### Core Implementation Files

| File | Location | Purpose | Size |
|------|----------|---------|------|
| **contacts_provider.dart** | `/lib/features/wallet/providers/` | State management | 5.5 KB |
| **saved_recipients_view.dart** | `/lib/features/wallet/views/` | Main UI | 26 KB |
| **send_view.dart** | `/lib/features/wallet/views/` | Enhanced send | 1,536 lines |
| **contact.dart** | `/lib/domain/entities/` | Data model | Existing |
| **contacts_service.dart** | `/lib/services/contacts/` | API client | Existing |

### Documentation Files

| File | Purpose |
|------|---------|
| `CONTACTS_API_INTEGRATION.md` | Complete technical documentation |
| `CONTACTS_INTEGRATION_SUMMARY.md` | Implementation summary |
| `IMPLEMENTATION_COMPLETE.md` | Detailed completion checklist |
| `CONTACTS_QUICK_REFERENCE.md` | This file - quick reference |

---

## Providers Quick Reference

### Import
```dart
import '../providers/contacts_provider.dart';
```

### Available Providers

| Provider | Type | Cache | Usage |
|----------|------|-------|-------|
| `contactsProvider` | FutureProvider | 30s | All contacts |
| `favoritesProvider` | FutureProvider | 30s | Favorite contacts |
| `recentsProvider` | FutureProvider | 30s | Recent contacts |
| `searchContactsProvider` | FutureProvider.family | None | Search results |
| `contactProvider` | NotifierProvider | N/A | CRUD operations |

---

## Common Patterns

### 1. Display Contacts List
```dart
final contactsAsync = ref.watch(contactsProvider);

return contactsAsync.when(
  data: (contacts) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => ErrorWidget(),
);
```

### 2. Create Contact
```dart
final success = await ref.read(contactProvider.notifier).createContact(
  name: 'John Doe',
  phone: '+2250701234567',
);
```

### 3. Search Contacts
```dart
final results = ref.watch(searchContactsProvider(searchQuery));
```

### 4. Toggle Favorite
```dart
await ref.read(contactProvider.notifier).toggleFavorite(contactId);
```

### 5. Delete Contact
```dart
await ref.read(contactProvider.notifier).deleteContact(contactId);
```

### 6. Manual Refresh
```dart
ref.invalidate(contactsProvider);
```

---

## API Endpoints

| Method | Endpoint | Provider/Method |
|--------|----------|-----------------|
| GET | `/contacts` | `contactsProvider` |
| GET | `/contacts/favorites` | `favoritesProvider` |
| GET | `/contacts/recents` | `recentsProvider` |
| GET | `/contacts/search?query=<q>` | `searchContactsProvider` |
| POST | `/contacts` | `createContact()` |
| PUT | `/contacts/:id` | `updateContact()` |
| PUT | `/contacts/:id/favorite` | `toggleFavorite()` |
| DELETE | `/contacts/:id` | `deleteContact()` |

---

## Contact Model Fields

```dart
class Contact {
  final String id;               // UUID
  final String name;             // Display name
  final String? phone;           // Phone number
  final String? walletAddress;   // Ethereum address
  final String? username;        // JoonaPay username
  final bool isFavorite;         // Favorite flag
  final int transactionCount;    // Number of transactions
  final DateTime? lastTransactionAt; // Last transaction date
  final bool isJoonaPayUser;     // Is JoonaPay user
}
```

---

## UI Components

### SavedRecipientsView
- **Location**: `/lib/features/wallet/views/saved_recipients_view.dart`
- **Features**:
  - Three tabs (All, Favorites, Recent)
  - Search bar
  - Add recipient button
  - Swipe-to-delete
  - Pull-to-refresh
  - Toggle favorite

### SendView (Enhanced)
- **Location**: `/lib/features/wallet/views/send_view.dart`
- **New Features**:
  - "Saved" button for saved recipients
  - Auto-populate from saved contacts
  - Save prompt after transfers

---

## Error Handling

All operations return `bool` indicating success:

```dart
final success = await ref.read(contactProvider.notifier).createContact(...);

if (success) {
  // Success - lists auto-refresh
} else {
  final error = ref.read(contactProvider).error;
  // Handle error
}
```

---

## Performance Tips

1. **Use TTL Caching**: Providers auto-cache for 30s
2. **Avoid Manual Refresh**: Let providers auto-refresh on mutations
3. **Use autoDispose**: Providers clean up when not in use
4. **Search Server-Side**: Use `searchContactsProvider` for server search
5. **Pull-to-Refresh**: Add RefreshIndicator for manual refresh

---

## Testing Checklist

```bash
# Start backend
cd usdc-wallet && npm run start:dev

# Start mobile
cd mobile && flutter run
```

- [ ] View all contacts
- [ ] View favorites
- [ ] View recents
- [ ] Search contacts
- [ ] Create contact (phone)
- [ ] Create contact (username)
- [ ] Create contact (wallet)
- [ ] Toggle favorite
- [ ] Delete contact
- [ ] Send to saved contact
- [ ] Save new contact after transfer
- [ ] Pull to refresh

---

## Troubleshooting

### Contacts not loading?
1. Check backend is running
2. Check network connection
3. Check auth token is valid
4. Check API base URL in `api_client.dart`

### Cache not refreshing?
1. Wait 30 seconds for auto-refresh
2. Pull-to-refresh manually
3. Call `ref.invalidate(contactsProvider)`

### Create/Update/Delete not working?
1. Check backend logs for errors
2. Check request validation
3. Verify auth token
4. Check for ApiException in error state

---

## Code Snippets

### Custom Contact List Widget
```dart
class MyContactsList extends ConsumerWidget {
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
            trailing: IconButton(
              icon: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
              ),
              onPressed: () {
                ref.read(contactProvider.notifier).toggleFavorite(contact.id);
              },
            ),
          );
        },
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### Contact Search Widget
```dart
class ContactSearch extends ConsumerStatefulWidget {
  @override
  ConsumerState<ContactSearch> createState() => _ContactSearchState();
}

class _ContactSearchState extends ConsumerState<ContactSearch> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final resultsAsync = _query.isEmpty
        ? ref.watch(contactsProvider)
        : ref.watch(searchContactsProvider(_query));

    return Column(
      children: [
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(hintText: 'Search...'),
        ),
        Expanded(
          child: resultsAsync.when(
            data: (results) => ListView.builder(...),
            loading: () => CircularProgressIndicator(),
            error: (error, stack) => Text('Error: $error'),
          ),
        ),
      ],
    );
  }
}
```

---

## Best Practices

1. ✅ Always handle loading and error states
2. ✅ Use `ref.watch()` for reactive updates
3. ✅ Use `ref.read()` for one-time operations
4. ✅ Check `mounted` before showing snackbars
5. ✅ Dispose controllers in StatefulWidgets
6. ✅ Show confirmation dialogs for destructive actions
7. ✅ Invalidate cache after mutations
8. ✅ Use pull-to-refresh for manual updates

---

## Related Files

### Navigation
- `/lib/core/router/app_router.dart` - Route definitions
- Route name: `/saved-recipients`

### Design System
- `/lib/design/tokens/index.dart` - Design tokens
- `/lib/design/components/primitives/index.dart` - UI components

### State Management
- `/lib/state/index.dart` - Global state providers

---

## Support

For detailed documentation, see:
- `CONTACTS_API_INTEGRATION.md` - Full technical docs
- `IMPLEMENTATION_COMPLETE.md` - Implementation details
- `CONTACTS_USAGE_EXAMPLES.dart` - Code examples

---

**Last Updated**: January 25, 2026
**Status**: ✅ Production Ready
