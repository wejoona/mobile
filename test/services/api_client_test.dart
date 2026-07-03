import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import '../helpers/test_utils.dart';

final _authInterceptorTestProvider = Provider<AuthInterceptor>(
  AuthInterceptor.new,
);

class _RecordingVersionPolicyController extends MobileVersionPolicyController {
  static final reasons = <String>[];

  @override
  MobileVersionPolicyState build() => const MobileVersionPolicyState();

  @override
  Future<MobileVersionPolicy?> check({
    String reason = 'startup',
    bool force = false,
  }) async {
    reasons.add(reason);
    return state.policy;
  }
}

class _DeviceBlacklistedAdapter implements HttpClientAdapter {
  const _DeviceBlacklistedAdapter({this.nestedEnvelope = false});

  final bool nestedEnvelope;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = nestedEnvelope
        ? {
            'success': false,
            'error': {
              'code': 'DEVICE_BLACKLISTED',
              'message': 'Access denied. This device has been blocked.',
            },
          }
        : {
            'statusCode': 403,
            'message': 'Access denied. This device has been blocked.',
            'error': 'DEVICE_BLACKLISTED',
          };

    return ResponseBody.fromString(
      jsonEncode(body),
      403,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _UpgradeRequiredAdapter implements HttpClientAdapter {
  const _UpgradeRequiredAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({
        'statusCode': 426,
        'message': 'Upgrade required',
        'error': 'UPGRADE_REQUIRED',
      }),
      426,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _RecordingStatusAdapter implements HttpClientAdapter {
  _RecordingStatusAdapter({this.statusCode = 200});

  final int statusCode;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);

    return ResponseBody.fromString(
      jsonEncode({'success': statusCode < 400}),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late MockSecureStorage mockStorage;

  setUpAll(registerFallbackValues);

  setUp(() {
    mockStorage = MockSecureStorage();
    _RecordingVersionPolicyController.reasons.clear();
  });

  tearDown(() {
    mockStorage.clear();
  });

  group('AuthInterceptor session invalidation', () {
    test('uses scoped recovery token for account recovery endpoints', () async {
      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
      );
      addTearDown(container.dispose);

      await mockStorage.write(
        key: StorageKeys.recoveryAccessToken,
        value: 'recovery.access',
      );
      await mockStorage.write(
        key: StorageKeys.recoveryAccessTokenScope,
        value: 'pin_reset',
      );

      final adapter = _RecordingStatusAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(container.read(_authInterceptorTestProvider));

      await dio.post('/user/pin/reset');

      expect(
        adapter.requests.single.headers['Authorization'],
        'Bearer recovery.access',
      );
    });

    test('keeps recovery OTP request and verification public', () async {
      final container = ProviderContainer(
        overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
      );
      addTearDown(container.dispose);

      await mockStorage.write(
        key: StorageKeys.accessToken,
        value: 'active.access',
      );
      await mockStorage.write(
        key: StorageKeys.recoveryAccessToken,
        value: 'recovery.access',
      );

      final adapter = _RecordingStatusAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(container.read(_authInterceptorTestProvider));

      await dio.post('/auth/recovery/request-otp');
      await dio.post('/auth/recovery/verify-otp');

      expect(adapter.requests, hasLength(2));
      for (final request in adapter.requests) {
        expect(request.headers['Authorization'], isNull);
      }
    });

    test(
      'explicit recovery scope wins over active access token for liveness',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'active.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessTokenScope,
          value: 'pin_reset',
        );

        final adapter = _RecordingStatusAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await dio.post(
          '/kyc/liveness/session',
          options: Options(extra: {ApiRequestExtra.useRecoveryToken: true}),
        );

        expect(
          adapter.requests.single.headers['Authorization'],
          'Bearer recovery.access',
        );
      },
    );

    test(
      'normal liveness keeps active access token when recovery is not scoped',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'active.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessTokenScope,
          value: 'pin_reset',
        );

        final adapter = _RecordingStatusAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await dio.post('/kyc/liveness/session');

        expect(
          adapter.requests.single.headers['Authorization'],
          'Bearer active.access',
        );
      },
    );

    test(
      'does not use recovery token for normal authenticated endpoints',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessTokenScope,
          value: 'pin_reset',
        );

        final adapter = _RecordingStatusAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await dio.get('/wallet');

