import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/config/api_config.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/security_headers_interceptor.dart'
    show securityHeadersInterceptorProvider;
import 'package:usdc_wallet/services/api/cache_interceptor.dart';
import 'package:usdc_wallet/services/api/deduplication_interceptor.dart';
import 'package:usdc_wallet/services/api/retry_interceptor.dart';
import 'package:usdc_wallet/services/security/jwe/jwe_service.dart';
import 'package:usdc_wallet/services/security/jwe/jwe_interceptor.dart';
import 'package:usdc_wallet/mocks/index.dart';
import 'package:usdc_wallet/services/security/certificate_pinning.dart';
import 'package:usdc_wallet/services/offline/offline_queue_interceptor.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';

/// API Configuration
/// SECURITY: Use HTTPS in production, HTTP only for local development
class ApiConfig {
  /// Resolved API URL. Kept as a compatibility wrapper for older imports.
  static String get baseUrl => ApiConfiguration.baseUrl;

  /// Check if running in production
  static bool get isProduction => EnvironmentConfig.isProduction;

  /// Check if running in development
  static bool get isDevelopment => EnvironmentConfig.isDevelopment;

  static bool get allowsBodyLogging =>
      (isDevelopment || kDebugMode) && !baseUrl.contains('joonapay.com');

  static String get environmentLabel {
    final buildMode = kReleaseMode
        ? 'release'
        : kProfileMode
        ? 'profile'
        : 'debug';
    return '${EnvironmentConfig.environment} ($buildMode)';
  }

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

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

/// Dio request metadata keys used by app services.
abstract final class ApiRequestExtra {
  static const String useRecoveryToken = 'useRecoveryToken';
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

/// Cache Interceptor Provider
final cacheInterceptorProvider = Provider<CacheInterceptor>((ref) {
  return CacheInterceptor();
});

/// Request Deduplication Interceptor Provider
final deduplicationInterceptorProvider =
    Provider<RequestDeduplicationInterceptor>((ref) {
      return RequestDeduplicationInterceptor();
    });

/// Dio Client Provider
final dioProvider = Provider<Dio>((ref) {
  final logger = AppLogger('API');

  // Log API configuration
  logger.info('API URL: ${ApiConfig.baseUrl}');
  logger.info('Environment: ${ApiConfig.environmentLabel}');
  logger.info('Mock Mode: ${MockConfig.useMocks ? 'Enabled' : 'Disabled'}');

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // SECURITY: Certificate pinning for production
  if (!MockConfig.useMocks) {
    final pinningActive = dio.enableCertificatePinning();
    logger.info(
      pinningActive
          ? 'Certificate pinning active'
          : 'Certificate pinning skipped for this build',
    );
  }

  // MOCKING: Add mock interceptor first if mocks are enabled
  if (MockConfig.useMocks) {
    MockRegistry.initialize();
    dio.interceptors.add(MockRegistry.interceptor);
    logger.info('Mock interceptor enabled - using mock API responses');
  }

  // Add auth before cache/dedup so user-specific GET state is keyed per
  // authenticated session instead of only by path.
  dio.interceptors.add(AuthInterceptor(ref));

  // PERFORMANCE: Add HTTP response caching before deduplication so a cache hit
  // does not create an in-flight deduplication entry that can never complete.
  dio.interceptors.add(ref.read(cacheInterceptorProvider));

  // PERFORMANCE: Add request deduplication for network-bound GET requests.
  dio.interceptors.add(ref.read(deduplicationInterceptorProvider));

  // SECURITY: Add device fingerprint and risk score headers
  final securityHeadersInterceptor = ref.read(
    securityHeadersInterceptorProvider,
  );
  dio.interceptors.add(securityHeadersInterceptor);

  // SECURITY: JWE encryption for sensitive endpoints (transfers, PIN, etc.)
  final jweService = ref.read(jweServiceProvider);
  jweService.init(dio); // Needs Dio to fetch server public key
  dio.interceptors.add(JweInterceptor(jweService));

  // Offline queue detection for transfer endpoints
  dio.interceptors.add(ref.read(offlineQueueInterceptorProvider));

  // Retry transient failures (GET only, exponential backoff)
  dio.interceptors.add(RetryInterceptor(dio: dio));

  // SECURITY: Only add log interceptor in debug mode to prevent sensitive data leakage
  if (kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: ApiConfig.allowsBodyLogging,
        responseBody: ApiConfig.allowsBodyLogging,
        error: true,
        // Don't log headers which may contain auth tokens
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  return dio;
});

/// Auth Interceptor - Adds JWT token to requests and handles token refresh
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  Completer<bool>? _refreshCompleter;
  bool _sessionInvalidated = false;

  static const _pinResetRecoveryScope = 'pin_reset';

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    if (_isPublicEndpoint(options.path)) {
      return handler.next(options);
    }

    final storage = _ref.read(secureStorageProvider);
    final useRecoveryToken =
        options.extra[ApiRequestExtra.useRecoveryToken] == true;

    if (useRecoveryToken) {
      final recoveryToken = await _readRecoveryTokenForScope(
        storage,
        _pinResetRecoveryScope,
      );
      if (recoveryToken != null && recoveryToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $recoveryToken';
      }
      return handler.next(options);
    }

    // Add token
    final token = await storage.read(key: StorageKeys.accessToken);

    if (token != null) {
      _sessionInvalidated = false;
      options.headers['Authorization'] = 'Bearer $token';
    } else if (_isAccountRecoveryEndpoint(options.path)) {
      final recoveryToken = await _readRecoveryTokenForScope(
        storage,
        _pinResetRecoveryScope,
      );
      if (recoveryToken != null && recoveryToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $recoveryToken';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    _scheduleVersionPolicyCheck(err);

    // Check if this is an authenticated endpoint
    final isPublicEndpoint = _isPublicEndpoint(err.requestOptions.path);
    final isAccountRecoveryEndpoint = _isAccountRecoveryEndpoint(
      err.requestOptions.path,
    );
    final optionalAuthEndpoints = ['/feature-flags/me'];
    final isOptionalAuthEndpoint = optionalAuthEndpoints.any(
      (e) => err.requestOptions.path.contains(e),
    );

    if (err.response?.statusCode == 401 && isOptionalAuthEndpoint) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401 && isAccountRecoveryEndpoint) {
      await _clearRecoveryAuthorization(_ref.read(secureStorageProvider));
      return handler.next(err);
    }

    if (_isDeviceBlacklistedError(err)) {
      await _invalidateLocalSession();
      return handler.next(err);
    }

    // Handle connection errors on authenticated endpoints - may be server rejecting expired token
    // Connection reset can happen when server sends 401 but connection closes before response arrives
    if (!isPublicEndpoint &&
        !isAccountRecoveryEndpoint &&
        err.response == null &&
        (err.type == DioExceptionType.connectionError ||
            err.type == DioExceptionType.unknown)) {
      // Try to refresh token and retry once
      if (!MockConfig.useMocks) {
        final refreshed = await _refreshToken(err.requestOptions);
        if (refreshed) {
          try {
            final storage = _ref.read(secureStorageProvider);
            final newToken = await storage.read(key: StorageKeys.accessToken);
            final response = await _retryWithAccessToken(
              err.requestOptions,
              newToken,
            );
            return handler.resolve(response);
          } catch (retryError) {
            // Retry failed, continue with original error
          }
        }
      }
    }

    // Handle 401 - Token expired, try refresh
    if (err.response?.statusCode == 401 && !isPublicEndpoint) {
      // Don't try to refresh if using mocks (mock tokens aren't valid JWTs)
      if (MockConfig.useMocks) {
        await _invalidateLocalSession();
        return handler.next(err);
      }

      // Attempt to refresh token
      final refreshed = await _refreshToken(err.requestOptions);

      if (refreshed) {
        // Retry the original request with new token
        try {
          final storage = _ref.read(secureStorageProvider);
          final newToken = await storage.read(key: StorageKeys.accessToken);

          final response = await _retryWithAccessToken(
            err.requestOptions,
            newToken,
          );
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh failed — don't logout immediately. A concurrent request may
        // have already refreshed the token.
        final storage = _ref.read(secureStorageProvider);
        final currentToken = await storage.read(key: StorageKeys.accessToken);
        final originalToken = err.requestOptions.headers['Authorization']
            ?.toString()
            .replaceFirst('Bearer ', '');

        // No concurrent refresh succeeded — LOCK the session instead of logging
        // out. The persistent session and cached data stay intact; the user
        // re-authenticates with PIN/biometric. Only a full session expiry or an
        // explicit logout clears the session.
        if (currentToken == null || currentToken == originalToken) {
          try {
            _ref
                .read(appFsmProvider.notifier)
                .dispatch(
                  const AppSessionEvent(
                    SessionLock(reason: 'Token refresh failed'),
                  ),
                );
          } catch (_) {
            // FSM might not be available in all contexts
          }
        }
        // Otherwise, retry with the new token from the concurrent refresh.
        else {
          try {
            final response = await _retryWithAccessToken(
              err.requestOptions,
              currentToken,
            );
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        }
      }
    }

    handler.next(err);
  }

  void _scheduleVersionPolicyCheck(DioException err) {
    if (!_shouldCheckVersionPolicy(err)) return;
    unawaited(
      _ref
          .read(mobileVersionPolicyProvider.notifier)
          .check(reason: 'http_${err.response?.statusCode ?? err.type.name}'),
    );
  }

  bool _shouldCheckVersionPolicy(DioException err) {
    if (MockConfig.useMocks) return false;
    if (err.requestOptions.path.contains('/config/mobile-version')) {
      return false;
    }

    final statusCode = err.response?.statusCode;
    if (statusCode == null) {
      return err.type == DioExceptionType.connectionError ||
          err.type == DioExceptionType.badResponse ||
          err.type == DioExceptionType.unknown;
    }

    return statusCode == 404 ||
        statusCode == 410 ||
        statusCode == 426 ||
        statusCode >= 500;
  }

  bool _isPublicEndpoint(String path) {
    const publicEndpoints = [
      '/auth/register',
      '/auth/verify-otp',
      '/auth/recovery/request-otp',
      '/auth/recovery/verify-otp',
      '/auth/login',
      '/auth/refresh',
      '/config/countries',
      '/config/mobile-version',
    ];
    return publicEndpoints.any(path.contains);
  }

  bool _isAccountRecoveryEndpoint(String path) {
    const recoveryEndpoints = [
      '/step-up/operation',
      '/step-up/validate',
      '/user/pin/reset',
      '/kyc/liveness',
    ];
    return recoveryEndpoints.any(path.contains);
  }

  Future<String?> _readRecoveryTokenForScope(
    FlutterSecureStorage storage,
    String scope,
  ) async {
    final token = await storage.read(key: StorageKeys.recoveryAccessToken);
    if (token == null || token.isEmpty) {
      return null;
    }

    final storedScope = await storage.read(
      key: StorageKeys.recoveryAccessTokenScope,
    );
    if (storedScope != scope) {
      return null;
    }

    return token;
  }

  Future<void> _clearRecoveryAuthorization(FlutterSecureStorage storage) async {
    await storage.delete(key: StorageKeys.recoveryAccessToken);
    await storage.delete(key: StorageKeys.recoveryAccessTokenPhone);
    await storage.delete(key: StorageKeys.recoveryAccessTokenScope);
    await storage.delete(key: StorageKeys.recoveryAccessTokenCreatedAt);
  }

  Future<Response<dynamic>> _retryWithAccessToken(
    RequestOptions original,
    String? accessToken,
  ) async {
    if (accessToken == null || accessToken.isEmpty) {
      throw StateError('Cannot retry request without an access token');
    }

    // `original` has already passed through request interceptors, so it carries
    // enriched headers such as X-Device-Id, X-Risk-Score, idempotency keys, and
    // any encrypted body produced before the 401/connection failure.
    original.headers['Authorization'] = 'Bearer $accessToken';

    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    return dio.fetch<dynamic>(original);
  }

  Future<void> _invalidateLocalSession() async {
    if (_sessionInvalidated) return;
    _sessionInvalidated = true;

    final storage = _ref.read(secureStorageProvider);
    await storage.delete(key: StorageKeys.accessToken);
    await storage.delete(key: StorageKeys.refreshToken);

    try {
      _ref.read(appFsmProvider.notifier).logout();
    } catch (_) {}

    try {
      final signal = _ref.read(authSessionInvalidatedProvider.notifier);
      signal.state = signal.state + 1;
    } catch (_) {}
  }

  bool _isDeviceBlacklistedError(DioException error) {
    final data = error.response?.data;
    if (error.response?.statusCode != 403 || data is! Map) {
      return false;
    }

    return ApiException.errorCode(data) == 'DEVICE_BLACKLISTED';
  }

  /// Refresh token with race condition protection
  /// SECURITY: Use Completer to queue concurrent refresh requests
  Future<bool> _refreshToken(RequestOptions failedRequest) async {
    // If refresh is already in progress, wait for it
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    // Create new completer for this refresh operation
    _refreshCompleter = Completer<bool>();

    try {
      final storage = _ref.read(secureStorageProvider);
      final refreshToken = await storage.read(key: StorageKeys.refreshToken);

      if (refreshToken == null) {
        _refreshCompleter!.complete(false);
        return false;
      }

      // Call refresh endpoint
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
        ),
      );
      final securityHeaders = await _ref
          .read(securityHeadersInterceptorProvider)
          .buildHeadersForPath('/auth/refresh');

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
        options: Options(headers: securityHeaders),
      );

      if (response.statusCode == 200) {
        final data = _responsePayload(response.data);
        if (data.isEmpty) {
          _refreshCompleter!.complete(false);
          return false;
        }

        final accessToken = data['accessToken'] as String?;
        if (accessToken == null || accessToken.isEmpty) {
          _refreshCompleter!.complete(false);
          return false;
        }

        await storage.write(key: StorageKeys.accessToken, value: accessToken);
        final nextRefreshToken = data['refreshToken'] as String?;
        if (nextRefreshToken != null && nextRefreshToken.isNotEmpty) {
          await storage.write(
            key: StorageKeys.refreshToken,
            value: nextRefreshToken,
          );
        }
        _refreshCompleter!.complete(true);
        return true;
      }

      _refreshCompleter!.complete(false);
      return false;
    } catch (e) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      // Clear the completer after a short delay to allow waiting requests to complete
      Future.delayed(const Duration(milliseconds: 100), () {
        _refreshCompleter = null;
      });
    }
  }
}

