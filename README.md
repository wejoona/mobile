# JoonaPay USDC Wallet - Mobile App

USDC stablecoin wallet for West Africa (Côte d'Ivoire, Senegal, Mali) with mobile money integration.

## Stack

- **Flutter** 3.10.7+
- **Riverpod** for state management
- **GoRouter** for navigation
- **Dio** for HTTP client
- **Firebase** for push notifications & analytics

## Quick Start

```bash
# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run on device
flutter run

# Run tests
flutter test
```

## Documentation

| Document | Purpose |
|----------|---------|
| `CLAUDE.md` | AI assistant context & quick reference |
| `CUSTOM_COMPONENTS.md` | Design system & component catalog |
| `DEEP_LINKING.md` | Deep linking implementation guide |
| `DEEP_LINKING_SUMMARY.md` | Deep linking quick reference |
| `.claude/` | Token-saving context files |

## Deep Linking

JoonaPay supports deep linking via custom scheme (`joonapay://`) and Universal Links/App Links.

**Quick Links:**
- Full Guide: [DEEP_LINKING.md](/mobile/DEEP_LINKING.md)
- Deployment: [docs/DEPLOY_DEEP_LINKS.md](/mobile/docs/DEPLOY_DEEP_LINKS.md)
- Testing: [docs/DEEP_LINK_TESTING_CHECKLIST.md](/mobile/docs/DEEP_LINK_TESTING_CHECKLIST.md)
- Summary: [DEEP_LINKING_SUMMARY.md](/mobile/DEEP_LINKING_SUMMARY.md)

**Example Links:**
```
joonapay://send?to=+2250701234567&amount=50.00
joonapay://receive?amount=100.00
joonapay://pay/ABCD1234
joonapay://transaction/550e8400-e29b-41d4-a716-446655440000
```

**Test Script:**
```bash
# Test all deep links on Android
./test_deep_links.sh android

# Test all deep links on iOS
./test_deep_links.sh ios
```

## Project Structure

```
lib/
├── core/
│   ├── deep_linking/          # Deep link handling
│   └── router/                # GoRouter configuration
├── features/                  # Feature modules
│   ├── auth/                  # Authentication
│   ├── wallet/                # Wallet & home
│   ├── send/                  # Send money flow
│   ├── kyc/                   # KYC verification
│   └── settings/              # Settings & profile
├── design/                    # Design system
│   ├── components/            # Reusable components
│   └── tokens/                # Design tokens (colors, spacing)
├── services/                  # API & services
│   ├── api/                   # API client
│   └── sdk/                   # USDC Wallet SDK
├── state/                     # Global state machines
├── mocks/                     # Mock data & services
└── l10n/                      # Localizations (en, fr)
```

## Features

### MVP (Phase 1)
- [x] Login/Registration with OTP
- [x] Wallet home & balance
- [x] Send money (internal transfers)
- [x] Receive money (QR code)
- [x] Transaction history
- [x] Basic KYC
- [x] Push notifications
- [x] Deep linking

### Phase 2
- [ ] Withdraw to mobile money
- [ ] Deposit from mobile money
- [ ] Virtual cards

### Phase 3
- [ ] Bill payments
- [ ] Airtime purchase
- [ ] External crypto transfers

### Phase 4
- [ ] Savings pots
- [ ] Recurring transfers
- [ ] Budget tracking
- [ ] Merchant payments

## Development

### Mock Mode

Mock mode is enabled by default in debug builds:

```dart
// Disable mocks to test with real API
MockConfig.useMocks = false;

// Dev OTP for testing
OTP: 123456
```

### Add Localized String

1. Add to `lib/l10n/app_en.arb`:
   ```json
   "feature_myKey": "My text"
   ```

2. Add French in `lib/l10n/app_fr.arb`:
   ```json
   "feature_myKey": "Mon texte"
   ```

3. Run `flutter gen-l10n`

4. Use: `AppLocalizations.of(context)!.feature_myKey`

### Add Route

Add to `lib/router/app_router.dart`:

```dart
GoRoute(
  path: '/my-route',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    state: state,
    child: const MyView(),
  ),
),
```

### Design System

Use existing components instead of creating new ones:

```dart
AppButton(label: 'Continue', onPressed: _handleSubmit)
AppInput(label: 'Phone', controller: _controller)
AppCard(child: _buildContent())
AppText('Title', style: TextStyle.headlineMedium)
```

**Colors:** `AppColors.gold500`, `AppColors.obsidian`
**Spacing:** `AppSpacing.md`, `AppSpacing.lg`

See `CUSTOM_COMPONENTS.md` for full component catalog.

## Testing

```bash
# All tests
flutter test

# Specific test file
flutter test test/services/pin_service_test.dart

# Code analysis
flutter analyze

# Deep link tests
./test_deep_links.sh android
```

## Build

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# iOS
flutter build ios --release
```

## West African Context

- **Currency:** XOF (CFA Franc)
- **Mobile Money:** Orange Money, MTN MoMo, Wave
- **Languages:** French (primary), English (secondary)
- **Phone Format:** +225 XX XX XX XX (Côte d'Ivoire)

## Contributing

1. Read `.claude/instructions.md` for token-saving rules
2. Check `.claude/sitemap.md` before creating screens
3. Use templates from `.claude/templates.md`
4. Follow existing patterns in `CLAUDE.md`

## License

Proprietary - JoonaPay © 2026
