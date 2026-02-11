import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Binds a user account to a specific device to prevent cloning.
class DeviceBindingService {
  static const _tag = 'DeviceBinding';
  final AppLogger _log = AppLogger(_tag);

  String? _boundDeviceId;

  /// Bind the current device.
  Future<bool> bindDevice(String deviceId, String userId) async {
    _log.debug('Binding device $deviceId for user $userId');
    _boundDeviceId = deviceId;
    return true;
  }

  /// Check if the current device matches the bound device.
  bool isDeviceBound(String currentDeviceId) {
    if (_boundDeviceId == null) return false;
    return _boundDeviceId == currentDeviceId;
  }

  /// Unbind device (e.g., during device transfer).
  Future<void> unbind() async {
    _log.debug('Unbinding device');
    _boundDeviceId = null;
  }

  /// Request device transfer approval from backend.
  Future<bool> requestTransfer(String newDeviceId) async {
    _log.debug('Requesting transfer to $newDeviceId');
    // Would call backend for approval
    return true;
  }
}

final deviceBindingServiceProvider = Provider<DeviceBindingService>((ref) {
  return DeviceBindingService();
});
