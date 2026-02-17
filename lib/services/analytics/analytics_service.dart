import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service d'analytics utilisant Firebase Analytics.
///
/// Règles :
/// - Pas de PII (pas de numéros de téléphone, pas de montants exacts)
/// - Uniquement des compteurs et catégories
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  bool _initialized = false;
  final List<AnalyticsEvent> _pendingEvents = [];
  FirebaseAnalytics? _firebase;

  Future<void> initialize() async {
    try {
      _firebase = FirebaseAnalytics.instance;
      _initialized = true;
      // Flush pending events
      for (final event in _pendingEvents) {
        await _sendEvent(event);
      }
      _pendingEvents.clear();
      if (kDebugMode) debugPrint('[Analytics] Initialized with Firebase');
    } catch (e) {
      if (kDebugMode) debugPrint('[Analytics] Firebase init failed: $e');
      _initialized = true; // Continue without Firebase
    }
  }

  // ============================================================
  // Suivi d'écrans
  // ============================================================

  void trackScreen(String screenName, {Map<String, dynamic>? properties}) {
    _firebase?.logScreenView(screenName: screenName);
    _track(AnalyticsEvent(
      name: 'screen_view',
      properties: {'screen_name': screenName, ...?properties},
    ));
  }

  // ============================================================
  // Événements clés
  // ============================================================

  void trackLogin({required String method}) {
    _track(AnalyticsEvent(
      name: 'login',
      properties: {'method': method},
    ));
  }

  void trackRegistration({required String country}) {
    _track(AnalyticsEvent(
      name: 'registration',
      properties: {'country': country},
    ));
  }

  void trackSendMoney({required String currency, required String recipientType, required bool success}) {
    _track(AnalyticsEvent(
      name: 'send_money',
      properties: {
        'currency': currency,
        'recipient_type': recipientType,
        'success': success,
      },
    ));
  }

  void trackReceiveMoney({required String currency}) {
    _track(AnalyticsEvent(
      name: 'receive_money',
      properties: {'currency': currency},
    ));
  }

  void trackKycStarted() {
    _track(AnalyticsEvent(name: 'kyc_started'));
  }

  void trackKycCompleted({required bool success}) {
    _track(AnalyticsEvent(
      name: 'kyc_completed',
      properties: {'success': success},
    ));
  }

  void trackDeposit({required String method, required bool success}) {
    _track(AnalyticsEvent(
      name: 'deposit',
      properties: {'method': method, 'success': success},
    ));
  }

  void trackWithdraw({required String method, required bool success}) {
    _track(AnalyticsEvent(
      name: 'withdraw',
      properties: {'method': method, 'success': success},
    ));
  }

  // ============================================================
  // Méthodes génériques (rétrocompatibilité)
  // ============================================================

  void trackAction(String action, {Map<String, dynamic>? properties}) {
    _track(AnalyticsEvent(
      name: action,
      properties: properties ?? {},
    ));
  }

  void trackSend({
    required double amount,
    required String currency,
    required String recipientType,
    required bool success,
  }) {
    // Ne pas envoyer le montant exact — uniquement la tranche
    _track(AnalyticsEvent(
      name: 'transfer_initiated',
      properties: {
        'amount_range': _amountRange(amount),
        'currency': currency,
        'recipient_type': recipientType,
        'success': success,
      },
    ));
  }

  void trackDeposit2({
    required String method,
    required double amount,
    required bool success,
  }) {
    _track(AnalyticsEvent(
      name: 'deposit_initiated',
      properties: {
        'method': method,
        'amount_range': _amountRange(amount),
        'success': success,
      },
    ));
  }

  void trackKycStep(String step, {bool completed = false}) {
    _track(AnalyticsEvent(
      name: 'kyc_step',
      properties: {
        'step': step,
        'completed': completed,
      },
    ));
  }

  void trackError(String errorType, String message) {
    _track(AnalyticsEvent(
      name: 'error',
      properties: {
        'error_type': errorType,
        // Ne pas envoyer le message complet — peut contenir des PII
        'message_hash': message.hashCode.toString(),
      },
    ));
  }

  void setUserProperties({
    String? userId,
    String? kycStatus,
    String? country,
    String? locale,
  }) {
    if (userId != null) _firebase?.setUserId(id: userId);
    if (kycStatus != null) _firebase?.setUserProperty(name: 'kyc_status', value: kycStatus);
    if (country != null) _firebase?.setUserProperty(name: 'country', value: country);
    if (locale != null) _firebase?.setUserProperty(name: 'locale', value: locale);
  }

  void setUserProperty(String name, dynamic value) {
    _firebase?.setUserProperty(name: name, value: value?.toString());
  }

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
        if (entry.value is String || entry.value is int || entry.value is double || entry.value is bool) {
          params[entry.key] = entry.value as Object;
        }
      }

      await _firebase?.logEvent(name: event.name, parameters: params);
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
