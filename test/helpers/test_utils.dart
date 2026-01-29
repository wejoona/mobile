/// Test utilities for Flutter unit tests
///
/// Provides mock factories, test helpers, and fake implementations
/// for secure storage, HTTP clients, and domain entities.

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mocktail/mocktail.dart';

import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/domain/entities/wallet.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';

// ============================================
// MOCK SECURE STORAGE
// ============================================

/// Mock implementation of FlutterSecureStorage for testing
class MockSecureStorage extends Mock implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  /// Clear all stored values (for test cleanup)
  void clear() {
    _storage.clear();
  }

  /// Get current storage state (for assertions)
  Map<String, String> get storage => Map.unmodifiable(_storage);

  // Override read to use in-memory storage
  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  // Override write to use in-memory storage
  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  // Override delete to use in-memory storage
  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  // Override deleteAll to use in-memory storage
  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }

  // Override readAll to use in-memory storage
  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return Map.from(_storage);
  }

  // Override containsKey to use in-memory storage
  @override
  Future<bool> containsKey({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage.containsKey(key);
  }
}

// ============================================
// MOCK DIO WITH RESPONSE QUEUE
// ============================================

/// Mock Dio client that queues responses for testing
class MockDio extends Mock implements Dio {
  final List<dynamic> _responseQueue = [];
  final List<RequestOptions> _requestHistory = [];

  MockDio() {
    // Initialize interceptors
    when(() => interceptors).thenReturn(Interceptors());
  }

  /// Queue a successful response
  void queueResponse(dynamic data, {int statusCode = 200}) {
    _responseQueue.add(Response<dynamic>(
      data: data,
      statusCode: statusCode,
      requestOptions: RequestOptions(path: ''),
    ));
  }

  /// Queue an error response
  void queueError(DioException error) {
    _responseQueue.add(error);
  }

  /// Queue a DioException with custom message
  void queueErrorResponse({
    required int statusCode,
    String? message,
    dynamic data,
  }) {
    _responseQueue.add(DioException(
      requestOptions: RequestOptions(path: ''),
      response: Response<dynamic>(
        data: data ?? {'message': message ?? 'Error'},
        statusCode: statusCode,
        requestOptions: RequestOptions(path: ''),
      ),
      type: DioExceptionType.badResponse,
    ));
  }

  /// Get request history for assertions
  List<RequestOptions> get requestHistory => List.unmodifiable(_requestHistory);

  /// Clear response queue and history
  void reset() {
    _responseQueue.clear();
    _requestHistory.clear();
  }

  dynamic _getNextResponse() {
    if (_responseQueue.isEmpty) {
      throw StateError('No responses queued. Add responses with queueResponse()');
    }
    return _responseQueue.removeAt(0);
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    _requestHistory.add(RequestOptions(
      path: path,
      method: 'GET',
      queryParameters: queryParameters,
    ));

    final response = _getNextResponse();
    if (response is DioException) throw response;
    return response as Response<T>;
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _requestHistory.add(RequestOptions(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
    ));

    final response = _getNextResponse();
    if (response is DioException) throw response;
    return response as Response<T>;
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    _requestHistory.add(RequestOptions(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
    ));

    final response = _getNextResponse();
    if (response is DioException) throw response;
    return response as Response<T>;
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    _requestHistory.add(RequestOptions(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
    ));

    final response = _getNextResponse();
    if (response is DioException) throw response;
    return response as Response<T>;
  }

  @override
  Future<Response<T>> fetch<T>(RequestOptions requestOptions) async {
    _requestHistory.add(requestOptions);

    final response = _getNextResponse();
    if (response is DioException) throw response;
    return response as Response<T>;
  }
}

// ============================================
// MOCK LOCAL AUTHENTICATION
// ============================================

/// Mock LocalAuthentication for biometric testing
class MockLocalAuthentication extends Mock implements LocalAuthentication {}

// ============================================
// MOCK AUTH SERVICE
// ============================================

/// Mock AuthService for auth provider testing
class MockAuthService extends Mock implements AuthService {}

// ============================================
// FAKE SESSION SERVICE
// ============================================

/// Fake SessionService for testing session management with timers
class FakeSessionService {
  Timer? _sessionTimer;
  Timer? _warningTimer;
  bool _isSessionActive = false;
  DateTime? _sessionExpiry;

  final StreamController<SessionEvent> _eventController =
      StreamController<SessionEvent>.broadcast();

  Stream<SessionEvent> get events => _eventController.stream;
  bool get isSessionActive => _isSessionActive;
  DateTime? get sessionExpiry => _sessionExpiry;

