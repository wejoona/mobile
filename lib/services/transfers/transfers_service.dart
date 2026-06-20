import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/core/utils/transaction_headers.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Transfers Service - mirrors backend TransfersController
/// Uses risk-based adaptive security (Visa 3DS / Apple style)
class TransfersService {
  final Dio _dio;
  final RiskBasedSecurityService? _riskSecurity;

  TransfersService(this._dio, [this._riskSecurity]);

  /// POST /wallet/transfer/internal
  /// Internal transfers between Korido users - typically low risk
  /// [pinToken] — required by backend PinVerificationGuard (X-Pin-Token header)
  /// [idempotencyKey] — required by backend IdempotencyGuard (X-Idempotency-Key header)
  /// [amount] — in user-facing USDC units. Backend transfer use cases expect major units.
  Future<TransferResult> createInternalTransfer({
    String? recipientId,
    String? recipientPhone,
    String? recipientUsername,
    required double amount,
    String? note,
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) async {
    final normalizedRecipientId = recipientId?.trim();
    final normalizedPhone = PhoneNumberValue.tryFromAny(
      phoneNumber: recipientPhone,
    )?.e164;
    final normalizedUsername = _normalizeUsername(recipientUsername);
    if ((normalizedRecipientId == null || normalizedRecipientId.isEmpty) &&
        (normalizedPhone == null || normalizedPhone.isEmpty) &&
        (normalizedUsername == null || normalizedUsername.isEmpty)) {
      throw ArgumentError('Recipient ID, phone, or username is required');
    }

    try {
      final recipientBody = _recipientIdentifierBody(
        recipientId: normalizedRecipientId,
        recipientPhone: normalizedPhone,
        recipientUsername: normalizedUsername,
      );
      final response = await _dio.post(
        ApiEndpoints.transfersSend,
        data: {
          ...recipientBody,
          'amount': amount,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
            stepUpToken: stepUpToken,
          ),
        ),
      );
      return TransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  String? _normalizeUsername(String? username) {
    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }

  Map<String, String> _recipientIdentifierBody({
    required String? recipientId,
    required String? recipientPhone,
    required String? recipientUsername,
  }) {
    // Backend accepts exactly one identifier. Lookup/contact selections may
    // carry display phone + username too; prefer the stable user id.
    if (recipientId != null && recipientId.isNotEmpty) {
      return {'recipientId': recipientId};
    }
    if (recipientUsername != null && recipientUsername.isNotEmpty) {
      return {'recipientUsername': recipientUsername};
    }
    return {'toPhone': recipientPhone!};
  }

  /// POST /wallet/transfer/external
  /// External transfers to blockchain addresses - risk-based verification
  ///
  /// Flow:
  /// 🟢 GREEN (low risk): No verification
  /// 🟡 YELLOW (medium risk): Biometric only
  /// 🔴 RED (high risk): Liveness required
  /// [pinToken] — required by backend PinVerificationGuard (X-Pin-Token header)
  /// [idempotencyKey] — required by backend IdempotencyGuard (X-Idempotency-Key header)
  /// [amount] — in user-facing USDC units. Backend transfer use cases expect major units.
  Future<TransferResult> createExternalTransfer({
    required String recipientAddress,
    required double amount,
    String? blockchain,
    String? note,
    bool isFirstTransactionToRecipient = false,
    String? challengeToken,
    String? livenessSessionId,
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) async {
    // Check if we have a pre-validated step-up
    if (challengeToken != null && _riskSecurity != null) {
      final validated = await _riskSecurity.validateStepUp(
        challengeToken: challengeToken,
        livenessSessionId: livenessSessionId,
        biometricVerified: true,
      );
      if (!validated) {
        throw SecurityVerificationFailedException(
          'Step-up validation failed',
          decision: null,
        );
      }
    } else if (_riskSecurity != null) {
      // Evaluate risk and determine step-up
      final result = await _riskSecurity.guardExternalTransfer(
        amount: amount,
        currency: 'USDC',
        recipientId: recipientAddress,
        isFirstTransaction: isFirstTransactionToRecipient,
      );

      AppLogger('Debug').debug(
        '${result.decision.flowEmoji} External transfer \$$amount: ${result.decision.stepUpType.name} (score: ${result.decision.riskScore})',
      );

      if (!result.approved) {
        // Liveness required - throw to let UI handle
        if (result.decision.stepUpType == StepUpType.liveness ||
            result.decision.stepUpType == StepUpType.biometricAndLiveness) {
          throw LivenessRequiredException(
            result.decision.description,
            decision: result.decision,
          );
        }
        // Manual review required
        if (result.decision.stepUpType == StepUpType.manualReview) {
          throw ManualReviewRequiredException(
            'This transaction requires manual review',
          );
        }
        throw SecurityVerificationFailedException(
          'Security verification failed',
          decision: result.decision,
        );
      }
    }

    try {
      final response = await _dio.post(
        ApiEndpoints.transfersExternal,
        data: {
          'toAddress': recipientAddress,
          'amount': amount,
          if (blockchain != null) 'network': blockchain,
          if (note != null) 'note': note,
        },
        options: Options(
          headers: transactionHeaders(
            pinToken: pinToken,
            idempotencyKey: idempotencyKey,
            stepUpToken: stepUpToken ?? challengeToken,
          ),
        ),
      );
      return TransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// Evaluate transfer risk without executing
  /// Use this to show the user what verification will be required
  Future<StepUpDecision?> evaluateTransferRisk({
    required String type,
    required double amount,
    required String recipientId,
    required String recipientType,
    bool isFirstTransaction = false,
  }) async {
    if (_riskSecurity == null) return null;

    return await _riskSecurity.evaluateTransaction(
      type: type,
      amount: amount,
      currency: 'USDC',
      recipientId: recipientId,
      recipientType: recipientType,
      isFirstTransactionToRecipient: isFirstTransaction,
    );
  }

  /// GET /wallet/transactions
  Future<TransferPage> getTransfers({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.walletTransactions,
        queryParameters: {
          'limit': pageSize,
          'offset': (page - 1).clamp(0, 1 << 31) * pageSize,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
        },
      );
      return TransferPage.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /wallet/transactions/:id
  Future<Transfer> getTransfer(String id) async {
    try {
      final response = await _dio.get(ApiEndpoints.walletTransactionById(id));
      return Transfer.fromJson(_payloadMap(_asStringMap(response.data)));
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

/// Transfer Result DTO
class TransferResult {
  final String id;
  final String reference;
  final String type;
  final String status;
  final double amount;
  final double fee;
  final String currency;
  final String? recipientPhone;
  final String? recipientAddress;
  final String? txHash;
  final DateTime createdAt;

  const TransferResult({
    required this.id,
    required this.reference,
    required this.type,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    this.recipientPhone,
    this.recipientAddress,
    this.txHash,
    required this.createdAt,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    final payload = _payloadMap(json);
    final id = _stringValue(payload, const [
      'id',
      'transactionId',
      'transferId',
    ]);
    return TransferResult(
      id: id ?? '',
      reference:
          _stringValue(payload, const ['reference', 'supportReference']) ??
          id ??
          '',
      type: _stringValue(payload, const ['type', 'transferType']) ?? 'internal',
      status: _stringValue(payload, const ['status']) ?? 'pending',
      amount: _numValue(payload, const ['amountDecimal', 'amount']) ?? 0,
      fee: _numValue(payload, const ['feeDecimal', 'fee']) ?? 0,
      currency: _stringValue(payload, const ['currency']) ?? 'USDC',
      recipientPhone: _stringValue(payload, const [
        'recipientPhone',
        'toPhone',
      ]),
      recipientAddress: _stringValue(payload, const ['recipientAddress']),
      txHash: _stringValue(payload, const ['txHash', 'transactionHash']),
      createdAt:
          _dateValue(payload, const ['createdAt', 'created_at', 'timestamp']) ??
          DateTime.now(),
    );
  }
}

/// Transfer Page DTO
class TransferPage {
  final List<Transfer> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const TransferPage({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory TransferPage.fromJson(Map<String, dynamic> json) {
    final payload = _payloadMap(json);
    final itemsData = _listValue(payload, const ['items', 'transfers', 'data']);
    final pageSize =
        _intValue(payload, const ['pageSize', 'page_size', 'limit']) ??
        itemsData.length;
    final offset = _intValue(payload, const ['offset']) ?? 0;
    final total = _intValue(payload, const ['total', 'count']) ?? 0;
    final page =
        _intValue(payload, const ['page']) ??
        (pageSize > 0 ? (offset ~/ pageSize) + 1 : 1);
    return TransferPage(
      items: itemsData.map((e) => Transfer.fromJson(_asStringMap(e))).toList(),
      total: total,
      page: page,
      pageSize: pageSize,
      totalPages:
          _intValue(payload, const ['totalPages', 'total_pages']) ??
          (pageSize > 0 ? (total / pageSize).ceil().clamp(1, 1 << 31) : 1),
    );
  }
}

Map<String, dynamic> _payloadMap(Map<String, dynamic> json) {
  final data = json['data'];
  if (data is Map) {
    return Map<String, dynamic>.from(data);
  }
  return json;
}

Map<String, dynamic> _asStringMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  throw const FormatException('Expected transfer JSON object');
}

List<dynamic> _listValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is List) return value;
  }
  return const [];
}

String? _stringValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.isNotEmpty) return value;
  }
  return null;
}

double? _numValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
  }
  return null;
}

int? _intValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
  }
  return null;
}

DateTime? _dateValue(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  }
  return null;
}

/// Exception when security verification fails
class SecurityVerificationFailedException implements Exception {
  final String message;
  final StepUpDecision? decision;

  SecurityVerificationFailedException(this.message, {this.decision});

  @override
  String toString() => message;
}

/// Exception when liveness is required (UI must handle)
class LivenessRequiredException implements Exception {
  final String message;
  final StepUpDecision decision;

  LivenessRequiredException(this.message, {required this.decision});

  String? get challengeToken => decision.challengeToken;
  StepUpType get stepUpType => decision.stepUpType;

  @override
  String toString() => message;
}

/// Transfers Service Provider
final transfersServiceProvider = Provider<TransfersService>((ref) {
  return TransfersService(
    ref.watch(dioProvider),
    ref.watch(riskBasedSecurityServiceProvider),
  );
});
