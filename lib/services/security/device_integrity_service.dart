import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/device_security.dart';
import 'package:usdc_wallet/services/security/debug_detection_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';

/// Service d'intégrité de l'appareil.
///
/// Vérifie root/jailbreak, débogueur et émulateur au démarrage.
/// Affiche un avertissement (sans bloquer) et journalise vers analytics.
class DeviceIntegrityService {
  final DeviceSecurity _deviceSecurity;
  final DebugDetectionService _debugDetection;
  final AnalyticsService _analytics;

  DeviceIntegrityService({
    DeviceSecurity? deviceSecurity,
    DebugDetectionService? debugDetection,
    required AnalyticsService analytics,
  })  : _deviceSecurity = deviceSecurity ?? DeviceSecurity(),
        _debugDetection = debugDetection ?? DebugDetectionService(),
        _analytics = analytics;

  DeviceSecurityResult? _lastResult;

  /// Résultat du dernier contrôle
  DeviceSecurityResult? get lastResult => _lastResult;

  /// Exécuter tous les contrôles d'intégrité
  Future<DeviceIntegrityReport> checkAll() async {
    final securityResult = await _deviceSecurity.checkSecurity();
    final debugResult = await _debugDetection.detectDebugEnvironment();

    _lastResult = securityResult;

    final threats = <String>[
      ...securityResult.threats,
      if (debugResult.isDebugEnvironment) ...debugResult.indicators,
    ];

    final report = DeviceIntegrityReport(
      isSecure: securityResult.isSecure && !debugResult.isDebugEnvironment,
      isRooted: securityResult.threats.any(
        (t) => t.contains('Root') || t.contains('root') || t.contains('Jailbreak') || t.contains('jailbreak'),
      ),
      isEmulator: securityResult.threats.any((t) => t.contains('emulator') || t.contains('simulator')),
      isDebuggerAttached: _debugDetection.isDebuggerAttached && !kDebugMode,
      threats: threats,
      checkedAt: DateTime.now(),
    );

    // Journaliser vers analytics (pas de PII)
    if (!report.isSecure) {
      _analytics.trackAction('device_integrity_warning', properties: {
        'is_rooted': report.isRooted,
        'is_emulator': report.isEmulator,
        'is_debugger': report.isDebuggerAttached,
        'threat_count': threats.length,
      });
    }

    return report;
  }

  /// Afficher un dialogue d'avertissement si l'appareil est compromis.
  /// Ne bloque pas l'accès — avertissement uniquement.
  static Future<void> showWarningIfNeeded(
    BuildContext context,
    DeviceIntegrityReport report,
  ) async {
    if (report.isSecure) return;

    final messages = <String>[];
    if (report.isRooted) {
      messages.add('Cet appareil semble être rooté ou jailbreaké.');
    }
    if (report.isEmulator) {
      messages.add('L\'application s\'exécute sur un émulateur.');
    }
    if (report.isDebuggerAttached) {
      messages.add('Un débogueur est détecté.');
    }

    if (messages.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Avertissement de sécurité'),
        content: Text(
          '${messages.join('\n\n')}\n\n'
          'Votre sécurité pourrait être compromise. '
          'Nous vous recommandons d\'utiliser un appareil non modifié.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }
}

/// Rapport d'intégrité de l'appareil
class DeviceIntegrityReport {
  final bool isSecure;
  final bool isRooted;
  final bool isEmulator;
  final bool isDebuggerAttached;
  final List<String> threats;
  final DateTime checkedAt;

  const DeviceIntegrityReport({
    required this.isSecure,
    required this.isRooted,
    required this.isEmulator,
    required this.isDebuggerAttached,
    required this.threats,
    required this.checkedAt,
  });
}

/// Provider pour le service d'intégrité
final deviceIntegrityServiceProvider = Provider<DeviceIntegrityService>((ref) {
  final analytics = ref.read(analyticsServiceProvider);
  return DeviceIntegrityService(analytics: analytics);
});

/// Provider pour le rapport d'intégrité (charge au démarrage)
final deviceIntegrityReportProvider = FutureProvider<DeviceIntegrityReport>((ref) async {
  final service = ref.read(deviceIntegrityServiceProvider);
  return service.checkAll();
});
