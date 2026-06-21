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
typedef LivenessManualReviewHandler =
    void Function(LivenessManualReviewRequest request);

class LivenessManualReviewRequest {
  final String reason;
  final String message;
  final String? title;
  final String? slaLabel;
  final String? backendReviewId;
  final String? backendReviewStatus;

  const LivenessManualReviewRequest({
    required this.reason,
    required this.message,
    this.title,
    this.slaLabel,
    this.backendReviewId,
    this.backendReviewStatus,
  });

  bool get backendReviewAlreadyCreated =>
      backendReviewId != null || backendReviewStatus == 'manual_review';
}

class LivenessCheckWidget extends ConsumerStatefulWidget {
  final void Function(LivenessResult result)? onComplete;
  final LivenessManualReviewHandler? onManualReviewRequired;
  final VoidCallback? onManualReviewAcknowledged;
  final VoidCallback? onCancel;
  final bool useRecoveryToken;
  final bool showHeader;

  const LivenessCheckWidget({
    super.key,
    this.onComplete,
    this.onManualReviewRequired,
    this.onManualReviewAcknowledged,
    this.onCancel,
    this.useRecoveryToken = false,
    this.showHeader = true,
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

class _LivenessCheckWidgetState extends ConsumerState<LivenessCheckWidget>
    with WidgetsBindingObserver {
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
  bool _systemCameraAccessGranted = false;
  bool _waitingForCameraSettings = false;
  int _cameraStartAttemptsAfterPermission = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_start());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_releaseCamera());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed ||
        !_waitingForCameraSettings ||
        !mounted ||
        _state != _LivenessState.cameraPermissionRequired) {
      return;
    }

