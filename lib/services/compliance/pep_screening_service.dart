import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Screening against Politically Exposed Persons (PEP) lists.
class PepScreeningService {
  static const _tag = 'PepScreen';
  final AppLogger _log = AppLogger(_tag);

  /// Screen a name against PEP databases.
  Future<PepScreenResult> screen(String fullName, String countryCode) async {
    _log.debug('PEP screening: $fullName ($countryCode)');
    // Would call compliance API
    return PepScreenResult(isMatch: false, score: 0);
  }

  /// Screen a batch of names.
  Future<List<PepScreenResult>> screenBatch(List<String> names, String countryCode) async {
    return names.map((n) => PepScreenResult(isMatch: false, score: 0)).toList();
  }
}

class PepScreenResult {
  final bool isMatch;
  final double score;
  final String? matchedName;
  final String? category;

  const PepScreenResult({
    required this.isMatch,
    required this.score,
    this.matchedName,
    this.category,
  });
}

final pepScreeningServiceProvider = Provider<PepScreeningService>((ref) {
  return PepScreeningService();
});
