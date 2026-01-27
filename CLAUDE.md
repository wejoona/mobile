# Claude Context - JoonaPay USDC Wallet Mobile

> **For AI Assistants:** Quick context to understand this codebase and work effectively.

## What Is This?

JoonaPay is a **USDC stablecoin wallet** for West Africa (Côte d'Ivoire, Senegal, Mali, etc.). It enables:
- Mobile money deposits/withdrawals (Orange Money, MTN, Wave)
- P2P transfers between users
- External crypto transfers
- Bill payments, airtime purchase
- Merchant QR payments

**Stack:** Flutter + Riverpod + GoRouter + Dio

---

## Before You Code

### 1. Check Existing Components First

**UI Components exist for everything common:**
```
lib/design/components/primitives/
├── app_button.dart    # Use instead of ElevatedButton/TextButton
├── app_text.dart      # Use instead of Text()
├── app_input.dart     # Use instead of TextField
├── app_select.dart    # Use instead of DropdownButton
└── app_card.dart      # Use instead of Card()
```

**Design tokens exist:**
```
lib/design/tokens/
├── colors.dart        # AppColors.gold500, AppColors.obsidian, etc.
├── typography.dart    # AppTypography.headlineMedium, etc.
└── spacing.dart       # AppSpacing.lg, AppRadius.md, etc.
```

### 2. Use the SDK for API Calls

```dart
// DON'T do this:
final response = await dio.get('/wallet');

// DO this:
final sdk = ref.read(sdkProvider);
final wallet = await sdk.wallet.getWallet();
```

### 3. Mocks Are Enabled in Debug

The app uses mocks by default in debug mode. To test with real API:
```dart
MockConfig.useMocks = false;
```

Dev OTP for testing: `123456`

---

## Key Files to Know

| Purpose | File |
|---------|------|
| API client setup | `lib/services/api/api_client.dart` |
| All API services | `lib/services/sdk/usdc_wallet_sdk.dart` |
| Mock configuration | `lib/mocks/mock_config.dart` |
| Router/navigation | `lib/router/app_router.dart` |
| Feature flags | `lib/services/feature_flags/feature_flags_service.dart` |
| Wallet state | `lib/state/wallet_state_machine.dart` |
| Auth provider | `lib/features/auth/providers/auth_provider.dart` |
| Design system | `lib/design/components/primitives/index.dart` |
| Localization | `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb` |

---

## Common Tasks

### Add a New Screen

1. Create view in `lib/features/{feature}/views/{name}_view.dart`
2. Add route in `lib/router/app_router.dart`
3. Use `AppPageTransitions.verticalSlide()` for modal-style or `.fade()` for settings

### Add API Endpoint

1. Add method to appropriate service in `lib/services/{service}/`
2. Add mock in `lib/mocks/services/{service}/{service}_mock.dart`
3. Update contract in `lib/mocks/services/{service}/{service}_contract.dart`

### Add Localized String

1. Add to `lib/l10n/app_en.arb`:
   ```json
   "feature_myString": "My text",
   ```
2. Add French in `lib/l10n/app_fr.arb`:
   ```json
   "feature_myString": "Mon texte",
   ```
3. Run `flutter gen-l10n`
4. Use: `AppLocalizations.of(context)!.feature_myString`

### Add Feature Flag

1. Add to `lib/services/feature_flags/feature_flags_service.dart`
2. Check with `ref.read(featureFlagsProvider).canDoThing`
3. Guard routes in `lib/router/app_router.dart` redirect

---

## Architecture Patterns

### State Management
- **Riverpod** with `Notifier` + `NotifierProvider` (not deprecated StateNotifier)
- State machines for complex state (wallet, transactions, user)
- Immutable state with `copyWith()`

### API Layer
- `UsdcWalletSdk` is the single entry point
- Services mirror backend structure
- Dio interceptors: mock → deduplication → cache → auth → logging

### Security
- PIN hashing with salt (never plain text)
- Biometric gating for sensitive actions
- Device security checks (root/jailbreak detection)
- Risk-based step-up authentication
- Session timeout with auto-lock

### Navigation
- GoRouter with typed routes
- Deep linking: `joonapay://` scheme
- Contextual transitions (slide, fade, scale)

---

## Code Style

### Naming
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/methods: `camelCase`
- Constants: `camelCase` (not SCREAMING_CASE)
- Private: `_prefixedWithUnderscore`

### Widgets
- Prefer `ConsumerWidget` for widgets needing providers
- Use `ref.watch()` for reactive state, `ref.read()` for actions
- Extract helper methods: `Widget _buildHeader()` pattern

### Imports
```dart
// Order: dart, flutter, packages, local
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/index.dart';
import '../../../services/sdk/usdc_wallet_sdk.dart';
```

---

## Testing

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/services/pin_service_test.dart

# Analyze code
flutter analyze

# Build debug APK
flutter build apk --debug
```

---

## Documentation

| Doc | Purpose |
|-----|---------|
| `CUSTOM_COMPONENTS.md` | Full catalog of reusable components |
| `lib/mocks/README.md` | Mocking framework guide |
| `lib/router/README.md` | Navigation system docs |
| `TODO.md` (root) | Project-wide task list |

---

## West African Context

- **Currencies:** XOF (CFA Franc), XAF, GNF, NGN
- **Mobile Money:** Orange Money, MTN MoMo, Wave (dominant payment methods)
- **Languages:** French primary, English secondary
- **Phone format:** +225 XX XX XX XX (Côte d'Ivoire)
- **Names:** Use `MockDataGenerator` for realistic test data (Amadou, Fatou, Diallo, Traore)

---

## Quick Commands

```bash
# Generate localizations after editing .arb files
flutter gen-l10n

# Clean build
flutter clean && flutter pub get

# Run on specific device
flutter run -d "iPhone 15"

# Build release APK
flutter build apk --release
```

---

*This file helps AI assistants work effectively with this codebase. Keep it updated!*
