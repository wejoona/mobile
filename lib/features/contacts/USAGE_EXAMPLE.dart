// USAGE EXAMPLE - Contact Sync Feature
// This file demonstrates how to use the contact sync feature

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/contacts_provider.dart';
import 'views/contacts_permission_screen.dart';
import 'views/contacts_list_screen.dart';
import 'widgets/contact_card.dart';
import 'widgets/invite_sheet.dart';
import 'models/synced_contact.dart';
import '../../design/tokens/index.dart';

// ============================================================================
// EXAMPLE 1: Navigate to Permission Screen
// ============================================================================

class SendMoneyScreen extends ConsumerWidget {
  const SendMoneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Check if user has granted permission
            final state = ref.read(contactsProvider);

            if (state.permissionState == PermissionState.granted) {
              // Go directly to contacts list
              context.push('/contacts/list');
            } else {
              // Show permission screen first
              context.push('/contacts/permission');
            }
          },
          child: const Text('Select from Contacts'),
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: Request Permission Programmatically
// ============================================================================

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Optional: Check permission on app launch
    Future.microtask(() {
      ref.read(contactsProvider.notifier).checkPermission();
    });
  }

  Future<void> _requestContactsAndSync() async {
    final notifier = ref.read(contactsProvider.notifier);

    // Request permission
    final granted = await notifier.requestPermission();

    if (granted) {
      // Permission granted, contacts auto-synced
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts synced successfully!')),
        );

        // Navigate to contacts list
        context.push('/contacts/list');
      }
    } else {
      // Permission denied
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contacts permission denied')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Column(
        children: [
          // Show JoonaPay contacts count
          if (state.joonaPayUsers.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.people),
              title: Text('${state.joonaPayUsers.length} friends on JoonaPay'),
              onTap: () => context.push('/contacts/list'),
            ),

          // Request contacts button
          if (state.permissionState != PermissionState.granted)
            ElevatedButton(
              onPressed: _requestContactsAndSync,
              child: const Text('Find Friends on JoonaPay'),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: Display Contact List with Actions
// ============================================================================

class MyContactsWidget extends ConsumerWidget {
  const MyContactsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contactsProvider);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text('Error: ${state.error}'));
    }

    final joonaPayUsers = state.joonaPayUsers;

    return ListView.builder(
      itemCount: joonaPayUsers.length,
      itemBuilder: (context, index) {
        final contact = joonaPayUsers[index];

        return ContactCard(
          contact: contact,
          onTap: () {
            // Navigate to send screen with pre-filled recipient
            context.push('/send', extra: {
              'recipientId': contact.joonaPayUserId,
            });
          },
          onSend: () {
            // Quick send action
            context.push('/send', extra: {
              'recipientId': contact.joonaPayUserId,
            });
          },
        );
      },
    );
  }
}

// ============================================================================
// EXAMPLE 4: Manual Sync (Pull-to-Refresh)
// ============================================================================

class ContactsWithRefresh extends ConsumerWidget {
  const ContactsWithRefresh({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contactsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        // Manually trigger sync
        await ref.read(contactsProvider.notifier).syncContacts();
      },
      child: ListView.builder(
        itemCount: state.contacts.length,
        itemBuilder: (context, index) {
          final contact = state.contacts[index];
          return ContactCard(contact: contact);
        },
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 5: Invite Non-JoonaPay User
// ============================================================================

class InviteContactExample extends StatelessWidget {
  final SyncedContact contact;

  const InviteContactExample({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Show invite bottom sheet
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => InviteSheet(contact: contact),
        );
      },
      child: const Text('Invite to JoonaPay'),
    );
  }
}

// ============================================================================
// EXAMPLE 6: Search Contacts
// ============================================================================

class SearchContactsExample extends ConsumerStatefulWidget {
  const SearchContactsExample({super.key});

  @override
  ConsumerState<SearchContactsExample> createState() => _SearchContactsExampleState();
}

class _SearchContactsExampleState extends ConsumerState<SearchContactsExample> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contactsProvider);

    // Filter contacts based on search query
    final filteredContacts = _query.isEmpty
        ? state.contacts
        : state.searchContacts(_query);

    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search contacts...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _query = value);
          },
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = filteredContacts[index];
              return ContactCard(contact: contact);
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 7: Show JoonaPay Badge
// ============================================================================

class ContactWithBadge extends StatelessWidget {
  final SyncedContact contact;

  const ContactWithBadge({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(contact.name),
          if (contact.isJoonaPayUser) ...[
            const SizedBox(width: 8),
            Icon(Icons.verified, color: AppColors.gold500, size: 16),
          ],
        ],
      ),
      subtitle: Text(contact.phone),
      trailing: contact.isJoonaPayUser
          ? ElevatedButton(
              onPressed: () {
                // Send money
              },
              child: const Text('Send'),
            )
          : OutlinedButton(
              onPressed: () {
                // Invite
              },
              child: const Text('Invite'),
            ),
    );
  }
}

// ============================================================================
// EXAMPLE 8: Background Sync on App Launch
// ============================================================================

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

    // Check if permission was previously granted
    await notifier.checkPermission();

    final state = ref.read(contactsProvider);
    if (state.permissionState == PermissionState.granted) {
      // Background sync (don't wait)
      notifier.loadAndSyncContacts();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ============================================================================
// EXAMPLE 9: Show Sync Status
// ============================================================================

class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(contactsProvider);

    if (state.isSyncing) {
      return const ListTile(
        leading: CircularProgressIndicator(),
        title: Text('Syncing contacts...'),
      );
    }

    if (state.lastSyncResult != null) {
      final result = state.lastSyncResult!;
      return ListTile(
        leading: const Icon(Icons.sync, color: Colors.green),
        title: Text('Found ${result.joonaPayUsersFound} friends'),
        subtitle: Text('Last synced: ${_formatTime(result.syncedAt)}'),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            ref.read(contactsProvider.notifier).syncContacts();
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ============================================================================
// EXAMPLE 10: Complete Integration in Send Flow
// ============================================================================

class CompleteIntegrationExample extends ConsumerStatefulWidget {
  const CompleteIntegrationExample({super.key});

  @override
  ConsumerState<CompleteIntegrationExample> createState() =>
      _CompleteIntegrationExampleState();
}

class _CompleteIntegrationExampleState
    extends ConsumerState<CompleteIntegrationExample> {
  Future<void> _selectRecipient() async {
    final state = ref.read(contactsProvider);

    if (state.permissionState == PermissionState.granted) {
      // Permission already granted, show contacts
      final contact = await Navigator.push<SyncedContact>(
        context,
        MaterialPageRoute(
          builder: (context) => const ContactsListScreen(),
        ),
      );

      if (contact != null && contact.isJoonaPayUser) {
        // Navigate to send screen with selected contact
        if (mounted) {
          context.push('/send', extra: {
            'recipientId': contact.joonaPayUserId,
            'recipientName': contact.name,
          });
        }
      }
    } else {
      // Request permission first
      final granted = await ref.read(contactsProvider.notifier).requestPermission();

      if (granted && mounted) {
        _selectRecipient(); // Retry
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.contacts),
            title: const Text('Select from Contacts'),
            subtitle: const Text('Send to JoonaPay users'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _selectRecipient,
          ),
        ],
      ),
    );
  }
}
