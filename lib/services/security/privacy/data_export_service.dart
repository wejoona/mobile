import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Exports user data for portability (GDPR-like compliance).
class DataExportService {
  static const _tag = 'DataExport';
  final AppLogger _log = AppLogger(_tag);

  /// Generate a portable data export for the user.
  Future<String> exportUserData(String userId, Map<String, dynamic> userData) async {
    _log.debug('Generating data export for user');
    final export = {
      'userId': userId,
      'exportDate': DateTime.now().toIso8601String(),
      'data': userData,
      'format': 'JSON',
      'version': '1.0',
    };
    return jsonEncode(export);
  }
}

final dataExportServiceProvider = Provider<DataExportService>((ref) {
  return DataExportService();
});
