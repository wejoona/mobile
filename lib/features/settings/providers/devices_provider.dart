import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import '../models/device.dart';
import '../repositories/devices_repository.dart';

/// State for devices management
class DevicesState {
  final bool isLoading;
  final String? error;
  final List<Device> devices;
  final String? currentDeviceId;

  const DevicesState({
    this.isLoading = false,
    this.error,
    this.devices = const [],
    this.currentDeviceId,
  });

  DevicesState copyWith({
    bool? isLoading,
    String? error,
    List<Device>? devices,
    String? currentDeviceId,
  }) {
    return DevicesState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      devices: devices ?? this.devices,
      currentDeviceId: currentDeviceId ?? this.currentDeviceId,
    );
  }
}

/// Notifier for managing devices
class DevicesNotifier extends Notifier<DevicesState> {
  @override
  DevicesState build() {
    _loadDevices();
    _identifyCurrentDevice();
    return const DevicesState();
  }

  /// Load all devices
  Future<void> _loadDevices() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repository = ref.read(devicesRepositoryProvider);
      final devices = await repository.getDevices();
      state = state.copyWith(isLoading: false, devices: devices);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refresh devices list
  Future<void> refresh() async {
    await _loadDevices();
  }

  /// Identify the current device
  Future<void> _identifyCurrentDevice() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String? deviceId;

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      }

      if (deviceId != null) {
        state = state.copyWith(currentDeviceId: deviceId);
      }
    } catch (e) {
      // Silently fail - not critical
    }
  }

  /// Trust a device
  Future<void> trustDevice(String deviceId) async {
    try {
      final repository = ref.read(devicesRepositoryProvider);
      final updatedDevice = await repository.trustDevice(deviceId);

      // Update the device in the list
      final updatedDevices = state.devices.map((device) {
        return device.id == deviceId ? updatedDevice : device;
      }).toList();

      state = state.copyWith(devices: updatedDevices);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Revoke a device
  Future<void> revokeDevice(String deviceId) async {
    try {
      final repository = ref.read(devicesRepositoryProvider);
      await repository.revokeDevice(deviceId);

      // Remove the device from the list
      final updatedDevices =
          state.devices.where((device) => device.id != deviceId).toList();

      state = state.copyWith(devices: updatedDevices);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// Check if a device is the current device
  bool isCurrentDevice(Device device) {
    return device.deviceIdentifier == state.currentDeviceId;
  }
}

/// Provider for devices state
final devicesProvider = NotifierProvider<DevicesNotifier, DevicesState>(
  DevicesNotifier.new,
);
