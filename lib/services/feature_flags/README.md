# Feature Flags Service

Backend-controlled feature flags with automatic refresh and offline caching.

## Features

- Fetches flags from backend API (`/feature-flags/me`)
- Auto-refreshes every 15 minutes
- Offline-first with SharedPreferences cache
- Server-side evaluation (user ID, country, app version, platform, rollout %)
- Declarative UI gating with widgets

## Setup

### 1. Initialize SharedPreferences

In `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}
```

### 2. Load Flags on Login

In your auth provider:

```dart
Future<void> login(String phone, String otp) async {
  // ... authenticate user

  // Refresh feature flags for logged-in user
  ref.read(featureFlagsProvider.notifier).refresh();
}
```

## Usage

### Check Flags in Providers

```dart
class TransferNotifier extends Notifier<TransferState> {
  Future<void> initiateExternalTransfer() async {
    final flags = ref.read(featureFlagsProvider);

    if (!flags[FeatureFlagKeys.externalTransfers] ?? false) {
      throw Exception('External transfers not available');
    }

    // ... proceed with transfer
  }
}
```

### Convenience Providers

```dart
final canTransferExternally = ref.watch(externalTransfersEnabledProvider);

if (canTransferExternally) {
  // Show external transfer option
}
```

### FeatureGate Widget

Conditionally render UI based on flags:

```dart
FeatureGate(
  flag: FeatureFlagKeys.billPayments,
  child: BillPaymentsCard(),
  fallback: ComingSoonCard(),
)
```

### FeatureGateBuilder

For more complex logic:

```dart
FeatureGateBuilder(
  flag: FeatureFlagKeys.savingsPots,
  builder: (context, isEnabled) {
    if (!isEnabled) {
      return Column(
        children: [
          DisabledFeatureBanner(),
          Text('Coming soon!'),
        ],
      );
    }

    return SavingsPotsSection();
  },
)
```

### MultiFeatureGate

Require multiple flags:

```dart
MultiFeatureGate(
  flags: [
    FeatureFlagKeys.externalTransfers,
    FeatureFlagKeys.biometricAuth,
  ],
  child: SecureExternalTransferButton(),
  fallback: Text('Secure transfers require biometric auth'),
)
```

### AnyFeatureGate

Show if any flag is enabled:

```dart
AnyFeatureGate(
  flags: [
    FeatureFlagKeys.billPayments,
    FeatureFlagKeys.airtime,
  ],
  child: ServicesSection(),
  fallback: SizedBox.shrink(),
)
```

## Available Flags

Backend-controlled flags from `system.feature_flags` table:

| Flag Key | Default | Description |
|----------|---------|-------------|
| `two_factor_auth` | `false` | Two-factor authentication |
| `external_transfers` | `true` | External crypto transfers |
| `bill_payments` | `true` | Bill payment services |
| `savings_pots` | `false` | Savings goals feature |
| `biometric_auth` | `true` | Biometric authentication |
| `mobile_money_withdrawals` | `true` | Mobile money withdrawals |

## API Endpoints

### Get All Flags

```
GET /api/v1/feature-flags/me
```

Response:
```json
{
  "flags": {
    "two_factor_auth": false,
    "external_transfers": true,
    "bill_payments": true,
    "savings_pots": false,
    "biometric_auth": true,
    "mobile_money_withdrawals": true
  }
}
```

### Check Single Flag

```
GET /api/v1/feature-flags/check/:key
```

Response:
```json
{
  "key": "bill_payments",
  "isEnabled": true
}
```

## Backend Evaluation

Flags are evaluated server-side based on:

- **User ID**: Enable for specific users
- **Country**: Enable for specific countries (ISO 3166-1 alpha-3)
- **App Version**: Minimum required version
- **Platform**: `ios`, `android`, `web`
- **Rollout Percentage**: Gradual rollout (0-100%)
- **Time Window**: `starts_at` / `ends_at` timestamps

## Testing

### Enable All Flags (Development)

```dart
// In debug mode, all flags are enabled by default
// See MockConfig.useMocks
```

### Override Specific Flag

```dart
// For testing, modify mock data in:
// lib/mocks/services/feature_flags/feature_flags_mock.dart
```

### Clear Cache

```dart
await ref.read(featureFlagsProvider.notifier).clearCache();
```

## Performance

- Flags cached in SharedPreferences
- Auto-refresh every 15 minutes
- Offline-first: uses cache if network unavailable
- Minimal UI rebuilds (Riverpod watches only used flags)

## Best Practices

1. Always use `FeatureGate` for UI gating
2. Check flags before expensive operations
3. Provide fallback UI for disabled features
4. Don't fetch flags repeatedly (use cached state)
5. Refresh on login to get user-specific flags
6. Handle flag changes gracefully (don't crash)

## Migration from Old System

Old hardcoded flags → New backend flags:

```dart
// OLD
if (FeatureFlags.mvp().canPayBills) { ... }

// NEW
if (ref.watch(featureFlagsProvider)[FeatureFlagKeys.billPayments] ?? false) { ... }

// OR
FeatureGate(flag: FeatureFlagKeys.billPayments, child: ...)
```
