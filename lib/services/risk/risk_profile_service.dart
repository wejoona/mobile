import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum CustomerRiskRating { low, medium, high, veryHigh, prohibited }

class CustomerRiskProfile {
  final String userId;
  final CustomerRiskRating rating;
  final double overallScore;
  final Map<String, double> factorScores;
  final DateTime lastAssessedAt;
  final DateTime nextReviewDate;
  final List<String> riskFactors;
  final String? reviewNotes;

  const CustomerRiskProfile({
    required this.userId,
    required this.rating,
    required this.overallScore,
    this.factorScores = const {},
    required this.lastAssessedAt,
    required this.nextReviewDate,
    this.riskFactors = const [],
    this.reviewNotes,
  });

  factory CustomerRiskProfile.fromJson(Map<String, dynamic> json) => CustomerRiskProfile(
    userId: json['userId'] as String,
    rating: CustomerRiskRating.values.byName(json['rating'] as String),
    overallScore: (json['overallScore'] as num).toDouble(),
    factorScores: Map<String, double>.from(
      (json['factorScores'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ?? {},
    ),
    lastAssessedAt: DateTime.parse(json['lastAssessedAt'] as String),
    nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    riskFactors: List<String>.from(json['riskFactors'] ?? []),
    reviewNotes: json['reviewNotes'] as String?,
  );
}

/// Service de profil de risque client.
///
/// Gère le profil de risque global d'un client
/// pour la segmentation et le monitoring continu.
class RiskProfileService {
  static const _tag = 'RiskProfile';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  RiskProfileService({required Dio dio}) : _dio = dio;

  Future<CustomerRiskProfile?> getProfile({required String userId}) async {
    try {
      final response = await _dio.get('/risk/profile/$userId');
      return CustomerRiskProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch risk profile', e);
      return null;
    }
  }

  Future<CustomerRiskProfile?> refreshProfile({required String userId}) async {
    try {
      final response = await _dio.post('/risk/profile/$userId/refresh');
      return CustomerRiskProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to refresh risk profile', e);
      return null;
    }
  }
}

final riskProfileProvider = Provider<RiskProfileService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
