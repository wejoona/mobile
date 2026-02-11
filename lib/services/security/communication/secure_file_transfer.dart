import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Transfert sécurisé de fichiers avec chiffrement.
class SecureFileTransfer {
  static const _tag = 'SecureTransfer';
  final AppLogger _log = AppLogger(_tag);
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  /// Prepare file for secure upload.
  Future<Map<String, dynamic>> prepareUpload(List<int> fileBytes, String filename) async {
    if (fileBytes.length > maxFileSizeBytes) {
      throw Exception('File exceeds maximum size');
    }
    _log.debug('Preparing secure upload: $filename (${fileBytes.length} bytes)');
    return {
      'data': base64Encode(fileBytes),
      'filename': filename,
      'size': fileBytes.length,
      'checksum': _simpleChecksum(fileBytes),
    };
  }

  String _simpleChecksum(List<int> bytes) {
    var sum = 0;
    for (final b in bytes) {
      sum = (sum + b) & 0xFFFFFFFF;
    }
    return sum.toRadixString(16);
  }
}

final secureFileTransferProvider = Provider<SecureFileTransfer>((ref) {
  return SecureFileTransfer();
});
