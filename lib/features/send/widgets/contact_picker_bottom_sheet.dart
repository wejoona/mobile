import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/countries_provider.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

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
  List<SyncedContact> _lookupResults = [];
  bool _isLoading = true;
  bool _isLookupLoading = false;
  bool _permissionRequired = false;
  Timer? _lookupDebounce;

  @override
  void initState() {
    super.initState();
    unawaited(_loadContacts());
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _loadDeviceContacts();

      if (mounted) {
        setState(() {
          _contacts = contacts;
          _filteredContacts = contacts;
          _permissionRequired = false;
          _isLoading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<SyncedContact>> _loadDeviceContacts() async {
    final contactsService = ref.read(contactsServiceProvider);
    if (!await contactsService.hasContactsPermission()) {
      if (mounted) {
        setState(() {
          _permissionRequired = true;
          _isLoading = false;
        });
      }
      return const [];
    }

    final deviceContacts = await contactsService.getDeviceContacts();
    var contacts = contactsService.deviceContactsToSyncedContacts(
      deviceContacts,
      defaultCountryPrefix: _defaultCountryPrefix(),
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

  String _defaultCountryPrefix() {
    final userCountryCode = ref.read(userStateMachineProvider).countryCode;
    final selectedCountry = ref.read(selectedCountryProvider);
    final country =
        SupportedCountries.findByCode(userCountryCode) ?? selectedCountry;
    return country.prefix;
  }

  Future<void> _requestContactsPermission() async {
    setState(() => _isLoading = true);
    final granted = await ref
        .read(contactsServiceProvider)
        .requestContactsPermission();
    if (!mounted) {
      return;
    }
    if (granted) {
      await _loadContacts();
      return;
    }
    setState(() {
      _permissionRequired = true;
      _isLoading = false;
    });
  }

  void _sortContacts(List<SyncedContact> contacts) {
    contacts.sort((a, b) {
      if (a.isKoridoUser && !b.isKoridoUser) {
        return -1;
      }
      if (!a.isKoridoUser && b.isKoridoUser) {
        return 1;
      }
      return a.name.compareTo(b.name);
    });
  }

  void _filterContacts(String query) {
    _lookupDebounce?.cancel();
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

    _lookupDebounce = Timer(
      const Duration(milliseconds: 280),
      () => _lookupKoridoUsers(query),
    );
  }

  Future<void> _lookupKoridoUsers(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 3) {
      if (mounted) {
        setState(() {
          _lookupResults = [];
          _isLookupLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() => _isLookupLoading = true);
    }

    try {
      final results = await ref
          .read(joonaPayContactsServiceProvider)
          .lookupKoridoUsers(trimmed);
      final localPhones = _contacts.map((contact) => contact.phone).toSet();
      final filteredResults = results
          .where(
            (result) =>
                result.phone.isEmpty || !localPhones.contains(result.phone),
          )
          .toList();

      if (mounted && _searchController.text.trim() == trimmed) {
        setState(() {
          _lookupResults = filteredResults;
          _isLookupLoading = false;
        });
      }
    } on Object {
      if (mounted && _searchController.text.trim() == trimmed) {
        setState(() {
          _lookupResults = [];
          _isLookupLoading = false;
        });
      }
    }
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
          if (!_permissionRequired) ...[
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
          ],

          // Contacts list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                    ),
                  )
                : _permissionRequired
                ? _buildPermissionRequest(colors)
                : _filteredContacts.isEmpty && _lookupResults.isEmpty
                ? Center(
                    child: AppText(
                      l10n.send_noContactsFound,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    children: [
                      if (_searchController.text.trim().length >= 3)
                        _buildLookupSection(colors),
                      if (_filteredContacts.isNotEmpty) ...[
                        if (_searchController.text.trim().length >= 3)
                          _buildSectionLabel(l10n.contacts_allContacts, colors),
                        ..._filteredContacts.map(
                          (contact) => _buildContactItem(contact, colors),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRequest(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      children: [
        AppCard(
          variant: AppCardVariant.goldAccent,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.goldSubtle,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.borderGold),
                ),
                child: Icon(
                  Icons.contacts_outlined,
                  color: colors.gold,
                  size: 30,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
              AppText(
                l10n.contacts_permission_title,
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
                fontWeight: FontWeight.w700,
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.contacts_permission_benefit2_desc,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.contacts_permission_allow,
                icon: Icons.person_search_rounded,
                isFullWidth: true,
                onPressed: () => unawaited(_requestContactsPermission()),
              ),
              SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.action_open_settings,
                icon: Icons.settings_outlined,
                variant: AppButtonVariant.secondary,
                isFullWidth: true,
                onPressed: () => unawaited(openAppSettings()),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLookupSection(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLookupLoading) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
              ),
            ),
            SizedBox(width: AppSpacing.sm),
            AppText(
              _localizedText(
                en: 'Searching Korido accounts',
                fr: 'Recherche de comptes Korido',
              ),
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ],
        ),
      );
    }

    if (_lookupResults.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined, color: colors.textSecondary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  l10n.contacts_no_results,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(l10n.contacts_on_joonapay, colors),
        ..._lookupResults.map(
          (contact) => _buildContactItem(contact, colors, fromLookup: true),
        ),
        SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildSectionLabel(String label, ThemeColors colors) {
    return Padding(
      padding: EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
      child: AppText(
        label,
        variant: AppTextVariant.labelMedium,
        color: colors.textSecondary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildContactItem(
    SyncedContact contact,
    ThemeColors colors, {
    bool fromLookup = false,
  }) {
    final verifiedAccount = _localizedText(
      en: 'Verified Korido account',
      fr: 'Compte Korido vérifié',
    );
    final canSelect = !fromLookup || contact.phone.isNotEmpty;

    return GestureDetector(
      key: ValueKey(
        fromLookup
            ? 'contact_lookup_${contact.joonaPayUserId ?? contact.id}'
            : 'contact_picker_${contact.id}',
      ),
      behavior: HitTestBehavior.opaque,
      onTap: canSelect
          ? () => Navigator.pop(context, contact)
          : () => _showLookupNeedsPhoneMessage(),
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
                    fromLookup && contact.phone.isEmpty
                        ? _localizedText(
                            en: 'Korido account found',
                            fr: 'Compte Korido trouvé',
                          )
                        : fromLookup
                        ? verifiedAccount
                        : contact.phone,
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

  void _showLookupNeedsPhoneMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _localizedText(
            en: 'This account is discoverable, but a phone number is required to send for now.',
            fr: 'Ce compte est visible, mais un numéro de téléphone est requis pour envoyer pour le moment.',
          ),
        ),
      ),
    );
  }

  String _localizedText({required String en, required String fr}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale == 'fr' ? fr : en;
  }
}
