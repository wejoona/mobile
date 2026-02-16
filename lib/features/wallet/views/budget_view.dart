import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class BudgetView extends ConsumerStatefulWidget {
  const BudgetView({super.key});

  @override
  ConsumerState<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends ConsumerState<BudgetView> {
  final List<_BudgetCategory> _categories = [
    _BudgetCategory(
      nameKey: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
      budget: 500,
      spent: 345.50,
    ),
    _BudgetCategory(
      nameKey: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      budget: 300,
      spent: 289.00,
    ),
    _BudgetCategory(
      nameKey: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      budget: 200,
      spent: 124.75,
    ),
    _BudgetCategory(
      nameKey: 'Entertainment',
      icon: Icons.movie,
      color: Colors.pink,
      budget: 150,
      spent: 89.99,
    ),
    _BudgetCategory(
      nameKey: 'Bills & Utilities',
      icon: Icons.receipt,
      color: Colors.teal,
      budget: 400,
      spent: 380.00,
    ),
    _BudgetCategory(
      nameKey: 'Health',
      icon: Icons.medical_services,
      color: Colors.red,
      budget: 100,
      spent: 45.00,
    ),
  ];

  double get _totalBudget => _categories.fold(0.0, (sum, c) => sum + c.budget);
  double get _totalSpent => _categories.fold(0.0, (sum, c) => sum + c.spent);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.services_budget,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.colors.gold),
            onPressed: () => _showAddCategory(l10n, colors),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(l10n, colors),
            const SizedBox(height: AppSpacing.xl),
            _buildMonthSelector(colors),
            const SizedBox(height: AppSpacing.xl),
            _buildCategoriesHeader(l10n, colors),
            const SizedBox(height: AppSpacing.md),
            ..._categories.map((category) => _buildCategoryCard(category, colors)),
            const SizedBox(height: AppSpacing.xl),
            _buildInsightsCard(l10n, colors),
            const SizedBox(height: AppSpacing.xl),
            _buildTipsCard(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(AppLocalizations l10n, ThemeColors colors) {
    final percentUsed = _totalSpent / _totalBudget;
    final remaining = _totalBudget - _totalSpent;
    final daysLeft = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day - DateTime.now().day;
    final dailyBudget = remaining / daysLeft;

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      AppStrings.monthlyBudget,
                      variant: AppTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    AppText(
                      '\$${_totalBudget.toStringAsFixed(0)}',
                      variant: AppTextVariant.headlineSmall,
                      color: colors.textPrimary,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: percentUsed.clamp(0.0, 1.0),
                      strokeWidth: 8,
                      backgroundColor: context.colors.borderSubtle,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentUsed > 0.9 ? context.colors.error :
                        percentUsed > 0.75 ? context.colors.warning : context.colors.gold,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          '${(percentUsed * 100).toStringAsFixed(0)}%',
                          variant: AppTextVariant.labelLarge,
                          color: colors.textPrimary,
                        ),
                        AppText(
                          'used',
                          variant: AppTextVariant.labelSmall,
                          color: colors.textTertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: context.colors.borderSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  AppStrings.spent,
                  '\$${_totalSpent.toStringAsFixed(0)}',
                  colors.textPrimary,
                  colors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.colors.borderSubtle,
              ),
              Expanded(
                child: _buildOverviewItem(
                  AppStrings.remaining,
                  '\$${remaining.toStringAsFixed(0)}',
                  remaining < 0 ? context.colors.error : context.colors.success,
                  colors,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: context.colors.borderSubtle,
              ),
              Expanded(
                child: _buildOverviewItem(
                  AppStrings.dailyBudget,
                  '\$${dailyBudget.toStringAsFixed(0)}',
                  context.colors.gold,
                  colors,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color valueColor, ThemeColors colors) {
    return Column(
      children: [
        AppText(
          value,
          variant: AppTextVariant.titleMedium,
          color: valueColor,
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMonthSelector(ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: colors.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.md),
        AppText(
          'January 2026',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton(
          icon: Icon(Icons.chevron_right, color: colors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoriesHeader(AppLocalizations l10n, ThemeColors colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(
          AppStrings.budgetCategories,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        TextButton(
          onPressed: () => _showEditMode(),
          child: AppText(
            'Edit',
            variant: AppTextVariant.labelMedium,
            color: context.colors.gold,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(_BudgetCategory category, ThemeColors colors) {
    final percentUsed = category.spent / category.budget;
    final remaining = category.budget - category.spent;
    final isOverBudget = remaining < 0;
    final isNearLimit = percentUsed >= 0.9;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () => _showCategoryDetails(category, colors),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.md),
                  ),
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        category.nameKey,
                        variant: AppTextVariant.labelMedium,
                        color: colors.textPrimary,
                      ),
                      AppText(
                        '\$${category.spent.toStringAsFixed(0)} of \$${category.budget.toStringAsFixed(0)}',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      isOverBudget ? '-\$${(-remaining).toStringAsFixed(0)}' : '\$${remaining.toStringAsFixed(0)}',
                      variant: AppTextVariant.labelMedium,
                      color: isOverBudget ? context.colors.error : (isNearLimit ? context.colors.warning : context.colors.success),
                    ),
                    AppText(
                      isOverBudget ? 'over budget' : 'left',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.xs),
              child: LinearProgressIndicator(
                value: percentUsed.clamp(0.0, 1.0),
                backgroundColor: context.colors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? context.colors.error :
                  isNearLimit ? context.colors.warning : category.color,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(AppLocalizations l10n, ThemeColors colors) {
    final overBudgetCategories = _categories.where((c) => c.spent > c.budget).toList();
    final nearLimitCategories = _categories.where((c) => c.spent / c.budget >= 0.9 && c.spent <= c.budget).toList();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights, color: context.colors.gold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                AppStrings.budgetInsights,
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (overBudgetCategories.isNotEmpty)
            _buildInsightItem(
              Icons.warning,
              context.colors.error,
              '${overBudgetCategories.length} ${overBudgetCategories.length == 1 ? 'category is' : 'categories are'} over budget',
              colors,
            ),
          if (nearLimitCategories.isNotEmpty)
            _buildInsightItem(
              Icons.trending_up,
              context.colors.warning,
              '${nearLimitCategories.length} ${nearLimitCategories.length == 1 ? 'category is' : 'categories are'} near the limit',
              colors,
            ),
          _buildInsightItem(
            Icons.check_circle,
            context.colors.success,
            'You\'ve saved \$${(_totalBudget - _totalSpent).toStringAsFixed(0)} so far this month',
            colors,
          ),
          _buildInsightItem(
            Icons.lightbulb,
            context.colors.gold,
            'Consider reducing spending on ${_categories.reduce((a, b) => a.spent > b.spent ? a : b).nameKey}',
            colors,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, Color color, String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: context.colors.gold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                AppStrings.budgetingTips,
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem('Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings', colors),
          _buildTipItem('Review and adjust your budget monthly', colors),
          _buildTipItem('Set up alerts when you reach 80% of a budget', colors),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: context.colors.success, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              tip,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategory(AppLocalizations l10n, ThemeColors colors) {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = context.colors.gold;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.elevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  AppStrings.addBudgetCategory,
                  variant: AppTextVariant.titleMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppInput(
                  controller: nameController,
                  hint: 'e.g., Groceries',
                  label: 'Category Name',
                ),
                const SizedBox(height: AppSpacing.md),
                AppInput(
                  controller: budgetController,
                  hint: '\$0',
                  label: AppStrings.monthlyBudget,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  'Choose Icon',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Icons.restaurant,
                    Icons.shopping_bag,
                    Icons.directions_car,
                    Icons.movie,
                    Icons.receipt,
                    Icons.medical_services,
                    Icons.school,
                    Icons.fitness_center,
                  ].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? selectedColor.withValues(alpha: 0.1) : context.colors.elevated,
                          borderRadius: BorderRadius.circular(AppSpacing.sm),
                          border: Border.all(
                            color: isSelected ? selectedColor : context.colors.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? selectedColor : colors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
                AppText(
                  'Choose Color',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    Colors.orange,
                    Colors.purple,
                    Colors.blue,
                    Colors.pink,
                    Colors.teal,
                    Colors.red,
                    Colors.green,
                    Colors.indigo,
                  ].map((color) {
                    final isSelected = selectedColor == color;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 3)
                              : null,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Add Category',
                  onPressed: () {
                    if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                      setState(() {
                        _categories.add(_BudgetCategory(
                          nameKey: nameController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                          budget: double.tryParse(budgetController.text) ?? 0,
                          spent: 0,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Category added'),
                          backgroundColor: context.colors.success,
                        ),
                      );
                    }
                  },
                  variant: AppButtonVariant.primary,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCategoryDetails(_BudgetCategory category, ThemeColors colors) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.elevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, color: category.color, size: 32),
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              category.nameKey,
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Budget', '\$${category.budget.toStringAsFixed(0)}', colors),
                _buildDetailItem(AppStrings.spent, '\$${category.spent.toStringAsFixed(0)}', colors),
                _buildDetailItem('Left', '\$${(category.budget - category.spent).toStringAsFixed(0)}', colors),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit Budget',
                    onPressed: () {
                      Navigator.pop(context);
                      _editCategoryBudget(category, colors);
                    },
                    variant: AppButtonVariant.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Delete',
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteCategory(category, colors);
                    },
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, ThemeColors colors) {
    return Column(
      children: [
        AppText(
          value,
          variant: AppTextVariant.titleMedium,
          color: context.colors.gold,
        ),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  void _editCategoryBudget(_BudgetCategory category, ThemeColors colors) {
    final budgetController = TextEditingController(text: category.budget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.elevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.lg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Edit ${category.nameKey} Budget',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppInput(
              controller: budgetController,
              hint: '\$0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Save',
              onPressed: () {
                setState(() {
                  category.budget = double.tryParse(budgetController.text) ?? category.budget;
                });
                Navigator.pop(context);
              },
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  void _deleteCategory(_BudgetCategory category, ThemeColors colors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.elevated,
        title: const AppText('Delete Category?', variant: AppTextVariant.titleMedium),
        content: AppText(
          'Are you sure you want to delete "${category.nameKey}"?',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText('Cancel', color: colors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              setState(() => _categories.removeWhere((c) => c.nameKey == category.nameKey));
              Navigator.pop(context);
            },
            child: AppText('Delete', color: context.colors.error),
          ),
        ],
      ),
    );
  }

  void _showEditMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tap any category to edit its budget'),
        backgroundColor: context.colors.info,
      ),
    );
  }
}

class _BudgetCategory {
  final String nameKey;
  final IconData icon;
  final Color color;
  double budget;
  double spent;

  _BudgetCategory({
    required this.nameKey,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
  });
}
