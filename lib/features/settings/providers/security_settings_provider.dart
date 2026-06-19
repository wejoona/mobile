import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Security settings state.
class SecuritySettings {
  final bool screenshotProtection;
  final bool pinOnAppOpen;
  final int autoLockMinutes;

  const SecuritySettings({
    this.screenshotProtection = true,
    this.pinOnAppOpen = true,
    this.autoLockMinutes = 5,
  });

  SecuritySettings copyWith({
    bool? screenshotProtection,
    bool? pinOnAppOpen,
    int? autoLockMinutes,
  }) => SecuritySettings(
    screenshotProtection: screenshotProtection ?? this.screenshotProtection,
    pinOnAppOpen: pinOnAppOpen ?? this.pinOnAppOpen,
    autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
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
      final screenshot = await prefs.read('security_screenshot');
      final pinOnOpen = await prefs.read('security_pin_open');
      final autoLock = await prefs.read('security_auto_lock');

      state = SecuritySettings(
        screenshotProtection: screenshot != 'false',
        pinOnAppOpen: pinOnOpen != 'false',
        autoLockMinutes: int.tryParse(autoLock ?? '5') ?? 5,
      );
    } catch (_) {}
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
