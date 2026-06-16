import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Liveness challenge types
enum LivenessChallengeType { blink, smile, turnLeft, turnRight, lookUp, nod }

enum LivenessCaptureMode { photo, video }

extension LivenessCaptureModeExt on LivenessCaptureMode {
  String get value {
    switch (this) {
      case LivenessCaptureMode.photo:
        return 'photo';
      case LivenessCaptureMode.video:
        return 'video';
    }
  }

  static LivenessCaptureMode fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'video':
        return LivenessCaptureMode.video;
      case 'photo':
      default:
        return LivenessCaptureMode.photo;
    }
  }
}

class LivenessClientCapabilities {
  final List<LivenessCaptureMode> supportedCaptureModes;
  final LivenessCaptureMode preferredCaptureMode;
  final List<String> supportedMimeTypes;
  final int? maxVideoDurationSeconds;
  final bool supportsOnDeviceFaceDetection;
  final bool supportsReferenceSelfie;

  const LivenessClientCapabilities({
    this.supportedCaptureModes = const [LivenessCaptureMode.photo],
    this.preferredCaptureMode = LivenessCaptureMode.photo,
    this.supportedMimeTypes = const ['image/jpeg'],
    this.maxVideoDurationSeconds,
    this.supportsOnDeviceFaceDetection = false,
    this.supportsReferenceSelfie = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'supportedCaptureModes': supportedCaptureModes
          .map((mode) => mode.value)
          .toList(),
      'preferredCaptureMode': preferredCaptureMode.value,
      'supportedMimeTypes': supportedMimeTypes,
      if (maxVideoDurationSeconds != null)
        'maxVideoDurationSeconds': maxVideoDurationSeconds,
      'supportsOnDeviceFaceDetection': supportsOnDeviceFaceDetection,
      'supportsReferenceSelfie': supportsReferenceSelfie,
    };
  }
}

extension LivenessChallengeTypeExt on LivenessChallengeType {
  String get value {
    switch (this) {
      case LivenessChallengeType.blink:
        return 'BLINK';
      case LivenessChallengeType.smile:
        return 'SMILE';
      case LivenessChallengeType.turnLeft:
        return 'TURN_LEFT';
      case LivenessChallengeType.turnRight:
        return 'TURN_RIGHT';
      case LivenessChallengeType.lookUp:
        return 'LOOK_UP';
      case LivenessChallengeType.nod:
        return 'NOD';
    }
  }

  static LivenessChallengeType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'BLINK':
        return LivenessChallengeType.blink;
      case 'SMILE':
        return LivenessChallengeType.smile;
      case 'TURN_LEFT':
        return LivenessChallengeType.turnLeft;
      case 'TURN_RIGHT':
        return LivenessChallengeType.turnRight;
      case 'LOOK_UP':
        return LivenessChallengeType.lookUp;
      case 'NOD':
        return LivenessChallengeType.nod;
      default:
        return LivenessChallengeType.blink;
    }
  }
}

/// A single liveness challenge
class LivenessChallenge {
  final String challengeId;
  final LivenessChallengeType type;
  final String instruction;
  final LivenessCaptureMode requiredCaptureMode;
  final List<LivenessCaptureMode> acceptedCaptureModes;

  const LivenessChallenge({
    required this.challengeId,
    required this.type,
    required this.instruction,
    this.requiredCaptureMode = LivenessCaptureMode.photo,
    this.acceptedCaptureModes = const [LivenessCaptureMode.photo],
  });

  factory LivenessChallenge.fromJson(Map<String, dynamic> json) {
    return LivenessChallenge(
      challengeId: (json['id'] ?? json['challengeId']) as String,
      type: LivenessChallengeTypeExt.fromString(json['type'] as String),
      instruction: json['instruction'] as String,
      requiredCaptureMode: LivenessCaptureModeExt.fromString(
        json['requiredCaptureMode'] as String?,
      ),
      acceptedCaptureModes:
          (json['acceptedCaptureModes'] as List<dynamic>?)
              ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
              .toList() ??
          const [LivenessCaptureMode.photo],
    );
  }
}

/// Liveness session with challenges
class LivenessSession {
  final String sessionToken;
  final List<LivenessChallenge> challenges;
  final LivenessCaptureMode requiredCaptureMode;
  final List<LivenessCaptureMode> acceptedCaptureModes;
  final List<String> requiredEvidence;

  const LivenessSession({
    required this.sessionToken,
    required this.challenges,
    this.requiredCaptureMode = LivenessCaptureMode.photo,
    this.acceptedCaptureModes = const [LivenessCaptureMode.photo],
    this.requiredEvidence = const ['challenge_photo', 'reference_selfie'],
  });

  factory LivenessSession.fromJson(Map<String, dynamic> json) {
    final challengesData = json['challenges'] as List<dynamic>? ?? [];
    return LivenessSession(
      sessionToken: json['sessionToken'] as String,
      challenges: challengesData
          .map((e) => LivenessChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredCaptureMode: LivenessCaptureModeExt.fromString(
        json['requiredCaptureMode'] as String?,
      ),
      acceptedCaptureModes:
          (json['acceptedCaptureModes'] as List<dynamic>?)
              ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
              .toList() ??
          const [LivenessCaptureMode.photo],
      requiredEvidence:
          (json['requiredEvidence'] as List<dynamic>?)
              ?.map((evidence) => '$evidence')
              .toList() ??
          const ['challenge_photo', 'reference_selfie'],
    );
  }
}

/// Result of submitting a single challenge photo
class ChallengeSubmitResult {
  final String sessionToken;
  final String status;
  final int challengesCompleted;
  final int challengesTotal;
  final bool? isAlive;
  final int? confidence;
  final ChallengeVerificationResult? result;

