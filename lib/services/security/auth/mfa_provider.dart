import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Supported MFA methods.
enum MfaMethod { sms, totp, biometric, email }

/// State of MFA enrollment and verification.
class MfaState {
  final List<MfaMethod> enrolledMethods;
  final MfaMethod? preferredMethod;
  final bool isVerified;
  final DateTime? lastVerifiedAt;

  const MfaState({
    this.enrolledMethods = const [],
    this.preferredMethod,
    this.isVerified = false,
    this.lastVerifiedAt,
  });

  MfaState copyWith({
    List<MfaMethod>? enrolledMethods,
    MfaMethod? preferredMethod,
    bool? isVerified,
    DateTime? lastVerifiedAt,
  }) {
    return MfaState(
      enrolledMethods: enrolledMethods ?? this.enrolledMethods,
      preferredMethod: preferredMethod ?? this.preferredMethod,
      isVerified: isVerified ?? this.isVerified,
      lastVerifiedAt: lastVerifiedAt ?? this.lastVerifiedAt,
    );
  }
}

/// Manages multi-factor authentication enrollment and verification.
class MfaProvider extends StateNotifier<MfaState> {
  static const _tag = 'MfaProvider';
  final AppLogger _log = AppLogger(_tag);

  MfaProvider() : super(const MfaState());

  /// Enroll a new MFA method.
  Future<bool> enroll(MfaMethod method) async {
    if (state.enrolledMethods.contains(method)) return true;
    _log.debug('Enrolling MFA method: $method');
    // Would call backend to initiate enrollment
    state = state.copyWith(
      enrolledMethods: [...state.enrolledMethods, method],
      preferredMethod: state.preferredMethod ?? method,
    );
    return true;
  }

  /// Verify MFA challenge.
  Future<bool> verify(MfaMethod method, String code) async {
    _log.debug('Verifying MFA: $method');
    // Would call backend to verify
    state = state.copyWith(
      isVerified: true,
      lastVerifiedAt: DateTime.now(),
    );
    return true;
  }

  /// Check if MFA verification is still valid within [duration].
  bool isRecentlyVerified({Duration duration = const Duration(minutes: 5)}) {
    if (state.lastVerifiedAt == null) return false;
    return DateTime.now().difference(state.lastVerifiedAt!) < duration;
  }

  /// Unenroll a method.
  void unenroll(MfaMethod method) {
    state = state.copyWith(
      enrolledMethods:
          state.enrolledMethods.where((m) => m != method).toList(),
    );
  }

  void resetVerification() {
    state = state.copyWith(isVerified: false);
  }
}

final mfaProvider = StateNotifierProvider<MfaProvider, MfaState>((ref) {
  return MfaProvider();
});
