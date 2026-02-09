import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/theme_colors.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';

class SubmittedView extends ConsumerWidget {
  const SubmittedView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              _buildSuccessAnimation(context),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.kyc_submitted_title,
                variant: AppTextVariant.headlineMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.lg),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: AppText(
                  l10n.kyc_submitted_description,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: colors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: colors.infoText,
                      size: 28,
                    ),
                    SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: AppText(
                        l10n.kyc_submitted_timeEstimate,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.infoText,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: l10n.common_done,
                onPressed: () => context.go('/home'),
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation(BuildContext context) {
    final colors = context.colors;
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
              color: colors.success.withOpacity(0.1),
            ),
            child: Icon(
              Icons.check_circle,
              size: 64,
              color: colors.success,
            ),
          ),
        );
      },
    );
  }
}
