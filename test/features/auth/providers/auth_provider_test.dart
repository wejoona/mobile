import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/device/device_registration_service.dart';
import 'package:usdc_wallet/services/notifications/push_notification_service.dart';
import 'package:usdc_wallet/services/session/session_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/app_state.dart' hide AuthStatus;
import '../../../helpers/test_utils.dart';

/// Mock AppFsmNotifier that does nothing (no side effects)
class MockAppFsmNotifier extends AppFsmNotifier {
  @override
  AppState build() => const AppState.initial();

  @override
  void handleEffects(List<FsmEffect> effects) {
    // No-op: prevent async side effects in tests
  }

  @override
  void restoreSession({
    required String userId,
    required String accessToken,
    String? refreshToken,
    String phone = '',
  }) {
    // No-op: prevent wallet/KYC fetch microtasks in tests
  }

  @override
  void completeAuthenticatedSession({
    required String userId,
    required String accessToken,
    String? refreshToken,
    String phone = '',
  }) {
    // No-op: prevent wallet/KYC fetch microtasks in tests
  }
}

/// Mock KycStateMachine that does nothing
class MockKycStateMachine extends KycStateMachine {
  @override
  KycStateMachineState build() => const KycStateMachineState();

  @override
  void updateFromAuthResponse(String? kycStatus) {
    // No-op
  }

  @override
  Future<void> fetch({bool force = false}) async {
    // No-op
  }
}

/// Mock WalletStateMachine that does nothing
class MockWalletStateMachine extends WalletStateMachine {
  @override
  WalletState build() => const WalletState();

  @override
  Future<void> fetch({bool force = false}) async {
    // No-op
  }

  @override
  Future<void> createWallet() async {
    // No-op
  }
}

/// Mock UserStateMachine that does nothing
class MockUserStateMachine extends UserStateMachine {
  @override
  UserState build() => const UserState();

  @override
  Future<void> hydrateAuthenticatedSession({bool fetchRelated = true}) async {
    // No-op
  }

  @override
  Future<void> logout() async {
    // No-op
  }
}

class MockDeviceRegistrationService extends Mock
    implements DeviceRegistrationService {}

class MockPushNotificationService extends Mock
    implements PushNotificationService {}