    _waitingForCameraSettings = false;
    unawaited(_retryCameraAccess(trustSystemSettings: true));
  }

  Future<void> _start({bool trustSystemSettings = false}) async {
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

    final cameraReady = await _initializeCamera(
      trustSystemSettings: trustSystemSettings,
    );
    if (mounted && cameraReady && _cameraController != null) {
      setState(() {
        _state = _LivenessState.ready;
        _statusMessage = 'Follow the liveness challenge';
      });
    }
  }

  Future<bool> _initializeCamera({bool trustSystemSettings = false}) async {
    setState(
      () => _statusMessage = trustSystemSettings
          ? 'Checking camera access...'
          : 'Initializing camera...',
    );

    try {
      if (!await _ensureCameraPermission()) {
        return false;
      }

      final cameras = await availableCameras().timeout(
        const Duration(seconds: 8),
      );
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

      await _cameraController!.initialize().timeout(
        const Duration(seconds: 12),
      );
      _cameraStartAttemptsAfterPermission = 0;
      if (mounted) setState(() {});
      return true;
    } catch (e) {
      await _releaseCamera();
      if (_isCameraPermissionException(e)) {
        final latestPermissionStatus = await ph.Permission.camera.status;
        final systemAllowsCamera =
            latestPermissionStatus.isGranted ||
            latestPermissionStatus.isLimited;
        _systemCameraAccessGranted = systemAllowsCamera;
        if (systemAllowsCamera) {
          _cameraStartAttemptsAfterPermission += 1;
          if (_cameraStartAttemptsAfterPermission >= 2 &&
              widget.onManualReviewRequired != null) {
            _fail(
              'Camera access is allowed, but this device could not start the camera safely. A Korido reviewer can continue this flow.',
              manualReviewReason:
                  'camera_initialization_failed_after_permission',
              manualReviewTitle: 'Manual review needed',
            );
            return false;
          }

          _showCameraPermissionRequired(
            permanentlyDenied: false,
            message:
                'Camera access is allowed, but this device could not start the camera safely. Try once more, or continue with manual review.',
          );
          return false;
        }
        _showCameraPermissionRequired(
          permanentlyDenied:
              !systemAllowsCamera &&
              (trustSystemSettings || _cameraExceptionNeedsSettings(e)),
          message: systemAllowsCamera
              ? 'Camera access is allowed, but the camera did not start. Try again; if it keeps failing, continue with manual review.'
              : trustSystemSettings
              ? 'Camera is still unavailable for this Korido build. Confirm camera access in Settings, then return to continue.'
              : 'Korido needs camera access to complete this face and liveness check.',
        );
        return false;
      }

      _fail(
        'Camera initialization failed.',
        manualReviewReason: 'camera_initialization_failed',
      );
      return false;
    }
  }

  Future<bool> _ensureCameraPermission() async {
    final currentStatus = await ph.Permission.camera.status;
    _systemCameraAccessGranted =
        currentStatus.isGranted || currentStatus.isLimited;
    if (currentStatus.isGranted || currentStatus.isLimited) {
      if (mounted) {
        setState(() {
          _cameraPermissionPermanentlyDenied = false;
          _systemCameraAccessGranted = true;
          _errorMessage = null;
        });
      }
      return true;
    }

    if (mounted) {
      setState(() => _statusMessage = 'Requesting camera permission...');
    }

    final requestedStatus = await ph.Permission.camera.request();
    _systemCameraAccessGranted =
        requestedStatus.isGranted || requestedStatus.isLimited;
    if (requestedStatus.isGranted || requestedStatus.isLimited) {
      if (mounted) {
        setState(() {
          _statusMessage = 'Camera access allowed...';
          _cameraPermissionPermanentlyDenied = false;
          _systemCameraAccessGranted = true;
          _errorMessage = null;
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
      return true;
    }

    if (!mounted) {
      return false;
    }

    _showCameraPermissionRequired(
      permanentlyDenied:
          currentStatus.isPermanentlyDenied ||
          currentStatus.isRestricted ||
          requestedStatus.isPermanentlyDenied ||
          requestedStatus.isRestricted ||
          (Platform.isIOS && requestedStatus.isDenied),
      message:
          'Korido needs camera access to complete this face and liveness check.',
    );
    return false;
  }

  bool _isCameraPermissionException(Object error) {
    if (error is! CameraException) return false;
    final code = error.code.toLowerCase();
    final description = error.description?.toLowerCase() ?? '';
    return code.contains('accessdenied') ||
        code.contains('accessrestricted') ||
        description.contains('permission') ||
        description.contains('access');
  }

  bool _cameraExceptionNeedsSettings(Object error) {
    if (error is! CameraException) return false;
    final code = error.code.toLowerCase();
    return code.contains('withoutprompt') || code.contains('restricted');
  }

  void _showCameraPermissionRequired({
    required bool permanentlyDenied,
    required String message,
  }) {
    if (!mounted) return;
    setState(() {
      _state = _LivenessState.cameraPermissionRequired;
      _statusMessage = 'Camera permission needed';
      _cameraPermissionPermanentlyDenied = permanentlyDenied;
      if (permanentlyDenied) {
        _systemCameraAccessGranted = false;
      }
      _errorMessage = message;
    });
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
            _unsupportedCaptureMessage(unsupportedChallenge),
            manualReviewReason: _unsupportedCaptureReason(unsupportedChallenge),
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
        backendReviewId: review.backendReviewId,
        backendReviewStatus: review.backendReviewStatus,
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

    String? tempPhotoPath;
    try {
      final photo = await _cameraController!.takePicture();
      tempPhotoPath = photo.path;

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
          _unsupportedCaptureMessage(challenge),
          manualReviewReason: _unsupportedCaptureReason(challenge),
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
              confidence: verification.confidence,
              faceMatchScore: verification.faceMatchScore,
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
      if (tempPhotoPath != null) {
        await _deleteTempPhoto(tempPhotoPath);
      }
      final review = _manualReviewFromError(e);
      _fail(
        review.message,
        manualReviewReason: review.reason,
        manualReviewTitle: review.title,
        manualReviewSlaLabel: review.slaLabel,
        backendReviewId: review.backendReviewId,
        backendReviewStatus: review.backendReviewStatus,
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
    if (challenge.recommendedCaptureMode == LivenessCaptureMode.video) {
      return true;
    }
    if (challenge.requiresMotionEvidence) {
      return true;
    }
    if (challenge.manualReviewRecommended) {
      return true;
    }
    return !challenge.acceptedCaptureModes.contains(LivenessCaptureMode.photo);
  }

  String _unsupportedCaptureReason(LivenessChallenge challenge) {
    if (challenge.manualReviewReason != null) {
      return challenge.manualReviewReason!;
    }
    if (challenge.requiresMotionEvidence ||
        challenge.recommendedCaptureMode == LivenessCaptureMode.video ||
        challenge.requiredCaptureMode == LivenessCaptureMode.video) {
      return 'motion_liveness_requires_video_evidence';
    }
    return 'liveness_capture_mode_unsupported';
  }

  String _unsupportedCaptureMessage(LivenessChallenge challenge) {
    final challengeName = challenge.type.value
        .replaceAll('_', ' ')
        .toLowerCase();
    if (challenge.requiresMotionEvidence) {
      return 'This liveness challenge requires motion evidence for $challengeName, but this device flow currently supports photo capture only.';
    }
    return 'This liveness challenge requires ${challenge.recommendedCaptureMode.value} evidence for $challengeName, but this device flow currently supports photo capture only.';
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
    String? backendReviewId,
    String? backendReviewStatus,
  }) {
    if (mounted) {
      unawaited(_releaseCamera());
      if (manualReviewReason != null && widget.onManualReviewRequired != null) {
        widget.onManualReviewRequired?.call(
          LivenessManualReviewRequest(
            reason: manualReviewReason,
            message: message,
            title: manualReviewTitle,
            slaLabel: manualReviewSlaLabel,
            backendReviewId: backendReviewId,
            backendReviewStatus: backendReviewStatus,
          ),
        );
        return;
      }
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
    }
  }

  ({
    String title,
    String message,
    String reason,
    String? slaLabel,
    String? backendReviewId,
    String? backendReviewStatus,
  })
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
      final backendReviewId = data['kycReviewId']?.toString();
      final backendReviewStatus = data['kycStatus']?.toString();
      final reviewAlreadyCreated =
          backendReviewId != null || backendReviewStatus == 'manual_review';

      return (
        title: reviewAlreadyCreated
            ? 'Manual review started'
            : 'Manual review needed',
        message: supportReviewRequired
            ? error.message
            : 'We could not safely start the automated identity check. A Korido reviewer will continue this flow.',
        reason: reason,
        slaLabel: slaLabel,
        backendReviewId: backendReviewId,
        backendReviewStatus: backendReviewStatus,
      );
    }

    return (
      title: 'Manual review needed',
      message:
          'We could not safely start the automated identity check. A Korido reviewer will continue this flow.',
      reason: 'liveness_session_unavailable',
      slaLabel: null,
      backendReviewId: null,
      backendReviewStatus: null,
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

  Future<void> _openCameraSettings() async {
    _waitingForCameraSettings = true;
    final opened = await ph.openAppSettings();
    if (!opened) {
      _waitingForCameraSettings = false;
    }
  }

  Future<void> _retryCameraAccess({bool trustSystemSettings = false}) async {
    if (!mounted) return;
    if (trustSystemSettings) {
      _waitingForCameraSettings = false;
    }

    setState(() {
      _state = _LivenessState.initializing;
      _statusMessage = trustSystemSettings
          ? 'Checking camera access...'
          : 'Requesting camera permission...';
      _errorMessage = null;
      _cameraPermissionPermanentlyDenied = false;
    });

    await _releaseCamera();
    if (!mounted) return;

    if (_sessionToken == null || _challenges.isEmpty) {
      await _start(trustSystemSettings: trustSystemSettings);
      return;
    }

    final cameraReady = await _initializeCamera(
      trustSystemSettings: trustSystemSettings,
    );
    if (mounted && cameraReady && _cameraController != null) {
      setState(() {
        _state = _LivenessState.ready;
        _statusMessage = 'Follow the liveness challenge';
      });
    }
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
      _systemCameraAccessGranted = false;
      _cameraStartAttemptsAfterPermission = 0;
      _sessionToken = null;
      _challenges = [];
      _submittedEvidence.clear();
      _evidencePolicy = const LivenessEvidencePolicy();
      _currentChallengeIndex = 0;
    });
    unawaited(_start());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.canvas,
      child: SafeArea(
        child: Column(
          children: [
            if (widget.showHeader) _buildHeader(colors),
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
    final needsSettings =
        _cameraPermissionPermanentlyDenied && !_systemCameraAccessGranted;
    final title = _systemCameraAccessGranted
        ? 'Camera could not start'
        : 'Camera permission needed';

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
              title,
              variant: AppTextVariant.titleMedium,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w700,
            ),
            const SizedBox(height: AppSpacing.sm),
            AppText(
              needsSettings
                  ? 'Camera access is disabled for Korido. Open Settings, allow camera access, then return to continue.'
                  : _errorMessage ??
                        'Korido needs camera access to complete this face and liveness check.',
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: needsSettings
                  ? 'Open Settings'
                  : _systemCameraAccessGranted
                  ? 'Try camera again'
                  : 'Allow camera access',
              onPressed: needsSettings
                  ? () => unawaited(_openCameraSettings())
                  : () => unawaited(
                      _retryCameraAccess(
                        trustSystemSettings: _systemCameraAccessGranted,
                      ),
                    ),
              isFullWidth: true,
            ),
            if (needsSettings) ...[
              const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: 'I allowed access',
                variant: AppButtonVariant.secondary,
                onPressed: () =>
                    unawaited(_retryCameraAccess(trustSystemSettings: true)),
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
