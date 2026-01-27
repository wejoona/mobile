import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/localization/language_service.dart';

void main() {
  late LanguageService service;

  setUp(() {
    service = LanguageService();
    SharedPreferences.setMockInitialValues({});
  });

  group('LanguageService', () {
    test('returns supported locales', () {
      final locales = service.getSupportedLocales();
      expect(locales, hasLength(2));
      expect(locales, contains(const Locale('en')));
      expect(locales, contains(const Locale('fr')));
    });

    test('gets locale from code', () {
      expect(service.getLocaleFromCode('en'), const Locale('en'));
      expect(service.getLocaleFromCode('fr'), const Locale('fr'));
      expect(service.getLocaleFromCode('invalid'), const Locale('en'));
    });

    test('gets language name from code', () {
      expect(service.getLanguageName('en'), 'English');
      expect(service.getLanguageName('fr'), 'Français');
      expect(service.getLanguageName('invalid'), 'English');
    });

    test('saves and retrieves language preference', () async {
      // Save language
      final saved = await service.saveLanguage('fr');
      expect(saved, isTrue);

      // Retrieve language
      final retrieved = await service.getSavedLanguage();
      expect(retrieved, 'fr');
    });

    test('returns null when no language is saved', () async {
      final retrieved = await service.getSavedLanguage();
      expect(retrieved, isNull);
    });

    test('gets language display name', () {
      // When current locale is English
      expect(
        service.getLanguageDisplayName('en', const Locale('en')),
        'English',
      );
      expect(
        service.getLanguageDisplayName('fr', const Locale('en')),
        'French',
      );

      // When current locale is French
      expect(
        service.getLanguageDisplayName('en', const Locale('fr')),
        'Anglais',
      );
      expect(
        service.getLanguageDisplayName('fr', const Locale('fr')),
        'Français',
      );
    });
  });
}
