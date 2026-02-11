import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat du filtrage par lot
class BatchScreeningResult {
  final int totalScreened;
  final int matchesFound;
  final List<String> matchedEntities;
  final DateTime completedAt;

  const BatchScreeningResult({
    required this.totalScreened,
    required this.matchesFound,
    this.matchedEntities = const [],
    required this.completedAt,
  });
}

/// Service de filtrage AML par lot.
///
/// Permet le filtrage simultané de plusieurs entités
/// pour les opérations de masse (import de bénéficiaires).
class BatchScreeningService {
  static const _tag = 'BatchScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  BatchScreeningService({required Dio dio}) : _dio = dio;

  Future<BatchScreeningResult> screenBatch({
    required List<Map<String, String>> entities,
  }) async {
    try {
      final response = await _dio.post('/aml/batch-screen', data: {
        'entities': entities,
      });
      final data = response.data as Map<String, dynamic>;
      return BatchScreeningResult(
        totalScreened: data['totalScreened'] as int,
        matchesFound: data['matchesFound'] as int,
        matchedEntities: List<String>.from(data['matchedEntities'] ?? []),
        completedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Batch screening failed', e);
      return BatchScreeningResult(
        totalScreened: 0, matchesFound: 0, completedAt: DateTime.now(),
      );
    }
  }
}

final batchScreeningProvider = Provider<BatchScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
