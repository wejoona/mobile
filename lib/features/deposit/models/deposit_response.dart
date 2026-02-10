import 'package:usdc_wallet/features/deposit/models/mobile_money_provider.dart';

/// Deposit Response Model
///
/// Returned by both POST /deposits/initiate and GET /deposits/:id
class DepositResponse {
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
  final String providerCode;
  final String? failureReason;

  const DepositResponse({
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
    this.providerCode = '',
    this.failureReason,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      depositId: json['depositId'] as String? ?? json['id'] as String? ?? '',
      token: json['token'] as String? ?? '',
      paymentMethodType: PaymentMethodTypeExt.fromString(
        json['paymentMethodType'] as String? ?? 'PUSH',
      ),
      instructions: json['instructions'] as String? ?? '',
      qrCodeData: json['qrCodeData'] as String?,
      deepLinkUrl: json['deepLinkUrl'] as String?,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : DateTime.now().add(const Duration(minutes: 15)),
      status: DepositStatusExt.fromString(
        json['status'] as String? ?? 'initiated',
      ),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'XOF',
      convertedAmount: json['convertedAmount'] != null
          ? (json['convertedAmount'] as num).toDouble()
          : null,
      convertedCurrency: json['convertedCurrency'] as String?,
      providerCode: json['providerCode'] as String? ?? '',
      failureReason: json['failureReason'] as String?,
    );
  }

  DepositResponse copyWith({
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
    String? providerCode,
    String? failureReason,
  }) {
    return DepositResponse(
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
      providerCode: providerCode ?? this.providerCode,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isCompleted => status == DepositStatus.completed;
  bool get isFailed => status == DepositStatus.failed || status == DepositStatus.expired;
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
        return DepositStatus.expired;
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
