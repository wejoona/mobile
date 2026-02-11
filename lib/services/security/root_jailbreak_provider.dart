import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/device_security.dart';

/// État de la détection root/jailbreak
class RootJailbreakState {
  final bool isChecked;
  final bool isCompromised;
  final List<String> threats;
  final DateTime? lastCheckedAt;

  const RootJailbreakState({
    this.isChecked = false,
    this.isCompromised = false,
    this.threats = const [],
    this.lastCheckedAt,
  });

  RootJailbreakState copyWith({
    bool? isChecked,
    bool? isCompromised,
    List<String>? threats,
    DateTime? lastCheckedAt,
  }) => RootJailbreakState(
    isChecked: isChecked ?? this.isChecked,
    isCompromised: isCompromised ?? this.isCompromised,
    threats: threats ?? this.threats,
    lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
  );
}

/// Fournisseur Riverpod pour la détection root/jailbreak.
///
/// Vérifie si l'appareil est compromis (rooté ou jailbreaké)
/// et maintient l'état en cache pour la session.
class RootJailbreakNotifier extends StateNotifier<RootJailbreakState> {
  final DeviceSecurity _deviceSecurity;

  RootJailbreakNotifier({DeviceSecurity? deviceSecurity})
      : _deviceSecurity = deviceSecurity ?? DeviceSecurity(),
        super(const RootJailbreakState());

  Future<void> checkDevice() async {
    final result = await _deviceSecurity.checkSecurity();
    state = state.copyWith(
      isChecked: true,
      isCompromised: !result.isSecure,
      threats: result.threats,
      lastCheckedAt: DateTime.now(),
    );
  }

  bool get shouldBlockAccess => state.isCompromised;
}

final rootJailbreakProvider =
    StateNotifierProvider<RootJailbreakNotifier, RootJailbreakState>((ref) {
  return RootJailbreakNotifier();
});
