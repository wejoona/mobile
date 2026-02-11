import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour la connexion - vérifie les conditions de login.
class LoginGuard extends GuardBase {
  static const _tag = 'LoginGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'login';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final isLocked = context.params['isLocked'] as bool? ?? false;
    if (isLocked) {
      return const GuardResult.deny('Compte temporairement verrouillé');
    }

    final failedAttempts = context.params['failedAttempts'] as int? ?? 0;
    if (failedAttempts >= 5) {
      return const GuardResult.deny('Trop de tentatives échouées. Réessayez plus tard.');
    }

    final deviceBound = context.params['deviceBound'] as bool? ?? true;
    if (!deviceBound) {
      return const GuardResult.redirect('/device-verification');
    }

    _log.debug('Login guard passed');
    return const GuardResult.allow();
  }
}

final loginGuardProvider = Provider<LoginGuard>((ref) {
  return LoginGuard();
});
