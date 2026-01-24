import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';

/// Referral Code Provider
final referralCodeProvider = FutureProvider.autoDispose<String>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  return service.getReferralCode();
});

/// Referral Stats Provider
final referralStatsProvider =
    FutureProvider.autoDispose<ReferralStats>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  return service.getStats();
});

/// Referral History Provider
final referralHistoryProvider =
    FutureProvider.autoDispose<List<Referral>>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  return service.getHistory();
});

/// Leaderboard Provider
final leaderboardProvider =
    FutureProvider.autoDispose<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  return service.getLeaderboard();
});

/// Apply Referral State
class ApplyReferralState {
  final bool isLoading;
  final bool success;
  final String? message;
  final String? error;

  const ApplyReferralState({
    this.isLoading = false,
    this.success = false,
    this.message,
    this.error,
  });

  ApplyReferralState copyWith({
    bool? isLoading,
    bool? success,
    String? message,
    String? error,
  }) {
    return ApplyReferralState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      message: message ?? this.message,
      error: error,
    );
  }
}

/// Apply Referral Notifier
class ApplyReferralNotifier extends Notifier<ApplyReferralState> {
  @override
  ApplyReferralState build() {
    return const ApplyReferralState();
  }

  ReferralsService get _service => ref.read(referralsServiceProvider);

  Future<bool> apply(String code) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.applyReferralCode(code);

      state = state.copyWith(
        isLoading: false,
        success: response.success,
        message: response.message,
      );

      return response.success;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const ApplyReferralState();
  }
}

final applyReferralProvider =
    NotifierProvider.autoDispose<ApplyReferralNotifier, ApplyReferralState>(
  ApplyReferralNotifier.new,
);