  const ChallengeSubmitResult({
    required this.sessionToken,
    required this.status,
    required this.challengesCompleted,
    required this.challengesTotal,
    this.isAlive,
    this.confidence,
    this.result,
  });

  bool get allComplete => challengesCompleted == challengesTotal;

  factory ChallengeSubmitResult.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmitResult(
      sessionToken: json['sessionToken'] as String,
      status: json['status'] as String,
      challengesCompleted: json['challengesCompleted'] as int,
      challengesTotal: json['challengesTotal'] as int,
      isAlive: json['isAlive'] as bool?,
      confidence: json['confidence'] as int?,
      result: json['result'] != null
          ? ChallengeVerificationResult.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Final verification result after all challenges
class ChallengeVerificationResult {
  final bool isAlive;
  final int confidence;
  final int antiSpoofScore;
  final int faceMatchScore;
  final String? failureReason;

  const ChallengeVerificationResult({
    required this.isAlive,
    required this.confidence,
    required this.antiSpoofScore,
    required this.faceMatchScore,
    this.failureReason,
  });

  factory ChallengeVerificationResult.fromJson(Map<String, dynamic> json) {
    return ChallengeVerificationResult(
      isAlive: json['isAlive'] as bool,
      confidence: json['confidence'] as int,
      antiSpoofScore: json['antiSpoofScore'] as int,
      faceMatchScore: json['faceMatchScore'] as int,
      failureReason: json['failureReason'] as String?,
    );
  }
}

/// Liveness decision based on confidence score
enum LivenessDecision {
  /// High confidence (≥85%) — auto-approve
  autoApprove,

  /// Medium confidence (50-84%) — manual review required
  manualReview,

  /// Low confidence (<50%) — decline
  decline,
}

/// Evaluate liveness score and return decision
LivenessDecision evaluateLivenessScore(double confidence) {
  if (confidence >= 0.85) return LivenessDecision.autoApprove;
  if (confidence >= 0.50) return LivenessDecision.manualReview;
  return LivenessDecision.decline;
}

/// Liveness result (for widget callback)
class LivenessResult {
  final String sessionId;
  final bool isLive;
  final double confidence;
  final double? faceMatchScore;
  final DateTime completedAt;
  final String? failureReason;

  const LivenessResult({
    required this.sessionId,
    required this.isLive,
    required this.confidence,
    this.faceMatchScore,
    required this.completedAt,
    this.failureReason,
  });

  /// Get the decision based on confidence score
  LivenessDecision get decision => evaluateLivenessScore(confidence);
}

/// Liveness detection service — challenge-based photo flow
///
/// Flow:
/// 1. createSession() → get sessionToken + 2-3 challenges
/// 2. For each challenge: capture photo → submitChallenge()
/// 3. Last submission auto-verifies and returns final result
class LivenessService {
  final Dio _dio;

  LivenessService(this._dio);

  /// Create a new liveness session
  /// Returns sessionToken + list of challenges (2-3)
  Future<LivenessSession> createSession({
    LivenessClientCapabilities capabilities =
        const LivenessClientCapabilities(),
  }) async {
    try {
      final response = await _dio.post(
        '/kyc/liveness/session',
        data: {'capabilities': capabilities.toJson()},
      );
      return LivenessSession.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Submit a photo for a specific challenge
  /// Returns progress and final result when all challenges complete
  Future<ChallengeSubmitResult> submitChallenge({
    required String sessionToken,
    required String challengeId,
    required String photoPath,
    LivenessCaptureMode captureMode = LivenessCaptureMode.photo,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final formData = FormData.fromMap({
        'sessionToken': sessionToken,
        'challengeId': challengeId,
        'captureMode': captureMode.value,
        'mediaType': captureMode.value,
        'mimeType': mimeType,
        'photo': await MultipartFile.fromFile(
          photoPath,
          filename: 'challenge.jpg',
          contentType: DioMediaType.parse(mimeType),
        ),
      });

      final response = await _dio.post(
        '/kyc/liveness/challenge',
        data: formData,
      );
      return ChallengeSubmitResult.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get liveness status
  Future<LivenessResult?> getLivenessStatus() async {
    try {
      final response = await _dio.get('/kyc/liveness/status');
      final data = response.data as Map<String, dynamic>;

      if (data['status'] == 'NOT_STARTED') return null;

      return LivenessResult(
        sessionId: data['id'] as String? ?? '',
        isLive: data['isAlive'] as bool? ?? false,
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        completedAt: DateTime.now(),
        failureReason: data['status'] == 'FAILED'
            ? 'Liveness check failed'
            : null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> cancelSession(String sessionId) async {
    // No cancel endpoint — no-op
  }
}

/// Liveness Service Provider
final livenessServiceProvider = Provider<LivenessService>((ref) {
  return LivenessService(ref.watch(dioProvider));
});
