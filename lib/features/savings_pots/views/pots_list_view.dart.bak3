import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../providers/savings_pots_provider.dart';
import '../widgets/pot_card.dart';

/// Main screen showing list of savings pots
class PotsListView extends ConsumerStatefulWidget {
  const PotsListView({super.key});

  @override
  ConsumerState<PotsListView> createState() => _PotsListViewState();
}

class _PotsListViewState extends ConsumerState<PotsListView> {
  @override
  void initState() {
    super.initState();
    // Load pots on mount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(savingsPotsProvider.notifier).loadPots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        title: AppText(
          l10n.savingsPots_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(savingsPotsProvider.notifier).loadPots(),
        color: AppColors.gold500,
        backgroundColor: AppColors.slate,
        child: state.isLoading && state.pots.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.pots.isEmpty
                ? _buildEmptyState(l10n)
                : _buildPotsList(state, currencyFormat, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/savings-pots/create'),
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
            const Text('🎯', style: TextStyle(fontSize: 64)),
            SizedBox(height: AppSpacing.md),
            AppText(
              l10n.savingsPots_emptyTitle,
              variant: AppTextVariant.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.savingsPots_emptyMessage,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.savingsPots_createFirst,
              onPressed: () => context.push('/savings-pots/create'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPotsList(
    SavingsPotsState state,
    NumberFormat currencyFormat,
    AppLocalizations l10n,
  ) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Total saved header
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.gold500.withOpacity(0.2),
                AppColors.gold500.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                l10n.savingsPots_totalSaved,
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                currencyFormat.format(state.totalSaved),
                variant: AppTextVariant.displaySmall,
                color: AppColors.gold500,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpacing.lg),

        // Pots grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: state.pots.length,
          itemBuilder: (context, index) {
            final pot = state.pots[index];
            return PotCard(
              pot: pot,
              onTap: () {
                ref.read(savingsPotsProvider.notifier).selectPot(pot.id);
                context.push('/savings-pots/detail/${pot.id}');
              },
            );
          },
        ),
      ],
    );
  }
}
