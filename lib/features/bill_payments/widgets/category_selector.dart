import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/bill_payments/bill_payments_service.dart';

/// Bill Category Selector Widget
/// Displays categories as horizontal scrollable chips or grid
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
    this.showGrid = false,
  });

  final List<CategoryInfo> categories;
  final BillCategory? selectedCategory;
  final ValueChanged<BillCategory?> onCategorySelected;
  final bool showGrid;

  @override
  Widget build(BuildContext context) {
    if (showGrid) {
      return _buildGrid();
    }
    return _buildHorizontalList();
  }

  Widget _buildHorizontalList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          // All option
          _CategoryChip(
            label: 'All',
            icon: Icons.apps,
            isSelected: selectedCategory == null,
            onTap: () => onCategorySelected(null),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Category chips
          ...categories.map((category) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _CategoryChip(
                  label: category.displayName,
                  icon: _getIconData(category.icon),
                  isSelected: selectedCategory == category.category,
                  onTap: () => onCategorySelected(category.category),
                  badge: category.providerCount > 0 ? category.providerCount : null,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryGridItem(
          category: category,
          isSelected: selectedCategory == category.category,
          onTap: () => onCategorySelected(category.category),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'tv':
        return Icons.tv;
      case 'phone_android':
        return Icons.phone_android;
      case 'security':
        return Icons.security;
      case 'school':
        return Icons.school;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.receipt_long;
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? colors.canvas : colors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            AppText(
              label,
              variant: AppTextVariant.labelMedium,
              color: isSelected ? colors.canvas : colors.textPrimary,
            ),
            if (badge != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colors.canvas.withOpacity(0.2)
                      : colors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: AppText(
                  '$badge',
                  variant: AppTextVariant.labelSmall,
                  color: isSelected ? colors.canvas : colors.gold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryInfo category;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withOpacity(0.1) : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.gold
                    : colors.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _getIconData(category.icon),
                size: 24,
                color: isSelected ? colors.canvas : colors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AppText(
                category.displayName,
                variant: AppTextVariant.labelSmall,
                color: isSelected ? colors.gold : colors.textSecondary,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'water_drop':
        return Icons.water_drop;
      case 'wifi':
        return Icons.wifi;
      case 'tv':
        return Icons.tv;
      case 'phone_android':
        return Icons.phone_android;
      case 'security':
        return Icons.security;
      case 'school':
        return Icons.school;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.receipt_long;
    }
  }
}
