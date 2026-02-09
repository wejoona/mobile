import 'package:usdc_wallet/state/fsm/fsm_base.dart';

/// ┌─────────────────────────────────────────────────────────────────┐
/// │                         KYC FSM                                  │
/// ├─────────────────────────────────────────────────────────────────┤
/// │                                                                  │
/// │                        ┌──────────────┐                          │
/// │            FETCH       │              │                          │
/// │  ┌───────────────────▶│   Loading    │                          │
/// │  │                     │              │                          │
/// │  │                     └──────┬───────┘                          │
/// │  │                            │                                  │
/// │  │                   ┌────────┼────────┐                         │
/// │  │                   │        │        │                         │
/// │  │                NONE     PENDING   VERIFIED                    │
/// │  │                   │        │        │                         │
/// │  │                   ▼        ▼        ▼                         │
/// │  │            ┌──────────────────────────────┐                   │
/// │  │            │         Tier 0 (None)        │                   │
/// │  │            │  • Basic features only       │                   │
/// │  │            │  • Low limits                │                   │
/// │  │            └────────────┬─────────────────┘                   │
/// │  │                         │                                     │
/// │  │                    START_KYC                                  │
/// │  │                         │                                     │
/// │  │                         ▼                                     │
/// │  │            ┌──────────────────────────────┐                   │
/// │  │            │      Tier 1 (In Progress)    │                   │
/// │  │            │  • Collecting documents      │                   │
/// │  │            └────────────┬─────────────────┘                   │
/// │  │                         │                                     │
/// │  │                      SUBMIT                                   │
/// │  │                         │                                     │
/// │  │                         ▼                                     │
/// │  │            ┌──────────────────────────────┐                   │
/// │  │            │        Tier 1 (Pending)      │◀──┐               │
/// │  │            │  • Awaiting review           │   │               │
/// │  │            └────────────┬─────────────────┘   │               │
/// │  │                         │                     │               │
/// │  │              ┌──────────┴──────────┐          │               │
/// │  │              │                     │          │               │
/// │  │           APPROVED             REJECTED       │               │
/// │  │              │                     │          │               │
/// │  │              ▼                     ▼          │               │
/// │  │  ┌──────────────────┐   ┌──────────────────┐  │               │
/// │  │  │  Tier 1 Verified │   │     Rejected     │──┘               │
/// │  │  │  • Higher limits │   │  • Can resubmit  │ RESUBMIT         │
/// │  │  └────────┬─────────┘   └──────────────────┘                  │
/// │  │           │                                                   │
/// │  │      UPGRADE_KYC                                              │
/// │  │           │                                                   │
/// │  │           ▼                                                   │
/// │  │  ┌──────────────────┐                                         │
/// │  │  │  Tier 2 Verified │                                         │
/// │  │  │  • Maximum limits│                                         │
/// │  │  │  • All features  │                                         │
/// │  │  └──────────────────┘                                         │
/// │  │                                                               │
/// │  │                                                               │
/// │  └──────────── Initial ──────────────────────────────────────────│
/// │                                                                  │
/// │  GLOBAL: RESET ──▶ Initial                                       │
/// │                                                                  │
/// └─────────────────────────────────────────────────────────────────┘

// ═══════════════════════════════════════════════════════════════════
// KYC TIERS - Define capabilities at each level
// ═══════════════════════════════════════════════════════════════════

enum KycTier {
  none(0),
  tier1(1),
  tier2(2),
  tier3(3);

  const KycTier(this.level);

  final int level;

  bool operator >=(KycTier other) => level >= other.level;
  bool operator >(KycTier other) => level > other.level;
  bool operator <=(KycTier other) => level <= other.level;
  bool operator <(KycTier other) => level < other.level;
}

/// Feature requirements
class KycRequirements {
  static const KycTier sendMoney = KycTier.none;
  static const KycTier receiveMoney = KycTier.none;
  static const KycTier deposit = KycTier.tier1;
  static const KycTier withdraw = KycTier.tier1;
  static const KycTier highLimits = KycTier.tier2;
  static const KycTier internationalTransfer = KycTier.tier2;
}

