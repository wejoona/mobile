import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/contacts/providers/contacts_provider.dart';
import 'package:usdc_wallet/design/components/primitives/contact_tile.dart';
import 'package:usdc_wallet/design/components/primitives/search_bar.dart';
import 'package:usdc_wallet/design/components/primitives/empty_state.dart';

/// Contacts list screen.
class ContactsView extends ConsumerStatefulWidget {
  const ContactsView({super.key});

  @override
  ConsumerState<ContactsView> createState() => _ContactsViewState();
}

class _ContactsViewState extends ConsumerState<ContactsView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(appContactsProvider);
    final favorites = ref.watch(favoriteContactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: [
          IconButton(icon: const Icon(Icons.person_add_rounded), onPressed: () {}),
        ],
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (contacts) {
          final filtered = _searchQuery.isEmpty
              ? contacts
              : ref.read(contactSearchProvider(_searchQuery));

          if (contacts.isEmpty) {
            return EmptyState(
              icon: Icons.people_rounded,
              title: 'No contacts yet',
              subtitle: 'Sync your phone contacts to find friends on Korido',
              actionLabel: 'Sync Contacts',
              onAction: () async {
                final actions = ref.read(contactActionsProvider);
                await actions.syncPhoneContacts([]);
                ref.invalidate(appContactsProvider);
              },
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: AppSearchBar(
                  hintText: 'Search contacts...',
                  onChanged: (q) => setState(() => _searchQuery = q),
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => ref.refresh(appContactsProvider.future),
                  child: ListView(
                    children: [
                      if (_searchQuery.isEmpty && favorites.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text('Favorites', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ),
                        ...favorites.map((c) => ContactTile(contact: c, onTap: () {})),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: Text('All Contacts', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ),
                      ],
                      ...filtered.map((c) => ContactTile(contact: c, onTap: () {})),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
