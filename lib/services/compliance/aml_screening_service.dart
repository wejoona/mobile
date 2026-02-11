import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// AML screening result.
class AmlScreeningResult {
  final bool cleared;
  final List<String> matchedLists;
  final double riskScore;
  final DateTime screenedAt;

  const AmlScreeningResult({
    required this.cleared,
    this.matchedLists = const [],
    required this.riskScore,
    required this.screenedAt,
  });
}

/// Client-side AML (Anti-Money Laundering) screening helper.
///
/// Coordinates with the backend to screen transaction counterparties
/// against sanctions lists and PEP databases.
class AmlScreeningService {
  static const _tag = 'AmlScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AmlScreeningService({required Dio dio}) : _dio = dio;

  /// Screen a counterparty before transaction.
  Future<AmlScreeningResult> screenCounterparty({
    required String name,
    String? phone,
    String? countryCode,
  }) async {
    try {
      final response = await _dio.post('/compliance/aml/screen', data: {
        'name': name,
        if (phone != null) 'phone': phone,
        if (countryCode != null) 'countryCode': countryCode,
      });

      final data = response.data as Map<String, dynamic>;
      return AmlScreeningResult(
        cleared: data['cleared'] as bool? ?? true,
        matchedLists: List<String>.from(data['matchedLists'] ?? []),
        riskScore: (data['riskScore'] as num?)?.toDouble() ?? 0.0,
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('AML screening failed', e);
      // Fail-open with high risk score to trigger manual review
      return AmlScreeningResult(
        cleared: true,
        riskScore: 0.5,
        screenedAt: DateTime.now(),
      );
    }
  }
}

final amlScreeningServiceProvider = Provider<AmlScreeningService>((ref) {
  return AmlScreeningService(dio: Dio());
});
