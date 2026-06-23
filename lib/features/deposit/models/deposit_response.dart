import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';

/// Deposit Response Model
///
/// Returned by POST /wallet/deposit and GET /wallet/deposit/:id.
class DepositResponse {
  final String transactionId;
  final String depositId;
  final String token;
  final PaymentMethodType paymentMethodType;
  final String instructions;
  final String? qrCodeData;
  final String? deepLinkUrl;
  final DateTime expiresAt;
  final DepositStatus status;
  final double amount;
  final String currency;
  final double? convertedAmount;
  final String? convertedCurrency;
  final double? exchangeRate;
  final String providerCode;
  final String? failureReason;

  const DepositResponse({
    this.transactionId = '',
    required this.depositId,
    this.token = '',
    required this.paymentMethodType,
    this.instructions = '',
    this.qrCodeData,
    this.deepLinkUrl,
    required this.expiresAt,
    required this.status,
    required this.amount,
    this.currency = 'XOF',
    this.convertedAmount,
    this.convertedCurrency,
    this.exchangeRate,
    this.providerCode = '',
    this.failureReason,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    final paymentInstructions =
        json['paymentInstructions'] as Map<String, dynamic>?;

    return DepositResponse(
      transactionId: json['transactionId'] as String? ?? '',
      depositId: json['depositId'] as String? ?? json['id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      paymentMethodType: PaymentMethodTypeExt.fromString(
        json['paymentMethodType'] as String? ??
            paymentInstructions?['paymentMethodType'] as String? ??
            paymentInstructions?['type'] as String? ??
            'PUSH',
      ),
      instructions:
          json['instructions'] as String? ??
          paymentInstructions?['instructions'] as String? ??
          '',
      qrCodeData:
          json['qrCodeData'] as String? ??
          paymentInstructions?['qrCodeData'] as String?,
      deepLinkUrl:
          json['deepLinkUrl'] as String? ??
          paymentInstructions?['deepLinkUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(minutes: 15)),
      status: DepositStatusExt.fromString(
        json['status'] as String? ?? 'initiated',
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency:
          json['sourceCurrency'] as String? ??
          json['currency'] as String? ??
          'XOF',
      convertedAmount: json['convertedAmount'] != null
          ? (json['convertedAmount'] as num).toDouble()
          : json['usdcAmount'] != null
          ? (json['usdcAmount'] as num).toDouble()
          : json['estimatedAmount'] != null
          ? (json['estimatedAmount'] as num).toDouble()
          : null,
      convertedCurrency:
          json['convertedCurrency'] as String? ??
          json['targetCurrency'] as String? ??
          'USDC',
      exchangeRate: json['exchangeRate'] != null
          ? (json['exchangeRate'] as num).toDouble()
          : json['rate'] != null
          ? (json['rate'] as num).toDouble()
          : null,
      providerCode:
          json['provider'] as String? ??
          json['providerCode'] as String? ??
          json['channelId'] as String? ??
          paymentInstructions?['provider'] as String? ??
          '',
      failureReason: json['failureReason'] as String?,
    );
  }

  DepositResponse copyWith({
    String? transactionId,
    String? depositId,
    String? token,
    PaymentMethodType? paymentMethodType,
    String? instructions,
    String? qrCodeData,
    String? deepLinkUrl,
    DateTime? expiresAt,
    DepositStatus? status,
    double? amount,
    String? currency,
    double? convertedAmount,
    String? convertedCurrency,
    double? exchangeRate,
    String? providerCode,
    String? failureReason,
  }) {
    return DepositResponse(
      transactionId: transactionId ?? this.transactionId,
      depositId: depositId ?? this.depositId,
      token: token ?? this.token,
      paymentMethodType: paymentMethodType ?? this.paymentMethodType,
      instructions: instructions ?? this.instructions,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      deepLinkUrl: deepLinkUrl ?? this.deepLinkUrl,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      convertedCurrency: convertedCurrency ?? this.convertedCurrency,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      providerCode: providerCode ?? this.providerCode,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  DepositResponse mergeStatusUpdate(DepositResponse update) {
    final updateHasPaymentInstructions =
        update.instructions.isNotEmpty ||
        update.qrCodeData?.isNotEmpty == true ||
        update.deepLinkUrl?.isNotEmpty == true ||
        update.token.isNotEmpty;

    return copyWith(
      transactionId: update.transactionId.isNotEmpty
          ? update.transactionId
          : transactionId,
      depositId: update.depositId.isNotEmpty ? update.depositId : depositId,
      token: update.token.isNotEmpty ? update.token : token,
      paymentMethodType: updateHasPaymentInstructions
          ? update.paymentMethodType
          : paymentMethodType,
      instructions: update.instructions.isNotEmpty
          ? update.instructions
          : instructions,
      qrCodeData: update.qrCodeData ?? qrCodeData,
      deepLinkUrl: update.deepLinkUrl ?? deepLinkUrl,
      expiresAt: update.expiresAt,
      status: update.status,
      amount: update.amount > 0 ? update.amount : amount,
      currency: update.currency,
      convertedAmount: update.convertedAmount ?? convertedAmount,
      convertedCurrency: update.convertedCurrency ?? convertedCurrency,
      exchangeRate: update.exchangeRate ?? exchangeRate,
      providerCode: update.providerCode.isNotEmpty
          ? update.providerCode
          : providerCode,
      failureReason: update.failureReason,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isCompleted => status == DepositStatus.completed;
  bool get isFailed =>
      status == DepositStatus.failed || status == DepositStatus.expired;
  String get statusLookupId =>
      transactionId.trim().isNotEmpty ? transactionId.trim() : depositId.trim();
  bool get isPending =>
      status == DepositStatus.initiated ||
      status == DepositStatus.pendingOtp ||
      status == DepositStatus.pendingConfirmation ||
      status == DepositStatus.processing;
}

/// Deposit Status
enum DepositStatus {
  initiated,
  pendingOtp,
  pendingConfirmation,
  processing,
  completed,
  failed,
  expired,
}

extension DepositStatusExt on DepositStatus {
  String get value {
    switch (this) {
      case DepositStatus.initiated:
        return 'initiated';
      case DepositStatus.pendingOtp:
        return 'pending_otp';
      case DepositStatus.pendingConfirmation:
        return 'pending_confirmation';
      case DepositStatus.processing:
        return 'processing';
      case DepositStatus.completed:
        return 'completed';
      case DepositStatus.failed:
        return 'failed';
      case DepositStatus.expired:
        return 'expired';
    }
  }

  static DepositStatus fromString(String value) {
    switch (value.toLowerCase().replaceAll('-', '_')) {
      case 'initiated':
        return DepositStatus.initiated;
      case 'pending_otp':
        return DepositStatus.pendingOtp;
      case 'pending_confirmation':
        return DepositStatus.pendingConfirmation;
      case 'processing':
        return DepositStatus.processing;
      case 'completed':
        return DepositStatus.completed;
      case 'failed':
        return DepositStatus.failed;
      case 'expired':
      case 'timeout':
      case 'cancelled':
        return DepositStatus.expired;
      case 'settled':
        return DepositStatus.completed;
      default:
        return DepositStatus.initiated;
    }
  }

  String get displayName {
    switch (this) {
      case DepositStatus.initiated:
        return 'Initiated';
      case DepositStatus.pendingOtp:
        return 'Waiting for OTP';
      case DepositStatus.pendingConfirmation:
        return 'Waiting for confirmation';
      case DepositStatus.processing:
        return 'Processing';
      case DepositStatus.completed:
        return 'Completed';
      case DepositStatus.failed:
        return 'Failed';
      case DepositStatus.expired:
        return 'Expired';
    }
  }
}