Map<String, dynamic> apiResponsePayload(Object? raw) {
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

Map<String, dynamic> _responsePayload(Object? raw) => apiResponsePayload(raw);

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;
  final String? code;

  ApiException({required this.message, this.statusCode, this.data, this.code});

  factory ApiException.fromDioError(DioException error) {
    String message = 'An unexpected error occurred';
    int? statusCode = error.response?.statusCode;
    final responseData = _withRetryMetadata(
      error.response?.data,
      error.response,
    );

    if (isOfflineQueueableErrorMessage(error.message)) {
      return ApiException(
        message: error.message!,
        statusCode: statusCode,
        data: const {'offlineQueueable': true},
      );
    }

    if (responseData != null) {
      final data = responseData;
      final code = errorCode(data);
      if (code == 'DEVICE_BLACKLISTED') {
        return ApiException(
          message: 'This device has been blocked. Contact Korido support.',
          statusCode: statusCode,
          data: data,
          code: code,
        );
      }
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      } else if (data is Map &&
          data['error'] is Map &&
          (data['error'] as Map)['message'] != null) {
        message = (data['error'] as Map)['message'].toString();
      } else {
        message = _getMessageFromStatusCode(statusCode);
      }
    } else {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = 'Connection timed out';
          break;
        case DioExceptionType.connectionError:
          message = 'No internet connection';
          break;
        case DioExceptionType.badResponse:
          message = _getMessageFromStatusCode(statusCode);
          break;
        default:
          message = 'An unexpected error occurred';
      }
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: responseData,
      code: errorCode(responseData),
    );
  }

  bool get isDeviceBlacklisted => code == 'DEVICE_BLACKLISTED';

  int? get retryAfterSeconds => _positiveSecondsFrom(data, const [
    'retryAfterSeconds',
    'retryAfter',
    'retry_after_seconds',
    'retry_after',
  ]);

  int? get resendAvailableIn => _positiveSecondsFrom(data, const [
    'resendAvailableIn',
    'retryAfterSeconds',
    'retryAfter',
    'retry_after_seconds',
    'retry_after',
  ]);

  static String? errorCode(Object? data) {
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['code'] != null) {
        return error['code'].toString();
      }
      if (error is String) {
        return error;
      }
      final value = data['code'];
      return value?.toString();
    }
    return null;
  }

  static int? _positiveSecondsFrom(Object? data, List<String> keys) {
    if (data is! Map) return null;

    for (final key in keys) {
      final parsed = _parsePositiveSeconds(data[key]);
      if (parsed != null) return parsed;
    }

    final error = data['error'];
    if (error is Map) {
      for (final key in keys) {
        final parsed = _parsePositiveSeconds(error[key]);
        if (parsed != null) return parsed;
      }

      final context = error['context'];
      if (context is Map) {
        for (final key in keys) {
          final parsed = _parsePositiveSeconds(context[key]);
          if (parsed != null) return parsed;
        }
      }
    }

    final context = data['context'];
    if (context is Map) {
      for (final key in keys) {
        final parsed = _parsePositiveSeconds(context[key]);
        if (parsed != null) return parsed;
      }
    }

    return null;
  }

  static Object? _withRetryMetadata(Object? data, Response? response) {
    final retryAfterSeconds = _retryAfterSecondsFromHeaders(response?.headers);
    if (retryAfterSeconds == null) return data;

    if (data is Map<String, dynamic>) {
      final copy = Map<String, dynamic>.from(data);
      copy.putIfAbsent('retryAfterSeconds', () => retryAfterSeconds);
      copy.putIfAbsent('resendAvailableIn', () => retryAfterSeconds);
      return copy;
    }

    if (data is Map) {
      final copy = Map<String, dynamic>.from(data);
      copy.putIfAbsent('retryAfterSeconds', () => retryAfterSeconds);
      copy.putIfAbsent('resendAvailableIn', () => retryAfterSeconds);
      return copy;
    }

    return {
      'retryAfterSeconds': retryAfterSeconds,
      'resendAvailableIn': retryAfterSeconds,
    };
  }

  static int? _retryAfterSecondsFromHeaders(Headers? headers) {
    if (headers == null) return null;

    final retryAfter = _parseRetryHeader(headers.value('retry-after'));
    if (retryAfter != null) return retryAfter;

    final rateLimitReset = _parsePositiveSeconds(
      headers.value('x-ratelimit-reset'),
    );
    return rateLimitReset;
  }

  static int? _parseRetryHeader(String? value) {
    final seconds = _parsePositiveSeconds(value);
    if (seconds != null) return seconds;

    if (value == null || value.trim().isEmpty) return null;
    final parsedDate = DateTime.tryParse(value.trim());
    if (parsedDate == null) return null;
    final difference = parsedDate.difference(DateTime.now()).inSeconds;
    return difference <= 0 ? 1 : difference;
  }

  static int? _parsePositiveSeconds(Object? value) {
    final number = switch (value) {
      int() => value,
      double() => value.ceil(),
      String() => int.tryParse(value),
      _ => null,
    };
    if (number == null || number <= 0) return null;
    return number;
  }

  static String _getMessageFromStatusCode(int? code) {
    switch (code) {
      case 400:
        return 'Invalid request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Access denied';
      case 404:
        return 'Not found';
      case 422:
        return 'Validation failed';
      case 429:
        return 'Too many attempts. Please wait a few minutes and try again.';
      case 500:
        return 'Server error';
      case 502:
      case 503:
      case 504:
      case 521:
      case 522:
      case 523:
      case 524:
        return 'Korido is temporarily unavailable. Please try again in a few minutes.';
      default:
        return 'An unexpected error occurred';
    }
  }

  @override
  String toString() => message;
}
