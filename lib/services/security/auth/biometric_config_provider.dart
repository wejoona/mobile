import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Configuration biométrique de l'appareil.
class BiometricConfig {
  final bool isFaceIdAvailable;
  final bool isTouchIdAvailable;
  final bool isEnrolled;
  final DateTime? lastEnrollmentCheck;

  const BiometricConfig({
    this.isFaceIdAvailable = false,
    this.isTouchIdAvailable = false,
    this.isEnrolled = false,
    this.lastEnrollmentCheck,
  });

  BiometricConfig copyWith({
    bool? isFaceIdAvailable,
    bool? isTouchIdAvailable,
    bool? isEnrolled,
    DateTime? lastEnrollmentCheck,
  }) {
    return BiometricConfig(
      isFaceIdAvailable: isFaceIdAvailable ?? this.isFaceIdAvailable,
      isTouchIdAvailable: isTouchIdAvailable ?? this.isTouchIdAvailable,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      lastEnrollmentCheck: lastEnrollmentCheck ?? this.lastEnrollmentCheck,
    );
  }
}

class BiometricConfigNotifier extends StateNotifier<BiometricConfig> {
  static const _tag = 'BiometricConfig';
  final AppLogger _log = AppLogger(_tag);

  BiometricConfigNotifier() : super(const BiometricConfig());

  Future<void> refresh() async {
    _log.debug('Refreshing biometric config');
    // Platform channel call in production
    state = state.copyWith(
      isFaceIdAvailable: true,
      isEnrolled: true,
      lastEnrollmentCheck: DateTime.now(),
    );
  }

  bool get hasAnyBiometric =>
      state.isFaceIdAvailable || state.isTouchIdAvailable;
}

final biometricConfigProvider =
    StateNotifierProvider<BiometricConfigNotifier, BiometricConfig>((ref) {
  return BiometricConfigNotifier();
});
