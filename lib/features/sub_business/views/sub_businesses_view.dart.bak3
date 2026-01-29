import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/sub_business_provider.dart';
import '../widgets/sub_business_card.dart';

/// Main screen showing list of sub-businesses
class SubBusinessesView extends ConsumerStatefulWidget {
  const SubBusinessesView({super.key});

  @override
  ConsumerState<SubBusinessesView> createState() => _SubBusinessesViewState();
}

class _SubBusinessesViewState extends ConsumerState<SubBusinessesView> {
  @override
  void initState() {
    super.initState();
    // Load sub-businesses on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subBusinessProvider.notifier).loadSubBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subBusinessProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.subBusiness_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(subBusinessProvider.notifier).loadSubBusinesses(),
        color: AppColors.gold500,
        backgroundColor: AppColors.slate,
        child: state.isLoading && state.subBusinesses.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.subBusinesses.isEmpty
                ? _buildEmptyState(l10n)
                : _buildSubBusinessesList(state, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/sub-businesses/create'),
        backgroundColor: AppColors.gold500,
        child: const Icon(Icons.add, color: AppColors.obsidian),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_center_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.subBusiness_emptyTitle,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.subBusiness_emptyMessage,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.subBusiness_createFirst,
              onPressed: () => context.push('/sub-businesses/create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubBusinessesList(
    SubBusinessState state,
    AppLocalizations l10n,
  ) {
    // Calculate total balance
    final totalBalance = state.subBusinesses.fold<double>(
      0.0,
      (sum, sb) => sum + sb.balance,
    );
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Total balance card
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold500,
                AppColors.gold500.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.subBusiness_totalBalance,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.obsidian,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                currencyFormat.format(totalBalance),
                variant: AppTextVariant.displaySmall,
                color: AppColors.obsidian,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                '${state.subBusinesses.length} ${state.subBusinesses.length == 1 ? l10n.subBusiness_unit : l10n.subBusiness_units}',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.obsidian.withOpacity(0.8),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Sub-businesses list
        AppText(
          l10n.subBusiness_listTitle,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),

        ...state.subBusinesses.map((subBusiness) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.md),
            child: SubBusinessCard(
              subBusiness: subBusiness,
              onTap: () => context.push('/sub-businesses/detail/${subBusiness.id}'),
              onTransfer: () => _showTransferDialog(subBusiness),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showTransferDialog(subBusiness) async {
    // TODO: Show transfer dialog
    // For now, navigate to transfer screen
    context.push('/sub-businesses/transfer/${subBusiness.id}');
  }
}
