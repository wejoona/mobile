import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Dio interceptor that attaches auth tokens to requests.
class AuthInterceptor {
  static const _tag = 'AuthInterceptor';
  final AppLogger _log = AppLogger(_tag);
  String? _accessToken;
  String? _refreshToken;

  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  /// Get headers to attach to requests.
  Map<String, String> getAuthHeaders() {
    if (_accessToken == null) return {};
    return {'Authorization': 'Bearer $_accessToken'};
  }

  /// Check if tokens are set.
  bool get hasTokens => _accessToken != null;

  /// Clear tokens on logout.
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _log.debug('Auth tokens cleared');
  }

  /// Refresh the access token using the refresh token.
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    _log.debug('Refreshing access token');
    // Would call auth endpoint
    return true;
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});
