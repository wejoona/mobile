import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
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

/// API Configuration
/// SECURITY: Use HTTPS in production, HTTP only for local development
class ApiConfig {
  // Environment-based configuration using --dart-define
  // Pass via: flutter run --dart-define=API_URL=http://YOUR_IP:3000/api/v1
  // Or use: flutter run --dart-define-from-file=env.dev.json

  /// Get API URL from compile-time environment variable
  /// Falls back to default dev/prod URLs if not specified
  static const String _envApiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  /// Environment type (development, staging, production)
  static const String _env = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Default development URL — dev API with debug endpoints
  static const String _defaultDevUrl = 'https://api.joonapay.com/api/v1';

  /// Default production URL
  static const String _defaultProdUrl = 'https://api.joonapay.com/api/v1';

  /// Get the base URL based on environment and configuration
  /// Priority: 1. --dart-define API_URL, 2. ENV-based default
  /// SECURITY: Always use HTTPS in production
  static String get baseUrl {
    // If API_URL is explicitly set via --dart-define, use it
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }

    // Otherwise, use environment-appropriate default
    switch (_env) {
      case 'production':
        return _defaultProdUrl;
      case 'staging':
        return 'https://staging-api.joonapay.com/api/v1';
      case 'development':
      default:
        return kDebugMode ? _defaultDevUrl : _defaultProdUrl;
    }
  }

  /// Check if running in production
  static bool get isProduction => _env == 'production';

  /// Check if running in development
  static bool get isDevelopment => _env == 'development' || kDebugMode;

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Secure Storage Keys
class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
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
  logger.info(
    'Environment: ${ApiConfig.isDevelopment ? 'Development' : 'Production'}',
  );
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
    dio.enableCertificatePinning();
    logger.info('Certificate pinning enabled');
  }

  // MOCKING: Add mock interceptor first if mocks are enabled
  if (MockConfig.useMocks) {
    MockRegistry.initialize();
    dio.interceptors.add(MockRegistry.interceptor);
    logger.info('Mock interceptor enabled - using mock API responses');
  }

  // PERFORMANCE: Add request deduplication
  dio.interceptors.add(ref.read(deduplicationInterceptorProvider));

  // PERFORMANCE: Add HTTP response caching (must be before auth)
  dio.interceptors.add(ref.read(cacheInterceptorProvider));

  // SECURITY: Add device fingerprint and risk score headers
  final securityHeadersInterceptor = ref.read(
    securityHeadersInterceptorProvider,
  );
  dio.interceptors.add(securityHeadersInterceptor);

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

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
        requestBody: true,
        responseBody: true,
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

  AuthInterceptor(this._ref);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for public endpoints
    final publicEndpoints = [
      '/auth/register',
      '/auth/verify-otp',
      '/auth/login',
      '/auth/refresh',
    ];
    final isPublicEndpoint = publicEndpoints.any(
      (e) => options.path.contains(e),
    );
    if (isPublicEndpoint) {
      return handler.next(options);
    }

    // Add token
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: StorageKeys.accessToken);

    if (token != null) {
      _sessionInvalidated = false;
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if this is an authenticated endpoint
    final publicEndpoints = [
      '/auth/register',
      '/auth/verify-otp',
      '/auth/login',
      '/auth/refresh',
    ];
    final isPublicEndpoint = publicEndpoints.any(
      (e) => err.requestOptions.path.contains(e),
    );
    final optionalAuthEndpoints = ['/feature-flags/me'];
    final isOptionalAuthEndpoint = optionalAuthEndpoints.any(
      (e) => err.requestOptions.path.contains(e),
    );

    if (err.response?.statusCode == 401 && isOptionalAuthEndpoint) {
      return handler.next(err);
    }

    // Handle connection errors on authenticated endpoints - may be server rejecting expired token
    // Connection reset can happen when server sends 401 but connection closes before response arrives
    if (!isPublicEndpoint &&
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
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';

            final dio = Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
              ),
            );

            final response = await dio.fetch(options);
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

          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';

          final dio = Dio(
            BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
            ),
          );

          final response = await dio.fetch(options);
          return handler.resolve(response);
        } catch (e) {
          return handler.next(err);
        }
      } else {
        // Refresh failed — but DON'T logout immediately.
        // The token may have been refreshed by a concurrent request.
        // Only clear tokens if we truly have no valid access token.
        final storage = _ref.read(secureStorageProvider);
        final currentToken = await storage.read(key: StorageKeys.accessToken);
        final originalToken = err.requestOptions.headers['Authorization']
            ?.toString()
            .replaceFirst('Bearer ', '');

        // Only logout if the current token is still the same failed one
        // (meaning no concurrent refresh succeeded)
        if (currentToken == null || currentToken == originalToken) {
          await _invalidateLocalSession();
        }
        // Otherwise, retry with the new token from concurrent refresh
        else {
          try {
            final options = err.requestOptions;
            options.headers['Authorization'] = 'Bearer $currentToken';
            final dio = Dio(
              BaseOptions(
                baseUrl: ApiConfig.baseUrl,
                connectTimeout: ApiConfig.connectTimeout,
                receiveTimeout: ApiConfig.receiveTimeout,
              ),
            );
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(err);
          }
        }
      }
    }

    handler.next(err);
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

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is! Map<String, dynamic>) {
          _refreshCompleter!.complete(false);
          return false;
        }

        await storage.write(
          key: StorageKeys.accessToken,
          value: data['accessToken'] as String?,
        );
        await storage.write(
          key: StorageKeys.refreshToken,
          value: data['refreshToken'] as String?,
        );
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

/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioError(DioException error) {
    String message = 'An unexpected error occurred';
    int? statusCode = error.response?.statusCode;

    if (isOfflineQueueableErrorMessage(error.message)) {
      return ApiException(
        message: error.message!,
        statusCode: statusCode,
        data: const {'offlineQueueable': true},
      );
    }

    if (error.response?.data != null) {
      final data = error.response?.data;
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
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
      data: error.response?.data,
    );
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
