import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/biometric/biometric_service.dart';
import 'package:usdc_wallet/services/liveness/liveness_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Risk flow colors (like Visa 3DS / Apple)
enum RiskFlow { green, yellow, red }

/// Step-up requirements
enum StepUpType {
  none,
  biometric,
  otp,
  liveness,
  biometricAndLiveness,
  manualReview,
}

/// Step-up decision from backend
class StepUpDecision {
  final RiskFlow flow;
  final int riskScore;
  final String riskLevel;
  final bool stepUpRequired;
  final StepUpType stepUpType;
  final String? reason;
  final List<String> factors;
  final String? challengeToken;
  final DateTime expiresAt;

  StepUpDecision({
    required this.flow,
    required this.riskScore,
    required this.riskLevel,
    required this.stepUpRequired,
    required this.stepUpType,
    this.reason,
    String? localizedReason,
    required this.factors,
    this.challengeToken,
    required this.expiresAt,
  });

  factory StepUpDecision.fromJson(Map<String, dynamic> json) {
    return StepUpDecision(
      flow: _parseFlow(json['flow']),
      riskScore: json['riskScore'] ?? 0,
      riskLevel: json['riskLevel'] ?? 'unknown',
      stepUpRequired: json['stepUpRequired'] ?? false,
      stepUpType: _parseStepUpType(json['stepUpType']),
      reason: json['reason'],
      factors: List<String>.from(json['factors'] ?? []),
      challengeToken: json['challengeToken'],
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  static RiskFlow _parseFlow(String? flow) {
    switch (flow) {
      case 'green':
        return RiskFlow.green;
      case 'yellow':
        return RiskFlow.yellow;
      case 'red':
        return RiskFlow.red;
      default:
        return RiskFlow.yellow;
    }
  }

  static StepUpType _parseStepUpType(String? type) {
    switch (type) {
      case 'none':
        return StepUpType.none;
      case 'biometric':
        return StepUpType.biometric;
      case 'otp':
        return StepUpType.otp;
      case 'liveness':
        return StepUpType.liveness;
      case 'biometric_and_liveness':
        return StepUpType.biometricAndLiveness;
      case 'manual_review':
        return StepUpType.manualReview;
      default:
        return StepUpType.biometric;
    }
  }

  /// Get emoji for flow
  String get flowEmoji {
    switch (flow) {
      case RiskFlow.green:
        return '🟢';
      case RiskFlow.yellow:
        return '🟡';
      case RiskFlow.red:
        return '🔴';
    }
  }

  /// User-friendly description
  String get description {
    if (!stepUpRequired) {
      return 'Transaction approved';
    }
    switch (stepUpType) {
      case StepUpType.biometric:
        return 'Please verify with fingerprint or Face ID';
      case StepUpType.liveness:
        return 'Please complete liveness verification';
      case StepUpType.biometricAndLiveness:
        return 'Please verify with biometric and liveness check';
      case StepUpType.otp:
        return 'Please enter the OTP sent to your phone';
      case StepUpType.manualReview:
        return 'This transaction requires manual review';
      default:
        return 'No additional verification needed';
    }
  }
}

/// Risk-Based Security Service
/// Uses backend risk assessment to determine step-up requirements
/// Like Visa 3DS and Apple's adaptive authentication
class RiskBasedSecurityService {
  final Dio _dio;
  final BiometricService _biometricService;
  final LivenessService _livenessService;

  RiskBasedSecurityService({
    required Dio dio,
    required BiometricService biometricService,
    required LivenessService livenessService,
  })  : _dio = dio,
        _biometricService = biometricService,
        _livenessService = livenessService;

  /// Evaluate step-up for a transaction
  /// Returns the risk decision with flow color and required verification
  Future<StepUpDecision> evaluateTransaction({
    required String type,
    required double amount,
    required String currency,
    String? recipientId,
    String? recipientType,
    bool isFirstTransactionToRecipient = false,
  }) async {
    try {
      final response = await _dio.post('/step-up/transaction', data: {
        'type': type,
        'amount': amount,
        'currency': currency,
        'recipientId': recipientId,
        'recipientType': recipientType,
        'isFirstTransactionToRecipient': isFirstTransactionToRecipient,
      });

      if (response.data['success'] == true) {
        return StepUpDecision.fromJson(response.data['data']);
      }

      throw Exception('Failed to evaluate transaction risk');
    } catch (e) {
      AppLogger('Risk evaluation failed, defaulting to biometric').error('Risk evaluation failed, defaulting to biometric', e);
      // Fallback to yellow flow on error
      return StepUpDecision(
        flow: RiskFlow.yellow,
        riskScore: 50,
        riskLevel: 'medium',
        stepUpRequired: true,
        stepUpType: StepUpType.biometric,
        localizedReason: 'Unable to assess risk, verification required',
        factors: ['risk_service_unavailable'],
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );
    }
  }

  /// Evaluate step-up for an operation (non-transaction)
  Future<StepUpDecision> evaluateOperation({
    required String operation,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post('/step-up/operation', data: {
        'operation': operation,
        'metadata': metadata,
      });

      if (response.data['success'] == true) {
        return StepUpDecision.fromJson(response.data['data']);
      }

      throw Exception('Failed to evaluate operation risk');
    } catch (e) {
      AppLogger('Risk evaluation failed for operation').error('Risk evaluation failed for operation', e);
      // Default requirements for known operations
      return _getDefaultOperationDecision(operation);
    }
  }

  /// Execute the required step-up verification
  /// Returns true if verification succeeds
  Future<bool> executeStepUp(StepUpDecision decision) async {
    if (!decision.stepUpRequired) {
      return true;
    }

    switch (decision.stepUpType) {
      case StepUpType.none:
        return true;

      case StepUpType.biometric:
        return await _executeBiometric(decision.reason ?? 'Verify your identity');

      case StepUpType.liveness:
        return await _executeLiveness(decision.challengeToken);

      case StepUpType.biometricAndLiveness:
        final biometricOk = await _executeBiometric('First, verify with biometric');
        if (!biometricOk) return false;
        return await _executeLiveness(decision.challengeToken);

      case StepUpType.otp:
        // OTP handled separately via UI
        return false;

      case StepUpType.manualReview:
        // Cannot proceed automatically
        throw ManualReviewRequiredException(
          'This transaction requires manual review by our team',
        );
    }
  }

  /// Execute biometric verification
  Future<bool> _executeBiometric(String reason) async {
    final isEnabled = await _biometricService.isBiometricEnabled();
    if (!isEnabled) {
      // Biometric not enabled, allow (user preference)
      return true;
    }

    final result = await _biometricService.authenticate(localizedReason: reason);
    return result.success;
  }

  /// Execute liveness verification
  Future<bool> _executeLiveness(String? challengeToken) async {
    try {
      final session = await _livenessService.createSession();

      // Note: In production, UI should show LivenessCheckWidget
      // and handle the actual liveness flow
      AppLogger('Debug').debug('Liveness session started: ${session.sessionToken}');

      // Return false to indicate UI should handle liveness
      // The calling code should show the liveness widget
      return false;
    } catch (e) {
      AppLogger('Liveness check failed').error('Liveness check failed', e);
      return false;
    }
  }

  /// Validate completed step-up with backend
  Future<bool> validateStepUp({
    required String challengeToken,
    String? livenessSessionId,
    bool? biometricVerified,
  }) async {
    try {
      final response = await _dio.post('/step-up/validate', data: {
        'challengeToken': challengeToken,
        'livenessSessionId': livenessSessionId,
        'biometricVerified': biometricVerified,
      });

      return response.data['success'] == true && response.data['data']['valid'] == true;
    } catch (e) {
      AppLogger('Step-up validation failed').error('Step-up validation failed', e);
      return false;
    }
  }

  /// Get default operation decision when backend is unavailable
  StepUpDecision _getDefaultOperationDecision(String operation) {
    final Map<String, StepUpType> defaults = {
      'pin_change': StepUpType.biometric,
      'add_recipient': StepUpType.biometric,
      'account_recovery': StepUpType.liveness,
      'kyc_selfie': StepUpType.liveness,
      'export_keys': StepUpType.biometricAndLiveness,
      'delete_account': StepUpType.biometricAndLiveness,
    };

    final stepUpType = defaults[operation] ?? StepUpType.biometric;
    final flow = stepUpType == StepUpType.liveness || stepUpType == StepUpType.biometricAndLiveness
        ? RiskFlow.red
        : stepUpType == StepUpType.biometric
            ? RiskFlow.yellow
            : RiskFlow.green;

    return StepUpDecision(
      flow: flow,
      riskScore: flow == RiskFlow.green ? 10 : flow == RiskFlow.yellow ? 45 : 75,
      riskLevel: flow == RiskFlow.green ? 'low' : flow == RiskFlow.yellow ? 'medium' : 'high',
      stepUpRequired: stepUpType != StepUpType.none,
      stepUpType: stepUpType,
      localizedReason: 'Verification required for $operation',
      factors: ['operation:$operation', 'fallback_mode'],
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
    );
  }

  // --- Convenience Methods ---

  /// Guard for external transfers with risk-based step-up
  Future<({bool approved, StepUpDecision decision})> guardExternalTransfer({
    required double amount,
    required String currency,
    required String recipientId,
    bool isFirstTransaction = false,
  }) async {
    final decision = await evaluateTransaction(
      type: 'transfer',
      amount: amount,
      currency: currency,
      recipientId: recipientId,
      recipientType: 'external',
      isFirstTransactionToRecipient: isFirstTransaction,
    );

    AppLogger('Debug').debug('${decision.flowEmoji} Transfer \$$amount: ${decision.stepUpType.name} (score: ${decision.riskScore})');

    if (!decision.stepUpRequired) {
      return (approved: true, decision: decision);
    }

    // For liveness, return decision so UI can show liveness widget
    if (decision.stepUpType == StepUpType.liveness ||
        decision.stepUpType == StepUpType.biometricAndLiveness) {
      return (approved: false, decision: decision);
    }

    // Execute biometric
    final verified = await executeStepUp(decision);
    return (approved: verified, decision: decision);
  }

  /// Guard for withdrawal with risk-based step-up
  Future<({bool approved, StepUpDecision decision})> guardWithdrawal({
    required double amount,
    required String currency,
    required String recipientId,
    bool isFirstWithdrawal = false,
  }) async {
    final decision = await evaluateTransaction(
      type: 'withdrawal',
      amount: amount,
      currency: currency,
      recipientId: recipientId,
      recipientType: 'external',
      isFirstTransactionToRecipient: isFirstWithdrawal,
    );

    AppLogger('Debug').debug('${decision.flowEmoji} Withdrawal \$$amount: ${decision.stepUpType.name} (score: ${decision.riskScore})');

    if (!decision.stepUpRequired) {
      return (approved: true, decision: decision);
    }

    if (decision.stepUpType == StepUpType.liveness ||
        decision.stepUpType == StepUpType.biometricAndLiveness) {
      return (approved: false, decision: decision);
    }

    final verified = await executeStepUp(decision);
    return (approved: verified, decision: decision);
  }

  /// Guard for PIN change
  Future<({bool approved, StepUpDecision decision})> guardPinChange() async {
    final decision = await evaluateOperation(operation: 'pin_change');

    if (!decision.stepUpRequired) {
      return (approved: true, decision: decision);
    }

    final verified = await executeStepUp(decision);
    return (approved: verified, decision: decision);
  }

  /// Guard for KYC selfie - always requires liveness
  Future<StepUpDecision> guardKycSelfie() async {
    return await evaluateOperation(operation: 'kyc_selfie');
  }

  /// Guard for account recovery - always requires liveness
  Future<StepUpDecision> guardAccountRecovery() async {
    return await evaluateOperation(operation: 'account_recovery');
  }

  /// Pre-screen a blockchain address before showing transfer form
  /// This provides early feedback to users about blocked addresses
  Future<AddressScreeningResult> screenAddress({
    required String address,
    String blockchain = 'polygon',
  }) async {
    try {
      final response = await _dio.post('/risk/screen-address', data: {
        'address': address,
        'blockchain': blockchain,
      });

      if (response.data['success'] == true) {
        return AddressScreeningResult.fromJson(response.data['data']);
      }

      // If API returns success: false, treat as error
      return AddressScreeningResult(
        address: address,
        decision: 'DENIED',
        riskSignals: ['Screening service error'],
        provider: 'error',
      );
    } catch (e) {
      AppLogger('Address screening failed').error('Address screening failed', e);
      // On network error, return unknown - let backend block at transfer time
      return AddressScreeningResult(
        address: address,
        decision: 'UNKNOWN',
        riskSignals: ['Screening unavailable'],
        provider: 'error',
      );
    }
  }

  /// Check if an address is safe for transactions
  /// Returns user-friendly result
  Future<({bool safe, String? warning})> isAddressSafe(String address) async {
    final result = await screenAddress(address: address);

    if (result.decision == 'DENIED') {
      return (
        safe: false,
        warning: 'This address has been flagged by our compliance system. '
            'Transfers to this address are not allowed.',
      );
    }

    if (result.decision == 'UNKNOWN') {
      return (
        safe: true, // Let backend handle final decision
        warning: null,
      );
    }

    // Check for warning signals
    if (result.riskSignals.isNotEmpty) {
      final warnings = result.riskSignals.where((s) =>
        s.contains('HIGH_RISK') || s.contains('PEP')
      ).toList();

      if (warnings.isNotEmpty) {
        return (
          safe: true,
          warning: 'This address has elevated risk signals. '
              'Additional verification may be required.',
        );
      }
    }

    return (safe: true, warning: null);
  }
}

/// Address screening result
class AddressScreeningResult {
  final String address;
  final String decision; // APPROVED, DENIED, UNKNOWN
  final List<String> riskSignals;
  final String provider;

  AddressScreeningResult({
    required this.address,
    required this.decision,
    required this.riskSignals,
    required this.provider,
  });

  factory AddressScreeningResult.fromJson(Map<String, dynamic> json) {
    return AddressScreeningResult(
      address: json['address'] ?? '',
      decision: json['decision'] ?? 'UNKNOWN',
      riskSignals: List<String>.from(json['riskSignals'] ?? []),
      provider: json['provider'] ?? 'unknown',
    );
  }

  bool get isApproved => decision == 'APPROVED';
  bool get isDenied => decision == 'DENIED';
  bool get isUnknown => decision == 'UNKNOWN';
}

/// Exception for compliance blocked address
class ComplianceBlockedException implements Exception {
  final String message;
  final String address;
  final List<String> reasons;

  ComplianceBlockedException({
    required this.message,
    required this.address,
    this.reasons = const [],
  });

  @override
  String toString() => message;
}

/// Exception for manual review required
class ManualReviewRequiredException implements Exception {
  final String message;
  ManualReviewRequiredException(this.message);

  @override
  String toString() => message;
}

/// Provider for RiskBasedSecurityService
final riskBasedSecurityServiceProvider = Provider<RiskBasedSecurityService>((ref) {
  return RiskBasedSecurityService(
    dio: ref.watch(dioProvider),
    biometricService: ref.watch(biometricServiceProvider),
    livenessService: ref.watch(livenessServiceProvider),
  );
});
