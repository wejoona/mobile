import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lightweight analytics facade.
///
/// Règles :
/// - Pas de PII (pas de numéros de téléphone, pas de montants exacts)
/// - Uniquement des compteurs et catégories
///
/// Firebase Analytics is intentionally not wired in the MVP mobile build. Core
/// wallet QA and privacy posture are more important than ad/measurement SDK
/// weight during team dogfood.
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  bool _initialized = false;
  final List<AnalyticsEvent> _pendingEvents = [];

  Future<void> initialize() async {
    _initialized = true;
    for (final event in _pendingEvents) {
      await _sendEvent(event);
    }
    _pendingEvents.clear();
    if (kDebugMode) debugPrint('[Analytics] Initialized local analytics');
  }

  // ============================================================
  // Suivi d'écrans
  // ============================================================

  void trackScreen(String screenName, {Map<String, dynamic>? properties}) {
    _track(
      AnalyticsEvent(
        name: 'screen_view',
        properties: {'screen_name': screenName, ...?properties},
      ),
    );
  }

  // ============================================================
  // Événements clés
  // ============================================================

  void trackLogin({required String method}) {
    _track(AnalyticsEvent(name: 'login', properties: {'method': method}));
  }

  Future<void> logLoginSuccess({required String method, String? userId}) async {
    trackLogin(method: method);
    if (userId != null) await setUserId(userId);
  }

  Future<void> logLoginFailed({
    required String method,
    required String reason,
  }) async {
    trackAction(
      'login_failed',
      properties: {'method': method, 'reason_hash': reason.hashCode.toString()},
    );
  }

  void trackRegistration({required String country}) {
    _track(
      AnalyticsEvent(name: 'registration', properties: {'country': country}),
    );
  }

  void trackSendMoney({
    required String currency,
    required String recipientType,
    required bool success,
  }) {
    _track(
      AnalyticsEvent(
        name: 'send_money',
        properties: {
          'currency': currency,
          'recipient_type': recipientType,
          'success': success,
        },
      ),
    );
  }

  void trackReceiveMoney({required String currency}) {
    _track(
      AnalyticsEvent(name: 'receive_money', properties: {'currency': currency}),
    );
  }

  void trackKycStarted() {
    _track(AnalyticsEvent(name: 'kyc_started'));
  }

  void trackKycCompleted({required bool success}) {
    _track(
      AnalyticsEvent(name: 'kyc_completed', properties: {'success': success}),
    );
  }

  void trackDeposit({required String method, required bool success}) {
    _track(
      AnalyticsEvent(
        name: 'deposit',
        properties: {'method': method, 'success': success},
      ),
    );
  }

  void trackWithdraw({required String method, required bool success}) {
    _track(
      AnalyticsEvent(
        name: 'withdraw',
        properties: {'method': method, 'success': success},
      ),
    );
  }

  // ============================================================
  // Méthodes génériques (rétrocompatibilité)
  // ============================================================

  Future<void> logTransferInitiated({
    required String transferType,
    required double amount,
    required String currency,
  }) {
    trackSend(
      amount: amount,
      currency: currency,
      recipientType: transferType,
      success: false,
    );
    return Future<void>.value();
  }

  Future<void> logTransferCompleted({
    required String transferType,
    required double amount,
    required String currency,
    String? transactionId,
  }) {
    trackAction(
      'transfer_completed',
      properties: {
        'amount_range': _amountRange(amount),
        'currency': currency,
        'transfer_type': transferType,
        if (transactionId != null)
          'transaction_id_hash': transactionId.hashCode.toString(),
      },
    );
    return Future<void>.value();
  }

  Future<void> logTransferFailed({
    required String transferType,
    required double amount,
    required String currency,
    required String reason,
  }) {
    trackAction(
      'transfer_failed',
      properties: {
        'amount_range': _amountRange(amount),
        'currency': currency,
        'transfer_type': transferType,
        'reason_hash': reason.hashCode.toString(),
      },
    );
    return Future<void>.value();
  }

  Future<void> logKycStarted({String? tier}) {
    trackAction('kyc_started', properties: {if (tier != null) 'tier': tier});
    return Future<void>.value();
  }

  Future<void> logKycCompleted({String? tier, required String status}) {
    trackAction(
      'kyc_completed',
      properties: {if (tier != null) 'tier': tier, 'status': status},
    );
    return Future<void>.value();
  }

  Future<void> logDepositInitiated({
    required String method,
    required double amount,
    required String currency,
  }) {
    trackAction(
      'deposit_initiated',
      properties: {
        'method': method,
        'amount_range': _amountRange(amount),
        'currency': currency,
      },
    );
    return Future<void>.value();
  }

  Future<void> logDepositCompleted({
    required String method,
    required double amount,
    required String currency,
    String? transactionId,
  }) {
    trackAction(
      'deposit_completed',
      properties: {
        'method': method,
        'amount_range': _amountRange(amount),
        'currency': currency,
        if (transactionId != null)
          'transaction_id_hash': transactionId.hashCode.toString(),
      },
    );
    return Future<void>.value();
  }

  Future<void> logBillPaymentCompleted({
    required String billerName,
    required String category,
    required double amount,
    required String currency,
    String? transactionId,
  }) {
    trackAction(
      'bill_payment_completed',
      properties: {
        'biller_hash': billerName.hashCode.toString(),
        'category': category,
        'amount_range': _amountRange(amount),
        'currency': currency,
        if (transactionId != null)
          'transaction_id_hash': transactionId.hashCode.toString(),
      },
    );
    return Future<void>.value();
  }

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) {
    trackScreen(
      screenName,
      properties: {if (screenClass != null) 'screen_class': screenClass},
    );
    return Future<void>.value();
  }

  Future<void> setUserId(String? userId) async {}

  Future<void> reset() async {
    _pendingEvents.clear();
  }

  void trackAction(String action, {Map<String, dynamic>? properties}) {
    _track(AnalyticsEvent(name: action, properties: properties ?? {}));
  }

  void trackSend({
    required double amount,
    required String currency,
    required String recipientType,
    required bool success,
  }) {
    // Ne pas envoyer le montant exact — uniquement la tranche
    _track(
      AnalyticsEvent(
        name: 'transfer_initiated',
        properties: {
          'amount_range': _amountRange(amount),
          'currency': currency,
          'recipient_type': recipientType,
          'success': success,
        },
      ),
    );
  }

  void trackDeposit2({
    required String method,
    required double amount,
    required bool success,
  }) {
    _track(
      AnalyticsEvent(
        name: 'deposit_initiated',
        properties: {
          'method': method,
          'amount_range': _amountRange(amount),
          'success': success,
        },
      ),
    );
  }

  void trackKycStep(String step, {bool completed = false}) {
    _track(
      AnalyticsEvent(
        name: 'kyc_step',
        properties: {'step': step, 'completed': completed},
      ),
    );
  }

  void trackError(String errorType, String message) {
    _track(
      AnalyticsEvent(
        name: 'error',
        properties: {
          'error_type': errorType,
          // Ne pas envoyer le message complet — peut contenir des PII
          'message_hash': message.hashCode.toString(),
        },
      ),
    );
  }

  Future<void> setUserProperties({
    String? userId,
    String? kycStatus,
    String? country,
    String? locale,
  }) {
    if (kDebugMode) {
      debugPrint(
        '[Analytics] user_properties ${{if (userId != null) 'user_id_hash': userId.hashCode.toString(), if (kycStatus != null) 'kyc_status': kycStatus, if (country != null) 'country': country, if (locale != null) 'locale': locale}}',
      );
    }
    return Future<void>.value();
  }

  Future<void> setUserProperty(String name, dynamic value) async {}

  // ============================================================
  // Internals
  // ============================================================

  void _track(AnalyticsEvent event) {
    if (!_initialized) {
      _pendingEvents.add(event);
      return;
    }
    _sendEvent(event);
  }

  Future<void> _sendEvent(AnalyticsEvent event) async {
    try {
      // Filtrer les propriétés pour Firebase (seulement String/int/double/bool)
      final params = <String, Object>{};
      for (final entry in event.properties.entries) {
        if (entry.value is String ||
            entry.value is int ||
            entry.value is double ||
            entry.value is bool) {
          params[entry.key] = entry.value as Object;
        }
      }

      if (kDebugMode) debugPrint('[Analytics] ${event.name} $params');
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Failed to send event: $e');
    }
  }

  /// Convertir un montant en tranche (pas de PII)
  String _amountRange(double amount) {
    if (amount < 10) return 'under_10';
    if (amount < 50) return '10_50';
    if (amount < 100) return '50_100';
    if (amount < 500) return '100_500';
    if (amount < 1000) return '500_1000';
    return 'over_1000';
  }
}

class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    this.properties = const {},
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Provider Riverpod
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
