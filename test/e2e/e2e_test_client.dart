/// Shared HTTP client for E2E tests — calls the real backend API.
// ignore_for_file: do_not_use_environment, avoid_dynamic_calls, avoid_slow_async_io
// ignore_for_file: avoid_catches_without_on_clauses
// ignore_for_file: always_put_control_body_on_new_line
// ignore_for_file: avoid_redundant_argument_values

library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:http_parser/http_parser.dart';
import 'package:test/test.dart';

/// Live E2E tests are opt-in because they call real backend services.
final bool runLiveE2E =
    Platform.environment['RUN_LIVE_E2E'] == 'true' ||
    const bool.fromEnvironment('RUN_LIVE_E2E');

const String liveE2ESkipReason =
    'Set RUN_LIVE_E2E=true and API_URL/AUTH_TOKEN as needed to run live backend E2E tests.';

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

/// Default OTP used by the test stack when the dev OTP endpoint is unavailable.
final String defaultTestOtp =
    Platform.environment['DEFAULT_OTP'] ??
    const String.fromEnvironment('DEFAULT_OTP', defaultValue: '123456');

/// Test phone
final String testPhone =
    Platform.environment['TEST_PHONE'] ??
    const String.fromEnvironment('TEST_PHONE', defaultValue: '+2250700000000');

/// Test country for local phone normalization
final String testCountryCode =
    Platform.environment['TEST_COUNTRY'] ??
    const String.fromEnvironment('TEST_COUNTRY', defaultValue: 'CI');

/// Live E2E tests are opt-in because they mutate real backend state.
final bool runE2E =
    Platform.environment['RUN_E2E'] == 'true' ||
    const bool.fromEnvironment('RUN_E2E');

/// Alias used by test files that check `e2eEnabled` at the top of main().
bool get e2eEnabled => runE2E;

final String? e2eSkipReason = runE2E
    ? null
    : 'Set RUN_E2E=true or --dart-define=RUN_E2E=true to run live E2E tests';

final File _tokenCacheFile = File(
  '${Directory.systemTemp.path}/korido_live_e2e_token_cache.json',
);

