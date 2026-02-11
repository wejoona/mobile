import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les modifications de paramètres sensibles.
class SettingsGuard extends GuardBase {
  static const _tag = 'SettingsGuard';
  final AppLogger _log = AppLogger(_tag);

  static const _sensitiveSettings = [
    'phone', 'email', 'pin', 'biometric', 'security',
    'withdrawal_address', 'notification_preferences',
  ];

  @override
  String get name => 'settings';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final setting = context.params['setting'] as String?;

    if (setting != null && _sensitiveSettings.contains(setting)) {
      final recentAuth = context.params['recentAuth'] as bool? ?? false;
      if (!recentAuth) {
        _log.debug('Settings guard: step-up required for $setting');
        return const GuardResult.redirect('/step-up-auth');
      }
    }

    return const GuardResult.allow();
  }
}

final settingsGuardProvider = Provider<SettingsGuard>((ref) {
  return SettingsGuard();
});
