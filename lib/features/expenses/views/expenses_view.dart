import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/kyc/models/missing_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/features/expenses/providers/expenses_provider.dart';
import 'package:usdc_wallet/features/expenses/models/expense.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ExpensesView extends ConsumerStatefulWidget {
  const ExpensesView({super.key});

  @override
  ConsumerState<ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends ConsumerState<ExpensesView> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(expensesStateProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_title,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            onPressed: () => context.push('/expenses/reports'),
            tooltip: l10n.expenses_viewReports,
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.expenses.isEmpty
                ? _buildEmptyState(context, l10n)
                : RefreshIndicator(
                    onRefresh: () async { ref.invalidate(expensesProvider); },
                    child: Column(
                      children: [
                        _buildSummaryCard(context, l10n, state),
                        Expanded(
                          child: _buildExpensesList(context, l10n, state),
                        ),
                      ],
                    ),
                  ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'capture',
            onPressed: () => context.push('/expenses/capture'),
            backgroundColor: context.colors.gold,
            child: const Icon(Icons.camera_alt),
          ),
          SizedBox(height: AppSpacing.sm),
          FloatingActionButton(
            heroTag: 'add',
            onPressed: () => context.push('/expenses/add'),
            backgroundColor: context.colors.elevated,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: context.colors.textSecondary.withValues(alpha: 0.5),
            ),
            SizedBox(height: AppSpacing.lg),
            AppText(
              l10n.expenses_emptyTitle,
              style: AppTypography.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.sm),
            AppText(
              l10n.expenses_emptyMessage,
              style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.xl),
            AppButton(
              label: l10n.expenses_captureReceipt,
              onPressed: () => context.push('/expenses/capture'),
              icon: Icons.camera_alt,
            ),
            SizedBox(height: AppSpacing.md),
            AppButton(
              label: l10n.expenses_addManually,
              onPressed: () => context.push('/expenses/add'),
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    AppLocalizations l10n,
    ExpensesState state,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'XOF',
      decimalDigits: 0,
    );

    return Padding(
      padding: EdgeInsets.all(AppSpacing.md),
      child: AppCard(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    l10n.expenses_totalExpenses,
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                  AppText(
                    '${state.expenses.length} ${l10n.expenses_items}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                currencyFormat.format(state.totalAmount),
                style: AppTypography.headlineLarge.copyWith(
                  color: context.colors.gold,
                ),
              ),
              SizedBox(height: AppSpacing.md),
              _buildCategoryBreakdown(l10n, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(AppLocalizations l10n, ExpensesState state) {
    if (state.categoryTotals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: state.categoryTotals.entries.map((entry) {
        final percentage = (entry.value / state.totalAmount * 100).toInt();
        return Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.xs),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(entry.key),
                size: 16,
                color: context.colors.textSecondary,
              ),
              SizedBox(width: AppSpacing.xs),
              Expanded(
                child: AppText(
                  _getCategoryLabel(l10n, entry.key),
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
              AppText(
                '$percentage%',
                style: AppTypography.bodySmall.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    AppLocalizations l10n,
    ExpensesState state,
  ) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'XOF',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
      itemCount: state.expenses.length,
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        return AppCard(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          onTap: () => context.push('/expenses/detail/${expense.id}', extra: expense),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _getCategoryIcon(expense.category),
                    color: context.colors.gold,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        expense.vendor ?? _getCategoryLabel(l10n, expense.category),
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          AppText(
                            dateFormat.format(expense.date),
                            style: AppTypography.bodySmall.copyWith(
                              color: context.colors.textSecondary,
                            ),
                          ),
                          if (expense.receiptImagePath != null) ...[
                            SizedBox(width: AppSpacing.xs),
                            Icon(
                              Icons.receipt,
                              size: 14,
                              color: context.colors.gold,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                AppText(
                  currencyFormat.format(expense.amount),
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: context.colors.gold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case ExpenseCategory.travel:
        return Icons.flight;
      case ExpenseCategory.meals:
        return Icons.restaurant;
      case ExpenseCategory.office:
        return Icons.business;
      case ExpenseCategory.transport:
        return Icons.directions_car;
      case ExpenseCategory.other:
      default:
        return Icons.more_horiz;
    }
  }

  String _getCategoryLabel(AppLocalizations l10n, String category) {
    switch (category) {
      case ExpenseCategory.travel:
        return l10n.expenses_categoryTravel;
      case ExpenseCategory.meals:
        return l10n.expenses_categoryMeals;
      case ExpenseCategory.office:
        return l10n.expenses_categoryOffice;
      case ExpenseCategory.transport:
        return l10n.expenses_categoryTransport;
      case ExpenseCategory.other:
      default:
        return l10n.expenses_categoryOther;
    }
  }
}
