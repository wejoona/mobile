import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Registered devices provider — wired to GET /devices.
final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 5), () => link.close());

  final response = await dio.get('/devices');
  // Backend may return {data: [...]} or [...] directly
  final raw = response.data;
  final List items;
  if (raw is Map<String, dynamic>) {
    items = raw['data'] as List? ?? [];
  } else if (raw is List) {
    items = raw;
  } else {
    items = [];
  }
  return items.map((e) => Device.fromJson(e as Map<String, dynamic>)).toList();
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
    return devices.firstWhere((d) =>
        d.isCurrent ||
        (localId.isNotEmpty && d.deviceIdentifier == localId));
  } catch (_) {
    return null;
  }
});

/// Device actions.
class DeviceActions {
  final dynamic _dio;
  final Ref _ref;
  DeviceActions(this._dio, this._ref);

  Future<void> revokeDevice(String deviceId) async {
    // ignore: avoid_dynamic_calls
    await _dio.delete('/devices/$deviceId');
    _ref.invalidate(devicesProvider);
  }

  Future<void> renameDevice(String deviceId, String name) async {
    // ignore: avoid_dynamic_calls
    await _dio.post('/devices/$deviceId/rename', data: {'name': name});
    _ref.invalidate(devicesProvider);
  }

  Future<void> refresh() async {
    _ref.invalidate(devicesProvider);
  }

  Future<void> trustDevice(String deviceId) async {
    // ignore: avoid_dynamic_calls
    await _dio.post('/devices/$deviceId/trust');
    _ref.invalidate(devicesProvider);
  }
}

final deviceActionsProvider = Provider<DeviceActions>((ref) {
  return DeviceActions(ref.watch(dioProvider), ref);
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
