import 'package:usdc_wallet/design/tokens/index.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/typography.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/app_card.dart';
import 'package:usdc_wallet/design/components/primitives/app_input.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';

enum AddressDocumentType {
  utilityBill,
  bankStatement,
  rentalAgreement,
  governmentLetter;

  String toApiString() {
    switch (this) {
      case AddressDocumentType.utilityBill:
        return 'utility_bill';
      case AddressDocumentType.bankStatement:
        return 'bank_statement';
      case AddressDocumentType.rentalAgreement:
        return 'rental_agreement';
      case AddressDocumentType.governmentLetter:
        return 'government_letter';
    }
  }
}

class KycAddressView extends ConsumerStatefulWidget {
  const KycAddressView({super.key});

  @override
  ConsumerState<KycAddressView> createState() => _KycAddressViewState();
}

class _KycAddressViewState extends ConsumerState<KycAddressView> {
  final _formKey = GlobalKey<FormState>();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'Côte d\'Ivoire');

  AddressDocumentType? _selectedDocumentType;
  String? _uploadedDocumentPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.canvas,
      appBar: AppBar(
        title: AppText(
          l10n.kyc_address_title,
          variant: AppTextVariant.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.md),
                  children: [
                    AppText(
                      l10n.kyc_address_description,
                      variant: AppTextVariant.bodyLarge,
                      color: context.colors.textSecondary,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    _buildAddressForm(l10n),
                    SizedBox(height: AppSpacing.xxl),
                    _buildDocumentTypeSelector(l10n),
                    if (_selectedDocumentType != null) ...[
                      SizedBox(height: AppSpacing.lg),
                      _buildDocumentUpload(l10n),
                    ],
                    SizedBox(height: AppSpacing.xxl),
                    _buildInfoCard(l10n),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.kyc_address_form_title,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.md),
        AppInput(
          label: l10n.kyc_address_addressLine1,
          controller: _addressLine1Controller,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.error_required;
            }
            return null;
          },
        ),
        SizedBox(height: AppSpacing.md),
        AppInput(
          label: l10n.kyc_address_addressLine2,
          controller: _addressLine2Controller,
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: AppInput(
                label: l10n.kyc_address_city,
                controller: _cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.error_required;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppInput(
                label: l10n.kyc_address_postalCode,
                controller: _postalCodeController,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        AppInput(
          label: l10n.kyc_address_state,
          controller: _stateController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return l10n.error_required;
            }
            return null;
          },
        ),
        SizedBox(height: AppSpacing.md),
        AppInput(
          label: l10n.kyc_address_country,
          controller: _countryController,
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildDocumentTypeSelector(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          l10n.kyc_address_proofDocument_title,
          variant: AppTextVariant.headlineSmall,
        ),
        SizedBox(height: AppSpacing.sm),
        AppText(
          l10n.kyc_address_proofDocument_description,
          variant: AppTextVariant.bodyMedium,
          color: context.colors.textSecondary,
        ),
        SizedBox(height: AppSpacing.md),
        ...AddressDocumentType.values.map((type) {
          final isSelected = _selectedDocumentType == type;
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDocumentType = type),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.charcoal : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? context.colors.gold : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      color: isSelected ? context.colors.gold : AppColors.silver,
                    ),
                    SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            _getDocumentTypeLabel(l10n, type),
                            variant: AppTextVariant.labelLarge,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          AppText(
                            _getDocumentTypeDescription(l10n, type),
                            variant: AppTextVariant.bodySmall,
                            color: context.colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDocumentUpload(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            l10n.kyc_address_uploadDocument,
            variant: AppTextVariant.labelLarge,
          ),
          SizedBox(height: AppSpacing.md),
          if (_uploadedDocumentPath != null) ...[
            _buildDocumentPreview(l10n),
            SizedBox(height: AppSpacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: _uploadedDocumentPath == null
                      ? l10n.kyc_address_takePhoto
                      : l10n.kyc_address_retakePhoto,
                  onPressed: _handleTakePhoto,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.camera_alt,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: _uploadedDocumentPath == null
                      ? l10n.kyc_address_chooseFile
                      : l10n.kyc_address_changeFile,
                  onPressed: _handleChooseFile,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.upload_file,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentPreview(AppLocalizations l10n) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.file(
            File(_uploadedDocumentPath!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: AppSpacing.sm,
          right: AppSpacing.sm,
          child: IconButton(
            onPressed: () => setState(() => _uploadedDocumentPath = null),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: context.colors.canvas.withOpacity(0.8),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(AppLocalizations l10n) {
    return AppCard(
      variant: AppCardVariant.subtle,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: context.colors.gold),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  l10n.kyc_address_info_title,
                  variant: AppTextVariant.labelMedium,
                ),
                SizedBox(height: AppSpacing.xs),
                AppText(
                  l10n.kyc_address_info_description,
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppLocalizations l10n) {
    final canSubmit = _formKey.currentState?.validate() == true &&
        _selectedDocumentType != null &&
        _uploadedDocumentPath != null;

    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        border: Border(
          top: BorderSide(color: AppColors.border),
        ),
      ),
      child: SafeArea(
        top: false,
        child: AppButton(
          label: l10n.kyc_address_submit,
          onPressed: canSubmit ? () => _handleSubmit(context, l10n) : null,
          isLoading: _isLoading,
          isFullWidth: true,
        ),
      ),
    );
  }

  Future<void> _handleTakePhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _uploadedDocumentPath = image.path);
    }
  }

  Future<void> _handleChooseFile() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() => _uploadedDocumentPath = image.path);
    }
  }

  Future<void> _handleSubmit(BuildContext context, AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDocumentType == null || _uploadedDocumentPath == null) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(kycProvider.notifier).submitAddressVerification({
            'addressLine1': _addressLine1Controller.text,
            'addressLine2': _addressLine2Controller.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'postalCode': _postalCodeController.text,
            'country': _countryController.text,
            'documentType': _selectedDocumentType!.toApiString(),
            'documentPath': _uploadedDocumentPath!,
          });

      if (!mounted) return;

      // Check if video verification is needed
      final state = ref.read(kycProvider);
      if (state.targetTier?.level == 3) {
        context.push('/kyc/video');
      } else {
        context.go('/kyc/submitted');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.kyc_address_error),
          backgroundColor: context.colors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getDocumentTypeLabel(AppLocalizations l10n, AddressDocumentType type) {
    switch (type) {
      case AddressDocumentType.utilityBill:
        return l10n.kyc_address_docType_utilityBill;
      case AddressDocumentType.bankStatement:
        return l10n.kyc_address_docType_bankStatement;
      case AddressDocumentType.rentalAgreement:
        return l10n.kyc_address_docType_rentalAgreement;
      case AddressDocumentType.governmentLetter:
        return l10n.kyc_address_docType_governmentLetter;
    }
  }

  String _getDocumentTypeDescription(AppLocalizations l10n, AddressDocumentType type) {
    switch (type) {
      case AddressDocumentType.utilityBill:
        return l10n.kyc_address_docType_utilityBill_description;
      case AddressDocumentType.bankStatement:
        return l10n.kyc_address_docType_bankStatement_description;
      case AddressDocumentType.rentalAgreement:
        return l10n.kyc_address_docType_rentalAgreement_description;
      case AddressDocumentType.governmentLetter:
        return l10n.kyc_address_docType_governmentLetter_description;
    }
  }
}
