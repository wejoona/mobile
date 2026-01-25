import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/liveness/liveness_service.dart';

/// Liveness check widget state
enum LivenessCheckState {
  initializing,
  ready,
  processing,
  completed,
  failed,
}

/// Reusable liveness check widget with camera preview and challenge instructions
/// Returns LivenessResult on successful completion
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
  String? _sessionId;
  List<LivenessChallenge> _allChallenges = [];
  LivenessChallenge? _currentChallenge;
  int _currentChallengeIndex = 0;
  String? _errorMessage;
  Timer? _captureTimer;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController?.dispose();
    if (_sessionId != null) {
      // Cancel session on dispose
      ref.read(livenessServiceProvider).cancelSession(_sessionId!);
    }
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
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
        _startLivenessSession();
      }
    } catch (e) {
      setState(() {
        _state = LivenessCheckState.failed;
        _errorMessage = 'Failed to initialize camera: $e';
      });
      widget.onError?.call(_errorMessage!);
    }
  }

  Future<void> _startLivenessSession() async {
    try {
      final livenessService = ref.read(livenessServiceProvider);
      final session = await livenessService.startSession(
        purpose: widget.purpose,
      );

      setState(() {
        _sessionId = session.sessionId;
        _allChallenges = session.challenges;
        if (_allChallenges.isNotEmpty) {
          _currentChallenge = _allChallenges[0];
          _currentChallengeIndex = 0;
          _state = LivenessCheckState.ready;
        } else {
          _state = LivenessCheckState.failed;
          _errorMessage = 'No challenges received';
        }
      });

      if (_state == LivenessCheckState.ready) {
        // Start auto-capture after showing challenge
        _startAutoCapture();
      }
    } catch (e) {
      setState(() {
        _state = LivenessCheckState.failed;
        _errorMessage = 'Failed to start liveness session: $e';
      });
      widget.onError?.call(_errorMessage!);
    }
  }

  void _startAutoCapture() {
    _captureTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isSubmitting && _state == LivenessCheckState.ready) {
        _captureAndSubmit();
      }
    });
  }

  Future<void> _captureAndSubmit() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _currentChallenge == null ||
        _sessionId == null ||
        _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _state = LivenessCheckState.processing;
    });

    try {
      final image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();

      final livenessService = ref.read(livenessServiceProvider);
      final response = await livenessService.submitChallenge(
        sessionId: _sessionId!,
        challengeId: _currentChallenge!.challengeId,
        frameData: bytes,
      );

      if (response.passed) {
        if (response.isComplete) {
          // All challenges completed
          _captureTimer?.cancel();
          await _completeSession();
        } else if (response.nextChallenge != null) {
          // Move to next challenge
          setState(() {
            _currentChallengeIndex++;
            _currentChallenge = response.nextChallenge;
            _state = LivenessCheckState.ready;
          });
        }
      } else {
        // Challenge failed, show message and retry
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Please try again'),
              backgroundColor: AppColors.warningBase,
              duration: const Duration(seconds: 2),
            ),
          );
        }
        setState(() {
          _state = LivenessCheckState.ready;
        });
      }
    } catch (e) {
      setState(() {
        _state = LivenessCheckState.failed;
        _errorMessage = 'Failed to submit challenge: $e';
      });
      widget.onError?.call(_errorMessage!);
      _captureTimer?.cancel();
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _completeSession() async {
    try {
      final livenessService = ref.read(livenessServiceProvider);
      final result = await livenessService.completeSession(_sessionId!);

      setState(() {
        _state = LivenessCheckState.completed;
      });

      widget.onComplete?.call(result);
    } catch (e) {
      setState(() {
        _state = LivenessCheckState.failed;
        _errorMessage = 'Failed to complete liveness check: $e';
      });
      widget.onError?.call(_errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.obsidian,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Camera preview or status
            Expanded(
              child: _buildContent(),
            ),

            // Instructions and progress
            if (_state == LivenessCheckState.ready ||
                _state == LivenessCheckState.processing)
              _buildInstructions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const AppText(
            'Liveness Check',
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
          ),
          if (_state != LivenessCheckState.completed)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: widget.onCancel,
              color: AppColors.textSecondary,
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_state) {
      case LivenessCheckState.initializing:
        return _buildLoadingView('Initializing camera...');

      case LivenessCheckState.ready:
      case LivenessCheckState.processing:
        return _buildCameraPreview();

      case LivenessCheckState.completed:
        return _buildSuccessView();

      case LivenessCheckState.failed:
        return _buildErrorView();
    }
  }

  Widget _buildLoadingView(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.gold500,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppText(
            message,
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoadingView('Starting camera...');
    }

    return Stack(
      children: [
        // Camera preview
        Center(
          child: AspectRatio(
            aspectRatio: _cameraController!.value.aspectRatio,
            child: CameraPreview(_cameraController!),
          ),
        ),

        // Face overlay guide
        Center(
          child: Container(
            width: 250,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(
                color: _state == LivenessCheckState.processing
                    ? AppColors.gold500
                    : AppColors.textPrimary.withOpacity(0.5),
                width: 3,
              ),
              borderRadius: BorderRadius.circular(AppRadius.xxl),
            ),
          ),
        ),

        // Processing indicator
        if (_state == LivenessCheckState.processing)
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
                  color: AppColors.gold500.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: const AppText(
                  'Processing...',
                  variant: AppTextVariant.labelMedium,
                  color: AppColors.obsidian,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructions() {
    if (_currentChallenge == null) return const SizedBox();

    final progress = _allChallenges.isNotEmpty
        ? '${_currentChallengeIndex + 1}/${_allChallenges.length}'
        : '';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.slate,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        children: [
          // Progress indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _allChallenges.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: index <= _currentChallengeIndex
                      ? AppColors.gold500
                      : AppColors.borderSubtle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Current challenge instruction
          AppText(
            _currentChallenge!.instruction,
            variant: AppTextVariant.titleMedium,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress text
          AppText(
            'Step $progress',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Tip
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.infoBase,
                size: 16,
              ),
              const SizedBox(width: AppSpacing.xs),
              AppText(
                'Position your face in the frame',
                variant: AppTextVariant.bodySmall,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
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
          const AppText(
            'Liveness Check Complete',
            variant: AppTextVariant.headlineSmall,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.md),
          const AppText(
            'Your identity has been verified',
            variant: AppTextVariant.bodyMedium,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
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
            const AppText(
              'Liveness Check Failed',
              variant: AppTextVariant.headlineSmall,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              _errorMessage ?? 'Please try again',
              variant: AppTextVariant.bodyMedium,
              color: AppColors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Try Again',
              onPressed: () {
                setState(() {
                  _state = LivenessCheckState.initializing;
                  _sessionId = null;
                  _currentChallenge = null;
                  _currentChallengeIndex = 0;
                  _errorMessage = null;
                });
                _initializeCamera();
              },
              variant: AppButtonVariant.primary,
            ),
          ],
        ),
      ),
    );
  }
}
