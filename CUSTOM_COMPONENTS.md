# JoonaPay Mobile - Custom Components & Services Catalog

> **Purpose:** Reference documentation for team members and AI assistants working on this codebase.
> This documents all custom-built, reusable components that should be used instead of creating new ones.

---

## Quick Reference

| Need | Use This | Location |
|------|----------|----------|
| Button | `AppButton` | `lib/design/components/primitives/app_button.dart` |
| Text | `AppText` | `lib/design/components/primitives/app_text.dart` |
| Input field | `AppInput` | `lib/design/components/primitives/app_input.dart` |
| Dropdown/Select | `AppSelect` | `lib/design/components/primitives/app_select.dart` |
| Card container | `AppCard` | `lib/design/components/primitives/app_card.dart` |
| PIN entry | `PinPad` + `PinDots` | `lib/design/components/composed/pin_pad.dart` |
| PIN confirmation | `PinConfirmationSheet` | `lib/design/components/composed/pin_confirmation_sheet.dart` |
| Balance display | `BalanceCard` | `lib/design/components/composed/balance_card.dart` |
| Transaction item | `TransactionRow` | `lib/design/components/composed/transaction_row.dart` |
| Colors | `AppColors` | `lib/design/tokens/colors.dart` |
| Typography | `AppTypography` | `lib/design/tokens/typography.dart` |
| Spacing | `AppSpacing` | `lib/design/tokens/spacing.dart` |
| API calls | `UsdcWalletSdk` | `lib/services/sdk/usdc_wallet_sdk.dart` |
| Mock APIs | `MockRegistry` | `lib/mocks/mock_registry.dart` |

---

## 1. Design System

### Design Tokens

#### Colors (`lib/design/tokens/colors.dart`)
```dart
import 'package:usdc_wallet/design/tokens/colors.dart';

// Dark backgrounds
AppColors.obsidian      // #0A0A0A - Deepest background
AppColors.graphite      // #141414 - Card backgrounds
AppColors.slate         // #1E1E1E - Elevated surfaces
AppColors.elevated      // #282828 - Higher elevation
AppColors.glass         // #FFFFFF0D - Glass effect

// Gold accents (primary brand color)
AppColors.gold500       // #FFB800 - Primary gold
AppColors.gold400       // Lighter
AppColors.gold600       // Darker
AppColors.goldGradient  // LinearGradient for buttons

// Text colors
AppColors.textPrimary   // High emphasis
AppColors.textSecondary // Medium emphasis
AppColors.textTertiary  // Low emphasis
AppColors.textDisabled  // Disabled state

// Semantic colors
AppColors.successBase   // Green for positive
AppColors.errorBase     // Red for errors
AppColors.warningBase   // Orange for warnings
AppColors.infoBase      // Blue for info
```

#### Typography (`lib/design/tokens/typography.dart`)
```dart
import 'package:usdc_wallet/design/tokens/typography.dart';

// Display (72px - 36px) - Hero text
AppTypography.displayLarge
AppTypography.displayMedium
AppTypography.displaySmall

// Headlines (32px - 24px) - Section headers
AppTypography.headlineLarge
AppTypography.headlineMedium
AppTypography.headlineSmall

// Titles (22px - 16px) - Card titles
AppTypography.titleLarge
AppTypography.titleMedium
AppTypography.titleSmall

// Body (16px - 12px) - Content text
AppTypography.bodyLarge
AppTypography.bodyMedium
AppTypography.bodySmall

// Special
AppTypography.balanceDisplay  // Large monospace for amounts
AppTypography.monoLarge       // Monospace for addresses
```

#### Spacing (`lib/design/tokens/spacing.dart`)
```dart
import 'package:usdc_wallet/design/tokens/spacing.dart';

// 8pt grid system
AppSpacing.xxs   // 2
AppSpacing.xs    // 4
AppSpacing.sm    // 8
AppSpacing.md    // 12
AppSpacing.lg    // 16
AppSpacing.xl    // 20
AppSpacing.xxl   // 24
AppSpacing.xxxl  // 32

// Component-specific
AppSpacing.screenPadding  // 20 - Page margins
AppSpacing.cardPadding    // 20 - Card internal padding
AppSpacing.buttonPadding  // 16 - Button internal padding

// Border radius
AppRadius.sm    // 4
AppRadius.md    // 8
AppRadius.lg    // 12
AppRadius.xl    // 16
AppRadius.full  // 9999 (circular)
```

