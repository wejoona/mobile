import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userPhone = 'user_phone';
  static const String userDialCode = 'user_dial_code';
  static const String userLocalPhone = 'user_local_phone';
  static const String userPhoneE164 = 'user_phone_e164';
  static const String recoveryAccessToken = 'recovery_access_token';
  static const String recoveryAccessTokenPhone = 'recovery_access_token_phone';
  static const String recoveryAccessTokenScope = 'recovery_access_token_scope';
  static const String recoveryAccessTokenCreatedAt =
      'recovery_access_token_created_at';
  static const String userPin = 'user_pin';
  static const String biometricEnabled = 'biometric_enabled';
  static const String rememberedPhone = 'remembered_phone';
  static const String avatarUrl = 'avatar_url';
}

/// Secure Storage Provider
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Bumped when an auth token is known to be invalid and local auth state must
/// be cleared without calling the backend logout endpoint.
final authSessionInvalidatedProvider = StateProvider<int>((ref) => 0);
