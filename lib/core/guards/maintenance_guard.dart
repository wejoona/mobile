import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Blocks actions during maintenance windows.
class MaintenanceGuard extends GuardBase {
  static const _tag = 'MaintenanceGuard';
  final AppLogger _log = AppLogger(_tag);
  bool _maintenanceMode = false;
  String? _maintenanceMessage;

  @override
  String get name => 'maintenance';

  void setMaintenanceMode(bool active, {String? message}) {
    _maintenanceMode = active;
    _maintenanceMessage = message;
  }

  @override
  Future<GuardResult> check(GuardContext context) async {
    if (_maintenanceMode) {
      return GuardResult.deny(
        _maintenanceMessage ?? 'Service temporairement indisponible pour maintenance',
      );
    }
    return const GuardResult.allow();
  }
}

final maintenanceGuardProvider = Provider<MaintenanceGuard>((ref) {
  return MaintenanceGuard();
});
