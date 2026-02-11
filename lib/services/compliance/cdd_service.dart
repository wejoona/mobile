import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Customer Due Diligence (CDD) service.
class CddService {
  static const _tag = 'CDD';
  final AppLogger _log = AppLogger(_tag);

  /// Determine required CDD level based on risk.
  CddLevel determineLevel(double riskScore) {
    if (riskScore >= 80) return CddLevel.enhanced;
    if (riskScore >= 40) return CddLevel.standard;
    return CddLevel.simplified;
  }

  /// Check if CDD is up to date.
  bool isCddCurrent(DateTime? lastCddDate) {
    if (lastCddDate == null) return false;
    return DateTime.now().difference(lastCddDate) < const Duration(days: 365);
  }

  /// Request additional CDD documents.
  Future<void> requestDocuments(String userId, CddLevel level) async {
    _log.debug('Requesting CDD documents for user: level=${level.name}');
  }
}

enum CddLevel { simplified, standard, enhanced }

final cddServiceProvider = Provider<CddService>((ref) {
  return CddService();
});
