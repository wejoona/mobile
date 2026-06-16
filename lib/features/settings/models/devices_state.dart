import 'package:usdc_wallet/domain/entities/device.dart';

class DevicesState {
  final bool isLoading;
  final String? error;
  final List<Device> devices;
  final bool requiresUnlock;

  const DevicesState({
    this.isLoading = false,
    this.error,
    this.devices = const [],
    this.requiresUnlock = false,
  });
}
