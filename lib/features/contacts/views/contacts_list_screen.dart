import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/contacts/models/synced_contact.dart';
import 'package:usdc_wallet/features/contacts/providers/contacts_provider.dart';
import 'package:usdc_wallet/features/contacts/widgets/contact_card.dart';
import 'package:usdc_wallet/features/contacts/widgets/invite_sheet.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/contacts/contacts_service.dart';

/// Contacts List Screen
///
/// Shows Korido users and contacts to invite
class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  List<SyncedContact> _lookupResults = [];
  bool _isLookupLoading = false;
  bool _lookupFailed = false;
  bool _isPermissionActionLoading = false;
  Timer? _lookupDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(_loadContactsOrRouteToPermission());
    });
  }

  @override
  void dispose() {
    _lookupDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    _lookupDebounce?.cancel();
    setState(() => _searchQuery = value);

    final trimmed = value.trim();
    if (trimmed.length < 3) {
      setState(() {
        _lookupResults = [];
        _isLookupLoading = false;
        _lookupFailed = false;
      });
      return;
    }

    setState(() {
      _isLookupLoading = true;
      _lookupFailed = false;
    });
    _lookupDebounce = Timer(
      const Duration(milliseconds: 280),
      () => _lookupKoridoUsers(trimmed),
    );
  }

  Future<void> _lookupKoridoUsers(String query) async {
    try {
      final results = await ref
          .read(koridoContactsServiceProvider)
          .lookupKoridoUsers(query);
      if (!mounted || _searchController.text.trim() != query) {
        return;
      }

      final state = ref.read(contactsProvider);
      final localPhones = state.contacts
          .map((contact) => contact.phone)
          .toSet();
      final localUserIds = state.contacts
          .map((contact) => contact.joonaPayUserId ?? contact.id)
          .where((id) => id.isNotEmpty)
          .toSet();

      setState(() {
        _lookupResults = results.where((result) {
          final userId = result.joonaPayUserId ?? result.id;
          final duplicatePhone =
              result.phone.isNotEmpty && localPhones.contains(result.phone);
          final duplicateUser =
              userId.isNotEmpty && localUserIds.contains(userId);
          return !duplicatePhone && !duplicateUser;
        }).toList();
        _isLookupLoading = false;
        _lookupFailed = false;
      });
    } on Object {
      if (!mounted || _searchController.text.trim() != query) {
        return;
      }
      setState(() {
        _lookupResults = [];
        _isLookupLoading = false;
        _lookupFailed = true;
      });
    }
  }

  Future<void> _manualSync() async {
    if (_isPermissionActionLoading) {
      return;
    }
    setState(() => _isPermissionActionLoading = true);
    try {
      await _requestPermissionAndSync(showSettingsDialog: true);
    } finally {
      if (mounted) {
        setState(() => _isPermissionActionLoading = false);
      }
    }
  }

  Future<void> _loadContactsOrRouteToPermission() async {
    final routed = await _routeToPermissionPromptIfNeeded();
    if (!routed && mounted) {
      await ref.read(contactsProvider.notifier).syncContacts();
    }
  }

  Future<bool> _routeToPermissionPromptIfNeeded() async {
    final contactsService = ref.read(contactsServiceProvider);
    final hasPermission = await contactsService.hasContactsPermission();
    if (hasPermission || !mounted) {
      return false;
    }

    final requiresSettings = await contactsService
        .contactsPermissionRequiresSettings();
    if (!requiresSettings && mounted) {
      context.go('/contacts/permission');
      return true;
    }
    return false;
  }

  Future<void> _requestPermissionAndSync({
    required bool showSettingsDialog,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final notifier = ref.read(contactsProvider.notifier);
    final granted = await notifier.requestPermission();
    if (granted) {
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

    if (!showSettingsDialog || !mounted) {
      return;
    }

    final state = ref.read(contactsProvider);
    if (state.permissionRequiresSettings) {
      await _showContactsSettingsDialog(l10n);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.contacts_permission_denied_message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(contactsProvider);

    List<SyncedContact> filteredContacts = state.contacts;
    if (_searchQuery.isNotEmpty) {
      filteredContacts = state.searchContacts(_searchQuery);
    }

    final joonaPayUsers = filteredContacts
        .where((c) => c.isKoridoUser)
        .toList();
    final nonUsers = filteredContacts.where((c) => !c.isKoridoUser).toList();

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: AppText(
          l10n.contacts_title,
          variant: AppTextVariant.headlineMedium,
        ),
        actions: [
          if (state.lastSyncTime != null)
            Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: Center(
                child: AppText(
                  _formatSyncTime(context, state.lastSyncTime!),
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textTertiary,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _manualSync,
        backgroundColor: context.colors.container,
        color: context.colors.gold,
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(color: context.colors.gold),
              )
            : Column(
                children: [
                  if (state.permissionRequired)
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _ContactsPermissionCard(
                        requiresSettings: state.permissionRequiresSettings,
                        isLoading: _isPermissionActionLoading,
                        onAction: _manualSync,
                      ),
                    ),

                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: AppInput(
                      controller: _searchController,
                      label: l10n.contacts_search,
                      prefixIcon: Icons.search,
                      onChanged: _handleSearchChanged,
                    ),
                  ),

                  // Sync status banner
                  if (state.lastSyncResult != null &&
                      state.lastSyncResult!.joonaPayUsersFound > 0)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: context.colors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: context.colors.gold.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: context.colors.gold,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              l10n.contacts_sync_success(
                                state.lastSyncResult!.joonaPayUsersFound,
                              ),
                              variant: AppTextVariant.bodySmall,
                              color: context.colors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppSpacing.md),

                  // Contact list
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      children: [
                        // Korido users section
                        if (_searchQuery.trim().length >= 3) ...[
                          _buildLookupSection(_lookupResults),
                          if (_lookupResults.isNotEmpty)
                            SizedBox(height: AppSpacing.xl),
                        ],

                        if (joonaPayUsers.isNotEmpty) ...[
                          _buildSectionHeader(
                            l10n.contacts_on_joonapay,
                            joonaPayUsers.length,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ...joonaPayUsers.map(
                            (contact) => ContactCard(
                              contact: contact,
                              onTap: () => _handleContactTap(contact),
                              onSend: () => _handleSend(contact),
                            ),
                          ),
                          SizedBox(height: AppSpacing.xl),
                        ],

                        // Invite section
                        if (nonUsers.isNotEmpty) ...[
                          _buildSectionHeader(
                            l10n.contacts_invite_to_joonapay,
                            nonUsers.length,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ...nonUsers.map(
                            (contact) => ContactCard(
                              contact: contact,
                              onTap: () => _handleContactTap(contact),
                              onInvite: () => _handleInvite(contact),
                            ),
                          ),
                        ],

                        // Empty state
                        if (filteredContacts.isEmpty &&
                            !state.isLoading &&
                            !_isLookupLoading)
                          _ContactsEmptyState(
                            title: _lookupFailed
                                ? _localizedText(
                                    en: 'Korido search is unavailable',
                                    fr: 'La recherche Korido est indisponible',
                                  )
                                : _searchQuery.isNotEmpty
                                ? l10n.contacts_no_results
                                : state.permissionRequired
                                ? l10n.contacts_permission_title
                                : l10n.contacts_empty,
                            description: _lookupFailed
                                ? _localizedText(
                                    en: 'Your contacts are still here. Try again in a moment.',
                                    fr: 'Vos contacts sont toujours là. Réessayez dans un instant.',
                                  )
                                : null,
                            showAction:
                                _searchQuery.isEmpty ||
                                (state.permissionRequired &&
                                    _searchQuery.trim().length < 3),
                            requiresSettings: state.permissionRequiresSettings,
                            isLoading: _isPermissionActionLoading,
                            onAction: _manualSync,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Row(
      children: [
        AppText(
          title,
          variant: AppTextVariant.bodyLarge,
          color: context.colors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(width: AppSpacing.xs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: context.colors.gold.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: AppText(
            '$count',
            variant: AppTextVariant.bodySmall,
            color: context.colors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLookupSection(List<SyncedContact> contacts) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

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
                color: colors.gold,
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

    if (contacts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(l10n.contacts_on_joonapay, contacts.length),
        SizedBox(height: AppSpacing.sm),
        ...contacts.map(
          (contact) => ContactCard(
            contact: contact,
            onTap: () => _handleLookupContactTap(contact),
            onSend: contact.canSendInKorido ? () => _handleSend(contact) : null,
          ),
        ),
      ],
    );
  }

  void _handleContactTap(SyncedContact contact) {
    if (contact.isKoridoUser) {
      // Navigate to send screen with pre-filled recipient
      unawaited(context.push('/send', extra: _sendExtra(contact)));
    } else {
      _handleInvite(contact);
    }
  }

  void _handleLookupContactTap(SyncedContact contact) {
    if (!contact.canSendInKorido) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _localizedText(
              en: 'This Korido account is discoverable, but cannot be selected until a username or phone is available.',
              fr: 'Ce compte Korido est visible, mais ne peut pas être sélectionné sans identifiant ou numéro disponible.',
            ),
          ),
        ),
      );
      return;
    }
    _handleSend(contact);
  }

  void _handleSend(SyncedContact contact) {
    unawaited(context.push('/send', extra: _sendExtra(contact)));
  }

  Map<String, String?> _sendExtra(SyncedContact contact) => {
    'recipientId': contact.joonaPayUserId,
    'recipientPhone': contact.phone,
    'recipientUsername': contact.username,
    'recipientName': contact.name,
  };

  void _handleInvite(SyncedContact contact) {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => InviteSheet(contact: contact),
      ),
    );
  }

  String _localizedText({required String en, required String fr}) {
    final locale = Localizations.localeOf(context).languageCode.toLowerCase();
    return locale == 'fr' ? fr : en;
  }

  Future<void> _showContactsSettingsDialog(AppLocalizations l10n) async {
    final shouldOpen = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.send_contactsPermissionSettingsTitle),
        content: Text(l10n.send_contactsPermissionSettingsMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.action_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.action_open_settings),
          ),
        ],
      ),
    );
    if (shouldOpen ?? false) {
      await ref.read(contactsServiceProvider).openContactsSettings();
    }
  }

  String _formatSyncTime(BuildContext context, DateTime time) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return l10n.contacts_synced_just_now;
    } else if (diff.inMinutes < 60) {
      return l10n.contacts_synced_minutes_ago(diff.inMinutes);
    } else if (diff.inHours < 24) {
      return l10n.contacts_synced_hours_ago(diff.inHours);
    } else {
      return l10n.contacts_synced_days_ago(diff.inDays);
    }
  }
}