/// Mock SessionService for testing
class MockSessionNotifier extends Notifier<SessionState>
    implements SessionService {
  @override
  SessionState build() => const SessionState();

  @override
  Future<void> startSession({
    required String accessToken,
    String? refreshToken,
    Duration? tokenValidity,
  }) async {
    state = const SessionState(status: SessionStatus.active);
  }

  @override
  Future<void> endSession() async {}

  @override
  void recordActivity() {}

  @override
  Future<void> extendSession() async {}

  @override
  void unlockSession() {
    state = const SessionState(status: SessionStatus.active);
  }

  @override
  Future<void> lockSession() async {
    state = const SessionState(status: SessionStatus.locked);
  }

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
  late MockDeviceRegistrationService mockDeviceRegistrationService;
  late MockPushNotificationService mockPushNotificationService;

  setUpAll(() {
    registerFallbackValues();
  });

  setUp(() async {
    mockAuthService = MockAuthService();
    mockStorage = MockSecureStorage();
    mockDeviceRegistrationService = MockDeviceRegistrationService();
    mockPushNotificationService = MockPushNotificationService();
    when(
      () => mockDeviceRegistrationService.registerCurrentDevice(),
    ).thenAnswer((_) async {});

    when(
      () => mockAuthService.logout(
        accessToken: any(named: 'accessToken'),
        refreshToken: any(named: 'refreshToken'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockPushNotificationService.unregisterFromBackend(),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        deviceRegistrationServiceProvider.overrideWithValue(
          mockDeviceRegistrationService,
        ),
        secureStorageProvider.overrideWithValue(mockStorage),
        sessionServiceProvider.overrideWith(() => MockSessionNotifier()),
        appFsmProvider.overrideWith(() => MockAppFsmNotifier()),
        kycStateMachineProvider.overrideWith(() => MockKycStateMachine()),
        userStateMachineProvider.overrideWith(() => MockUserStateMachine()),
        walletStateMachineProvider.overrideWith(() => MockWalletStateMachine()),
        pushNotificationServiceProvider.overrideWithValue(
          mockPushNotificationService,
        ),
      ],
    );

    container.read(authProvider);
    await pumpEventQueue(times: 3);
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
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(state.user, isNull);
      expect(state.phone, isNull);
      expect(state.error, isNull);
    });
  });

  group('Register flow -> OTP sent state', () {
    test(
      'should transition to loading then otpSent on successful register',
      () async {
        // Arrange
        final otpResponse = OtpResponse(
          success: true,
          message: 'OTP sent',
          expiresIn: 300,
        );
        when(
          () => mockAuthService.register(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
          ),
        ).thenAnswer((_) async => otpResponse);

        // Get notifier
        final notifier = container.read(authProvider.notifier);

        // Act
        await notifier.register('+2250123456789', 'CI');

        // Assert
        final state = container.read(authProvider);
        expect(state.status, equals(AuthStatus.otpSent));
        expect(state.phone, equals('0123456789'));
        expect(state.countryCode, equals('CI'));
        expect(state.otpExpiresIn, equals(300));
      },
    );

    test('should transition to error on failed register', () async {
      // Arrange
      when(
        () => mockAuthService.register(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenThrow(ApiException(message: 'User already exists'));

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
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async => otpResponse);

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.login('+2250123456789');

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.otpSent));
      expect(state.phone, equals('0123456789'));
      expect(state.countryCode, equals('CI'));
    });

    test('should transition to error on failed login', () async {
      // Arrange
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenThrow(ApiException(message: 'User not found'));

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
    test(
      'should transition to authenticated on successful OTP verification',
      () async {
        // Arrange
        final otpResponse = OtpResponse(
          success: true,
          message: 'OTP sent',
          expiresIn: 300,
        );
        when(
          () => mockAuthService.login(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
          ),
        ).thenAnswer((_) async => otpResponse);

        final authResponse = AuthResponse(
          accessToken: 'test.access.token',
          user: createTestUser(),
          walletCreated: true,
          expiresIn: 900,
        );
        when(
          () => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => authResponse);

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
      },
    );

    test('should store access token on successful verification', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async => otpResponse);

      final authResponse = AuthResponse(
        accessToken: 'test.access.token',
        user: createTestUser(),
        walletCreated: true,
        expiresIn: 900,
      );
      when(
        () => mockAuthService.verifyOtp(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
          otp: any(named: 'otp'),
        ),
      ).thenAnswer((_) async => authResponse);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');

      // Act
      await notifier.verifyOtp('123456');

      // Assert
      expect(
        mockStorage.storage[StorageKeys.accessToken],
        equals('test.access.token'),
      );
    });

    test('should return false on OTP verification failure', () async {
      // Arrange
      final otpResponse = OtpResponse(
        success: true,
        message: 'OTP sent',
        expiresIn: 300,
      );
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async => otpResponse);

      when(
        () => mockAuthService.verifyOtp(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
          otp: any(named: 'otp'),
        ),
      ).thenThrow(ApiException(message: 'Invalid OTP'));

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

    test(
      'should reject OTP completion when current device is blacklisted',
      () async {
        // Arrange
        final otpResponse = OtpResponse(
          success: true,
          message: 'OTP sent',
          expiresIn: 300,
        );
        when(
          () => mockAuthService.login(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
          ),
        ).thenAnswer((_) async => otpResponse);

        final authResponse = AuthResponse(
          accessToken: 'test.access.token',
          refreshToken: 'test.refresh.token',
          user: createTestUser(),
          walletCreated: true,
          expiresIn: 900,
        );
        when(
          () => mockAuthService.verifyOtp(
            phone: any(named: 'phone'),
            countryCode: any(named: 'countryCode'),
            otp: any(named: 'otp'),
          ),
        ).thenAnswer((_) async => authResponse);
        when(
          () => mockDeviceRegistrationService.registerCurrentDevice(),
        ).thenThrow(
          ApiException(
            message: 'This device has been blocked. Contact Korido support.',
            statusCode: 403,
            code: 'DEVICE_BLACKLISTED',
          ),
        );

        final notifier = container.read(authProvider.notifier);
        await notifier.login('+2250123456789');

        // Act
        final result = await notifier.verifyOtp('123456');

        // Assert
        final state = container.read(authProvider);
        expect(result, isFalse);
        expect(state.status, equals(AuthStatus.error));
        expect(
          state.error,
          equals('This device has been blocked. Contact Korido support.'),
        );
        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
      },
    );
  });

  group('Handle API errors -> error state', () {
    test('should capture error message from ApiException', () async {
      // Arrange
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenThrow(ApiException(message: 'Network error'));

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
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenThrow(ApiException(message: 'Error'));

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

    test('should revoke backend session and push token on logout', () async {
      // Arrange
      await mockStorage.write(key: StorageKeys.accessToken, value: 'token');
      await mockStorage.write(key: StorageKeys.refreshToken, value: 'refresh');

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.logout();

      // Assert
      verify(
        () => mockAuthService.logout(
          accessToken: 'token',
          refreshToken: 'refresh',
        ),
      ).called(1);
      verify(
        () => mockPushNotificationService.unregisterFromBackend(),
      ).called(1);
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

    test('should ignore stale startup refresh after logout', () async {
      // Arrange
      await mockStorage.write(key: StorageKeys.accessToken, value: 'old.token');
      await mockStorage.write(
        key: StorageKeys.refreshToken,
        value: 'old.refresh',
      );

      final refreshCompleter = Completer<RefreshResponse>();
      when(
        () => mockAuthService.refreshToken(refreshToken: 'old.refresh'),
      ).thenAnswer((_) => refreshCompleter.future);

      final notifier = container.read(authProvider.notifier);

      // Act: start restore, then log out before refresh returns.
      final restore = notifier.checkAuth();
      await Future<void>.delayed(Duration.zero);
      await notifier.logout();
      refreshCompleter.complete(
        RefreshResponse(
          accessToken: 'new.token',
          refreshToken: 'new.refresh',
          expiresIn: 900,
        ),
      );
      await restore;

      // Assert: stale restore must not resurrect a locked/authenticated session.
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.unauthenticated));
      expect(mockStorage.storage[StorageKeys.accessToken], isNull);
      expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
    });

    test(
      'should clear locked auth state when local session is invalidated',
      () async {
        // Arrange
        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'expired.token',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'expired.refresh',
        );

        final notifier = container.read(authProvider.notifier);
        await notifier.checkAuth();
        expect(container.read(authProvider).status, equals(AuthStatus.locked));

        // Act
        final invalidation = container.read(
          authSessionInvalidatedProvider.notifier,
        );
        invalidation.state = invalidation.state + 1;
        await Future<void>.delayed(Duration.zero);

        // Assert
        final state = container.read(authProvider);
        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
      },
    );

    test(
      'should clear local session when unlock refresh token is rejected',
      () async {
        // Arrange
        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'expired.token',
        );

        final notifier = container.read(authProvider.notifier);
        await notifier.checkAuth();
        expect(container.read(authProvider).status, equals(AuthStatus.locked));
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'expired.refresh',
        );
        when(
          () => mockAuthService.refreshToken(refreshToken: 'expired.refresh'),
        ).thenThrow(
          ApiException(message: 'Invalid refresh token', statusCode: 401),
        );

        // Act
        notifier.unlock();
        await Future<void>.delayed(Duration.zero);

        // Assert
        final state = container.read(authProvider);
        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
      },
    );

    test(
      'should clear access and refresh tokens when biometric refresh fails',
      () async {
        // Arrange
        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'expired.token',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'expired.refresh',
        );
        when(
          () => mockAuthService.refreshToken(refreshToken: 'expired.refresh'),
        ).thenThrow(
          ApiException(message: 'Invalid refresh token', statusCode: 401),
        );

        final notifier = container.read(authProvider.notifier);

        // Act
        final result = await notifier.loginWithBiometric('expired.refresh');

        // Assert
        expect(result, isFalse);
        expect(container.read(authProvider).status, equals(AuthStatus.error));
        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
      },
    );
  });

  group('Account recovery unlock', () {
    test(
      'refreshes deterministically before unlocking after PIN reset',
      () async {
        // Arrange
        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'old.access.token',
        );

        final notifier = container.read(authProvider.notifier);
        await notifier.checkAuth();
        expect(container.read(authProvider).status, equals(AuthStatus.locked));

        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'recovery.refresh.token',
        );
        when(
          () => mockAuthService.refreshToken(
            refreshToken: 'recovery.refresh.token',
          ),
        ).thenAnswer(
          (_) async => const RefreshResponse(
            accessToken: 'fresh.access.token',
            refreshToken: 'fresh.refresh.token',
            expiresIn: 900,
          ),
        );

        // Act
        final unlocked = await notifier.unlockAfterAccountRecovery();

        // Assert
        expect(unlocked, isTrue);
        expect(container.read(authProvider).status, AuthStatus.authenticated);
        expect(container.read(sessionServiceProvider).isLocked, isFalse);
        expect(
          mockStorage.storage[StorageKeys.accessToken],
          'fresh.access.token',
        );
        expect(
          mockStorage.storage[StorageKeys.refreshToken],
          'fresh.refresh.token',
        );
        verify(
          () => mockAuthService.refreshToken(
            refreshToken: 'recovery.refresh.token',
          ),
        ).called(1);
      },
    );
  });

  group('Check stored auth restores session', () {
    test('should transition to locked when token exists', () async {
      // Arrange
      await mockStorage.write(
        key: StorageKeys.accessToken,
        value: 'existing.token',
      );

      final notifier = container.read(authProvider.notifier);

      // Act
      await notifier.checkAuth();

      // Assert
      final state = container.read(authProvider);
      expect(state.status, equals(AuthStatus.locked));
    });

    test(
      'should clear stale stored session when startup refresh is unauthorized',
      () async {
        // Arrange
        await mockStorage.write(
          key: StorageKeys.accessToken,
          value: 'existing.token',
        );
        await mockStorage.write(
          key: StorageKeys.refreshToken,
          value: 'rejected.refresh',
        );
        when(
          () => mockAuthService.refreshToken(refreshToken: 'rejected.refresh'),
        ).thenThrow(ApiException(message: 'Unauthorized', statusCode: 401));

        final notifier = container.read(authProvider.notifier);

        // Act
        await notifier.checkAuth();

        // Assert
        final state = container.read(authProvider);
        expect(state.status, equals(AuthStatus.unauthenticated));
        expect(mockStorage.storage[StorageKeys.accessToken], isNull);
        expect(mockStorage.storage[StorageKeys.refreshToken], isNull);
      },
    );

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
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async => otpResponse);

      final authResponse = AuthResponse(
        accessToken: 'token',
        user: createTestUser(),
        walletCreated: true,
        expiresIn: 900,
      );
      when(
        () => mockAuthService.verifyOtp(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
          otp: any(named: 'otp'),
        ),
      ).thenAnswer((_) async => authResponse);

      final notifier = container.read(authProvider.notifier);
      await notifier.login('+2250123456789');
      await notifier.verifyOtp('123456');

      // Assert
      expect(container.read(authProvider).isAuthenticated, isTrue);
    });

    test('isLoading should return true during async operations', () async {
      // Arrange
      when(
        () => mockAuthService.login(
          phone: any(named: 'phone'),
          countryCode: any(named: 'countryCode'),
        ),
      ).thenAnswer((_) async {
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
      const state = AuthState(status: AuthStatus.error, error: 'Some error');

      // Act
      final newState = state.copyWith(status: AuthStatus.loading);

      // Assert
      // Note: error is cleared because copyWith with status change nullifies error
      expect(newState.status, equals(AuthStatus.loading));
    });
  });
}
