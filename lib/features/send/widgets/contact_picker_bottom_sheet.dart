import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

class ContactPickerBottomSheet extends ConsumerStatefulWidget {
  const ContactPickerBottomSheet({super.key});

  @override
  ConsumerState<ContactPickerBottomSheet> createState() =>
      _ContactPickerBottomSheetState();
}

class _ContactPickerBottomSheetState
    extends ConsumerState<ContactPickerBottomSheet> {
  final _searchController = TextEditingController();
  List<SyncedContact> _contacts = [];
  List<SyncedContact> _filteredContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = MockConfig.useMocks
          ? await _loadMockContacts()
          : await _loadDeviceContacts();

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
          _isLoading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<SyncedContact>> _loadMockContacts() async {
    final response = await ref.read(dioProvider).get('/contacts');
    final contacts = _extractContactList(
      response.data,
    ).map(SyncedContact.fromJson).toList();
    _sortContacts(contacts);
    return contacts;
  }

  Future<List<SyncedContact>> _loadDeviceContacts() async {
    final contactsService = ref.read(contactsServiceProvider);
    final deviceContacts = await contactsService.getDeviceContacts();
    var contacts = contactsService.deviceContactsToSyncedContacts(
      deviceContacts,
    );

    try {
      contacts = await contactsService.getKoridoContacts(
        ref.read(dioProvider),
        contacts,
      );
    } on Object {
      // Keep the picker usable even if the API cannot return account matches.
    }

    _sortContacts(contacts);
    return contacts;
  }

  List<Map<String, dynamic>> _extractContactList(Object? data) {
    final raw = switch (data) {
      {'contacts': final List contacts} => contacts,
      {'data': final List contacts} => contacts,
      {'items': final List contacts} => contacts,
      final List contacts => contacts,
      _ => const <Object?>[],
    };

    return raw
        .whereType<Map>()
        .map((contact) => Map<String, dynamic>.from(contact))
        .toList();
  }

  void _sortContacts(List<SyncedContact> contacts) {
    contacts.sort((a, b) {
      if (a.isKoridoUser && !b.isKoridoUser) return -1;
      if (!a.isKoridoUser && b.isKoridoUser) return 1;
      return a.name.compareTo(b.name);
    });
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where(
              (contact) =>
                  contact.name.toLowerCase().contains(query.toLowerCase()) ||
                  contact.phone.contains(query),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  l10n.send_selectContact,
                  variant: AppTextVariant.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: colors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppInput(
              controller: _searchController,
              hint: l10n.send_searchContacts,
              prefixIcon: Icons.search,
              onChanged: _filterContacts,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Contacts list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                    ),
                  )
                : _filteredContacts.isEmpty
                ? Center(
                    child: AppText(
                      l10n.send_noContactsFound,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      return _buildContactItem(contact, colors);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(SyncedContact contact, ThemeColors colors) {
    return GestureDetector(
      key: ValueKey('contact_picker_${contact.id}'),
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context, contact),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  imageUrl: contact.avatarUrl,
                  firstName: contact.name.split(' ').first,
                  lastName: contact.name.split(' ').length > 1
                      ? contact.name.split(' ').last
                      : null,
                  size: 40,
                  showBorder: contact.isKoridoUser,
                  borderColor: colors.gold,
                ),
                if (contact.isKoridoUser)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: KoridoAccountBadge(compact: true),
                  ),
              ],
            ),
            SizedBox(width: AppSpacing.md),
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
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact.isKoridoUser) ...[
                        SizedBox(width: AppSpacing.xs),
                        const KoridoAccountBadge(compact: true),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    contact.phone,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
}
