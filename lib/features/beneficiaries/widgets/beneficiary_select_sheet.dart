import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/beneficiaries_provider.dart';
import '../models/beneficiary.dart';

/// Beneficiary Select Sheet
///
/// Bottom sheet for selecting a beneficiary from saved list
/// Used in transfer flows
class BeneficiarySelectSheet extends ConsumerStatefulWidget {
  const BeneficiarySelectSheet({
    super.key,
    this.accountTypeFilter,
  });

  /// Optional filter by account type
  final AccountType? accountTypeFilter;

  @override
  ConsumerState<BeneficiarySelectSheet> createState() =>
      _BeneficiarySelectSheetState();
}

class _BeneficiarySelectSheetState
    extends ConsumerState<BeneficiarySelectSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load beneficiaries
    Future.microtask(() {
      ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.slate,
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
              color: AppColors.textSecondary,
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
                  l10n.send_selectBeneficiary,
                  variant: AppTextVariant.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.gold500,
            labelColor: AppColors.gold500,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: l10n.beneficiaries_tabAll),
              Tab(text: l10n.beneficiaries_tabFavorites),
              Tab(text: l10n.beneficiaries_tabRecent),
            ],
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: AppInput(
              controller: _searchController,
              hint: l10n.send_searchBeneficiaries,
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              suffixIcon: _searchQuery.isNotEmpty ? Icons.clear : null,
            ),
          ),

          // Beneficiaries list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBeneficiariesList(
                  state,
                  l10n,
                  BeneficiariesFilter.all,
                ),
                _buildBeneficiariesList(
                  state,
                  l10n,
                  BeneficiariesFilter.favorites,
                ),
                _buildBeneficiariesList(
                  state,
                  l10n,
                  BeneficiariesFilter.recent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiariesList(
    BeneficiariesState state,
    AppLocalizations l10n,
    BeneficiariesFilter filter,
  ) {
    if (state.isLoading && state.beneficiaries.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold500),
        ),
      );
    }

    var beneficiaries = state.beneficiaries;

    // Apply filter
    switch (filter) {
      case BeneficiariesFilter.favorites:
        beneficiaries = beneficiaries.where((b) => b.isFavorite).toList();
        break;
      case BeneficiariesFilter.recent:
        beneficiaries = beneficiaries.where((b) => b.lastTransferAt != null).toList();
        beneficiaries.sort((a, b) => b.lastTransferAt!.compareTo(a.lastTransferAt!));
        break;
      case BeneficiariesFilter.all:
        break;
    }

    // Apply account type filter if provided
    if (widget.accountTypeFilter != null) {
      beneficiaries = beneficiaries
          .where((b) => b.accountType == widget.accountTypeFilter)
          .toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      beneficiaries = beneficiaries.where((b) {
        return b.name.toLowerCase().contains(query) ||
            (b.phoneE164?.contains(query) ?? false);
      }).toList();
    }

    if (beneficiaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_outline,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.send_noBeneficiariesFound,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: beneficiaries.length,
      itemBuilder: (context, index) {
        final beneficiary = beneficiaries[index];
        return _buildBeneficiaryItem(beneficiary);
      },
    );
  }

  Widget _buildBeneficiaryItem(Beneficiary beneficiary) {
    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: () => Navigator.pop(context, beneficiary),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Avatar with account type icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getAccountTypeColor(beneficiary.accountType).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getAccountTypeIcon(beneficiary.accountType),
                color: _getAccountTypeColor(beneficiary.accountType),
                size: 24,
              ),
            ),
            SizedBox(width: AppSpacing.md),

            // Name and details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          beneficiary.name,
                          variant: AppTextVariant.bodyLarge,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (beneficiary.isFavorite) ...[
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: AppColors.gold500,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (beneficiary.phoneE164 != null)
                        Expanded(
                          child: AppText(
                            beneficiary.phoneE164!,
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      AppText(
                        _getAccountTypeLabel(beneficiary.accountType, l10n),
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountTypeIcon(AccountType type) {
    return switch (type) {
      AccountType.joonapayUser => Icons.person,
      AccountType.externalWallet => Icons.account_balance_wallet,
      AccountType.bankAccount => Icons.account_balance,
      AccountType.mobileMoney => Icons.phone_android,
    };
  }

  Color _getAccountTypeColor(AccountType type) {
    return switch (type) {
      AccountType.joonapayUser => AppColors.gold500,
      AccountType.externalWallet => AppColors.infoBase,
      AccountType.bankAccount => AppColors.successBase,
      AccountType.mobileMoney => AppColors.warningBase,
    };
  }

  String _getAccountTypeLabel(AccountType type, AppLocalizations l10n) {
    return switch (type) {
      AccountType.joonapayUser => l10n.beneficiaries_typeJoonapay,
      AccountType.externalWallet => l10n.beneficiaries_typeWallet,
      AccountType.bankAccount => l10n.beneficiaries_typeBank,
      AccountType.mobileMoney => l10n.beneficiaries_typeMobileMoney,
    };
  }
}

/// Helper function to show beneficiary select sheet
Future<Beneficiary?> showBeneficiarySelectSheet(
  BuildContext context, {
  AccountType? accountTypeFilter,
}) {
  return showModalBottomSheet<Beneficiary>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) => BeneficiarySelectSheet(
      accountTypeFilter: accountTypeFilter,
    ),
  );
}
