import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Filtre de sécurité pour les notifications push.
class NotificationSecurityFilter {
  static const _tag = 'NotifFilter';
  final AppLogger _log = AppLogger(_tag);

  /// Validate notification origin.
  bool isFromTrustedSource(Map<String, dynamic> notification) {
    return notification.containsKey('signature');
  }

  /// Strip sensitive data from notification display.
  Map<String, dynamic> sanitizeForDisplay(Map<String, dynamic> notification) {
    final sanitized = Map<String, dynamic>.from(notification);
    sanitized.remove('accountNumber');
    sanitized.remove('balance');
    // Masquer le montant dans la notification
    if (sanitized.containsKey('amount')) {
      sanitized['amount'] = '***';
    }
    return sanitized;
  }

  /// Check if notification should be shown on lock screen.
  bool allowOnLockScreen(Map<String, dynamic> notification) {
    final category = notification['category'] as String?;
    return category != 'transaction' && category != 'security';
  }
}

final notificationSecurityFilterProvider = Provider<NotificationSecurityFilter>((ref) {
  return NotificationSecurityFilter();
});
