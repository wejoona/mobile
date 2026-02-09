import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/api_client.dart';
import '../services/kyc/kyc_service.dart';
import '../features/kyc/models/kyc_status.dart';
import 'fsm/fsm_provider.dart';
import 'fsm/kyc_fsm.dart';

/// KYC State for the state machine
class KycStateMachineState {
  final KycStatus status;
  final String? rejectionReason;
  final bool isLoading;
  final String? error;

  const KycStateMachineState({
    this.status = KycStatus.pending,
    this.rejectionReason,
    this.isLoading = false,
    this.error,
  });

  KycStateMachineState copyWith({
    KycStatus? status,
    String? rejectionReason,
    bool? isLoading,
    String? error,
  }) {
    return KycStateMachineState(
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// KYC State Machine - manages KYC status globally
class KycStateMachine extends Notifier<KycStateMachineState> {
  @override
  KycStateMachineState build() {
    return const KycStateMachineState();
  }

  KycService get _service => ref.read(kycServiceProvider);

  /// Map API status string to FSM status string
  String _mapToFsmStatus(String apiStatus) {
    // API returns: none, pending, documents_pending, submitted, verified, rejected
    // FSM expects: none, pending, verified, rejected, expired, manual_review
    //
    // Mapping:
    // - "none" = never started → 'none' (should show KYC screen)
    // - "documents_pending" = needs to submit docs → 'none' (should show KYC screen)
    // - "pending" = user has status but not verified → 'none' for new signup flow
    // - "submitted" = submitted, awaiting review → 'pending' (can proceed to wallet)
    // - "verified" / "approved" = verified → 'verified'
    // - "rejected" = rejected → 'rejected'
    switch (apiStatus.toLowerCase()) {
      case 'none':
      case 'documents_pending':
      case 'pending': // New signups have "pending" status, need KYC
        return 'none';
      case 'submitted':
      case 'in_review':
        return 'pending';
      case 'verified':
      case 'approved':
        return 'verified';
      case 'rejected':
        return 'rejected';
      case 'expired':
        return 'expired';
      case 'manual_review':
        return 'manual_review';
      default:
        debugPrint('[KycStateMachine] Unknown status: $apiStatus, defaulting to none');
        return 'none';
    }
  }

  /// Fetch KYC status from API
  Future<void> fetch() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true);

    try {
      final response = await _service.getKycStatus();

      state = state.copyWith(
        status: response.status,
        rejectionReason: response.rejectionReason,
        isLoading: false,
        error: null,
      );

      // Sync with FSM: notify KYC status loaded
      final fsmStatus = _mapToFsmStatus(response.status.name);
      ref.read(appFsmProvider.notifier).onKycStatusLoaded(
        tier: _getTierFromStatus(response.status),
        status: fsmStatus,
        rejectionReason: response.rejectionReason,
      );
    } on ApiException catch (e) {
      debugPrint('[KycStateMachine] API error: ${e.message}');
      state = state.copyWith(
        isLoading: false,
        error: e.message,
      );

      // If 404 or similar, treat as "none" (no KYC submitted)
      if (e.statusCode == 404) {
        ref.read(appFsmProvider.notifier).onKycStatusLoaded(
          tier: KycTier.none,
          status: 'none',
        );
      }
    } catch (e) {
      debugPrint('[KycStateMachine] Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update KYC status directly (e.g., from auth response)
  void updateFromAuthResponse(String? kycStatus) {
    if (kycStatus == null) return;

    debugPrint('[KycStateMachine] Updating from auth response: $kycStatus');

    final status = KycStatus.fromString(kycStatus);
    state = state.copyWith(
      status: status,
      isLoading: false,
    );

    // Sync with FSM
    final fsmStatus = _mapToFsmStatus(kycStatus);
    ref.read(appFsmProvider.notifier).onKycStatusLoaded(
      tier: _getTierFromStatus(status),
      status: fsmStatus,
    );
  }

  /// Get KYC tier from status
  KycTier _getTierFromStatus(KycStatus status) {
    switch (status) {
      case KycStatus.verified:
        return KycTier.tier1;
      default:
        return KycTier.none;
    }
  }

  /// Reset state (on logout)
  void reset() {
    state = const KycStateMachineState();
  }
}

final kycStateMachineProvider =
    NotifierProvider<KycStateMachine, KycStateMachineState>(
  KycStateMachine.new,
);

/// Convenience providers
final kycMachineStatusProvider = Provider<KycStatus>((ref) {
  return ref.watch(kycStateMachineProvider).status;
});

final isKycMachineLoadingProvider = Provider<bool>((ref) {
  return ref.watch(kycStateMachineProvider).isLoading;
});

/// Provider for KycService
final kycServiceProvider = Provider<KycService>((ref) {
  return KycService(ref.watch(dioProvider));
});
