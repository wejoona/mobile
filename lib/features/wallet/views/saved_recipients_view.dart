import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';
import 'package:usdc_wallet/features/wallet/providers/saved_recipients_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;
    final contactsAsync = ref.watch(savedRecipientsProvider);
    final favoritesAsync = ref.watch(favoriteRecipientsProvider);
    final recentsAsync = ref.watch(recentRecipientsProvider);
    final searchResultsAsync = _searchQuery.isNotEmpty
        ? ref.watch(searchSavedRecipientsProvider(_searchQuery))
        : null;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.services_recipients,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_add, color: context.colors.gold),
            onPressed: () => _showAddRecipient(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: context.colors.gold,
          labelColor: context.colors.gold,
          unselectedLabelColor: colors.textTertiary,
          tabs: [
            Tab(
              text: contactsAsync.maybeWhen(
                data: (contacts) =>
                    '${l10n.beneficiaries_tabAll} (${_filterContacts(contacts).length})',
                orElse: () => l10n.beneficiaries_tabAll,
              ),
            ),
            Tab(
              text: favoritesAsync.maybeWhen(
                data: (favorites) =>
                    '${l10n.beneficiaries_tabFavorites} (${_filterContacts(favorites).length})',
                orElse: () => l10n.beneficiaries_tabFavorites,
              ),
            ),
            Tab(text: l10n.beneficiaries_tabRecent),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              hint: l10n.send_searchRecipients,
              prefixIcon: Icons.search,
              variant: AppInputVariant.search,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

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
          (c.username?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (c.walletAddress?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
              false);
    }).toList();
  }

  Widget _buildSearchResults(AsyncValue<List<Contact>> searchResultsAsync) {
    final colors = context.colors;
    return searchResultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: colors.textTertiary),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  AppStrings.noResultsFound,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
      loading: () =>
          Center(child: CircularProgressIndicator(color: context.colors.gold)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Error: ${error.toString()}',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: AppLocalizations.of(context)!.action_retry,
              onPressed: () {
                ref.invalidate(searchSavedRecipientsProvider(_searchQuery));
              },
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList(AsyncValue<List<Contact>> contactsAsync) {
    final colors = context.colors;
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
                  color: colors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppText(
                  AppStrings.noRecipientsFound,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: AppStrings.addRecipient,
                  onPressed: _showAddRecipient,
                  variant: AppButtonVariant.secondary,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(savedRecipientsProvider);
            ref.invalidate(favoriteRecipientsProvider);
            ref.invalidate(recentRecipientsProvider);
          },
          color: context.colors.gold,
          backgroundColor: context.colors.elevated,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
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
      loading: () =>
          Center(child: CircularProgressIndicator(color: context.colors.gold)),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: context.colors.error),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              AppStrings.failedToLoadContacts,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: AppLocalizations.of(context)!.action_retry,
              onPressed: () {
                ref.invalidate(savedRecipientsProvider);
                ref.invalidate(favoriteRecipientsProvider);
                ref.invalidate(recentRecipientsProvider);
              },
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  void _sendToRecipient(Contact contact) {
    unawaited(context.push('/send', extra: contact));
  }

  Future<void> _toggleFavorite(String id) async {
    final success = await ref
        .read(savedRecipientMutationProvider.notifier)
        .toggleFavorite(id);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.favoriteUpdated),
            backgroundColor: context.colors.success,
          ),
        );
      } else {
        final error = ref.read(savedRecipientMutationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ??
                  AppLocalizations.of(
                    context,
                  )!.beneficiaries_failedToUpdateFavorite,
            ),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  void _deleteRecipient(Contact contact) {
    final colors = context.colors;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.colors.elevated,
          title: Text(
            AppLocalizations.of(context)!.beneficiaries_deleteConfirm,
            style: TextStyle(color: colors.textPrimary),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            )!.beneficiaries_deleteMessage(contact.name),
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                AppLocalizations.of(context)!.action_cancel,
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final success = await ref
                    .read(savedRecipientMutationProvider.notifier)
                    .deleteContact(contact.id);

                if (mounted) {
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.beneficiaries_recipientRemoved,
                        ),
                        backgroundColor: context.colors.success,
                      ),
                    );
                  } else {
                    final error = ref
                        .read(savedRecipientMutationProvider)
                        .error;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          error ??
                              AppLocalizations.of(
                                context,
                              )!.beneficiaries_failedToDelete,
                        ),
                        backgroundColor: context.colors.error,
                      ),
                    );
                  }
                }
              },
              child: Text(
                AppLocalizations.of(context)!.common_delete,
                style: TextStyle(color: context.colors.error),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddRecipient() {
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: context.colors.elevated,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _AddRecipientSheet(
            onAdded: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context)!.beneficiaries_recipientAdded,
                  ),
                  backgroundColor: context.colors.success,
                ),
              );
            },
          ),
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
    final colors = context.colors;
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        // Show confirmation dialog
        return await showDialog<bool>(
              context: context,
              builder: (context) {
                final dialogColors = context.colors;
                return AlertDialog(
                  backgroundColor: dialogColors.container,
                  title: Text(
                    AppLocalizations.of(context)!.beneficiaries_deleteConfirm,
                    style: TextStyle(color: dialogColors.textPrimary),
                  ),
                  content: Text(
                    AppLocalizations.of(
                      context,
                    )!.beneficiaries_deleteMessage(contact.name),
                    style: TextStyle(color: dialogColors.textSecondary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        AppLocalizations.of(context)!.action_cancel,
                        style: TextStyle(color: dialogColors.textSecondary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        AppLocalizations.of(context)!.common_delete,
                        style: TextStyle(color: context.colors.error),
                      ),
                    ),
                  ],
                );
              },
            ) ??
            false;
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colors.error,
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
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: Row(
            children: [
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: contact.isKoridoUser
                          ? context.colors.gold.withValues(alpha: 0.2)
                          : context.colors.elevated,
                      shape: BoxShape.circle,
                      border: contact.isKoridoUser
                          ? Border.all(color: context.colors.gold)
                          : null,
                    ),
                    child:
                        contact.walletAddress != null && contact.phone == null
                        ? Icon(
                            Icons.account_balance_wallet,
                            color: colors.textSecondary,
                          )
                        : Center(
                            child: AppText(
                              _getInitials(contact.name),
                              variant: AppTextVariant.titleMedium,
                              color: contact.isKoridoUser
                                  ? context.colors.gold
                                  : colors.textSecondary,
                            ),
                          ),
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
                            color: colors.textPrimary,
                          ),
                        ),
                        if (contact.isKoridoUser) ...[
                          const SizedBox(width: AppSpacing.xs),
                          const KoridoAccountBadge(compact: true),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      contact.displayIdentifier,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                    if (contact.transactionCount > 0) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        '${contact.transactionCount} ${AppStrings.transactions.toLowerCase()}',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
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
                          ? context.colors.gold
                          : colors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: context.colors.gold,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: AppText(
                      AppStrings.send,
                      variant: AppTextVariant.labelSmall,
                      color: colors.canvas,
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              AppStrings.addRecipient,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.xxl),

            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    label: AppStrings.phoneNumber,
                    isSelected: _recipientType == 'phone',
                    onTap: () => setState(() => _recipientType = 'phone'),
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TypeButton(
                    label: l10n.beneficiaries_typeJoonapay,
                    isSelected: _recipientType == 'username',
                    onTap: () => setState(() => _recipientType = 'username'),
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TypeButton(
                    label: l10n.beneficiaries_typeWallet,
                    isSelected: _recipientType == 'wallet',
                    onTap: () => setState(() => _recipientType = 'wallet'),
                    colors: colors,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            AppInput(
              controller: _nameController,
              label: l10n.beneficiaries_fieldName,
              hint: l10n.beneficiaries_fieldName,
              prefixIcon: Icons.person_outline,
            ),

            const SizedBox(height: AppSpacing.lg),

            if (_recipientType == 'phone') ...[
              AppInput(
                controller: _phoneController,
                label: AppStrings.phoneNumber,
                hint: '+225 07 48 80 56 63',
                prefixIcon: Icons.phone_outlined,
                variant: AppInputVariant.phone,
                keyboardType: TextInputType.phone,
              ),
            ] else if (_recipientType == 'username') ...[
              AppInput(
                controller: _usernameController,
                label: l10n.beneficiaries_typeJoonapay,
                hint: '@korido',
                prefixIcon: Icons.alternate_email,
              ),
            ] else ...[
              AppInput(
                controller: _walletController,
                label: l10n.beneficiaries_fieldWalletAddress,
                hint: l10n.sendExternal_walletAddress,
                prefixIcon: Icons.account_balance_wallet_outlined,
                keyboardType: TextInputType.text,
              ),
            ],

            const SizedBox(height: AppSpacing.xxl),

            // Add Button
            AppButton(
              label: AppStrings.addRecipient,
              onPressed: _canAdd() ? _add : null,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
              isLoading: _isSubmitting,
            ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
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

    final success = await ref
        .read(savedRecipientMutationProvider.notifier)
        .createContact(
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
        final error = ref.read(savedRecipientMutationProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error ?? AppLocalizations.of(context)!.beneficiaries_failedToAdd,
            ),
            backgroundColor: context.colors.error,
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
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.gold : colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Center(
          child: AppText(
            label,
            variant: AppTextVariant.labelMedium,
            color: isSelected ? colors.canvas : colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
