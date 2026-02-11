import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'activité inhabituelle
enum UnusualActivityType {
  unusualTime,
  unusualAmount,
  unusualLocation,
  unusualRecipient,
  unusualFrequency,
  unusualDevice,
  dormantAccount,
}

/// Alerte d'activité inhabituelle
class UnusualActivityAlert {
  final String alertId;
  final UnusualActivityType type;
  final String description;
  final double severity; // 0.0 - 1.0
  final Map<String, dynamic> context;
  final DateTime detectedAt;

  const UnusualActivityAlert({
    required this.alertId,
    required this.type,
    required this.description,
    required this.severity,
    this.context = const {},
    required this.detectedAt,
  });
}

/// Service de détection d'activité inhabituelle.
///
/// Analyse le comportement de l'utilisateur pour détecter
/// les déviations par rapport à ses habitudes normales.
class UnusualActivityDetector {
  static const _tag = 'UnusualActivity';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  UnusualActivityDetector({required Dio dio}) : _dio = dio;

  /// Vérifier si une transaction est inhabituelle
  Future<List<UnusualActivityAlert>> checkTransaction({
    required String userId,
    required double amount,
    required String recipientId,
    required DateTime timestamp,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/fraud/unusual-activity/check', data: {
        'userId': userId,
        'amount': amount,
        'recipientId': recipientId,
        'timestamp': timestamp.toIso8601String(),
        if (location != null) 'location': location,
      });
      final list = response.data as List;
      return list.map((e) {
        final m = e as Map<String, dynamic>;
        return UnusualActivityAlert(
          alertId: m['alertId'] as String,
          type: UnusualActivityType.values.byName(m['type'] as String),
          description: m['description'] as String,
          severity: (m['severity'] as num).toDouble(),
          context: Map<String, dynamic>.from(m['context'] ?? {}),
          detectedAt: DateTime.now(),
        );
      }).toList();
    } catch (e) {
      _log.error('Unusual activity check failed', e);
      return [];
    }
  }

  /// Vérifier l'heure habituelle de transaction
  bool isUnusualTime(DateTime timestamp) {
    final hour = timestamp.hour;
    // Transactions entre 1h et 5h du matin sont inhabituelles
    return hour >= 1 && hour <= 5;
  }
}

final unusualActivityDetectorProvider = Provider<UnusualActivityDetector>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
