import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/services/api/api_client.dart' hide StorageKeys, secureStorageProvider;
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Authentication session state.
enum AuthState { unknown, authenticated, unauthenticated, expired }

/// Session management provider.
class SessionNotifier extends Notifier<AuthState> {
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _expiryKey = 'token_expiry';

  @override
  AuthState build() {
    _checkSession();
    return AuthState.unknown;
  }

  Future<void> _checkSession() async {
    final storage = ref.read(secureStorageProvider);
    final token = await storage.read(key: _tokenKey);
    final expiry = await storage.read(key: _expiryKey);

    if (token == null) {
      state = AuthState.unauthenticated;
      return;
    }

    if (expiry != null) {
      final expiryDate = DateTime.tryParse(expiry);
      if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
        // Try refresh
        final refreshed = await _refreshToken();
        state = refreshed ? AuthState.authenticated : AuthState.expired;
        return;
      }
    }

    state = AuthState.authenticated;
  }

  Future<bool> _refreshToken() async {
    try {
      final storage = ref.read(secureStorageProvider);
      final refreshToken = await storage.read(key: _refreshKey);
      if (refreshToken == null) return false;

      final dio = ref.read(dioProvider);
      final response = await dio.post('/auth/refresh', data: {
        'refreshToken': refreshToken,
      });

      final data = response.data as Map<String, dynamic>;
      await storage.write(key: _tokenKey, value: data['accessToken'] as String);
      await storage.write(key: _refreshKey, value: data['refreshToken'] as String);
      if (data['expiresAt'] != null) {
        await storage.write(key: _expiryKey, value: data['expiresAt'] as String);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setTokens({required String accessToken, required String refreshToken, DateTime? expiresAt}) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _tokenKey, value: accessToken);
    await storage.write(key: _refreshKey, value: refreshToken);
    if (expiresAt != null) {
      await storage.write(key: _expiryKey, value: expiresAt.toIso8601String());
    }
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/logout');
    } catch (_) {}
    final storage = ref.read(secureStorageProvider);
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshKey);
    await storage.delete(key: _expiryKey);
    state = AuthState.unauthenticated;
  }
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthState>(SessionNotifier.new);

/// Whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider) == AuthState.authenticated;
});