---

### Primitive Components

#### AppButton (`lib/design/components/primitives/app_button.dart`)
```dart
import 'package:usdc_wallet/design/components/primitives/app_button.dart';

// Primary (gold gradient)
AppButton(
  label: 'Continue',
  onPressed: () {},
  variant: AppButtonVariant.primary,
  size: AppButtonSize.large,
  isFullWidth: true,
)

// With loading state
AppButton(
  label: 'Submit',
  onPressed: _submit,
  isLoading: _isSubmitting,
)

// With icon
AppButton(
  label: 'Send Money',
  onPressed: _send,
  leadingIcon: Icons.send,
)

// Variants: primary, secondary, ghost, success, danger
// Sizes: small, medium, large
```

#### AppText (`lib/design/components/primitives/app_text.dart`)
```dart
import 'package:usdc_wallet/design/components/primitives/app_text.dart';

// Basic usage
AppText('Hello World', variant: AppTextVariant.bodyMedium)

// With customization
AppText(
  'Balance',
  variant: AppTextVariant.headlineMedium,
  color: AppColors.textSecondary,
  textAlign: TextAlign.center,
)

// Special variants for financial data
AppText('\$1,234.56', variant: AppTextVariant.balance)
AppText('+5.2%', variant: AppTextVariant.percentage)
AppText('0x1234...', variant: AppTextVariant.monoMedium)
```

#### AppInput (`lib/design/components/primitives/app_input.dart`)
```dart
import 'package:usdc_wallet/design/components/primitives/app_input.dart';

// Standard text input
AppInput(
  controller: _controller,
  label: 'Email',
  hint: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
)

// Phone input with country code
AppInput.phone(
  controller: _phoneController,
  countryCode: '+225',
  onCountryTap: _showCountryPicker,
)

// Amount input
AppInput.amount(
  controller: _amountController,
  label: 'Amount',
  prefix: '\$',
)

// With error state
AppInput(
  controller: _controller,
  label: 'Password',
  error: _errorMessage,
  obscureText: true,
)
```

#### AppSelect (`lib/design/components/primitives/app_select.dart`)
```dart
import 'package:usdc_wallet/design/components/primitives/app_select.dart';

// Basic dropdown
AppSelect<String>(
  label: 'Country',
  hint: 'Select a country',
  value: _selectedCountry,
  items: [
    AppSelectItem(value: 'CI', label: 'Côte d\'Ivoire'),
    AppSelectItem(value: 'SN', label: 'Senegal'),
    AppSelectItem(value: 'ML', label: 'Mali'),
  ],
  onChanged: (value) => setState(() => _selectedCountry = value),
)

// With icons and subtitles
AppSelect<String>(
  label: 'Payment Method',
  value: _method,
  items: [
    AppSelectItem(
      value: 'orange',
      label: 'Orange Money',
      subtitle: 'Instant transfer',
      icon: Icons.phone_android,
    ),
    AppSelectItem(
      value: 'wave',
      label: 'Wave',
      subtitle: '0% fees',
      icon: Icons.waves,
    ),
  ],
  onChanged: (value) => setState(() => _method = value),
)
```

#### AppCard (`lib/design/components/primitives/app_card.dart`)
```dart
import 'package:usdc_wallet/design/components/primitives/app_card.dart';

// Elevated card
AppCard(
  variant: AppCardVariant.elevated,
  child: Column(...),
)

// Gold accent (for featured items)
AppCard(
  variant: AppCardVariant.goldAccent,
  onTap: _handleTap,
  child: ...,
)

// Glass effect
AppCard(
  variant: AppCardVariant.glass,
  child: ...,
)

// Variants: elevated, goldAccent, subtle, glass
```

---

### Composed Components

