import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          // Image
          Container(
            height: 280,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Image.asset(
              data.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(Icons.image_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.3)),
            ),
          ),
          const Spacer(),
          // Title
          Text(
            data.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Description
          Text(
            data.description,
            style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const Spacer(flex: 2),
        ],
      ),
    );
  }
}