// ═══════════════════════════════════════════════════════════════════
// STATES
// ═══════════════════════════════════════════════════════════════════

sealed class KycState extends FsmState {
  const KycState();

  /// Current KYC tier
  KycTier get tier;

  /// Whether user can perform an action requiring a specific tier
  bool canPerform(KycTier required) => tier >= required;

  /// Whether user can send money
  bool get canSend => canPerform(KycRequirements.sendMoney);

  /// Whether user can receive money
  bool get canReceive => canPerform(KycRequirements.receiveMoney);

  /// Whether user can deposit
  bool get canDeposit => canPerform(KycRequirements.deposit);

  /// Whether user can withdraw
  bool get canWithdraw => canPerform(KycRequirements.withdraw);
}

/// Initial state - KYC status unknown
class KycInitial extends KycState {
  const KycInitial();

  @override
  String get name => 'INITIAL';

  @override
  KycTier get tier => KycTier.none;
}

/// Loading KYC status
class KycLoading extends KycState {
  const KycLoading();

  @override
  String get name => 'LOADING';

  @override
  KycTier get tier => KycTier.none;

  @override
  bool get isTransitioning => true;
}

/// No KYC submitted (Tier 0)
class KycNone extends KycState {
  const KycNone();

  @override
  String get name => 'NONE';

  @override
  KycTier get tier => KycTier.none;
}

/// KYC in progress - user is filling out forms
class KycInProgress extends KycState {
  const KycInProgress({
    required this.targetTier,
    required this.currentStep,
    this.collectedData,
  });

  final KycTier targetTier;
  final KycStep currentStep;
  final Map<String, dynamic>? collectedData;

  @override
  String get name => 'IN_PROGRESS';

  @override
  KycTier get tier => KycTier.none; // Still tier 0 until verified
}

/// KYC submitted, awaiting review
class KycPending extends KycState {
  const KycPending({
    required this.targetTier,
    required this.submittedAt,
  });

  final KycTier targetTier;
  final DateTime submittedAt;

  @override
  String get name => 'PENDING';

  @override
  KycTier get tier => KycTier.none; // Still tier 0 until verified
}

/// KYC verified at a specific tier
class KycVerified extends KycState {
  const KycVerified({
    required this.tier,
    required this.verifiedAt,
    this.nextTier,
  });

  @override
  final KycTier tier;
  final DateTime verifiedAt;
  final KycTier? nextTier; // If upgrade is available

  @override
  String get name => 'VERIFIED_TIER${tier.level}';

  bool get canUpgrade => nextTier != null;
}

/// KYC rejected - can resubmit
class KycRejected extends KycState {
  const KycRejected({
    required this.targetTier,
    required this.reason,
    required this.rejectedAt,
  });

  final KycTier targetTier;
  final String reason;
  final DateTime rejectedAt;

  @override
  String get name => 'REJECTED';

  @override
  KycTier get tier => KycTier.none;
}

/// KYC documents expired
class KycExpired extends KycState {
  const KycExpired({
    required this.previousTier,
    required this.expiredAt,
  });

  final KycTier previousTier;
  final DateTime expiredAt;

  @override
  String get name => 'EXPIRED';

  @override
  KycTier get tier => KycTier.none; // Reverted to tier 0 until renewal
}

/// KYC pending manual review
class KycManualReview extends KycState {
  const KycManualReview({
    required this.targetTier,
    required this.reason,
    required this.reviewStartedAt,
  });

  final KycTier targetTier;
  final String reason;
  final DateTime reviewStartedAt;

  @override
  String get name => 'MANUAL_REVIEW';

  @override
  KycTier get tier => KycTier.none; // Still tier 0 until verified
}

/// KYC upgrade in progress
class KycUpgrading extends KycState {
  const KycUpgrading({
    required this.currentTier,
    required this.targetTier,
    required this.currentStep,
    this.collectedData,
  });

  final KycTier currentTier;
  final KycTier targetTier;
  final KycStep currentStep;
  final Map<String, dynamic>? collectedData;

  @override
  String get name => 'UPGRADING';

  @override
  KycTier get tier => currentTier; // Maintain current tier during upgrade
}

