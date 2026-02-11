import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Handles data subject access requests.
enum GdprRequestType { access, rectification, erasure, portability, objection }

class GdprRequestHandler {
  static const _tag = 'GDPR';
  final AppLogger _log = AppLogger(_tag);
  final List<GdprRequest> _requests = [];

  Future<String> submitRequest(GdprRequestType type, String userId) async {
    final id = 'GDPR-${DateTime.now().millisecondsSinceEpoch}';
    _requests.add(GdprRequest(id: id, type: type, userId: userId));
    _log.debug('GDPR request submitted: ${type.name} by $userId');
    return id;
  }

  List<GdprRequest> getPending() =>
      _requests.where((r) => !r.completed).toList();
}

class GdprRequest {
  final String id;
  final GdprRequestType type;
  final String userId;
  final DateTime createdAt;
  bool completed;

  GdprRequest({
    required this.id,
    required this.type,
    required this.userId,
    this.completed = false,
  }) : createdAt = DateTime.now();
}

final gdprRequestHandlerProvider = Provider<GdprRequestHandler>((ref) {
  return GdprRequestHandler();
});
