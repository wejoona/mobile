# Internationalization (i18n) Setup

This document describes the internationalization setup for the JoonaPay Flutter app.

## Overview

The app uses Flutter's official localization package with ARB (Application Resource Bundle) files for managing translations.

**Supported Languages:**
- English (en) - Default
- French (fr)

## Architecture

### Files Structure

```
lib/
├── l10n/
│   ├── app_en.arb          # English translations (template)
│   └── app_fr.arb          # French translations
├── services/
│   └── localization/
│       ├── language_service.dart     # Language management service
│       ├── language_provider.dart    # Riverpod state management
│       └── README.md                # This file
```

### Configuration

**l10n.yaml** (project root):
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
```

**pubspec.yaml**:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter

flutter:
  generate: true
```

## Usage

### 1. Accessing Translations in Widgets

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Text(l10n.navigation_home);
  }
}
```

### 2. Changing Language

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        await ref.read(localeProvider.notifier).changeLanguage('fr');
      },
      child: Text('Switch to French'),
    );
  }
}
```

### 3. Getting Current Language

```dart
final localeState = ref.watch(localeProvider);
final currentLanguageCode = localeState.locale.languageCode;
```

### 4. Translations with Parameters

In ARB file:
```json
{
  "greeting": "Hello, {name}!",
  "@greeting": {
    "description": "Greeting message",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  }
}
```

In code:
```dart
Text(l10n.greeting('John'))
```

## Adding New Translations

### 1. Add to English ARB (app_en.arb)

```json
{
  "myNewKey": "My new translation",
  "@myNewKey": {
    "description": "Description of what this key is used for"
  }
}
```

### 2. Add to French ARB (app_fr.arb)

```json
{
  "myNewKey": "Ma nouvelle traduction"
}
```

### 3. Run Code Generation

Translations are auto-generated on build, but you can manually trigger:
```bash
flutter pub get
flutter build [platform]
```

### 4. Use in Code

```dart
Text(l10n.myNewKey)
```

## Translation Keys Reference

### Navigation
- `navigation_home` - Home
- `navigation_settings` - Settings
- `navigation_send` - Send
- `navigation_receive` - Receive
- `navigation_transactions` - Transactions
- `navigation_services` - Services

### Actions
- `action_continue` - Continue
- `action_cancel` - Cancel
- `action_confirm` - Confirm
- `action_back` - Back
- `action_submit` - Submit
- `action_done` - Done
- `action_save` - Save
- `action_edit` - Edit

### Authentication
- `auth_login` - Login
- `auth_verify` - Verify
- `auth_enterOtp` - Enter OTP
- `auth_phoneNumber` - Phone Number
- `auth_pin` - PIN
- `auth_logout` - Log Out
- `auth_logoutConfirm` - Logout confirmation

### Wallet
- `wallet_balance` - Balance
- `wallet_sendMoney` - Send Money
- `wallet_receiveMoney` - Receive Money
- `wallet_transactionHistory` - Transaction History
- `wallet_availableBalance` - Available Balance

### Settings
- `settings_profile` - Profile
- `settings_security` - Security
- `settings_language` - Language
- `settings_theme` - Theme
- `settings_notifications` - Notifications
- `settings_defaultCurrency` - Default Currency
- (See ARB files for complete list)

### KYC Status
- `kyc_verified` - Verified
- `kyc_pending` - Pending Review
- `kyc_rejected` - Rejected - Retry
- `kyc_notStarted` - Not Started

### Transaction Status
- `transaction_sent` - Sent
- `transaction_received` - Received
- `transaction_pending` - Pending
- `transaction_failed` - Failed
- `transaction_completed` - Completed

### Language Names
- `language_english` - English
- `language_french` - French
- `language_selectLanguage` - Select Language
- `language_changeLanguage` - Change Language

## Adding a New Language

### 1. Create ARB File

Create `lib/l10n/app_[locale].arb` (e.g., `app_es.arb` for Spanish)

### 2. Add Translations

Copy structure from `app_en.arb` and translate all strings.

### 3. Update Language Service

Add locale to `language_service.dart`:

```dart
List<Locale> getSupportedLocales() {
  return const [
    Locale('en'),
    Locale('fr'),
    Locale('es'), // Add new locale
  ];
}

String getLanguageName(String code) {
  switch (code) {
    case 'en':
      return 'English';
    case 'fr':
      return 'Français';
    case 'es':
      return 'Español'; // Add new language
    default:
      return 'English';
  }
}
```

### 4. Update Main.dart

Add locale to `supportedLocales` in `main.dart`:

```dart
supportedLocales: const [
  Locale('en'),
  Locale('fr'),
  Locale('es'), // Add new locale
],
```

### 5. Update Language View

Add language option to `language_view.dart`:

```dart
final languages = [
  {'code': 'en', 'nativeName': 'English'},
  {'code': 'fr', 'nativeName': 'Français'},
  {'code': 'es', 'nativeName': 'Español'}, // Add new language
];
```

## Best Practices

1. **Always use translation keys** - Never hardcode user-facing strings
2. **Use descriptive keys** - Format: `category_specificName` (e.g., `wallet_balance`)
3. **Add descriptions** - Always include `@keyName` metadata with descriptions
4. **Keep ARB files synchronized** - Ensure all languages have the same keys
5. **Test both languages** - Verify UI layout works for all supported languages
6. **Consider text expansion** - Some languages require more space (French is typically 20-30% longer than English)
7. **Use placeholders wisely** - For dynamic content, use typed placeholders
8. **Persist language preference** - Language selection is saved using SharedPreferences

## Testing

### Test Language Switching

```dart
testWidgets('Language switches correctly', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MyApp(),
      ),
    ),
  );

  // Test implementation
});
```

## Persistence

Language preference is automatically saved using `SharedPreferences` and restored on app launch.

**Storage Key:** `app_language`

## Performance

- Localization files are generated at compile time
- No runtime overhead for translation lookups
- Language changes require widget rebuild but don't restart app

## Troubleshooting

### Translations not appearing
1. Run `flutter clean`
2. Run `flutter pub get`
3. Rebuild the app

### New keys not recognized
1. Ensure ARB file syntax is valid JSON
2. Ensure you have both the key and `@key` metadata
3. Rebuild the app to regenerate localization code

### Language not persisting
- Check that SharedPreferences permissions are granted
- Verify `language_service.dart` is saving correctly
- Check for any errors in device logs
