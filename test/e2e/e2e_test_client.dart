/// Shared HTTP client for E2E tests — calls the real backend API.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// API base URL — override via env: API_URL=...
final String _envApiUrl = Platform.environment['API_URL'] ??
    const String.fromEnvironment('API_URL',
        defaultValue: 'https://dev-api.joonapay.com/api/v1');

/// Pre-configured auth token for prod testing (no /dev/otp in prod)
final String _envAuthToken = Platform.environment['AUTH_TOKEN'] ??
    const String.fromEnvironment('AUTH_TOKEN', defaultValue: '');

/// Test phone
final String testPhone = Platform.environment['TEST_PHONE'] ??
    const String.fromEnvironment('TEST_PHONE', defaultValue: '+2250700000000');

/// E2E test bypass secret — skips rate limiting in dev mode
const String _testBypassSecret = 'korido-e2e-test-2026';

/// Lightweight HTTP wrapper for E2E tests.
class E2EClient {
  E2EClient({String? baseUrl}) : baseUrl = baseUrl ?? _envApiUrl;

  final String baseUrl;
  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'X-Test-Bypass': _testBypassSecret,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  // ── HTTP verbs ──

  Future<E2EResponse> get(String path) async {
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: _headers);
    return E2EResponse(res);
  }

  Future<E2EResponse> post(String path, [Map<String, dynamic>? body]) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> put(String path, [Map<String, dynamic>? body]) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> delete(String path) async {
    final res =
        await http.delete(Uri.parse('$baseUrl$path'), headers: _headers);
    return E2EResponse(res);
  }

  // ── Auth helpers ──

  /// Register → get OTP from dev endpoint → verify OTP → get tokens.
  /// If AUTH_TOKEN is set via --dart-define, skips the flow entirely.
  Future<void> loginFlow(String phone) async {
    // If pre-configured token provided, use it directly
    if (_envAuthToken.isNotEmpty) {
      _accessToken = _envAuthToken;
      return;
    }
    // Step 1: Register (idempotent) then login
    await post('/auth/register', {'phone': phone, 'countryCode': 'CI'});
    await post('/auth/login', {'phone': phone});

    // Step 2: Get OTP from dev endpoint
    final otpRes = await get('/dev/otp/${Uri.encodeComponent(phone)}');
    String otp;
    if (otpRes.statusCode == 200 && otpRes.data?['data']?['otp'] != null) {
      otp = otpRes.data!['data']['otp'].toString();
    } else {
      // Fall back to default dev OTP
      otp = '123456';
    }

    // Step 3: Verify OTP → get tokens
    final verifyRes = await post('/auth/verify-otp', {
      'phone': phone,
      'otp': otp,
    });

    if (verifyRes.statusCode == 200 || verifyRes.statusCode == 201) {
      final data = verifyRes.data?['data'] ?? verifyRes.data;
      _accessToken = data?['accessToken'] ?? data?['access_token'];
      _refreshToken = data?['refreshToken'] ?? data?['refresh_token'];
    }
  }

  /// Refresh the access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    final res = await post('/auth/refresh', {'refreshToken': _refreshToken});
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data?['data'] ?? res.data;
      _accessToken = data?['accessToken'] ?? data?['access_token'];
      _refreshToken = data?['refreshToken'] ?? data?['refresh_token'] ?? _refreshToken;
      return true;
    }
    return false;
  }
}

/// Thin wrapper around http.Response with JSON parsing.
class E2EResponse {
  E2EResponse(this._raw);
  final http.Response _raw;

  int get statusCode => _raw.statusCode;
  String get body => _raw.body;

  Map<String, dynamic>? get data {
    try {
      return jsonDecode(_raw.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  bool get isOk => statusCode >= 200 && statusCode < 300;

  /// Assert status code — throws with body on failure for easy debugging.
  void expectStatus(int expected) {
    if (statusCode != expected) {
      throw AssertionError(
        'Expected $expected but got $statusCode\nBody: ${_raw.body}',
      );
    }
  }

  /// Assert 2xx
  void expectOk() {
    if (!isOk) {
      throw AssertionError('Expected 2xx but got $statusCode\nBody: ${_raw.body}');
    }
  }

  @override
  String toString() => 'E2EResponse($statusCode, ${_raw.body.length > 200 ? '${_raw.body.substring(0, 200)}...' : _raw.body})';
}
