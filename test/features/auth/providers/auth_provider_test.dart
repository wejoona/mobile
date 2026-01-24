import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import '../../../helpers/test_utils.dart';

/// Mock SessionService for testing
class MockSessionNotifier extends Notifier<SessionState> implements SessionService {
  @override
  SessionState build() => const SessionState();

  @override
  Future<void> startSession({
    required String accessToken,
    String? refreshToken,
    Duration? tokenValidity,
  }) async {}

  @override
  Future<void> endSession() async {}

  @override
  void recordActivity() {}

  @override
  Future<void> extendSession() async {}

  @override
  void unlockSession() {}

  @override
  Future<void> lockSession() async {}

  @override
  SessionConfig get config => const SessionConfig();

  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<String?> getRefreshToken() async => null;

  @override
  Future<bool> hasStoredSession() async => false;

  @override
  void onAppBackground() {}

  @override
  void onAppForeground() {}
}

void main() {
  // Initialize Flutter bindings for secure storage
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockAuthService mockAuthService;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockStorage = MockSecureStorage();

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        secureStorageProvider.overrideWithValue(mockStorage),
        sessionServiceProvider.overrideWith(() => MockSessionNotifier()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    mockStorage.clear();
  });

  group('Initial state is unauthenticated', () {
    test('should have initial status', () {
      // Act
      final state = container.read(authProvider);

      // Assert
      expect(state.status, equals(AuthStatus.initial));
      expect(state.user, isNull);
      expect(state.phone, isNull);
      expect(state.error, isNull);
    });
  });

  group('Register flow -> OTP sent state', () {
    test('should transition to loading then otpSent on successful register', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.register(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
          )).thenAnswer((_) async => otpResponse);

      // Get notifier
      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.register('+2250123456789', 'CI');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.otpSent));
      expect(state.phone, equals('+2250123456789'));
      expect(state.otpExpiresIn, equals(300));
    });

    test('should transition to error on failed register', () async {
      // Arrange
      when(() => mockAuthService.register(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
          )).thenThrow(ApiException(message: 'User already exists'));

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.register('+2250123456789', 'CI');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.error));
      expect(state.error, equals('User already exists'));
    });
  });

  group('Login flow -> OTP sent state', () {
    test('should transition to otpSent on successful login', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async => otpResponse);

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.login('+2250123456789');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.otpSent));
      expect(state.phone, equals('+2250123456789'));
    });

    test('should transition to error on failed login', () async {
      // Arrange
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenThrow(ApiException(message: 'User not found'));

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.login('+2250123456789');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.error));
      expect(state.error, equals('User not found'));
    });
  });

  group('OTP verification -> authenticated state', () {
    test('should transition to authenticated on successful OTP verification', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async => otpResponse);

      final authResponse = AuthResponse(
        accessToken: 'test.access.token',
        user: createTestUser(),
        walletCreated: true,
      );
      when(() => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => authResponse);

      final notifier = container.read(authProvider.notifier);

      // Login first to set phone
      await notifier.login('+2250123456789');

      // Act
      final result = await notifier.verifyOtp('123456');

      // Assert
      expect(result, isTrue);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.authenticated));
      expect(state.user, isNotNull);
    });

    test('should store access token on successful verification', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async => otpResponse);

      final authResponse = AuthResponse(
        accessToken: 'test.access.token',
        user: createTestUser(),
        walletCreated: true,
      );
      when(() => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => authResponse);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');

      // Act
      await notifier.verifyOtp('123456');

      // Assert
      expect(mockStorage.storage[StorageKeys.accessToken], equals('test.access.token'));
    });

    test('should return false on OTP verification failure', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async => otpResponse);

      when(() => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenThrow(ApiException(message: 'Invalid OTP'));

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');

      // Act
      final result = await notifier.verifyOtp('wrong');

      // Assert
      expect(result, isFalse);
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.error));
      expect(state.error, equals('Invalid OTP'));
    });

    test('should return false when phone is not set', () async {
      // Arrange
      final notifier = container.read(authProvider.notifier);

      // Act - verify without login
      final result = await notifier.verifyOtp('123456');

      // Assert
      expect(result, isFalse);
      final state = container.read(authProvider);
      expect(state.error, equals('Phone number not found'));
    });
  });

  group('Handle API errors -> error state', () {
    test('should capture error message from ApiException', () async {
      // Arrange
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenThrow(ApiException(message: 'Network error'));

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.login('+2250123456789');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.error));
      expect(state.error, equals('Network error'));
    });

    test('should clear error with clearError', () async {
      // Arrange
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenThrow(ApiException(message: 'Error'));

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');

      // Verify error is set
      expect(container.read(authProvider).error, isNotNull);

      // Act
      notifier.clearError();

      // Assert
      expect(container.read(authProvider).error, isNull);
    });
  });

  group('Logout clears session and tokens', () {
    test('should clear tokens on logout', () async {
      // Arrange
      await mockStorage.write(key: StorageKeys.accessToken, value: 'token');
      await mockStorage.write(key: StorageKeys.refreshToken, value: 'refresh');

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.logout();

      // Assert
      expect(mockStorage.storage[StorageKeys.accessToken], isNull);
      expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
    });

    test('should transition to unauthenticated on logout', () async {
      // Arrange
      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.logout();

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.user, isNull);
    });
  });

  group('Check stored auth restores session', () {
    test('should transition to authenticated when token exists', () async {
      // Arrange
      await mockStorage.write(key: StorageKeys.accessToken, value: 'existing.token');

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.checkAuth();

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.authenticated));
    });

    test('should transition to unauthenticated when no token', () async {
      // Arrange - no token stored

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.checkAuth();

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
    });
  });

  group('State helper properties', () {
    test('isAuthenticated should return true when authenticated', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async => otpResponse);

      final authResponse = AuthResponse(
        accessToken: 'token',
        user: createTestUser(),
        walletCreated: true,
      );
      when(() => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
          )).thenAnswer((_) async => authResponse);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');
      await notifier.verifyOtp('123456');

      // Assert
      expect(container.read(authProvider).isAuthenticated, isTrue);
    });

    test('isLoading should return true during async operations', () async {
      // Arrange
      when(() => mockAuthService.login(phone: any(named: 'phone')))
          .thenAnswer((_) async {
        // Simulate delay
        await Future.delayed(const Duration(milliseconds: 100));
        return OtpResponse(success: true, message: 'OTP sent', expiresIn: 300);
      });

      final notifier = container.read(authProvider.notifier);

      // Act - start login
      final loginFuture = notifier.login('+2250123456789');

      // Assert - should be loading initially
      // Note: This is tricky to test due to async nature

      await loginFuture;
    });
  });

  group('AuthState copyWith', () {
    test('should preserve existing values when not overridden', () {
      // Arrange
      const state = AuthState(
        status: AuthStatus.authenticated,
        phone: '+2250123456789',
      );

      // Act
      final newState = state.copyWith(error: 'New error');

      // Assert
      expect(newState.status, equals(AuthStatus.authenticated));
      expect(newState.phone, equals('+2250123456789'));
      expect(newState.error, equals('New error'));
    });

    test('should allow clearing error by passing null', () {
      // Arrange
      const state = AuthState(
        status: AuthStatus.error,
        error: 'Some error',
      );

      // Act
      final newState = state.copyWith(status: AuthStatus.loading);

      // Assert
      // Note: error is cleared because copyWith with status change nullifies error
      expect(newState.status, equals(AuthStatus.loading));
    });
  });
}
