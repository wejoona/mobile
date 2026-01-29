import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';

class SubmittedView extends ConsumerWidget {
  const SubmittedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessAnimation(),
              SizedBox(height: AppSpacing.xl),
              AppText(
                l10n.kyc_submitted_title,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.md),
              AppText(
                l10n.kyc_submitted_description,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.infoBase.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.infoBase.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppColors.infoText,
                      size: 24,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        l10n.kyc_submitted_timeEstimate,
                        variant: AppTextVariant.bodyMedium,
                        color: AppColors.infoText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: l10n.action_done,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.successBase.withOpacity(0.1),
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: AppColors.successBase,
            ),
          ),
        );
      },
    );
  }
}
