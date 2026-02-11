import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Cross-border transaction flag result.
class CrossBorderFlag {
  final bool isCrossBorder;
  final bool requiresDeclaration;
  final String? originCountry;
  final String? destinationCountry;
  final List<String> requiredDocuments;

  const CrossBorderFlag({
    required this.isCrossBorder,
    this.requiresDeclaration = false,
    this.originCountry,
    this.destinationCountry,
    this.requiredDocuments = const [],
  });
}

/// Detects and flags cross-border transactions for regulatory compliance.
///
/// UEMOA intra-zone transfers have different requirements from
/// extra-zone transfers. This service classifies accordingly.
class CrossBorderFlagger {
  static const _tag = 'CrossBorderFlagger';
  final AppLogger _log = AppLogger(_tag);

  /// UEMOA member country codes.
  static const _uemoaCountries = [
    'BJ', // Benin
    'BF', // Burkina Faso
    'CI', // Cote d'Ivoire
    'GW', // Guinee-Bissau
    'ML', // Mali
    'NE', // Niger
    'SN', // Senegal
    'TG', // Togo
  ];

  /// Flag a transaction based on origin and destination.
  CrossBorderFlag evaluate({
    required String originCountry,
    required String destinationCountry,
    required double amountCfa,
  }) {
    if (originCountry == destinationCountry) {
      return const CrossBorderFlag(isCrossBorder: false);
    }

    final isIntraUemoa = _uemoaCountries.contains(originCountry) &&
        _uemoaCountries.contains(destinationCountry);

    final docs = <String>[];
    bool requiresDeclaration = false;

    if (isIntraUemoa) {
      if (amountCfa >= 1000000) {
        requiresDeclaration = true;
        docs.add('Formulaire de transfert intra-UEMOA');
      }
    } else {
      requiresDeclaration = true;
      docs.add('Justificatif de transfert international');
      if (amountCfa >= 5000000) {
        docs.add('Declaration de change');
        docs.add('Piece d\'identite du beneficiaire');
      }
    }

    _log.debug('Cross-border: $originCountry -> $destinationCountry, '
        'intraUEMOA: $isIntraUemoa');

    return CrossBorderFlag(
      isCrossBorder: true,
      requiresDeclaration: requiresDeclaration,
      originCountry: originCountry,
      destinationCountry: destinationCountry,
      requiredDocuments: docs,
    );
  }

  /// Check if a country is in the UEMOA zone.
  bool isUemoaMember(String countryCode) {
    return _uemoaCountries.contains(countryCode.toUpperCase());
  }
}

final crossBorderFlaggerProvider = Provider<CrossBorderFlagger>((ref) {
  return CrossBorderFlagger();
});