        expect(adapter.requests.single.headers['Authorization'], isNull);
      },
    );

    test(
      'does not use recovery token for generic support ticket routes',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessTokenScope,
          value: 'pin_reset',
        );

        final adapter = _RecordingStatusAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await dio.get('/support/tickets/active');

        expect(adapter.requests.single.headers['Authorization'], isNull);
      },
    );

    test(
      'recovery 401 clears recovery token without invalidating app session',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'active.access',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'active.refresh',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );

        final adapter = _RecordingStatusAdapter(statusCode: 401);
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await expectLater(
          dio.post(
            '/user/pin/reset',
            options: Options(extra: {ApiRequestExtra.useRecoveryToken: true}),
          ),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        expect(mockStorage.storage[StorageKeys.recoveryAccessToken], isNull);
        expect(mockStorage.storage[StorageKeys.accessToken], 'active.access');
        expect(mockStorage.storage[StorageKeys.refreshToken], 'active.refresh');
        expect(container.read(authSessionInvalidatedProvider), equals(0));
      },
    );

    test(
      'normal liveness 401 does not clear scoped recovery authorization',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'expired.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessToken,
          value: 'recovery.access',
        );
        await mockStorage.write(
          key: StorageKeys.recoveryAccessTokenScope,
          value: 'pin_reset',
        );

        final adapter = _RecordingStatusAdapter(statusCode: 401);
        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = adapter
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await expectLater(
          dio.post('/kyc/liveness/session'),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              401,
            ),
          ),
        );

        expect(
          mockStorage.storage[StorageKeys.recoveryAccessToken],
          'recovery.access',
        );
        expect(container.read(sessionServiceProvider).isLocked, isTrue);
        expect(container.read(authSessionInvalidatedProvider), equals(0));
      },
    );

    test(
      'checks mobile version policy after upgrade-required responses',
      () async {
        final container = ProviderContainer(
          overrides: [
            secureStorageProvider.overrideWithValue(mockStorage),
            mobileVersionPolicyProvider.overrideWith(
              _RecordingVersionPolicyController.new,
            ),
          ],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'valid.access',
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = const _UpgradeRequiredAdapter()
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await expectLater(
          dio.get('/wallet'),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              426,
            ),
          ),
        );
        await pumpEventQueue(times: 5);

        expect(_RecordingVersionPolicyController.reasons, contains('http_426'));
      },
    );

    test(
      'clears local session and emits invalidation when device is blacklisted',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'blocked.access',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'blocked.refresh',
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = _DeviceBlacklistedAdapter()
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await expectLater(
          dio.get('/wallet'),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              403,
            ),
          ),
        );

        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
        expect(container.read(authSessionInvalidatedProvider), equals(1));
      },
    );

    test(
      'clears local session for nested device blacklist API envelopes',
      () async {
        final container = ProviderContainer(
          overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
        );
        addTearDown(container.dispose);

        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'blocked.access',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'blocked.refresh',
        );

        final dio = Dio(BaseOptions(baseUrl: 'https://api.test/api/v1'))
          ..httpClientAdapter = const _DeviceBlacklistedAdapter(
            nestedEnvelope: true,
          )
          ..interceptors.add(container.read(_authInterceptorTestProvider));

        await expectLater(
          dio.get('/wallet'),
          throwsA(
            isA<DioException>().having(
              (error) => error.response?.statusCode,
              'statusCode',
              403,
            ),
          ),
        );

        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
        expect(container.read(authSessionInvalidatedProvider), equals(1));
      },
    );
  });

  group('ApiException mapping from status codes', () {
    test('should map 400 to Invalid request', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(400));
      expect(exception.message, equals('Invalid request'));
    });

    test('should map 401 to Unauthorized', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(401));
      expect(exception.message, equals('Unauthorized'));
    });

    test('should map 403 to Access denied', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(403));
      expect(exception.message, equals('Access denied'));
    });

    test('should map device blacklist errors to blocked-device message', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/wallet'),
        response: Response(
          statusCode: 403,
          data: {
            'statusCode': 403,
            'message': 'Access denied. This device has been blocked.',
            'error': 'DEVICE_BLACKLISTED',
          },
          requestOptions: RequestOptions(path: '/wallet'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(403));
      expect(exception.code, equals('DEVICE_BLACKLISTED'));
      expect(exception.isDeviceBlacklisted, isTrue);
      expect(
        exception.message,
        equals('This device has been blocked. Contact Korido support.'),
      );
    });

    test(
      'should map nested device blacklist envelopes to blocked-device code',
      () {
        // Arrange
        final dioError = DioException(
          requestOptions: RequestOptions(path: '/wallet'),
          response: Response(
            statusCode: 403,
            data: {
              'success': false,
              'error': {
                'code': 'DEVICE_BLACKLISTED',
                'message': 'Access denied. This device has been blocked.',
              },
            },
            requestOptions: RequestOptions(path: '/wallet'),
          ),
          type: DioExceptionType.badResponse,
        );

        // Act
        final exception = ApiException.fromDioError(dioError);

        // Assert
        expect(exception.statusCode, equals(403));
        expect(exception.code, equals('DEVICE_BLACKLISTED'));
        expect(exception.isDeviceBlacklisted, isTrue);
        expect(
          exception.message,
          equals('This device has been blocked. Contact Korido support.'),
        );
      },
    );

    test('should map 404 to Not found', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Not found'));
    });

    test('should map 422 to Validation failed', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 422,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(422));
      expect(exception.message, equals('Validation failed'));
    });

    test('should map 500 to Server error', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(500));
      expect(exception.message, equals('Server error'));
    });

    test('should map Cloudflare origin failures to service unavailable', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 521,
          data: 'error code: 521',
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(521));
      expect(
        exception.message,
        equals(
          'Korido is temporarily unavailable. Please try again in a few minutes.',
        ),
      );
    });

    test('should map rate limits to a retry later message', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 429,
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.statusCode, equals(429));
      expect(
        exception.message,
        equals('Too many attempts. Please wait a few minutes and try again.'),
      );
    });

    test('should extract message from response body', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          data: {'message': 'Custom error message'},
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Custom error message'));
    });

    test('should hide framework route-miss messages from users', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        response: Response(
          statusCode: 404,
          data: {
            'success': false,
            'error': {
              'code': 'NOT_FOUND',
              'message': 'Cannot POST /api/v1/auth/recovery/request-otp',
            },
          },
          requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioError(dioError);

      expect(exception.statusCode, equals(404));
      expect(exception.message, equals('Not found'));
      expect(exception.message, isNot(contains('Cannot POST')));
    });

    test('should preserve business 404 messages', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        response: Response(
          statusCode: 404,
          data: {
            'success': false,
            'error': {
              'code': 'NOT_FOUND',
              'message': 'User not found. Please register first.',
            },
          },
          requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioError(dioError);

      expect(
        exception.message,
        equals('User not found. Please register first.'),
      );
    });

    test('should handle connection timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle send timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.sendTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle receive timeout', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('Connection timed out'));
    });

    test('should handle connection error', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('No internet connection'));
    });

    test('should handle unknown errors', () {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.message, equals('An unexpected error occurred'));
    });
  });

  group('ApiException', () {
    test('toString should return message', () {
      // Arrange
      final exception = ApiException(message: 'Test error', statusCode: 400);

      // Act
      final result = exception.toString();

      // Assert
      expect(result, equals('Test error'));
    });

    test('should store data from response', () {
      // Arrange
      final responseData = {'field': 'error', 'details': 'Invalid value'};
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          statusCode: 400,
          data: {'message': 'Validation error', ...responseData},
          requestOptions: RequestOptions(path: '/test'),
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      final exception = ApiException.fromDioError(dioError);

      // Assert
      expect(exception.data, isNotNull);
    });

    test('should expose retry metadata from rate-limit envelopes', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        response: Response(
          statusCode: 429,
          data: {
            'success': false,
            'error': {
              'code': 'E9001',
              'message': 'Too many verification requests',
              'context': {'retryAfterSeconds': 120, 'resendAvailableIn': 120},
            },
          },
          requestOptions: RequestOptions(path: '/auth/recovery/request-otp'),
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioError(dioError);

      expect(exception.statusCode, 429);
      expect(exception.retryAfterSeconds, 120);
      expect(exception.resendAvailableIn, 120);
    });

    test('should expose retry metadata from rate-limit headers', () {
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          statusCode: 429,
          data: {'message': 'Too many requests'},
          headers: Headers.fromMap({
            'retry-after': ['45'],
          }),
          requestOptions: RequestOptions(path: '/auth/login'),
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioError(dioError);

      expect(exception.statusCode, 429);
      expect(exception.retryAfterSeconds, 45);
      expect(exception.resendAvailableIn, 45);
    });

    test('should treat X-RateLimit-Reset epoch seconds as cooldown', () {
      final resetAtEpochSeconds =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 + 75;
      final dioError = DioException(
        requestOptions: RequestOptions(path: '/kyc/liveness/session'),
        response: Response(
          statusCode: 429,
          data: {'message': 'Too many liveness checks'},
          headers: Headers.fromMap({
            'x-ratelimit-reset': ['$resetAtEpochSeconds'],
          }),
          requestOptions: RequestOptions(path: '/kyc/liveness/session'),
        ),
        type: DioExceptionType.badResponse,
      );

      final exception = ApiException.fromDioError(dioError);

      expect(exception.statusCode, 429);
      expect(exception.retryAfterSeconds, inInclusiveRange(70, 75));
      expect(exception.resendAvailableIn, inInclusiveRange(70, 75));
    });

    test('should create exception with message only', () {
      // Arrange & Act
      final exception = ApiException(message: 'Simple error');

      // Assert
      expect(exception.message, equals('Simple error'));
      expect(exception.statusCode, isNull);
      expect(exception.data, isNull);
    });

    test('should create exception with all fields', () {
      // Arrange & Act
      final exception = ApiException(
        message: 'Full error',
        statusCode: 500,
        data: {'extra': 'info'},
      );

      // Assert
      expect(exception.message, equals('Full error'));
      expect(exception.statusCode, equals(500));
      expect(exception.data, equals({'extra': 'info'}));
    });
  });

  group('Storage Keys', () {
    test('should have correct key values', () {
      expect(StorageKeys.accessToken, equals('access_token'));
      expect(StorageKeys.refreshToken, equals('refresh_token'));
      expect(StorageKeys.recoveryAccessToken, equals('recovery_access_token'));
      expect(StorageKeys.userPin, equals('user_pin'));
      expect(StorageKeys.biometricEnabled, equals('biometric_enabled'));
    });
  });

  group('MockSecureStorage', () {
    test('should store and retrieve values', () async {
      // Act
      await mockStorage.write(key: 'test_key', value: 'test_value');
      final result = await mockStorage.read(key: 'test_key');

      // Assert
      expect(result, equals('test_value'));
    });

    test('should return null for non-existent keys', () async {
      // Act
      final result = await mockStorage.read(key: 'non_existent');

      // Assert
      expect(result, isNull);
    });

    test('should delete values', () async {
      // Arrange
      await mockStorage.write(key: 'to_delete', value: 'value');

      // Act
      await mockStorage.delete(key: 'to_delete');
      final result = await mockStorage.read(key: 'to_delete');

      // Assert
      expect(result, isNull);
    });

    test('should clear all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      mockStorage.clear();
      final result1 = await mockStorage.read(key: 'key1');
      final result2 = await mockStorage.read(key: 'key2');

      // Assert
      expect(result1, isNull);
      expect(result2, isNull);
    });

    test('should check if key exists', () async {
      // Arrange
      await mockStorage.write(key: 'existing', value: 'value');

      // Act
      final exists = await mockStorage.containsKey(key: 'existing');
      final notExists = await mockStorage.containsKey(key: 'not_existing');

      // Assert
      expect(exists, isTrue);
      expect(notExists, isFalse);
    });

    test('should read all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      final all = await mockStorage.readAll();

      // Assert
      expect(all['key1'], equals('value1'));
      expect(all['key2'], equals('value2'));
    });

    test('should delete all values', () async {
      // Arrange
      await mockStorage.write(key: 'key1', value: 'value1');
      await mockStorage.write(key: 'key2', value: 'value2');

      // Act
      await mockStorage.deleteAll();
      final all = await mockStorage.readAll();

      // Assert
      expect(all, isEmpty);
    });

    test('should handle null value as delete', () async {
      // Arrange
      await mockStorage.write(key: 'key', value: 'value');

      // Act
      await mockStorage.write(key: 'key', value: null);
      final result = await mockStorage.read(key: 'key');

      // Assert
      expect(result, isNull);
    });
  });
}
