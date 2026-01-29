/// Deposit Response Model
class DepositResponse {
  final String depositId;
  final PaymentInstructions paymentInstructions;
  final DateTime expiresAt;
  final DepositStatus status;
  final double amount;
  final double? convertedAmount;

  const DepositResponse({
    required this.depositId,
    required this.paymentInstructions,
    required this.expiresAt,
    required this.status,
    required this.amount,
    this.convertedAmount,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      depositId: json['depositId'] as String,
      paymentInstructions: PaymentInstructions.fromJson(
        json['paymentInstructions'] as Map<String, dynamic>,
      ),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: DepositStatusExt.fromString(json['status'] as String),
      amount: (json['amount'] as num).toDouble(),
      convertedAmount: json['convertedAmount'] != null
          ? (json['convertedAmount'] as num).toDouble()
          : null,
    );
  }

  DepositResponse copyWith({
    String? depositId,
    PaymentInstructions? paymentInstructions,
    DateTime? expiresAt,
    DepositStatus? status,
    double? amount,
    double? convertedAmount,
  }) {
    return DepositResponse(
      depositId: depositId ?? this.depositId,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
    );
  }
}

/// Payment Instructions
class PaymentInstructions {
  final String provider;
  final String? ussdCode;
  final String? deepLink;
  final String referenceNumber;
  final double amountToPay;
  final String currency;
  final String instructions;

  const PaymentInstructions({
    required this.provider,
    this.ussdCode,
    this.deepLink,
    required this.referenceNumber,
    required this.amountToPay,
    required this.currency,
    required this.instructions,
  });

  factory PaymentInstructions.fromJson(Map<String, dynamic> json) {
    return PaymentInstructions(
      provider: json['provider'] as String,
      ussdCode: json['ussdCode'] as String?,
      deepLink: json['deepLink'] as String?,
      referenceNumber: json['referenceNumber'] as String,
      amountToPay: (json['amountToPay'] as num).toDouble(),
      currency: json['currency'] as String,
      instructions: json['instructions'] as String,
    );
  }
}

/// Deposit Status
enum DepositStatus {
  pending,
  completed,
  failed,
  expired,
}

extension DepositStatusExt on DepositStatus {
  String get value {
    switch (this) {
      case DepositStatus.pending:
        return 'pending';
      case DepositStatus.completed:
        return 'completed';
      case DepositStatus.failed:
        return 'failed';
      case DepositStatus.expired:
        return 'expired';
    }
  }

  static DepositStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return DepositStatus.pending;
      case 'completed':
        return DepositStatus.completed;
      case 'failed':
        return DepositStatus.failed;
      case 'expired':
        return DepositStatus.expired;
      default:
        return DepositStatus.pending;
    }
  }
}
