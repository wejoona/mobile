import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/onboarding/models/onboarding_page_data.dart';

/// Single onboarding page.
class OnboardingPage extends StatelessWidget {
  final OnboardingPageData data;
  final int index;
  final int total;

  const OnboardingPage({super.key, required this.data, required this.index, required this.total});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Image
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.xxl),
            ),
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.image_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.3)),
            ),
          ),
          const Spacer(),
          // Title
          AppText(
            data.title,
            variant: AppTextVariant.headlineSmall,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Description
          AppText(
            data.description,
            variant: AppTextVariant.bodyLarge,
            color: context.colors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