#### PinPad + PinDots (`lib/design/components/composed/pin_pad.dart`)
```dart
import 'package:usdc_wallet/design/components/composed/pin_pad.dart';

// PIN entry with visual dots
Column(
  children: [
    PinDots(
      length: 6,
      filledCount: _pin.length,
      hasError: _hasError,
    ),
    SizedBox(height: 32),
    PinPad(
      onDigitPressed: (digit) => setState(() => _pin += digit.toString()),
      onDeletePressed: () => setState(() => _pin = _pin.substring(0, _pin.length - 1)),
      onBiometricPressed: _authenticateWithBiometric,
      showBiometric: true,
    ),
  ],
)
```

#### PinConfirmationSheet (`lib/design/components/composed/pin_confirmation_sheet.dart`)
```dart
import 'package:usdc_wallet/design/components/composed/pin_confirmation_sheet.dart';

// Show PIN confirmation for sensitive action
final result = await PinConfirmationSheet.show(
  context: context,
  title: 'Confirm Transfer',
  subtitle: 'Enter PIN to send \$100 to John',
);

if (result == PinConfirmationResult.success) {
  // Proceed with transfer
}
```

#### BalanceCard (`lib/design/components/composed/balance_card.dart`)
```dart
import 'package:usdc_wallet/design/components/composed/balance_card.dart';

BalanceCard(
  balance: 1234.56,
  changeAmount: 45.23,
  changePercent: 3.8,
  isLoading: false,
  onDepositTap: _showDepositSheet,
)
```

#### TransactionRow (`lib/design/components/composed/transaction_row.dart`)
```dart
import 'package:usdc_wallet/design/components/composed/transaction_row.dart';

TransactionRow(
  type: TransactionRowType.transferOut,
  title: 'Sent to Amadou',
  subtitle: '+225 01 23 45 67',
  amount: 50.00,
  date: DateTime.now(),
  status: TransactionRowStatus.completed,
  onTap: () => _viewDetails(tx),
)

// Or use TransactionList for a group
TransactionList(
  title: 'Recent Transactions',
  transactions: [...],
  isLoading: false,
  emptyMessage: 'No transactions yet',
)
```

---

## 2. Services

### Unified SDK (`lib/services/sdk/usdc_wallet_sdk.dart`)
```dart
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';

// Access via provider
final sdk = ref.read(sdkProvider);

// Auth
await sdk.auth.login(phone);
await sdk.auth.verifyOtp(phone, otp);

// Wallet
final wallet = await sdk.wallet.getWallet();
await sdk.wallet.deposit(amount, provider, phone);

// Transactions
final transactions = await sdk.transactions.getTransactions();
await sdk.transfers.sendInternal(recipientPhone, amount, note);

// User
final profile = await sdk.user.getProfile();
await sdk.user.updateProfile(firstName: 'John');
```

### Security Services

#### PinService (`lib/services/pin/pin_service.dart`)
```dart
final pinService = ref.read(pinServiceProvider);

// Check if PIN is set
final hasPin = await pinService.hasPin();

// Set PIN (validates strength)
final result = await pinService.setPin('123456');
if (!result.success) {
  print(result.message); // "PIN is too weak"
}

// Verify PIN (with attempt tracking)
final verify = await pinService.verifyPin('123456');
if (verify.isLocked) {
  print('Locked for ${verify.lockRemainingSeconds} seconds');
}
```

#### BiometricService (`lib/services/biometric/biometric_service.dart`)
```dart
final biometricService = ref.read(biometricServiceProvider);

// Check availability
final isAvailable = await biometricService.isAvailable();
final types = await biometricService.getAvailableTypes(); // fingerprint, faceId

// Authenticate
final success = await biometricService.authenticate(
  reason: 'Confirm transfer',
);

// Enable/disable for user
await biometricService.setBiometricEnabled(true);
```

#### DeviceSecurity (`lib/services/security/device_security.dart`)
```dart
final deviceSecurity = ref.read(deviceSecurityProvider);

final result = await deviceSecurity.checkSecurity();
if (result.isCompromised) {
  print('Threats: ${result.threats}'); // [rooted, debuggerAttached]
}
```

#### RiskBasedSecurityService (`lib/services/security/risk_based_security_service.dart`)
```dart
final riskService = ref.read(riskBasedSecurityServiceProvider);

// Evaluate transaction risk
final decision = await riskService.evaluateTransferRisk(
  amount: 500.0,
  recipientAddress: '0x...',
  isNewRecipient: true,
);

// decision.level: green, yellow, red
// decision.requirement: none, biometric, otp, liveness, combined

if (decision.requirement != StepUpRequirement.none) {
  final verified = await riskService.executeStepUp(decision);
  if (!verified) return; // Step-up failed
}

// Proceed with transfer
```

