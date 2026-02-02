import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import '../../../router/navigation_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/theme_colors.dart';
import '../../../design/components/primitives/app_button.dart';
import '../../../design/components/primitives/app_text.dart';
import '../providers/kyc_provider.dart';
import '../../../services/kyc/image_quality_checker.dart';
import '../models/image_quality_result.dart';
import '../../../utils/logger.dart';
import '../../../mocks/mock_config_provider.dart';

class SelfieView extends ConsumerStatefulWidget {
  const SelfieView({super.key});

  @override
  ConsumerState<SelfieView> createState() => _SelfieViewState();
}

class _SelfieViewState extends ConsumerState<SelfieView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  String? _capturedImagePath;
  bool _isCheckingQuality = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    debugPrint('[SelfieView] initState called - starting camera init');
    _initializeCamera();
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
      debugPrint('[Selfie] Simulator detected - using gallery fallback');
      if (mounted) {
        setState(() => _cameraError = 'Camera mocked for simulator. Please use gallery.');
      }
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        if (mounted) {
          setState(() => _cameraError = 'No cameras available on this device');
        }
        return;
      }

      // Find front camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras![0],
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      AppLogger('Camera initialization error').error('Camera initialization error', e);
      if (mounted) {
        setState(() => _cameraError = 'Camera not available. Please use gallery instead.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    // Show captured image review screen
    if (_capturedImagePath != null) {
      return _buildReviewScreen(context, l10n);
    }

    // Show gallery fallback when camera not available
    if (_cameraError != null) {
      return _buildGalleryFallbackScreen(context, l10n);
    }

    // Show loading while camera initializes
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return _buildCaptureScreen(context, l10n);
  }

  Widget _buildCaptureScreen(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.black, // Always black for camera screen
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview
            Positioned.fill(
              child: CameraPreview(_controller!),
            ),
            // Face oval overlay
            Positioned.fill(
              child: CustomPaint(
                painter: FaceOvalPainter(),
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
                    Expanded(
                      child: AppText(
                        l10n.kyc_selfie_title,
                        textAlign: TextAlign.center,
                        variant: AppTextVariant.headlineSmall,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 48),
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
                child: Column(
                  children: [
                    AppText(
                      l10n.kyc_selfie_guidance,
                      textAlign: TextAlign.center,
                      variant: AppTextVariant.bodyMedium,
                      color: Colors.white,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    AppText(
                      l10n.kyc_selfie_livenessHint,
                      textAlign: TextAlign.center,
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.gold500,
                    ),
                  ],
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
                      l10n.kyc_selfie_instructions,
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

  Widget _buildReviewScreen(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.kyc_reviewSelfie, variant: AppTextVariant.headlineSmall),
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

  Widget _buildGalleryFallbackScreen(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        title: AppText(l10n.kyc_selfie_title, variant: AppTextVariant.headlineSmall),
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.warning.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.no_photography,
                      size: 64,
                      color: colors.warning,
                    ),
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  AppText(
                    l10n.kyc_camera_unavailable,
                    variant: AppTextVariant.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppText(
                    l10n.kyc_camera_unavailable_description,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: l10n.kyc_chooseFromGallery,
                    onPressed: _isCheckingQuality ? null : _pickFromGallery,
                    isFullWidth: true,
                    icon: Icons.photo_library,
                  ),
                  SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.kyc_tryAgain,
                    variant: AppButtonVariant.secondary,
                    onPressed: _isCheckingQuality ? null : () {
                      setState(() {
                        _cameraError = null;
                        _isInitialized = false;
                      });
                      _initializeCamera();
                    },
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
            if (_isCheckingQuality)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
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

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (image == null) {
        return;
      }

      // Show loading only after user has picked an image
      setState(() => _isCheckingQuality = true);

      // Check image quality with timeout
      final isSimulator = ref.read(isSimulatorProvider);
      final qualityResult = await ImageQualityChecker.checkQuality(
        image.path,
        skipStrictChecks: isSimulator,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => ImageQualityResult.acceptable(),
      );

      if (!qualityResult.isAcceptable) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                qualityResult.errorKey != null
                    ? _getErrorMessage(l10n, qualityResult.errorKey!)
                    : l10n.kyc_error_imageQuality,
              ),
              backgroundColor: context.colors.error,
            ),
          );
        }
        setState(() => _isCheckingQuality = false);
        return;
      }

      // Save to permanent location
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = path.join(directory.path, fileName);
      await File(image.path).copy(permanentPath);

      setState(() {
        _capturedImagePath = permanentPath;
        _isCheckingQuality = false;
        _cameraError = null;
      });
    } catch (e) {
      setState(() => _isCheckingQuality = false);
      AppLogger('Gallery pick error').error('Gallery pick error', e);
    }
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                qualityResult.errorKey != null
                    ? _getErrorMessage(l10n, qualityResult.errorKey!)
                    : l10n.kyc_error_imageQuality,
              ),
              backgroundColor: context.colors.error,
            ),
          );
        }
        setState(() => _isCheckingQuality = false);
        return;
      }

      // Save to permanent location
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
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
    ref.read(kycProvider.notifier).setSelfie(_capturedImagePath!);
    context.go('/kyc/liveness');
  }
}

class FaceOvalPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.7) // Always black for camera overlay
      ..style = PaintingStyle.fill;

    final ovalPaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Face oval dimensions
    final ovalWidth = size.width * 0.6;
    final ovalHeight = ovalWidth * 1.3;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: ovalWidth,
      height: ovalHeight,
    );

    // Draw darkened areas outside oval
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw animated oval border
    canvas.drawOval(ovalRect, ovalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
