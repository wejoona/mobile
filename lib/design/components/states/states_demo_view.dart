import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import 'index.dart';

/// Demo view showcasing all state components
/// Navigate to this view to see all states in action
///
/// Add to router:
/// ```dart
/// GoRoute(
///   path: '/design/states-demo',
///   builder: (context, state) => const StatesDemoView(),
/// )
/// ```
class StatesDemoView extends StatefulWidget {
  const StatesDemoView({super.key});

  @override
  State<StatesDemoView> createState() => _StatesDemoViewState();
}

class _StatesDemoViewState extends State<StatesDemoView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.obsidian : AppColorsLight.canvas,
      appBar: AppBar(
        title: const Text('State Components Demo'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              // Toggle theme in your app
            },
            tooltip: 'Toggle theme',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(isDark),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(bool isDark) {
    final tabs = ['Loading', 'Skeleton', 'Empty', 'Error'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate : AppColorsLight.container,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppColors.borderSubtle
                : AppColorsLight.borderSubtle,
          ),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: tabs.asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isSelected = _selectedTab == index;

            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedTab = index);
                },
                backgroundColor: isDark
                    ? AppColors.elevated
                    : AppColorsLight.elevated,
                selectedColor: isDark
                    ? AppColors.gold500
                    : AppColorsLight.gold500,
                labelStyle: TextStyle(
                  color: isSelected
                      ? (isDark
                          ? AppColors.textInverse
                          : AppColorsLight.textInverse)
                      : (isDark
                          ? AppColors.textPrimary
                          : AppColorsLight.textPrimary),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildLoadingTab();
      case 1:
        return _buildSkeletonTab();
      case 2:
        return _buildEmptyTab();
      case 3:
        return _buildErrorTab();
      default:
        return const SizedBox();
    }
  }

  Widget _buildLoadingTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          'Small Loading Indicator',
          const LoadingIndicator.small(),
        ),
        _buildSection(
          'Medium Loading Indicator (Default)',
          const LoadingIndicator(),
        ),
        _buildSection(
          'Large Loading Indicator',
          const LoadingIndicator.large(),
        ),
        _buildSection(
          'Custom Color',
          LoadingIndicator(color: AppColors.successBase),
        ),
        _buildSection(
          'In Button Context',
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: null,
              child: const LoadingIndicator.small(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          'Rectangle',
          SkeletonLoader.rectangle(
            width: double.infinity,
            height: 100,
          ),
        ),
        _buildSection(
          'Circle (Avatar)',
          const Align(
            alignment: Alignment.centerLeft,
            child: SkeletonLoader.circle(size: 60),
          ),
        ),
        _buildSection(
          'Text Lines',
          SkeletonPattern.text(lines: 4),
        ),
        _buildSection(
          'Transaction Item',
          SkeletonPattern.transaction(),
        ),
        _buildSection(
          'Balance Card',
          SkeletonPattern.balanceCard(),
        ),
        _buildSection(
          'Transaction List',
          SkeletonPattern.transactionList(count: 3),
        ),
      ],
    );
  }

  Widget _buildEmptyTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          'Basic Empty State',
          EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Items',
            description: 'There are no items to display',
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          'With Action Button',
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No Transactions',
            description: 'Your transaction history will appear here',
            action: EmptyStateAction(
              label: 'Send Money',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Send Money pressed')),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          'No Search Results',
          EmptyStateVariant.noSearchResults(
            title: 'No Results Found',
            description: 'Try adjusting your search terms',
            onClear: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Clear search pressed')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        _buildSection(
          'Basic Error State',
          ErrorState(
            title: 'Failed to Load',
            message: 'Something went wrong. Please try again.',
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry pressed')),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          'With Support Option',
          ErrorState.withSupport(
            title: 'Server Error',
            message: 'Unable to connect to our servers.',
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry pressed')),
              );
            },
            onContactSupport: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact support pressed')),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          'Network Error',
          ErrorState.network(
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry pressed')),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        _buildSection(
          'Inline Error',
          InlineError(
            message: 'Failed to save changes. Please try again.',
            onRetry: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Retry pressed')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleSmall.copyWith(
            color: isDark
                ? AppColors.textPrimary
                : AppColorsLight.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: isDark ? AppColors.slate : AppColorsLight.container,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark
                  ? AppColors.borderSubtle
                  : AppColorsLight.borderSubtle,
            ),
          ),
          child: child,
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}
