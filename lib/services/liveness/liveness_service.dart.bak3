import 'dart:typed_data';
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
/// Handles face liveness verification through sequential challenges
class LivenessService {
  final Dio _dio;

  LivenessService(this._dio);

  /// Start a new liveness detection session
  /// Returns session ID and list of challenges to complete
  Future<LivenessSession> startSession({
    String? purpose, // 'kyc', 'recovery', 'withdrawal'
  }) async {
    try {
      final response = await _dio.post('/liveness/start', data: {
        if (purpose != null) 'purpose': purpose,
      });

      return LivenessSession.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Submit a frame for a specific challenge
  /// Returns whether challenge passed and the next challenge if any
  Future<LivenessChallengeResponse> submitChallenge({
    required String sessionId,
    required String challengeId,
    required Uint8List frameData,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'sessionId': sessionId,
        'challengeId': challengeId,
        'frame': MultipartFile.fromBytes(
          frameData,
          filename: 'frame.jpg',
        ),
      });

      final response = await _dio.post(
        '/liveness/submit-challenge',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      return LivenessChallengeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Complete the liveness session and get final result
  /// Must be called after all challenges are completed
  Future<LivenessResult> completeSession(String sessionId) async {
    try {
      final response = await _dio.post('/liveness/complete', data: {
        'sessionId': sessionId,
      });

      return LivenessResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Cancel an ongoing liveness session
  Future<void> cancelSession(String sessionId) async {
    try {
      await _dio.post('/liveness/cancel', data: {
        'sessionId': sessionId,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get the current status of a liveness session
  Future<Map<String, dynamic>> getSessionStatus(String sessionId) async {
    try {
      final response = await _dio.get('/liveness/session/$sessionId');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Liveness Service Provider
final livenessServiceProvider = Provider<LivenessService>((ref) {
  return LivenessService(ref.watch(dioProvider));
});
