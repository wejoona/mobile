import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Liveness challenge types
enum LivenessChallengeType {
  blink,
  smile,
  turnLeft,
  turnRight,
  lookUp,
  nod,
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

  const LivenessChallenge({
    required this.challengeId,
    required this.type,
    required this.instruction,
  });

  factory LivenessChallenge.fromJson(Map<String, dynamic> json) {
    return LivenessChallenge(
      challengeId: json['id'] as String,
      type: LivenessChallengeTypeExt.fromString(json['type'] as String),
      instruction: json['instruction'] as String,
    );
  }
}

/// Liveness session with challenges
class LivenessSession {
  final String sessionToken;
  final List<LivenessChallenge> challenges;

  const LivenessSession({
    required this.sessionToken,
    required this.challenges,
  });

  factory LivenessSession.fromJson(Map<String, dynamic> json) {
    final challengesData = json['challenges'] as List<dynamic>? ?? [];
    return LivenessSession(
      sessionToken: json['sessionToken'] as String,
      challenges: challengesData
          .map((e) => LivenessChallenge.fromJson(e as Map<String, dynamic>))
          .toList(),
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
          ? ChallengeVerificationResult.fromJson(json['result'] as Map<String, dynamic>)
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

/// Liveness result (for widget callback)
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
  Future<LivenessSession> createSession() async {
    try {
      final response = await _dio.post('/kyc/liveness/session');
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
  }) async {
    try {
      final formData = FormData.fromMap({
        'sessionToken': sessionToken,
        'challengeId': challengeId,
        'photo': await MultipartFile.fromFile(photoPath, filename: 'challenge.jpg'),
      });

      final response = await _dio.post('/kyc/liveness/challenge', data: formData);
      return ChallengeSubmitResult.fromJson(response.data as Map<String, dynamic>);
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
        failureReason: data['status'] == 'FAILED' ? 'Liveness check failed' : null,
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
