import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/biometric/biometric_provider.dart';

/// Biometric Settings State
class BiometricSettings {
  const BiometricSettings({
    this.isBiometricEnabled = false,
    this.requireForAppUnlock = true,
  });

  final bool isBiometricEnabled;
  final bool requireForAppUnlock;

  BiometricSettings copyWith({
    bool? isBiometricEnabled,
    bool? requireForAppUnlock,
  }) => BiometricSettings(
    isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    requireForAppUnlock: requireForAppUnlock ?? this.requireForAppUnlock,
  );
}

/// Biometric Settings Notifier
class BiometricSettingsNotifier extends Notifier<BiometricSettings> {
  static const _keyRequireAppUnlock = 'biometric_require_app_unlock';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  BiometricSettings build() {
    unawaited(_loadSettings());
    return const BiometricSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await ref
        .read(biometricServiceProvider)
        .isBiometricEnabled();
    final appUnlock = await _storage.read(key: _keyRequireAppUnlock) != 'false';

    state = BiometricSettings(
      isBiometricEnabled: enabled,
      requireForAppUnlock: appUnlock,
    );
  }

  Future<void> setRequireForAppUnlock({required bool value}) async {
    await _storage.write(key: _keyRequireAppUnlock, value: value.toString());
    state = state.copyWith(requireForAppUnlock: value);
  }
}

/// Biometric Settings Provider
final biometricSettingsProvider =
    NotifierProvider<BiometricSettingsNotifier, BiometricSettings>(
      BiometricSettingsNotifier.new,
    );