/// KYC error
class KycError extends KycState with FsmStateError {
  const KycError({
    required this.errorMessage,
    this.errorData,
    required this.previousState,
  });

  @override
  final String errorMessage;
  @override
  final dynamic errorData;
  final KycState previousState;

  @override
  String get name => 'ERROR';

  @override
  KycTier get tier => previousState.tier;
}

// ═══════════════════════════════════════════════════════════════════
// KYC STEPS
// ═══════════════════════════════════════════════════════════════════

enum KycStep {
  personalInfo,
  documentType,
  documentCapture,
  selfie,
  addressProof,
  review,
}

// ═══════════════════════════════════════════════════════════════════
// EVENTS
// ═══════════════════════════════════════════════════════════════════

sealed class KycEvent extends FsmEvent {
  const KycEvent();
}

/// Fetch current KYC status
class KycFetch extends KycEvent {
  const KycFetch();

  @override
  String get name => 'FETCH';
}

/// KYC status loaded
class KycStatusLoaded extends KycEvent {
  const KycStatusLoaded({
    required this.tier,
    required this.status,
    this.rejectionReason,
    this.verifiedAt,
  });

  final KycTier tier;
  final String status; // none, pending, verified, rejected
  final String? rejectionReason;
  final DateTime? verifiedAt;

  @override
  String get name => 'STATUS_LOADED';
}

/// Start KYC process
class KycStart extends KycEvent {
  const KycStart({this.targetTier = KycTier.tier1});

  final KycTier targetTier;

  @override
  String get name => 'START';
}

/// Progress to next step
class KycNextStep extends KycEvent {
  const KycNextStep({required this.stepData});

  final Map<String, dynamic> stepData;

  @override
  String get name => 'NEXT_STEP';
}

/// Go back to previous step
class KycPreviousStep extends KycEvent {
  const KycPreviousStep();

  @override
  String get name => 'PREVIOUS_STEP';
}

/// Submit KYC for review
class KycSubmit extends KycEvent {
  const KycSubmit();

  @override
  String get name => 'SUBMIT';
}

/// KYC submitted successfully
class KycSubmitted extends KycEvent {
  const KycSubmitted();

  @override
  String get name => 'SUBMITTED';
}

/// KYC approved
class KycApproved extends KycEvent {
  const KycApproved({required this.tier, required this.verifiedAt});

  final KycTier tier;
  final DateTime verifiedAt;

  @override
  String get name => 'APPROVED';
}

/// KYC rejected
class KycRejectedEvent extends KycEvent {
  const KycRejectedEvent({required this.reason});

  final String reason;

  @override
  String get name => 'REJECTED';
}

/// Start upgrade to next tier
class KycUpgrade extends KycEvent {
  const KycUpgrade({required this.targetTier});

  final KycTier targetTier;

  @override
  String get name => 'UPGRADE';
}

/// Resubmit after rejection
class KycResubmit extends KycEvent {
  const KycResubmit();

  @override
  String get name => 'RESUBMIT';
}

/// Error occurred
class KycFailed extends KycEvent {
  const KycFailed({required this.message, this.data});

  final String message;
  final dynamic data;

  @override
  String get name => 'FAILED';
}

/// KYC expired event
class KycExpiredEvent extends KycEvent {
  const KycExpiredEvent();

  @override
  String get name => 'EXPIRED';
}

/// Manual review required
class KycManualReviewRequired extends KycEvent {
  const KycManualReviewRequired({required this.reason});

  final String reason;

  @override
  String get name => 'MANUAL_REVIEW_REQUIRED';
}

/// Manual review completed
class KycManualReviewCompleted extends KycEvent {
  const KycManualReviewCompleted({
    required this.tier,
    required this.verifiedAt,
  });

  final KycTier tier;
  final DateTime verifiedAt;

  @override
  String get name => 'MANUAL_REVIEW_COMPLETED';
}

/// Renew expired KYC
class KycRenew extends KycEvent {
  const KycRenew();

  @override
  String get name => 'RENEW';
}

// ═══════════════════════════════════════════════════════════════════
// FSM DEFINITION
// ═══════════════════════════════════════════════════════════════════

