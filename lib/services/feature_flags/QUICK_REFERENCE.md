# Feature Flags - Quick Reference

## Setup Complete ✅

The feature flags system is fully implemented and ready to use:

- ✅ Backend API integration (`/feature-flags/me`)
- ✅ SharedPreferences caching
- ✅ Auto-refresh every 15 minutes
- ✅ Refresh on app resume
- ✅ Mock data for development
- ✅ Widget gates (FeatureGate, MultiFeatureGate, AnyFeatureGate)
- ✅ Extension methods for clean checks
- ✅ Router guard examples

## Available Feature Keys

```dart
// Import
import 'package:usdc_wallet/services/feature_flags/feature_flags_service.dart';

// Backend-controlled
FeatureFlagKeys.twoFactorAuth
FeatureFlagKeys.externalTransfers
FeatureFlagKeys.billPayments
FeatureFlagKeys.savingsPots
FeatureFlagKeys.biometricAuth
FeatureFlagKeys.mobileMoneyWithdrawals

// New features (as requested)
FeatureFlagKeys.merchantQr          // Merchant QR payments
FeatureFlagKeys.paymentLinks        // Payment link creation
FeatureFlagKeys.referralProgram     // Referral rewards
FeatureFlagKeys.recurringTransfers  // Scheduled transfers
```

## Quick Usage

### 1. Simple Show/Hide

```dart
import 'package:usdc_wallet/services/feature_flags/feature_gate.dart';

FeatureGate(
  flag: FeatureFlagKeys.merchantQr,
  child: MerchantQrButton(),
)
```

### 2. With Fallback

```dart
FeatureGate(
  flag: FeatureFlagKeys.paymentLinks,
  child: PaymentLinksCard(),
  fallback: ComingSoonCard(),
)
```

### 3. Conditional Rendering

```dart
FeatureGateBuilder(
  flag: FeatureFlagKeys.referralProgram,
  builder: (context, isEnabled) {
    return isEnabled
      ? ReferralSection()
      : Text('Coming Soon');
  },
)
```

### 4. Check in Provider

```dart
final flags = ref.watch(featureFlagsProvider);

if (flags.canUseMerchantQr) {
  // Show merchant features
}

if (flags.canUsePaymentLinks) {
  // Show payment links
}
```

### 5. Router Guard

```dart
// In app_router.dart redirect function
if (path.startsWith('/merchant') && !flags.canUseMerchantQr) {
  return '/home'; // Redirect if disabled
}

if (path.startsWith('/payment-links') && !flags.canUsePaymentLinks) {
  return '/home';
}
```

## Extension Methods

```dart
final flags = ref.watch(featureFlagsProvider);

// Clean readable checks
flags.canUseMerchantQr           // merchant_qr
flags.canUsePaymentLinks         // payment_links
flags.canUseReferralProgram      // referral_program
flags.canScheduleTransfers       // recurring_transfers
flags.canUseSavingsPots          // savings_pots
flags.canUseExternalTransfers    // external_transfers
flags.canUseBillPayments         // bill_payments
```

## Convenience Providers

```dart
// Watch individual flags
final canUseMerchant = ref.watch(merchantQrEnabledProvider);
final canUseLinks = ref.watch(paymentLinksEnabledProvider);
final canUseReferral = ref.watch(referralProgramEnabledProvider);
final canSchedule = ref.watch(recurringTransfersEnabledProvider);
```

## Common Patterns

