import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';

void main() {
  late SessionFsm fsm;

  setUp(() {
    fsm = SessionFsm();
  });

  group('SessionFsm - Initial State', () {
    test('should have none as initial state', () {
      expect(fsm.initialState, isA<SessionNone>());
      expect(fsm.initialState.name, equals('NONE'));
      expect(fsm.initialState.isActive, isFalse);
    });
  });

  group('SessionFsm - Start Session', () {
    test('should transition from none to active on start', () {
      const state = SessionNone();
      const event = SessionStart(
        timeout: Duration(minutes: 30),
        warningTime: Duration(seconds: 30),
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
      final active = success.newState as SessionActive;
      expect(active.timeout, equals(const Duration(minutes: 30)));
      expect(active.isActive, isTrue);
    });
  });

  group('SessionFsm - Activity Tracking', () {
    test('should update last activity on activity event', () {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
      final state = SessionActive(
        startedAt: startedAt,
        lastActivity: startedAt,
        timeout: const Duration(minutes: 30),
      );
      const event = SessionActivity();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
      final updated = success.newState as SessionActive;
      expect(updated.lastActivity.isAfter(state.lastActivity), isTrue);
    });

    test('should calculate remaining time correctly', () {
      final lastActivity = DateTime.now().subtract(const Duration(minutes: 20));
      final state = SessionActive(
        startedAt: DateTime.now().subtract(const Duration(minutes: 25)),
        lastActivity: lastActivity,
        timeout: const Duration(minutes: 30),
      );

      final remaining = state.remainingTime;
      expect(remaining.inMinutes, closeTo(10, 1));
    });
  });

  group('SessionFsm - Background Transitions', () {
    test('should transition from active to backgrounded', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionBackground();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionBackgrounded>());
      final backgrounded = success.newState as SessionBackgrounded;
      expect(backgrounded.timeout, equals(const Duration(minutes: 5)));
    });

    test('should transition from backgrounded to active on foreground', () {
      final state = SessionBackgrounded(
        startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        backgroundedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        timeout: const Duration(minutes: 5),
      );
      const event = SessionForeground();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
    });

    test('should transition from backgrounded to locked if timeout exceeded', () {
      final state = SessionBackgrounded(
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        backgroundedAt: DateTime.now().subtract(const Duration(minutes: 6)),
        timeout: const Duration(minutes: 5),
      );
      const event = SessionForeground();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionLocked>());
      final locked = success.newState as SessionLocked;
      expect(locked.reason, contains('background'));
    });

    test('backgrounded state should calculate remaining time', () {
      final backgroundedAt = DateTime.now().subtract(const Duration(minutes: 2));
      final state = SessionBackgrounded(
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        backgroundedAt: backgroundedAt,
        timeout: const Duration(minutes: 5),
      );

      final remaining = state.remainingTime;
      expect(remaining.inMinutes, closeTo(3, 1));
    });
  });

  group('SessionFsm - Timeout and Expiry', () {
    test('should transition from active to expiring on warning', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionTimeoutWarning(remainingSeconds: 30);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpiring>());
      final expiring = success.newState as SessionExpiring;
      expect(expiring.remainingSeconds, equals(30));
      expect(expiring.needsAttention, isTrue);
    });

    test('should transition from expiring to active on extend', () {
      final state = SessionExpiring(
        remainingSeconds: 15,
        expiresAt: DateTime.now().add(const Duration(seconds: 15)),
      );
      const event = SessionExtend();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
    });

    test('should transition from expiring to active on activity', () {
      final state = SessionExpiring(
        remainingSeconds: 15,
        expiresAt: DateTime.now().add(const Duration(seconds: 15)),
      );
      const event = SessionActivity();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
    });

    test('should transition from expiring to expired on timeout', () {
      final state = SessionExpiring(
        remainingSeconds: 0,
        expiresAt: DateTime.now(),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is ClearEffect), isTrue);
    });

    test('should transition from active to expired', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });

    test('expired state should be terminal', () {
      final state = SessionExpired(expiredAt: DateTime.now());
      expect(state.isTerminal, isTrue);
      expect(state.needsAttention, isTrue);

      const event = SessionActivity();
      final result = fsm.handle(state, event);
      expect(result, isA<TransitionNotApplicable<SessionState>>());
    });
  });

  group('SessionFsm - Lock and Unlock', () {
    test('should transition from active to locked', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionLock(reason: 'Manual lock');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionLocked>());
      final locked = success.newState as SessionLocked;
      expect(locked.reason, equals('Manual lock'));
      expect(locked.needsAttention, isTrue);
    });

    test('should transition from locked to active on unlock', () {
      final state = SessionLocked(
        lockedAt: DateTime.now(),
        reason: 'Was locked',
      );
      const event = SessionUnlock();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
    });

    test('should transition from locked to expired', () {
      final state = SessionLocked(
        lockedAt: DateTime.now(),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });
  });

  group('SessionFsm - Biometric Authentication', () {
    test('should transition from active to biometric prompt', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionRequestBiometric(reason: 'Sensitive operation');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionBiometricPrompt>());
      final prompt = success.newState as SessionBiometricPrompt;
      expect(prompt.reason, equals('Sensitive operation'));
      expect(prompt.needsAttention, isTrue);
    });

    test('should transition from biometric prompt to active on success', () {
      final state = SessionBiometricPrompt(
        promptedAt: DateTime.now(),
        reason: 'Verification',
      );
      const event = SessionBiometricSuccess();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
    });

    test('should transition from biometric prompt to locked on failure', () {
      final state = SessionBiometricPrompt(
        promptedAt: DateTime.now(),
        reason: 'Verification',
      );
      const event = SessionBiometricFailed();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionLocked>());
      final locked = success.newState as SessionLocked;
      expect(locked.reason, contains('Biometric'));
    });

    test('should transition from biometric prompt to expired', () {
      final state = SessionBiometricPrompt(
        promptedAt: DateTime.now(),
        reason: 'Verification',
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });
  });

  group('SessionFsm - Device Change Detection', () {
    test('should transition from active to device changed', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionDeviceChangedEvent(deviceId: 'new-device-123');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionDeviceChanged>());
      final deviceChanged = success.newState as SessionDeviceChanged;
      expect(deviceChanged.deviceId, equals('new-device-123'));
      expect(deviceChanged.needsAttention, isTrue);
      expect(success.effects, isNotNull);
    });

    test('should transition from device changed to active on verification', () {
      final state = SessionDeviceChanged(
        deviceId: 'new-device-123',
        detectedAt: DateTime.now(),
      );
      const event = SessionDeviceVerified();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should transition from device changed to expired', () {
      final state = SessionDeviceChanged(
        deviceId: 'new-device-123',
        detectedAt: DateTime.now(),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });
  });

  group('SessionFsm - Session Conflict', () {
    test('should transition from active to conflict on detection', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionConflictDetected(conflictingDeviceId: 'other-device');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionConflict>());
      final conflict = success.newState as SessionConflict;
      expect(conflict.conflictingDeviceId, equals('other-device'));
      expect(conflict.needsAttention, isTrue);
    });

    test('should transition from conflict to active on resolution', () {
      final state = SessionConflict(
        conflictingDeviceId: 'other-device',
        conflictDetectedAt: DateTime.now(),
      );
      const event = SessionResolveConflict();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionActive>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is FetchEffect), isTrue);
    });

    test('should transition from conflict to expired', () {
      final state = SessionConflict(
        conflictingDeviceId: 'other-device',
        conflictDetectedAt: DateTime.now(),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });
  });

  group('SessionFsm - Global Events', () {
    test('should transition to none on end from any state', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      const event = SessionEnd();

      final result = fsm.handleGlobal(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionNone>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is ClearEffect), isTrue);
    });

    test('should handle end from locked state', () {
      final state = SessionLocked(lockedAt: DateTime.now());
      const event = SessionEnd();

      final result = fsm.handleGlobal(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionNone>());
    });

    test('should handle end from biometric prompt state', () {
      final state = SessionBiometricPrompt(
        promptedAt: DateTime.now(),
        reason: 'Verification',
      );
      const event = SessionEnd();

      final result = fsm.handleGlobal(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionNone>());
    });
  });

  group('SessionFsm - Background Expiry', () {
    test('should transition from backgrounded to expired on timeout', () {
      final state = SessionBackgrounded(
        startedAt: DateTime.now(),
        backgroundedAt: DateTime.now(),
        timeout: const Duration(minutes: 5),
      );
      const event = SessionExpire();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<SessionState>>());
      final success = result as TransitionSuccess<SessionState>;
      expect(success.newState, isA<SessionExpired>());
    });
  });

  group('SessionFsm - State Properties', () {
    test('active state should be active', () {
      final state = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );
      expect(state.isActive, isTrue);
      expect(state.needsAttention, isFalse);
    });

    test('locked state should need attention', () {
      final state = SessionLocked(lockedAt: DateTime.now());
      expect(state.isActive, isFalse);
      expect(state.needsAttention, isTrue);
    });

    test('expiring state should need attention', () {
      final state = SessionExpiring(
        remainingSeconds: 30,
        expiresAt: DateTime.now().add(const Duration(seconds: 30)),
      );
      expect(state.needsAttention, isTrue);
    });

    test('expired state should need attention and be terminal', () {
      final state = SessionExpired(expiredAt: DateTime.now());
      expect(state.needsAttention, isTrue);
      expect(state.isTerminal, isTrue);
    });

    test('biometric prompt should need attention', () {
      final state = SessionBiometricPrompt(
        promptedAt: DateTime.now(),
        reason: 'Verification',
      );
      expect(state.needsAttention, isTrue);
    });

    test('device changed should need attention', () {
      final state = SessionDeviceChanged(
        deviceId: 'device123',
        detectedAt: DateTime.now(),
      );
      expect(state.needsAttention, isTrue);
    });

    test('conflict should need attention', () {
      final state = SessionConflict(
        conflictingDeviceId: 'other-device',
        conflictDetectedAt: DateTime.now(),
      );
      expect(state.needsAttention, isTrue);
    });
  });

  group('SessionFsm - Complex Flows', () {
    test('should handle full lifecycle: start -> background -> foreground -> lock -> unlock', () {
      const state1 = SessionNone();
      final result1 = fsm.handle(state1, const SessionStart());
      final state2 = (result1 as TransitionSuccess<SessionState>).newState;

      expect(state2, isA<SessionActive>());

      final result2 = fsm.handle(state2, const SessionBackground());
      final state3 = (result2 as TransitionSuccess<SessionState>).newState;

      expect(state3, isA<SessionBackgrounded>());

      final result3 = fsm.handle(state3, const SessionForeground());
      final state4 = (result3 as TransitionSuccess<SessionState>).newState;

      expect(state4, isA<SessionActive>());

      final result4 = fsm.handle(state4, const SessionLock(reason: 'Test'));
      final state5 = (result4 as TransitionSuccess<SessionState>).newState;

      expect(state5, isA<SessionLocked>());

      final result5 = fsm.handle(state5, const SessionUnlock());
      final state6 = (result5 as TransitionSuccess<SessionState>).newState;

      expect(state6, isA<SessionActive>());
    });

    test('should handle device change flow', () {
      final state1 = SessionActive(
        startedAt: DateTime.now(),
        lastActivity: DateTime.now(),
        timeout: const Duration(minutes: 30),
      );

      const event1 = SessionDeviceChangedEvent(deviceId: 'new-device');
      final result1 = fsm.handle(state1, event1);
      final state2 = (result1 as TransitionSuccess<SessionState>).newState;

      expect(state2, isA<SessionDeviceChanged>());

      const event2 = SessionDeviceVerified();
      final result2 = fsm.handle(state2, event2);
      final state3 = (result2 as TransitionSuccess<SessionState>).newState;

      expect(state3, isA<SessionActive>());
    });
  });
}
