import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Security settings state.
class SecuritySettings {
  final bool biometricEnabled;
  final bool screenshotProtection;
  final bool pinOnAppOpen;
  final int autoLockMinutes;
  final bool transactionAlerts;

  const SecuritySettings({
    this.biometricEnabled = true,
    this.screenshotProtection = true,
    this.pinOnAppOpen = true,
    this.autoLockMinutes = 5,
    this.transactionAlerts = true,
  });

  SecuritySettings copyWith({
    bool? biometricEnabled,
    bool? screenshotProtection,
    bool? pinOnAppOpen,
    int? autoLockMinutes,
    bool? transactionAlerts,
  }) => SecuritySettings(
    biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    screenshotProtection: screenshotProtection ?? this.screenshotProtection,
    pinOnAppOpen: pinOnAppOpen ?? this.pinOnAppOpen,
    autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    transactionAlerts: transactionAlerts ?? this.transactionAlerts,
  );
}

/// Security settings notifier.
class SecuritySettingsNotifier extends Notifier<SecuritySettings> {
  @override
  SecuritySettings build() {
    _loadSaved();
    return const SecuritySettings();
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = ref.read(securePrefsProvider);
      final biometric = await prefs.read('security_biometric');
      final screenshot = await prefs.read('security_screenshot');
      final pinOnOpen = await prefs.read('security_pin_open');
      final autoLock = await prefs.read('security_auto_lock');
      final alerts = await prefs.read('security_alerts');

      state = SecuritySettings(
        biometricEnabled: biometric != 'false',
        screenshotProtection: screenshot != 'false',
        pinOnAppOpen: pinOnOpen != 'false',
        autoLockMinutes: int.tryParse(autoLock ?? '5') ?? 5,
        transactionAlerts: alerts != 'false',
      );
    } catch (_) {}
  }

  Future<void> setBiometric(bool value) async {
    state = state.copyWith(biometricEnabled: value);
    await _save('security_biometric', value.toString());
  }

  Future<void> setScreenshotProtection(bool value) async {
    state = state.copyWith(screenshotProtection: value);
    await _save('security_screenshot', value.toString());
  }

  Future<void> setPinOnAppOpen(bool value) async {
    state = state.copyWith(pinOnAppOpen: value);
    await _save('security_pin_open', value.toString());
  }

  Future<void> setAutoLock(int minutes) async {
    state = state.copyWith(autoLockMinutes: minutes);
    await _save('security_auto_lock', minutes.toString());
  }

  Future<void> setTransactionAlerts(bool value) async {
    state = state.copyWith(transactionAlerts: value);
    await _save('security_alerts', value.toString());
  }

  Future<void> _save(String key, String value) async {
    try {
      final prefs = ref.read(securePrefsProvider);
      await prefs.write(key, value);
    } catch (_) {}
  }
}

final securitySettingsProvider =
    NotifierProvider<SecuritySettingsNotifier, SecuritySettings>(
  SecuritySettingsNotifier.new,
);