  void startSession({
    required String accessToken,
    required Duration tokenValidity,
  }) {
    _isSessionActive = true;
    _sessionExpiry = DateTime.now().add(tokenValidity);

    // Cancel existing timers
    _sessionTimer?.cancel();
    _warningTimer?.cancel();

    // Set up warning timer (1 minute before expiry)
    final warningDuration = tokenValidity - const Duration(minutes: 1);
    if (warningDuration.isNegative == false) {
      _warningTimer = Timer(warningDuration, () {
        _eventController.add(SessionEvent.warning);
      });
    }

    // Set up expiry timer
    _sessionTimer = Timer(tokenValidity, () {
      _isSessionActive = false;
      _eventController.add(SessionEvent.expired);
    });
  }

  void endSession() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _isSessionActive = false;
    _sessionExpiry = null;
    _eventController.add(SessionEvent.ended);
  }

  void refreshSession(Duration additionalTime) {
    if (_sessionExpiry != null) {
      _sessionExpiry = _sessionExpiry!.add(additionalTime);
      _eventController.add(SessionEvent.refreshed);
    }
  }

  void dispose() {
    _sessionTimer?.cancel();
    _warningTimer?.cancel();
    _eventController.close();
  }
}

enum SessionEvent {
  warning,
  expired,
  ended,
  refreshed,
}

// ============================================
// TEST ENTITY FACTORIES
// ============================================

/// Create a test User entity with default values
User createTestUser({
  String? id,
  String? phone,
  String? username,
  String? firstName,
  String? lastName,
  String? email,
  String? countryCode,
  bool? isPhoneVerified,
  UserRole? role,
  UserStatus? status,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return User(
    id: id ?? 'test-user-id',
    phone: phone ?? '+2250123456789',
    username: username,
    firstName: firstName ?? 'Test',
    lastName: lastName ?? 'User',
    email: email,
    countryCode: countryCode ?? 'CI',
    isPhoneVerified: isPhoneVerified ?? true,
    role: role ?? UserRole.user,
    status: status ?? UserStatus.active,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

/// Create a test Wallet entity with default values
Wallet createTestWallet({
  String? id,
  String? userId,
  String? circleWalletId,
  String? walletAddress,
  String? blockchain,
  KycStatus? kycStatus,
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Wallet(
    id: id ?? 'test-wallet-id',
    userId: userId ?? 'test-user-id',
    circleWalletId: circleWalletId,
    walletAddress: walletAddress ?? '0x${'a' * 40}',
    blockchain: blockchain ?? 'MATIC',
    kycStatus: kycStatus ?? KycStatus.verified,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

// ============================================
// TEST DATA
// ============================================

/// Common test data for authentication flows
class TestAuthData {
  static const validPhone = '+2250123456789';
  static const validOtp = '123456';
  static const validAccessToken = 'test.access.token';
  static const validRefreshToken = 'test.refresh.token';
  static const validPin = '1234';

  static Map<String, dynamic> get authResponseJson => {
    'accessToken': validAccessToken,
    'refreshToken': validRefreshToken,
    'user': testUserJson,
    'walletCreated': true,
  };

  static Map<String, dynamic> get testUserJson => {
    'id': 'test-user-id',
    'phone': validPhone,
    'username': null,
    'firstName': 'Test',
    'lastName': 'User',
    'email': null,
    'countryCode': 'CI',
    'phoneVerified': true,
    'role': 'user',
    'status': 'active',
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> get otpResponseJson => {
    'success': true,
    'message': 'OTP sent successfully',
    'expiresIn': 300,
  };
}

/// Common test data for wallet operations
class TestWalletData {
  static Map<String, dynamic> get testWalletJson => {
    'id': 'test-wallet-id',
    'userId': 'test-user-id',
    'circleWalletId': 'circle-wallet-id',
    'walletAddress': '0x${'a' * 40}',
    'blockchain': 'MATIC',
    'kycStatus': 'verified',
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  static Map<String, dynamic> get pinVerificationResponseJson => {
    'valid': true,
    'message': 'PIN verified successfully',
    'pinToken': 'a' * 64,
    'expiresIn': 300,
  };
}

// ============================================
// REGISTER FALLBACK VALUES
// ============================================

/// Register fallback values for mocktail
/// Call this in setUpAll() before using mocks
void registerFallbackValues() {
  registerFallbackValue(RequestOptions(path: ''));
  registerFallbackValue(Options());
  registerFallbackValue(CancelToken());
  // local_auth fallback values
  registerFallbackValue(const AuthenticationOptions());
}
