/// Shared HTTP client for E2E tests — calls the real backend API.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

/// API base URL — override via env: API_URL=...
final String _envApiUrl =
    Platform.environment['API_URL'] ??
    const String.fromEnvironment(
      'API_URL',
      defaultValue: 'https://dev-api.joonapay.com/api/v1',
    );

/// Pre-configured auth token for prod testing (no /dev/otp in prod)
final String _envAuthToken =
    Platform.environment['AUTH_TOKEN'] ??
    const String.fromEnvironment('AUTH_TOKEN', defaultValue: '');

/// Test phone
final String testPhone =
    Platform.environment['TEST_PHONE'] ??
    const String.fromEnvironment('TEST_PHONE', defaultValue: '+2250700000000');

/// Live E2E tests are opt-in because they mutate real backend state.
final bool runE2E =
    Platform.environment['RUN_E2E'] == 'true' ||
    const bool.fromEnvironment('RUN_E2E');

final String? e2eSkipReason = runE2E
    ? null
    : 'Set RUN_E2E=true or --dart-define=RUN_E2E=true to run live E2E tests';

void e2eGroup(String description, void Function() body) {
  group(description, body, skip: e2eSkipReason);
}

/// E2E test bypass secret — skips rate limiting in dev mode
const String _testBypassSecret = 'korido-e2e-test-2026';

/// Generate an isolated CI-format Ivorian phone number for mutating E2E flows.
String uniqueE2EPhone() {
  final seed = DateTime.now().microsecondsSinceEpoch.toString();
  return '+22507${seed.substring(seed.length - 8)}';
}

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

  Future<E2EResponse> get(String path, [Map<String, String>? headers]) async {
    final res = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, ...?headers},
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> post(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> put(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> delete(
    String path, [
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  ]) async {
    final res = await http.delete(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> patch(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: {..._headers, ...?headers},
      body: body != null ? jsonEncode(body) : null,
    );
    return E2EResponse(res);
  }

  // ── Auth helpers ──

  /// Register → get OTP from dev endpoint → verify OTP → get tokens.
  /// If AUTH_TOKEN is set via --dart-define, skips the flow entirely.
  Future<void> loginFlow(String phone) async {
    if (!runE2E) return;

    // If pre-configured token provided, use it directly
    if (_envAuthToken.isNotEmpty) {
      _accessToken = _envAuthToken;
      return;
    }
    // Step 1: Register is idempotent and sends an OTP for both new and
    // existing users, so avoid a second OTP request through /auth/login.
    final registerRes = await post('/auth/register', {
      'phone': phone,
      'countryCode': 'CI',
    });
    _expectAuthStepOk('register', registerRes);

    // Step 2: Get OTP from dev endpoint when local verification is active.
    // For VerifyHQ sandbox, /dev/otp intentionally has no local OTP, so the
    // default dev code remains the fallback.
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
    _expectAuthStepOk('verify OTP', verifyRes);

    if (verifyRes.statusCode == 200 || verifyRes.statusCode == 201) {
      final data = verifyRes.data?['data'] ?? verifyRes.data;
      _accessToken =
          data?['accessToken']?.toString() ?? data?['access_token']?.toString();
      _refreshToken =
          data?['refreshToken']?.toString() ??
          data?['refresh_token']?.toString();
    }

    if (_accessToken == null || _accessToken!.isEmpty) {
      throw AssertionError(
        'Live E2E login did not return an access token.\n'
        'Base URL: $baseUrl\n'
        'Phone: $phone\n'
        'Verify response: ${verifyRes.statusCode} ${verifyRes.body}',
      );
    }

    final sessionProbe = await get('/sessions');
    if (sessionProbe.statusCode == 401) {
      throw AssertionError(
        'Live E2E login returned an invalid access token.\n'
        'Base URL: $baseUrl\n'
        'Phone: $phone\n'
        'Token prefix: ${_accessToken!.substring(0, 16)}...\n'
        'Session probe: ${sessionProbe.statusCode} ${sessionProbe.body}',
      );
    }
  }

  void _expectAuthStepOk(String step, E2EResponse response) {
    if (response.isOk) return;
    throw AssertionError(
      'Live E2E auth $step failed.\n'
      'Base URL: $baseUrl\n'
      'Status: ${response.statusCode}\n'
      'Body: ${response.body}',
    );
  }

  /// Refresh the access token
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    final res = await post('/auth/refresh', {'refreshToken': _refreshToken});
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = res.data?['data'] ?? res.data;
      _accessToken = data?['accessToken'] ?? data?['access_token'];
      _refreshToken =
          data?['refreshToken'] ?? data?['refresh_token'] ?? _refreshToken;
      return true;
    }
    return false;
  }

  Future<void> ensureWallet() async {
    if (!runE2E) return;

    final res = await post('/wallet/create');
    if (res.statusCode == 200 || res.statusCode == 201) return;
    throw AssertionError(
      'Live E2E wallet creation failed.\n'
      'Base URL: $baseUrl\n'
      'Status: ${res.statusCode}\n'
      'Body: ${res.body}',
    );
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
      throw AssertionError(
        'Expected 2xx but got $statusCode\nBody: ${_raw.body}',
      );
    }
  }

  @override
  String toString() =>
      'E2EResponse($statusCode, ${_raw.body.length > 200 ? '${_raw.body.substring(0, 200)}...' : _raw.body})';
}
