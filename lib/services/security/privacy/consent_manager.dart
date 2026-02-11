import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Gestion du consentement utilisateur.
class ConsentManager {
  static const _tag = 'Consent';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, bool> _consents = {};

  void grantConsent(String purpose) {
    _consents[purpose] = true;
    _log.debug('Consent granted: $purpose');
  }

  void revokeConsent(String purpose) {
    _consents[purpose] = false;
    _log.debug('Consent revoked: $purpose');
  }

  bool hasConsent(String purpose) => _consents[purpose] ?? false;

  Map<String, bool> get allConsents => Map.unmodifiable(_consents);
}

final consentManagerProvider = Provider<ConsentManager>((ref) {
  return ConsentManager();
});
