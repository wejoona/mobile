import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'send_limits_provider.dart';
import 'send_fee_provider.dart';

/// Run 353: Comprehensive send validation provider
class SendValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const SendValidationResult({
    this.isValid = true,
    this.errors = const [],
    this.warnings = const [],
  });

  factory SendValidationResult.error(String message) =>
      SendValidationResult(isValid: false, errors: [message]);

  factory SendValidationResult.valid({List<String> warnings = const []}) =>
      SendValidationResult(isValid: true, warnings: warnings);
}

class SendValidationParams {
  final double amount;
  final String? recipientId;
  final String? recipientAddress;
  final double availableBalance;

  const SendValidationParams({
    required this.amount,
    this.recipientId,
    this.recipientAddress,
    required this.availableBalance,
  });
}

final sendValidationProvider =
    Provider.family<SendValidationResult, SendValidationParams>((ref, params) {
  final errors = <String>[];
  final warnings = <String>[];

  // Amount validation
  if (params.amount <= 0) {
    errors.add('Le montant doit etre superieur a zero');
  }

  if (params.amount > params.availableBalance) {
    errors.add('Solde insuffisant');
  }

  // Recipient validation
  if (params.recipientId == null && params.recipientAddress == null) {
    errors.add('Veuillez selectionner un destinataire');
  }

  // Minimum amount
  if (params.amount > 0 && params.amount < 0.01) {
    errors.add('Le montant minimum est de 0.01 USDC');
  }

  // Warnings for large amounts
  if (params.amount > 200) {
    warnings.add('Montant eleve - verification PIN requise');
  }

  if (params.amount > params.availableBalance * 0.9) {
    warnings.add('Ce transfert utilisera plus de 90% de votre solde');
  }

  return SendValidationResult(
    isValid: errors.isEmpty,
    errors: errors,
    warnings: warnings,
  );
});
