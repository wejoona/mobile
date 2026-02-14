import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Validates source of funds declarations.
class SourceOfFundsValidator {
  static const _tag = 'SofValidator';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  static const validSources = [
    'salary', 'business', 'savings', 'investment',
    'inheritance', 'gift', 'pension', 'other',
  ];

  /// Validate a source of funds declaration.
  SofValidationResult validate({
    required String source,
    required double amount,
    String? documentation,
  }) {
    if (!validSources.contains(source)) {
      return SofValidationResult(valid: false, reason: 'Source invalide');
    }

    // Amounts over threshold require documentation
    if (amount > 1000000 && documentation == null) {
      return SofValidationResult(
        valid: false,
        reason: 'Justificatif requis pour les montants supérieurs à 1 000 000 FCFA',
      );
    }

    return SofValidationResult(valid: true);
  }
}

class SofValidationResult {
  final bool valid;
  final String? reason;
  const SofValidationResult({required this.valid, this.reason});
}

final sourceOfFundsValidatorProvider = Provider<SourceOfFundsValidator>((ref) {
  return SourceOfFundsValidator();
});
