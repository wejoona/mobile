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

class LivenessSessionCapabilities {
  final List<LivenessCaptureMode> supportedCaptureModes;
  final LivenessCaptureMode preferredCaptureMode;
  final List<String> supportedMimeTypes;
  final int? maxVideoDurationSeconds;
  final bool supportsOnDeviceFaceDetection;
  final bool supportsReferenceSelfie;
  final List<String> supportedChallengeTypes;
  final bool requiresReferenceSelfie;

  const LivenessSessionCapabilities({
    this.supportedCaptureModes = const [LivenessCaptureMode.photo],
    this.preferredCaptureMode = LivenessCaptureMode.photo,
    this.supportedMimeTypes = const ['image/jpeg'],
    this.maxVideoDurationSeconds,
    this.supportsOnDeviceFaceDetection = false,
    this.supportsReferenceSelfie = true,
    this.supportedChallengeTypes = const [],
    this.requiresReferenceSelfie = true,
  });

  factory LivenessSessionCapabilities.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LivenessSessionCapabilities();
    }

    return LivenessSessionCapabilities(
      supportedCaptureModes:
          (json['supportedCaptureModes'] as List<dynamic>?)
              ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
              .toList() ??
          const [LivenessCaptureMode.photo],
      preferredCaptureMode: LivenessCaptureModeExt.fromString(
        json['preferredCaptureMode'] as String?,
      ),
      supportedMimeTypes:
          (json['supportedMimeTypes'] as List<dynamic>?)
              ?.map((mimeType) => '$mimeType')
              .toList() ??
          const ['image/jpeg'],
      maxVideoDurationSeconds: (json['maxVideoDurationSeconds'] as num?)
          ?.toInt(),
      supportsOnDeviceFaceDetection:
          json['supportsOnDeviceFaceDetection'] as bool? ?? false,
      supportsReferenceSelfie:
          json['supportsReferenceSelfie'] as bool? ??
          !(json['requiresReferenceSelfie'] == false),
      supportedChallengeTypes:
          (json['supportedChallengeTypes'] as List<dynamic>?)
              ?.map((type) => '$type')
              .toList() ??
          const [],
      requiresReferenceSelfie: json['requiresReferenceSelfie'] as bool? ?? true,
    );
  }
}

class LivenessEvidencePolicy {
  final LivenessCaptureMode requiredCaptureMode;
  final List<LivenessCaptureMode> acceptedCaptureModes;
  final List<String> supportedMimeTypes;
  final List<String> requiredEvidence;
  final List<String> faceMatchSources;
  final bool manualReviewOnProviderUnavailable;
  final bool requiresReferenceSelfie;
  final bool requiresOnDeviceFaceDetection;

  const LivenessEvidencePolicy({
    this.requiredCaptureMode = LivenessCaptureMode.photo,
    this.acceptedCaptureModes = const [LivenessCaptureMode.photo],
    this.supportedMimeTypes = const ['image/jpeg'],
    this.requiredEvidence = const ['challenge_photo', 'reference_selfie'],
    this.faceMatchSources = const [],
    this.manualReviewOnProviderUnavailable = true,
    this.requiresReferenceSelfie = true,
    this.requiresOnDeviceFaceDetection = false,
  });

  factory LivenessEvidencePolicy.fromJson(
    Map<String, dynamic>? json, {
    required LivenessCaptureMode fallbackRequiredCaptureMode,
    required List<LivenessCaptureMode> fallbackAcceptedCaptureModes,
    required List<String> fallbackRequiredEvidence,
  }) {
    if (json == null) {
      return LivenessEvidencePolicy(
        requiredCaptureMode: fallbackRequiredCaptureMode,
        acceptedCaptureModes: fallbackAcceptedCaptureModes,
        requiredEvidence: fallbackRequiredEvidence,
      );
    }

    final captureModes = json['captureModes'] is Map
        ? Map<String, dynamic>.from(json['captureModes'] as Map)
        : const <String, dynamic>{};
    return LivenessEvidencePolicy(
      requiredCaptureMode: LivenessCaptureModeExt.fromString(
        captureModes['required'] as String?,
      ),
      acceptedCaptureModes:
          (captureModes['accepted'] as List<dynamic>?)
              ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
              .toList() ??
          fallbackAcceptedCaptureModes,
      supportedMimeTypes:
          (json['supportedMimeTypes'] as List<dynamic>?)
              ?.map((mimeType) => '$mimeType')
              .toList() ??
          const ['image/jpeg'],
      requiredEvidence: fallbackRequiredEvidence,
      faceMatchSources:
          (json['faceMatchSources'] as List<dynamic>?)
              ?.map((source) => '$source')
              .toList() ??
          const [],
      manualReviewOnProviderUnavailable:
          json['manualReviewOnProviderUnavailable'] as bool? ?? true,
      requiresReferenceSelfie: json['requiresReferenceSelfie'] as bool? ?? true,
      requiresOnDeviceFaceDetection:
          json['requiresOnDeviceFaceDetection'] as bool? ?? false,
    );
  }
}

