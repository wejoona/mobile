import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Merchant Service - handles merchant-related API calls
class MerchantService {
  final Dio _dio;

  MerchantService(this._dio);

  /// Register as a merchant
  Future<MerchantResponse> register({
    required String businessName,
    String? displayName,
    required String category,
    required String country,
    String? businessAddress,
    String? businessPhone,
    String? businessEmail,
    String? taxId,
    String? webhookUrl,
  }) async {
    try {
      final response = await _dio.post('/merchants/register', data: {
        'businessName': businessName,
        if (displayName != null) 'displayName': displayName,
        'category': category,
        'country': country,
        if (businessAddress != null) 'businessAddress': businessAddress,
        if (businessPhone != null) 'businessPhone': businessPhone,
        if (businessEmail != null) 'businessEmail': businessEmail,
        if (taxId != null) 'taxId': taxId,
        if (webhookUrl != null) 'webhookUrl': webhookUrl,
      });
      return MerchantResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get my merchant profile
  Future<MerchantResponse> getMyMerchant() async {
    try {
      final response = await _dio.get('/merchants/me');
      return MerchantResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get merchant by ID
  Future<MerchantResponse> getMerchantById(String merchantId) async {
    try {
      final response = await _dio.get('/merchants/$merchantId');
      return MerchantResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get merchant QR code
  Future<MerchantQrResponse> getMerchantQr(String merchantId) async {
    try {
      final response = await _dio.get('/merchants/$merchantId/qr');
      return MerchantQrResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Decode QR code data
  Future<QrDecodeResponse> decodeQr(String qrData) async {
    try {
      final response = await _dio.post('/merchants/decode-qr', data: {
        'qrData': qrData,
      });
      return QrDecodeResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Create payment request (dynamic QR)
  Future<PaymentRequestResponse> createPaymentRequest({
    required String merchantId,
    required double amount,
    String? currency,
    String? description,
    String? reference,
    int? expiresInMinutes,
  }) async {
    try {
      final response = await _dio.post(
        '/merchants/$merchantId/payment-request',
        data: {
          'amount': amount,
          if (currency != null) 'currency': currency,
          if (description != null) 'description': description,
          if (reference != null) 'reference': reference,
          if (expiresInMinutes != null) 'expiresInMinutes': expiresInMinutes,
        },
      );
      return PaymentRequestResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Process payment (pay merchant)
  Future<PaymentResponse> processPayment({
    required String qrData,
    double? amount,
  }) async {
    try {
      final response = await _dio.post('/merchants/pay', data: {
        'qrData': qrData,
        if (amount != null) 'amount': amount,
      });
      return PaymentResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get merchant transactions
  Future<MerchantTransactionsResponse> getTransactions({
    required String merchantId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/merchants/$merchantId/transactions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
      );
      return MerchantTransactionsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Get merchant analytics
  Future<MerchantAnalyticsResponse> getAnalytics({
    required String merchantId,
    String period = 'month',
  }) async {
    try {
      final response = await _dio.get(
        '/merchants/$merchantId/analytics',
        queryParameters: {'period': period},
      );
      return MerchantAnalyticsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ============================================
// RESPONSE MODELS
// ============================================

class MerchantResponse {
  final String merchantId;
  final String businessName;
  final String displayName;
  final String category;
  final String country;
  final String walletId;
  final String qrCode;
  final String? qrCodeUrl;
  final bool isVerified;
  final double feePercent;
  final double dailyLimit;
  final double monthlyLimit;
  final double dailyVolume;
  final double monthlyVolume;
  final double remainingDailyLimit;
  final double remainingMonthlyLimit;
  final int totalTransactions;
  final String status;
  final String? businessAddress;
  final String? businessPhone;
  final String? businessEmail;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MerchantResponse({
    required this.merchantId,
    required this.businessName,
    required this.displayName,
    required this.category,
    required this.country,
    required this.walletId,
    required this.qrCode,
    this.qrCodeUrl,
    required this.isVerified,
    required this.feePercent,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.dailyVolume,
    required this.monthlyVolume,
    required this.remainingDailyLimit,
    required this.remainingMonthlyLimit,
    required this.totalTransactions,
    required this.status,
    this.businessAddress,
    this.businessPhone,
    this.businessEmail,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MerchantResponse.fromJson(Map<String, dynamic> json) {
    return MerchantResponse(
      merchantId: json['merchantId'] as String,
      businessName: json['businessName'] as String,
      displayName: json['displayName'] as String,
      category: json['category'] as String,
      country: json['country'] as String,
      walletId: json['walletId'] as String,
      qrCode: json['qrCode'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String?,
      isVerified: json['isVerified'] as bool,
      feePercent: (json['feePercent'] as num).toDouble(),
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      dailyVolume: (json['dailyVolume'] as num).toDouble(),
      monthlyVolume: (json['monthlyVolume'] as num).toDouble(),
      remainingDailyLimit: (json['remainingDailyLimit'] as num).toDouble(),
      remainingMonthlyLimit: (json['remainingMonthlyLimit'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      status: json['status'] as String,
      businessAddress: json['businessAddress'] as String?,
      businessPhone: json['businessPhone'] as String?,
      businessEmail: json['businessEmail'] as String?,
      logoUrl: json['logoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';
}

class MerchantQrResponse {
  final String merchantId;
  final String merchantName;
  final String qrCode;
  final String? qrCodeUrl;

  const MerchantQrResponse({
    required this.merchantId,
    required this.merchantName,
    required this.qrCode,
    this.qrCodeUrl,
  });

  factory MerchantQrResponse.fromJson(Map<String, dynamic> json) {
    return MerchantQrResponse(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      qrCode: json['qrCode'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String?,
    );
  }
}

class QrDecodeResponse {
  final String merchantId;
  final String displayName;
  final String category;
  final bool isVerified;
  final String? logoUrl;
  final String qrType;
  final double? amount;
  final String? requestId;

  const QrDecodeResponse({
    required this.merchantId,
    required this.displayName,
    required this.category,
    required this.isVerified,
    this.logoUrl,
    required this.qrType,
    this.amount,
    this.requestId,
  });

  factory QrDecodeResponse.fromJson(Map<String, dynamic> json) {
    return QrDecodeResponse(
      merchantId: json['merchantId'] as String,
      displayName: json['displayName'] as String,
      category: json['category'] as String,
      isVerified: json['isVerified'] as bool,
      logoUrl: json['logoUrl'] as String?,
      qrType: json['qrType'] as String,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      requestId: json['requestId'] as String?,
    );
  }

  bool get isStaticQr => qrType == 'static';
  bool get isDynamicQr => qrType == 'dynamic';
}

class PaymentRequestResponse {
  final String requestId;
  final String merchantId;
  final String merchantName;
  final double amount;
  final String currency;
  final String? description;
  final String qrData;
  final String qrCodeUrl;
  final DateTime expiresAt;
  final int expiresInSeconds;

  const PaymentRequestResponse({
    required this.requestId,
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.currency,
    this.description,
    required this.qrData,
    required this.qrCodeUrl,
    required this.expiresAt,
    required this.expiresInSeconds,
  });

  factory PaymentRequestResponse.fromJson(Map<String, dynamic> json) {
    return PaymentRequestResponse(
      requestId: json['requestId'] as String,
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      qrData: json['qrData'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      expiresInSeconds: json['expiresInSeconds'] as int,
    );
  }
}

class PaymentReceipt {
  final String transactionId;
  final String merchantName;
  final String merchantCategory;
  final double amount;
  final double fee;
  final double total;
  final DateTime timestamp;
  final String reference;

  const PaymentReceipt({
    required this.transactionId,
    required this.merchantName,
    required this.merchantCategory,
    required this.amount,
    required this.fee,
    required this.total,
    required this.timestamp,
    required this.reference,
  });

  factory PaymentReceipt.fromJson(Map<String, dynamic> json) {
    return PaymentReceipt(
      transactionId: json['transactionId'] as String,
      merchantName: json['merchantName'] as String,
      merchantCategory: json['merchantCategory'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      reference: json['reference'] as String,
    );
  }
}

class PaymentResponse {
  final String paymentId;
  final String reference;
  final String merchantId;
  final String merchantName;
  final double amount;
  final double fee;
  final double netAmount;
  final String currency;
  final String status;
  final DateTime createdAt;
  final PaymentReceipt receipt;

  const PaymentResponse({
    required this.paymentId,
    required this.reference,
    required this.merchantId,
    required this.merchantName,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.currency,
    required this.status,
    required this.createdAt,
    required this.receipt,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      paymentId: json['paymentId'] as String,
      reference: json['reference'] as String,
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      receipt: PaymentReceipt.fromJson(json['receipt'] as Map<String, dynamic>),
    );
  }
}

class MerchantTransaction {
  final String paymentId;
  final String reference;
  final String customerId;
  final double amount;
  final double fee;
  final double netAmount;
  final String currency;
  final String? description;
  final String status;
  final DateTime createdAt;

  const MerchantTransaction({
    required this.paymentId,
    required this.reference,
    required this.customerId,
    required this.amount,
    required this.fee,
    required this.netAmount,
    required this.currency,
    this.description,
    required this.status,
    required this.createdAt,
  });

  factory MerchantTransaction.fromJson(Map<String, dynamic> json) {
    return MerchantTransaction(
      paymentId: json['paymentId'] as String,
      reference: json['reference'] as String,
      customerId: json['customerId'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      netAmount: (json['netAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class MerchantTransactionsResponse {
  final String merchantId;
  final String merchantName;
  final List<MerchantTransaction> transactions;
  final int total;
  final int limit;
  final int offset;

  const MerchantTransactionsResponse({
    required this.merchantId,
    required this.merchantName,
    required this.transactions,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory MerchantTransactionsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> txList = json['transactions'] ?? [];
    return MerchantTransactionsResponse(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      transactions: txList
          .map((e) => MerchantTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
    );
  }
}

class HourlyBreakdown {
  final int hour;
  final int count;

  const HourlyBreakdown({required this.hour, required this.count});

  factory HourlyBreakdown.fromJson(Map<String, dynamic> json) {
    return HourlyBreakdown(
      hour: json['hour'] as int,
      count: json['count'] as int,
    );
  }
}

class DailyBreakdown {
  final String date;
  final int count;
  final double volume;

  const DailyBreakdown({
    required this.date,
    required this.count,
    required this.volume,
  });

  factory DailyBreakdown.fromJson(Map<String, dynamic> json) {
    return DailyBreakdown(
      date: json['date'] as String,
      count: json['count'] as int,
      volume: (json['volume'] as num).toDouble(),
    );
  }
}

class MerchantAnalyticsResponse {
  final String merchantId;
  final String merchantName;
  final String period;
  final DateTime startDate;
  final DateTime endDate;
  final int totalTransactions;
  final double totalVolume;
  final double totalFees;
  final double averageTransactionSize;
  final int uniqueCustomers;
  final String currency;
  final List<HourlyBreakdown> topHours;
  final List<DailyBreakdown> transactionsByDay;

  const MerchantAnalyticsResponse({
    required this.merchantId,
    required this.merchantName,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.totalTransactions,
    required this.totalVolume,
    required this.totalFees,
    required this.averageTransactionSize,
    required this.uniqueCustomers,
    required this.currency,
    required this.topHours,
    required this.transactionsByDay,
  });

  factory MerchantAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> hoursList = json['topHours'] ?? [];
    final List<dynamic> daysList = json['transactionsByDay'] ?? [];
    return MerchantAnalyticsResponse(
      merchantId: json['merchantId'] as String,
      merchantName: json['merchantName'] as String,
      period: json['period'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalTransactions: json['totalTransactions'] as int,
      totalVolume: (json['totalVolume'] as num).toDouble(),
      totalFees: (json['totalFees'] as num).toDouble(),
      averageTransactionSize: (json['averageTransactionSize'] as num).toDouble(),
      uniqueCustomers: json['uniqueCustomers'] as int,
      currency: json['currency'] as String,
      topHours: hoursList
          .map((e) => HourlyBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
      transactionsByDay: daysList
          .map((e) => DailyBreakdown.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Provider for MerchantService
final merchantServiceProvider = Provider<MerchantService>((ref) {
  return MerchantService(ref.watch(dioProvider));
});