class KycFsm extends FsmDefinition<KycState, KycEvent> {
  @override
  KycState get initialState => const KycInitial();

  @override
  TransitionResult<KycState> handle(KycState currentState, KycEvent event) {
    return switch (currentState) {
      KycInitial() => _handleInitial(currentState, event),
      KycLoading() => _handleLoading(currentState, event),
      KycNone() => _handleNone(currentState, event),
      KycInProgress() => _handleInProgress(currentState, event),
      KycPending() => _handlePending(currentState, event),
      KycVerified() => _handleVerified(currentState, event),
      KycRejected() => _handleRejected(currentState, event),
      KycExpired() => _handleExpired(currentState, event),
      KycManualReview() => _handleManualReview(currentState, event),
      KycUpgrading() => _handleUpgrading(currentState, event),
      KycError() => _handleError(currentState, event),
    };
  }

  TransitionResult<KycState> _handleInitial(
    KycInitial state,
    KycEvent event,
  ) {
    if (event is KycFetch) {
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    // Also handle KycStatusLoaded in initial state (e.g., from auth response)
    if (event is KycStatusLoaded) {
      return switch (event.status) {
        'none' => const TransitionSuccess(KycNone()),
        'pending' => TransitionSuccess(
            KycPending(
              targetTier: event.tier,
              submittedAt: DateTime.now(),
            ),
          ),
        'verified' => TransitionSuccess(
            KycVerified(
              tier: event.tier,
              verifiedAt: event.verifiedAt ?? DateTime.now(),
              nextTier: event.tier < KycTier.tier2 ? KycTier.tier2 : null,
            ),
          ),
        'rejected' => TransitionSuccess(
            KycRejected(
              targetTier: event.tier,
              reason: event.rejectionReason ?? 'Unknown reason',
              rejectedAt: DateTime.now(),
            ),
          ),
        _ => const TransitionSuccess(KycNone()),
      };
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleLoading(
    KycLoading state,
    KycEvent event,
  ) {
    if (event is KycStatusLoaded) {
      return switch (event.status) {
        'none' => const TransitionSuccess(KycNone()),
        'pending' => TransitionSuccess(
            KycPending(
              targetTier: event.tier,
              submittedAt: DateTime.now(),
            ),
          ),
        'verified' => TransitionSuccess(
            KycVerified(
              tier: event.tier,
              verifiedAt: event.verifiedAt ?? DateTime.now(),
              nextTier: event.tier < KycTier.tier2 ? KycTier.tier2 : null,
            ),
          ),
        'rejected' => TransitionSuccess(
            KycRejected(
              targetTier: event.tier,
              reason: event.rejectionReason ?? 'Unknown reason',
              rejectedAt: DateTime.now(),
            ),
          ),
        'expired' => TransitionSuccess(
            KycExpired(
              previousTier: event.tier,
              expiredAt: DateTime.now(),
            ),
          ),
        'manual_review' => TransitionSuccess(
            KycManualReview(
              targetTier: event.tier,
              reason: event.rejectionReason ?? 'Additional verification required',
              reviewStartedAt: DateTime.now(),
            ),
          ),
        _ => const TransitionSuccess(KycNone()),
      };
    }
    if (event is KycFailed) {
      return TransitionSuccess(
        KycError(
          errorMessage: event.message,
          errorData: event.data,
          previousState: const KycInitial(),
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleNone(KycNone state, KycEvent event) {
    if (event is KycStart) {
      return TransitionSuccess(
        KycInProgress(
          targetTier: event.targetTier,
          currentStep: KycStep.personalInfo,
        ),
        effects: [const NavigateEffect('/kyc/personal-info')],
      );
    }
    // Handle status updates (e.g., after KYC submission)
    if (event is KycStatusLoaded) {
      return switch (event.status) {
        'none' => const TransitionSuccess(KycNone()),
        'pending' => TransitionSuccess(
            KycPending(
              targetTier: event.tier,
              submittedAt: DateTime.now(),
            ),
          ),
        'verified' => TransitionSuccess(
            KycVerified(
              tier: event.tier,
              verifiedAt: event.verifiedAt ?? DateTime.now(),
              nextTier: event.tier < KycTier.tier2 ? KycTier.tier2 : null,
            ),
          ),
        'rejected' => TransitionSuccess(
            KycRejected(
              targetTier: event.tier,
              reason: event.rejectionReason ?? 'Unknown reason',
              rejectedAt: DateTime.now(),
            ),
          ),
        _ => const TransitionSuccess(KycNone()),
      };
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleInProgress(
    KycInProgress state,
    KycEvent event,
  ) {
    if (event is KycNextStep) {
      final nextStep = _getNextStep(state.currentStep);
      if (nextStep == null) {
        // At last step, ready to submit
        return TransitionSuccess(
          KycInProgress(
            targetTier: state.targetTier,
            currentStep: KycStep.review,
            collectedData: {...?state.collectedData, ...event.stepData},
          ),
        );
      }
      return TransitionSuccess(
        KycInProgress(
          targetTier: state.targetTier,
          currentStep: nextStep,
          collectedData: {...?state.collectedData, ...event.stepData},
        ),
      );
    }
    if (event is KycPreviousStep) {
      final prevStep = _getPreviousStep(state.currentStep);
      if (prevStep == null) {
        return const TransitionSuccess(KycNone());
      }
      return TransitionSuccess(
        KycInProgress(
          targetTier: state.targetTier,
          currentStep: prevStep,
          collectedData: state.collectedData,
        ),
      );
    }
    if (event is KycSubmit) {
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/submit')],
      );
    }
    if (event is KycSubmitted) {
      return TransitionSuccess(
        KycPending(
          targetTier: state.targetTier,
          submittedAt: DateTime.now(),
        ),
        effects: [
          const NavigateEffect('/kyc/submitted'),
          const NotifyEffect('KYC submitted for review', type: NotifyType.success),
        ],
      );
    }
    if (event is KycManualReviewRequired) {
      return TransitionSuccess(
        KycManualReview(
          targetTier: state.targetTier,
          reason: event.reason,
          reviewStartedAt: DateTime.now(),
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.warning),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handlePending(
    KycPending state,
    KycEvent event,
  ) {
    if (event is KycApproved) {
      return TransitionSuccess(
        KycVerified(
          tier: event.tier,
          verifiedAt: event.verifiedAt,
          nextTier: event.tier < KycTier.tier2 ? KycTier.tier2 : null,
        ),
        effects: [
          const NotifyEffect('KYC verified!', type: NotifyType.success),
        ],
      );
    }
    if (event is KycRejectedEvent) {
      return TransitionSuccess(
        KycRejected(
          targetTier: state.targetTier,
          reason: event.reason,
          rejectedAt: DateTime.now(),
        ),
        effects: [
          NotifyEffect('KYC rejected: ${event.reason}', type: NotifyType.error),
        ],
      );
    }
    if (event is KycManualReviewRequired) {
      return TransitionSuccess(
        KycManualReview(
          targetTier: state.targetTier,
          reason: event.reason,
          reviewStartedAt: DateTime.now(),
        ),
        effects: [
          NotifyEffect(event.reason, type: NotifyType.warning),
        ],
      );
    }
    if (event is KycFetch) {
      // Poll for status update
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleVerified(
    KycVerified state,
    KycEvent event,
  ) {
    if (event is KycUpgrade && state.canUpgrade) {
      return TransitionSuccess(
        KycUpgrading(
          currentTier: state.tier,
          targetTier: event.targetTier,
          currentStep: KycStep.addressProof, // Higher tiers start later
        ),
      );
    }
    if (event is KycExpiredEvent) {
      return TransitionSuccess(
        KycExpired(
          previousTier: state.tier,
          expiredAt: DateTime.now(),
        ),
        effects: [
          const NotifyEffect('KYC expired. Please renew your documents.', type: NotifyType.warning),
        ],
      );
    }
    if (event is KycFetch) {
      // Refresh status
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleRejected(
    KycRejected state,
    KycEvent event,
  ) {
    if (event is KycResubmit) {
      return TransitionSuccess(
        KycInProgress(
          targetTier: state.targetTier,
          currentStep: KycStep.documentCapture, // Start from documents
        ),
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleExpired(
    KycExpired state,
    KycEvent event,
  ) {
    if (event is KycRenew) {
      return TransitionSuccess(
        KycInProgress(
          targetTier: state.previousTier,
          currentStep: KycStep.documentCapture, // Start from documents
        ),
        effects: [
          const NavigateEffect('/kyc/renew'),
        ],
      );
    }
    if (event is KycFetch) {
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleManualReview(
    KycManualReview state,
    KycEvent event,
  ) {
    if (event is KycManualReviewCompleted) {
      return TransitionSuccess(
        KycVerified(
          tier: event.tier,
          verifiedAt: event.verifiedAt,
          nextTier: event.tier < KycTier.tier2 ? KycTier.tier2 : null,
        ),
        effects: [
          const NotifyEffect('KYC verified!', type: NotifyType.success),
        ],
      );
    }
    if (event is KycRejectedEvent) {
      return TransitionSuccess(
        KycRejected(
          targetTier: state.targetTier,
          reason: event.reason,
          rejectedAt: DateTime.now(),
        ),
        effects: [
          NotifyEffect('KYC rejected: ${event.reason}', type: NotifyType.error),
        ],
      );
    }
    if (event is KycFetch) {
      // Poll for status update
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleUpgrading(
    KycUpgrading state,
    KycEvent event,
  ) {
    if (event is KycNextStep) {
      final nextStep = _getNextStep(state.currentStep);
      if (nextStep == null) {
        return TransitionSuccess(
          KycUpgrading(
            currentTier: state.currentTier,
            targetTier: state.targetTier,
            currentStep: KycStep.review,
            collectedData: {...?state.collectedData, ...event.stepData},
          ),
        );
      }
      return TransitionSuccess(
        KycUpgrading(
          currentTier: state.currentTier,
          targetTier: state.targetTier,
          currentStep: nextStep,
          collectedData: {...?state.collectedData, ...event.stepData},
        ),
      );
    }
    if (event is KycPreviousStep) {
      final prevStep = _getPreviousStep(state.currentStep);
      if (prevStep == null) {
        // Return to verified state with current tier
        return TransitionSuccess(
          KycVerified(
            tier: state.currentTier,
            verifiedAt: DateTime.now(),
            nextTier: state.currentTier < KycTier.tier2 ? KycTier.tier2 : null,
          ),
        );
      }
      return TransitionSuccess(
        KycUpgrading(
          currentTier: state.currentTier,
          targetTier: state.targetTier,
          currentStep: prevStep,
          collectedData: state.collectedData,
        ),
      );
    }
    if (event is KycSubmit) {
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/submit')],
      );
    }
    if (event is KycSubmitted) {
      return TransitionSuccess(
        KycPending(
          targetTier: state.targetTier,
          submittedAt: DateTime.now(),
        ),
        effects: [
          const NavigateEffect('/kyc/submitted'),
          const NotifyEffect('KYC upgrade submitted for review', type: NotifyType.success),
        ],
      );
    }
    return const TransitionNotApplicable();
  }

  TransitionResult<KycState> _handleError(KycError state, KycEvent event) {
    if (event is KycFetch) {
      return TransitionSuccess(
        const KycLoading(),
        effects: [const FetchEffect('kyc/status')],
      );
    }
    return const TransitionNotApplicable();
  }

  KycStep? _getNextStep(KycStep current) {
    return switch (current) {
      KycStep.personalInfo => KycStep.documentType,
      KycStep.documentType => KycStep.documentCapture,
      KycStep.documentCapture => KycStep.selfie,
      KycStep.selfie => KycStep.review,
      KycStep.addressProof => KycStep.review,
      KycStep.review => null,
    };
  }

  KycStep? _getPreviousStep(KycStep current) {
    return switch (current) {
      KycStep.personalInfo => null,
      KycStep.documentType => KycStep.personalInfo,
      KycStep.documentCapture => KycStep.documentType,
      KycStep.selfie => KycStep.documentCapture,
      KycStep.addressProof => KycStep.selfie,
      KycStep.review => KycStep.selfie,
    };
  }
}
