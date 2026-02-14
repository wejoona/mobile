import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_provider.dart';
import 'package:usdc_wallet/features/onboarding/widgets/onboarding_progress.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Profile setup screen
class ProfileSetupView extends ConsumerStatefulWidget {
  const ProfileSetupView({super.key});

  @override
  ConsumerState<ProfileSetupView> createState() => _ProfileSetupViewState();
}

class _ProfileSetupViewState extends ConsumerState<ProfileSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(onboardingProvider);

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(AppSpacing.xl),
            children: [
              // Progress indicator
              const OnboardingProgress(currentStep: 3, totalSteps: 5),
              SizedBox(height: AppSpacing.xxl),
              AppText(
                l10n.onboarding_profile_title,
                style: AppTypography.headlineLarge,
              ),
              SizedBox(height: AppSpacing.sm),
              AppText(
                l10n.onboarding_profile_subtitle,
                style: AppTypography.bodyLarge.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              // First name
              AppInput(
                label: l10n.onboarding_profile_firstName,
                controller: _firstNameController,
                hint: l10n.onboarding_profile_firstNameHint,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.onboarding_profile_firstNameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Last name
              AppInput(
                label: l10n.onboarding_profile_lastName,
                controller: _lastNameController,
                hint: l10n.onboarding_profile_lastNameHint,
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.onboarding_profile_lastNameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.lg),
              // Email (optional)
              AppInput(
                label: l10n.onboarding_profile_email,
                controller: _emailController,
                hint: l10n.onboarding_profile_emailHint,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return l10n.onboarding_profile_emailInvalid;
                    }
                  }
                  return null;
                },
              ),
              if (state.error != null) ...[
                SizedBox(height: AppSpacing.lg),
                Container(
                  padding: EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: context.colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(color: context.colors.error),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: context.colors.error),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: AppText(
                          state.error!,
                          style: AppTypography.bodySmall.copyWith(
                            color: context.colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.action_continue,
                onPressed: _handleSubmit,
                isLoading: state.isLoading,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(onboardingProvider.notifier).updateProfile(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
    );

    await ref.read(onboardingProvider.notifier).submitProfile();

    if (mounted && ref.read(onboardingProvider).error == null) {
      context.go('/onboarding/pin');
    }
  }
}
