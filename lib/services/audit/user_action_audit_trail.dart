import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Type d'action utilisateur
enum UserActionType {
  login,
  logout,
  transfer,
  deposit,
  withdrawal,
  profileUpdate,
  settingsChange,
  beneficiaryAdd,
  beneficiaryRemove,
  pinChange,
  biometricEnroll,
  kycSubmit,
  supportRequest,
  screenView,
}

/// Entrée de piste d'audit utilisateur
class UserActionEntry {
  final String actionId;
  final UserActionType actionType;
  final String description;
  final String? targetId;
  final Map<String, dynamic> details;
  final DateTime timestamp;

  const UserActionEntry({
    required this.actionId,
    required this.actionType,
    required this.description,
    this.targetId,
    this.details = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'actionId': actionId,
    'actionType': actionType.name,
    'description': description,
    if (targetId != null) 'targetId': targetId,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Piste d'audit des actions utilisateur.
///
/// Enregistre toutes les actions significatives
/// de l'utilisateur pour la traçabilité.
class UserActionAuditTrail {
  static const _tag = 'UserAuditTrail';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<UserActionEntry> _buffer = [];

  UserActionAuditTrail({required Dio dio}) : _dio = dio;

  void record({
    required UserActionType actionType,
    required String description,
    String? targetId,
    Map<String, dynamic>? details,
  }) {
    _buffer.add(UserActionEntry(
      actionId: '${DateTime.now().millisecondsSinceEpoch}',
      actionType: actionType,
      description: description,
      targetId: targetId,
      details: details ?? {},
      timestamp: DateTime.now(),
    ));
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<UserActionEntry>.from(_buffer);
    _buffer.clear();
    try {
      await _dio.post('/audit/user-actions/batch', data: {
        'actions': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush user action audit', e);
      _buffer.insertAll(0, batch);
    }
  }
}

final userActionAuditTrailProvider = Provider<UserActionAuditTrail>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
