import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Liveness challenge types
enum LivenessChallengeType {
  blink,
  smile,
  turnHead,
  nod,
}

extension LivenessChallengeTypeExt on LivenessChallengeType {
  String get value {
    switch (this) {
      case LivenessChallengeType.blink:
        return 'blink';
      case LivenessChallengeType.smile:
        return 'smile';
      case LivenessChallengeType.turnHead:
        return 'turn_head';
      case LivenessChallengeType.nod:
        return 'nod';
    }
  }

  static LivenessChallengeType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'blink':
        return LivenessChallengeType.blink;
      case 'smile':
        return LivenessChallengeType.smile;
      case 'turn_head':
        return LivenessChallengeType.turnHead;
      case 'nod':
        return LivenessChallengeType.nod;
      default:
        return LivenessChallengeType.blink;
    }
  }
}

/// Liveness challenge model
class LivenessChallenge {
  final String challengeId;
  final LivenessChallengeType type;
  final String instruction;
  final DateTime expiresAt;

  const LivenessChallenge({
    required this.challengeId,
    required this.type,
    required this.instruction,
    required this.expiresAt,
  });

  factory LivenessChallenge.fromJson(Map<String, dynamic> json) {
    return LivenessChallenge(
      challengeId: json['challengeId'] as String,
      type: LivenessChallengeTypeExt.fromString(json['type'] as String),
      instruction: json['instruction'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challengeId': challengeId,
      'type': type.value,
      'instruction': instruction,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// Liveness result model
class LivenessResult {
  final String sessionId;
  final bool isLive;
  final double confidence;
  final DateTime completedAt;
  final String? failureReason;

  const LivenessResult({
    required this.sessionId,
    required this.isLive,
    required this.confidence,
    required this.completedAt,
    this.failureReason,
  });

  factory LivenessResult.fromJson(Map<String, dynamic> json) {
    return LivenessResult(
      sessionId: json['sessionId'] as String,
      isLive: json['isLive'] as bool,
      confidence: (json['confidence'] as num).toDouble(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'isLive': isLive,
      'confidence': confidence,
      'completedAt': completedAt.toIso8601String(),
      if (failureReason != null) 'failureReason': failureReason,
    };
  }
}

/// Liveness session start response
class LivenessSession {
  final String sessionId;
  final List<LivenessChallenge> challenges;

  const LivenessSession({
    required this.sessionId,
    required this.challenges,
  });

  factory LivenessSession.fromJson(Map<String, dynamic> json) {
    final challengesData = json['challenges'] as List<dynamic>? ?? [];
    return LivenessSession(
      sessionId: json['sessionId'] as String,
      challenges: challengesData
          .map((e) => LivenessChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Liveness challenge submission response
class LivenessChallengeResponse {
  final bool passed;
  final LivenessChallenge? nextChallenge;
  final bool isComplete;
  final String? message;

  const LivenessChallengeResponse({
    required this.passed,
    this.nextChallenge,
    this.isComplete = false,
    this.message,
  });

  factory LivenessChallengeResponse.fromJson(Map<String, dynamic> json) {
    return LivenessChallengeResponse(
      passed: json['passed'] as bool,
      nextChallenge: json['nextChallenge'] != null
          ? LivenessChallenge.fromJson(
              json['nextChallenge'] as Map<String, dynamic>)
          : null,
      isComplete: json['isComplete'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// Liveness detection service
/// Handles face liveness verification through the backend's /kyc/liveness/* endpoints
/// Flow: createSession() → capture video+selfie → submitLiveness() → poll getLivenessStatus()
class LivenessService {
  final Dio _dio;

  LivenessService(this._dio);

  /// Create a new liveness session via POST /kyc/liveness/session
  /// Returns sessionToken + challenge info from VerifyHQ
  Future<LivenessSession> createSession() async {
    try {
      final response = await _dio.post('/kyc/liveness/session');
      final data = response.data as Map<String, dynamic>;

      // Map backend response to LivenessSession
      final sessionToken = data['sessionToken'] as String;
      final challengeType = data['challengeType'] as String?;
      final challengeData = data['challengeData'] as Map<String, dynamic>?;

      // Build challenges list from challengeData if available
      final challenges = <LivenessChallenge>[];
      if (challengeData != null && challengeData['challenges'] is List) {
        for (final c in challengeData['challenges'] as List) {
          if (c is Map<String, dynamic>) {
            challenges.add(LivenessChallenge.fromJson(c));
          }
        }
      } else if (challengeType != null) {
        // Single challenge type — create a default challenge
        challenges.add(LivenessChallenge(
          challengeId: 'default',
          type: LivenessChallengeTypeExt.fromString(challengeType),
          instruction: _getInstructionForType(challengeType),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
        ));
      }

      return LivenessSession(
        sessionId: sessionToken,
        challenges: challenges,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Submit liveness check with video + selfie S3 keys
  /// via POST /kyc/liveness/submit
  Future<LivenessResult> submitLiveness({
    required String sessionToken,
    required String videoKey,
    required String selfieKey,
  }) async {
    try {
      final response = await _dio.post('/kyc/liveness/submit', data: {
        'sessionToken': sessionToken,
        'videoKey': videoKey,
        'selfieKey': selfieKey,
      });

      final data = response.data as Map<String, dynamic>;
      return LivenessResult(
        sessionId: data['id'] as String? ?? sessionToken,
        isLive: data['isAlive'] as bool? ?? false,
        confidence: (data['confidence'] as num?)?.toDouble() ?? 0.0,
        completedAt: DateTime.now(),
        failureReason: data['status'] == 'failed' ? 'Liveness check failed' : null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get liveness status via GET /kyc/liveness/status
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
        failureReason: data['status'] == 'failed' ? 'Liveness check failed' : null,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cancel an ongoing liveness session (best-effort, no backend endpoint currently)
  Future<void> cancelSession(String sessionId) async {
    // No cancel endpoint in the new backend — just a no-op
  }

  String _getInstructionForType(String type) {
    switch (type.toLowerCase()) {
      case 'blink':
        return 'Please blink your eyes';
      case 'smile':
        return 'Please smile';
      case 'turn_head':
        return 'Please turn your head slowly';
      case 'nod':
        return 'Please nod your head';
      default:
        return 'Follow the on-screen instructions';
    }
  }
}

/// Liveness Service Provider
final livenessServiceProvider = Provider<LivenessService>((ref) {
  return LivenessService(ref.watch(dioProvider));
});
