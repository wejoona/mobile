import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/storage/secure_storage_service.dart';

/// Run 376: Riverpod provider for secure storage
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