### Session Management (`lib/services/session/`)
```dart
final sessionService = ref.read(sessionServiceProvider);

// Check session status
final status = sessionService.status; // active, expiring, expired, locked

// Manual lock
sessionService.lockSession();

// Session config
SessionConfig(
  inactivityTimeout: Duration(minutes: 5),
  warningDuration: Duration(seconds: 30),
  backgroundTimeout: Duration(minutes: 15),
)
```

### Feature Flags (`lib/services/feature_flags/feature_flags_service.dart`)
```dart
final flags = ref.read(featureFlagsProvider);

// Check feature availability
if (flags.canWithdraw) {
  // Show withdraw option
}

// Phase-based features
flags.canDeposit          // Phase 1 (always on)
flags.canWithdraw         // Phase 2
flags.canBuyAirtime       // Phase 3
flags.canSetSavingsGoals  // Phase 4
```

---

## 3. Mocking Framework (`lib/mocks/`)

### Enable Mocks
```dart
import 'package:usdc_wallet/mocks/index.dart';

// Global toggle (enabled by default in debug)
MockConfig.useMocks = true;

// Per-service toggle
MockConfig.mockAuth = true;
MockConfig.mockWallet = true;
MockConfig.mockTransactions = false; // Use real API

// Simulate network conditions
MockConfig.networkDelayMs = 500;
MockConfig.simulateRandomFailures = true;
MockConfig.failureRate = 0.1;
```

### Add New Mock Service
```dart
// 1. Create contract (lib/mocks/services/kyc/kyc_contract.dart)
class KycContract extends ApiContract {
  @override
  String get serviceName => 'KYC';

  @override
  String get basePath => '/kyc';

  static const submitKyc = ApiEndpoint(
    path: '/submit',
    method: HttpMethod.post,
    description: 'Submit KYC documents',
  );

  @override
  List<ApiEndpoint> get endpoints => [submitKyc];
}

// 2. Create mock (lib/mocks/services/kyc/kyc_mock.dart)
class KycMock {
  static void register(MockInterceptor interceptor) {
    interceptor.register(
      method: 'POST',
      path: '/kyc/submit',
      handler: (options) async {
        return MockResponse.success({'status': 'pending'});
      },
    );
  }
}

// 3. Register in MockRegistry.initialize()
KycMock.register(_interceptor);
```

### Mock Data Generator
```dart
import 'package:usdc_wallet/mocks/index.dart';

MockDataGenerator.uuid();           // 'a1b2c3d4-...'
MockDataGenerator.fullName();       // 'Amadou Diallo'
MockDataGenerator.firstName();      // 'Fatou'
MockDataGenerator.lastName();       // 'Traore'
MockDataGenerator.phoneNumber();    // '+225012345678'
MockDataGenerator.walletAddress();  // '0x1234...'
MockDataGenerator.amount();         // 1234.56
MockDataGenerator.balance();        // 5000.00
MockDataGenerator.currency();       // 'XOF'
MockDataGenerator.transactionRef(); // 'TXN1234567890'
MockDataGenerator.pastDate();       // DateTime 1-30 days ago
MockDataGenerator.pick(list);       // Random item from list
MockDataGenerator.boolean();        // true/false
```

---

## 4. State Management (`lib/state/`)

### Wallet State
```dart
final walletState = ref.watch(walletStateMachineProvider);

// Access data
walletState.status      // loading, loaded, error
walletState.balanceUsd  // 1234.56
walletState.balanceUsdc // 1200.00
walletState.pending     // 34.56
walletState.address     // '0x...'

// Refresh
ref.read(walletStateMachineProvider.notifier).refresh();
```

### Transaction State
```dart
final txState = ref.watch(transactionStateMachineProvider);

txState.transactions    // List<Transaction>
txState.isLoading
txState.hasMore
txState.filter

// Load more
ref.read(transactionStateMachineProvider.notifier).loadMore();

// Apply filter
ref.read(transactionStateMachineProvider.notifier).setFilter(
  TransactionFilter(type: TransactionType.deposit),
);
```

