import 'package:usdc_wallet/features/savings_pots/models/savings_pots_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/savings_pots/providers/savings_pots_provider.dart';
import 'package:usdc_wallet/features/savings_pots/widgets/pot_card.dart';

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
      ref.read(savingsPotsActionsProvider).loadPots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(savingsPotsStateProvider);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.savingsPots_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(savingsPotsActionsProvider).loadPots(),
        color: colors.gold,
        backgroundColor: colors.container,
        child: state.isLoading && state.pots.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : state.pots.isEmpty
                ? _buildEmptyState(l10n)
                : _buildPotsList(state, currencyFormat, l10n),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/savings-pots/create'),
        backgroundColor: colors.gold,
        child: Icon(Icons.add, color: colors.textInverse),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    final colors = context.colors;

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
              color: colors.textSecondary,
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
    final colors = context.colors;

    return ListView(
      padding: EdgeInsets.all(AppSpacing.md),
      children: [
        // Total saved header
        Container(
          padding: EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.gold.withValues(alpha: 0.2),
                colors.gold.withValues(alpha: 0.05),
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
                color: colors.textSecondary,
              ),
              SizedBox(height: AppSpacing.xs),
              AppText(
                currencyFormat.format(state.totalSaved),
                variant: AppTextVariant.displaySmall,
                color: colors.gold,
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
                ref.read(savingsPotsActionsProvider).selectPot(pot.id);
                context.push('/savings-pots/detail/${pot.id}');
              },
            );
          },
        ),
      ],
    );
  }
}
