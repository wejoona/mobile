import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';

void main() {
  late AuthFsm fsm;

  setUp(() {
    fsm = AuthFsm();
  });

  group('AuthFsm - Initial State', () {
    test('should have unauthenticated as initial state', () {
      expect(fsm.initialState, isA<AuthUnauthenticated>());
      expect(fsm.initialState.name, equals('UNAUTHENTICATED'));
    });
  });

  group('AuthFsm - Login Flow', () {
    test('should transition from unauthenticated to submitting on login', () {
      const state = AuthUnauthenticated();
      const event = AuthLogin(phone: '+22512345678', countryCode: 'CI');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
      expect((success.newState as AuthSubmitting).phone, equals('+22512345678'));
      expect(success.effects, isNotNull);
      expect(success.effects!.length, equals(1));
      expect(success.effects![0], isA<FetchEffect>());
    });

    test('should transition from submitting to otpSent on success', () {
      const state = AuthSubmitting(phone: '+22512345678');
      const event = AuthOtpReceived(expiresIn: 300);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthOtpSent>());
      final otpSent = success.newState as AuthOtpSent;
      expect(otpSent.phone, equals('+22512345678'));
      expect(otpSent.expiresIn, equals(300));
    });

    test('should transition from submitting to error on failure', () {
      const state = AuthSubmitting(phone: '+22512345678');
      const event = AuthFailed(message: 'Network error');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthError>());
      final error = success.newState as AuthError;
      expect(error.errorMessage, equals('Network error'));
      expect(error.previousState, isA<AuthUnauthenticated>());
    });
  });

  group('AuthFsm - OTP Expiry Transitions', () {
    test('should transition from otpSent to otpExpired on timeout', () {
      const state = AuthOtpSent(phone: '+22512345678', expiresIn: 300);
      const event = AuthOtpExpiredEvent();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthOtpExpired>());
      expect((success.newState as AuthOtpExpired).phone, equals('+22512345678'));
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should transition from otpExpired to submitting on retry', () {
      const state = AuthOtpExpired(phone: '+22512345678');
      const event = AuthResendOtp();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
      expect((success.newState as AuthSubmitting).phone, equals('+22512345678'));
    });

    test('should transition from otpExpired to submitting on new login', () {
      const state = AuthOtpExpired(phone: '+22512345678');
      const event = AuthLogin(phone: '+22587654321', countryCode: 'CI');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
      expect((success.newState as AuthSubmitting).phone, equals('+22587654321'));
    });
  });

  group('AuthFsm - OTP Verification', () {
    test('should transition from otpSent to verifying on verify', () {
      const state = AuthOtpSent(phone: '+22512345678');
      const event = AuthVerifyOtp(otp: '123456');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthVerifying>());
      expect((success.newState as AuthVerifying).phone, equals('+22512345678'));
    });

    test('should transition from verifying to authenticated on success', () {
      const state = AuthVerifying(phone: '+22512345678');
      const event = AuthVerified(
        userId: 'user123',
        accessToken: 'token123',
        refreshToken: 'refresh123',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthAuthenticated>());
      final authenticated = success.newState as AuthAuthenticated;
      expect(authenticated.userId, equals('user123'));
      expect(authenticated.phone, equals('+22512345678'));
      expect(authenticated.accessToken, equals('token123'));
      expect(authenticated.refreshToken, equals('refresh123'));
      expect(success.effects, isNotNull);
      expect(success.effects!.length, greaterThanOrEqualTo(2));
    });

    test('should transition from verifying to error on failure', () {
      const state = AuthVerifying(phone: '+22512345678');
      const event = AuthFailed(message: 'Invalid OTP');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthError>());
      final error = success.newState as AuthError;
      expect(error.errorMessage, equals('Invalid OTP'));
      expect(error.previousState, isA<AuthOtpSent>());
    });
  });

  group('AuthFsm - Token Refresh', () {
    test('should transition from authenticated to tokenRefreshing', () {
      const state = AuthAuthenticated(
        userId: 'user123',
        phone: '+22512345678',
        accessToken: 'old_token',
      );
      const event = AuthRefreshToken();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthTokenRefreshing>());
      final refreshing = success.newState as AuthTokenRefreshing;
      expect(refreshing.userId, equals('user123'));
      expect(refreshing.phone, equals('+22512345678'));
    });

    test('should transition from tokenRefreshing to authenticated on success', () {
      const state = AuthTokenRefreshing(
        userId: 'user123',
        phone: '+22512345678',
      );
      const event = AuthTokenRefreshed(
        accessToken: 'new_token',
        refreshToken: 'new_refresh',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthAuthenticated>());
      final authenticated = success.newState as AuthAuthenticated;
      expect(authenticated.accessToken, equals('new_token'));
      expect(authenticated.refreshToken, equals('new_refresh'));
    });

    test('should transition from tokenRefreshing to unauthenticated on failure', () {
      const state = AuthTokenRefreshing(
        userId: 'user123',
        phone: '+22512345678',
      );
      const event = AuthFailed(message: 'Refresh token expired');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthUnauthenticated>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is ClearEffect), isTrue);
      expect(success.effects!.any((e) => e is NavigateEffect), isTrue);
    });
  });

  group('AuthFsm - Account Locked', () {
    test('should transition from submitting to locked on too many attempts', () {
      const state = AuthSubmitting(phone: '+22512345678');
      const event = AuthAccountLocked(
        lockDuration: Duration(minutes: 15),
        reason: 'Too many failed attempts',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthLocked>());
      final locked = success.newState as AuthLocked;
      expect(locked.phone, equals('+22512345678'));
      expect(locked.lockDuration, equals(const Duration(minutes: 15)));
      expect(locked.reason, equals('Too many failed attempts'));
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should allow login from locked state after unlock time', () {
      final lockedAt = DateTime.now().subtract(const Duration(minutes: 16));
      final state = AuthLocked(
        phone: '+22512345678',
        lockedAt: lockedAt,
        lockDuration: const Duration(minutes: 15),
        reason: 'Too many attempts',
      );
      const event = AuthLogin(phone: '+22512345678', countryCode: 'CI');

      // Verify lock is expired
      expect(state.isUnlocked, isTrue);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
    });

    test('should not allow login from locked state before unlock time', () {
      final lockedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final state = AuthLocked(
        phone: '+22512345678',
        lockedAt: lockedAt,
        lockDuration: const Duration(minutes: 15),
        reason: 'Too many attempts',
      );
      const event = AuthLogin(phone: '+22512345678', countryCode: 'CI');

      // Verify lock is still active
      expect(state.isUnlocked, isFalse);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionNotApplicable<AuthState>>());
    });
  });

  group('AuthFsm - Account Suspended', () {
    test('should transition from submitting to suspended', () {
      const state = AuthSubmitting(phone: '+22512345678');
      final suspendedUntil = DateTime.now().add(const Duration(days: 30));
      final event = AuthAccountSuspended(
        reason: 'Suspicious activity detected',
        suspendedUntil: suspendedUntil,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSuspended>());
      final suspended = success.newState as AuthSuspended;
      expect(suspended.phone, equals('+22512345678'));
      expect(suspended.reason, equals('Suspicious activity detected'));
      expect(suspended.suspendedUntil, equals(suspendedUntil));
      expect(suspended.isPermanent, isFalse);
    });

    test('should transition from authenticated to suspended', () {
      const state = AuthAuthenticated(
        userId: 'user123',
        phone: '+22512345678',
        accessToken: 'token123',
      );
      const event = AuthAccountSuspended(
        reason: 'Policy violation',
        suspendedUntil: null,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSuspended>());
      final suspended = success.newState as AuthSuspended;
      expect(suspended.userId, equals('user123'));
      expect(suspended.isPermanent, isTrue);
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NavigateEffect), isTrue);
    });

    test('suspended state should be mostly terminal', () {
      final state = AuthSuspended(
        userId: 'user123',
        phone: '+22512345678',
        reason: 'Suspended',
        suspendedAt: DateTime.now(),
      );
      const event = AuthLogin(phone: '+22512345678', countryCode: 'CI');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionNotApplicable<AuthState>>());
    });
  });

  group('AuthFsm - OTP Resend', () {
    test('should transition from otpSent to submitting on resend', () {
      const state = AuthOtpSent(phone: '+22512345678');
      const event = AuthResendOtp();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
      expect((success.newState as AuthSubmitting).phone, equals('+22512345678'));
    });
  });

  group('AuthFsm - Error Handling', () {
    test('should transition from error to unauthenticated on clear', () {
      const state = AuthError(
        errorMessage: 'Something went wrong',
        previousState: AuthUnauthenticated(),
      );
      const event = AuthClearError();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthUnauthenticated>());
    });

    test('should allow retry from error state', () {
      const state = AuthError(
        errorMessage: 'Network error',
        previousState: AuthUnauthenticated(),
      );
      const event = AuthLogin(phone: '+22512345678', countryCode: 'CI');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthSubmitting>());
    });
  });

  group('AuthFsm - Global Events', () {
    test('should transition to unauthenticated on logout from any state', () {
      const state = AuthAuthenticated(
        userId: 'user123',
        phone: '+22512345678',
        accessToken: 'token123',
      );
      const event = AuthLogout();

      final result = fsm.handleGlobal(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthUnauthenticated>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is ClearEffect), isTrue);
      expect(success.effects!.any((e) => e is NavigateEffect), isTrue);
    });

    test('should handle logout from otpSent state', () {
      const state = AuthOtpSent(phone: '+22512345678');
      const event = AuthLogout();

      final result = fsm.handleGlobal(state, event);

      expect(result, isA<TransitionSuccess<AuthState>>());
      final success = result as TransitionSuccess<AuthState>;
      expect(success.newState, isA<AuthUnauthenticated>());
    });
  });

  group('AuthFsm - State Properties', () {
    test('submitting state should be transitioning', () {
      const state = AuthSubmitting(phone: '+22512345678');
      expect(state.isTransitioning, isTrue);
    });

    test('verifying state should be transitioning', () {
      const state = AuthVerifying(phone: '+22512345678');
      expect(state.isTransitioning, isTrue);
    });

    test('tokenRefreshing state should be transitioning', () {
      const state = AuthTokenRefreshing(userId: 'user123', phone: '+22512345678');
      expect(state.isTransitioning, isTrue);
    });

    test('authenticated state should not be transitioning', () {
      const state = AuthAuthenticated(
        userId: 'user123',
        phone: '+22512345678',
        accessToken: 'token123',
      );
      expect(state.isTransitioning, isFalse);
    });

    test('locked state should calculate remaining time correctly', () {
      final lockedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final state = AuthLocked(
        phone: '+22512345678',
        lockedAt: lockedAt,
        lockDuration: const Duration(minutes: 15),
        reason: 'Too many attempts',
      );

      final remaining = state.remainingTime;
      expect(remaining.inMinutes, closeTo(10, 1));
    });

    test('suspended state should detect permanent suspension', () {
      final state = AuthSuspended(
        userId: 'user123',
        phone: '+22512345678',
        reason: 'Permanent ban',
        suspendedAt: DateTime.now(),
        suspendedUntil: null,
      );

      expect(state.isPermanent, isTrue);
    });

    test('suspended state should detect temporary suspension', () {
      final suspendedUntil = DateTime.now().add(const Duration(days: 7));
      final state = AuthSuspended(
        userId: 'user123',
        phone: '+22512345678',
        reason: 'Temporary suspension',
        suspendedAt: DateTime.now(),
        suspendedUntil: suspendedUntil,
      );

      expect(state.isPermanent, isFalse);
    });
  });
}
