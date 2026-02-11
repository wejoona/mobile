import 'package:usdc_wallet/features/kyc/models/kyc_state.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdc_wallet/router/navigation_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/models/document_type.dart';
import 'package:usdc_wallet/features/kyc/models/kyc_document.dart';
import 'package:usdc_wallet/services/kyc/image_quality_checker.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/mocks/mock_config_provider.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_instruction_screen.dart';

class DocumentCaptureView extends ConsumerStatefulWidget {
  const DocumentCaptureView({super.key});

  @override
  ConsumerState<DocumentCaptureView> createState() => _DocumentCaptureViewState();
}

class _DocumentCaptureViewState extends ConsumerState<DocumentCaptureView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _flashEnabled = false;
  String? _capturedImagePath;
  bool _isCheckingQuality = false;
  DocumentSide _currentSide = DocumentSide.front;
  String? _cameraError;
  bool _showInstructions = true; // Show instructions first

  @override
  void initState() {
    super.initState();
    // Don't initialize camera immediately - wait for user to continue from instructions
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    // Skip camera initialization if running on simulator (auto-detected)
    final mockCamera = ref.read(mockCameraProvider);
    if (mockCamera) {
      debugPrint('[DocumentCapture] Simulator detected - showing gallery picker');
      if (mounted) {
        setState(() {
          _cameraError = 'Camera mocked for simulator testing';
        });
      }
      return;
    }

    try {
      debugPrint('[DocumentCapture] Initializing camera...');

      // Add timeout for simulator environments where camera hangs
      _cameras = await availableCameras().timeout(
        const Duration(seconds: 5),
        onTimeout: () => <CameraDescription>[],
      );
      debugPrint('[DocumentCapture] Found ${_cameras?.length ?? 0} cameras');

      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() {
            _cameraError = 'No cameras available on this device';
          });
        }
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Camera initialization timed out');
        },
      );
      debugPrint('[DocumentCapture] Camera initialized successfully');
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('[DocumentCapture] Camera initialization error: $e');
      AppLogger('Camera initialization error').error('Camera initialization error', e);
      if (mounted) {
        setState(() {
          _cameraError = 'Camera initialization failed: ${e.toString().split('\n').first}';
        });
      }
    }
  }

  Future<void> _pickFromGallery(BuildContext context, KycFlowState state) async {
    try {
      final picker = ImagePicker();
      debugPrint('[DocumentCapture] Opening gallery picker...');

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image == null) {
        debugPrint('[DocumentCapture] Gallery picker cancelled');
        return;
      }

      debugPrint('[DocumentCapture] Image selected: ${image.path}');

      // Copy to app directory for consistency
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'document_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(appDir.path, fileName);

      debugPrint('[DocumentCapture] Copying to: $savedPath');
      await File(image.path).copy(savedPath);
      debugPrint('[DocumentCapture] File copied successfully');

      // Set the captured image and go to review
      if (mounted) {
        setState(() {
          _capturedImagePath = savedPath;
          _cameraError = null;
        });
        debugPrint('[DocumentCapture] State updated, showing review screen');
      } else {
        debugPrint('[DocumentCapture] Widget not mounted, cannot update state');
      }
    } catch (e, stack) {
      debugPrint('[DocumentCapture] Gallery pick error: $e');
      debugPrint('[DocumentCapture] Stack: $stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(kycProvider);
    final colors = context.colors;

    // Show instruction screen first
    if (_showInstructions) {
      return _buildInstructionScreen(context, l10n, state);
    }

    // Check captured image FIRST - this must come before camera error check
    // so gallery-picked images show the review screen
    if (_capturedImagePath != null) {
      return _buildReviewScreen(context, l10n, state);
    }

    // Show error if camera failed - with gallery option
    if (_cameraError != null) {
      final documentType = state.selectedDocumentType;
      final isBackSide = documentType?.requiresBackSide == true && state.capturedDocuments.isNotEmpty;
      final documentName = _getDocumentTypeName(l10n, documentType);
      final sideLabel = isBackSide ? 'Back Side' : 'Front Side';

      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
          backgroundColor: Colors.transparent,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                // Task card - what user needs to do (primary focus)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: colors.gold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.gold.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: colors.gold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.badge_outlined,
                          color: colors.gold,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              documentName,
                              variant: AppTextVariant.labelMedium,
                              color: colors.gold,
                            ),
                            SizedBox(height: AppSpacing.xxs),
                            AppText(
                              sideLabel,
                              variant: AppTextVariant.headlineMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Spacer to push content to center
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: colors.textTertiary),
                      SizedBox(height: AppSpacing.md),
                      AppText(
                        l10n.kyc_camera_unavailable,
                        variant: AppTextVariant.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: AppSpacing.xs),
                      AppText(
                        l10n.kyc_camera_unavailable_description,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textSecondary,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Actions at bottom (natural thumb zone)
                AppButton(
                  label: l10n.kyc_chooseFromGallery,
                  icon: Icons.photo_library,
                  onPressed: () => _pickFromGallery(context, state),
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.kyc_tryAgain,
                  variant: AppButtonVariant.secondary,
                  icon: Icons.refresh,
                  onPressed: () {
                    setState(() {
                      _cameraError = null;
                    });
                    _initializeCamera();
                  },
                  isFullWidth: true,
                ),
                SizedBox(height: AppSpacing.sm),
                AppButton(
                  label: l10n.common_cancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.pop(),
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show loading while camera initializes
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: AppText(l10n.kyc_title, variant: AppTextVariant.headlineSmall),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colors.gold),
              SizedBox(height: AppSpacing.lg),
              AppText(
                'Initializing camera...',
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      );
    }

    return _buildCaptureScreen(context, l10n, state);
  }

  Widget _buildInstructionScreen(
    BuildContext context,
    AppLocalizations l10n,
    KycFlowState state,
  ) {
    final documentType = state.selectedDocumentType;
    final documentName = _getDocumentTypeName(l10n, documentType);
    final isBackSide = documentType?.requiresBackSide == true && state.capturedDocuments.isNotEmpty;

    return KycInstructionScreen(
      title: isBackSide ? 'Capture Back Side' : 'Capture $documentName',
      description: isBackSide
          ? 'Now flip your document over and capture the back side.'
          : 'Position your document within the frame and take a clear photo.',
      icon: Icons.badge_outlined,
      instructions: KycInstructions.documentCapture,
      buttonLabel: l10n.common_continue,
      onContinue: () {
        setState(() => _showInstructions = false);
        _initializeCamera();
      },
      onBack: () => context.safePop(),
    );
  }

  Widget _buildCaptureScreen(
    BuildContext context,
    AppLocalizations l10n,
    KycFlowState state,
  ) {
    final documentType = state.selectedDocumentType!;
    final requiresBackSide = documentType.requiresBackSide;
    final isBackSide = requiresBackSide && state.capturedDocuments.isNotEmpty;

    if (isBackSide) {
      _currentSide = DocumentSide.back;
    }

    return Scaffold(
      backgroundColor: AppColors.obsidian,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),
            // Document frame overlay
            Positioned.fill(
              child: CustomPaint(
                painter: DocumentFramePainter(
                  documentType: documentType,
                ),
              ),
            ),
            // Top controls
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => context.safePop(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _flashEnabled ? Icons.flash_on : Icons.flash_off,
                        color: AppColors.gold500,
                        size: 28,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
            // Guidance text
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.gold500.withOpacity(0.3), // Keep gold for visibility
                    width: 1,
                  ),
                ),
                child: AppText(
                  isBackSide
                      ? l10n.kyc_capture_backSide_guidance
                      : l10n.kyc_capture_frontSide_guidance,
                  textAlign: TextAlign.center,
                  variant: AppTextVariant.bodyMedium,
                  color: Colors.white,
                ),
              ),
            ),
            // Bottom controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(AppSpacing.xxl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    AppText(
                      _getCaptureInstructions(l10n, documentType, isBackSide),
                      textAlign: TextAlign.center,
                      variant: AppTextVariant.bodyLarge,
                      color: Colors.white,
                    ),
                    SizedBox(height: AppSpacing.xxl),
                    _buildCaptureButton(),
                  ],
                ),
              ),
            ),
            if (_isCheckingQuality)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        SizedBox(height: AppSpacing.md),
                        AppText(
                          l10n.kyc_checkingQuality,
                          variant: AppTextVariant.bodyMedium,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewScreen(
    BuildContext context,
    AppLocalizations l10n,
    KycFlowState state,
  ) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.kyc_reviewImage, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
        leading: Container(),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.border, width: 1),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    child: Image.file(
                      File(_capturedImagePath!),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.kyc_retake,
                      onPressed: _retakePhoto,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: AppButton(
                      label: l10n.kyc_accept,
                      onPressed: () => _acceptPhoto(context),
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

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: _capturePhoto,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getCaptureInstructions(
    AppLocalizations l10n,
    DocumentType type,
    bool isBackSide,
  ) {
    if (isBackSide) {
      return l10n.kyc_capture_backInstructions;
    }

    switch (type) {
      case DocumentType.nationalId:
        return l10n.kyc_capture_nationalIdInstructions;
      case DocumentType.passport:
        return l10n.kyc_capture_passportInstructions;
      case DocumentType.driversLicense:
        return l10n.kyc_capture_driversLicenseInstructions;
    }
  }

  String _getDocumentTypeName(AppLocalizations l10n, DocumentType? type) {
    if (type == null) return 'Document';
    switch (type) {
      case DocumentType.nationalId:
        return l10n.kyc_documentType_nationalId;
      case DocumentType.passport:
        return l10n.kyc_documentType_passport;
      case DocumentType.driversLicense:
        return l10n.kyc_documentType_driversLicense;
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null) return;

    setState(() => _flashEnabled = !_flashEnabled);
    await _controller!.setFlashMode(
      _flashEnabled ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> _capturePhoto() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isCheckingQuality = true);

    try {
      final image = await _controller!.takePicture();

      // Check image quality
      final isSimulator = ref.read(isSimulatorProvider);
      final qualityResult = await ImageQualityChecker.checkQuality(
        image.path,
        skipStrictChecks: isSimulator,
      );

      if (!qualityResult.isAcceptable) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          final colors = context.colors;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                qualityResult.errorKey != null
                    ? _getErrorMessage(l10n, qualityResult.errorKey!)
                    : l10n.kyc_error_imageQuality,
              ),
              backgroundColor: colors.error,
            ),
          );
        }
        setState(() => _isCheckingQuality = false);
        return;
      }

      // Save to permanent location
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = path.join(directory.path, fileName);
      await File(image.path).copy(permanentPath);

      setState(() {
        _capturedImagePath = permanentPath;
        _isCheckingQuality = false;
      });
    } catch (e) {
      setState(() => _isCheckingQuality = false);
      AppLogger('Capture error').error('Capture error', e);
    }
  }

  String _getErrorMessage(AppLocalizations l10n, String errorKey) {
    switch (errorKey) {
      case 'kyc_error_imageBlurry':
        return l10n.kyc_error_imageBlurry;
      case 'kyc_error_imageGlare':
        return l10n.kyc_error_imageGlare;
      case 'kyc_error_imageTooDark':
        return l10n.kyc_error_imageTooDark;
      default:
        return l10n.kyc_error_imageQuality;
    }
  }

  void _retakePhoto() {
    setState(() => _capturedImagePath = null);
  }

  void _acceptPhoto(BuildContext context) {
    final state = ref.read(kycProvider);
    final documentType = state.selectedDocumentType!;
    final existingDocCount = state.capturedDocuments.length;

    // Determine the correct side based on existing documents (BEFORE adding)
    final isBackSide = documentType.requiresBackSide && existingDocCount > 0;
    final side = isBackSide ? DocumentSide.back : DocumentSide.front;

    debugPrint('[DocumentCapture] Accepting photo as ${side.name} side (existing docs: $existingDocCount)');

    final document = KycDocument(
      type: documentType,
      imagePath: _capturedImagePath!,
      side: side,
    );

    ref.read(kycProvider.notifier).addDocument(document);

    // Check if we need to capture the back side (check based on count BEFORE adding)
    final needsBackSide = documentType.requiresBackSide && existingDocCount == 0;

    if (needsBackSide) {
      // Reset for back side capture - show instructions again
      debugPrint('[DocumentCapture] Need back side - showing instructions for back side');
      setState(() {
        _capturedImagePath = null;
        _currentSide = DocumentSide.back;
        _showInstructions = true; // Show instructions for back side
      });
    } else {
      // Move to selfie
      debugPrint('[DocumentCapture] All documents captured - navigating to /kyc/selfie');
      context.go('/kyc/selfie');
    }
  }
}

class DocumentFramePainter extends CustomPainter {
  final DocumentType documentType;

  DocumentFramePainter({required this.documentType});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7) // Always black for camera overlay
      ..style = PaintingStyle.fill;

    final framePaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Document frame dimensions
    final aspectRatio = documentType == DocumentType.passport ? 0.707 : 1.586; // ID card ratio
    final frameWidth = size.width * 0.85;
    final frameHeight = frameWidth / aspectRatio;

    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: frameWidth,
      height: frameHeight,
    );

    // Draw darkened areas outside frame
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(frameRect, const Radius.circular(12)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw animated frame border
    canvas.drawRRect(
      RRect.fromRectAndRadius(frameRect, const Radius.circular(12)),
      framePaint,
    );

    // Draw corner markers
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top + cornerLength),
      Offset(frameRect.left, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLength, frameRect.top),
      cornerPaint,
    );

    // Top-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.top),
      Offset(frameRect.right, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      Offset(frameRect.left, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      cornerPaint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
