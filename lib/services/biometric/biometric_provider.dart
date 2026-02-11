import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'biometric_service.dart';

/// Run 373: Biometric authentication Riverpod providers
final biometricServiceProvider = Provider<BiometricService>((ref) {
  return BiometricService();
});

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isAvailable();
});

final biometricTypeProvider = FutureProvider<BiometricType>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.getAvailableType();
});

final biometricEnrolledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  return service.isEnrolled();
});