class _ContactsPermissionCard extends StatelessWidget {
  const _ContactsPermissionCard({
    required this.requiresSettings,
    required this.isLoading,
    required this.onAction,
  });

  final bool requiresSettings;
  final bool isLoading;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return AppCard(
      variant: AppCardVariant.goldAccent,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors.goldSubtle,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.borderGold),
            ),
            child: Icon(Icons.contacts_outlined, color: colors.gold, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.contacts_permission_title,
                  variant: AppTextVariant.titleSmall,
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                const SizedBox(height: AppSpacing.xs),
                AppText(
                  l10n.contacts_permission_benefit2_desc,
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: requiresSettings
                      ? l10n.action_open_settings
                      : l10n.contacts_permission_allow,
                  icon: requiresSettings
                      ? Icons.settings_outlined
                      : Icons.person_search_rounded,
                  isFullWidth: true,
                  isLoading: isLoading,
                  onPressed: isLoading ? null : () => unawaited(onAction()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactsEmptyState extends StatelessWidget {
  const _ContactsEmptyState({
    required this.title,
    this.description,
    required this.showAction,
    required this.requiresSettings,
    required this.isLoading,
    required this.onAction,
  });

  final String title;
  final String? description;
  final bool showAction;
  final bool requiresSettings;
  final bool isLoading;
  final Future<void> Function() onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: AppCard(
        variant: AppCardVariant.goldAccent,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: colors.goldSubtle,
                shape: BoxShape.circle,
                border: Border.all(color: colors.borderGold),
              ),
              child: Icon(
                Icons.contacts_outlined,
                size: 34,
                color: colors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              description ?? l10n.contacts_permission_benefit2_desc,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (showAction) ...[
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: requiresSettings
                    ? l10n.action_open_settings
                    : l10n.contacts_permission_allow,
                icon: requiresSettings
                    ? Icons.settings_outlined
                    : Icons.person_search_rounded,
                isFullWidth: true,
                isLoading: isLoading,
                onPressed: isLoading ? null : () => unawaited(onAction()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
