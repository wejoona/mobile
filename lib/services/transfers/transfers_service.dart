import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/security/risk_based_security_service.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Transfers Service - mirrors backend TransfersController
/// Uses risk-based adaptive security (Visa 3DS / Apple style)
class TransfersService {
  final Dio _dio;
  final RiskBasedSecurityService? _riskSecurity;

  TransfersService(this._dio, [this._riskSecurity]);

  /// POST /transfers/internal
  /// Internal transfers between JoonaPay users - typically low risk
  Future<TransferResult> createInternalTransfer({
    required String recipientPhone,
    required double amount,
    String? note,
  }) async {
    // Internal transfers usually get green flow (no verification)
    // But still check for anomalies
    if (_riskSecurity != null) {
      final decision = await _riskSecurity.evaluateTransaction(
        type: 'transfer',
        amount: amount,
        currency: 'USDC',
        recipientType: 'internal',
      );

      AppLogger('Debug').debug('${decision.flowEmoji} Internal transfer \$$amount: ${decision.stepUpType.name}');

      if (decision.stepUpRequired) {
        final verified = await _riskSecurity.executeStepUp(decision);
        if (!verified && decision.stepUpType != StepUpType.liveness) {
          throw SecurityVerificationFailedException(
            'Security verification required for this transfer',
            decision: decision,
          );
        }
        // Liveness requires UI - throw to let caller handle
        if (decision.stepUpType == StepUpType.liveness ||
            decision.stepUpType == StepUpType.biometricAndLiveness) {
          throw LivenessRequiredException(
            'Liveness verification required',
            decision: decision,
          );
        }
      }
    }

    try {
      final response = await _dio.post('/transfers/internal', data: {
        'recipientPhone': recipientPhone,
        'amount': amount,
        if (note != null) 'note': note,
      });
      return TransferResult.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// POST /transfers/external
  /// External transfers to blockchain addresses - risk-based verification
  ///
  /// Flow:
  /// 🟢 GREEN (low risk): No verification
  /// 🟡 YELLOW (medium risk): Biometric only
  /// 🔴 RED (high risk): Liveness required
  Future<TransferResult> createExternalTransfer({
    required String recipientAddress,
    required double amount,
    String? blockchain,
    String? note,
    bool isFirstTransactionToRecipient = false,
    String? challengeToken, // Pre-validated challenge token
    String? livenessSessionId, // Completed liveness session
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

      AppLogger('Debug').debug('${result.decision.flowEmoji} External transfer \$$amount: ${result.decision.stepUpType.name} (score: ${result.decision.riskScore})');

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
      final response = await _dio.post('/transfers/external', data: {
        'recipientAddress': recipientAddress,
        'amount': amount,
        if (blockchain != null) 'blockchain': blockchain,
        if (note != null) 'note': note,
        if (challengeToken != null) 'challengeToken': challengeToken,
      });
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

  /// GET /transfers
  Future<TransferPage> getTransfers({
    int page = 1,
    int pageSize = 20,
    String? type,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/transfers',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
        },
      );
      return TransferPage.fromJson(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  /// GET /transfers/:id
  Future<Transfer> getTransfer(String id) async {
    try {
      final response = await _dio.get('/transfers/$id');
      return Transfer.fromJson(response.data);
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
    return TransferResult(
      id: json['id'] as String,
      reference: json['reference'] as String,
      type: json['type'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      recipientPhone: json['recipientPhone'] as String?,
      recipientAddress: json['recipientAddress'] as String?,
      txHash: json['txHash'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
    final List<dynamic> itemsData = json['items'] ?? json['data'] ?? [];
    return TransferPage(
      items: itemsData
          .map((e) => Transfer.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['pageSize'] as int? ?? 20,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
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
