import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Full-screen maintenance mode view
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.construction,
                size: 80,
                color: context.colors.gold,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                'Maintenance en cours',
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'Korido est en cours de maintenance. Nous serons de retour très bientôt. Merci de votre patience.',
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppText(
                'Veuillez réessayer dans quelques minutes',
                variant: AppTextVariant.bodySmall,
                color: context.colors.textTertiary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
