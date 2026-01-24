import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../state/index.dart';

/// KYC Document Type
enum KycDocumentType {
  nationalId,
  passport,
  driversLicense,
}

extension KycDocumentTypeExt on KycDocumentType {
  String get label {
    switch (this) {
      case KycDocumentType.nationalId:
        return 'National ID Card';
      case KycDocumentType.passport:
        return 'Passport';
      case KycDocumentType.driversLicense:
        return "Driver's License";
    }
  }

  IconData get icon {
    switch (this) {
      case KycDocumentType.nationalId:
        return Icons.credit_card;
      case KycDocumentType.passport:
        return Icons.menu_book;
      case KycDocumentType.driversLicense:
        return Icons.drive_eta;
    }
  }
}

class KycView extends ConsumerStatefulWidget {
  const KycView({super.key});

  @override
  ConsumerState<KycView> createState() => _KycViewState();
}

class _KycViewState extends ConsumerState<KycView> {
  int _currentStep = 0;
  KycDocumentType? _selectedDocType;
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _selfieUploaded = false;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userStateMachineProvider);

    // If already verified, show status
    if (userState.kycStatus == KycStatus.verified) {
      return _buildVerifiedView();
    }

    // If pending, show pending status
    if (userState.kycStatus == KycStatus.pending) {
      return _buildPendingView();
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressBar(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _buildCurrentStep(),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Document'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Photos'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Selfie'),
          Expanded(child: _buildStepLine(2)),
          _buildStepIndicator(3, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? AppColors.gold500
                : AppColors.elevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? AppColors.gold500 : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.obsidian, size: 18)
                : AppText(
                    '${step + 1}',
                    variant: AppTextVariant.labelMedium,
                    color: isCurrent ? AppColors.obsidian : AppColors.textTertiary,
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: isCurrent ? AppColors.gold500 : AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isCompleted = _currentStep > afterStep;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? AppColors.gold500 : AppColors.borderSubtle,
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildDocumentTypeStep();
      case 1:
        return _buildDocumentPhotosStep();
      case 2:
        return _buildSelfieStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildDocumentTypeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Select Document Type',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'Choose the type of government-issued ID you want to use for verification.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        ...KycDocumentType.values.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _DocumentTypeCard(
                type: type,
                isSelected: _selectedDocType == type,
                onTap: () => setState(() => _selectedDocType = type),
              ),
            )),
        const SizedBox(height: AppSpacing.lg),
        // Info
        AppCard(
          variant: AppCardVariant.subtle,
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.infoBase, size: 20),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Make sure your document is valid and not expired. We accept documents from most countries.',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPhotosStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Upload ${_selectedDocType?.label ?? "Document"} Photos',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'Take clear photos of the front and back of your document.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Front Photo
        _UploadCard(
          title: 'Front of Document',
          description: 'Photo of the front side showing your photo and details',
          isUploaded: _frontUploaded,
          onTap: () async {
            // TODO: Open camera/gallery
            setState(() => _frontUploaded = true);
          },
        ),
        const SizedBox(height: AppSpacing.md),
        // Back Photo
        _UploadCard(
          title: 'Back of Document',
          description: 'Photo of the back side of your ID',
          isUploaded: _backUploaded,
          onTap: () async {
            // TODO: Open camera/gallery
            setState(() => _backUploaded = true);
          },
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Tips
        const AppText(
          'Photo Tips',
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTip(Icons.wb_sunny, 'Use good lighting'),
        _buildTip(Icons.crop_free, 'Capture all corners'),
        _buildTip(Icons.blur_off, 'Avoid blur and glare'),
      ],
    );
  }

  Widget _buildSelfieStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Take a Selfie',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'We need a photo of your face to verify your identity matches your document.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Selfie Upload
        Center(
          child: GestureDetector(
            onTap: () {
              // TODO: Open front camera
              setState(() => _selfieUploaded = true);
            },
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.slate,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selfieUploaded ? AppColors.successBase : AppColors.borderSubtle,
                  width: 3,
                ),
              ),
              child: _selfieUploaded
                  ? const Icon(
                      Icons.check_circle,
                      color: AppColors.successBase,
                      size: 80,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          color: AppColors.textTertiary,
                          size: 48,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const AppText(
                          'Tap to take selfie',
                          variant: AppTextVariant.bodyMedium,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxxl),
        // Tips
        const AppText(
          'Selfie Tips',
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTip(Icons.face, 'Look directly at the camera'),
        _buildTip(Icons.wb_sunny, 'Ensure your face is well-lit'),
        _buildTip(Icons.close, 'No sunglasses or hats'),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Review & Submit',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'Please review your submission before submitting.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Summary
        _ReviewItem(
          icon: Icons.credit_card,
          label: 'Document Type',
          value: _selectedDocType?.label ?? 'Not selected',
        ),
        _ReviewItem(
          icon: Icons.photo,
          label: 'Front Photo',
          value: _frontUploaded ? 'Uploaded' : 'Missing',
          valueColor: _frontUploaded ? AppColors.successBase : AppColors.errorBase,
        ),
        _ReviewItem(
          icon: Icons.photo,
          label: 'Back Photo',
          value: _backUploaded ? 'Uploaded' : 'Missing',
          valueColor: _backUploaded ? AppColors.successBase : AppColors.errorBase,
        ),
        _ReviewItem(
          icon: Icons.face,
          label: 'Selfie',
          value: _selfieUploaded ? 'Uploaded' : 'Missing',
          valueColor: _selfieUploaded ? AppColors.successBase : AppColors.errorBase,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Disclaimer
        AppCard(
          variant: AppCardVariant.subtle,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'By submitting, you confirm that:',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: AppSpacing.md),
              _DisclaimerItem(text: 'The information provided is accurate'),
              _DisclaimerItem(text: 'The documents belong to you'),
              _DisclaimerItem(text: 'You agree to our Terms of Service'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold500, size: 20),
          const SizedBox(width: AppSpacing.sm),
          AppText(
            text,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: const BoxDecoration(
        color: AppColors.slate,
        border: Border(
          top: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: AppButton(
                  label: 'Back',
                  onPressed: () => setState(() => _currentStep--),
                  variant: AppButtonVariant.secondary,
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: AppButton(
                label: _currentStep == 3 ? 'Submit' : 'Continue',
                onPressed: _canProceed() ? _handleNext : null,
                variant: AppButtonVariant.primary,
                isLoading: _isSubmitting,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedDocType != null;
      case 1:
        return _frontUploaded && _backUploaded;
      case 2:
        return _selfieUploaded;
      case 3:
        return _frontUploaded && _backUploaded && _selfieUploaded;
      default:
        return false;
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      // Submit KYC
      setState(() => _isSubmitting = true);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Update status
      ref.read(userStateMachineProvider.notifier).updateProfile(
            kycStatus: KycStatus.pending,
          );

      setState(() => _isSubmitting = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC submitted successfully!'),
            backgroundColor: AppColors.successBase,
          ),
        );
        context.pop();
      }
    }
  }

  Widget _buildVerifiedView() {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.successBase.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: AppColors.successBase,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppText(
              'Identity Verified',
              variant: AppTextVariant.headlineSmall,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                'Your identity has been successfully verified. You can now use all features of JoonaPay.',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView() {
    return Scaffold(
      backgroundColor: AppColors.obsidian,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.warningBase.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top,
                color: AppColors.warningBase,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const AppText(
              'Verification In Progress',
              variant: AppTextVariant.headlineSmall,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                'We are reviewing your documents. This usually takes 1-2 business days. You will be notified once completed.',
                variant: AppTextVariant.bodyMedium,
                color: AppColors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentTypeCard extends StatelessWidget {
  const _DocumentTypeCard({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final KycDocumentType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold500.withValues(alpha: 0.1)
              : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.gold500 : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold500.withValues(alpha: 0.2)
                    : AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? AppColors.gold500 : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                type.label,
                variant: AppTextVariant.bodyLarge,
                color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.gold500),
          ],
        ),
      ),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.description,
    required this.isUploaded,
    required this.onTap,
  });

  final String title;
  final String description;
  final bool isUploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUploaded ? AppColors.successBase : AppColors.borderSubtle,
            width: isUploaded ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUploaded
                    ? AppColors.successBase.withValues(alpha: 0.2)
                    : AppColors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                isUploaded ? Icons.check : Icons.add_a_photo,
                color: isUploaded ? AppColors.successBase : AppColors.textTertiary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.bodyLarge,
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
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
            ),
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: AppColors.gold500, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
