import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'language_service.dart';

/// State for managing app locale
class LocaleState {
  final Locale locale;
  final bool isLoading;

  const LocaleState({
    required this.locale,
    this.isLoading = false,
  });

  LocaleState copyWith({
    Locale? locale,
    bool? isLoading,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Provider for language service
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

/// Notifier for managing app locale using modern Riverpod API
class LocaleNotifier extends Notifier<LocaleState> {
  late final LanguageService _languageService;

  @override
  LocaleState build() {
    _languageService = ref.watch(languageServiceProvider);
    _loadSavedLanguage();
    return const LocaleState(locale: Locale('en'));
  }

  /// Load saved language from storage
  Future<void> _loadSavedLanguage() async {
    final savedLanguage = await _languageService.getSavedLanguage();
    if (savedLanguage != null) {
      state = LocaleState(
        locale: _languageService.getLocaleFromCode(savedLanguage),
      );
    }
  }

  /// Change app language
  Future<void> changeLanguage(String languageCode) async {
    state = state.copyWith(isLoading: true);

    final locale = _languageService.getLocaleFromCode(languageCode);
    final saved = await _languageService.saveLanguage(languageCode);

    if (saved) {
      state = LocaleState(locale: locale, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Get supported locales
  List<Locale> getSupportedLocales() {
    return _languageService.getSupportedLocales();
  }

  /// Get current language code
  String getCurrentLanguageCode() {
    return state.locale.languageCode;
  }

  /// Get language name
  String getLanguageName(String code) {
    return _languageService.getLanguageName(code);
  }

  /// Get language display name (localized)
  String getLanguageDisplayName(String code) {
    return _languageService.getLanguageDisplayName(code, state.locale);
  }
}

/// Provider for locale state
final localeProvider = NotifierProvider<LocaleNotifier, LocaleState>(() {
  return LocaleNotifier();
});
