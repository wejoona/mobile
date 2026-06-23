import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/device.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/settings/models/devices_state.dart';
import 'package:usdc_wallet/features/settings/repositories/devices_repository.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Registered devices provider — wired to GET /devices.
final devicesProvider = FutureProvider<List<Device>>((ref) async {
  final authReady = await _ensureAuthenticatedForDeviceRead(ref);
  if (!authReady) {
    return const <Device>[];
  }

  final repository = ref.watch(devicesRepositoryProvider);
  final link = ref.keepAlive();
  final timer = Timer(const Duration(minutes: 5), () => link.close());
  ref.onDispose(() => timer.cancel());
  try {
    return await repository.getDevices();
  } on ApiException catch (e) {
    if (e.isDeviceBlacklisted) {
      await ref.read(authProvider.notifier).clearLocalSession();
    } else if (e.statusCode == 401) {
      final refreshed = await ref
          .read(authProvider.notifier)
          .refreshAccessTokenForForegroundRequest();
      if (ref.mounted && refreshed) {
        try {
          return await repository.getDevices();
        } on ApiException catch (retryError) {
          if (retryError.isDeviceBlacklisted) {
            await ref.read(authProvider.notifier).clearLocalSession();
          } else if (retryError.statusCode == 401) {
            await ref.read(authProvider.notifier).setLocked();
          }
          throw retryError;
        }
      }
      if (ref.mounted) {
        await ref.read(authProvider.notifier).setLocked();
      }
    }
    rethrow;
  }
});

Future<bool> _ensureAuthenticatedForDeviceRead(Ref ref) async {
  var authState = ref.read(authProvider);
  if (authState.status == AuthStatus.initial ||
      authState.status == AuthStatus.loading) {
    await ref.read(authProvider.notifier).checkAuth();
    if (!ref.mounted) {
      return false;
    }
    authState = ref.read(authProvider);
  }

  return authState.isAuthenticated;
}

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
    await _runDeviceAction(() => _repository.revokeDevice(deviceId));
  }

  Future<void> renameDevice(String deviceId, String name) async {
    await _runDeviceAction(() => _repository.renameDevice(deviceId, name));
  }

  Future<void> refresh() async {
    _ref.invalidate(devicesProvider);
  }

  Future<void> trustDevice(String deviceId) async {
    await _runDeviceAction(() => _repository.trustDevice(deviceId));
  }

  Future<void> untrustDevice(String deviceId) async {
    await _runDeviceAction(() => _repository.untrustDevice(deviceId));
  }

  Future<void> revokeOtherDevices(List<Device> devices, String localId) async {
    await _runDeviceAction(() async {
      final currentDeviceResolved = devices.any(
        (device) =>
            device.isCurrent ||
            (localId.isNotEmpty && device.deviceIdentifier == localId),
      );
      if (!currentDeviceResolved) {
        throw StateError('Current device could not be resolved.');
      }

      for (final device in devices) {
        final isCurrent =
            device.isCurrent ||
            (localId.isNotEmpty && device.deviceIdentifier == localId);
        if (!isCurrent) {
          await _repository.revokeDevice(device.id);
        }
      }
    });
  }

  Future<void> _runDeviceAction(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (e) {
      await _handleApiActionError(e);
      rethrow;
    }
    _ref.invalidate(devicesProvider);
  }

  Future<void> _handleApiActionError(ApiException error) async {
    if (error.isDeviceBlacklisted) {
      await _ref.read(authProvider.notifier).clearLocalSession();
    } else if (error.statusCode == 401) {
      await _ref.read(authProvider.notifier).setLocked();
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
  final authState = ref.watch(authProvider);
  final error = async.error;
  final requiresUnlock =
      authState.isLocked || (error is ApiException && error.statusCode == 401);
  return DevicesState(
    isLoading: async.isLoading,
    error: requiresUnlock ? null : _friendlyDeviceError(error),
    devices: async.value ?? [],
    requiresUnlock: requiresUnlock,
  );
});

String? _friendlyDeviceError(Object? error) {
  if (error == null) return null;
  if (error is ApiException) {
    if (error.isDeviceBlacklisted) {
      return error.message;
    }
    if (error.statusCode == 401) return null;
    if (error.statusCode == 403) {
      return 'You do not have permission to manage devices right now.';
    }
    return error.message;
  }
  return 'Unable to load devices. Please try again.';
}
