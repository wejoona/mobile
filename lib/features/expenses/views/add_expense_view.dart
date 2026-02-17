import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/design/components/primitives/app_select.dart';
import 'package:usdc_wallet/features/expenses/providers/expenses_provider.dart';
import 'package:usdc_wallet/domain/entities/expense.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class AddExpenseView extends ConsumerStatefulWidget {
  const AddExpenseView({super.key});

  @override
  ConsumerState<AddExpenseView> createState() => _AddExpenseViewState();
}

class _AddExpenseViewState extends ConsumerState<AddExpenseView> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _vendorController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = ExpenseCategory.other;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _vendorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.expenses_addManually,
          style: AppTypography.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.md),
            children: [
              AppSelect(
                label: l10n.expenses_category,
                value: _selectedCategory,
                items: ExpenseCategory.all.map((category) {
                  return AppSelectItem(
                    value: category,
                    label: _getCategoryLabel(l10n, category),
                    icon: _getCategoryIcon(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_amount,
                controller: _amountController,
                keyboardType: TextInputType.number,
                prefix: const Text('XOF '),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return l10n.expenses_errorAmountRequired;
                  }
                  if (double.tryParse(value!) == null) {
                    return l10n.expenses_errorInvalidAmount;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_vendor,
                controller: _vendorController,
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_date,
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('MMMM dd, yyyy').format(_selectedDate),
                ),
                suffixIcon: Icons.calendar_today,
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: AppSpacing.md),
              AppInput(
                label: l10n.expenses_description,
                controller: _descriptionController,
                maxLines: 3,
              ),
              SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.expenses_addExpense,
                onPressed: _handleSubmit,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.gold,
              onPrimary: context.colors.canvas,
              surface: context.colors.elevated,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // ignore: unused_local_variable
      final __expense = Expense(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        currency: 'XOF',
        date: _selectedDate,
        vendor: _vendorController.text.isEmpty ? null : _vendorController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: DateTime.now(),
      );

      ref.invalidate(expensesProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.expenses_addedSuccessfully,
            ),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.expenses_saveError),
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
