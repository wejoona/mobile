import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Classifie les transactions selon les catégories BCEAO.
enum BceaoCategory {
  transfertDomestique,
  transfertUemoa,
  transfertInternational,
  paiementMarchand,
  retraitEspeces,
  depotEspeces,
  achatCredit,
}

class BceaoTransactionClassifier {
  static const _tag = 'BceaoClassifier';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Classify a transaction for BCEAO reporting.
  BceaoCategory classify({
    required String type,
    required String? destinationCountry,
    required double amount,
  }) {
    if (type == 'withdrawal') return BceaoCategory.retraitEspeces;
    if (type == 'deposit') return BceaoCategory.depotEspeces;
    if (type == 'merchant') return BceaoCategory.paiementMarchand;

    if (destinationCountry == null || destinationCountry == 'CI') {
      return BceaoCategory.transfertDomestique;
    }

    const uemoaCountries = ['BJ', 'BF', 'CI', 'GW', 'ML', 'NE', 'SN', 'TG'];
    if (uemoaCountries.contains(destinationCountry)) {
      return BceaoCategory.transfertUemoa;
    }

    return BceaoCategory.transfertInternational;
  }
}

final bceaoTransactionClassifierProvider = Provider<BceaoTransactionClassifier>((ref) {
  return BceaoTransactionClassifier();
});
