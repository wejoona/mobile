import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class SavingsGoalsView extends ConsumerStatefulWidget {
  const SavingsGoalsView({super.key});

  @override
  ConsumerState<SavingsGoalsView> createState() => _SavingsGoalsViewState();
}

class _SavingsGoalsViewState extends ConsumerState<SavingsGoalsView> {
  final List<_SavingsGoal> _goals = [
    _SavingsGoal(
      id: '1',
      name: 'Emergency Fund',
      targetAmount: 1000,
      savedAmount: 450,
      icon: Icons.shield,
      color: Colors.blue,
      deadline: DateTime.now().add(const Duration(days: 90)),
      autoSaveEnabled: true,
      autoSaveAmount: 50,
    ),
    _SavingsGoal(
      id: '2',
      name: 'Vacation',
      targetAmount: 2500,
      savedAmount: 800,
      icon: Icons.flight,
      color: Colors.orange,
      deadline: DateTime.now().add(const Duration(days: 180)),
      autoSaveEnabled: false,
      autoSaveAmount: 0,
    ),
    _SavingsGoal(
      id: '3',
      name: 'New Phone',
      targetAmount: 500,
      savedAmount: 320,
      icon: Icons.phone_iphone,
      color: Colors.purple,
      deadline: DateTime.now().add(const Duration(days: 45)),
      autoSaveEnabled: true,
      autoSaveAmount: 25,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final walletState = ref.watch(walletStateMachineProvider);
    final totalSaved = _goals.fold(0.0, (sum, goal) => sum + goal.savedAmount);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Savings Goals',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateGoalSheet(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            _buildSummaryCard(totalSaved, walletState, colors),

            const SizedBox(height: AppSpacing.xxl),

            // Goals List
            AppText(
              'Your Goals',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),

            if (_goals.isEmpty)
              _buildEmptyState(colors)
            else
              ..._goals.map((goal) => _buildGoalCard(goal, colors)),

            const SizedBox(height: AppSpacing.xxl),

            // Tips Card
            _buildTipsCard(colors),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGoalSheet(),
        backgroundColor: colors.gold,
        icon: Icon(Icons.add, color: colors.canvas),
        label: AppText(
          'New Goal',
          variant: AppTextVariant.labelMedium,
          color: colors.canvas,
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double totalSaved, WalletState walletState, ThemeColors colors) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.gold, context.colors.gold],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.savings,
                  color: colors.canvas,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Total Saved',
                      variant: AppTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                    AppText(
                      '\$${totalSaved.toStringAsFixed(2)}',
                      variant: AppTextVariant.headlineSmall,
                      color: colors.gold,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  AppText(
                    'Available',
                    variant: AppTextVariant.labelSmall,
                    color: colors.textSecondary,
                  ),
                  AppText(
                    '\$${walletState.availableBalance.toStringAsFixed(2)}',
                    variant: AppTextVariant.titleMedium,
                    color: colors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: colors.borderSubtle),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem('${_goals.length}', 'Active Goals', colors),
              _buildSummaryItem(
                '${_goals.where((g) => g.autoSaveEnabled).length}',
                'Auto-Saving',
                colors,
              ),
              _buildSummaryItem(
                '\$${_goals.fold(0.0, (sum, g) => sum + g.autoSaveAmount).toStringAsFixed(0)}',
                'Monthly',
                colors,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String value, String label, ThemeColors colors) {
    return Column(
      children: [
        AppText(
          value,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildGoalCard(_SavingsGoal goal, ThemeColors colors) {
    final progress = goal.savedAmount / goal.targetAmount;
    final remaining = goal.targetAmount - goal.savedAmount;
    final daysLeft = goal.deadline.difference(DateTime.now()).inDays;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        onTap: () => _showGoalDetails(goal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: goal.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppText(
                            goal.name,
                            variant: AppTextVariant.labelLarge,
                            color: colors.textPrimary,
                          ),
                          if (goal.autoSaveEnabled) ...[
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xs,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.xs),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.autorenew, size: 12, color: context.colors.success),
                                  SizedBox(width: 2),
                                  AppText(
                                    'Auto',
                                    variant: AppTextVariant.labelSmall,
                                    color: context.colors.success,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      AppText(
                        '$daysLeft days left',
                        variant: AppTextVariant.bodySmall,
                        color: daysLeft < 30 ? context.colors.warning : colors.textSecondary,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: colors.gold),
                  onPressed: () => _showAddFundsSheet(goal),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.xs),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: colors.borderSubtle,
                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppText(
                  '\$${goal.savedAmount.toStringAsFixed(2)} saved',
                  variant: AppTextVariant.labelMedium,
                  color: goal.color,
                ),
                AppText(
                  '\$${remaining.toStringAsFixed(2)} to go',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs),
            AppText(
              'Target: \$${goal.targetAmount.toStringAsFixed(2)}',
              variant: AppTextVariant.bodySmall,
              color: colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colors.container,
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Icon(
                Icons.savings_outlined,
                color: colors.textTertiary,
                size: 40,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'No Savings Goals Yet',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              'Start saving for your dreams!\nCreate your first goal to get started.',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
              Icon(Icons.lightbulb_outline, color: colors.gold, size: 20),
              const SizedBox(width: AppSpacing.sm),
              AppText(
                'Savings Tips',
                variant: AppTextVariant.labelMedium,
                color: colors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTipItem('Enable auto-save to reach goals faster', colors),
          _buildTipItem('Start with small, achievable goals', colors),
          _buildTipItem('Review and adjust goals monthly', colors),
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
          Icon(Icons.check_circle, color: context.colors.success, size: 16),
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

  void _showCreateGoalSheet() {
    final colors = context.colors;
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    IconData selectedIcon = Icons.savings;
    Color selectedColor = colors.gold;
    bool autoSave = false;
    double autoSaveAmount = 25;

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
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
                  'Create Savings Goal',
                  variant: AppTextVariant.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Goal Name
                AppText(
                  'Goal Name',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: nameController,
                  hint: 'e.g., Vacation Fund',
                ),

                const SizedBox(height: AppSpacing.lg),

                // Target Amount
                AppText(
                  'Target Amount',
                  variant: AppTextVariant.labelMedium,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppInput(
                  controller: targetController,
                  hint: '\$0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Icon Selection
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
                    Icons.savings,
                    Icons.flight,
                    Icons.home,
                    Icons.directions_car,
                    Icons.phone_iphone,
                    Icons.school,
                    Icons.celebration,
                    Icons.shield,
                  ].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = icon),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isSelected ? selectedColor.withValues(alpha: 0.1) : colors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected ? selectedColor : colors.borderSubtle,
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

                const SizedBox(height: AppSpacing.lg),

                // Auto-save toggle
                AppCard(
                  variant: AppCardVariant.subtle,
                  child: Row(
                    children: [
                      Icon(Icons.autorenew, color: colors.gold),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              'Auto-Save',
                              variant: AppTextVariant.labelMedium,
                              color: colors.textPrimary,
                            ),
                            AppText(
                              'Automatically save each month',
                              variant: AppTextVariant.bodySmall,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: autoSave,
                        onChanged: (value) => setModalState(() => autoSave = value),
                        activeColor: colors.gold,
                      ),
                    ],
                  ),
                ),

                if (autoSave) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppInput(
                    hint: 'Monthly amount',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      autoSaveAmount = double.tryParse(value) ?? 25;
                    },
                  ),
                ],

                const SizedBox(height: AppSpacing.xxl),

                AppButton(
                  label: 'Create Goal',
                  onPressed: () {
                    if (nameController.text.isNotEmpty && targetController.text.isNotEmpty) {
                      setState(() {
                        _goals.add(_SavingsGoal(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text,
                          targetAmount: double.tryParse(targetController.text) ?? 0,
                          savedAmount: 0,
                          icon: selectedIcon,
                          color: selectedColor,
                          deadline: DateTime.now().add(const Duration(days: 90)),
                          autoSaveEnabled: autoSave,
                          autoSaveAmount: autoSave ? autoSaveAmount : 0,
                        ));
                      });
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Goal created successfully!'),
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

  void _showGoalDetails(_SavingsGoal goal) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
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
                color: goal.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(goal.icon, color: goal.color, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              goal.name,
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDetailItem('Saved', '\$${goal.savedAmount.toStringAsFixed(2)}', colors),
                _buildDetailItem('Target', '\$${goal.targetAmount.toStringAsFixed(2)}', colors),
                _buildDetailItem('Progress', '${(goal.savedAmount / goal.targetAmount * 100).toStringAsFixed(0)}%', colors),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Add Funds',
                    onPressed: () {
                      Navigator.pop(context);
                      _showAddFundsSheet(goal);
                    },
                    variant: AppButtonVariant.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: 'Withdraw',
                    onPressed: () {
                      Navigator.pop(context);
                      _withdrawFromGoal(goal);
                    },
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteGoal(goal);
              },
              child: AppText(
                'Delete Goal',
                variant: AppTextVariant.labelMedium,
                color: context.colors.error,
              ),
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
          color: colors.gold,
        ),
        AppText(
          label,
          variant: AppTextVariant.labelSmall,
          color: colors.textSecondary,
        ),
      ],
    );
  }

  void _showAddFundsSheet(_SavingsGoal goal) {
    final colors = context.colors;
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.container,
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
              'Add to ${goal.name}',
              variant: AppTextVariant.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppInput(
              controller: amountController,
              hint: '\$0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              children: [10, 25, 50, 100].map((amount) {
                return GestureDetector(
                  onTap: () => amountController.text = amount.toString(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: colors.elevated,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: AppText(
                      '\$$amount',
                      variant: AppTextVariant.labelSmall,
                      color: colors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Add Funds',
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0;
                if (amount > 0) {
                  setState(() {
                    goal.savedAmount += amount;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('\$$amount added to ${goal.name}'),
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
    );
  }

  void _withdrawFromGoal(_SavingsGoal goal) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Withdraw feature coming soon'),
        backgroundColor: context.colors.info,
      ),
    );
  }

  void _deleteGoal(_SavingsGoal goal) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.container,
        title: const AppText('Delete Goal?', variant: AppTextVariant.titleMedium),
        content: AppText(
          'Are you sure you want to delete "${goal.name}"? Any saved funds will be returned to your wallet.',
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
              setState(() => _goals.removeWhere((g) => g.id == goal.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Goal deleted'),
                  backgroundColor: context.colors.info,
                ),
              );
            },
            child: AppText('Delete', color: context.colors.error),
          ),
        ],
      ),
    );
  }
}

class _SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  double savedAmount;
  final IconData icon;
  final Color color;
  final DateTime deadline;
  final bool autoSaveEnabled;
  final double autoSaveAmount;

  _SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.icon,
    required this.color,
    required this.deadline,
    required this.autoSaveEnabled,
    required this.autoSaveAmount,
  });
}