class LivenessEvidenceMetadata {
  final String kind;
  final String? challengeId;
  final LivenessCaptureMode captureMode;
  final LivenessCaptureMode mediaType;
  final String? mimeType;
  final int? byteSize;
  final String? provider;
  final String? storage;
  final String? sessionTokenRef;
  final DateTime? submittedAt;
  final List<String> reviewUsage;

  const LivenessEvidenceMetadata({
    required this.kind,
    this.challengeId,
    this.captureMode = LivenessCaptureMode.photo,
    this.mediaType = LivenessCaptureMode.photo,
    this.mimeType,
    this.byteSize,
    this.provider,
    this.storage,
    this.sessionTokenRef,
    this.submittedAt,
    this.reviewUsage = const [],
  });

  factory LivenessEvidenceMetadata.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LivenessEvidenceMetadata(kind: 'unknown');
    }

    return LivenessEvidenceMetadata(
      kind: json['kind'] as String? ?? 'unknown',
      challengeId: json['challengeId'] as String?,
      captureMode: LivenessCaptureModeExt.fromString(
        json['captureMode'] as String?,
      ),
      mediaType: LivenessCaptureModeExt.fromString(
        json['mediaType'] as String?,
      ),
      mimeType: json['mimeType'] as String?,
      byteSize: (json['byteSize'] as num?)?.toInt(),
      provider: json['provider'] as String?,
      storage: json['storage'] as String?,
      sessionTokenRef: json['sessionTokenRef'] as String?,
      submittedAt: DateTime.tryParse(json['submittedAt'] as String? ?? ''),
      reviewUsage:
          (json['reviewUsage'] as List<dynamic>?)
              ?.map((usage) => '$usage')
              .toList() ??
          const [],
    );
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
  final LivenessCaptureMode recommendedCaptureMode;
  final List<LivenessCaptureMode> acceptedCaptureModes;
  final bool requiresMotionEvidence;
  final bool manualReviewRecommended;
  final String? manualReviewReason;

  const LivenessChallenge({
    required this.challengeId,
    required this.type,
    required this.instruction,
    this.requiredCaptureMode = LivenessCaptureMode.photo,
    this.recommendedCaptureMode = LivenessCaptureMode.photo,
    this.acceptedCaptureModes = const [LivenessCaptureMode.photo],
    this.requiresMotionEvidence = false,
    this.manualReviewRecommended = false,
    this.manualReviewReason,
  });

  factory LivenessChallenge.fromJson(Map<String, dynamic> json) {
    return LivenessChallenge(
      challengeId: (json['id'] ?? json['challengeId']) as String,
      type: LivenessChallengeTypeExt.fromString(json['type'] as String),
      instruction: json['instruction'] as String,
      requiredCaptureMode: LivenessCaptureModeExt.fromString(
        json['requiredCaptureMode'] as String?,
      ),
      recommendedCaptureMode: LivenessCaptureModeExt.fromString(
        json['recommendedCaptureMode'] as String?,
      ),
      acceptedCaptureModes:
          (json['acceptedCaptureModes'] as List<dynamic>?)
              ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
              .toList() ??
          const [LivenessCaptureMode.photo],
      requiresMotionEvidence: json['requiresMotionEvidence'] as bool? ?? false,
      manualReviewRecommended:
          json['manualReviewRecommended'] as bool? ?? false,
      manualReviewReason: json['manualReviewReason'] as String?,
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
  final LivenessSessionCapabilities providerCapabilities;
  final LivenessSessionCapabilities clientCapabilities;
  final LivenessSessionCapabilities negotiatedCapabilities;
  final LivenessEvidencePolicy evidencePolicy;

  const LivenessSession({
    required this.sessionToken,
    required this.challenges,
    this.requiredCaptureMode = LivenessCaptureMode.photo,
    this.acceptedCaptureModes = const [LivenessCaptureMode.photo],
    this.requiredEvidence = const ['challenge_photo', 'reference_selfie'],
    this.providerCapabilities = const LivenessSessionCapabilities(),
    this.clientCapabilities = const LivenessSessionCapabilities(),
    this.negotiatedCapabilities = const LivenessSessionCapabilities(),
    this.evidencePolicy = const LivenessEvidencePolicy(),
  });

  factory LivenessSession.fromJson(Map<String, dynamic> json) {
    final challengesData = json['challenges'] as List<dynamic>? ?? [];
    final requiredCaptureMode = LivenessCaptureModeExt.fromString(
      json['requiredCaptureMode'] as String?,
    );
    final acceptedCaptureModes =
        (json['acceptedCaptureModes'] as List<dynamic>?)
            ?.map((mode) => LivenessCaptureModeExt.fromString('$mode'))
            .toList() ??
        const [LivenessCaptureMode.photo];
    final requiredEvidence =
        (json['requiredEvidence'] as List<dynamic>?)
            ?.map((evidence) => '$evidence')
            .toList() ??
        const ['challenge_photo', 'reference_selfie'];
    return LivenessSession(
      sessionToken: json['sessionToken'] as String,
      challenges: challengesData
          .map((e) => LivenessChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
      requiredCaptureMode: requiredCaptureMode,
      acceptedCaptureModes: acceptedCaptureModes,
      requiredEvidence: requiredEvidence,
      providerCapabilities: LivenessSessionCapabilities.fromJson(
        json['providerCapabilities'] as Map<String, dynamic>?,
      ),
      clientCapabilities: LivenessSessionCapabilities.fromJson(
        json['clientCapabilities'] as Map<String, dynamic>?,
      ),
      negotiatedCapabilities: LivenessSessionCapabilities.fromJson(
        json['negotiatedCapabilities'] as Map<String, dynamic>?,
      ),
      evidencePolicy: LivenessEvidencePolicy.fromJson(
        json['evidencePolicy'] as Map<String, dynamic>?,
        fallbackRequiredCaptureMode: requiredCaptureMode,
        fallbackAcceptedCaptureModes: acceptedCaptureModes,
        fallbackRequiredEvidence: requiredEvidence,
      ),
    );
  }
}

/// Result of submitting a single challenge photo
class ChallengeSubmitResult {
  final String sessionToken;
  final String? livenessCheckId;
  final String? livenessProofId;
  final String status;
  final int challengesCompleted;
  final int challengesTotal;
  final bool? isAlive;
  final double? confidence;
  final ChallengeVerificationResult? result;
  final LivenessEvidenceMetadata? evidence;

  const ChallengeSubmitResult({
    required this.sessionToken,
    this.livenessCheckId,
    this.livenessProofId,
    required this.status,
    required this.challengesCompleted,
    required this.challengesTotal,
    this.isAlive,
    this.confidence,
    this.result,
    this.evidence,
  });

  bool get allComplete => challengesCompleted == challengesTotal;

  factory ChallengeSubmitResult.fromJson(Map<String, dynamic> json) {
    return ChallengeSubmitResult(
      sessionToken: json['sessionToken'] as String,
      livenessCheckId: json['livenessCheckId'] as String?,
      livenessProofId:
          json['livenessProofId'] as String? ??
          json['livenessCheckId'] as String?,
      status: json['status'] as String,
      challengesCompleted: json['challengesCompleted'] as int,
      challengesTotal: json['challengesTotal'] as int,
      isAlive: json['isAlive'] as bool?,
      confidence: livenessScoreFromJson(json['confidence']),
      result: json['result'] != null
          ? ChallengeVerificationResult.fromJson(
              json['result'] as Map<String, dynamic>,
            )
          : null,
      evidence: json['evidence'] != null
          ? LivenessEvidenceMetadata.fromJson(
              json['evidence'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// Final verification result after all challenges
class ChallengeVerificationResult {
  final bool isAlive;
  final double confidence;
  final double antiSpoofScore;
  final double faceMatchScore;
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
      confidence: livenessScoreFromJson(json['confidence']) ?? 0,
      antiSpoofScore: livenessScoreFromJson(json['antiSpoofScore']) ?? 0,
      faceMatchScore: livenessScoreFromJson(json['faceMatchScore']) ?? 0,
      failureReason: json['failureReason'] as String?,
    );
  }
}

/// Normalize provider confidence scores into the app's decision scale.
///
/// VerifyHQ and mock providers may return either `0..1` ratios or `0..100`
/// percentages. Mobile liveness decisions always consume `0..1`.
double? livenessScoreFromJson(Object? value) {
  if (value == null) {
    return null;
  }
  final score = value is num ? value.toDouble() : double.tryParse('$value');
  if (score == null || score.isNaN) {
    return null;
  }
  if (score <= 0) {
    return 0;
  }
  if (score <= 1) {
    return score;
  }
  return (score / 100).clamp(0, 1);
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
  final String? livenessProofId;
  final bool isLive;
  final double confidence;
  final double? faceMatchScore;
  final DateTime completedAt;
  final String? failureReason;
  final List<LivenessEvidenceMetadata> evidence;

  const LivenessResult({
    required this.sessionId,
    this.livenessProofId,
    required this.isLive,
    required this.confidence,
    this.faceMatchScore,
    required this.completedAt,
    this.failureReason,
    this.evidence = const [],
  });

  String get stepUpProofId => livenessProofId ?? sessionId;

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
    bool useRecoveryToken = false,
  }) async {
    try {
      final response = await _dio.post(
        '/kyc/liveness/session',
        data: {'capabilities': capabilities.toJson()},
        options: useRecoveryToken
            ? Options(extra: {ApiRequestExtra.useRecoveryToken: true})
            : null,
      );
      return LivenessSession.fromJson(apiResponsePayload(response.data));
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
    bool useRecoveryToken = false,
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
        options: useRecoveryToken
            ? Options(extra: {ApiRequestExtra.useRecoveryToken: true})
            : null,
      );
      return ChallengeSubmitResult.fromJson(apiResponsePayload(response.data));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get liveness status
  Future<LivenessResult?> getLivenessStatus() async {
    try {
      final response = await _dio.get('/kyc/liveness/status');
      final data = apiResponsePayload(response.data);

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
