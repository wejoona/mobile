import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

/// Bill Payments Service - mirrors backend BillPaymentController
class BillPaymentsService {
  final Dio _dio;

  BillPaymentsService(this._dio);

  /// GET /bill-payments/providers
  Future<BillProvidersResponse> getProviders({
    String? country,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (country != null) queryParams['country'] = country;
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '/bill-payments/providers',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      return BillProvidersResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /bill-payments/categories
  Future<BillCategoriesResponse> getCategories({String? country}) async {
    try {
      final response = await _dio.get(
        '/bill-payments/categories',
        queryParameters: country != null ? {'country': country} : null,
      );
      return BillCategoriesResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /bill-payments/validate
  Future<AccountValidationResult> validateAccount({
    required String providerId,
    required String accountNumber,
    String? meterNumber,
  }) async {
    try {
      final response = await _dio.post('/bill-payments/validate', data: {
        'providerId': providerId,
        'accountNumber': accountNumber,
        if (meterNumber != null) 'meterNumber': meterNumber,
      });
      return AccountValidationResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /bill-payments/pay
  Future<BillPaymentResult> payBill({
    required String providerId,
    required String accountNumber,
    required double amount,
    String? meterNumber,
    String? customerName,
    String? currency,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await _dio.post('/bill-payments/pay', data: {
        'providerId': providerId,
        'accountNumber': accountNumber,
        'amount': amount,
        if (meterNumber != null) 'meterNumber': meterNumber,
        if (customerName != null) 'customerName': customerName,
        if (currency != null) 'currency': currency,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
      });
      return BillPaymentResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /bill-payments/history
  Future<BillPaymentHistoryResponse> getHistory({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _dio.get(
        '/bill-payments/history',
        queryParameters: queryParams,
      );
      return BillPaymentHistoryResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /bill-payments/:id/receipt
  Future<BillPaymentReceipt> getReceipt(String paymentId) async {
    try {
      final response = await _dio.get('/bill-payments/$paymentId/receipt');
      return BillPaymentReceipt.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

// ============================================================================
// MODELS
// ============================================================================

/// Bill Category
enum BillCategory {
  electricity,
  water,
  internet,
  tv,
  phoneCredit,
  insurance,
  education,
  government;

  String get value {
    switch (this) {
      case BillCategory.electricity:
        return 'electricity';
      case BillCategory.water:
        return 'water';
      case BillCategory.internet:
        return 'internet';
      case BillCategory.tv:
        return 'tv';
      case BillCategory.phoneCredit:
        return 'phone_credit';
      case BillCategory.insurance:
        return 'insurance';
      case BillCategory.education:
        return 'education';
      case BillCategory.government:
        return 'government';
    }
  }

  static BillCategory fromString(String value) {
    switch (value) {
      case 'electricity':
        return BillCategory.electricity;
      case 'water':
        return BillCategory.water;
      case 'internet':
        return BillCategory.internet;
      case 'tv':
        return BillCategory.tv;
      case 'phone_credit':
        return BillCategory.phoneCredit;
      case 'insurance':
        return BillCategory.insurance;
      case 'education':
        return BillCategory.education;
      case 'government':
        return BillCategory.government;
      default:
        return BillCategory.electricity;
    }
  }

  String get displayName {
    switch (this) {
      case BillCategory.electricity:
        return 'Electricity';
      case BillCategory.water:
        return 'Water';
      case BillCategory.internet:
        return 'Internet';
      case BillCategory.tv:
        return 'TV';
      case BillCategory.phoneCredit:
        return 'Phone Credit';
      case BillCategory.insurance:
        return 'Insurance';
      case BillCategory.education:
        return 'Education';
      case BillCategory.government:
        return 'Government';
    }
  }

  String get icon {
    switch (this) {
      case BillCategory.electricity:
        return 'bolt';
      case BillCategory.water:
        return 'water_drop';
      case BillCategory.internet:
        return 'wifi';
      case BillCategory.tv:
        return 'tv';
      case BillCategory.phoneCredit:
        return 'phone_android';
      case BillCategory.insurance:
        return 'security';
      case BillCategory.education:
        return 'school';
      case BillCategory.government:
        return 'account_balance';
    }
  }
}

/// Bill Provider
class BillProvider {
  final String id;
  final String name;
  final String shortName;
  final BillCategory category;
  final String country;
  final String logo;
  final bool requiresAccountNumber;
  final bool requiresMeterNumber;
  final bool requiresCustomerName;
  final String accountNumberLabel;
  final String? accountNumberPattern;
  final int? accountNumberLength;
  final double minimumAmount;
  final double maximumAmount;
  final double processingFee;
  final String processingFeeType;
  final String currency;
  final bool isActive;
  final bool supportsValidation;
  final String estimatedProcessingTime;

  const BillProvider({
    required this.id,
    required this.name,
    required this.shortName,
    required this.category,
    required this.country,
    required this.logo,
    required this.requiresAccountNumber,
    required this.requiresMeterNumber,
    required this.requiresCustomerName,
    required this.accountNumberLabel,
    this.accountNumberPattern,
    this.accountNumberLength,
    required this.minimumAmount,
    required this.maximumAmount,
    required this.processingFee,
    required this.processingFeeType,
    required this.currency,
    required this.isActive,
    required this.supportsValidation,
    required this.estimatedProcessingTime,
  });

  factory BillProvider.fromJson(Map<String, dynamic> json) {
    return BillProvider(
      id: json['id'] as String,
      name: json['name'] as String,
      shortName: json['shortName'] as String,
      category: BillCategory.fromString(json['category'] as String),
      country: json['country'] as String,
      logo: json['logo'] as String? ?? '',
      requiresAccountNumber: json['requiresAccountNumber'] as bool? ?? true,
      requiresMeterNumber: json['requiresMeterNumber'] as bool? ?? false,
      requiresCustomerName: json['requiresCustomerName'] as bool? ?? false,
      accountNumberLabel: json['accountNumberLabel'] as String? ?? 'Account Number',
      accountNumberPattern: json['accountNumberPattern'] as String?,
      accountNumberLength: json['accountNumberLength'] as int?,
      minimumAmount: (json['minimumAmount'] as num).toDouble(),
      maximumAmount: (json['maximumAmount'] as num).toDouble(),
      processingFee: (json['processingFee'] as num).toDouble(),
      processingFeeType: json['processingFeeType'] as String? ?? 'fixed',
      currency: json['currency'] as String? ?? 'XOF',
      isActive: json['isActive'] as bool? ?? true,
      supportsValidation: json['supportsValidation'] as bool? ?? true,
      estimatedProcessingTime: json['estimatedProcessingTime'] as String? ?? 'Instant',
    );
  }

  double calculateFee(double amount) {
    if (processingFeeType == 'percentage') {
      return amount * processingFee / 100;
    }
    return processingFee;
  }
}

/// Bill Providers Response
class BillProvidersResponse {
  final List<BillProvider> providers;
  final List<String> availableCountries;
  final List<BillCategory> availableCategories;

  const BillProvidersResponse({
    required this.providers,
    required this.availableCountries,
    required this.availableCategories,
  });

  factory BillProvidersResponse.fromJson(Map<String, dynamic> json) {
    return BillProvidersResponse(
      providers: (json['providers'] as List<dynamic>)
          .map((e) => BillProvider.fromJson(e as Map<String, dynamic>))
          .toList(),
      availableCountries: (json['availableCountries'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      availableCategories: (json['availableCategories'] as List<dynamic>)
          .map((e) => BillCategory.fromString(e as String))
          .toList(),
    );
  }
}

/// Category Info
class CategoryInfo {
  final BillCategory category;
  final String displayName;
  final String description;
  final String icon;
  final int providerCount;

  const CategoryInfo({
    required this.category,
    required this.displayName,
    required this.description,
    required this.icon,
    required this.providerCount,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      category: BillCategory.fromString(json['category'] as String),
      displayName: json['displayName'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      providerCount: json['providerCount'] as int,
    );
  }
}

/// Bill Categories Response
class BillCategoriesResponse {
  final List<CategoryInfo> categories;

  const BillCategoriesResponse({required this.categories});

  factory BillCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return BillCategoriesResponse(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Account Validation Result
class AccountValidationResult {
  final bool isValid;
  final String? customerName;
  final String accountNumber;
  final String? meterNumber;
  final String? accountType;
  final double? outstandingBalance;
  final double? minimumPayment;
  final String? message;

  const AccountValidationResult({
    required this.isValid,
    this.customerName,
    required this.accountNumber,
    this.meterNumber,
    this.accountType,
    this.outstandingBalance,
    this.minimumPayment,
    this.message,
  });

  factory AccountValidationResult.fromJson(Map<String, dynamic> json) {
    return AccountValidationResult(
      isValid: json['isValid'] as bool,
      customerName: json['customerName'] as String?,
      accountNumber: json['accountNumber'] as String,
      meterNumber: json['meterNumber'] as String?,
      accountType: json['accountType'] as String?,
      outstandingBalance: (json['outstandingBalance'] as num?)?.toDouble(),
      minimumPayment: (json['minimumPayment'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }
}

/// Bill Payment Result
class BillPaymentResult {
  final String paymentId;
  final String transactionId;
  final String status;
  final String? receiptNumber;
  final String? providerReference;
  final String? tokenNumber;
  final String? units;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final DateTime? paidAt;
  final String? estimatedCompletionTime;

  const BillPaymentResult({
    required this.paymentId,
    required this.transactionId,
    required this.status,
    this.receiptNumber,
    this.providerReference,
    this.tokenNumber,
    this.units,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.currency,
    this.paidAt,
    this.estimatedCompletionTime,
  });

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending' || status == 'processing';
  bool get isFailed => status == 'failed';

  factory BillPaymentResult.fromJson(Map<String, dynamic> json) {
    return BillPaymentResult(
      paymentId: json['paymentId'] as String,
      transactionId: json['transactionId'] as String,
      status: json['status'] as String,
      receiptNumber: json['receiptNumber'] as String?,
      providerReference: json['providerReference'] as String?,
      tokenNumber: json['tokenNumber'] as String?,
      units: json['units'] as String?,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
      estimatedCompletionTime: json['estimatedCompletionTime'] as String?,
    );
  }
}

/// Bill Payment History Item
class BillPaymentHistoryItem {
  final String id;
  final String providerId;
  final String providerName;
  final String providerLogo;
  final BillCategory category;
  final String accountNumber;
  final String? customerName;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String status;
  final String? receiptNumber;
  final String? tokenNumber;
  final DateTime createdAt;
  final DateTime? completedAt;

  const BillPaymentHistoryItem({
    required this.id,
    required this.providerId,
    required this.providerName,
    required this.providerLogo,
    required this.category,
    required this.accountNumber,
    this.customerName,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.currency,
    required this.status,
    this.receiptNumber,
    this.tokenNumber,
    required this.createdAt,
    this.completedAt,
  });

  bool get isCompleted => status == 'completed';

  factory BillPaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return BillPaymentHistoryItem(
      id: json['id'] as String,
      providerId: json['providerId'] as String,
      providerName: json['providerName'] as String,
      providerLogo: json['providerLogo'] as String? ?? '',
      category: BillCategory.fromString(json['category'] as String),
      accountNumber: json['accountNumber'] as String,
      customerName: json['customerName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: json['status'] as String,
      receiptNumber: json['receiptNumber'] as String?,
      tokenNumber: json['tokenNumber'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Bill Payment History Response
class BillPaymentHistoryResponse {
  final List<BillPaymentHistoryItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const BillPaymentHistoryResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;

  factory BillPaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final pagination = json['pagination'] as Map<String, dynamic>;
    return BillPaymentHistoryResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => BillPaymentHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: pagination['page'] as int,
      limit: pagination['limit'] as int,
      total: pagination['total'] as int,
      totalPages: pagination['totalPages'] as int,
    );
  }
}

/// Bill Payment Receipt
class BillPaymentReceipt {
  final String paymentId;
  final String receiptNumber;
  final String providerName;
  final String providerLogo;
  final BillCategory category;
  final String accountNumber;
  final String? customerName;
  final double amount;
  final double fee;
  final double totalAmount;
  final String currency;
  final String? tokenNumber;
  final String? units;
  final String status;
  final DateTime paidAt;
  final String? providerReference;
  final String? qrCode;

  const BillPaymentReceipt({
    required this.paymentId,
    required this.receiptNumber,
    required this.providerName,
    required this.providerLogo,
    required this.category,
    required this.accountNumber,
    this.customerName,
    required this.amount,
    required this.fee,
    required this.totalAmount,
    required this.currency,
    this.tokenNumber,
    this.units,
    required this.status,
    required this.paidAt,
    this.providerReference,
    this.qrCode,
  });

  factory BillPaymentReceipt.fromJson(Map<String, dynamic> json) {
    return BillPaymentReceipt(
      paymentId: json['paymentId'] as String,
      receiptNumber: json['receiptNumber'] as String,
      providerName: json['providerName'] as String,
      providerLogo: json['providerLogo'] as String? ?? '',
      category: BillCategory.fromString(json['category'] as String),
      accountNumber: json['accountNumber'] as String,
      customerName: json['customerName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      tokenNumber: json['tokenNumber'] as String?,
      units: json['units'] as String?,
      status: json['status'] as String,
      paidAt: DateTime.parse(json['paidAt'] as String),
      providerReference: json['providerReference'] as String?,
      qrCode: json['qrCode'] as String?,
    );
  }
}

/// Bill Payments Service Provider
final billPaymentsServiceProvider = Provider<BillPaymentsService>((ref) {
  return BillPaymentsService(ref.watch(dioProvider));
});
