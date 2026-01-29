import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../state/index.dart';

/// Time period for analytics
enum AnalyticsPeriod {
  week,
  month,
  quarter,
  year,
}

extension AnalyticsPeriodExt on AnalyticsPeriod {
  String get label {
    switch (this) {
      case AnalyticsPeriod.week:
        return '7 Days';
      case AnalyticsPeriod.month:
        return '30 Days';
      case AnalyticsPeriod.quarter:
        return '90 Days';
      case AnalyticsPeriod.year:
        return '1 Year';
    }
  }
}

/// Category for spending
class SpendingCategory {
  final String name;
  final IconData icon;
  final Color color;
  final double amount;
  final double percentage;
  final int count;

  const SpendingCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
    required this.count,
  });
}

class AnalyticsView extends ConsumerStatefulWidget {
  const AnalyticsView({super.key});

  @override
  ConsumerState<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends ConsumerState<AnalyticsView> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  // Mock analytics data
  double get _totalIncome => 2450.00;
  double get _totalExpenses => 1875.50;
  double get _netChange => _totalIncome - _totalExpenses;

  List<SpendingCategory> get _categories => [
        SpendingCategory(
          name: 'Transfers',
          icon: Icons.send,
          color: const Color(0xFF4CAF50),
          amount: 850.00,
          percentage: 45.3,
          count: 12,
        ),
        SpendingCategory(
          name: 'Withdrawals',
          icon: Icons.arrow_upward,
          color: const Color(0xFFF44336),
          amount: 500.00,
          percentage: 26.7,
          count: 4,
        ),
        SpendingCategory(
          name: 'Bills',
          icon: Icons.receipt,
          color: const Color(0xFF2196F3),
          amount: 325.50,
          percentage: 17.4,
          count: 6,
        ),
        SpendingCategory(
          name: 'Other',
          icon: Icons.more_horiz,
          color: const Color(0xFF9E9E9E),
          amount: 200.00,
          percentage: 10.6,
          count: 3,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Analytics',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _exportReport,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Period Selector
            _buildPeriodSelector(),

            const SizedBox(height: AppSpacing.xxl),

            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Income',
                    amount: _totalIncome,
                    icon: Icons.arrow_downward,
                    iconColor: AppColors.successBase,
                    trend: '+12.5%',
                    trendPositive: true,
                    colors: colors,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _StatCard(
                    label: 'Expenses',
                    amount: _totalExpenses,
                    icon: Icons.arrow_upward,
                    iconColor: AppColors.errorBase,
                    trend: '-5.2%',
                    trendPositive: true,
                    colors: colors,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Net Change Card
            _buildNetChangeCard(),

            const SizedBox(height: AppSpacing.xxl),

            // Spending Chart (simplified bar representation)
            AppText(
              'Spending by Category',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSpendingChart(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Category Breakdown
            AppText(
              'Category Details',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            ..._categories.map((category) => _CategoryCard(category: category, colors: colors)),

            const SizedBox(height: AppSpacing.xxl),

            // Transaction Frequency
            AppText(
              'Transaction Frequency',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildFrequencyChart(colors),

            const SizedBox(height: AppSpacing.xxl),

            // Insights
            AppText(
              'Insights',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildInsights(colors),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final colors = context.colors;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: AnalyticsPeriod.values.map((period) {
          final isSelected = _selectedPeriod == period;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = period),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? colors.gold : colors.container,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: isSelected ? colors.gold : colors.borderSubtle,
                  ),
                ),
                child: AppText(
                  period.label,
                  variant: AppTextVariant.labelMedium,
                  color: isSelected ? colors.canvas : colors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNetChangeCard() {
    final isPositive = _netChange >= 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [const Color(0xFFB71C1C), const Color(0xFFC62828)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Icon(
              isPositive ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  'Net Change',
                  variant: AppTextVariant.bodyMedium,
                  color: Colors.white70,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  '${isPositive ? '+' : ''}\$${_netChange.abs().toStringAsFixed(2)}',
                  variant: AppTextVariant.headlineSmall,
                  color: Colors.white,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xxs),
                AppText(
                  isPositive ? 'Surplus' : 'Deficit',
                  variant: AppTextVariant.labelSmall,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingChart(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        children: [
          // Horizontal bar chart
          ..._categories.map((category) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            AppText(
                              category.name,
                              variant: AppTextVariant.bodyMedium,
                              color: colors.textPrimary,
                            ),
                          ],
                        ),
                        AppText(
                          '${category.percentage.toStringAsFixed(1)}%',
                          variant: AppTextVariant.labelMedium,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: colors.elevated,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: category.percentage / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: category.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildFrequencyChart(ThemeColors colors) {
    // Mock weekly data
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [3, 5, 2, 8, 4, 6, 1];
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final height = (values[index] / maxValue) * 100;
          return Column(
            children: [
              Container(
                width: 32,
                height: height,
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.3 + (values[index] / maxValue) * 0.7),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              AppText(
                weekDays[index],
                variant: AppTextVariant.labelSmall,
                color: colors.textTertiary,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildInsights(ThemeColors colors) {
    return Column(
      children: [
        _InsightCard(
          icon: Icons.trending_up,
          iconColor: AppColors.successBase,
          title: 'Spending Down',
          description: 'Your spending is 5.2% lower than last month. Great job!',
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          icon: Icons.savings,
          iconColor: colors.gold,
          title: 'Savings Opportunity',
          description: 'You could save \$50/month by reducing withdrawal fees.',
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),
        _InsightCard(
          icon: Icons.schedule,
          iconColor: AppColors.infoBase,
          title: 'Peak Activity',
          description: 'Most of your transactions happen on Thursdays.',
          colors: colors,
        ),
      ],
    );
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting report...'),
        backgroundColor: AppColors.infoBase,
      ),
    );
    // TODO: Implement actual export
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.trend,
    required this.trendPositive,
    required this.colors,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final String trend;
  final bool trendPositive;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: trendPositive
                      ? AppColors.successBase.withValues(alpha: 0.2)
                      : AppColors.errorBase.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  trend,
                  variant: AppTextVariant.labelSmall,
                  color: trendPositive ? AppColors.successBase : AppColors.errorBase,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            label,
            variant: AppTextVariant.bodySmall,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.xxs),
          AppText(
            '\$${amount.toStringAsFixed(2)}',
            variant: AppTextVariant.titleLarge,
            color: colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.colors});

  final SpendingCategory category;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.2),
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
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textPrimary,
                ),
                AppText(
                  '${category.count} transactions',
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
                '\$${category.amount.toStringAsFixed(2)}',
                variant: AppTextVariant.titleMedium,
                color: colors.textPrimary,
              ),
              AppText(
                '${category.percentage.toStringAsFixed(1)}%',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.colors,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.elevated,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  description,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