### Settings Screen

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return ListView(
      children: [
        if (flags.canUsePaymentLinks)
          SettingsTile(
            title: 'Payment Links',
            onTap: () => context.push('/payment-links'),
          ),

        if (flags.canUseMerchantQr)
          SettingsTile(
            title: 'Merchant QR',
            onTap: () => context.push('/merchant'),
          ),

        SettingsTile(
          title: 'Recurring Transfers',
          onTap: flags.canScheduleTransfers
              ? () => context.push('/recurring')
              : null,
          trailing: flags.canScheduleTransfers
              ? Icon(Icons.chevron_right)
              : Chip(label: Text('Soon')),
        ),
      ],
    );
  }
}
```

### Home Screen Features

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Always visible
        DepositCard(),
        SendCard(),

        // Feature-gated
        FeatureGate(
          flag: FeatureFlagKeys.merchantQr,
          child: MerchantQrCard(
            onTap: () => context.push('/merchant/scan'),
          ),
        ),

        FeatureGate(
          flag: FeatureFlagKeys.paymentLinks,
          child: PaymentLinksCard(
            onTap: () => context.push('/payment-links'),
          ),
        ),

        FeatureGate(
          flag: FeatureFlagKeys.referralProgram,
          child: ReferralCard(
            onTap: () => context.push('/referral'),
          ),
        ),
      ],
    );
  }
}
```

### Before API Call

```dart
class TransferNotifier extends Notifier<TransferState> {
  Future<void> createRecurringTransfer() async {
    final flags = ref.read(featureFlagsProvider);

    if (!flags.canScheduleTransfers) {
      state = state.copyWith(
        error: 'Recurring transfers not available',
      );
      return;
    }

    // Proceed with API call
    final sdk = ref.read(sdkProvider);
    await sdk.transfers.createRecurring(...);
  }
}
```

## Manual Operations

```dart
// Refresh flags
await ref.read(featureFlagsProvider.notifier).refresh();

// Load from cache/API
await ref.read(featureFlagsProvider.notifier).loadFlags();

// Clear cache (testing)
await ref.read(featureFlagsProvider.notifier).clearCache();

// Check if enabled
final isEnabled = ref.read(featureFlagsProvider.notifier).isEnabled(
  FeatureFlagKeys.merchantQr,
);
```

## Testing

### Override in Tests

```dart
testWidgets('shows merchant QR when enabled', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        featureFlagsProvider.overrideWith((ref) => {
          FeatureFlagKeys.merchantQr: true,
          FeatureFlagKeys.paymentLinks: false,
        }),
      ],
      child: MyApp(),
    ),
  );

  expect(find.text('Merchant QR'), findsOneWidget);
  expect(find.text('Payment Links'), findsNothing);
});
```

### Modify Mock Data

```dart
// In lib/mocks/services/feature_flags/feature_flags_mock.dart
'flags': {
  'merchant_qr': true,
  'payment_links': true,
  'referral_program': true,
  'recurring_transfers': false,
}
```

## Backend Endpoint

```
GET /api/v1/feature-flags/me

Response:
{
  "flags": {
    "merchant_qr": true,
    "payment_links": true,
    "referral_program": true,
    "recurring_transfers": false,
    "savings_pots": false,
    "external_transfers": true,
    "bill_payments": true,
    ...
  }
}
```

## Files Reference

```
lib/services/feature_flags/
├── feature_flags_service.dart       # Core service with cache
├── feature_flags_provider.dart      # Riverpod providers
├── feature_gate.dart                # Widget gates
├── feature_flags_extensions.dart    # Extension methods
├── README.md                        # Full documentation
├── INTEGRATION_GUIDE.md             # Step-by-step guide
├── QUICK_REFERENCE.md              # This file
└── router_example.dart              # Router integration examples

lib/mocks/services/feature_flags/
├── feature_flags_mock.dart          # Mock API responses
└── feature_flags_contract.dart      # API contract
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Flags not loading | Check SharedPreferences initialized in main.dart |
| Old flags showing | Force refresh: `ref.read(featureFlagsProvider.notifier).refresh()` |
| Feature not showing | Check mock data and flag key spelling |
| Tests failing | Override provider in ProviderScope |

## Next Steps

1. ✅ Feature flags are ready to use
2. Add route guards in `lib/router/app_router.dart`
3. Use `FeatureGate` widgets in views
4. Guard API calls in providers
5. Test with mock data (enabled by default in debug)

## Support

- Full docs: `lib/services/feature_flags/README.md`
- Integration guide: `lib/services/feature_flags/INTEGRATION_GUIDE.md`
- Router examples: `lib/services/feature_flags/router_example.dart`
