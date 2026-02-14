import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Anonymizes user data for analytics and reporting.
class AnonymizationService {
  static const _tag = 'Anonymize';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Anonymize a user record for analytics.
  Map<String, dynamic> anonymize(Map<String, dynamic> record) {
    final anon = Map<String, dynamic>.from(record);
    anon.remove('name');
    anon.remove('email');
    anon.remove('phone');
    anon.remove('address');
    if (anon.containsKey('userId')) {
      anon['userId'] = _hash(anon['userId'] as String);
    }
    return anon;
  }

  String _hash(String value) {
    var hash = 0;
    for (var i = 0; i < value.length; i++) {
      hash = ((hash << 5) - hash) + value.codeUnitAt(i);
      hash = hash & 0xFFFFFFFF;
    }
    return 'anon_${hash.toRadixString(16)}';
  }
}

final anonymizationServiceProvider = Provider<AnonymizationService>((ref) {
  return AnonymizationService();
});
