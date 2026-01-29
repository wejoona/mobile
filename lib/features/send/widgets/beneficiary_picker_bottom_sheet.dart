import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../beneficiaries/providers/beneficiaries_provider.dart';
import '../../beneficiaries/models/beneficiary.dart';

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

    final filteredBeneficiaries = _searchQuery.isEmpty
        ? state.beneficiaries
        : state.beneficiaries
            .where((b) =>
                b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                (b.phoneE164?.contains(_searchQuery) ?? false))
            .toList();

    // Filter only JoonaPay users for internal transfers
    final joonaPayBeneficiaries = filteredBeneficiaries
        .where((b) => b.accountType == AccountType.joonapayUser)
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.gold500),
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
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        itemCount: joonaPayBeneficiaries.length,
                        itemBuilder: (context, index) {
                          final beneficiary = joonaPayBeneficiaries[index];
                          return _buildBeneficiaryItem(beneficiary);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeneficiaryItem(Beneficiary beneficiary) {
    return InkWell(
      onTap: () => Navigator.pop(context, beneficiary),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.gold500.withOpacity(0.2),
              child: AppText(
                beneficiary.name[0].toUpperCase(),
                variant: AppTextVariant.bodyLarge,
                  color: AppColors.gold500,
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
                          color: AppColors.gold500,
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: AppSpacing.xs),
                  AppText(
                    beneficiary.phoneE164 ?? '',
                    variant: AppTextVariant.bodySmall,
                      color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
