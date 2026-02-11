import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';

/// Supported app locales.
enum AppLocale {
  fr(Locale('fr'), 'Français'),
  en(Locale('en'), 'English'),
  pt(Locale('pt'), 'Português'),
  ar(Locale('ar'), 'العربية');

  final Locale locale;
  final String displayName;
  const AppLocale(this.locale, this.displayName);

  static AppLocale fromCode(String code) {
    return AppLocale.values.firstWhere(
      (l) => l.locale.languageCode == code,
      orElse: () => AppLocale.fr,
    );
  }
}

/// Locale state notifier for app-wide language switching.
class LocaleNotifier extends Notifier<AppLocale> {
  static const _key = 'app_locale';

  @override
  AppLocale build() {
    _loadSaved();
    return AppLocale.fr; // Default: French (Côte d'Ivoire)
  }

  Future<void> _loadSaved() async {
    try {
      final prefs = ref.read(securePrefsProvider);
      final saved = await prefs.read(_key);
      if (saved != null) {
        state = AppLocale.fromCode(saved);
      }
    } catch (_) {}
  }

  Future<void> setLocale(AppLocale locale) async {
    state = locale;
    try {
      final prefs = ref.read(securePrefsProvider);
      await prefs.write(_key, locale.locale.languageCode);
    } catch (_) {}
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, AppLocale>(
  LocaleNotifier.new,
);

/// Convenience: current Locale object.
final appLocaleProvider = Provider<Locale>((ref) {
  return ref.watch(localeProvider).locale;
});
