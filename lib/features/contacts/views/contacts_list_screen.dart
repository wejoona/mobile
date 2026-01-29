import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/contacts_provider.dart';
import '../models/synced_contact.dart';
import '../widgets/contact_card.dart';
import '../widgets/invite_sheet.dart';

/// Contacts List Screen
///
/// Shows JoonaPay users and contacts to invite
class ContactsListScreen extends ConsumerStatefulWidget {
  const ContactsListScreen({super.key});

  @override
  ConsumerState<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState extends ConsumerState<ContactsListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

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
    final notifier = ref.read(contactsProvider.notifier);
    await notifier.loadAndSyncContacts();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(contactsProvider);

    List<SyncedContact> filteredContacts = state.contacts;
    if (_searchQuery.isNotEmpty) {
      filteredContacts = state.searchContacts(_searchQuery);
    }

    final joonaPayUsers =
        filteredContacts.where((c) => c.isJoonaPayUser).toList();
    final nonUsers = filteredContacts.where((c) => !c.isJoonaPayUser).toList();

    return Scaffold(
      backgroundColor: AppColors.obsidian,
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
                  color: AppColors.textTertiary,
                ),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(contactsProvider.notifier).syncContacts();
        },
        backgroundColor: AppColors.slate,
        color: AppColors.gold500,
        child: state.isLoading
            ? Center(
                child: CircularProgressIndicator(color: AppColors.gold500),
              )
            : Column(
                children: [
                  // Search bar
                  Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: AppInput(
                      controller: _searchController,
                      label: l10n.contacts_search,
                      prefixIcon: Icons.search,
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),

                  // Sync status banner
                  if (state.lastSyncResult != null && state.lastSyncResult!.joonaPayUsersFound > 0)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.gold500.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.gold500.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppColors.gold500,
                            size: 20,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: AppText(
                              l10n.contacts_sync_success(
                                state.lastSyncResult!.joonaPayUsersFound,
                              ),
                              variant: AppTextVariant.bodySmall,
                              color: AppColors.gold500,
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
                        // JoonaPay users section
                        if (joonaPayUsers.isNotEmpty) ...[
                          _buildSectionHeader(
                            l10n.contacts_on_joonapay,
                            joonaPayUsers.length,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ...joonaPayUsers.map((contact) => ContactCard(
                                contact: contact,
                                onTap: () => _handleContactTap(contact),
                                onSend: () => _handleSend(contact),
                              )),
                          SizedBox(height: AppSpacing.xl),
                        ],

                        // Invite section
                        if (nonUsers.isNotEmpty) ...[
                          _buildSectionHeader(
                            l10n.contacts_invite_to_joonapay,
                            nonUsers.length,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          ...nonUsers.map((contact) => ContactCard(
                                contact: contact,
                                onTap: () => _handleContactTap(contact),
                                onInvite: () => _handleInvite(contact),
                              )),
                        ],

                        // Empty state
                        if (filteredContacts.isEmpty && !state.isLoading)
                          Center(
                            child: Padding(
                              padding: EdgeInsets.all(AppSpacing.xxl),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.contacts_outlined,
                                    size: 64,
                                    color: AppColors.textTertiary,
                                  ),
                                  SizedBox(height: AppSpacing.md),
                                  AppText(
                                    _searchQuery.isNotEmpty
                                        ? l10n.contacts_no_results
                                        : l10n.contacts_empty,
                                    variant: AppTextVariant.bodyLarge,
                                    color: AppColors.textSecondary,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
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
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(width: AppSpacing.xs),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.gold500.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: AppText(
            '$count',
            variant: AppTextVariant.bodySmall,
            color: AppColors.gold500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _handleContactTap(SyncedContact contact) {
    if (contact.isJoonaPayUser) {
      // Navigate to send screen with pre-filled recipient
      context.push('/send', extra: {'recipientId': contact.joonaPayUserId});
    } else {
      _handleInvite(contact);
    }
  }

  void _handleSend(SyncedContact contact) {
    context.push('/send', extra: {'recipientId': contact.joonaPayUserId});
  }

  void _handleInvite(SyncedContact contact) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => InviteSheet(contact: contact),
    );
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