void skipE2ESuite() {
  group('E2E suite disabled', () {
    test(
      'set RUN_E2E=true and API_URL to run real backend checks',
      () {},
      skip: 'E2E tests call a real backend and are opt-in.',
    );
  });
}

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
  E2EClient({String? baseUrl})
    : baseUrl = baseUrl ?? _envApiUrl,
      _client = IOClient(
        HttpClient()
          ..connectionTimeout = const Duration(seconds: 15)
          ..badCertificateCallback = (cert, host, port) => true,
      );

  final String baseUrl;
  final http.Client _client;
  final String deviceIdentifier =
      Platform.environment['E2E_DEVICE_ID'] ??
      const String.fromEnvironment(
        'E2E_DEVICE_ID',
        defaultValue: 'e2e-test-device-001',
      );
  String? _accessToken;
  String? _refreshToken;
  String? _tokenPhone;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-Test-Bypass': _testBypassSecret,
    'X-Device-Id': deviceIdentifier,
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _tokenPhone = null;
  }

  // ── HTTP verbs ──

  Future<E2EResponse> get(String path, [Map<String, String>? headers]) async {
    final res = await _sendWithRateLimitRetry(
      () => _client.get(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, ...?headers},
      ),
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> post(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await _sendWithRateLimitRetry(
      () => _client.post(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> put(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await _sendWithRateLimitRetry(
      () => _client.put(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> delete(
    String path, [
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  ]) async {
    final res = await _sendWithRateLimitRetry(
      () => _client.delete(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> patch(
    String path, [
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  ]) async {
    final res = await _sendWithRateLimitRetry(
      () => _client.patch(
        Uri.parse('$baseUrl$path'),
        headers: {..._headers, ...?headers},
        body: body != null ? jsonEncode(body) : null,
      ),
    );
    return E2EResponse(res);
  }

  Future<E2EResponse> multipartPost(
    String path, {
    required String fieldName,
    required File file,
    String? filename,
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    final res = await _sendWithRateLimitRetry(() async {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      request.headers.addAll({
        'X-Test-Bypass': _testBypassSecret,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        ...?headers,
      });
      if (fields != null) request.fields.addAll(fields);
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          filename: filename ?? file.uri.pathSegments.last,
          contentType: _contentTypeForPath(filename ?? file.path),
        ),
      );

      final streamed = await request.send();
      return http.Response.fromStream(streamed);
    });
    return E2EResponse(res);
  }

  MediaType _contentTypeForPath(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => MediaType('image', 'png'),
      'webp' => MediaType('image', 'webp'),
      'jpg' || 'jpeg' => MediaType('image', 'jpeg'),
      _ => MediaType('application', 'octet-stream'),
    };
  }

  Future<http.Response> _sendWithRateLimitRetry(
    Future<http.Response> Function() send,
  ) async {
    var response = await send();
    if (!runLiveE2E || response.statusCode != 429) return response;

    for (final fallbackDelay in const [
      Duration(seconds: 15),
      Duration(seconds: 45),
    ]) {
      await Future.delayed(_rateLimitDelay(response) ?? fallbackDelay);
      response = await send();
      if (response.statusCode != 429) return response;
    }

    return response;
  }

  Duration? _rateLimitDelay(http.Response response) {
    final retryAfter = response.headers['retry-after'];
    if (retryAfter == null) return null;

    final seconds = int.tryParse(retryAfter);
    if (seconds == null || seconds <= 0) return null;

    return Duration(seconds: seconds.clamp(1, 60));
  }

  // ── Auth helpers ──

  /// Register → get OTP from dev endpoint → verify OTP → get tokens.
  /// If AUTH_TOKEN is set via --dart-define, skips the flow entirely.
  Future<void> loginFlow(String phone) async {
    if (!runE2E) return;

    // If pre-configured token provided, use it directly
    if (_envAuthToken.isNotEmpty) {
      _accessToken = _envAuthToken;
      _tokenPhone = phone;
      return;
    }

    if (await _loadCachedTokens(phone)) {
      final sessionProbe = await get('/sessions');
      if (sessionProbe.isOk) {
        return;
      }
      await _clearTokenCache();
      clearTokens();
    }

    // Step 1: Register is idempotent and sends an OTP for both new and
    // existing users, so avoid a second OTP request through /auth/login.
    final consentPayload = await registrationConsentPayload();
    final registerRes = await post('/auth/register', {
      'phone': phone,
      'countryCode': 'CI',
      ...consentPayload,
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
      // Fall back to the configured default OTP for staging/dogfood stacks.
      otp = defaultTestOtp;
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
      _tokenPhone = phone;
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
    if (!sessionProbe.isOk) {
      throw AssertionError(
        'Live E2E login returned an invalid access token.\n'
        'Base URL: $baseUrl\n'
        'Phone: $phone\n'
        'Token prefix: ${_accessToken!.substring(0, 16)}...\n'
        'Session probe: ${sessionProbe.statusCode} ${sessionProbe.body}',
      );
    }

    await _saveCachedTokens(phone);
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

  Future<Map<String, dynamic>> registrationConsentPayload() async {
    final termsVersion = await _legalDocumentVersion('/legal/terms');
    final privacyVersion = await _legalDocumentVersion('/legal/privacy');
    return {
      'acceptedTerms': true,
      if (termsVersion != null) 'termsVersion': termsVersion,
      if (privacyVersion != null) 'privacyVersion': privacyVersion,
    };
  }

  Future<String?> _legalDocumentVersion(String path) async {
    try {
      final res = await get(path);
      if (!res.isOk) return null;

      final body = res.data;
      final payload = body?['data'];
      final document = payload is Map<String, dynamic> ? payload : body;
      return document?['version']?.toString();
    } catch (_) {
      return null;
    }
  }

  Future<String> resolveOtp(String phone) async {
    final otpRes = await get('/dev/otp/${Uri.encodeComponent(phone)}');
    if (otpRes.statusCode == 200 && otpRes.data?['data']?['otp'] != null) {
      return otpRes.data!['data']['otp'].toString();
    }

    return defaultTestOtp;
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
      await _saveCachedTokens(_tokenPhone ?? testPhone);
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

  Future<bool> _loadCachedTokens(String phone) async {
    if (!await _tokenCacheFile.exists()) return false;
    try {
      final cached =
          jsonDecode(await _tokenCacheFile.readAsString())
              as Map<String, dynamic>;
      if (cached['baseUrl'] != baseUrl) return false;
      if (cached['phone'] != phone) return false;
      if (cached['deviceIdentifier'] != deviceIdentifier) return false;
      final access = cached['accessToken']?.toString();
      final refresh = cached['refreshToken']?.toString();
      if (access == null || access.isEmpty) return false;
      _accessToken = access;
      _tokenPhone = phone;
      if (refresh != null && refresh.isNotEmpty) {
        _refreshToken = refresh;
      }
      return true;
    } catch (_) {
      await _clearTokenCache();
      return false;
    }
  }

  Future<void> _saveCachedTokens(String phone) async {
    if (_accessToken == null || _accessToken!.isEmpty) return;
    await _tokenCacheFile.writeAsString(
      jsonEncode({
        'baseUrl': baseUrl,
        'phone': phone,
        'deviceIdentifier': deviceIdentifier,
        'accessToken': _accessToken,
        'refreshToken': _refreshToken,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _clearTokenCache() async {
    if (await _tokenCacheFile.exists()) {
      await _tokenCacheFile.delete();
    }
  }

  void close() => _client.close();
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
