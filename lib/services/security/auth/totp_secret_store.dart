import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Stockage sécurisé des secrets TOTP.
class TotpSecretStore {
  static const _tag = 'TotpSecretStore';
  final AppLogger _log = const AppLogger(_tag);

  Future<void> storeSecret(String userId, String secret) async {
    _log.security(
      'Rejected device-local TOTP secret storage; authenticator MFA must be backend-backed',
      level: 'WARN',
    );
    throw UnsupportedError(
      'Device-local TOTP secret storage is disabled for Korido.',
    );
  }

  Future<String?> retrieveSecret(String userId) async => null;

  Future<void> deleteSecret(String userId) async {
    _log.debug('Deleted TOTP secret');
  }

  Future<bool> hasSecret(String userId) async => false;
}

final totpSecretStoreProvider = Provider<TotpSecretStore>(
  (ref) => TotpSecretStore(),
);
