import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/services/user/user_service.dart';

/// Minimal "What's your name?" screen shown after first login
/// when the user profile has no firstName set.
class ProfileCompleteView extends ConsumerStatefulWidget {
  const ProfileCompleteView({super.key});

  @override
  ConsumerState<ProfileCompleteView> createState() =>
      _ProfileCompleteViewState();
}

class _ProfileCompleteViewState extends ConsumerState<ProfileCompleteView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      await userService.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
      );

      // Update local state
      ref.read(userStateMachineProvider.notifier).updateName(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
          );

      HapticFeedback.mediumImpact();

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.xxl),

                // Welcome icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.gold,
                        colors.gold.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    Icons.person_outline_rounded,
                    color: colors.textInverse,
                    size: 32,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Title
                AppText(
                  l10n.onboarding_profile_title,
                  variant: AppTextVariant.headlineLarge,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppText(
                  l10n.onboarding_profile_subtitle,
                  variant: AppTextVariant.bodyLarge,
                  color: colors.textSecondary,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // First name
                AppInput(
                  label: l10n.onboarding_profile_firstName,
                  controller: _firstNameController,
                  hint: l10n.onboarding_profile_firstNameHint,
                  prefixIcon: Icons.person_outline,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.onboarding_profile_firstNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // Last name
                AppInput(
                  label: l10n.onboarding_profile_lastName,
                  controller: _lastNameController,
                  hint: l10n.onboarding_profile_lastNameHint,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.onboarding_profile_lastNameRequired;
                    }
                    return null;
                  },
                ),

                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: colors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: colors.error, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: AppText(
                            _error!,
                            variant: AppTextVariant.bodySmall,
                            color: colors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const Spacer(),

                // Continue button
                AppButton(
                  label: l10n.action_continue,
                  onPressed: _handleContinue,
                  isLoading: _isSubmitting,
                  isFullWidth: true,
                  variant: AppButtonVariant.primary,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/home'),
                    child: AppText(
                      l10n.action_skip,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textTertiary,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
