import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Transfert sécurisé de fichiers avec chiffrement.
///
/// This boundary is intentionally fail-closed until uploads are protected by a
/// real encryption/integrity contract. Base64 and additive checksums are not
/// acceptable for identity or compliance evidence.
class SecureFileTransfer {
  static const _tag = 'SecureTransfer';
  final AppLogger _log = AppLogger(_tag);
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  /// Prepare file for secure upload.
  Future<Map<String, dynamic>> prepareUpload(
    List<int> fileBytes,
    String filename,
  ) async {
    if (fileBytes.length > maxFileSizeBytes) {
      throw Exception('File exceeds maximum size');
    }
    _log.debug(
      'Preparing secure upload: $filename (${fileBytes.length} bytes)',
    );
    throw UnsupportedError(
      'Secure file transfer is not implemented; upload envelope blocked.',
    );
  }
}

final secureFileTransferProvider = Provider<SecureFileTransfer>((ref) {
  return SecureFileTransfer();
});
