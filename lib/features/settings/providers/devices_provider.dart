import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';

/// Registered devices provider — wired to GET /devices.
final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final repository = ref.watch(devicesRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());
  return repository.getDevices();
});

/// Local device identifier (vendor ID on iOS, android.id on Android).
final localDeviceIdProvider = FutureProvider<String>((ref) async {
  final info = DeviceInfoPlugin();
  if (Platform.isIOS) {
    final ios = await info.iosInfo;
    return ios.identifierForVendor ?? '';
  } else if (Platform.isAndroid) {
    final android = await info.androidInfo;
    return android.id;
  }
  return '';
});

/// Current device — match by deviceIdentifier (iOS vendorId / Android id).
final currentDeviceProvider = Provider<Device?>((ref) {
  final devices = ref.watch(devicesProvider).value ?? [];
  final localId = ref.watch(localDeviceIdProvider).value ?? '';
  try {
    return devices.firstWhere(
      (d) =>
          d.isCurrent || (localId.isNotEmpty && d.deviceIdentifier == localId),
    );
  } catch (_) {
    return null;
  }
});

/// Device actions.
class DeviceActions {
  final DevicesRepository _repository;
  final Ref _ref;
  DeviceActions(this._repository, this._ref);

  Future<void> revokeDevice(String deviceId) async {
    await _repository.revokeDevice(deviceId);
    _ref.invalidate(devicesProvider);
  }

  Future<void> renameDevice(String deviceId, String name) async {
    await _repository.renameDevice(deviceId, name);
    _ref.invalidate(devicesProvider);
  }

  Future<void> refresh() async {
    _ref.invalidate(devicesProvider);
  }

  Future<void> trustDevice(String deviceId) async {
    await _repository.trustDevice(deviceId);
    _ref.invalidate(devicesProvider);
  }

  Future<void> untrustDevice(String deviceId) async {
    await _repository.untrustDevice(deviceId);
    _ref.invalidate(devicesProvider);
  }

  Future<void> revokeOtherDevices(List<Device> devices, String localId) async {
    for (final device in devices) {
      final isCurrent =
          device.isCurrent ||
          (localId.isNotEmpty && device.deviceIdentifier == localId);
      if (!isCurrent) {
        await _repository.revokeDevice(device.id);
      }
    }
    _ref.invalidate(devicesProvider);
  }
}

final deviceActionsProvider = Provider<DeviceActions>((ref) {
  return DeviceActions(ref.watch(devicesRepositoryProvider), ref);
});

/// Adapter: wraps raw list into DevicesState for views.
final devicesStateProvider = Provider<DevicesState>((ref) {
  final async = ref.watch(devicesProvider);
  return DevicesState(
    isLoading: async.isLoading,
    error: async.error?.toString(),
    devices: async.value ?? [],
  );
});
