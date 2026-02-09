import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/kyc_fsm.dart';
import 'package:usdc_wallet/state/fsm/fsm_base.dart';

void main() {
  late KycFsm fsm;

  setUp(() {
    fsm = KycFsm();
  });

  group('KycFsm - Initial State', () {
    test('should have initial as initial state', () {
      expect(fsm.initialState, isA<KycInitial>());
      expect(fsm.initialState.name, equals('INITIAL'));
      expect(fsm.initialState.tier, equals(KycTier.none));
    });
  });

  group('KycFsm - Fetch and Load', () {
    test('should transition from initial to loading on fetch', () {
      const state = KycInitial();
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });

    test('should transition from loading to none when no KYC exists', () {
      const state = KycLoading();
      const event = KycStatusLoaded(tier: KycTier.none, status: 'none');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycNone>());
    });

    test('should transition from loading to pending', () {
      const state = KycLoading();
      const event = KycStatusLoaded(
        tier: KycTier.tier1,
        status: 'pending',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycPending>());
      final pending = success.newState as KycPending;
      expect(pending.targetTier, equals(KycTier.tier1));
    });

    test('should transition from loading to verified', () {
      final verifiedAt = DateTime.now();
      final event = KycStatusLoaded(
        tier: KycTier.tier1,
        status: 'verified',
        verifiedAt: verifiedAt,
      );
      const state = KycLoading();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycVerified>());
      final verified = success.newState as KycVerified;
      expect(verified.tier, equals(KycTier.tier1));
      expect(verified.verifiedAt, equals(verifiedAt));
      expect(verified.canUpgrade, isTrue);
    });

    test('should transition from loading to expired', () {
      const state = KycLoading();
      const event = KycStatusLoaded(
        tier: KycTier.tier1,
        status: 'expired',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycExpired>());
      final expired = success.newState as KycExpired;
      expect(expired.previousTier, equals(KycTier.tier1));
    });

    test('should transition from loading to manual review', () {
      const state = KycLoading();
      const event = KycStatusLoaded(
        tier: KycTier.tier1,
        status: 'manual_review',
        rejectionReason: 'Additional verification required',
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycManualReview>());
      final review = success.newState as KycManualReview;
      expect(review.targetTier, equals(KycTier.tier1));
      expect(review.reason, equals('Additional verification required'));
    });
  });

  group('KycFsm - Start KYC Flow', () {
    test('should transition from none to inProgress on start', () {
      const state = KycNone();
      const event = KycStart(targetTier: KycTier.tier1);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final inProgress = success.newState as KycInProgress;
      expect(inProgress.targetTier, equals(KycTier.tier1));
      expect(inProgress.currentStep, equals(KycStep.personalInfo));
    });

    test('should progress through steps', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.personalInfo,
      );
      const event = KycNextStep(stepData: {'name': 'John Doe'});

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final nextState = success.newState as KycInProgress;
      expect(nextState.currentStep, equals(KycStep.documentType));
    });

    test('should go back to previous step', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.documentType,
      );
      const event = KycPreviousStep();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final prevState = success.newState as KycInProgress;
      expect(prevState.currentStep, equals(KycStep.personalInfo));
    });

    test('should return to none when going back from first step', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.personalInfo,
      );
      const event = KycPreviousStep();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycNone>());
    });

    test('should reach review step', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.selfie,
      );
      const event = KycNextStep(stepData: {'selfieUrl': 'url'});

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final reviewState = success.newState as KycInProgress;
      expect(reviewState.currentStep, equals(KycStep.review));
    });
  });

  group('KycFsm - Submit and Pending', () {
    test('should transition from inProgress to loading on submit', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.review,
      );
      const event = KycSubmit();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });

    test('should transition from inProgress to pending on submitted', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.review,
      );
      const event = KycSubmitted();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycPending>());
      expect(success.effects, isNotNull);
      expect(success.effects!.any((e) => e is NavigateEffect), isTrue);
    });

    test('should transition from inProgress to manual review', () {
      const state = KycInProgress(
        targetTier: KycTier.tier1,
        currentStep: KycStep.review,
      );
      const event = KycManualReviewRequired(reason: 'Document verification needed');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycManualReview>());
    });
  });

  group('KycFsm - Pending to Verified/Rejected', () {
    test('should transition from pending to verified on approval', () {
      final submittedAt = DateTime.now();
      final state = KycPending(
        targetTier: KycTier.tier1,
        submittedAt: submittedAt,
      );
      final verifiedAt = DateTime.now();
      final event = KycApproved(tier: KycTier.tier1, verifiedAt: verifiedAt);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycVerified>());
      final verified = success.newState as KycVerified;
      expect(verified.tier, equals(KycTier.tier1));
      expect(verified.verifiedAt, equals(verifiedAt));
      expect(success.effects, isNotNull);
    });

    test('should transition from pending to rejected on rejection', () {
      final state = KycPending(
        targetTier: KycTier.tier1,
        submittedAt: DateTime.now(),
      );
      const event = KycRejectedEvent(reason: 'Invalid documents');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycRejected>());
      final rejected = success.newState as KycRejected;
      expect(rejected.targetTier, equals(KycTier.tier1));
      expect(rejected.reason, equals('Invalid documents'));
    });

    test('should transition from pending to manual review', () {
      final state = KycPending(
        targetTier: KycTier.tier1,
        submittedAt: DateTime.now(),
      );
      const event = KycManualReviewRequired(reason: 'Needs human verification');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycManualReview>());
    });

    test('should allow refresh from pending state', () {
      final state = KycPending(
        targetTier: KycTier.tier1,
        submittedAt: DateTime.now(),
      );
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });
  });

  group('KycFsm - Manual Review Transitions', () {
    test('should transition from manual review to verified', () {
      final state = KycManualReview(
        targetTier: KycTier.tier1,
        reason: 'Under review',
        reviewStartedAt: DateTime.now(),
      );
      final verifiedAt = DateTime.now();
      final event = KycManualReviewCompleted(
        tier: KycTier.tier1,
        verifiedAt: verifiedAt,
      );

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycVerified>());
      final verified = success.newState as KycVerified;
      expect(verified.tier, equals(KycTier.tier1));
    });

    test('should transition from manual review to rejected', () {
      final state = KycManualReview(
        targetTier: KycTier.tier1,
        reason: 'Under review',
        reviewStartedAt: DateTime.now(),
      );
      const event = KycRejectedEvent(reason: 'Failed manual review');

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycRejected>());
    });

    test('should allow refresh from manual review', () {
      final state = KycManualReview(
        targetTier: KycTier.tier1,
        reason: 'Under review',
        reviewStartedAt: DateTime.now(),
      );
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });
  });

  group('KycFsm - Verified State Transitions', () {
    test('should transition from verified to expired', () {
      final state = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now().subtract(const Duration(days: 365)),
        nextTier: KycTier.tier2,
      );
      const event = KycExpiredEvent();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycExpired>());
      final expired = success.newState as KycExpired;
      expect(expired.previousTier, equals(KycTier.tier1));
      expect(success.effects, isNotNull);
    });

    test('should transition from verified to upgrading', () {
      final state = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now(),
        nextTier: KycTier.tier2,
      );
      const event = KycUpgrade(targetTier: KycTier.tier2);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycUpgrading>());
      final upgrading = success.newState as KycUpgrading;
      expect(upgrading.currentTier, equals(KycTier.tier1));
      expect(upgrading.targetTier, equals(KycTier.tier2));
      expect(upgrading.tier, equals(KycTier.tier1)); // Maintains tier during upgrade
    });

    test('should not upgrade if not available', () {
      final state = KycVerified(
        tier: KycTier.tier2,
        verifiedAt: DateTime.now(),
        nextTier: null,
      );
      const event = KycUpgrade(targetTier: KycTier.tier3);

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionNotApplicable<KycState>>());
    });

    test('should allow refresh from verified state', () {
      final state = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now(),
      );
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });
  });

  group('KycFsm - Expired and Renewal', () {
    test('should transition from expired to inProgress on renew', () {
      final state = KycExpired(
        previousTier: KycTier.tier1,
        expiredAt: DateTime.now(),
      );
      const event = KycRenew();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final inProgress = success.newState as KycInProgress;
      expect(inProgress.targetTier, equals(KycTier.tier1));
      expect(inProgress.currentStep, equals(KycStep.documentCapture));
    });

    test('should allow refresh from expired state', () {
      final state = KycExpired(
        previousTier: KycTier.tier1,
        expiredAt: DateTime.now(),
      );
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });
  });

  group('KycFsm - Rejected and Resubmit', () {
    test('should transition from rejected to inProgress on resubmit', () {
      final state = KycRejected(
        targetTier: KycTier.tier1,
        reason: 'Invalid documents',
        rejectedAt: DateTime.now(),
      );
      const event = KycResubmit();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycInProgress>());
      final inProgress = success.newState as KycInProgress;
      expect(inProgress.targetTier, equals(KycTier.tier1));
      expect(inProgress.currentStep, equals(KycStep.documentCapture));
    });
  });

  group('KycFsm - Upgrading Flow', () {
    test('should progress through upgrade steps', () {
      const state = KycUpgrading(
        currentTier: KycTier.tier1,
        targetTier: KycTier.tier2,
        currentStep: KycStep.addressProof,
      );
      const event = KycNextStep(stepData: {'address': 'proof'});

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycUpgrading>());
      final nextState = success.newState as KycUpgrading;
      expect(nextState.currentStep, equals(KycStep.review));
    });

    test('should go back during upgrade', () {
      const state = KycUpgrading(
        currentTier: KycTier.tier1,
        targetTier: KycTier.tier2,
        currentStep: KycStep.review,
      );
      const event = KycPreviousStep();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycUpgrading>());
    });

    test('should go back to previous step during upgrade', () {
      const state = KycUpgrading(
        currentTier: KycTier.tier1,
        targetTier: KycTier.tier2,
        currentStep: KycStep.review,
      );
      const event = KycPreviousStep();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycUpgrading>());
      final upgrading = success.newState as KycUpgrading;
      expect(upgrading.currentStep, equals(KycStep.selfie));
    });

    test('should submit upgrade', () {
      const state = KycUpgrading(
        currentTier: KycTier.tier1,
        targetTier: KycTier.tier2,
        currentStep: KycStep.review,
      );
      const event = KycSubmitted();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycPending>());
      final pending = success.newState as KycPending;
      expect(pending.targetTier, equals(KycTier.tier2));
    });
  });

  group('KycFsm - Error Handling', () {
    test('should allow retry from error state', () {
      const state = KycError(
        errorMessage: 'Network error',
        previousState: KycInitial(),
      );
      const event = KycFetch();

      final result = fsm.handle(state, event);

      expect(result, isA<TransitionSuccess<KycState>>());
      final success = result as TransitionSuccess<KycState>;
      expect(success.newState, isA<KycLoading>());
    });

    test('error state should maintain previous tier', () {
      final previousState = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now().subtract(const Duration(days: 30)),
      );
      final state = KycError(
        errorMessage: 'Error',
        previousState: previousState,
      );

      expect(state.tier, equals(KycTier.tier1));
    });
  });

  group('KycFsm - Tier Capabilities', () {
    test('tier none should have basic capabilities', () {
      const state = KycNone();
      expect(state.tier, equals(KycTier.none));
      expect(state.canSend, isTrue);
      expect(state.canReceive, isTrue);
      expect(state.canDeposit, isFalse);
      expect(state.canWithdraw, isFalse);
    });

    test('tier 1 should allow deposits and withdrawals', () {
      final state = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now(),
      );
      expect(state.canDeposit, isTrue);
      expect(state.canWithdraw, isTrue);
      expect(state.canPerform(KycRequirements.deposit), isTrue);
    });

    test('tier 2 should allow high limits', () {
      final state = KycVerified(
        tier: KycTier.tier2,
        verifiedAt: DateTime.now(),
      );
      expect(state.canPerform(KycRequirements.highLimits), isTrue);
      expect(state.canPerform(KycRequirements.internationalTransfer), isTrue);
    });

    test('should compare tiers correctly', () {
      expect(KycTier.tier1 > KycTier.none, isTrue);
      expect(KycTier.tier2 > KycTier.tier1, isTrue);
      expect(KycTier.tier1 >= KycTier.tier1, isTrue);
      expect(KycTier.none < KycTier.tier1, isTrue);
    });
  });

  group('KycFsm - State Properties', () {
    test('loading state should be transitioning', () {
      const state = KycLoading();
      expect(state.isTransitioning, isTrue);
    });

    test('verified state should detect upgrade availability', () {
      final state1 = KycVerified(
        tier: KycTier.tier1,
        verifiedAt: DateTime.now(),
        nextTier: KycTier.tier2,
      );
      expect(state1.canUpgrade, isTrue);

      final state2 = KycVerified(
        tier: KycTier.tier2,
        verifiedAt: DateTime.now(),
        nextTier: null,
      );
      expect(state2.canUpgrade, isFalse);
    });

    test('upgrading state should maintain current tier', () {
      const state = KycUpgrading(
        currentTier: KycTier.tier1,
        targetTier: KycTier.tier2,
        currentStep: KycStep.addressProof,
      );
      expect(state.tier, equals(KycTier.tier1));
    });
  });
}
