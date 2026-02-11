import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Checks device integrity before sensitive operations.
class DeviceIntegrityGuard extends GuardBase {
  static const _tag = 'DeviceIntegrity';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'device_integrity';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final isRooted = context.params['isRooted'] as bool? ?? false;
    final isEmulator = context.params['isEmulator'] as bool? ?? false;
    final debuggerAttached = context.params['debuggerAttached'] as bool? ?? false;

    if (isRooted) {
      return const GuardResult.deny('Appareil rooté/jailbreaké détecté');
    }
    if (isEmulator) {
      return const GuardResult.deny('Émulateur détecté');
    }
    if (debuggerAttached) {
      _log.warn('Debugger attached');
      return const GuardResult.deny('Débogueur détecté');
    }
    return const GuardResult.allow();
  }
}

final deviceIntegrityGuardProvider = Provider<DeviceIntegrityGuard>((ref) {
  return DeviceIntegrityGuard();
});
