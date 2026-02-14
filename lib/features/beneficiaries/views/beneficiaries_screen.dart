import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';
import 'package:usdc_wallet/features/beneficiaries/widgets/beneficiary_card.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

/// Beneficiaries Screen
///
/// Main screen showing saved beneficiaries with tabs for All, Favorites, Recent
class BeneficiariesScreen extends ConsumerStatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  ConsumerState<BeneficiariesScreen> createState() =>
      _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends ConsumerState<BeneficiariesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Load beneficiaries on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final filter = _getFilterForTab(_tabController.index);
      ref.read(beneficiariesProvider.notifier).setFilter(filter);
    }
  }

  BeneficiariesFilter _getFilterForTab(int index) {
    switch (index) {
      case 0:
        return BeneficiariesFilter.all;
      case 1:
        return BeneficiariesFilter.favorites;
      case 2:
        return BeneficiariesFilter.recent;
      default:
        return BeneficiariesFilter.all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesProvider);
    final colors = context.colors;
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.beneficiaries_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: appColors.gold500,
          labelColor: appColors.gold500,
          unselectedLabelColor: colors.textSecondary,
          tabs: [
            Tab(text: l10n.beneficiaries_tabAll),
            Tab(text: l10n.beneficiaries_tabFavorites),
            Tab(text: l10n.beneficiaries_tabRecent),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: AppInput(
                controller: _searchController,
                hint: l10n.beneficiaries_searchHint,
                prefixIcon: Icons.search,
                onChanged: (value) {
                  ref.read(beneficiariesProvider.notifier).setSearchQuery(value);
                },
                suffixIcon: _searchController.text.isNotEmpty
                    ? Icons.clear
                    : null,
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(beneficiariesProvider.notifier).refresh(),
                color: appColors.gold500,
                backgroundColor: colors.container,
                child: _buildContent(context, state, l10n),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddBeneficiary(context),
        backgroundColor: appColors.gold500,
        child: Icon(Icons.add, color: colors.textInverse),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BeneficiariesState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.beneficiaries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.beneficiaries.isEmpty) {
      return _buildError(l10n, state.error!);
    }

    final filteredBeneficiaries = state.filteredBeneficiaries;

    if (filteredBeneficiaries.isEmpty) {
      return _buildEmptyState(context, l10n, state.currentFilter);
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: filteredBeneficiaries.length,
      itemBuilder: (context, index) {
        final beneficiary = filteredBeneficiaries[index];
        return BeneficiaryCard(
          beneficiary: beneficiary,
          onTap: () => _selectBeneficiary(context, beneficiary),
          onLongPress: () => _showBeneficiaryMenu(context, beneficiary, l10n),
          onFavoriteToggle: () => ref
              .read(beneficiariesProvider.notifier)
              .toggleFavorite(beneficiary.id),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppLocalizations l10n,
    BeneficiariesFilter filter,
  ) {
    final colors = context.colors;

    String title;
    String message;
    IconData icon;

    switch (filter) {
      case BeneficiariesFilter.all:
        title = l10n.beneficiaries_emptyTitle;
        message = l10n.beneficiaries_emptyMessage;
        icon = Icons.person_add;
        break;
      case BeneficiariesFilter.favorites:
        title = l10n.beneficiaries_emptyFavoritesTitle;
        message = l10n.beneficiaries_emptyFavoritesMessage;
        icon = Icons.star_border;
        break;
      case BeneficiariesFilter.recent:
        title = l10n.beneficiaries_emptyRecentTitle;
        message = l10n.beneficiaries_emptyRecentMessage;
        icon = Icons.history;
        break;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colors.textSecondary.withValues(alpha: 0.5)),
            SizedBox(height: AppSpacing.md),
            AppText(
              title,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              message,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (filter == BeneficiariesFilter.all) ...[
              SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.beneficiaries_addFirst,
                onPressed: () => _navigateToAddBeneficiary(context),
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n, String error) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colors.error),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.beneficiaries_errorTitle,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              error,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.common_retry,
              onPressed: () =>
                  ref.read(beneficiariesProvider.notifier).loadBeneficiaries(),
              size: AppButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }

  void _selectBeneficiary(BuildContext context, Beneficiary beneficiary) {
    // Navigate to detail view
    context.push('/beneficiaries/detail/${beneficiary.id}');
  }

  void _navigateToAddBeneficiary(BuildContext context) {
    context.push('/beneficiaries/add').then((_) {
      // Refresh list after adding
      ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
    });
  }

  void _showBeneficiaryMenu(
    BuildContext context,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) {
    final colors = context.colors;
    final appColors = context.appColors;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Title
            AppText(
              beneficiary.name,
              variant: AppTextVariant.headlineSmall,
            ),
            SizedBox(height: AppSpacing.lg),

            // Edit
            ListTile(
              leading: Icon(Icons.edit, color: appColors.gold500),
              title: AppText(l10n.beneficiaries_menuEdit),
              onTap: () {
                context.pop();
                context
                    .push('/beneficiaries/edit/${beneficiary.id}')
                    .then((_) {
                  ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
                });
              },
            ),

            // Delete
            ListTile(
              leading: Icon(Icons.delete, color: colors.error),
              title: AppText(
                l10n.beneficiaries_menuDelete,
                variant: AppTextVariant.bodyLarge,
                color: colors.error,
              ),
              onTap: () {
                context.pop();
                _showDeleteConfirmation(context, beneficiary, l10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    Beneficiary beneficiary,
    AppLocalizations l10n,
  ) async {
    final colors = context.colors;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.container,
        title: AppText(
          l10n.beneficiaries_deleteTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        content: AppText(
          l10n.beneficiaries_deleteMessage(beneficiary.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: AppText(l10n.common_cancel),
          ),
          AppButton(
            label: l10n.common_delete,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final colors = context.colors;
      final success = await ref
          .read(beneficiariesProvider.notifier)
          .deleteBeneficiary(beneficiary.id);

      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: AppText(l10n.beneficiaries_deleteSuccess),
            backgroundColor: colors.success,
          ),
        );
      }
    }
  }
}
