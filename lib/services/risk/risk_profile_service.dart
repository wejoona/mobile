import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/utils/logger.dart';

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

  factory CustomerRiskProfile.fromJson(Map<String, dynamic> json) {
    final payload = _riskPayload(json);
    final lastAssessedAt =
        _dateValue(payload, const [
          'lastAssessedAt',
          'last_assessed_at',
          'updatedAt',
          'updated_at',
        ]) ??
        DateTime.now().toUtc();

    return CustomerRiskProfile(
      userId: _stringValue(payload, const ['userId', 'user_id']) ?? '',
      rating: _riskRating(
        _stringValue(payload, const ['rating', 'riskLevel', 'risk_level']),
      ),
      overallScore:
          _doubleValue(payload, const [
            'overallScore',
            'overall_score',
            'overallRiskScore',
            'overall_risk_score',
          ]) ??
          0,
      factorScores: _factorScores(payload['factorScores']),
      lastAssessedAt: lastAssessedAt,
      nextReviewDate:
          _dateValue(payload, const ['nextReviewDate', 'next_review_date']) ??
          lastAssessedAt.add(const Duration(days: 30)),
      riskFactors: _stringList(
        payload['riskFactors'] ?? payload['risk_factors'],
      ),
      reviewNotes:
          _stringValue(payload, const ['reviewNotes', 'review_notes']) ??
          _stringValue(payload, const ['screeningStatus', 'screening_status']),
    );
  }
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

  /// Current user's risk profile.
  ///
  /// Customer mobile code must use the current-user endpoint so the API owns
  /// identity and authorization. User-id access is admin/support territory.
  Future<CustomerRiskProfile?> getProfile() async {
    try {
      final response = await _dio.get('/risk/profile');
      return CustomerRiskProfile.fromJson(_mapPayload(response.data));
    } catch (e) {
      _log.error('Failed to fetch risk profile', e);
      return null;
    }
  }

  /// Explicit admin/support lookup. Do not use this from customer UI.
  Future<CustomerRiskProfile?> getAdminProfile({required String userId}) async {
    try {
      final response = await _dio.get('/risk/profile/$userId');
      return CustomerRiskProfile.fromJson(_mapPayload(response.data));
    } catch (e) {
      _log.error('Failed to fetch admin risk profile', e);
      return null;
    }
  }

  /// The Korido API has no refresh route; refetch the canonical profile.
  Future<CustomerRiskProfile?> refreshProfile({String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      return getAdminProfile(userId: userId);
    }
    return getProfile();
  }
}

final riskProfileProvider = Provider<RiskProfileService>((ref) {
  return RiskProfileService(dio: ref.watch(dioProvider));
});

Map<String, dynamic> _mapPayload(Object? raw) {
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  return const {};
}

Map<String, dynamic> _riskPayload(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

String? _stringValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

double? _doubleValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) {
        return parsed;
      }
    }
  }
  return null;
}

DateTime? _dateValue(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is DateTime) {
      return value.toUtc();
    }
    if (value is String && value.trim().isNotEmpty) {
      final parsed = DateTime.tryParse(value.trim());
      if (parsed != null) {
        return parsed.toUtc();
      }
    }
  }
  return null;
}

Map<String, double> _factorScores(Object? raw) {
  if (raw is! Map) {
    return const {};
  }
  return raw.map((key, value) {
    final numeric = value is num ? value.toDouble() : double.tryParse('$value');
    return MapEntry('$key', numeric ?? 0);
  });
}

List<String> _stringList(Object? raw) {
  if (raw is! List) {
    return const [];
  }
  return raw.whereType<String>().toList(growable: false);
}

CustomerRiskRating _riskRating(String? raw) {
  final normalized = raw?.trim().toLowerCase().replaceAll('-', '_');
  return switch (normalized) {
    'low' => CustomerRiskRating.low,
    'medium' => CustomerRiskRating.medium,
    'high' => CustomerRiskRating.high,
    'very_high' || 'veryhigh' => CustomerRiskRating.veryHigh,
    'prohibited' => CustomerRiskRating.prohibited,
    _ => CustomerRiskRating.medium,
  };
}
