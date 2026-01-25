// ============================================================================
// CONTACTS PROVIDER - USAGE EXAMPLES
// ============================================================================
// This file demonstrates how to use the contacts providers in your widgets.
// These are EXAMPLES ONLY - not meant to be imported or run.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/contact.dart';
import '../../../design/tokens/index.dart';
import 'contacts_provider.dart';

// ============================================================================
// EXAMPLE 1: Display All Contacts
// ============================================================================

class ContactsListExample extends ConsumerWidget {
  const ContactsListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the contacts provider - automatically rebuilds when data changes
    final contactsAsync = ref.watch(contactsProvider);

    // Handle loading, data, and error states
    return contactsAsync.when(
      // When data is loaded
      data: (contacts) {
        if (contacts.isEmpty) {
          return const Center(child: Text('No contacts'));
        }

        return ListView.builder(
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ListTile(
              title: Text(contact.name),
              subtitle: Text(contact.displayIdentifier),
              trailing: Icon(
                contact.isFavorite ? Icons.star : Icons.star_border,
              ),
            );
          },
        );
      },
      // While loading
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      // On error
      error: (error, stack) => Center(
        child: Text('Error: $error'),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Display Favorite Contacts Only
// ============================================================================

class FavoritesListExample extends ConsumerWidget {
  const FavoritesListExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoritesProvider);

    return favoritesAsync.when(
      data: (favorites) => ListView.builder(
        itemCount: favorites.length,
        itemBuilder: (context, index) {
          final contact = favorites[index];
          return ListTile(
            leading: const Icon(Icons.star, color: Colors.amber),
            title: Text(contact.name),
            subtitle: Text(contact.displayIdentifier),
          );
        },
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Search Contacts
// ============================================================================

class ContactSearchExample extends ConsumerStatefulWidget {
  const ContactSearchExample({super.key});

  @override
  ConsumerState<ContactSearchExample> createState() => _ContactSearchExampleState();
}

class _ContactSearchExampleState extends ConsumerState<ContactSearchExample> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Watch search provider with current query
    final searchResultsAsync = _searchQuery.isNotEmpty
        ? ref.watch(searchContactsProvider(_searchQuery))
        : null;

    return Column(
      children: [
        // Search input
        TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            prefixIcon: Icon(Icons.search),
          ),
        ),

        // Search results
        Expanded(
          child: searchResultsAsync == null
              ? const Center(child: Text('Type to search'))
              : searchResultsAsync.when(
                  data: (results) => ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final contact = results[index];
                      return ListTile(
                        title: Text(contact.name),
                        subtitle: Text(contact.displayIdentifier),
                      );
                    },
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 4: Create a New Contact
// ============================================================================

class CreateContactExample extends ConsumerStatefulWidget {
  const CreateContactExample({super.key});

  @override
  ConsumerState<CreateContactExample> createState() => _CreateContactExampleState();
}

class _CreateContactExampleState extends ConsumerState<CreateContactExample> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createContact() async {
    // Call the create method
    final success = await ref.read(contactProvider.notifier).createContact(
          name: _nameController.text,
          phone: _phoneController.text,
        );

    if (mounted) {
      if (success) {
        // Success! The contactsProvider will auto-refresh
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact created')),
        );
        Navigator.pop(context);
      } else {
        // Error - get the error message
        final error = ref.read(contactProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Failed to create contact')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the mutation state for loading indicator
    final contactState = ref.watch(contactProvider);

    return Column(
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        TextField(
          controller: _phoneController,
          decoration: const InputDecoration(labelText: 'Phone'),
          keyboardType: TextInputType.phone,
        ),
        ElevatedButton(
          onPressed: contactState.isLoading ? null : _createContact,
          child: contactState.isLoading
              ? const CircularProgressIndicator()
              : const Text('Create Contact'),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 5: Toggle Favorite Status
// ============================================================================

class ToggleFavoriteExample extends ConsumerWidget {
  const ToggleFavoriteExample({
    super.key,
    required this.contact,
  });

  final Contact contact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(
        contact.isFavorite ? Icons.star : Icons.star_border,
        color: contact.isFavorite ? Colors.amber : Colors.grey,
      ),
      onPressed: () async {
        // Toggle favorite
        final success = await ref
            .read(contactProvider.notifier)
            .toggleFavorite(contact.id);

        if (success) {
          // Success! Both contactsProvider and favoritesProvider will auto-refresh
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                contact.isFavorite
                    ? 'Removed from favorites'
                    : 'Added to favorites',
              ),
            ),
          );
        }
      },
    );
  }
}

// ============================================================================
// EXAMPLE 6: Update Contact Name
// ============================================================================

class UpdateContactExample extends ConsumerWidget {
  const UpdateContactExample({
    super.key,
    required this.contact,
  });

  final Contact contact;

  Future<void> _updateName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: contact.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final success = await ref.read(contactProvider.notifier).updateContact(
            contactId: contact.id,
            name: newName,
          );

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact updated')),
        );
      }
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      title: Text(contact.name),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _updateName(context, ref),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 7: Delete Contact
// ============================================================================

class DeleteContactExample extends ConsumerWidget {
  const DeleteContactExample({
    super.key,
    required this.contact,
  });

  final Contact contact;

  Future<void> _deleteContact(BuildContext context, WidgetRef ref) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact?'),
        content: Text('Remove ${contact.name} from your contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Delete the contact
      final success = await ref
          .read(contactProvider.notifier)
          .deleteContact(contact.id);

      if (context.mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _deleteContact(context, ref).then((_) => true),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: ListTile(
        title: Text(contact.name),
        subtitle: Text(contact.displayIdentifier),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Manual Refresh
// ============================================================================

class ManualRefreshExample extends ConsumerWidget {
  const ManualRefreshExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    return RefreshIndicator(
      // Pull-to-refresh
      onRefresh: () async {
        // Invalidate the provider to trigger a refresh
        ref.invalidate(contactsProvider);

        // Wait for the new data to load
        return ref.read(contactsProvider.future);
      },
      child: contactsAsync.when(
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 9: Recent Contacts for Quick Send
// ============================================================================

class RecentContactsChipsExample extends ConsumerWidget {
  const RecentContactsChipsExample({
    super.key,
    required this.onContactSelected,
  });

  final ValueChanged<Contact> onContactSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentsAsync = ref.watch(recentsProvider);

    return recentsAsync.when(
      data: (recents) {
        if (recents.isEmpty) return const SizedBox();

        return SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recents.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final contact = recents[index];
              return GestureDetector(
                onTap: () => onContactSelected(contact),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: contact.isJoonaPayUser
                          ? AppColors.gold500.withValues(alpha: 0.2)
                          : Colors.grey[800],
                      child: Text(
                        _getInitials(contact.name),
                        style: TextStyle(
                          color: contact.isJoonaPayUser
                              ? AppColors.gold500
                              : Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        contact.name.split(' ').first,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}

// ============================================================================
// EXAMPLE 10: Contact Selection Dialog
// ============================================================================

class ContactSelectionDialogExample extends ConsumerStatefulWidget {
  const ContactSelectionDialogExample({
    super.key,
    required this.onContactSelected,
  });

  final ValueChanged<Contact> onContactSelected;

  @override
  ConsumerState<ContactSelectionDialogExample> createState() =>
      _ContactSelectionDialogExampleState();
}

class _ContactSelectionDialogExampleState
    extends ConsumerState<ContactSelectionDialogExample> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contactsAsync = _searchQuery.isEmpty
        ? ref.watch(contactsProvider)
        : ref.watch(searchContactsProvider(_searchQuery));

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: contactsAsync.when(
              data: (contacts) => ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return ListTile(
                    title: Text(contact.name),
                    subtitle: Text(contact.displayIdentifier),
                    onTap: () {
                      widget.onContactSelected(contact);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
