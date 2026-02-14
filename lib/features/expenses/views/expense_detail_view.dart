import 'package:usdc_wallet/design/tokens/index.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/features/expenses/providers/expenses_provider.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class ExpenseDetailView extends ConsumerWidget {
  const ExpenseDetailView({
    super.key,
    required this.expense,
  });

  final Expense expense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currencyFormat = NumberFormat.currency(symbol: 'XOF', decimalDigits: 0);
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_expenseDetails,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context, ref, l10n),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.md),
          children: [
            // Receipt Image
            if (expense.receiptImagePath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.file(
                  File(expense.receiptImagePath!),
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            // Amount Card
            AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: context.colors.elevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getCategoryIcon(expense.category),
                        color: context.colors.gold,
                        size: 32,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    AppText(
                      _getCategoryLabel(l10n, expense.category),
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    AppText(
                      currencyFormat.format(expense.amount),
                      style: AppTypography.displaySmall.copyWith(
                        color: context.colors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Details Section
            AppCard(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      l10n.expenses_details,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.md),
                    if (expense.vendor != null)
                      _buildDetailRow(
                        l10n.expenses_vendor,
                        expense.vendor!,
                        Icons.store,
                      ),
                    _buildDetailRow(
                      l10n.expenses_date,
                      dateFormat.format(expense.date),
                      Icons.calendar_today,
                    ),
                    _buildDetailRow(
                      l10n.expenses_time,
                      timeFormat.format(expense.createdAt ?? expense.date),
                      Icons.access_time,
                    ),
                    if (expense.description != null)
                      _buildDetailRow(
                        l10n.expenses_description,
                        expense.description!,
                        Icons.description,
                      ),
                    if (expense.transactionId != null) // ignore: unnecessary_null_comparison
                      _buildDetailRow(
                        l10n.expenses_linkedTransaction,
                        expense.transactionId,
                        Icons.link,
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // Action Buttons
            AppButton(
              label: l10n.common_share,
              onPressed: () => _shareExpense(context, l10n),
              icon: Icons.share,
              variant: AppButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  value,
                  style: AppTypography.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.elevated,
        title: AppText(
          l10n.expenses_deleteExpense,
          style: AppTypography.headlineSmall,
        ),
        content: AppText(l10n.expenses_deleteConfirmation),
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
      try {
        ref.invalidate(expensesProvider);
        if (context.mounted) {
          context.pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.expenses_deletedSuccessfully),
              backgroundColor: context.colors.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.error_generic),
              backgroundColor: context.colors.error,
            ),
          );
        }
      }
    }
  }

  void _shareExpense(BuildContext context, AppLocalizations l10n) {
    final currencyFormat =
        NumberFormat.currency(symbol: 'XOF', decimalDigits: 0);
    final dateFormat = DateFormat('MMMM dd, yyyy');
    final text = StringBuffer();
    text.writeln('${l10n.expenses_expenseDetails}: ${expense.description ?? ''}');
    text.writeln('${l10n.expenses_amount}: ${currencyFormat.format(expense.amount)}');
    text.writeln('${l10n.expenses_category}: ${_getCategoryLabel(l10n, expense.category)}');
    text.writeln('${l10n.expenses_date}: ${dateFormat.format(expense.date)}');
    if (expense.vendor != null) {
      text.writeln('${l10n.expenses_vendor}: ${expense.vendor}');
    }
    if (expense.description != null && expense.description!.isNotEmpty) {
      text.writeln('${l10n.expenses_description}: ${expense.description}');
    }
    text.writeln('\n— Korido');
    SharePlus.instance.share(ShareParams(text: text.toString()));
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
