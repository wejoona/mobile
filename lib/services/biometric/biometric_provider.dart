import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';

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

/// Whether biometric authentication is enabled by the user.
final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  const storage = FlutterSecureStorage();
  final value = await storage.read(key: 'biometric_enabled');
  return value == 'true';
});

/// The primary biometric type available on the device.
final primaryBiometricTypeProvider = FutureProvider<BiometricType?>((ref) async {
  final service = ref.watch(biometricServiceProvider);
  final available = await service.isAvailable();
  if (!available) return null;
  return service.getAvailableType();
});

/// Biometric guard — convenience provider for biometric authentication checks.
final biometricGuardProvider = Provider<BiometricService>((ref) {
  return ref.watch(biometricServiceProvider);
});
