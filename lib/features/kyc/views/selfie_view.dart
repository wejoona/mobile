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
import '../widgets/kyc_instruction_screen.dart';

enum _SelfieViewState {
  instructions,
  initializing,
  capturing,
  reviewing,
  error,
}

class SelfieView extends ConsumerStatefulWidget {
  const SelfieView({super.key});

  @override
  ConsumerState<SelfieView> createState() => _SelfieViewState2();
}

class _SelfieViewState2 extends ConsumerState<SelfieView> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  _SelfieViewState _viewState = _SelfieViewState.instructions;
  String? _capturedImagePath;
  bool _isCheckingQuality = false;
  String? _cameraError;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() => _viewState = _SelfieViewState.initializing);

    // Check if running on simulator
    final mockCamera = ref.read(mockCameraProvider);
    if (mockCamera) {
      debugPrint('[Selfie] Simulator detected - using gallery fallback');
      if (mounted) {
        setState(() {
          _cameraError = 'Camera mocked for simulator. Please use gallery.';
          _viewState = _SelfieViewState.error;
        });
      }
      return;
    }

    try {
      debugPrint('[Selfie] Getting available cameras...');
      _cameras = await availableCameras();

      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('[Selfie] No cameras available');
        if (mounted) {
          setState(() {
            _cameraError = 'No cameras available on this device';
            _viewState = _SelfieViewState.error;
          });
        }
        return;
      }

      // Log all available cameras
      for (int i = 0; i < _cameras!.length; i++) {
        final cam = _cameras![i];
        debugPrint('[Selfie] Camera $i: ${cam.name}, direction: ${cam.lensDirection}');
      }

      // Find front camera - MUST use front camera for selfie
      CameraDescription? frontCamera;
      for (final camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      if (frontCamera == null) {
        debugPrint('[Selfie] No front camera found, using first available');
        frontCamera = _cameras!.first;
      } else {
        debugPrint('[Selfie] Using front camera: ${frontCamera.name}');
      }

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      debugPrint('[Selfie] Initializing camera controller...');
      await _controller!.initialize();
      debugPrint('[Selfie] Camera initialized successfully');

      if (mounted) {
        setState(() => _viewState = _SelfieViewState.capturing);
      }
    } catch (e, stack) {
      debugPrint('[Selfie] Camera initialization error: $e');
      debugPrint('[Selfie] Stack: $stack');
      AppLogger('Selfie camera error').error('Camera initialization error', e);
      if (mounted) {
        setState(() {
          _cameraError = 'Camera not available. Please use gallery instead.';
          _viewState = _SelfieViewState.error;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_viewState) {
      case _SelfieViewState.instructions:
        return _buildInstructionScreen(context, l10n);
      case _SelfieViewState.initializing:
        return _buildLoadingScreen(context, l10n);
      case _SelfieViewState.capturing:
        return _buildCaptureScreen(context, l10n);
      case _SelfieViewState.reviewing:
        return _buildReviewScreen(context, l10n);
      case _SelfieViewState.error:
        return _buildGalleryFallbackScreen(context, l10n);
    }
  }

  Widget _buildInstructionScreen(BuildContext context, AppLocalizations l10n) {
    return KycInstructionScreen(
      title: l10n.kyc_selfie_title,
      description: 'We need a clear photo of your face to verify your identity.',
      icon: Icons.face,
      instructions: KycInstructions.selfie,
      buttonLabel: l10n.common_continue,
      onContinue: _initializeCamera,
      onBack: () => context.safePop(),
    );
  }

  Widget _buildLoadingScreen(BuildContext context, AppLocalizations l10n) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.canvas,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: colors.gold),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Starting camera...',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureScreen(BuildContext context, AppLocalizations l10n) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return _buildLoadingScreen(context, l10n);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview - full screen
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
                padding: const EdgeInsets.all(AppSpacing.lg),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        _controller?.dispose();
                        _controller = null;
                        setState(() => _viewState = _SelfieViewState.instructions);
                      },
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
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.gold500.withOpacity(0.3),
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
                    const SizedBox(height: AppSpacing.sm),
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
                padding: const EdgeInsets.all(AppSpacing.xxl),
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
                    const SizedBox(height: AppSpacing.xxl),
                    _buildCaptureButton(),
                  ],
                ),
              ),
            ),
            // Processing overlay
            if (_isCheckingQuality)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.8),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: AppSpacing.md),
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
          padding: const EdgeInsets.all(AppSpacing.lg),
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
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: l10n.kyc_retake,
                      onPressed: _retakePhoto,
                      variant: AppButtonVariant.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
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
      onTap: _isCheckingQuality ? null : _capturePhoto,
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
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.safePop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
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
                  const SizedBox(height: AppSpacing.xxl),
                  AppText(
                    l10n.kyc_camera_unavailable,
                    variant: AppTextVariant.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    _cameraError ?? l10n.kyc_camera_unavailable_description,
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: l10n.kyc_chooseFromGallery,
                    onPressed: _isCheckingQuality ? null : _pickFromGallery,
                    isFullWidth: true,
                    icon: Icons.photo_library,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: l10n.kyc_tryAgain,
                    variant: AppButtonVariant.secondary,
                    onPressed: _isCheckingQuality ? null : _initializeCamera,
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
                        const SizedBox(height: AppSpacing.md),
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
        preferredCameraDevice: CameraDevice.front,
      );

      if (image == null) return;

      setState(() => _isCheckingQuality = true);

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

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = path.join(directory.path, fileName);
      await File(image.path).copy(permanentPath);

      setState(() {
        _capturedImagePath = permanentPath;
        _isCheckingQuality = false;
        _viewState = _SelfieViewState.reviewing;
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
      debugPrint('[Selfie] Taking picture...');
      final image = await _controller!.takePicture();
      debugPrint('[Selfie] Picture taken: ${image.path}');

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

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentPath = path.join(directory.path, fileName);
      await File(image.path).copy(permanentPath);

      // Dispose camera before showing review
      _controller?.dispose();
      _controller = null;

      setState(() {
        _capturedImagePath = permanentPath;
        _isCheckingQuality = false;
        _viewState = _SelfieViewState.reviewing;
      });
    } catch (e) {
      debugPrint('[Selfie] Capture error: $e');
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
    setState(() {
      _capturedImagePath = null;
      _viewState = _SelfieViewState.instructions;
    });
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
      ..color = Colors.black.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final ovalPaint = Paint()
      ..color = AppColors.gold500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final ovalWidth = size.width * 0.6;
    final ovalHeight = ovalWidth * 1.3;

    final ovalRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 50),
      width: ovalWidth,
      height: ovalHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
    canvas.drawOval(ovalRect, ovalPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
