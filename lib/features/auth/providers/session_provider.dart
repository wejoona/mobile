import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart'
    hide StorageKeys, secureStorageProvider;
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Authentication session state.
enum AuthState { unknown, authenticated, unauthenticated, expired }

/// Session management provider.
/// @deprecated Prefer [AuthNotifier] from auth_provider.dart for new code.
/// This provider is retained for backward compatibility with login_provider.dart.
/// Follow-up: Consolidate SessionNotifier into AuthNotifier to eliminate dual auth state.
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
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = _authPayload(response.data);
      final accessToken = data['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) return false;

      await storage.write(key: _tokenKey, value: accessToken);
      final nextRefreshToken = data['refreshToken'] as String?;
      if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
        await storage.write(key: _refreshKey, value: nextRefreshToken);
      }
      if (data['expiresAt'] != null) {
        await storage.write(
          key: _expiryKey,
          value: data['expiresAt'] as String,
        );
      } else if (data['expiresIn'] != null) {
        final expiresIn = data['expiresIn'] as num;
        await storage.write(
          key: _expiryKey,
          value: DateTime.now()
              .add(Duration(seconds: expiresIn.toInt()))
              .toIso8601String(),
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    DateTime? expiresAt,
  }) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _tokenKey, value: accessToken);
    await storage.write(key: _refreshKey, value: refreshToken);
    if (expiresAt != null) {
      await storage.write(key: _expiryKey, value: expiresAt.toIso8601String());
    }
    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    final storage = ref.read(secureStorageProvider);
    try {
      final refreshToken = await storage.read(key: _refreshKey);
      final dio = ref.read(dioProvider);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await dio.post('/auth/logout', data: {'refreshToken': refreshToken});
      }
    } catch (_) {}
    await storage.delete(key: _tokenKey);
    await storage.delete(key: _refreshKey);
    await storage.delete(key: _expiryKey);
    state = AuthState.unauthenticated;
  }
}

Map<String, dynamic> _authPayload(Object? raw) {
  if (raw is Map<String, dynamic>) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) return data;
    return raw;
  }
  if (raw is Map) {
    final map = Map<String, dynamic>.from(raw);
    final data = map['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    return map;
  }
  return const <String, dynamic>{};
}

final sessionProvider = NotifierProvider<SessionNotifier, AuthState>(
  SessionNotifier.new,
);

/// Whether the user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(sessionProvider) == AuthState.authenticated;
});
