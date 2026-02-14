import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Full-screen server error view for critical failures
class ServerErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const ServerErrorView({super.key, this.onRetry});

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
                Icons.cloud_off,
                size: 80,
                color: context.colors.error,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppText(
                'Erreur du serveur',
                variant: AppTextVariant.headlineMedium,
                color: context.colors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              AppText(
                'Nous rencontrons des difficultés techniques. Veuillez réessayer dans quelques instants.',
                variant: AppTextVariant.bodyLarge,
                color: context.colors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (onRetry != null)
                AppButton(
                  label: 'Réessayer',
                  onPressed: onRetry!,
                  isFullWidth: true,
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
