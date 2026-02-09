import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/mocks/mock_config_provider.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';

/// Liveness check widget state
enum LivenessCheckState {
  initializing,
  ready,
  recording,
  uploading,
  processing,
  completed,
  failed,
}

/// Reusable liveness check widget with camera preview and challenge instructions
/// Uses the real backend flow:
/// 1. Create liveness session (get sessionToken + challenges)
/// 2. Show challenges to user, record video + capture selfie
/// 3. Upload video + selfie to get S3 keys
/// 4. Submit S3 keys to /kyc/liveness/submit
/// 5. Poll /kyc/liveness/status for result
class LivenessCheckWidget extends ConsumerStatefulWidget {
  final String purpose; // 'kyc', 'recovery', 'withdrawal'
  final VoidCallback? onCancel;
  final Function(LivenessResult)? onComplete;
  final Function(String)? onError;

  const LivenessCheckWidget({
    super.key,
    required this.purpose,
    this.onCancel,
    this.onComplete,
    this.onError,
  });

  @override
  ConsumerState<LivenessCheckWidget> createState() =>
      _LivenessCheckWidgetState();
}

class _LivenessCheckWidgetState extends ConsumerState<LivenessCheckWidget> {
  LivenessCheckState _state = LivenessCheckState.initializing;
  CameraController? _cameraController;
  String? _sessionToken;
  List<LivenessChallenge> _challenges = [];
  int _currentChallengeIndex = 0;
  String? _errorMessage;
  String? _statusMessage;
  bool _isRecording = false;
  String? _videoPath;
  String? _selfiePath;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final isSimulator = ref.read(isSimulatorProvider);
    final mockCamera = ref.read(mockCameraProvider);

    // Simulator: auto-pass
    if (isSimulator || mockCamera) {
      debugPrint('[Liveness] Simulator detected - using mock flow');
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.onComplete?.call(LivenessResult(
          isLive: true,
          confidence: 0.99,
          sessionId: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
          completedAt: DateTime.now(),
        ));
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _fail('No cameras available on this device');
        return;
      }

