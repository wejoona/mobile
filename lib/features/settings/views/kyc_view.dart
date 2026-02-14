import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/state/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/features/liveness/widgets/liveness_check_widget.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

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
    final colors = context.colors;
    final userState = ref.watch(userStateMachineProvider);

    // If already verified, show status
    if (userState.kycStatus == KycStatus.verified) {
      return _buildVerifiedView(colors);
    }

    // If submitted/pending review, show pending status
    if (userState.kycStatus == KycStatus.submitted ||
        userState.kycStatus == KycStatus.pending) {
      return _buildPendingView(colors);
    }

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          _buildProgressBar(colors),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _buildCurrentStep(colors),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(colors),
        ],
      ),
    );
  }

  Widget _buildProgressBar(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: _buildStepIndicator(0, 'Info', colors)),
          Expanded(child: _buildStepLine(0, colors)),
          Flexible(child: _buildStepIndicator(1, 'Doc', colors)),
          Expanded(child: _buildStepLine(1, colors)),
          Flexible(child: _buildStepIndicator(2, 'Photo', colors)),
          Expanded(child: _buildStepLine(2, colors)),
          Flexible(child: _buildStepIndicator(3, 'Selfie', colors)),
          Expanded(child: _buildStepLine(3, colors)),
          Flexible(child: _buildStepIndicator(4, 'Review', colors)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, ThemeColors colors) {
    final isCompleted = _currentStep > step;
    final isCurrent = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCompleted || isCurrent
                ? colors.gold
                : colors.elevated,
            shape: BoxShape.circle,
            border: Border.all(
              color: isCurrent ? colors.gold : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(Icons.check, color: colors.canvas, size: 18)
                : AppText(
                    '${step + 1}',
                    variant: AppTextVariant.labelMedium,
                    color: isCurrent ? colors.canvas : colors.textTertiary,
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppText(
          label,
          variant: AppTextVariant.bodySmall,
          color: isCurrent ? colors.gold : colors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildStepLine(int afterStep, ThemeColors colors) {
    final isCompleted = _currentStep > afterStep;

    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted ? colors.gold : colors.borderSubtle,
    );
  }

  Widget _buildCurrentStep(ThemeColors colors) {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep(colors);
      case 1:
        return _buildDocumentTypeStep(colors);
      case 2:
        return _buildDocumentPhotosStep(colors);
      case 3:
        return _buildSelfieStep(colors);
      case 4:
        return _buildReviewStep(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildPersonalInfoStep(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Personal Information',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'Please provide your personal details as they appear on your ID document.',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
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
          child: Row(
            children: [
              Icon(Icons.info_outline, color: context.colors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Your information must match the ID document you will upload in the next steps.',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentTypeStep(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Select Document Type',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'Choose the type of government-issued ID you want to use for verification.',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        ...KycDocumentType.values.map((type) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _DocumentTypeCard(
                type: type,
                isSelected: _selectedDocType == type,
                onTap: () => setState(() => _selectedDocType = type),
                colors: colors,
              ),
            )),
        const SizedBox(height: AppSpacing.lg),
        // Info
        AppCard(
          variant: AppCardVariant.subtle,
          child: Row(
            children: [
              Icon(Icons.info_outline, color: context.colors.info, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppText(
                  'Make sure your document is valid and not expired. We accept documents from most countries.',
                  variant: AppTextVariant.bodySmall,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentPhotosStep(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Upload ${_selectedDocType?.label ?? "Document"} Photos',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'Take clear photos of the front and back of your document.',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Front Photo
        _UploadCard(
          title: 'Front of Document',
          description: 'Photo of the front side showing your photo and details',
          isUploaded: _frontUploaded,
          imageFile: _frontImage,
          onTap: () => _showImageSourceDialog('front'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.md),
        // Back Photo
        _UploadCard(
          title: 'Back of Document',
          description: 'Photo of the back side of your ID',
          isUploaded: _backUploaded,
          imageFile: _backImage,
          onTap: () => _showImageSourceDialog('back'),
          colors: colors,
        ),
        const SizedBox(height: AppSpacing.xxl),
        // Tips
        AppText(
          'Photo Tips',
          variant: AppTextVariant.labelMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildTip(Icons.wb_sunny, 'Use good lighting', colors),
        _buildTip(Icons.crop_free, 'Capture all corners', colors),
        _buildTip(Icons.blur_off, 'Avoid blur and glare', colors),
      ],
    );
  }

  Widget _buildSelfieStep(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Liveness Check & Selfie',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'Complete a liveness check to verify you are a real person, then take a selfie.',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
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
                        color: context.colors.info.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.face_retouching_natural,
                        color: context.colors.info,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            'Liveness Check Required',
                            variant: AppTextVariant.bodyLarge,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            'Follow on-screen instructions',
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
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
                    color: context.colors.success.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: context.colors.success,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Liveness Check Passed',
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        'You can now take your selfie',
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
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
                  color: colors.container,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _selfieUploaded
                        ? context.colors.success
                        : colors.borderSubtle,
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
                            color: colors.textTertiary,
                            size: 48,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppText(
                            'Tap to take selfie',
                            variant: AppTextVariant.bodyMedium,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),

          // Tips
          AppText(
            'Selfie Tips',
            variant: AppTextVariant.labelMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTip(Icons.face, 'Look directly at the camera', colors),
          _buildTip(Icons.wb_sunny, 'Ensure your face is well-lit', colors),
          _buildTip(Icons.close, 'No sunglasses or hats', colors),
        ],
      ],
    );
  }

  Widget _buildReviewStep(ThemeColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          'Review & Submit',
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.sm),
        AppText(
          'Please review your submission before submitting.',
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Personal Information Section
        AppText(
          'Personal Information',
          variant: AppTextVariant.labelLarge,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewItem(
          icon: Icons.person,
          label: 'Full Name',
          value: '${_firstNameController.text} ${_lastNameController.text}',
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.cake,
          label: 'Date of Birth',
          value: _dateOfBirth != null
              ? DateFormat('MMM dd, yyyy').format(_dateOfBirth!)
              : 'Not set',
          valueColor: _dateOfBirth != null ? colors.textPrimary : context.colors.error,
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.public,
          label: 'Country',
          value: _selectedCountry?.name ?? 'Not selected',
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.badge,
          label: 'ID Type',
          value: _getIdTypeName(_selectedIdType),
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.numbers,
          label: 'ID Number',
          value: _idNumberController.text.isNotEmpty
              ? _idNumberController.text
              : 'Not provided',
          valueColor: _idNumberController.text.isNotEmpty
              ? colors.textPrimary
              : context.colors.error,
          colors: colors,
        ),

        const SizedBox(height: AppSpacing.xl),

        // Documents Section
        AppText(
          'Documents',
          variant: AppTextVariant.labelLarge,
          color: colors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.md),
        _ReviewItem(
          icon: Icons.credit_card,
          label: 'Document Type',
          value: _selectedDocType?.label ?? 'Not selected',
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.photo,
          label: 'Front Photo',
          value: _frontUploaded ? 'Uploaded' : 'Missing',
          valueColor: _frontUploaded ? context.colors.success : context.colors.error,
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.photo,
          label: 'Back Photo',
          value: _backUploaded ? 'Uploaded' : 'Missing',
          valueColor: _backUploaded ? context.colors.success : context.colors.error,
          colors: colors,
        ),
        _ReviewItem(
          icon: Icons.face,
          label: 'Selfie',
          value: _selfieUploaded ? 'Uploaded' : 'Missing',
          valueColor: _selfieUploaded ? context.colors.success : context.colors.error,
          colors: colors,
        ),

        const SizedBox(height: AppSpacing.xxl),

        // Disclaimer
        AppCard(
          variant: AppCardVariant.subtle,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'By submitting, you confirm that:',
                variant: AppTextVariant.bodyMedium,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.md),
              _DisclaimerItem(text: 'The information provided is accurate', colors: colors),
              _DisclaimerItem(text: 'The documents belong to you', colors: colors),
              _DisclaimerItem(text: 'You agree to our Terms of Service', colors: colors),
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

  Widget _buildTip(IconData icon, String text, ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, color: colors.gold, size: 20),
          const SizedBox(width: AppSpacing.sm),
          AppText(
            text,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(ThemeColors colors) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: colors.container,
        border: Border(
          top: BorderSide(color: colors.borderSubtle),
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
    return AppSelect<String>(
      label: 'ID Type',
      value: _selectedIdType,
      items: const [
        AppSelectItem(
          value: 'national_id',
          label: 'National ID',
          icon: Icons.credit_card,
        ),
        AppSelectItem(
          value: 'passport',
          label: 'Passport',
          icon: Icons.menu_book,
        ),
        AppSelectItem(
          value: 'drivers_license',
          label: "Driver's License",
          icon: Icons.drive_eta,
        ),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedIdType = value);
        }
      },
      hint: 'Select ID type',
    );
  }

  Future<void> _selectDateOfBirth() async {
    final colors = context.colors;
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
            colorScheme: ColorScheme.dark(
              primary: colors.gold,
              onPrimary: colors.canvas,
              surface: colors.container,
              onSurface: colors.textPrimary,
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
      backgroundColor: context.colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        final colors = context.colors;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: AppText(
                  'Select Country',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
                ),
              ),
              Divider(color: colors.borderSubtle),
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
                        color: isSelected ? colors.gold : colors.textPrimary,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: colors.gold)
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
        );
      },
    );
  }

  /// Show dialog to choose between camera and gallery
  void _showImageSourceDialog(String type) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) {
        final colors = context.colors;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  'Choose Image Source',
                  variant: AppTextVariant.titleMedium,
                  color: colors.textPrimary,
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
                        colors: colors,
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
                        colors: colors,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
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
            backgroundColor: context.colors.error,
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
          onCancel: () => Navigator.of(context).pop(),
          onComplete: (result) => Navigator.of(context).pop(result),
          /* onError handled internally by widget now - shows retry UI */
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
          SnackBar(
            content: Text('Liveness check passed! You can now take your selfie.'),
            backgroundColor: context.colors.success,
          ),
        );
      }
    } else if (result != null && !result.isLive) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Liveness check failed: ${result.failureReason ?? "Please try again"}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  /// Take selfie with front camera (only after liveness check passes)
  Future<void> _takeSelfie() async {
    if (!_livenessCheckPassed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete liveness check first'),
          backgroundColor: context.colors.warning,
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
            backgroundColor: context.colors.error,
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
            SnackBar(
              content: Text('KYC submitted successfully!'),
              backgroundColor: context.colors.success,
            ),
          );
          context.safePop(fallbackRoute: '/settings');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to submit KYC: ${e.toString()}'),
              backgroundColor: context.colors.error,
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

  Widget _buildVerifiedView(ThemeColors colors) {
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
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
                color: context.colors.success.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified,
                color: context.colors.success,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'Identity Verified',
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                'Your identity has been successfully verified. You can now use all features of JoonaPay.',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingView(ThemeColors colors) {
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          'Identity Verification',
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.gold),
          onPressed: () => context.safePop(fallbackRoute: '/settings'),
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
                color: context.colors.warning.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.hourglass_top,
                color: context.colors.warning,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'Verification In Progress',
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxxl),
              child: AppText(
                'We are reviewing your documents. This usually takes 1-2 business days. You will be notified once completed.',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
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
    required this.colors,
  });

  final KycDocumentType type;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.gold.withValues(alpha: 0.1)
              : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? colors.gold : Colors.transparent,
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
                    ? colors.gold.withValues(alpha: 0.2)
                    : colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? colors.gold : colors.textSecondary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: AppText(
                type.label,
                variant: AppTextVariant.bodyLarge,
                color: isSelected ? colors.gold : colors.textPrimary,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.gold),
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
    required this.colors,
    this.imageFile,
  });

  final String title;
  final String description;
  final bool isUploaded;
  final VoidCallback onTap;
  final File? imageFile;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isUploaded ? context.colors.success : colors.borderSubtle,
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
                    ? context.colors.success.withValues(alpha: 0.2)
                    : colors.elevated,
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
                      color: isUploaded ? context.colors.success : colors.textTertiary,
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
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  AppText(
                    isUploaded ? 'Tap to change' : description,
                    variant: AppTextVariant.bodySmall,
                    color: isUploaded ? context.colors.success : colors.textSecondary,
                  ),
                ],
              ),
            ),
            Icon(
              isUploaded ? Icons.edit : Icons.chevron_right,
              color: isUploaded ? context.colors.success : colors.textTertiary,
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
    required this.colors,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: colors.elevated,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colors.gold,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: colors.textPrimary,
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
    required this.colors,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Icon(icon, color: colors.textTertiary, size: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppText(
              label,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ),
          AppText(
            value,
            variant: AppTextVariant.bodyMedium,
            color: valueColor ?? colors.textPrimary,
          ),
        ],
      ),
    );
  }
}

class _DisclaimerItem extends StatelessWidget {
  const _DisclaimerItem({
    required this.text,
    required this.colors,
  });

  final String text;
  final ThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, color: colors.gold, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppText(
              text,
              variant: AppTextVariant.bodySmall,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
