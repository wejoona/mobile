import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';

/// Referral Code Provider with TTL-based caching
/// Cache duration: 1 hour (referral code rarely changes)
final referralCodeProvider = FutureProvider<String>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 1 hour
  Timer(const Duration(hours: 1), () {
    link.close();
  });

  return service.getReferralCode();
});

/// Referral Stats Provider with TTL-based caching
/// Cache duration: 2 minutes (stats update relatively slowly)
final referralStatsProvider =
    FutureProvider<ReferralStats>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 2 minutes
  Timer(const Duration(minutes: 2), () {
    link.close();
  });

  return service.getStats();
});

/// Referral History Provider with TTL-based caching
/// Cache duration: 5 minutes (history doesn't change frequently)
final referralHistoryProvider =
    FutureProvider<List<Referral>>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  Timer(const Duration(minutes: 5), () {
    link.close();
  });

  return service.getHistory();
});

/// Leaderboard Provider with TTL-based caching
/// Cache duration: 5 minutes (leaderboard updates periodically)
final leaderboardProvider =
    FutureProvider<List<LeaderboardEntry>>((ref) async {
  final service = ref.watch(referralsServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes
  Timer(const Duration(minutes: 5), () {
    link.close();
  });

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
