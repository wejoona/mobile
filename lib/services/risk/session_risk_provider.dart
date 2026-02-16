import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/services/security/security_headers_interceptor.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Session risk data returned from POST /risk/session
class SessionRiskData {
  final String sessionRiskToken;
  final String riskLevel;
  final int deviceTrust;
  final List<String> requiredActions;

  SessionRiskData({
    required this.sessionRiskToken,
    required this.riskLevel,
    required this.deviceTrust,
    required this.requiredActions,
  });

  factory SessionRiskData.fromJson(Map<String, dynamic> json) {
    return SessionRiskData(
      sessionRiskToken: json['sessionRiskToken'] ?? '',
      riskLevel: json['riskLevel'] ?? 'unknown',
      deviceTrust: json['deviceTrust'] ?? 0,
      requiredActions: List<String>.from(json['requiredActions'] ?? []),
    );
  }
}

/// Notifier holding current session risk data (Riverpod 3.x compatible)
class SessionRiskNotifier extends Notifier<SessionRiskData?> {
  @override
  SessionRiskData? build() => null;

  void set(SessionRiskData data) {
    state = data;
  }

  void clear() {
    state = null;
  }
}

final sessionRiskProvider =
    NotifierProvider<SessionRiskNotifier, SessionRiskData?>(
  SessionRiskNotifier.new,
);

/// Convenience provider for just the token
final sessionRiskTokenProvider = Provider<String?>((ref) {
  return ref.watch(sessionRiskProvider)?.sessionRiskToken;
});

/// Timer handle for auto-refresh
Timer? _sessionRiskRefreshTimer;

/// Assess session risk — call on app start, auto-refreshes every 30 min
Future<void> assessSessionRisk(WidgetRef ref) async {
  await _doAssess(ref);
}

/// Overload for use inside providers/notifiers with a Ref
Future<void> assessSessionRiskFromRef(Ref ref) async {
  await _doAssessRef(ref);
}

Future<void> _doAssess(WidgetRef ref) async {
  final logger = AppLogger('SessionRisk');
  try {
    final dio = ref.read(dioProvider);
    final fpService = ref.read(deviceFingerprintServiceProvider);
    final fp = await fpService.collect();

    final response = await dio.post('/risk/session', data: {
      'deviceFingerprint': fp.deviceId,
      'appVersion': fp.appVersion,
    });

    // ignore: avoid_dynamic_calls
    if (response.data['success'] == true) {
      // ignore: avoid_dynamic_calls
      final data = SessionRiskData.fromJson(response.data['data']);
      ref.read(sessionRiskProvider.notifier).set(data);
      // Set token on the security headers interceptor
      ref.read(securityHeadersInterceptorProvider).sessionRiskToken =
          data.sessionRiskToken;
      if (kDebugMode) {
        logger.debug('Session risk assessed: ${data.riskLevel}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      logger.debug('Session risk assessment failed (non-blocking): $e');
    }
  }

  // Schedule refresh every 30 minutes
  _sessionRiskRefreshTimer?.cancel();
  _sessionRiskRefreshTimer = Timer(const Duration(minutes: 30), () {
    _doAssess(ref);
  });
}

Future<void> _doAssessRef(Ref ref) async {
  final logger = AppLogger('SessionRisk');
  try {
    final dio = ref.read(dioProvider);
    final fpService = ref.read(deviceFingerprintServiceProvider);
    final fp = await fpService.collect();

    final response = await dio.post('/risk/session', data: {
      'deviceFingerprint': fp.deviceId,
      'appVersion': fp.appVersion,
    });

    // ignore: avoid_dynamic_calls
    if (response.data['success'] == true) {
      // ignore: avoid_dynamic_calls
      final data = SessionRiskData.fromJson(response.data['data']);
      ref.read(sessionRiskProvider.notifier).set(data);
      ref.read(securityHeadersInterceptorProvider).sessionRiskToken =
          data.sessionRiskToken;
      if (kDebugMode) {
        logger.debug('Session risk assessed: ${data.riskLevel}');
      }
    }
  } catch (e) {
    if (kDebugMode) {
      logger.debug('Session risk assessment failed (non-blocking): $e');
    }
  }
}
