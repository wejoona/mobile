import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing app language preferences
class LanguageService {
  static const String _languageKey = 'app_language';

  /// Get saved language code from storage
  Future<String?> getSavedLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey);
    } catch (e) {
      debugPrint('Error getting saved language: $e');
      return null;
    }
  }

  /// Save language code to storage
  Future<bool> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      debugPrint('Error saving language: $e');
      return false;
    }
  }

  /// Get supported locales
  List<Locale> getSupportedLocales() {
    return const [
      Locale('en'),
      Locale('fr'),
    ];
  }

  /// Get locale from language code
  Locale getLocaleFromCode(String code) {
    switch (code) {
      case 'en':
        return const Locale('en');
      case 'fr':
        return const Locale('fr');
      default:
        return const Locale('en');
    }
  }

  /// Get language name from code
  String getLanguageName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  /// Get language display name (localized)
  String getLanguageDisplayName(String code, Locale currentLocale) {
    final isEnglish = currentLocale.languageCode == 'en';

    switch (code) {
      case 'en':
        return isEnglish ? 'English' : 'Anglais';
      case 'fr':
        return isEnglish ? 'French' : 'Français';
      default:
        return 'English';
    }
  }
}
