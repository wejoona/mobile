import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

class BudgetView extends ConsumerStatefulWidget {
  const BudgetView({super.key});

  @override
  ConsumerState<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends ConsumerState<BudgetView> {
  final List<_BudgetCategory> _categories = [
    _BudgetCategory(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: Colors.orange,
      budget: 500,
      spent: 345.50,
    ),
    _BudgetCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.purple,
      budget: 300,
      spent: 289.00,
    ),
    _BudgetCategory(
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
      budget: 200,
      spent: 124.75,
    ),
    _BudgetCategory(
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.pink,
      budget: 150,
      spent: 89.99,
    ),
    _BudgetCategory(
      name: 'Bills & Utilities',
      icon: Icons.receipt,
      color: Colors.teal,
      budget: 400,
      spent: 380.00,
    ),
    _BudgetCategory(
      name: 'Health',
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
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Budget',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddCategory(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            _buildOverviewCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Month Navigation
            _buildMonthSelector(),

            const SizedBox(height: AppSpacing.xxl),

            // Budget Categories
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  'Budget Categories',
                  variant: AppTextVariant.titleMedium,
                  color: AppColors.textPrimary,
                ),
                TextButton(
                  onPressed: () => _showEditMode(),
                  child: const AppText(
                    'Edit',
                    variant: AppTextVariant.labelMedium,
                    color: AppColors.gold500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            ..._categories.map((category) => _buildCategoryCard(category)),

            const SizedBox(height: AppSpacing.xxl),

            // Insights
            _buildInsightsCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Tips
            _buildTipsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
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
                    const AppText(
                      'Monthly Budget',
                      variant: AppTextVariant.labelSmall,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      '\$${_totalBudget.toStringAsFixed(0)}',
                      variant: AppTextVariant.headlineSmall,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              Container(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: percentUsed.clamp(0.0, 1.0),
                        strokeWidth: 8,
                        backgroundColor: AppColors.borderSubtle,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentUsed > 0.9 ? AppColors.errorBase :
                          percentUsed > 0.75 ? AppColors.warningBase : AppColors.gold500,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          '${(percentUsed * 100).toStringAsFixed(0)}%',
                          variant: AppTextVariant.labelLarge,
                          color: AppColors.textPrimary,
                        ),
                        const AppText(
                          'used',
                          variant: AppTextVariant.labelSmall,
                          color: AppColors.textTertiary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.borderSubtle),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Spent',
                  '\$${_totalSpent.toStringAsFixed(0)}',
                  AppColors.textPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _buildOverviewItem(
                  'Remaining',
                  '\$${remaining.toStringAsFixed(0)}',
                  remaining < 0 ? AppColors.errorBase : AppColors.successBase,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _buildOverviewItem(
                  'Daily Budget',
                  '\$${dailyBudget.toStringAsFixed(0)}',
                  AppColors.gold500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        AppText(
          value,
          variant: AppTextVariant.titleMedium,
          color: valueColor,
        ),
        const SizedBox(height: AppSpacing.xxs),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.textSecondary),
          onPressed: () {},
        ),
        const SizedBox(width: AppSpacing.md),
        const AppText(
          'January 2026',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton(
          icon: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategoryCard(_BudgetCategory category) {
    final percentUsed = category.spent / category.budget;
    final remaining = category.budget - category.spent;
    final isOverBudget = remaining < 0;
    final isNearLimit = percentUsed >= 0.9;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () => _showCategoryDetails(category),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(category.icon, color: category.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        category.name,
                        variant: AppTextVariant.labelMedium,
                        color: AppColors.textPrimary,
                      ),
                      AppText(
                        '\$${category.spent.toStringAsFixed(0)} of \$${category.budget.toStringAsFixed(0)}',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
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
                      color: isOverBudget ? AppColors.errorBase : (isNearLimit ? AppColors.warningBase : AppColors.successBase),
                    ),
                    AppText(
                      isOverBudget ? 'over budget' : 'left',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: percentUsed.clamp(0.0, 1.0),
                backgroundColor: AppColors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? AppColors.errorBase :
                  isNearLimit ? AppColors.warningBase : category.color,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final overBudgetCategories = _categories.where((c) => c.spent > c.budget).toList();
    final nearLimitCategories = _categories.where((c) => c.spent / c.budget >= 0.9 && c.spent <= c.budget).toList();

    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights, color: AppColors.gold500, size: 20),
              SizedBox(width: AppSpacing.sm),
              AppText(
                'Budget Insights',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          if (overBudgetCategories.isNotEmpty)
            _buildInsightItem(
              Icons.warning,
              AppColors.errorBase,
              '${overBudgetCategories.length} ${overBudgetCategories.length == 1 ? 'category is' : 'categories are'} over budget',
            ),

          if (nearLimitCategories.isNotEmpty)
            _buildInsightItem(
              Icons.trending_up,
              AppColors.warningBase,
              '${nearLimitCategories.length} ${nearLimitCategories.length == 1 ? 'category is' : 'categories are'} near the limit',
            ),

          _buildInsightItem(
            Icons.check_circle,
            AppColors.successBase,
            'You\'ve saved \$${(_totalBudget - _totalSpent).toStringAsFixed(0)} so far this month',
          ),

          _buildInsightItem(
            Icons.lightbulb,
            AppColors.gold500,
            'Consider reducing spending on ${_categories.reduce((a, b) => a.spent > b.spent ? a : b).name}',
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(IconData icon, Color color, String text) {
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
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: AppColors.gold500, size: 20),
              SizedBox(width: AppSpacing.sm),
              AppText(
                'Budgeting Tips',
                variant: AppTextVariant.labelMedium,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem('Follow the 50/30/20 rule: 50% needs, 30% wants, 20% savings'),
          _buildTipItem('Review and adjust your budget monthly'),
          _buildTipItem('Set up alerts when you reach 80% of a budget'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.successBase, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              tip,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddCategory() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    IconData selectedIcon = Icons.category;
    Color selectedColor = AppColors.gold500;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.xl,
            right: AppSpacing.xl,
            top: AppSpacing.xl,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Add Budget Category',
                  variant: AppTextVariant.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                const AppText(
                  'Category Name',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: nameController,
                  hint: 'e.g., Groceries',
                ),

                const SizedBox(height: AppSpacing.lg),

                const AppText(
                  'Monthly Budget',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: budgetController,
                  hint: '\$0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: AppSpacing.lg),

                const AppText(
                  'Choose Icon',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
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
                          color: isSelected ? selectedColor.withValues(alpha: 0.1) : AppColors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected ? selectedColor : AppColors.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: isSelected ? selectedColor : AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.lg),

                const AppText(
                  'Choose Color',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.textSecondary,
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

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: 'Add Category',
                  onPressed: () {
                    if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty) {
                      setState(() {
                        _categories.add(_BudgetCategory(
                          name: nameController.text,
                          icon: selectedIcon,
                          color: selectedColor,
                          budget: double.tryParse(budgetController.text) ?? 0,
                          spent: 0,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Category added'),
                          backgroundColor: AppColors.successBase,
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

  void _showCategoryDetails(_BudgetCategory category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.lg),
            AppText(
              category.name,
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Budget', '\$${category.budget.toStringAsFixed(0)}'),
                _buildDetailItem('Spent', '\$${category.spent.toStringAsFixed(0)}'),
                _buildDetailItem('Left', '\$${(category.budget - category.spent).toStringAsFixed(0)}'),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Edit Budget',
                    onPressed: () {
                      Navigator.pop(context);
                      _editCategoryBudget(category);
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
                      _deleteCategory(category);
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

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        AppText(
          value,
          variant: AppTextVariant.titleMedium,
          color: AppColors.gold500,
        ),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  void _editCategoryBudget(_BudgetCategory category) {
    final budgetController = TextEditingController(text: category.budget.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Edit ${category.name} Budget',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppInput(
              controller: budgetController,
              hint: '\$0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.xxl),
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

  void _deleteCategory(_BudgetCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: const AppText('Delete Category?', variant: AppTextVariant.titleMedium),
        content: AppText(
          'Are you sure you want to delete "${category.name}"?',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const AppText('Cancel', color: AppColors.textSecondary),
          ),
          TextButton(
            onPressed: () {
              setState(() => _categories.removeWhere((c) => c.name == category.name));
              Navigator.pop(context);
            },
            child: const AppText('Delete', color: AppColors.errorBase),
          ),
        ],
      ),
    );
  }

  void _showEditMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tap any category to edit its budget'),
        backgroundColor: AppColors.infoBase,
      ),
    );
  }
}

class _BudgetCategory {
  final String name;
  final IconData icon;
  final Color color;
  double budget;
  double spent;

  _BudgetCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
  });
}
