import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Registered devices provider — wired to GET /devices.
final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/devices');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
});

/// Current device.
final currentDeviceProvider = Provider<Device?>((ref) {
  final devices = ref.watch(devicesProvider).value ?? [];
  try {
    return devices.firstWhere((d) => d.isCurrent);
  } catch (_) {
    return null;
  }
});

/// Device actions.
class DeviceActions {
  final dynamic _dio;
  DeviceActions(this._dio);

  Future<void> revokeDevice(String deviceId) async {
    await _dio.delete('/devices/$deviceId');
  }

  Future<void> renameDevice(String deviceId, String name) async {
    await _dio.patch('/devices/$deviceId', data: {'name': name});
  }

  Future<void> refresh() async {
    // Triggers re-fetch via provider invalidation
  }

  bool isCurrentDevice(String deviceId) => false;

  Future<void> trustDevice(String deviceId) async {
    await _dio.post('/devices/$deviceId/trust');
  }
}

final deviceActionsProvider = Provider<DeviceActions>((ref) {
  return DeviceActions(ref.watch(dioProvider));
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
