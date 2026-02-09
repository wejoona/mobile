import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../design/theme/theme_extensions.dart';
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
    final colors = context.colors;
    final appColors = context.appColors;
    final state = ref.watch(beneficiariesProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  l10n.send_selectBeneficiary,
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

          // Tabs
          TabBar(
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
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(context.appColors.gold500),
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
      return Builder(
        builder: (context) {
          final colors = context.colors;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_outline,
                  size: 64,
                  color: colors.textSecondary.withOpacity(0.5),
                ),
                SizedBox(height: AppSpacing.md),
                AppText(
                  l10n.send_noBeneficiariesFound,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
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
    final colors = context.colors;
    final appColors = context.appColors;

    return InkWell(
      onTap: () => Navigator.pop(context, beneficiary),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Avatar with account type icon or initial
            _buildAvatar(beneficiary),
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
                          color: appColors.gold500,
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
                            color: colors.textSecondary,
                          ),
                        ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getAccountTypeColor(beneficiary.accountType).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: AppText(
                          _getAccountTypeLabel(beneficiary.accountType, l10n),
                          variant: AppTextVariant.bodySmall,
                          color: _getAccountTypeColor(beneficiary.accountType),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            Icon(
              Icons.chevron_right,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(Beneficiary beneficiary) {
    final iconColor = _getAccountTypeColor(beneficiary.accountType);
    final iconData = _getAccountTypeIcon(beneficiary.accountType);
    final initial = beneficiary.accountType == AccountType.joonapayUser &&
                    beneficiary.name.isNotEmpty
        ? beneficiary.name[0].toUpperCase()
        : null;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: initial != null
          ? Center(
              child: Text(
                initial,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Icon(
              iconData,
              color: iconColor,
              size: 24,
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
    // Fixed brand colors for account types
    return switch (type) {
      AccountType.joonapayUser => AppColors.gold500,        // Gold/primary accent
      AccountType.externalWallet => const Color(0xFF6B8DD6), // Purple accent
      AccountType.bankAccount => const Color(0xFF5B9BD5),    // Blue accent
      AccountType.mobileMoney => const Color(0xFFFF9955),    // Orange accent
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