      final frontCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      if (mounted) {
        setState(() {});
        _createLivenessSession();
      }
    } catch (e) {
      _fail('Failed to initialize camera: $e');
    }
  }

  Future<void> _createLivenessSession() async {
    try {
      setState(() => _statusMessage = 'Creating liveness session...');
      final livenessService = ref.read(livenessServiceProvider);
      final session = await livenessService.createSession();

      setState(() {
        _sessionToken = session.sessionId;
        _challenges = session.challenges;
        _currentChallengeIndex = 0;
        _state = LivenessCheckState.ready;
        _statusMessage = null;
      });
    } catch (e) {
      _fail('Failed to create liveness session: $e');
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    if (_isRecording) return;

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _state = LivenessCheckState.recording;
      });

      // Auto-advance through challenges with timed intervals
      _advanceChallenges();
    } catch (e) {
      _fail('Failed to start recording: $e');
    }
  }

  Future<void> _advanceChallenges() async {
    // Show each challenge for 3 seconds
    for (int i = 0; i < _challenges.length; i++) {
      if (!mounted || !_isRecording) return;
      setState(() => _currentChallengeIndex = i);
      await Future.delayed(const Duration(seconds: 3));
    }

    // All challenges shown, stop recording and capture selfie
    if (mounted && _isRecording) {
      await _stopRecordingAndCapture();
    }
  }

  Future<void> _stopRecordingAndCapture() async {
    if (_cameraController == null) return;

    try {
      // Stop video recording
      final videoFile = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);

      // Save video to app directory
      final appDir = await getApplicationDocumentsDirectory();
      final videoName = 'liveness_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final videoSavePath = path.join(appDir.path, videoName);
      await File(videoFile.path).copy(videoSavePath);
      _videoPath = videoSavePath;

      // Capture selfie
      final selfieImage = await _cameraController!.takePicture();
      final selfieName = 'liveness_selfie_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final selfieSavePath = path.join(appDir.path, selfieName);
      await File(selfieImage.path).copy(selfieSavePath);
      _selfiePath = selfieSavePath;

      // Upload and submit
      await _uploadAndSubmit();
    } catch (e) {
      _fail('Failed to capture: $e');
    }
  }

  Future<void> _uploadAndSubmit() async {
    if (_videoPath == null || _selfiePath == null || _sessionToken == null) {
      _fail('Missing video, selfie, or session token');
      return;
    }

    setState(() {
      _state = LivenessCheckState.uploading;
      _statusMessage = 'Uploading video and selfie...';
    });

    try {
      final sdk = ref.read(sdkProvider);

      // Upload video and selfie to get S3 keys
      debugPrint('[Liveness] Uploading video...');
      final videoKey = await sdk.kyc.uploadFileForVerification(_videoPath!, 'video');
      debugPrint('[Liveness] Uploading selfie...');
      final selfieKey = await sdk.kyc.uploadFileForVerification(_selfiePath!, 'selfie');

      setState(() {
        _state = LivenessCheckState.processing;
        _statusMessage = 'Verifying liveness...';
      });

      // Submit S3 keys to liveness endpoint
      debugPrint('[Liveness] Submitting liveness check...');
      final livenessService = ref.read(livenessServiceProvider);
      final result = await livenessService.submitLiveness(
        sessionToken: _sessionToken!,
        videoKey: videoKey,
        selfieKey: selfieKey,
      );

      if (result.isLive) {
        setState(() => _state = LivenessCheckState.completed);
        widget.onComplete?.call(result);
      } else {
        // Check if still processing — poll
        if (result.failureReason == null) {
          _startPolling();
        } else {
          _fail(result.failureReason ?? 'Liveness verification failed');
        }
      }
    } catch (e) {
      _fail('Liveness submission failed: $e');
    }
  }

  void _startPolling() {
    int attempts = 0;
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      attempts++;
      if (attempts > 10) {
        timer.cancel();
        _fail('Verification timed out. Please try again.');
        return;
      }

      try {
        final livenessService = ref.read(livenessServiceProvider);
        final status = await livenessService.getLivenessStatus();

        if (status == null) return;

        if (status.isLive) {
          timer.cancel();
          if (mounted) {
            setState(() => _state = LivenessCheckState.completed);
            widget.onComplete?.call(status);
          }
        } else if (status.failureReason != null) {
          timer.cancel();
          _fail(status.failureReason!);
        }
      } catch (e) {
        // Continue polling on transient errors
        debugPrint('[Liveness] Poll error: $e');
      }
    });
  }

  void _fail(String message) {
    debugPrint('[Liveness] Failed: $message');
    if (mounted) {
      setState(() {
        _state = LivenessCheckState.failed;
        _errorMessage = message;
        _statusMessage = null;
        _isRecording = false;
      });
      widget.onError?.call(message);
    }
  }

  void _retry() {
    _pollTimer?.cancel();
    _cameraController?.dispose();
    _cameraController = null;
    setState(() {
      _state = LivenessCheckState.initializing;
      _sessionToken = null;
      _challenges = [];
      _currentChallengeIndex = 0;
      _errorMessage = null;
      _statusMessage = null;
      _videoPath = null;
      _selfiePath = null;
      _isRecording = false;
    });
    _initializeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      color: colors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            Expanded(child: _buildContent(colors)),
            if (_state == LivenessCheckState.ready ||
                _state == LivenessCheckState.recording)
              _buildInstructions(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            'Liveness Check',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          if (_state != LivenessCheckState.completed)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onCancel,
              color: colors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeColors colors) {
    switch (_state) {
      case LivenessCheckState.initializing:
        return _buildLoadingView(_statusMessage ?? 'Initializing camera...', colors);

      case LivenessCheckState.ready:
      case LivenessCheckState.recording:
        return _buildCameraPreview(colors);

      case LivenessCheckState.uploading:
      case LivenessCheckState.processing:
        return _buildLoadingView(_statusMessage ?? 'Processing...', colors);

      case LivenessCheckState.completed:
        return _buildSuccessView(colors);

      case LivenessCheckState.failed:
        return _buildErrorView(colors);
    }
  }

  Widget _buildLoadingView(String message, ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: colors.gold),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            message,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ThemeColors colors) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoadingView('Starting camera...', colors);
    }

    return Stack(
      children: [
        Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),
        // Face oval guide
        Center(
          child: Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: _isRecording
                    ? colors.gold
                    : colors.textPrimary.withOpacity(0.5),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
          ),
        ),
        // Recording indicator
        if (_isRecording)
          Positioned(
            top: AppSpacing.xl,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorBase.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppText(
                      'Recording',
                      variant: AppTextVariant.labelMedium,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Start button (when ready, not recording yet)
        if (_state == LivenessCheckState.ready && !_isRecording)
          Positioned(
            bottom: AppSpacing.xxl,
            left: AppSpacing.xxl,
            right: AppSpacing.xxl,
            child: AppButton(
              label: 'Start Liveness Check',
              onPressed: _startRecording,
              variant: AppButtonVariant.primary,
              isFullWidth: true,
            ),
          ),
      ],
    );
  }

  Widget _buildInstructions(ThemeColors colors) {
    if (_challenges.isEmpty) return const SizedBox();

    final currentChallenge = _currentChallengeIndex < _challenges.length
        ? _challenges[_currentChallengeIndex]
        : _challenges.last;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colors.container,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          // Progress dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _challenges.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index <= _currentChallengeIndex
                      ? colors.gold
                      : colors.borderSubtle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppText(
            currentChallenge.instruction,
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppText(
            'Step ${_currentChallengeIndex + 1} of ${_challenges.length}',
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.info_outline, color: AppColors.infoBase, size: 16),
              const SizedBox(width: AppSpacing.xs),
              AppText(
                'Position your face in the frame',
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.successBase.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: AppColors.successBase,
              size: 60,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppText(
            'Liveness Check Complete',
            variant: AppTextVariant.headlineSmall,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Your identity has been verified',
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.errorBase.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error,
                color: AppColors.errorBase,
                size: 60,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppText(
              'Liveness Check Failed',
              variant: AppTextVariant.headlineSmall,
              color: colors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              _errorMessage ?? 'Please try again',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Try Again',
              onPressed: _retry,
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
