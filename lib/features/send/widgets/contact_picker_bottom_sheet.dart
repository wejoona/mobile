import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  bool _lookupFailed = false;
  bool _permissionRequired = false;
  bool _requiresSettings = false;
  bool _isPermissionActionLoading = false;
  bool _initialPermissionPromptAttempted = false;
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
          _requiresSettings = false;
          _isLoading = false;
        });
      }
    } on Object {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _permissionRequired = true;
          _requiresSettings = false;
        });
      }
    }
  }

  Future<List<SyncedContact>> _loadDeviceContacts() async {
    final contactsService = ref.read(contactsServiceProvider);
    final hasPermission = await contactsService.hasContactsPermission();
    if (!hasPermission) {
      final requiresSettings = await contactsService
          .contactsPermissionRequiresSettings();

      // Opening the picker from "From contacts" is already an explicit user
      // action. Request immediately while iOS/Android can still show the
      // system prompt; otherwise the sheet feels like it reports an error
      // without ever asking for permission.
      if (!requiresSettings && !_initialPermissionPromptAttempted) {
        _initialPermissionPromptAttempted = true;
        final granted = await contactsService.requestContactsPermission();
        if (granted) {
          return _readSyncedDeviceContacts(contactsService);
        }
      }

      final refreshedRequiresSettings = await contactsService
          .contactsPermissionRequiresSettings();
      if (mounted) {
        setState(() {
          _permissionRequired = true;
          _requiresSettings = refreshedRequiresSettings;
          _isLoading = false;
        });
      }
      return const [];
    }

    return _readSyncedDeviceContacts(contactsService);
  }

  Future<List<SyncedContact>> _readSyncedDeviceContacts(
    ContactsService contactsService,
  ) async {
    final deviceContacts = await contactsService.getDeviceContacts();
    var contacts = contactsService.deviceContactsToSyncedContacts(
      deviceContacts,
      defaultCountryPrefix: _defaultCountryPrefix(),
    );

    try {
      contacts = await contactsService.getKoridoContacts(
        ref.read(dioProvider),
        contacts,
        defaultCountryPrefix: _defaultCountryPrefix(),
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
    if (_isPermissionActionLoading) {
      return;
    }
    setState(() => _isPermissionActionLoading = true);
    final contactsService = ref.read(contactsServiceProvider);
    final l10n = AppLocalizations.of(context)!;

    try {
      if (await contactsService.contactsPermissionRequiresSettings()) {
        if (mounted) {
          setState(() {
            _permissionRequired = true;
            _requiresSettings = true;
          });
        }
        await contactsService.openContactsSettings();
        return;
      }

      final granted = await contactsService.requestContactsPermission();
      if (!mounted) {
        return;
      }
      if (granted) {
        await _loadContacts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _localizedText(
                  en: 'Contacts are ready',
                  fr: 'Vos contacts sont prêts',
                ),
              ),
            ),
          );
        }
        return;
      }

      final requiresSettings = await contactsService
          .contactsPermissionRequiresSettings();
      if (mounted) {
        setState(() {
          _permissionRequired = true;
          _requiresSettings = requiresSettings;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contacts_permission_denied_message)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isPermissionActionLoading = false;
        });
      }
    }
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
          _lookupFailed = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLookupLoading = true;
        _lookupFailed = false;
      });
    }

    try {
      final results = await ref
          .read(koridoContactsServiceProvider)
          .lookupKoridoUsers(trimmed);
      final localPhones = _contacts.map((contact) => contact.phone).toSet();
      final localUserIds = _contacts
          .map((contact) => contact.joonaPayUserId ?? contact.id)
          .where((id) => id.isNotEmpty)
          .toSet();
      final filteredResults = results.where((result) {
        final userId = result.joonaPayUserId ?? result.id;
        final duplicatePhone =
            result.phone.isNotEmpty && localPhones.contains(result.phone);
        final duplicateUser =
            userId.isNotEmpty && localUserIds.contains(userId);
        return !duplicatePhone && !duplicateUser;
      }).toList();

      if (mounted && _searchController.text.trim() == trimmed) {
        setState(() {
          _lookupResults = filteredResults;
          _isLookupLoading = false;
          _lookupFailed = false;
        });
      }
    } on Object {
      if (mounted && _searchController.text.trim() == trimmed) {
        setState(() {
          _lookupResults = [];
          _isLookupLoading = false;
          _lookupFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final query = _searchController.text.trim();
    final canShowLookupWithoutContacts =
        _permissionRequired && query.length >= 3;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpacing.sm),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppInput(
              controller: _searchController,
              hint: l10n.send_searchContacts,
              prefixIcon: Icons.search,
              onChanged: _filterContacts,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Contacts list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colors.gold),
                    ),
                  )
                : _permissionRequired && !canShowLookupWithoutContacts
                ? _buildPermissionRequest(colors)
                : _filteredContacts.isEmpty &&
                      _lookupResults.isEmpty &&
                      !_isLookupLoading
                ? _buildEmptyState(colors)
                : ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    children: [
                      if (query.length >= 3) _buildLookupSection(colors),
                      if (_permissionRequired) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildPermissionRequestCard(colors),
                      ],
                      if (_filteredContacts.isNotEmpty) ...[
                        if (query.length >= 3)
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

  Widget _buildEmptyState(ThemeColors colors) {
    final query = _searchController.text.trim();
    final isSearchingKorido = query.length >= 3;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _lookupFailed
                  ? Icons.cloud_off_outlined
                  : Icons.person_search_outlined,
              color: colors.textTertiary,
              size: 34,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              _lookupFailed
                  ? _localizedText(
                      en: 'Korido search is unavailable',
                      fr: 'La recherche Korido est indisponible',
                    )
                  : isSearchingKorido
                  ? _localizedText(
                      en: 'No Korido account found',
                      fr: 'Aucun compte Korido trouvé',
                    )
                  : AppLocalizations.of(context)!.send_noContactsFound,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
            ),
            if (_lookupFailed) ...[
              const SizedBox(height: AppSpacing.xs),
              AppText(
                _localizedText(
                  en: 'Try again in a moment, or enter the recipient manually.',
                  fr: 'Réessayez dans un instant ou saisissez le destinataire manuellement.',
                ),
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionRequest(ThemeColors colors) => ListView(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    children: [_buildPermissionRequestCard(colors)],
  );

  Widget _buildPermissionRequestCard(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;

    return AppCard(
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
            child: Icon(Icons.contacts_outlined, color: colors.gold, size: 30),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            l10n.contacts_permission_title,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            l10n.contacts_permission_benefit2_desc,
            color: colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          if (!_requiresSettings) ...[
            const SizedBox(height: AppSpacing.sm),
            AppText(
              _localizedText(
                en: 'You can still search Korido accounts by name, username, or phone.',
                fr: 'Vous pouvez toujours rechercher des comptes Korido par nom, identifiant ou numéro.',
              ),
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: _requiresSettings
                ? l10n.action_open_settings
                : l10n.contacts_permission_allow,
            icon: _requiresSettings
                ? Icons.settings_outlined
                : Icons.person_search_rounded,
            isFullWidth: true,
            isLoading: _isPermissionActionLoading,
            onPressed: _isPermissionActionLoading
                ? null
                : () => unawaited(_requestContactsPermission()),
          ),
        ],
      ),
    );
  }

  Widget _buildLookupSection(ThemeColors colors) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLookupLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
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
            const SizedBox(width: AppSpacing.sm),
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
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: AppCard(
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined, color: colors.textSecondary),
              const SizedBox(width: AppSpacing.sm),
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
        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }

  Widget _buildSectionLabel(String label, ThemeColors colors) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.xs, bottom: AppSpacing.sm),
    child: AppText(
      label,
      variant: AppTextVariant.labelMedium,
      color: colors.textSecondary,
      fontWeight: FontWeight.w700,
    ),
  );

  Widget _buildContactItem(
    SyncedContact contact,
    ThemeColors colors, {
    bool fromLookup = false,
  }) {
    final verifiedAccount = _localizedText(
      en: 'Verified Korido account',
      fr: 'Compte Korido vérifié',
    );
    final canSelect = !fromLookup || contact.canSendInKorido;

    return GestureDetector(
      key: ValueKey(
        fromLookup
            ? 'contact_lookup_${contact.joonaPayUserId ?? contact.id}'
            : 'contact_picker_${contact.id}',
      ),
      behavior: HitTestBehavior.opaque,
      onTap: canSelect
          ? () => Navigator.pop(context, contact)
          : _showLookupNeedsPhoneMessage,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
            const SizedBox(width: AppSpacing.md),
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
                        const SizedBox(width: AppSpacing.xs),
                        const KoridoAccountBadge(compact: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  AppText(
                    fromLookup && contact.phone.isEmpty
                        ? _localizedText(
                            en:
                                contact.displayIdentifier ??
                                'Korido account found',
                            fr:
                                contact.displayIdentifier ??
                                'Compte Korido trouvé',
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
            en: 'This account is discoverable, but a username or phone is required to send.',
            fr: 'Ce compte est visible, mais un identifiant ou un numéro est requis pour envoyer.',
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
