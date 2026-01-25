import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/entities/contact.dart';
import '../providers/contacts_provider.dart';

class SavedRecipientsView extends ConsumerStatefulWidget {
  const SavedRecipientsView({super.key});

  @override
  ConsumerState<SavedRecipientsView> createState() =>
      _SavedRecipientsViewState();
}

class _SavedRecipientsViewState extends ConsumerState<SavedRecipientsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);
    final favoritesAsync = ref.watch(favoritesProvider);
    final recentsAsync = ref.watch(recentsProvider);
    final searchResultsAsync = _searchQuery.isNotEmpty
        ? ref.watch(searchContactsProvider(_searchQuery))
        : null;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Saved Recipients',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: AppColors.gold500),
            onPressed: () => _showAddRecipient(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold500,
          labelColor: AppColors.gold500,
          unselectedLabelColor: AppColors.textTertiary,
          tabs: [
            Tab(
              text: contactsAsync.maybeWhen(
                data: (contacts) => 'All (${_filterContacts(contacts).length})',
                orElse: () => 'All',
              ),
            ),
            Tab(
              text: favoritesAsync.maybeWhen(
                data: (favorites) => 'Favorites (${_filterContacts(favorites).length})',
                orElse: () => 'Favorites',
              ),
            ),
            const Tab(text: 'Recent'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipients...',
                hintStyle: const TextStyle(color: AppColors.textTertiary),
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textTertiary),
                filled: true,
                fillColor: AppColors.slate,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Content
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(searchResultsAsync!)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildContactsList(contactsAsync),
                      _buildContactsList(favoritesAsync),
                      _buildContactsList(recentsAsync),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Filter contacts by search query (client-side filter)
  List<Contact> _filterContacts(List<Contact> contacts) {
    if (_searchQuery.isEmpty) return contacts;

    return contacts.where((c) {
      return c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.phone?.contains(_searchQuery) ?? false) ||
          (c.username?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (c.walletAddress?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
    }).toList();
  }

  Widget _buildSearchResults(AsyncValue<List<Contact>> searchResultsAsync) {
    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppText(
                  'No results found',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final contact = results[index];
            return _RecipientCard(
              contact: contact,
              onTap: () => _sendToRecipient(contact),
              onFavoriteToggle: () => _toggleFavorite(contact.id),
              onDelete: () => _deleteRecipient(contact),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold500),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorBase,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Error: ${error.toString()}',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Retry',
              onPressed: () {
                ref.invalidate(searchContactsProvider(_searchQuery));
              },
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(AsyncValue<List<Contact>> contactsAsync) {
    return contactsAsync.when(
      data: (contacts) {
        final filteredContacts = _filterContacts(contacts);

        if (filteredContacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppText(
                  'No recipients found',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Add Recipient',
                  onPressed: _showAddRecipient,
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(contactsProvider);
            ref.invalidate(favoritesProvider);
            ref.invalidate(recentsProvider);
          },
          color: AppColors.gold500,
          backgroundColor: AppColors.slate,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            itemCount: filteredContacts.length,
            itemBuilder: (context, index) {
              final contact = filteredContacts[index];
              return _RecipientCard(
                contact: contact,
                onTap: () => _sendToRecipient(contact),
                onFavoriteToggle: () => _toggleFavorite(contact.id),
                onDelete: () => _deleteRecipient(contact),
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.gold500),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorBase,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Failed to load contacts',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Retry',
              onPressed: () {
                ref.invalidate(contactsProvider);
                ref.invalidate(favoritesProvider);
                ref.invalidate(recentsProvider);
              },
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _sendToRecipient(Contact contact) {
    // Navigate to send view with pre-filled recipient
    context.push('/send', extra: contact);
  }

  Future<void> _toggleFavorite(String id) async {
    final success = await ref.read(contactProvider.notifier).toggleFavorite(id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorite updated'),
            backgroundColor: AppColors.successBase,
          ),
        );
      } else {
        final error = ref.read(contactProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to update favorite'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  void _deleteRecipient(Contact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const Text('Delete Recipient?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Remove ${contact.name} from your saved recipients?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final success = await ref.read(contactProvider.notifier).deleteContact(contact.id);

              if (mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recipient removed'),
                      backgroundColor: AppColors.successBase,
                    ),
                  );
                } else {
                  final error = ref.read(contactProvider).error;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error ?? 'Failed to delete contact'),
                      backgroundColor: AppColors.errorBase,
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorBase)),
          ),
        ],
      ),
    );
  }

  void _showAddRecipient() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _AddRecipientSheet(
          onAdded: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Recipient added'),
                backgroundColor: AppColors.successBase,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({
    required this.contact,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onDelete,
  });

  final Contact contact;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.slate,
            title: const Text('Delete Recipient?', style: TextStyle(color: AppColors.textPrimary)),
            content: Text(
              'Remove ${contact.name} from your saved recipients?',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete', style: TextStyle(color: AppColors.errorBase)),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorBase,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: contact.isJoonaPayUser
                      ? AppColors.gold500.withValues(alpha: 0.2)
                      : AppColors.slate,
                  shape: BoxShape.circle,
                ),
                child: contact.walletAddress != null && contact.phone == null
                    ? const Icon(
                        Icons.account_balance_wallet,
                        color: AppColors.textSecondary,
                      )
                    : Center(
                        child: AppText(
                          _getInitials(contact.name),
                          variant: AppTextVariant.titleMedium,
                          color: contact.isJoonaPayUser
                              ? AppColors.gold500
                              : AppColors.textSecondary,
                        ),
                      ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: AppText(
                            contact.name,
                            variant: AppTextVariant.bodyLarge,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (contact.isJoonaPayUser) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const Icon(
                            Icons.verified,
                            color: AppColors.gold500,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      contact.displayIdentifier,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                    ),
                    if (contact.transactionCount > 0) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        '${contact.transactionCount} transfers',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              Column(
                children: [
                  GestureDetector(
                    onTap: onFavoriteToggle,
                    child: Icon(
                      contact.isFavorite ? Icons.star : Icons.star_border,
                      color: contact.isFavorite
                          ? AppColors.gold500
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold500,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const AppText(
                      'Send',
                      variant: AppTextVariant.labelSmall,
                      color: AppColors.obsidian,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

class _AddRecipientSheet extends ConsumerStatefulWidget {
  const _AddRecipientSheet({required this.onAdded});

  final VoidCallback onAdded;

  @override
  ConsumerState<_AddRecipientSheet> createState() => _AddRecipientSheetState();
}

class _AddRecipientSheetState extends ConsumerState<_AddRecipientSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _walletController = TextEditingController();
  String _recipientType = 'phone'; // 'phone', 'username', 'wallet'
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          const AppText(
            'Add Recipient',
            variant: AppTextVariant.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Type Toggle
          Row(
            children: [
              Expanded(
                child: _TypeButton(
                  label: 'Phone',
                  isSelected: _recipientType == 'phone',
                  onTap: () => setState(() => _recipientType = 'phone'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TypeButton(
                  label: 'Username',
                  isSelected: _recipientType == 'username',
                  onTap: () => setState(() => _recipientType = 'username'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _TypeButton(
                  label: 'Wallet',
                  isSelected: _recipientType == 'wallet',
                  onTap: () => setState(() => _recipientType = 'wallet'),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.xl),

          // Name
          const AppText(
            'Name',
            variant: AppTextVariant.labelMedium,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppInput(
            controller: _nameController,
            hint: 'Enter name',
          ),

          const SizedBox(height: AppSpacing.lg),

          // Type-specific field
          if (_recipientType == 'phone') ...[
            const AppText(
              'Phone Number',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _phoneController,
              hint: '+225 XX XX XX XX',
              keyboardType: TextInputType.phone,
            ),
          ] else if (_recipientType == 'username') ...[
            const AppText(
              'JoonaPay Username',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _usernameController,
              hint: '@username',
              prefixIcon: Icons.alternate_email,
            ),
          ] else ...[
            const AppText(
              'Wallet Address',
              variant: AppTextVariant.labelMedium,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppInput(
              controller: _walletController,
              hint: '0x...',
              keyboardType: TextInputType.text,
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Add Button
          AppButton(
            label: 'Add Recipient',
            onPressed: _canAdd() ? _add : null,
            variant: AppButtonVariant.primary,
            isFullWidth: true,
            isLoading: _isSubmitting,
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  bool _canAdd() {
    if (_nameController.text.isEmpty) return false;

    switch (_recipientType) {
      case 'phone':
        return _phoneController.text.isNotEmpty;
      case 'username':
        return _usernameController.text.isNotEmpty;
      case 'wallet':
        return _walletController.text.isNotEmpty;
      default:
        return false;
    }
  }

  Future<void> _add() async {
    setState(() => _isSubmitting = true);

    String? phone;
    String? username;
    String? walletAddress;

    switch (_recipientType) {
      case 'phone':
        phone = _phoneController.text;
        break;
      case 'username':
        username = _usernameController.text.replaceFirst('@', '');
        break;
      case 'wallet':
        walletAddress = _walletController.text;
        break;
    }

    final success = await ref.read(contactProvider.notifier).createContact(
          name: _nameController.text,
          phone: phone,
          username: username,
          walletAddress: walletAddress,
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        widget.onAdded();
      } else {
        final error = ref.read(contactProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to add recipient'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500 : AppColors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: isSelected ? AppColors.obsidian : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
