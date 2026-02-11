import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/providers/balance_provider.dart';

/// Validates send form before submission.
final sendValidationProvider = Provider.family<SendValidation, SendFormData>((ref, data) {
  final balance = ref.watch(availableBalanceProvider);
  final errors = <String, String>{};

  // Recipient validation
  if (data.recipientPhone == null || data.recipientPhone!.isEmpty) {
    errors['recipient'] = 'Veuillez saisir un destinataire';
  } else if (!_isValidPhone(data.recipientPhone!)) {
    errors['recipient'] = 'Numero de telephone invalide';
  }

  // Amount validation
  if (data.amount == null || data.amount! <= 0) {
    errors['amount'] = 'Montant invalide';
  } else if (data.amount! < 0.01) {
    errors['amount'] = 'Montant minimum: 0.01 USDC';
  } else if (data.amount! > balance) {
    errors['amount'] = 'Solde insuffisant';
  } else if (data.amount! > 10000) {
    errors['amount'] = 'Montant maximum: 10,000 USDC par transaction';
  }

  return SendValidation(
    isValid: errors.isEmpty,
    errors: errors,
  );
});

/// Send form data for validation.
class SendFormData {
  final String? recipientPhone;
  final double? amount;
  final String? note;

  const SendFormData({this.recipientPhone, this.amount, this.note});
}

/// Validation result.
class SendValidation {
  final bool isValid;
  final Map<String, String> errors;

  const SendValidation({this.isValid = false, this.errors = const {}});

  String? errorFor(String field) => errors[field];
}

bool _isValidPhone(String phone) {
  // CI phone: +225 followed by 10 digits
  final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  return RegExp(r'^\+?225\d{10}$').hasMatch(cleaned) || RegExp(r'^\d{10}$').hasMatch(cleaned);
}
