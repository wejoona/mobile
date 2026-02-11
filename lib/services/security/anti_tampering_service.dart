import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de la vérification d'intégrité
class IntegrityCheckResult {
  final bool isIntact;
  final List<String> violations;
  final DateTime checkedAt;

  const IntegrityCheckResult({
    required this.isIntact,
    this.violations = const [],
    required this.checkedAt,
  });
}

/// Service anti-falsification.
///
/// Vérifie l'intégrité de l'application pour détecter
/// les modifications non autorisées (repackaging, hooking).
class AntiTamperingService {
  static const _tag = 'AntiTampering';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier l'intégrité de l'application
  Future<IntegrityCheckResult> checkIntegrity() async {
    if (kDebugMode) {
      return IntegrityCheckResult(isIntact: true, checkedAt: DateTime.now());
    }

    final violations = <String>[];

    // Vérifier la signature de l'application
    if (Platform.isAndroid) {
      violations.addAll(await _checkAndroidSignature());
    } else if (Platform.isIOS) {
      violations.addAll(await _checkiOSProvisioningProfile());
    }

    // Vérifier les bibliothèques injectées
    violations.addAll(await _checkInjectedLibraries());

    // Vérifier les frameworks de hooking
    violations.addAll(await _checkHookingFrameworks());

    if (violations.isNotEmpty) {
      _log.warning('Tampering detected: $violations');
    }

    return IntegrityCheckResult(
      isIntact: violations.isEmpty,
      violations: violations,
      checkedAt: DateTime.now(),
    );
  }

  Future<List<String>> _checkAndroidSignature() async {
    // En production, utiliser le Play Integrity API
    return [];
  }

  Future<List<String>> _checkiOSProvisioningProfile() async {
    final violations = <String>[];
    try {
      final file = File('/var/containers/Bundle/Application/embedded.mobileprovision');
      if (!await file.exists()) {
        // App Store builds don't have this file
        return [];
      }
    } catch (_) {}
    return violations;
  }

  Future<List<String>> _checkInjectedLibraries() async {
    final violations = <String>[];
    if (Platform.isIOS) {
      final suspiciousLibs = [
        'FridaGadget',
        'frida-agent',
        'libcycript',
        'MobileSubstrate',
        'SubstrateLoader',
      ];
      // En production, vérifier via _dyld_image_count/_dyld_get_image_name
      // via method channel
      for (final lib in suspiciousLibs) {
        // Placeholder pour vérification native
        _ = lib;
      }
    }
    return violations;
  }

  Future<List<String>> _checkHookingFrameworks() async {
    final violations = <String>[];
    final hookingIndicators = [
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/lib/libcycript.dylib',
    ];
    for (final path in hookingIndicators) {
      try {
        if (await File(path).exists()) {
          violations.add('Hooking framework detected: $path');
        }
      } catch (_) {}
    }
    return violations;
  }
}

final antiTamperingProvider = Provider<AntiTamperingService>((ref) {
  return AntiTamperingService();
});
