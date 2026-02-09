import 'package:flutter/material.dart';
import 'package:usdc_wallet/catalog/widget_catalog_view.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

class SkeletonCatalog extends StatelessWidget {
  const SkeletonCatalog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatalogSection(
          title: 'Basic Shapes',
          description: 'Simple skeleton loading indicators',
          children: [
            DemoCard(
              label: 'Rectangle',
              child: const AppSkeleton(
                width: double.infinity,
                height: 60,
              ),
            ),
            DemoCard(
              label: 'Square',
              child: const AppSkeleton(
                width: 100,
                height: 100,
              ),
            ),
            DemoCard(
              label: 'Circle',
              child: const AppSkeleton.circle(
                size: 80,
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Common Patterns',
          description: 'Pre-built skeleton patterns for common UI elements',
          children: [
            DemoCard(
              label: 'List Item',
              child: SkeletonLayouts.listItem(),
            ),
            DemoCard(
              label: 'Transaction Item',
              child: SkeletonLayouts.transactionItem(),
            ),
            DemoCard(
              label: 'Balance Card',
              child: SkeletonLayouts.balanceCard(context),
            ),
            DemoCard(
              label: 'Card',
              child: const AppSkeleton.card(),
            ),
            DemoCard(
              label: 'Text Line',
              child: const AppSkeleton.text(width: 200),
            ),
          ],
        ),
        CatalogSection(
          title: 'Custom Layouts',
          description: 'Compose skeletons for complex layouts',
          children: [
            DemoCard(
              label: 'Profile Header',
              child: Row(
                children: [
                  const AppSkeleton.circle(size: 60),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(
                          width: double.infinity,
                          height: 20,
                          borderRadius: AppRadius.sm,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppSkeleton(
                          width: 150,
                          height: 16,
                          borderRadius: AppRadius.sm,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            DemoCard(
              label: 'Transaction List',
              child: Column(
                children: List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index < 2 ? AppSpacing.md : 0,
                    ),
                    child: Row(
                      children: [
                        const AppSkeleton.circle(size: 40),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppSkeleton(
                                width: double.infinity,
                                height: 16,
                                borderRadius: AppRadius.sm,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              AppSkeleton(
                                width: 100,
                                height: 14,
                                borderRadius: AppRadius.sm,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        AppSkeleton(
                          width: 80,
                          height: 16,
                          borderRadius: AppRadius.sm,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            DemoCard(
              label: 'Card Grid',
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.md,
                crossAxisSpacing: AppSpacing.md,
                childAspectRatio: 1.5,
                children: List.generate(
                  4,
                  (index) => AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSkeleton(
                          width: double.infinity,
                          height: 16,
                          borderRadius: AppRadius.sm,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        AppSkeleton(
                          width: 60,
                          height: 14,
                          borderRadius: AppRadius.sm,
                        ),
                        const Spacer(),
                        AppSkeleton(
                          width: double.infinity,
                          height: 20,
                          borderRadius: AppRadius.sm,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        CatalogSection(
          title: 'Animation',
          description: 'Animated shimmer effect demonstrates loading state',
          children: [
            DemoCard(
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Shimmer Animation',
                      variant: AppTextVariant.titleMedium,
                      color: colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const AppSkeleton(
                      width: double.infinity,
                      height: 100,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    AppText(
                      'Watch the shimmer effect animate across the skeleton',
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