### Navigation State
```dart
final navState = ref.watch(navigationProvider);

navState.currentTab  // NavTab.wallet, .activity, .rewards, .settings

// Navigate
ref.read(navigationProvider.notifier).setTab(NavTab.activity);
```

---

## 5. Router & Navigation (`lib/router/`)

### Page Transitions
```dart
import 'package:usdc_wallet/router/page_transitions.dart';

// In GoRoute pageBuilder:
GoRoute(
  path: '/send',
  pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
    state: state,
    child: const SendView(),
  ),
)

// Available transitions:
AppPageTransitions.none()           // No animation (splash)
AppPageTransitions.fade()           // Crossfade (auth screens)
AppPageTransitions.horizontalSlide() // Tab switching
AppPageTransitions.verticalSlide()  // Modal-style screens
createSuccessTransition()           // Scale+fade for success screens
```

### Deep Links
```
joonapay://send          -> /send
joonapay://receive       -> /receive
joonapay://transactions  -> /transactions
https://app.joonapay.com/send -> /send
```

---

## 6. Localization (`lib/l10n/`)

### Usage
```dart
import 'package:usdc_wallet/l10n/app_localizations.dart';

// In widget
final l10n = AppLocalizations.of(context)!;

Text(l10n.auth_login)           // "Login"
Text(l10n.wallet_balance)       // "Balance"
Text(l10n.send_transferSuccess) // "Transfer successful!"

// With parameters
Text(l10n.auth_otpMessage('+225012345678'))
// "Enter the 6-digit code sent to +225012345678"
```

### Add New Strings
```json
// lib/l10n/app_en.arb
{
  "feature_newString": "My new string",
  "@feature_newString": {
    "description": "Description for translators"
  },
  "feature_withParam": "Hello {name}",
  "@feature_withParam": {
    "placeholders": {
      "name": {"type": "String"}
    }
  }
}

// lib/l10n/app_fr.arb
{
  "feature_newString": "Ma nouvelle chaîne",
  "feature_withParam": "Bonjour {name}"
}
```

Then run: `flutter gen-l10n`

---

## Best Practices

### DO
- Use `AppButton`, `AppText`, `AppInput`, `AppSelect`, `AppCard` instead of raw Flutter widgets
- Use `AppColors`, `AppTypography`, `AppSpacing` for consistency
- Access APIs via `UsdcWalletSdk` provider
- Use mocks for new feature development
- Use `PinConfirmationSheet` for sensitive operations
- Check `featureFlagsProvider` before showing features

### DON'T
- Create new button/input/card styles without checking existing components
- Use raw `Colors`, `TextStyle`, or hardcoded spacing values
- Make direct Dio calls (use SDK services)
- Skip PIN/biometric confirmation for sensitive actions
- Show features without checking feature flags

---

## File Structure Overview

```
lib/
├── design/
│   ├── tokens/           # Colors, typography, spacing, shadows
│   ├── components/
│   │   ├── primitives/   # AppButton, AppText, AppInput, AppSelect, AppCard
│   │   └── composed/     # BalanceCard, PinPad, TransactionRow, etc.
│   └── theme/            # AppTheme, ThemeProvider
├── services/
│   ├── api/              # ApiClient, cache, deduplication
│   ├── sdk/              # UsdcWalletSdk (unified entry point)
│   ├── auth/             # AuthService
│   ├── wallet/           # WalletService
│   ├── transactions/     # TransactionsService
│   ├── transfers/        # TransfersService
│   ├── pin/              # PinService
│   ├── biometric/        # BiometricService
│   ├── security/         # DeviceSecurity, RiskBasedSecurity, etc.
│   ├── session/          # SessionService, SessionManager
│   ├── notifications/    # Push, local, rich notifications
│   ├── feature_flags/    # FeatureFlagsService
│   ├── localization/     # LanguageService, LanguageProvider
│   └── contacts/         # ContactsService
├── state/                # Riverpod state machines
├── mocks/                # Mocking framework
├── router/               # GoRouter + transitions
├── l10n/                 # Localization (EN, FR)
├── features/             # Feature modules (views, providers)
└── domain/               # Entities, enums, DTOs
```

---

*Last updated: 2026-01-27*
