import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config_provider.dart';
import 'package:usdc_wallet/services/api/api_client.dart' show ApiException;
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
  final VoidCallback? onManualReviewAcknowledged;
  final VoidCallback? onCancel;
  final bool useRecoveryToken;

  const LivenessCheckWidget({
    super.key,
    this.onComplete,
    this.onManualReviewRequired,
    this.onManualReviewAcknowledged,
    this.onCancel,
    this.useRecoveryToken = false,
  });

  @override
  ConsumerState<LivenessCheckWidget> createState() =>
      _LivenessCheckWidgetState();
}

enum _LivenessState {
  initializing,
  cameraPermissionRequired,
  ready,
  capturing,
  uploading,
  processing,
  completed,
  manualReview,
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
  String? _manualReviewReason;
  String? _manualReviewTitle;
  String? _manualReviewSlaLabel;
  bool _cameraPermissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    unawaited(_releaseCamera());
    super.dispose();
  }

  Future<void> _start() async {
    final isSimulator = ref.read(isSimulatorProvider);
    final mockCamera = ref.read(mockCameraProvider);

    if (isSimulator || mockCamera) {
      await _completeMockLiveness();
      return;
    }

    final sessionReady = await _createSession();
    if (!mounted || !sessionReady) {
      return;
    }

    final cameraReady = await _initializeCamera();
    if (mounted && cameraReady && _cameraController != null) {
      setState(() {
        _state = _LivenessState.ready;
        _statusMessage = 'Follow the liveness challenge';
      });
    }
  }

  Future<bool> _initializeCamera() async {
    setState(() => _statusMessage = 'Initializing camera...');

    try {
      final hasPermission = await _ensureCameraPermission();
      if (!hasPermission) {
        return false;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (!kReleaseMode && ref.read(mockCameraProvider)) {
          await _completeMockLiveness();
          return true;
        }
        _fail(
          'No front camera is available on this device.',
          manualReviewReason: 'camera_unavailable',
        );
        return false;
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
      return true;
    } catch (e) {
      _fail(
        'Camera initialization failed.',
        manualReviewReason: 'camera_initialization_failed',
      );
      return false;
    }
  }

  Future<bool> _ensureCameraPermission() async {
    final currentStatus = await ph.Permission.camera.status;
    if (currentStatus.isGranted || currentStatus.isLimited) {
      return true;
    }

    if (mounted) {
      setState(() => _statusMessage = 'Requesting camera permission...');
    }

    final requestedStatus = await ph.Permission.camera.request();
    if (requestedStatus.isGranted || requestedStatus.isLimited) {
      if (mounted) {
        setState(() => _statusMessage = 'Camera access allowed...');
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return true;
    }

    if (!mounted) {
      return false;
    }

    setState(() {
      _state = _LivenessState.cameraPermissionRequired;
      _statusMessage = 'Camera permission needed';
      _cameraPermissionPermanentlyDenied =
          requestedStatus.isPermanentlyDenied || requestedStatus.isRestricted;
      _errorMessage =
          'Korido needs camera access to complete this face and liveness check.';
    });
    return false;
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

  Future<bool> _createSession() async {
    setState(() => _statusMessage = 'Preparing secure liveness session...');

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
        useRecoveryToken: widget.useRecoveryToken,
      );

      if (mounted) {
        if (session.evidencePolicy.requiredCaptureMode !=
            LivenessCaptureMode.photo) {
          _fail(
            'This liveness check requires ${session.evidencePolicy.requiredCaptureMode.value} evidence, but this device flow currently supports photo capture only.',
            manualReviewReason: 'liveness_capture_mode_unsupported',
          );
          return false;
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
          return false;
        }
        if (session.challenges.isEmpty) {
          _fail(
            'The verification provider did not return a liveness challenge.',
            manualReviewReason: 'liveness_challenge_unavailable',
          );
          return false;
        }

        setState(() {
          _sessionToken = session.sessionToken;
          _challenges = session.challenges;
          _evidencePolicy = session.evidencePolicy;
          _currentChallengeIndex = 0;
        });
        return true;
      }
    } catch (e) {
      final review = _manualReviewFromError(e);
      _fail(
        review.message,
        manualReviewReason: review.reason,
        manualReviewTitle: review.title,
        manualReviewSlaLabel: review.slaLabel,
      );
      return false;
    }
    return false;
  }

  Future<void> _captureAndSubmit() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;
    if (_state == _LivenessState.capturing ||
        _state == _LivenessState.uploading)
      return;
    if (_sessionToken == null ||
        _challenges.isEmpty ||
        _currentChallengeIndex >= _challenges.length) {
      _fail(
        'The liveness session is not ready.',
        manualReviewReason: 'liveness_session_not_ready',
      );
      return;
    }

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
        await _deleteTempPhoto(photo.path);
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
        await _deleteTempPhoto(photo.path);
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
        useRecoveryToken: widget.useRecoveryToken,
      );
      if (result.evidence != null) {
        _submittedEvidence.add(result.evidence!);
      }

      // Clean up temp photo
      await _deleteTempPhoto(photo.path);

      if (!mounted) return;

      if (result.allComplete) {
        final verification = result.result;
        if (verification == null) {
          _fail(
            'The verification provider did not return a final liveness decision.',
            manualReviewReason: 'liveness_result_unavailable',
          );
          return;
        }

        await _releaseCamera();
        if (!mounted) return;

        // All challenges done — show result
        setState(() {
          _state = verification.isAlive
              ? _LivenessState.completed
              : _LivenessState.failed;
          _statusMessage = verification.isAlive
              ? 'Verification passed!'
              : 'Verification failed';
          _errorMessage = verification.failureReason;
        });

        if (verification.isAlive) {
          widget.onComplete?.call(
            LivenessResult(
              sessionId: result.sessionToken,
              livenessProofId: result.livenessProofId,
              isLive: true,
              confidence: verification.confidence / 100.0,
              faceMatchScore: verification.faceMatchScore / 100.0,
              completedAt: DateTime.now(),
              evidence: List.unmodifiable(_submittedEvidence),
            ),
          );
        }
      } else {
        final nextChallengeIndex = _currentChallengeIndex + 1;
        if (nextChallengeIndex >= _challenges.length) {
          _fail(
            'The verification provider did not return a final liveness decision after the last challenge.',
            manualReviewReason: 'liveness_result_unavailable',
          );
          return;
        }

        // Move to next challenge
        setState(() {
          _currentChallengeIndex = nextChallengeIndex;
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

  Future<void> _deleteTempPhoto(String path) async {
    try {
      await File(path).delete();
    } catch (_) {}
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

  void _fail(
    String message, {
    String? manualReviewReason,
    String? manualReviewTitle,
    String? manualReviewSlaLabel,
  }) {
    if (mounted) {
      unawaited(_releaseCamera());
      setState(() {
        _state = manualReviewReason == null
            ? _LivenessState.failed
            : _LivenessState.manualReview;
        _statusMessage = manualReviewReason == null
            ? 'Verification failed'
            : 'Manual review needed';
        _errorMessage = message;
        _manualReviewReason = manualReviewReason;
        _manualReviewTitle = manualReviewTitle;
        _manualReviewSlaLabel = manualReviewSlaLabel;
      });
      if (manualReviewReason != null) {
        widget.onManualReviewRequired?.call(manualReviewReason);
      }
    }
  }

  ({String title, String message, String reason, String? slaLabel})
  _manualReviewFromError(Object error) {
    if (error is ApiException) {
      final data = _apiErrorData(error.data);
      final supportReviewRequired = data['supportReviewRequired'] == true;
      final reason =
          data['featureReason']?.toString() ??
          data['reason']?.toString() ??
          error.code ??
          'liveness_session_unavailable';
      final reviewSla = data['reviewSla'];
      final slaLabel = reviewSla is Map ? reviewSla['label']?.toString() : null;

      return (
        title: supportReviewRequired
            ? 'Manual review started'
            : 'Manual review needed',
        message: supportReviewRequired
            ? error.message
            : 'We could not safely start the automated identity check. A Korido reviewer will continue this flow.',
        reason: reason,
        slaLabel: slaLabel,
      );
    }

    return (
      title: 'Manual review needed',
      message:
          'We could not safely start the automated identity check. A Korido reviewer will continue this flow.',
      reason: 'liveness_session_unavailable',
      slaLabel: null,
    );
  }

  Map<String, dynamic> _apiErrorData(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final error = raw['error'];
      if (error is Map) {
        return {...raw, ...Map<String, dynamic>.from(error)};
      }
      return raw;
    }
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw);
      final error = map['error'];
      if (error is Map) {
        return {...map, ...Map<String, dynamic>.from(error)};
      }
      return map;
    }
    return const <String, dynamic>{};
  }

  Future<void> _releaseCamera() async {
    final controller = _cameraController;
    _cameraController = null;
    await controller?.dispose();
  }

  void _acknowledgeManualReview() {
    final acknowledge = widget.onManualReviewAcknowledged;
    if (acknowledge != null) {
      acknowledge();
      return;
    }
    widget.onCancel?.call();
  }

  void _retry() {
    setState(() {
      _state = _LivenessState.initializing;
      _statusMessage = 'Initializing...';
      _errorMessage = null;
      _manualReviewReason = null;
      _manualReviewTitle = null;
      _manualReviewSlaLabel = null;
      _cameraPermissionPermanentlyDenied = false;
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
          if (widget.onCancel != null &&
              _state != _LivenessState.completed &&
              _state != _LivenessState.manualReview)
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

      case _LivenessState.cameraPermissionRequired:
        return _buildCameraPermissionRequired(colors);

      case _LivenessState.ready:
        return _buildCameraWithChallenge(colors);

      case _LivenessState.capturing:
      case _LivenessState.uploading:
      case _LivenessState.processing:
        return _buildCameraWithProgress(colors);

      case _LivenessState.completed:
        return _buildSuccess(colors);

      case _LivenessState.manualReview:
        return _buildManualReview(colors);

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
    if (_challenges.isEmpty || _currentChallengeIndex >= _challenges.length) {
      return _buildLoading(colors, 'Preparing liveness challenge...');
    }

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

  Widget _buildCameraPermissionRequired(ThemeColors colors) {
    final canUseManualReview = widget.onManualReviewRequired != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.goldSubtle,
                border: Border.all(color: colors.borderGold),
              ),
              child: Icon(
                Icons.photo_camera_front_rounded,
                size: 38,
                color: colors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              'Camera permission needed',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              _cameraPermissionPermanentlyDenied
                  ? 'Camera access is disabled for Korido. Open Settings, allow camera access, then return to continue.'
                  : _errorMessage ??
                        'Korido needs camera access to complete this face and liveness check.',
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: _cameraPermissionPermanentlyDenied
                  ? 'Open Settings'
                  : 'Allow camera access',
              onPressed: _cameraPermissionPermanentlyDenied
                  ? () => unawaited(ph.openAppSettings())
                  : _retry,
              isFullWidth: true,
            ),
            if (_cameraPermissionPermanentlyDenied) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'I allowed access',
                variant: AppButtonVariant.secondary,
                onPressed: _retry,
                isFullWidth: true,
              ),
            ],
            if (canUseManualReview) ...[
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => _fail(
                  'Camera permission is unavailable.',
                  manualReviewReason: 'camera_permission_unavailable',
                ),
                child: AppText(
                  'Continue with manual review',
                  variant: AppTextVariant.labelLarge,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
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

  Widget _buildManualReview(ThemeColors colors) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.goldSubtle,
                border: Border.all(color: colors.borderGold),
              ),
              child: Icon(
                Icons.manage_accounts_rounded,
                size: 38,
                color: colors.gold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppText(
              _manualReviewTitle ?? 'Manual review needed',
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              _errorMessage ??
                  'We could not safely complete the automated identity check. A Korido reviewer will use your identity evidence to continue this flow.',
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            if (_manualReviewSlaLabel != null) ...[
              const SizedBox(height: AppSpacing.lg),
              InfoCallout(
                icon: Icons.schedule_rounded,
                title: _manualReviewSlaLabel!,
                tone: InfoCalloutTone.info,
              ),
            ],
            if (_manualReviewReason != null) ...[
              const SizedBox(height: AppSpacing.lg),
              InfoCallout(
                icon: Icons.verified_user_outlined,
                title: 'Reason: ${_manualReviewReason!.replaceAll('_', ' ')}',
                tone: InfoCalloutTone.info,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: 'Continue', onPressed: _acknowledgeManualReview),
          ],
        ),
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
