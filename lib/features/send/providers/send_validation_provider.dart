import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/limits/models/transaction_limits.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';

/// Validates send form before submission.
final sendValidationProvider = Provider.family<SendValidation, SendFormData>((
  ref,
  data,
) {
  final balance = ref.watch(availableBalanceProvider);
  final limits =
      ref.watch(limitsProvider).limits ??
      ref.watch(transactionLimitsProvider).value;
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
  } else if (limits != null) {
    final limitHit = limits.limitHitByFor(
      TransactionLimitOperation.send,
      data.amount!,
    );
    if (limitHit != null) {
      errors['amount'] = sendLimitErrorFor(limitHit, limits);
    }
  }

  return SendValidation(isValid: errors.isEmpty, errors: errors);
});

/// Send form data for validation.
class SendFormData {
  const SendFormData({this.recipientPhone, this.amount, this.note});

  final String? recipientPhone;
  final double? amount;
  final String? note;
}

/// Validation result.
class SendValidation {
  const SendValidation({this.isValid = false, this.errors = const {}});

  final bool isValid;
  final Map<String, String> errors;

  String? errorFor(String field) => errors[field];
}

bool _isValidPhone(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  if (RegExp(r'^\+?225\d{10}$').hasMatch(cleaned)) {
    return true;
  }
  if (RegExp(r'^\+?1\d{10}$').hasMatch(cleaned)) {
    return true;
  }
  return RegExp(r'^\+[1-9]\d{7,14}$').hasMatch(cleaned);
}

String sendLimitErrorFor(
  String limitHit,
  TransactionLimits limits,
) => switch (limitHit) {
  'manual_review_required' =>
    limits.permissions.blockReason?.isNotEmpty == true
        ? limits.permissions.blockReason!
        : 'Manual review required before sending money',
  'kyc_required' =>
    limits.permissions.blockReason?.isNotEmpty == true
        ? limits.permissions.blockReason!
        : 'Verification required before sending money',
  'single_transaction' =>
    'Montant maximum: ${limits.singleTransactionLimit.toStringAsFixed(2)} USDC par transfert',
  'daily' =>
    'Limite quotidienne restante: ${limits.dailyRemainingFor(TransactionLimitOperation.send).toStringAsFixed(2)} USDC',
  'monthly' =>
    'Limite mensuelle restante: ${limits.monthlyRemaining.toStringAsFixed(2)} USDC',
  _ => 'Montant au-dessus de vos limites actuelles',
};
