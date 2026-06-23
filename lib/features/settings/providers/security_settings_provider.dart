import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/screenshot_protection.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Security settings state.
class SecuritySettings {
  final bool screenshotProtection;
  final bool pinOnAppOpen;
  final int autoLockMinutes;
  final bool isLoaded;

  const SecuritySettings({
    this.screenshotProtection = true,
    this.pinOnAppOpen = true,
    this.autoLockMinutes = 5,
    this.isLoaded = false,
  });

  SecuritySettings copyWith({
    bool? screenshotProtection,
    bool? pinOnAppOpen,
    int? autoLockMinutes,
    bool? isLoaded,
  }) => SecuritySettings(
    screenshotProtection: screenshotProtection ?? this.screenshotProtection,
    pinOnAppOpen: pinOnAppOpen ?? this.pinOnAppOpen,
    autoLockMinutes: autoLockMinutes ?? this.autoLockMinutes,
    isLoaded: isLoaded ?? this.isLoaded,
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
      final screenshotProtection = screenshot != 'false';
      final screenshotApplied = screenshotProtection
          ? await ref.read(screenshotProtectionProvider).enableSecureMode()
          : await ref.read(screenshotProtectionProvider).disableSecureMode();

      state = SecuritySettings(
        screenshotProtection: screenshotApplied && screenshotProtection,
        pinOnAppOpen: pinOnOpen != 'false',
        autoLockMinutes: int.tryParse(autoLock ?? '5') ?? 5,
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  Future<bool> setScreenshotProtection(bool value) async {
    final previous = state.screenshotProtection;
    state = state.copyWith(screenshotProtection: value);
    final applied = value
        ? await ref.read(screenshotProtectionProvider).enableSecureMode()
        : await ref.read(screenshotProtectionProvider).disableSecureMode();
    if (!applied) {
      state = state.copyWith(screenshotProtection: previous);
      return false;
    }

    state = state.copyWith(screenshotProtection: value);
    await _save('security_screenshot', value.toString());
    return true;
  }

  Future<void> setPinOnAppOpen(bool value) async {
    state = state.copyWith(pinOnAppOpen: value, isLoaded: true);
    await _save('security_pin_open', value.toString());
  }

  Future<void> setAutoLock(int minutes) async {
    state = state.copyWith(autoLockMinutes: minutes, isLoaded: true);
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
