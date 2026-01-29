import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/account_type.dart';
import '../providers/business_provider.dart';

/// Business Setup View - initial setup for business account
class BusinessSetupView extends ConsumerStatefulWidget {
  const BusinessSetupView({super.key});

  @override
  ConsumerState<BusinessSetupView> createState() => _BusinessSetupViewState();
}

class _BusinessSetupViewState extends ConsumerState<BusinessSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _taxIdController = TextEditingController();

  BusinessType _selectedBusinessType = BusinessType.soleProprietor;

  @override
  void dispose() {
    _businessNameController.dispose();
    _registrationNumberController.dispose();
    _businessAddressController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final state = ref.watch(businessProvider);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.business_setupTitle,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              // Header
              AppText(
                l10n.business_setupDescription,
                variant: AppTextVariant.bodyLarge,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Business Name
              AppInput(
                label: l10n.business_businessName,
                controller: _businessNameController,
                keyboardType: TextInputType.text,
                validator: (v) => v?.isEmpty == true ? l10n.error_required : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Registration Number (Optional)
              AppInput(
                label: l10n.business_registrationNumber,
                controller: _registrationNumberController,
                keyboardType: TextInputType.text,
                helperText: l10n.common_optional,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Business Type
              AppText(
                l10n.business_businessType,
                variant: AppTextVariant.labelMedium,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.sm),
              AppSelect<BusinessType>(
                value: _selectedBusinessType,
                items: BusinessType.values,
                itemBuilder: (type) => type.displayName,
                onChanged: (type) {
                  if (type != null) {
                    setState(() => _selectedBusinessType = type);
                  }
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Business Address
              AppInput(
                label: l10n.business_businessAddress,
                controller: _businessAddressController,
                keyboardType: TextInputType.streetAddress,
                maxLines: 3,
                helperText: l10n.common_optional,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tax ID (Optional)
              AppInput(
                label: l10n.business_taxId,
                controller: _taxIdController,
                keyboardType: TextInputType.text,
                helperText: l10n.common_optional,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Info Box
              AppCard(
                variant: AppCardVariant.outlined,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colors.gold,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppText(
                        l10n.business_verificationNote,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Submit Button
              AppButton(
                label: l10n.business_completeSetup,
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

    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(businessProvider.notifier).saveBusinessProfile(
      businessName: _businessNameController.text.trim(),
      registrationNumber: _registrationNumberController.text.trim().isEmpty
          ? null
          : _registrationNumberController.text.trim(),
      businessType: _selectedBusinessType,
      businessAddress: _businessAddressController.text.trim().isEmpty
          ? null
          : _businessAddressController.text.trim(),
      taxId: _taxIdController.text.trim().isEmpty
          ? null
          : _taxIdController.text.trim(),
    );

    if (mounted) {
      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.business_setupSuccess),
            backgroundColor: AppColors.successBase,
          ),
        );
        // Navigate to business profile
        context.go('/settings/business-profile');
      } else {
        // Show error
        final error = ref.read(businessProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? l10n.error_generic),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }
}
