import 'dart:async';

/// Run 370: Analytics service for tracking user events and screens
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._();
  factory AnalyticsService() => _instance;
  AnalyticsService._();

  bool _initialized = false;
  final List<AnalyticsEvent> _pendingEvents = [];

  Future<void> initialize() async {
    _initialized = true;
    // Flush pending events
    for (final event in _pendingEvents) {
      await _sendEvent(event);
    }
    _pendingEvents.clear();
  }

  void trackScreen(String screenName, {Map<String, dynamic>? properties}) {
    _track(AnalyticsEvent(
      name: 'screen_view',
      properties: {'screen_name': screenName, ...?properties},
    ));
  }

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
    _track(AnalyticsEvent(
      name: 'transfer_initiated',
      properties: {
        'amount': amount,
        'currency': currency,
        'recipient_type': recipientType,
        'success': success,
      },
    ));
  }

  void trackDeposit({
    required String method,
    required double amount,
    required bool success,
  }) {
    _track(AnalyticsEvent(
      name: 'deposit_initiated',
      properties: {
        'method': method,
        'amount': amount,
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
        'message': message,
      },
    ));
  }

  void setUserProperties({
    String? userId,
    String? kycStatus,
    String? country,
    String? locale,
  }) {
    // Set user-level properties for analytics segmentation
  }

  void _track(AnalyticsEvent event) {
    if (!_initialized) {
      _pendingEvents.add(event);
      return;
    }
    _sendEvent(event);
  }

  Future<void> _sendEvent(AnalyticsEvent event) async {
    // Integration point for analytics backend (Mixpanel, Amplitude, etc.)
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

  void setUserProperty(String name, String value) {}

}
