import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config_provider.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';

/// Challenge-based liveness check widget
///
/// Flow:
/// 1. Create session → get 2-3 challenges
/// 2. Show each challenge instruction + camera preview
/// 3. User taps capture → photo taken → submitted to backend
/// 4. After all challenges → backend verifies → result returned
class LivenessCheckWidget extends ConsumerStatefulWidget {
  final void Function(LivenessResult result)? onComplete;
  final void Function(String reason)? onManualReviewRequired;
  final VoidCallback? onCancel;

  const LivenessCheckWidget({
    super.key,
    this.onComplete,
    this.onManualReviewRequired,
    this.onCancel,
  });

  @override
  ConsumerState<LivenessCheckWidget> createState() =>
      _LivenessCheckWidgetState();
}

enum _LivenessState {
  initializing,
  ready,
  capturing,
  uploading,
  processing,
  completed,
  failed,
}

class _LivenessCheckWidgetState extends ConsumerState<LivenessCheckWidget> {
  CameraController? _cameraController;
  _LivenessState _state = _LivenessState.initializing;
  String _statusMessage = 'Initializing...';

  String? _sessionToken;
  List<LivenessChallenge> _challenges = [];
  final List<LivenessEvidenceMetadata> _submittedEvidence = [];
  LivenessEvidencePolicy _evidencePolicy = const LivenessEvidencePolicy();
  int _currentChallengeIndex = 0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final isSimulator = ref.read(isSimulatorProvider);
    final mockCamera = ref.read(mockCameraProvider);

    if (isSimulator || mockCamera) {
      await _completeMockLiveness();
      return;
    }

