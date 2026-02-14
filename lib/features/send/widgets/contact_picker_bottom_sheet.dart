import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
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
  List<ContactInfo> _contacts = [];
  List<ContactInfo> _filteredContacts = [];
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
      final contactsService = ref.read(contactsServiceProvider);
      final contacts = await contactsService.getContacts();

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = _contacts;
      } else {
        _filteredContacts = _contacts
            .where((contact) =>
                contact.name.toLowerCase().contains(query.toLowerCase()) ||
                contact.phoneNumber.contains(query))
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
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
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
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.gold),
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
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
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

  Widget _buildContactItem(ContactInfo contact, ThemeColors colors) {
    return InkWell(
      onTap: () => Navigator.pop(context, contact),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.gold.withValues(alpha: 0.2),
              child: AppText(
                contact.name[0].toUpperCase(),
                variant: AppTextVariant.bodyLarge,
                color: colors.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    contact.name,
                    variant: AppTextVariant.bodyLarge,
                    fontWeight: FontWeight.w600,
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    contact.phoneNumber,
                    variant: AppTextVariant.bodySmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
