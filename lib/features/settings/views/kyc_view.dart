import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../domain/enums/index.dart';
import '../../../state/index.dart';
import '../../../services/api/api_client.dart';
import '../../../services/liveness/liveness_service.dart';
import '../../liveness/widgets/liveness_check_widget.dart';
import '../../../config/countries.dart';

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
  bool _isSubmitting = false;

  // Image files
  File? _frontImage;
  File? _backImage;
  File? _selfieImage;

  // Uploaded document keys (from S3)
  String? _frontDocKey;
  String? _backDocKey;
  String? _selfieDocKey;

  // Liveness check state
  bool _livenessCheckPassed = false;
  String? _livenessSessionId;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  // Form controllers for personal information
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _idNumberController;

  // Form data
  DateTime? _dateOfBirth;
  CountryConfig? _selectedCountry;
  String _selectedIdType = 'national_id';

  bool get _frontUploaded => _frontImage != null;
  bool get _backUploaded => _backImage != null;
  bool get _selfieUploaded => _selfieImage != null;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with empty values
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _idNumberController = TextEditingController();

    // Populate controllers and country after first frame using post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userState = ref.read(userStateMachineProvider);
        _firstNameController.text = userState.firstName ?? '';
        _lastNameController.text = userState.lastName ?? '';

        // Set default country based on user's country code
        setState(() {
          _selectedCountry = SupportedCountries.findByCodeIncludingDisabled(userState.countryCode);
          _selectedCountry ??= SupportedCountries.defaultCountry;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

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
          _buildStepIndicator(0, 'Info'),
          Expanded(child: _buildStepLine(0)),
          _buildStepIndicator(1, 'Document'),
          Expanded(child: _buildStepLine(1)),
          _buildStepIndicator(2, 'Photos'),
          Expanded(child: _buildStepLine(2)),
          _buildStepIndicator(3, 'Selfie'),
          Expanded(child: _buildStepLine(3)),
          _buildStepIndicator(4, 'Review'),
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
        return _buildPersonalInfoStep();
      case 1:
        return _buildDocumentTypeStep();
      case 2:
        return _buildDocumentPhotosStep();
      case 3:
        return _buildSelfieStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'Personal Information',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'Please provide your personal details as they appear on your ID document.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // First Name
        AppInput(
          label: 'First Name',
          controller: _firstNameController,
          hint: 'Enter your first name',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: AppSpacing.md),

        // Last Name
        AppInput(
          label: 'Last Name',
          controller: _lastNameController,
          hint: 'Enter your last name',
          keyboardType: TextInputType.name,
        ),
        const SizedBox(height: AppSpacing.md),

        // Date of Birth
        GestureDetector(
          onTap: _selectDateOfBirth,
          child: AbsorbPointer(
            child: AppInput(
              label: 'Date of Birth',
              controller: TextEditingController(
                text: _dateOfBirth != null
                    ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
                    : '',
              ),
              hint: 'Select your date of birth',
              suffixIcon: Icons.calendar_today,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Country
        _buildCountryDropdown(),
        const SizedBox(height: AppSpacing.md),

        // ID Type
        _buildIdTypeDropdown(),
        const SizedBox(height: AppSpacing.md),

        // ID Number
        AppInput(
          label: 'ID Number',
          controller: _idNumberController,
          hint: 'Enter your ID number',
          keyboardType: TextInputType.text,
        ),

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
                  'Your information must match the ID document you will upload in the next steps.',
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
          imageFile: _frontImage,
          onTap: () => _showImageSourceDialog('front'),
        ),
        const SizedBox(height: AppSpacing.md),
        // Back Photo
        _UploadCard(
          title: 'Back of Document',
          description: 'Photo of the back side of your ID',
          isUploaded: _backUploaded,
          imageFile: _backImage,
          onTap: () => _showImageSourceDialog('back'),
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
          'Liveness Check & Selfie',
          variant: AppTextVariant.titleMedium,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        const AppText(
          'Complete a liveness check to verify you are a real person, then take a selfie.',
          variant: AppTextVariant.bodyMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Liveness check status
        if (!_livenessCheckPassed)
          AppCard(
            variant: AppCardVariant.subtle,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.infoBase.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
                        color: AppColors.infoBase,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Liveness Check Required',
                            variant: AppTextVariant.bodyLarge,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(height: AppSpacing.xxs),
                          AppText(
                            'Follow on-screen instructions',
                            variant: AppTextVariant.bodySmall,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: 'Start Liveness Check',
                  onPressed: _startLivenessCheck,
                  variant: AppButtonVariant.primary,
                ),
              ],
            ),
          ),

        if (_livenessCheckPassed) ...[
          // Liveness check passed indicator
          AppCard(
            variant: AppCardVariant.subtle,
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.successBase.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: AppColors.successBase,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Liveness Check Passed',
                        variant: AppTextVariant.bodyLarge,
                        color: AppColors.textPrimary,
                      ),
                      SizedBox(height: AppSpacing.xxs),
                      AppText(
                        'You can now take your selfie',
                        variant: AppTextVariant.bodySmall,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Selfie Upload (only after liveness check passes)
          Center(
            child: GestureDetector(
              onTap: () => _takeSelfie(),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.slate,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selfieUploaded
                        ? AppColors.successBase
                        : AppColors.borderSubtle,
                    width: 3,
                  ),
                ),
                child: _selfieUploaded && _selfieImage != null
                    ? ClipOval(
                        child: Image.file(
                          _selfieImage!,
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
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

        // Personal Information Section
        const AppText(
          'Personal Information',
          variant: AppTextVariant.labelLarge,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewItem(
          icon: Icons.person,
          label: 'Full Name',
          value: '${_firstNameController.text} ${_lastNameController.text}',
        ),
        _ReviewItem(
          icon: Icons.cake,
          label: 'Date of Birth',
          value: _dateOfBirth != null
              ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
              : 'Not set',
          valueColor: _dateOfBirth != null ? AppColors.textPrimary : AppColors.errorBase,
        ),
        _ReviewItem(
          icon: Icons.public,
          label: 'Country',
          value: _selectedCountry?.name ?? 'Not selected',
        ),
        _ReviewItem(
          icon: Icons.badge,
          label: 'ID Type',
          value: _getIdTypeName(_selectedIdType),
        ),
        _ReviewItem(
          icon: Icons.numbers,
          label: 'ID Number',
          value: _idNumberController.text.isNotEmpty
              ? _idNumberController.text
              : 'Not provided',
          valueColor: _idNumberController.text.isNotEmpty
              ? AppColors.textPrimary
              : AppColors.errorBase,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Documents Section
        const AppText(
          'Documents',
          variant: AppTextVariant.labelLarge,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
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

  String _getIdTypeName(String idType) {
    switch (idType) {
      case 'passport':
        return 'Passport';
      case 'national_id':
        return 'National ID';
      case 'drivers_license':
        return "Driver's License";
      default:
        return idType;
    }
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
                label: _currentStep == 4 ? 'Submit' : 'Continue',
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
        // Personal info step
        return _firstNameController.text.isNotEmpty &&
            _lastNameController.text.isNotEmpty &&
            _dateOfBirth != null &&
            _selectedCountry != null &&
            _idNumberController.text.isNotEmpty &&
            _isValidAge();
      case 1:
        return _selectedDocType != null;
      case 2:
        return _frontUploaded && _backUploaded;
      case 3:
        return _livenessCheckPassed && _selfieUploaded;
      case 4:
        return _frontUploaded && _backUploaded && _selfieUploaded && _livenessCheckPassed;
      default:
        return false;
    }
  }

  bool _isValidAge() {
    if (_dateOfBirth == null) return false;
    final age = DateTime.now().difference(_dateOfBirth!).inDays ~/ 365;
    return age >= 18;
  }

  Widget _buildCountryDropdown() {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: AbsorbPointer(
        child: AppInput(
          label: 'Country',
          controller: TextEditingController(
            text: _selectedCountry?.name ?? '',
          ),
          hint: 'Select your country',
          suffixIcon: Icons.arrow_drop_down,
        ),
      ),
    );
  }

  Widget _buildIdTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppText(
          'ID Type',
          variant: AppTextVariant.labelMedium,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.slate,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButton<String>(
            value: _selectedIdType,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: AppColors.slate,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            items: const [
              DropdownMenuItem(
                value: 'national_id',
                child: AppText('National ID', variant: AppTextVariant.bodyMedium),
              ),
              DropdownMenuItem(
                value: 'passport',
                child: AppText('Passport', variant: AppTextVariant.bodyMedium),
              ),
              DropdownMenuItem(
                value: 'drivers_license',
                child: AppText("Driver's License", variant: AppTextVariant.bodyMedium),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedIdType = value);
              }
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);
    final hundredYearsAgo = DateTime(now.year - 100, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? eighteenYearsAgo,
      firstDate: hundredYearsAgo,
      lastDate: eighteenYearsAgo,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.gold500,
              onPrimary: AppColors.obsidian,
              surface: AppColors.slate,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _dateOfBirth = date);
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const AppText(
                'Select Country',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
            ),
            const Divider(color: AppColors.borderSubtle),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: SupportedCountries.allIncludingDisabled.length,
                itemBuilder: (context, index) {
                  final country = SupportedCountries.allIncludingDisabled[index];
                  final isSelected = _selectedCountry?.code == country.code;

                  return ListTile(
                    leading: AppText(
                      country.flag,
                      variant: AppTextVariant.titleMedium,
                    ),
                    title: AppText(
                      country.name,
                      variant: AppTextVariant.bodyMedium,
                      color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.gold500)
                        : null,
                    onTap: () {
                      setState(() => _selectedCountry = country);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to choose between camera and gallery
  void _showImageSourceDialog(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slate,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                'Choose Image Source',
                variant: AppTextVariant.titleMedium,
                color: AppColors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, type);
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _SourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, type);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source, String type) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          switch (type) {
            case 'front':
              _frontImage = File(image.path);
              break;
            case 'back':
              _backImage = File(image.path);
              break;
            case 'selfie':
              _selfieImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  /// Start liveness check before selfie
  Future<void> _startLivenessCheck() async {
    final result = await showDialog<LivenessResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: LivenessCheckWidget(
          purpose: 'kyc',
          onCancel: () => Navigator.of(context).pop(),
          onComplete: (result) => Navigator.of(context).pop(result),
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: AppColors.errorBase,
              ),
            );
          },
        ),
      ),
    );

    if (result != null && result.isLive) {
      setState(() {
        _livenessCheckPassed = true;
        _livenessSessionId = result.sessionId;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Liveness check passed! You can now take your selfie.'),
            backgroundColor: AppColors.successBase,
          ),
        );
      }
    } else if (result != null && !result.isLive) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Liveness check failed: ${result.failureReason ?? "Please try again"}'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  /// Take selfie with front camera (only after liveness check passes)
  Future<void> _takeSelfie() async {
    if (!_livenessCheckPassed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete liveness check first'),
          backgroundColor: AppColors.warningBase,
        ),
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selfieImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to take selfie: $e'),
            backgroundColor: AppColors.errorBase,
          ),
        );
      }
    }
  }

  /// Upload all documents to the backend
  Future<void> _uploadDocuments() async {
    if (_frontImage == null || _backImage == null || _selfieImage == null) {
      throw Exception('All documents are required');
    }

    final dio = ref.read(dioProvider);

    final formData = FormData.fromMap({
      'idFront': await MultipartFile.fromFile(
        _frontImage!.path,
        filename: 'id_front.jpg',
      ),
      'idBack': await MultipartFile.fromFile(
        _backImage!.path,
        filename: 'id_back.jpg',
      ),
      'selfie': await MultipartFile.fromFile(
        _selfieImage!.path,
        filename: 'selfie.jpg',
      ),
    });

    final response = await dio.post(
      '/kyc/documents',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );

    if (response.data != null && response.data['documents'] != null) {
      final docs = response.data['documents'];
      _frontDocKey = docs['idFront']?['key'];
      _backDocKey = docs['idBack']?['key'];
      _selfieDocKey = docs['selfie']?['key'];
    }
  }

  Future<void> _handleNext() async {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      // Submit KYC
      setState(() => _isSubmitting = true);

      try {
        // First, upload all documents
        await _uploadDocuments();

        // Then submit KYC form with document keys
        await _submitKycData();

        // Update local status
        ref.read(userStateMachineProvider.notifier).updateProfile(
              kycStatus: KycStatus.pending,
            );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('KYC submitted successfully!'),
              backgroundColor: AppColors.successBase,
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit KYC: ${e.toString()}'),
              backgroundColor: AppColors.errorBase,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  /// Submit KYC form data with document keys to the backend
  Future<void> _submitKycData() async {
    if (_frontDocKey == null || _backDocKey == null || _selfieDocKey == null) {
      throw Exception('Documents must be uploaded first');
    }

    if (_dateOfBirth == null || _selectedCountry == null) {
      throw Exception('Personal information is incomplete');
    }

    final dio = ref.read(dioProvider);

    // Format date of birth as ISO 8601 (YYYY-MM-DD)
    final formattedDob = DateFormat('yyyy-MM-dd').format(_dateOfBirth!);

    await dio.post('/wallet/kyc/submit', data: {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'dateOfBirth': formattedDob,
      'country': _selectedCountry!.code,
      'idType': _selectedIdType,
      'idNumber': _idNumberController.text.trim(),
      'documentFrontKey': _frontDocKey,
      'documentBackKey': _backDocKey,
      'selfieKey': _selfieDocKey,
      if (_livenessSessionId != null) 'livenessSessionId': _livenessSessionId,
    });
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
    this.imageFile,
  });

  final String title;
  final String description;
  final bool isUploaded;
  final VoidCallback onTap;
  final File? imageFile;

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
              child: isUploaded && imageFile != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: Image.file(
                        imageFile!,
                        fit: BoxFit.cover,
                        width: 60,
                        height: 60,
                      ),
                    )
                  : Icon(
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
                    isUploaded ? 'Tap to change' : description,
                    variant: AppTextVariant.bodySmall,
                    color: isUploaded ? AppColors.successBase : AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.edit : Icons.chevron_right,
              color: isUploaded ? AppColors.successBase : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Source option widget for image source dialog
class _SourceOption extends StatelessWidget {
  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.gold500,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textPrimary,
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
