import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Catégorie d'événement d'audit de sécurité
enum SecurityAuditCategory {
  authentication,
  authorization,
  dataAccess,
  configChange,
  securityThreat,
  compliance,
}

/// Entrée du journal d'audit de sécurité
class SecurityAuditEntry {
  final String entryId;
  final SecurityAuditCategory category;
  final String action;
  final String description;
  final String? userId;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const SecurityAuditEntry({
    required this.entryId,
    required this.category,
    required this.action,
    required this.description,
    this.userId,
    this.deviceId,
    this.ipAddress,
    this.metadata = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'entryId': entryId,
    'category': category.name,
    'action': action,
    'description': description,
    if (userId != null) 'userId': userId,
    if (deviceId != null) 'deviceId': deviceId,
    if (ipAddress != null) 'ipAddress': ipAddress,
    'metadata': metadata,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Service de journal d'audit de sécurité.
///
/// Enregistre tous les événements de sécurité pour
/// la conformité et l'investigation.
class SecurityAuditLogService {
  static const _tag = 'SecurityAuditLog';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<SecurityAuditEntry> _pendingEntries = [];
  static const int _batchSize = 20;

  SecurityAuditLogService({required Dio dio}) : _dio = dio;

  /// Enregistrer un événement d'audit
  Future<void> logEvent({
    required SecurityAuditCategory category,
    required String action,
    required String description,
    String? userId,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    final entry = SecurityAuditEntry(
      entryId: '${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      action: action,
      description: description,
      userId: userId,
      deviceId: deviceId,
      metadata: metadata ?? {},
      timestamp: DateTime.now(),
    );
    _pendingEntries.add(entry);
    if (_pendingEntries.length >= _batchSize) {
      await flush();
    }
  }

  /// Envoyer les entrées en attente
  Future<void> flush() async {
    if (_pendingEntries.isEmpty) return;
    final batch = List<SecurityAuditEntry>.from(_pendingEntries);
    _pendingEntries.clear();
    try {
      await _dio.post('/audit/security/batch', data: {
        'entries': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush audit log', e);
      _pendingEntries.insertAll(0, batch); // Remettre en file
    }
  }
}

final securityAuditLogProvider = Provider<SecurityAuditLogService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
