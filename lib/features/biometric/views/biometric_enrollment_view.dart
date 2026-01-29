import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/biometric/biometric_service.dart';

/// Biometric Enrollment View
/// Shows benefits and guides user through biometric setup
class BiometricEnrollmentView extends ConsumerStatefulWidget {
  const BiometricEnrollmentView({
    super.key,
    this.isOptional = true,
    this.onComplete,
  });

  final bool isOptional;
  final VoidCallback? onComplete;

  @override
  ConsumerState<BiometricEnrollmentView> createState() =>
      _BiometricEnrollmentViewState();
}

class _BiometricEnrollmentViewState
    extends ConsumerState<BiometricEnrollmentView> {
  bool _isEnrolling = false;
  bool _showSuccess = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_showSuccess) {
      return _buildSuccessView(l10n);
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: widget.isOptional
            ? IconButton(
                icon: const Icon(Icons.close, color: AppColors.gold500),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Biometric Icon
                      _buildBiometricIcon(),
                      const SizedBox(height: AppSpacing.xl),

                      // Title
                      AppText(
                        l10n.biometric_enrollment_title,
                        variant: AppTextVariant.headlineMedium,
                        color: AppColors.textPrimary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Subtitle
                      AppText(
                        l10n.biometric_enrollment_subtitle,
                        variant: AppTextVariant.bodyLarge,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Benefits
                      _buildBenefits(l10n),
                    ],
                  ),
                ),
              ),

              // Actions
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.biometric_enrollment_enable,
                onPressed: _handleEnroll,
                isLoading: _isEnrolling,
                isFullWidth: true,
              ),
              if (widget.isOptional) ...[
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: l10n.biometric_enrollment_skip,
                  onPressed: _handleSkip,
                  variant: AppButtonVariant.ghost,
                  isFullWidth: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiometricIcon() {
    final biometricType = ref.watch(primaryBiometricTypeProvider);

    return biometricType.when(
      data: (type) {
        IconData icon;
        Color color;

        switch (type) {
          case BiometricType.faceId:
            icon = Icons.face;
            color = AppColors.gold500;
            break;
          case BiometricType.fingerprint:
            icon = Icons.fingerprint;
            color = AppColors.gold500;
            break;
          case BiometricType.iris:
            icon = Icons.visibility;
            color = AppColors.gold500;
            break;
          case BiometricType.none:
            icon = Icons.security;
            color = AppColors.textSecondary;
            break;
        }

        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 64, color: color),
        );
      },
      loading: () => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.gold500.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const CircularProgressIndicator(),
      ),
      error: (_, __) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.security, size: 64, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildBenefits(AppLocalizations l10n) {
    final benefits = [
      {
        'icon': Icons.flash_on,
        'title': l10n.biometric_enrollment_benefit_fast_title,
        'description': l10n.biometric_enrollment_benefit_fast_desc,
      },
      {
        'icon': Icons.shield,
        'title': l10n.biometric_enrollment_benefit_secure_title,
        'description': l10n.biometric_enrollment_benefit_secure_desc,
      },
      {
        'icon': Icons.verified_user,
        'title': l10n.biometric_enrollment_benefit_convenient_title,
        'description': l10n.biometric_enrollment_benefit_convenient_desc,
      },
    ];

    return Column(
      children: benefits
          .map((benefit) => _buildBenefitCard(
                icon: benefit['icon'] as IconData,
                title: benefit['title'] as String,
                description: benefit['description'] as String,
              ))
          .toList(),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: AppCard(
        variant: AppCardVariant.subtle,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold500.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.gold500, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.titleSmall,
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    description,
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success Animation
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.successBase.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 80,
                  color: AppColors.successBase,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Success Title
              AppText(
                l10n.biometric_enrollment_success_title,
                variant: AppTextVariant.headlineMedium,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),

              // Success Message
              AppText(
                l10n.biometric_enrollment_success_message,
                variant: AppTextVariant.bodyLarge,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Continue Button
              AppButton(
                label: l10n.action_continue,
                onPressed: () {
                  widget.onComplete?.call();
                  context.pop(true);
                },
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleEnroll() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isEnrolling = true);

    try {
      final biometricService = ref.read(biometricServiceProvider);

      // Check if biometric is available
      final isAvailable = await biometricService.canCheckBiometrics();
      if (!isAvailable && mounted) {
        _showError(l10n.biometric_enrollment_error_not_available);
        return;
      }

      // Authenticate to verify biometric works
      final authenticated = await biometricService.authenticate(
        reason: l10n.biometric_enrollment_authenticate_reason,
      );

      if (authenticated) {
        // Enable biometric
        await biometricService.enableBiometric();

        // Invalidate providers to refresh UI
        ref.invalidate(biometricEnabledProvider);

        if (mounted) {
          setState(() => _showSuccess = true);
        }
      } else if (mounted) {
        _showError(l10n.biometric_enrollment_error_failed);
      }
    } catch (e) {
      if (mounted) {
        _showError(l10n.biometric_enrollment_error_generic);
      }
    } finally {
      if (mounted) {
        setState(() => _isEnrolling = false);
      }
    }
  }

  Future<void> _handleSkip() async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.slate,
        title: AppText(
          l10n.biometric_enrollment_skip_confirm_title,
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        content: AppText(
          l10n.biometric_enrollment_skip_confirm_message,
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        actions: [
          AppButton(
            label: l10n.action_cancel,
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.ghost,
            size: AppButtonSize.small,
          ),
          AppButton(
            label: l10n.biometric_enrollment_skip,
            onPressed: () => Navigator.pop(context, true),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      widget.onComplete?.call();
      context.pop(false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorBase,
      ),
    );
  }
}
