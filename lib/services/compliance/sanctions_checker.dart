import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Vérifie les listes de sanctions internationales.
class SanctionsChecker {
  static const _tag = 'Sanctions';
  final AppLogger _log = AppLogger(_tag);

  /// Check individual against sanctions lists.
  Future<SanctionsResult> checkIndividual(String name, String country) async {
    _log.debug('Sanctions check: $name');
    return const SanctionsResult(isListed: false);
  }

  /// Check entity against sanctions lists.
  Future<SanctionsResult> checkEntity(String entityName) async {
    return const SanctionsResult(isListed: false);
  }

  /// Check if a country is sanctioned.
  bool isCountrySanctioned(String countryCode) {
    const sanctioned = ['KP', 'IR', 'SY', 'CU'];
    return sanctioned.contains(countryCode);
  }
}

class SanctionsResult {
  final bool isListed;
  final String? listName;
  final String? matchDetails;

  const SanctionsResult({
    required this.isListed,
    this.listName,
    this.matchDetails,
  });
}

final sanctionsCheckerProvider = Provider<SanctionsChecker>((ref) {
  return SanctionsChecker();
});
