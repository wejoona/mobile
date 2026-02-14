import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';

class BeneficiaryPickerBottomSheet extends ConsumerStatefulWidget {
  const BeneficiaryPickerBottomSheet({super.key});

  @override
  ConsumerState<BeneficiaryPickerBottomSheet> createState() =>
      _BeneficiaryPickerBottomSheetState();
}

class _BeneficiaryPickerBottomSheetState
    extends ConsumerState<BeneficiaryPickerBottomSheet> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Load beneficiaries
    Future.microtask(() {
      ref.read(beneficiariesProvider.notifier).loadBeneficiaries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(beneficiariesProvider);
    final colors = context.colors;

    final filteredBeneficiaries = _searchQuery.isEmpty
        ? state.beneficiaries
        : state.beneficiaries
            .where((b) =>
                b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (b.phoneE164?.contains(_searchQuery) ?? false))
            .toList();

    // Filter only Korido users for internal transfers
    final joonaPayBeneficiaries = filteredBeneficiaries
        .where((b) => b.accountType == AccountType.joonapayUser)
        .toList();

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
          SizedBox(height: AppSpacing.md),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppInput(
              controller: _searchController,
              hint: l10n.send_searchBeneficiaries,
              prefixIcon: Icons.search,
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Beneficiaries list
          Expanded(
            child: state.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colors.gold),
                    ),
                  )
                : joonaPayBeneficiaries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.bookmark_outline,
                              size: 64,
                              color: colors.textSecondary.withValues(alpha: 0.5),
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
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: joonaPayBeneficiaries.length,
                        itemBuilder: (context, index) {
                          final beneficiary = joonaPayBeneficiaries[index];
                          return _buildBeneficiaryItem(beneficiary, colors);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryItem(Beneficiary beneficiary, ThemeColors colors) {
    return InkWell(
      onTap: () => Navigator.pop(context, beneficiary),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colors.gold.withValues(alpha: 0.2),
              child: AppText(
                beneficiary.name[0].toUpperCase(),
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
                  Row(
                    children: [
                      AppText(
                        beneficiary.name,
                        variant: AppTextVariant.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      if (beneficiary.isFavorite) ...[
                        SizedBox(width: AppSpacing.xs),
                        Icon(
                          Icons.star,
                          size: 16,
                          color: colors.gold,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    beneficiary.phoneE164 ?? '',
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
