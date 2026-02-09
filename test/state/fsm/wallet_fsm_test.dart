import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';

void main() {
  late WalletFsm fsm;

  setUp(() {
    fsm = WalletFsm();
  });

  group('WalletFsm - Initial State', () {
    test('should have none as initial state', () {
      expect(fsm.initialState, isA<WalletNone>());
      expect(fsm.initialState.name, equals('NONE'));
    });

    test('initial state should not allow transactions', () {
      expect(fsm.initialState.canTransact, isFalse);
    });
  });

  group('WalletFsm - Fetch and Load', () {
    test('should transition from none to loading on fetch', () {
      const state = WalletNone();
      const event = WalletFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
      expect((success.newState as WalletLoading).isRefresh, isFalse);
    });

    test('should transition from loading to ready on success', () {
      const state = WalletLoading();
      const event = WalletLoaded(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        blockchain: 'MATIC',
        usdcBalance: 100.50,
        pendingBalance: 5.25,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletReady>());
      final ready = success.newState as WalletReady;
      expect(ready.walletId, equals('wallet123'));
      expect(ready.usdcBalance, equals(100.50));
      expect(ready.pendingBalance, equals(5.25));
      expect(ready.totalBalance, equals(105.75));
      expect(ready.canTransact, isTrue);
    });

    test('should transition from loading to notCreated on not found', () {
      const state = WalletLoading();
      const event = WalletNotFound();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletNotCreated>());
    });

    test('should transition from loading to error on failure', () {
      const state = WalletLoading();
      const event = WalletFailed(message: 'Network error');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletError>());
      final error = success.newState as WalletError;
      expect(error.errorMessage, equals('Network error'));
      expect(error.previousState, isA<WalletNone>());
    });
  });

  group('WalletFsm - Wallet Creation', () {
    test('should transition from notCreated to creating on create', () {
      const state = WalletNotCreated();
      const event = WalletCreate();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletCreating>());
      expect(success.effects, isNotNull);
    });

    test('should transition from creating to ready on success', () {
      const state = WalletCreating();
      const event = WalletCreated(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        blockchain: 'MATIC',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletReady>());
      final ready = success.newState as WalletReady;
      expect(ready.walletId, equals('wallet123'));
      expect(ready.usdcBalance, equals(0));
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should transition from creating to error on failure', () {
      const state = WalletCreating();
      const event = WalletFailed(message: 'Creation failed');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletError>());
      final error = success.newState as WalletError;
      expect(error.errorMessage, equals('Creation failed'));
      expect(error.previousState, isA<WalletNotCreated>());
    });
  });

  group('WalletFsm - Ready State Transitions', () {
    test('should transition from ready to frozen', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      final frozenUntil = DateTime.now().add(const Duration(days: 30));
      final event = WalletFrozenEvent(
        reason: 'Suspicious activity',
        frozenUntil: frozenUntil,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletFrozen>());
      final frozen = success.newState as WalletFrozen;
      expect(frozen.walletId, equals('wallet123'));
      expect(frozen.reason, equals('Suspicious activity'));
      expect(frozen.frozenUntil, equals(frozenUntil));
      expect(frozen.isPermanent, isFalse);
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should transition from ready to under review', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      const event = WalletUnderReviewEvent(reason: 'Compliance check required');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletUnderReview>());
      final review = success.newState as WalletUnderReview;
      expect(review.walletId, equals('wallet123'));
      expect(review.reason, equals('Compliance check required'));
    });

    test('should transition from ready to limited', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      const event = WalletLimitedEvent(
        reason: 'KYC tier 1 limits',
        maxTransactionAmount: 500.0,
        dailyLimit: 1000.0,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLimited>());
      final limited = success.newState as WalletLimited;
      expect(limited.walletId, equals('wallet123'));
      expect(limited.limitReason, equals('KYC tier 1 limits'));
      expect(limited.maxTransactionAmount, equals(500.0));
      expect(limited.dailyLimit, equals(1000.0));
      expect(limited.canTransact, isTrue);
    });

    test('should refresh from ready state', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      const event = WalletRefresh();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
      expect((success.newState as WalletLoading).isRefresh, isTrue);
    });

    test('should update balance optimistically', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      const event = WalletBalanceUpdate(
        subtractAmount: 25.0,
        addPending: 5.0,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletReady>());
      final updated = success.newState as WalletReady;
      expect(updated.usdcBalance, equals(75.0));
      expect(updated.pendingBalance, equals(5.0));
    });

    test('should update balance directly from loaded event', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      const event = WalletLoaded(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 150.0,
        pendingBalance: 10.0,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletReady>());
      final updated = success.newState as WalletReady;
      expect(updated.usdcBalance, equals(150.0));
      expect(updated.pendingBalance, equals(10.0));
    });
  });

  group('WalletFsm - Frozen State Transitions', () {
    test('should transition from frozen to loading on unfreeze', () {
      final state = WalletFrozen(
        walletId: 'wallet123',
        reason: 'Was frozen',
        frozenAt: DateTime.now(),
      );
      const event = WalletUnfrozen();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NotifyEffect), isTrue);
    });

    test('should allow refresh from frozen state', () {
      final state = WalletFrozen(
        walletId: 'wallet123',
        reason: 'Frozen',
        frozenAt: DateTime.now(),
      );
      const event = WalletRefresh();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
    });

    test('frozen state should detect permanent freeze', () {
      final state = WalletFrozen(
        walletId: 'wallet123',
        reason: 'Permanent freeze',
        frozenAt: DateTime.now(),
        frozenUntil: null,
      );

      expect(state.isPermanent, isTrue);
    });
  });

  group('WalletFsm - Under Review Transitions', () {
    test('should transition from under review to loading on completion', () {
      final state = WalletUnderReview(
        walletId: 'wallet123',
        reason: 'Compliance review',
        reviewStartedAt: DateTime.now(),
      );
      const event = WalletReviewCompleted();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
      expect(success.effects, isNotNull);
    });

    test('should allow refresh from under review state', () {
      final state = WalletUnderReview(
        walletId: 'wallet123',
        reason: 'Under review',
        reviewStartedAt: DateTime.now(),
      );
      const event = WalletRefresh();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
    });
  });

  group('WalletFsm - Limited State Transitions', () {
    test('should transition from limited to ready when limits removed', () {
      final state = WalletLimited(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
        limitReason: 'Tier 1 limits',
        maxTransactionAmount: 500.0,
        dailyLimit: 1000.0,
      );
      const event = WalletLoaded(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletReady>());
    });

    test('should transition from limited to frozen', () {
      final state = WalletLimited(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
        limitReason: 'Tier 1 limits',
      );
      const event = WalletFrozenEvent(reason: 'Suspicious activity');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletFrozen>());
    });

    test('should allow refresh from limited state', () {
      final state = WalletLimited(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
        limitReason: 'Tier 1 limits',
      );
      const event = WalletRefresh();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
    });
  });

  group('WalletFsm - Error Handling', () {
    test('should allow retry from error state', () {
      const state = WalletError(
        errorMessage: 'Network error',
        previousState: WalletNone(),
      );
      const event = WalletFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<WalletState>>());
      final success = result as TransitionSuccess<WalletState>;
      expect(success.newState, isA<WalletLoading>());
    });
  });

  group('WalletFsm - State Properties', () {
    test('loading state should be transitioning', () {
      const state = WalletLoading();
      expect(state.isTransitioning, isTrue);
    });

    test('creating state should be transitioning', () {
      const state = WalletCreating();
      expect(state.isTransitioning, isTrue);
    });

    test('ready state should allow transactions', () {
      final state = WalletReady(
        walletId: 'wallet123',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      expect(state.canTransact, isTrue);
    });

    test('frozen state should not allow transactions', () {
      final state = WalletFrozen(
        walletId: 'wallet123',
        reason: 'Frozen',
        frozenAt: DateTime.now(),
      );
      expect(state.canTransact, isFalse);
    });

    test('limited state should allow transactions', () {
      final state = WalletLimited(
        walletId: 'wallet123',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
        limitReason: 'Limited',
      );
      expect(state.canTransact, isTrue);
    });

    test('ready state should calculate total balance', () {
      final state = WalletReady(
        walletId: 'wallet123',
        usdcBalance: 100.0,
        pendingBalance: 25.5,
        lastUpdated: DateTime.now(),
      );
      expect(state.totalBalance, equals(125.5));
    });

    test('ready state should format short address', () {
      final state = WalletReady(
        walletId: 'wallet123',
        walletAddress: '0x1234567890abcdef1234567890abcdef12345678',
        usdcBalance: 100.0,
        lastUpdated: DateTime.now(),
      );
      expect(state.shortAddress, equals('0x1234...5678'));
    });

    test('limited state should calculate total balance', () {
      final state = WalletLimited(
        walletId: 'wallet123',
        usdcBalance: 100.0,
        pendingBalance: 10.0,
        lastUpdated: DateTime.now(),
        limitReason: 'Limited',
      );
      expect(state.totalBalance, equals(110.0));
    });
  });

  group('WalletFsm - Complex Flows', () {
    test('should handle full lifecycle: none -> loading -> ready -> frozen -> unfrozen -> loading', () {
      const state1 = WalletNone();
      final result1 = fsm.handle(state1, const WalletFetch());
      final state2 = (result1 as TransitionSuccess<WalletState>).newState;

      const event2 = WalletLoaded(
        walletId: 'wallet123',
        usdcBalance: 100.0,
      );
      final result2 = fsm.handle(state2, event2);
      final state3 = (result2 as TransitionSuccess<WalletState>).newState as WalletReady;

      const event3 = WalletFrozenEvent(reason: 'Suspicious');
      final result3 = fsm.handle(state3, event3);
      final state4 = (result3 as TransitionSuccess<WalletState>).newState;

      expect(state4, isA<WalletFrozen>());

      const event4 = WalletUnfrozen();
      final result4 = fsm.handle(state4, event4);
      final state5 = (result4 as TransitionSuccess<WalletState>).newState;

      expect(state5, isA<WalletLoading>());
    });
  });
}
