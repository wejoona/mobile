import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Service de détection du débogage.
///
/// Détecte si l'application est exécutée en mode debug,
/// si un débogueur est attaché, ou si des outils
/// d'instrumentation sont actifs.
class DebugDetectionService {
  static const _tag = 'DebugDetection';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier si le mode debug est actif
  bool get isDebugMode => kDebugMode;

  /// Vérifier si un débogueur est attaché
  bool get isDebuggerAttached {
    bool attached = false;
    assert(() {
      attached = true;
      return true;
    }());
    return attached;
  }

  /// Vérifier si l'application est en mode profil
  bool get isProfileMode => kProfileMode;

  /// Vérifier si l'application est en mode release
  bool get isReleaseMode => kReleaseMode;

  /// Vérification complète de l'environnement de débogage
  Future<DebugDetectionResult> detectDebugEnvironment() async {
    final indicators = <String>[];

    if (isDebugMode) indicators.add('Debug mode active');
    if (isDebuggerAttached) indicators.add('Debugger attached');
    if (isProfileMode) indicators.add('Profile mode');

    // Vérifier les ports de débogage courants
    if (await _checkDebugPorts()) {
      indicators.add('Debug ports open');
    }

    // Vérifier les variables d'environnement suspectes
    if (_checkDebugEnvVars()) {
      indicators.add('Debug environment variables detected');
    }

    return DebugDetectionResult(
      isDebugEnvironment: indicators.isNotEmpty && !kDebugMode,
      indicators: indicators,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _checkDebugPorts() async {
    final debugPorts = [8888, 5037, 27042]; // Frida, ADB, etc.
    for (final port in debugPorts) {
      try {
        final socket = await Socket.connect('127.0.0.1', port,
            timeout: const Duration(milliseconds: 100));
        socket.destroy();
        return true;
      } catch (_) {}
    }
    return false;
  }

  bool _checkDebugEnvVars() {
    final suspiciousVars = ['DYLD_INSERT_LIBRARIES', 'LD_PRELOAD'];
    for (final v in suspiciousVars) {
      if (Platform.environment.containsKey(v)) return true;
    }
    return false;
  }
}

class DebugDetectionResult {
  final bool isDebugEnvironment;
  final List<String> indicators;
  final DateTime checkedAt;

  const DebugDetectionResult({
    required this.isDebugEnvironment,
    this.indicators = const [],
    required this.checkedAt,
  });
}

final debugDetectionProvider = Provider<DebugDetectionService>((ref) {
  return DebugDetectionService();
});
