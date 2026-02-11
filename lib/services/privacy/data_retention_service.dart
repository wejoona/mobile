import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Politique de rétention des données
class RetentionPolicy {
  final String dataCategory;
  final Duration retentionPeriod;
  final bool autoDelete;
  final String legalBasis;

  const RetentionPolicy({
    required this.dataCategory,
    required this.retentionPeriod,
    this.autoDelete = true,
    required this.legalBasis,
  });
}

/// Service de gestion de la rétention des données.
///
/// Applique les politiques de rétention conformes au RGPD
/// et à la réglementation UEMOA sur la protection des données.
class DataRetentionService {
  static const _tag = 'DataRetention';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  /// Politiques de rétention par défaut (conformes BCEAO)
  static const List<RetentionPolicy> defaultPolicies = [
    RetentionPolicy(
      dataCategory: 'transaction_records',
      retentionPeriod: Duration(days: 3650), // 10 ans
      autoDelete: false,
      legalBasis: 'Obligation BCEAO - conservation des données de transaction',
    ),
    RetentionPolicy(
      dataCategory: 'kyc_documents',
      retentionPeriod: Duration(days: 1825), // 5 ans après clôture
      autoDelete: false,
      legalBasis: 'Obligation CENTIF - conservation des pièces KYC',
    ),
    RetentionPolicy(
      dataCategory: 'session_logs',
      retentionPeriod: Duration(days: 90),
      autoDelete: true,
      legalBasis: 'Intérêt légitime - sécurité',
    ),
    RetentionPolicy(
      dataCategory: 'marketing_data',
      retentionPeriod: Duration(days: 730), // 2 ans
      autoDelete: true,
      legalBasis: 'Consentement utilisateur',
    ),
  ];

  DataRetentionService({required Dio dio}) : _dio = dio;

  /// Demander la suppression des données expirées
  Future<int> purgeExpiredData() async {
    try {
      final response = await _dio.post('/privacy/retention/purge');
      return (response.data as Map<String, dynamic>)['deletedCount'] as int? ?? 0;
    } catch (e) {
      _log.error('Data purge failed', e);
      return 0;
    }
  }

  /// Obtenir le statut de rétention pour un utilisateur
  Future<Map<String, DateTime>> getRetentionStatus() async {
    try {
      final response = await _dio.get('/privacy/retention/status');
      final data = response.data as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
    } catch (e) {
      _log.error('Failed to get retention status', e);
      return {};
    }
  }

  RetentionPolicy? getPolicyFor(String dataCategory) {
    return defaultPolicies.where((p) => p.dataCategory == dataCategory).firstOrNull;
  }
}

final dataRetentionProvider = Provider<DataRetentionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
