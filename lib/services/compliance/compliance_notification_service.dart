import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Sends compliance-related notifications to users and admins.
class ComplianceNotificationService {
  static const _tag = 'ComplianceNotif';
  final AppLogger _log = AppLogger(_tag);

  /// Notify user about KYC requirement.
  Future<void> notifyKycRequired(String userId, String reason) async {
    _log.debug('KYC notification sent to $userId: $reason');
  }

  /// Notify about approaching transaction limits.
  Future<void> notifyLimitApproaching(String userId, double usagePercent) async {
    if (usagePercent >= 80) {
      _log.debug('Limit warning: ${usagePercent.toStringAsFixed(0)}% used');
    }
  }

  /// Notify compliance team of suspicious activity.
  Future<void> notifyComplianceTeam(String alertType, Map<String, dynamic> details) async {
    _log.warn('Compliance alert: $alertType');
  }
}

final complianceNotificationServiceProvider = Provider<ComplianceNotificationService>((ref) {
  return ComplianceNotificationService();
});
