# JoonaPay Mobile - Claude Context

> **Read this first. Don't explore unless necessary.**
> **Read sitemap.md for ALL routes before creating screens.**

## CRITICAL: Do Not Duplicate These Screens

| Screen | File | Has |
|--------|------|-----|
| Login | `login_view.dart` | Country picker, login/register toggle |
| Onboarding | `onboarding_view.dart` | 4-page tutorial |
| OTP | `login_otp_view.dart` | Auto-submit, resend |
| Splash | `splash_view.dart` | Auth check, animations |

**If a route exists in sitemap.md, DO NOT create a new screen for it.**

## Project Summary
- **App:** USDC stablecoin wallet for West Africa
- **Stack:** Flutter 3.x + Riverpod + GoRouter + Dio
- **Target:** iOS/Android, French/English
- **Backend:** NestJS at `usdc-wallet/`

## File Locations (Don't Search)

### Features
```
lib/features/
├── auth/           # Login, OTP, registration
├── wallet/         # Home, balance, transactions
├── settings/       # Profile, security, KYC
├── transfers/      # Send money flows
└── onboarding/     # First-time user flow
```

### Services
```
lib/services/
├── api/api_client.dart        # Dio setup, interceptors
├── sdk/usdc_wallet_sdk.dart   # All API calls
├── pin/pin_service.dart       # PIN hashing, verification
├── biometric/biometric_service.dart
├── session/session_manager.dart
├── security/device_security.dart
└── transfers/transfers_service.dart
```

### Design System
```
lib/design/
├── tokens/colors.dart         # AppColors.gold500, .obsidian
├── tokens/typography.dart     # AppTypography.headlineMedium
├── tokens/spacing.dart        # AppSpacing.lg, AppRadius.md
└── components/primitives/     # AppButton, AppText, AppInput, AppCard, AppSelect
```

### State
```
lib/state/
├── wallet_state_machine.dart
├── user_state_machine.dart
└── transaction_state_machine.dart
```

### Router
```
lib/router/app_router.dart     # All routes defined here
```

### Mocks
```
lib/mocks/
├── mock_config.dart           # MockConfig.useMocks = true/false
├── mock_registry.dart         # Central registration
└── services/{feature}/        # Per-feature mocks
```

### Localization
```
lib/l10n/
├── app_en.arb                 # English (1053 lines)
└── app_fr.arb                 # French (220 lines)
```

## Patterns (Don't Ask)

### Widget Pattern
```dart
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(myProvider);

    return Scaffold(
      body: SafeArea(child: _buildContent(context, ref, l10n)),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    // Helper methods get l10n as parameter
  }
}
```

### Provider Pattern
```dart
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);

class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState.initial();

  Future<void> doThing() async {
    state = state.copyWith(isLoading: true);
    // ...
  }
}
```

### API Call Pattern
```dart
final sdk = ref.read(sdkProvider);
final result = await sdk.wallet.getBalance();
```

### Navigation Pattern
```dart
context.push('/transfer/confirm');
context.go('/home');
context.pop();
```

### Button Pattern
```dart
AppButton(
  label: l10n.common_continue,
  onPressed: _handleSubmit,
  isLoading: state.isLoading,
)
```

### Input Pattern
```dart
AppInput(
  label: l10n.auth_phoneNumber,
  controller: _phoneController,
  keyboardType: TextInputType.phone,
  validator: Validators.phone,
)
```

## Common Tasks (Copy-Paste)

### Add Screen
1. Create `lib/features/{feature}/views/{name}_view.dart`
2. Add route in `lib/router/app_router.dart`:
```dart
GoRoute(
  path: '/my-route',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const MyView(),
  ),
),
```

### Add Localized String
1. `lib/l10n/app_en.arb`: `"feature_myKey": "English text",`
2. `lib/l10n/app_fr.arb`: `"feature_myKey": "French text",`
3. Run: `flutter gen-l10n`
4. Use: `l10n.feature_myKey`

### Add API Method
1. Add to `lib/services/{service}/{service}_service.dart`
2. Add mock in `lib/mocks/services/{service}/{service}_mock.dart`

### Add Provider
```dart
// In lib/features/{feature}/providers/{name}_provider.dart
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);
```

## Existing Components (Don't Recreate)

| Need | Use |
|------|-----|
| Button | `AppButton` |
| Text | `AppText` |
| Input | `AppInput` |
| Dropdown | `AppSelect` |
| Card | `AppCard` |
| Loading | `AppButton(isLoading: true)` |
| Dialog | `AppDialog.show()` |
| Bottom Sheet | `AppBottomSheet.show()` |
| Toast | `AppToast.show()` |
| PIN Entry | `PinEntryWidget` |
| Amount Input | `AmountInputWidget` |
| Phone Input | `PhoneInputWidget` |
| Country Picker | `CountryPickerWidget` |
| Transaction List | `TransactionListWidget` |
| Balance Card | `BalanceCardWidget` |

## Colors (Don't Guess)
```dart
AppColors.gold500        // Primary gold
AppColors.obsidian       // Dark background
AppColors.charcoal       // Card background
AppColors.silver         // Secondary text
AppColors.success        // Green
AppColors.error          // Red
AppColors.warning        // Orange
```

## Spacing (Don't Guess)
```dart
AppSpacing.xs   // 4
AppSpacing.sm   // 8
AppSpacing.md   // 16
AppSpacing.lg   // 24
AppSpacing.xl   // 32
AppSpacing.xxl  // 48
```

## Dev Commands
```bash
flutter gen-l10n          # Regenerate localizations
flutter analyze           # Check for issues
flutter test              # Run tests
flutter run               # Run app
```

## Mock Mode
- Enabled by default in debug
- Dev OTP: `123456`
- Toggle: `MockConfig.useMocks = false`

## West African Context
- Currency: XOF (CFA Franc)
- Mobile Money: Orange Money, MTN MoMo, Wave
- Phone: +225 XX XX XX XX (Côte d'Ivoire)
- Names: Amadou, Fatou, Diallo, Traore
