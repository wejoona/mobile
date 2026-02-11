import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type de vérification de vélocité
enum VelocityCheckType {
  dailyCount,
  dailyAmount,
  weeklyCount,
  weeklyAmount,
  monthlyCount,
  monthlyAmount,
  uniqueRecipients,
  crossBorderCount,
}

/// Résultat de la vérification de vélocité
class VelocityCheckResult {
  final bool withinLimits;
  final List<VelocityViolation> violations;
  final Map<VelocityCheckType, double> currentUsage;
  final DateTime checkedAt;

  const VelocityCheckResult({
    required this.withinLimits,
    this.violations = const [],
    this.currentUsage = const {},
    required this.checkedAt,
  });
}

class VelocityViolation {
  final VelocityCheckType type;
  final double limit;
  final double current;
  final String message;

  const VelocityViolation({
    required this.type,
    required this.limit,
    required this.current,
    required this.message,
  });
}

/// Service de vérification de vélocité des transactions.
///
/// Détecte les schémas de transactions anormaux (structuration,
/// smurfing) en vérifiant les limites de fréquence et de montant.
class VelocityCheckService {
  static const _tag = 'VelocityCheck';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  VelocityCheckService({required Dio dio}) : _dio = dio;

  /// Vérifier la vélocité avant une transaction
  Future<VelocityCheckResult> checkVelocity({
    required String userId,
    required double amount,
    required String currency,
    String? recipientId,
    bool isCrossBorder = false,
  }) async {
    try {
      final response = await _dio.post('/aml/velocity/check', data: {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        if (recipientId != null) 'recipientId': recipientId,
        'isCrossBorder': isCrossBorder,
      });
      final data = response.data as Map<String, dynamic>;
      return VelocityCheckResult(
        withinLimits: data['withinLimits'] as bool? ?? true,
        violations: (data['violations'] as List?)?.map((v) {
          final m = v as Map<String, dynamic>;
          return VelocityViolation(
            type: VelocityCheckType.values.byName(m['type'] as String),
            limit: (m['limit'] as num).toDouble(),
            current: (m['current'] as num).toDouble(),
            message: m['message'] as String,
          );
        }).toList() ?? [],
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Velocity check failed', e);
      return VelocityCheckResult(withinLimits: true, checkedAt: DateTime.now());
    }
  }

  /// Obtenir le résumé de vélocité actuel
  Future<Map<VelocityCheckType, double>> getCurrentUsage({
    required String userId,
  }) async {
    try {
      final response = await _dio.get('/aml/velocity/usage/$userId');
      final data = response.data as Map<String, dynamic>;
      return (data['usage'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(VelocityCheckType.values.byName(k), (v as num).toDouble()),
      ) ?? {};
    } catch (e) {
      _log.error('Failed to get velocity usage', e);
      return {};
    }
  }
}

final velocityCheckProvider = Provider<VelocityCheckService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