    await _initializeCamera();
    if (mounted && _cameraController != null) {
      await _createSession();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() => _statusMessage = 'Initializing camera...');

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!kReleaseMode) {
          await _completeMockLiveness();
          return;
        }
        _fail('No cameras available');
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
      if (mounted) setState(() {});
    } catch (e) {
      _fail('Camera initialization failed: $e');
    }
  }

  Future<void> _completeMockLiveness() async {
    if (!mounted) return;

    widget.onComplete?.call(
      LivenessResult(
        sessionId: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
        isLive: true,
        confidence: 0.99,
        faceMatchScore: 1.0,
        completedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _createSession() async {
    setState(() => _statusMessage = 'Creating liveness session...');

    try {
      final livenessService = ref.read(livenessServiceProvider);
      final session = await livenessService.createSession(
        capabilities: const LivenessClientCapabilities(
          supportedCaptureModes: [LivenessCaptureMode.photo],
          preferredCaptureMode: LivenessCaptureMode.photo,
          supportedMimeTypes: ['image/jpeg'],
          supportsOnDeviceFaceDetection: false,
          supportsReferenceSelfie: true,
        ),
      );

      if (mounted) {
        if (session.evidencePolicy.requiredCaptureMode !=
            LivenessCaptureMode.photo) {
          _fail(
            'This liveness check requires ${session.evidencePolicy.requiredCaptureMode.value} evidence, but this device flow currently supports photo capture only.',
            manualReviewReason: 'liveness_capture_mode_unsupported',
          );
          return;
        }
        final unsupportedChallenge = _firstUnsupportedChallenge(
          session.challenges,
        );
        if (unsupportedChallenge != null) {
          _fail(
            'This liveness check requires ${unsupportedChallenge.recommendedCaptureMode.value} evidence for ${unsupportedChallenge.type.value}, but this device flow currently supports photo capture only.',
            manualReviewReason:
                unsupportedChallenge.manualReviewReason ??
                'liveness_motion_capture_unsupported',
          );
          return;
        }

        setState(() {
          _sessionToken = session.sessionToken;
          _challenges = session.challenges;
          _evidencePolicy = session.evidencePolicy;
          _currentChallengeIndex = 0;
          _state = _LivenessState.ready;
        });
      }
    } catch (e) {
      _fail(
        'Failed to create liveness session: $e',
        manualReviewReason: 'liveness_session_unavailable',
      );
    }
  }

  Future<void> _captureAndSubmit() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_state == _LivenessState.capturing ||
        _state == _LivenessState.uploading)
      return;

    setState(() {
      _state = _LivenessState.capturing;
      _statusMessage = 'Capturing photo...';
    });

    try {
      final photo = await _cameraController!.takePicture();

      setState(() {
        _state = _LivenessState.uploading;
        _statusMessage =
            'Submitting challenge ${_currentChallengeIndex + 1} of ${_challenges.length}...';
      });

      final livenessService = ref.read(livenessServiceProvider);
      final challenge = _challenges[_currentChallengeIndex];
      if (_requiresUnsupportedCapture(challenge)) {
        _fail(
          'This challenge requires ${challenge.recommendedCaptureMode.value} evidence, but this device flow currently supports photo capture only.',
          manualReviewReason:
              challenge.manualReviewReason ??
              'liveness_motion_capture_unsupported',
        );
        return;
      }
      final captureMode =
          challenge.acceptedCaptureModes.contains(LivenessCaptureMode.photo)
          ? LivenessCaptureMode.photo
          : _evidencePolicy.requiredCaptureMode;

      if (captureMode != LivenessCaptureMode.photo) {
        _fail(
          'This challenge requires ${captureMode.value} evidence, but this device flow currently supports photo capture only.',
          manualReviewReason: 'liveness_capture_mode_unsupported',
        );
        return;
      }

      final result = await livenessService.submitChallenge(
        sessionToken: _sessionToken!,
        challengeId: challenge.challengeId,
        photoPath: photo.path,
        captureMode: captureMode,
        mimeType: 'image/jpeg',
      );
      if (result.evidence != null) {
        _submittedEvidence.add(result.evidence!);
      }

      // Clean up temp photo
      try {
        File(photo.path).deleteSync();
      } catch (_) {}

      if (!mounted) return;

      if (result.allComplete && result.result != null) {
        // All challenges done — show result
        setState(() {
          _state = result.result!.isAlive
              ? _LivenessState.completed
              : _LivenessState.failed;
          _statusMessage = result.result!.isAlive
              ? 'Verification passed!'
              : 'Verification failed';
          _errorMessage = result.result!.failureReason;
        });

        if (result.result!.isAlive) {
          widget.onComplete?.call(
            LivenessResult(
              sessionId: result.sessionToken,
              livenessProofId: result.livenessProofId,
              isLive: true,
              confidence: result.result!.confidence / 100.0,
              faceMatchScore: result.result!.faceMatchScore / 100.0,
              completedAt: DateTime.now(),
              evidence: List.unmodifiable(_submittedEvidence),
            ),
          );
        }
      } else {
        // Move to next challenge
        setState(() {
          _currentChallengeIndex++;
          _state = _LivenessState.ready;
        });
      }
    } catch (e) {
      _fail(
        'Challenge submission failed: $e',
        manualReviewReason: 'liveness_challenge_unavailable',
      );
    }
  }

  bool _requiresUnsupportedCapture(LivenessChallenge challenge) {
    if (challenge.requiredCaptureMode == LivenessCaptureMode.video) {
      return true;
    }
    return challenge.manualReviewRecommended &&
        challenge.recommendedCaptureMode == LivenessCaptureMode.video &&
        !challenge.acceptedCaptureModes.contains(LivenessCaptureMode.video);
  }

  LivenessChallenge? _firstUnsupportedChallenge(
    List<LivenessChallenge> challenges,
  ) {
    for (final challenge in challenges) {
      if (_requiresUnsupportedCapture(challenge)) {
        return challenge;
      }
    }
    return null;
  }

  void _fail(String message, {String? manualReviewReason}) {
    if (mounted) {
      setState(() {
        _state = _LivenessState.failed;
        _statusMessage = 'Verification failed';
        _errorMessage = message;
      });
      if (manualReviewReason != null) {
        widget.onManualReviewRequired?.call(manualReviewReason);
      }
    }
  }

  void _retry() {
    setState(() {
      _state = _LivenessState.initializing;
      _statusMessage = 'Initializing...';
      _errorMessage = null;
      _sessionToken = null;
      _challenges = [];
      _submittedEvidence.clear();
      _evidencePolicy = const LivenessEvidencePolicy();
      _currentChallengeIndex = 0;
    });
    _start();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            Expanded(child: _buildContent(colors)),
            if (_state == _LivenessState.ready) _buildCaptureButton(colors),
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
          if (_state != _LivenessState.completed)
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
      case _LivenessState.initializing:
        return _buildLoading(colors, _statusMessage);

      case _LivenessState.ready:
        return _buildCameraWithChallenge(colors);

      case _LivenessState.capturing:
      case _LivenessState.uploading:
      case _LivenessState.processing:
        return _buildCameraWithProgress(colors);

      case _LivenessState.completed:
        return _buildSuccess(colors);

      case _LivenessState.failed:
        return _buildFailure(colors);
    }
  }

  Widget _buildLoading(ThemeColors colors, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: colors.gold),
          const SizedBox(height: AppSpacing.md),
          AppText(message, color: colors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildCameraWithChallenge(ThemeColors colors) {
    final challenge = _challenges[_currentChallengeIndex];

    return Column(
      children: [
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: List.generate(_challenges.length, (i) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: i < _currentChallengeIndex
                        ? colors.success
                        : i == _currentChallengeIndex
                        ? colors.gold
                        : colors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.xxs),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Challenge instruction
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              AppText(
                'Challenge ${_currentChallengeIndex + 1} of ${_challenges.length}',
                variant: AppTextVariant.labelSmall,
                color: colors.textSecondary,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppText(
                challenge.instruction,
                variant: AppTextVariant.titleSmall,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Camera preview
        Expanded(child: _buildCameraPreview(colors)),
      ],
    );
  }

  Widget _buildCameraPreview(ThemeColors colors) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return _buildLoading(colors, 'Camera not ready');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: CameraPreview(_cameraController!),
        ),
      ),
    );
  }

  Widget _buildCameraWithProgress(ThemeColors colors) {
    return Stack(
      children: [
        _buildCameraWithChallenge(colors),
        Positioned.fill(
          child: Container(
            color: Colors.black54,
            child: _buildLoading(colors, _statusMessage),
          ),
        ),
      ],
    );
  }

  Widget _buildCaptureButton(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: GestureDetector(
        onTap: _captureAndSubmit,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colors.gold, width: 4),
          ),
          child: Container(
            margin: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colors.gold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccess(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 80, color: colors.success),
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Liveness Verified!',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          const SizedBox(height: AppSpacing.xs),
          AppText(
            'Your identity has been confirmed',
            color: colors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFailure(ThemeColors colors) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 80, color: colors.error),
          const SizedBox(height: AppSpacing.md),
          AppText(
            'Liveness Check Failed',
            variant: AppTextVariant.titleMedium,
            color: colors.textPrimary,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: AppText(
                _errorMessage!,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: AppLocalizations.of(context)!.liveness_tryAgain,
            onPressed: _retry,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: widget.onCancel,
            child: Text(
              AppLocalizations.of(context)!.liveness_goBack,
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
