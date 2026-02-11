import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Stockage sécurisé des secrets TOTP.
class TotpSecretStore {
  static const _tag = 'TotpSecretStore';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, String> _secrets = {};

  Future<void> storeSecret(String userId, String secret) async {
    _log.debug('Storing TOTP secret for user');
    _secrets[userId] = secret;
  }

  Future<String?> retrieveSecret(String userId) async {
    return _secrets[userId];
  }

  Future<void> deleteSecret(String userId) async {
    _secrets.remove(userId);
    _log.debug('Deleted TOTP secret');
  }

  Future<bool> hasSecret(String userId) async {
    return _secrets.containsKey(userId);
  }
}

final totpSecretStoreProvider = Provider<TotpSecretStore>((ref) {
  return TotpSecretStore();
});
