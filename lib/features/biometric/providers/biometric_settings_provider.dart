import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api/api_client.dart';

/// Biometric Settings State
class BiometricSettings {
  final bool isBiometricEnabled;
  final bool requireForAppUnlock;
  final bool requireForTransactions;
  final bool requireForSensitiveSettings;
  final bool requireForViewBalance;
  final int biometricTimeoutMinutes;
  final double highValueThreshold;

  const BiometricSettings({
    this.isBiometricEnabled = false,
    this.requireForAppUnlock = true,
    this.requireForTransactions = true,
    this.requireForSensitiveSettings = true,
    this.requireForViewBalance = false,
    this.biometricTimeoutMinutes = 5,
    this.highValueThreshold = 1000.0,
  });

  BiometricSettings copyWith({
    bool? isBiometricEnabled,
    bool? requireForAppUnlock,
    bool? requireForTransactions,
    bool? requireForSensitiveSettings,
    bool? requireForViewBalance,
    int? biometricTimeoutMinutes,
    double? highValueThreshold,
  }) {
    return BiometricSettings(
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      requireForAppUnlock: requireForAppUnlock ?? this.requireForAppUnlock,
      requireForTransactions:
          requireForTransactions ?? this.requireForTransactions,
      requireForSensitiveSettings:
          requireForSensitiveSettings ?? this.requireForSensitiveSettings,
      requireForViewBalance:
          requireForViewBalance ?? this.requireForViewBalance,
      biometricTimeoutMinutes:
          biometricTimeoutMinutes ?? this.biometricTimeoutMinutes,
      highValueThreshold: highValueThreshold ?? this.highValueThreshold,
    );
  }
}

/// Biometric Settings Notifier
class BiometricSettingsNotifier extends Notifier<BiometricSettings> {
  static const _keyBiometricEnabled = StorageKeys.biometricEnabled;
  static const _keyRequireAppUnlock = 'biometric_require_app_unlock';
  static const _keyRequireTransactions = 'biometric_require_transactions';
  static const _keyRequireSensitiveSettings = 'biometric_require_sensitive';
  static const _keyRequireViewBalance = 'biometric_require_view_balance';
  static const _keyTimeoutMinutes = 'biometric_timeout_minutes';
  static const _keyHighValueThreshold = 'biometric_high_value_threshold';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  BiometricSettings build() {
    _loadSettings();
    return const BiometricSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _storage.read(key: _keyBiometricEnabled) == 'true';
    final appUnlock = await _storage.read(key: _keyRequireAppUnlock) != 'false';
    final transactions = await _storage.read(key: _keyRequireTransactions) != 'false';
    final sensitive = await _storage.read(key: _keyRequireSensitiveSettings) != 'false';
    final viewBalance = await _storage.read(key: _keyRequireViewBalance) == 'true';
    final timeoutStr = await _storage.read(key: _keyTimeoutMinutes);
    final thresholdStr = await _storage.read(key: _keyHighValueThreshold);

    state = BiometricSettings(
      isBiometricEnabled: enabled,
      requireForAppUnlock: appUnlock,
      requireForTransactions: transactions,
      requireForSensitiveSettings: sensitive,
      requireForViewBalance: viewBalance,
      biometricTimeoutMinutes: int.tryParse(timeoutStr ?? '') ?? 5,
      highValueThreshold: double.tryParse(thresholdStr ?? '') ?? 1000.0,
    );
  }

  Future<void> setRequireForAppUnlock(bool value) async {
    await _storage.write(key: _keyRequireAppUnlock, value: value.toString());
    state = state.copyWith(requireForAppUnlock: value);
  }

  Future<void> setRequireForTransactions(bool value) async {
    await _storage.write(key: _keyRequireTransactions, value: value.toString());
    state = state.copyWith(requireForTransactions: value);
  }

  Future<void> setRequireForSensitiveSettings(bool value) async {
    await _storage.write(
        key: _keyRequireSensitiveSettings, value: value.toString());
    state = state.copyWith(requireForSensitiveSettings: value);
  }

  Future<void> setRequireForViewBalance(bool value) async {
    await _storage.write(key: _keyRequireViewBalance, value: value.toString());
    state = state.copyWith(requireForViewBalance: value);
  }

  Future<void> setBiometricTimeout(int minutes) async {
    await _storage.write(key: _keyTimeoutMinutes, value: minutes.toString());
    state = state.copyWith(biometricTimeoutMinutes: minutes);
  }

  Future<void> setHighValueThreshold(double threshold) async {
    await _storage.write(
        key: _keyHighValueThreshold, value: threshold.toString());
    state = state.copyWith(highValueThreshold: threshold);
  }

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(key: _keyBiometricEnabled, value: value.toString());
    state = state.copyWith(isBiometricEnabled: value);
  }

  /// Check if biometric is required for a specific action
  bool isRequiredFor(BiometricAction action) {
    if (!state.isBiometricEnabled) return false;

    switch (action) {
      case BiometricAction.appUnlock:
        return state.requireForAppUnlock;
      case BiometricAction.transaction:
        return state.requireForTransactions;
      case BiometricAction.sensitiveSettings:
        return state.requireForSensitiveSettings;
      case BiometricAction.viewBalance:
        return state.requireForViewBalance;
    }
  }

  /// Check if biometric is required for high-value transaction
  bool isRequiredForAmount(double amount) {
    if (!state.isBiometricEnabled || !state.requireForTransactions) {
      return false;
    }
    return amount >= state.highValueThreshold;
  }
}

/// Biometric Actions
enum BiometricAction {
  appUnlock,
  transaction,
  sensitiveSettings,
  viewBalance,
}

/// Biometric Settings Provider
final biometricSettingsProvider =
    NotifierProvider<BiometricSettingsNotifier, BiometricSettings>(
  BiometricSettingsNotifier.new,
);
