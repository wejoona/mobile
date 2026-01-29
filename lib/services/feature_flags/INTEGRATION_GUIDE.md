# Feature Flags Integration Guide

Complete guide for integrating feature flags throughout the JoonaPay mobile app.

## Table of Contents
1. [Setup](#setup)
2. [Usage in Views](#usage-in-views)
3. [Usage in Providers](#usage-in-providers)
4. [Router Integration](#router-integration)
5. [Settings Screen](#settings-screen)
6. [Testing](#testing)

---

## Setup

### 1. Already Configured
The feature flags system is already initialized in `main.dart`:
- SharedPreferences initialized
- Provider override configured
- Auto-refresh on app resume via `SessionManager`

### 2. Feature Keys Available

```dart
// Backend-controlled flags
FeatureFlagKeys.twoFactorAuth
FeatureFlagKeys.externalTransfers
FeatureFlagKeys.billPayments
FeatureFlagKeys.savingsPots
FeatureFlagKeys.biometricAuth
FeatureFlagKeys.mobileMoneyWithdrawals

// Phase rollout flags
FeatureFlagKeys.deposit          // Phase 1 (MVP)
FeatureFlagKeys.send             // Phase 1 (MVP)
FeatureFlagKeys.receive          // Phase 1 (MVP)
FeatureFlagKeys.transactions     // Phase 1 (MVP)
FeatureFlagKeys.kyc              // Phase 1 (MVP)
FeatureFlagKeys.withdraw         // Phase 2
FeatureFlagKeys.offRamp          // Phase 2
FeatureFlagKeys.airtime          // Phase 3
FeatureFlagKeys.bills            // Phase 3
FeatureFlagKeys.savings          // Phase 4
FeatureFlagKeys.virtualCards     // Phase 4
FeatureFlagKeys.splitBills       // Phase 4
FeatureFlagKeys.recurringTransfers // Phase 4
FeatureFlagKeys.budget           // Phase 4
FeatureFlagKeys.agentNetwork     // Phase 5
FeatureFlagKeys.ussd             // Phase 5

// Feature flags
FeatureFlagKeys.referrals
FeatureFlagKeys.referralProgram
FeatureFlagKeys.analytics
FeatureFlagKeys.currencyConverter
FeatureFlagKeys.requestMoney
FeatureFlagKeys.scheduledTransfers
FeatureFlagKeys.savedRecipients
FeatureFlagKeys.merchantQr
FeatureFlagKeys.paymentLinks
```

---

## Usage in Views

### Method 1: FeatureGate Widget (Recommended)

Simple show/hide based on flag:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/feature_flags/feature_gate.dart';
import '../../../services/feature_flags/feature_flags_service.dart';

class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ListView(
        children: [
          // Always visible
          DepositCard(),
          SendCard(),

          // Only show if bill payments enabled
          FeatureGate(
            flag: FeatureFlagKeys.billPayments,
            child: BillPaymentsCard(),
          ),

          // Show "Coming Soon" if disabled
          FeatureGate(
            flag: FeatureFlagKeys.savingsPots,
            child: SavingsPotsCard(),
            fallback: ComingSoonCard(title: 'Savings Pots'),
          ),
        ],
      ),
    );
  }
}
```

### Method 2: FeatureGateBuilder (Conditional Logic)

For more complex rendering:

```dart
FeatureGateBuilder(
  flag: FeatureFlagKeys.merchantQr,
  builder: (context, isEnabled) {
    if (!isEnabled) {
      return Column(
        children: [
          Icon(Icons.lock, size: 48),
          Text('Feature locked'),
          Text('Available in your region soon!'),
        ],
      );
    }

    return MerchantQrSection(
      onScan: () => context.push('/merchant/scan'),
      onGenerate: () => context.push('/merchant/generate'),
    );
  },
)
```

### Method 3: MultiFeatureGate (Multiple Requirements)

Require multiple flags:

```dart
MultiFeatureGate(
  flags: [
    FeatureFlagKeys.externalTransfers,
    FeatureFlagKeys.biometricAuth,
  ],
  child: SecureExternalTransferButton(
    onPressed: () => context.push('/transfer/external'),
  ),
  fallback: Text('Requires biometric authentication'),
)
```

### Method 4: AnyFeatureGate (Any Flag Enabled)

Show if ANY flag is enabled:

```dart
AnyFeatureGate(
  flags: [
    FeatureFlagKeys.billPayments,
    FeatureFlagKeys.airtime,
  ],
  child: ServicesSection(),
  fallback: EmptyState(message: 'No services available yet'),
)
```

### Method 5: Direct Check in Provider

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);
    final canUsePaymentLinks = flags.canUsePaymentLinks; // Extension method

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (canUsePaymentLinks)
            IconButton(
              icon: Icon(Icons.link),
              onPressed: () => context.push('/payment-links'),
            ),
        ],
      ),
      body: ...,
    );
  }
}
```

---

## Usage in Providers

### Check Flag Before API Call

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/feature_flags/feature_flags_provider.dart';
import '../../services/feature_flags/feature_flags_service.dart';

class TransferNotifier extends Notifier<TransferState> {
  @override
  TransferState build() => TransferState.initial();

  Future<void> initiateExternalTransfer({
    required String address,
    required double amount,
  }) async {
    // Check if feature is enabled
    final flags = ref.read(featureFlagsProvider);
    if (!flags[FeatureFlagKeys.externalTransfers] ?? false) {
      state = state.copyWith(
        error: 'External transfers are not available in your region',
      );
      return;
    }

    // Proceed with transfer
    state = state.copyWith(isLoading: true);
    try {
      final sdk = ref.read(sdkProvider);
      await sdk.transfers.createExternalTransfer(
        recipientAddress: address,
        amount: amount,
      );
      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final transferProvider = NotifierProvider<TransferNotifier, TransferState>(
  TransferNotifier.new,
);
```

### Use Convenience Providers

```dart
class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => SettingsState.initial();

  List<SettingItem> getAvailableSettings() {
    final canUseTwoFactor = ref.watch(twoFactorAuthEnabledProvider);
    final canUseBiometric = ref.watch(biometricAuthEnabledProvider);

    return [
      SettingItem(title: 'Change PIN', icon: Icons.lock),
      if (canUseBiometric)
        SettingItem(title: 'Biometric Auth', icon: Icons.fingerprint),
      if (canUseTwoFactor)
        SettingItem(title: '2FA Settings', icon: Icons.security),
    ];
  }
}
```

---

## Router Integration

### Guard Routes Based on Flags

```dart
// In lib/router/app_router.dart

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final flags = ref.watch(featureFlagsProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final path = state.uri.path;

      // Feature flag guards
      if (path.startsWith('/merchant') && !flags.canUseMerchantQr) {
        return '/home'; // Redirect to home if feature disabled
      }

      if (path.startsWith('/payment-links') && !flags.canUsePaymentLinks) {
        return '/home';
      }

      if (path.startsWith('/savings-pots') && !flags.canUseSavingsPots) {
        return '/home';
      }

      if (path.startsWith('/recurring') && !flags.canScheduleTransfers) {
        return '/home';
      }

      // Auth guards
      if (!isAuthenticated && !_isPublicRoute(path)) {
        return '/login';
      }

      return null; // No redirect
    },
    routes: [
      // Public routes
      GoRoute(path: '/splash', builder: (_, __) => SplashView()),
      GoRoute(path: '/login', builder: (_, __) => LoginPhoneView()),

      // Protected routes with feature flag checks in redirect
      GoRoute(path: '/home', builder: (_, __) => WalletHomeScreen()),
      GoRoute(path: '/merchant/scan', builder: (_, __) => ScanQrView()),
      GoRoute(path: '/payment-links', builder: (_, __) => PaymentLinksListView()),
      GoRoute(path: '/savings-pots', builder: (_, __) => PotsListView()),
      GoRoute(path: '/recurring', builder: (_, __) => RecurringTransfersListView()),
    ],
  );
});

bool _isPublicRoute(String path) {
  return path == '/splash' || path.startsWith('/login');
}
```

---

## Settings Screen

### Conditionally Show Settings Items

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/feature_flags/feature_flags_provider.dart';
import '../../../services/feature_flags/feature_flags_extensions.dart';

class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        children: [
          // Always available
          SettingsTile(
            title: 'Profile',
            icon: Icons.person,
            onTap: () => context.push('/settings/profile'),
          ),
          SettingsTile(
            title: 'Security',
            icon: Icons.lock,
            onTap: () => context.push('/settings/security'),
          ),

          // Conditional sections
          if (flags.canUseBiometricAuth)
            SettingsTile(
              title: 'Biometric Authentication',
              icon: Icons.fingerprint,
              onTap: () => context.push('/settings/biometric'),
            ),

          if (flags.canUseTwoFactorAuth)
            SettingsTile(
              title: 'Two-Factor Authentication',
              icon: Icons.security,
              onTap: () => context.push('/settings/2fa'),
            ),

          if (flags.canUsePaymentLinks)
            SettingsTile(
              title: 'Payment Links',
              icon: Icons.link,
              onTap: () => context.push('/payment-links'),
            ),

          Divider(),

          // Features section with coming soon badges
          SettingsSectionHeader(title: 'Features'),

          SettingsTile(
            title: 'Savings Pots',
            icon: Icons.savings,
            onTap: flags.canUseSavingsPots
                ? () => context.push('/savings-pots')
                : null,
            trailing: flags.canUseSavingsPots
                ? Icon(Icons.chevron_right)
                : Chip(label: Text('Coming Soon')),
          ),

          SettingsTile(
            title: 'Recurring Transfers',
            icon: Icons.repeat,
            onTap: flags.canScheduleTransfers
                ? () => context.push('/recurring')
                : null,
            trailing: flags.canScheduleTransfers
                ? Icon(Icons.chevron_right)
                : Chip(label: Text('Coming Soon')),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing

### Override Feature Flags in Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('should show payment links when flag enabled', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featureFlagsProvider.overrideWith((ref) => {
            FeatureFlagKeys.paymentLinks: true,
            FeatureFlagKeys.merchantQr: false,
          }),
        ],
        child: MaterialApp(home: SettingsScreen()),
      ),
    );

    expect(find.text('Payment Links'), findsOneWidget);
    expect(find.text('Merchant QR'), findsNothing);
  });
}
```

### Clear Cache for Testing

```dart
// In debug builds or test setup
await ref.read(featureFlagsProvider.notifier).clearCache();
```

### Override Mock Data

```dart
// In lib/mocks/services/feature_flags/feature_flags_mock.dart
// Modify the mock response to test different scenarios

// Enable all flags
'flags': {
  'bill_payments': true,
  'savings_pots': true,
  'merchant_qr': true,
  // ...
}

// Disable all flags
'flags': {
  'bill_payments': false,
  'savings_pots': false,
  'merchant_qr': false,
  // ...
}
```

---

## Best Practices

### 1. Always Provide Fallback UI
```dart
FeatureGate(
  flag: FeatureFlagKeys.savingsPots,
  child: SavingsSection(),
  fallback: ComingSoonCard(), // Don't just hide it
)
```

### 2. Check Flags Before Expensive Operations
```dart
Future<void> generateQrCode() async {
  // Check flag BEFORE generating QR
  if (!ref.read(featureFlagsProvider).canUseMerchantQr) {
    showError('Feature not available');
    return;
  }

  // Expensive operation
  final qr = await generateComplexQr();
}
```

### 3. Use Extensions for Readability
```dart
// Good
if (flags.canUseMerchantQr) { ... }

// Less readable
if (flags[FeatureFlagKeys.merchantQr] ?? false) { ... }
```

### 4. Refresh on Login
```dart
// In auth provider after successful login
Future<void> verifyOtp(String phone, String otp) async {
  await sdk.auth.verifyOtp(phone: phone, otp: otp);

  // Refresh flags for this user
  ref.read(featureFlagsProvider.notifier).refresh();
}
```

### 5. Handle Flag Changes Gracefully
```dart
// Listen for flag changes
ref.listen(featureFlagsProvider, (previous, next) {
  if (previous?.canUseMerchantQr == true &&
      next.canUseMerchantQr == false) {
    // Feature was disabled, navigate away
    context.go('/home');
  }
});
```

---

## Troubleshooting

### Flags Not Loading
1. Check SharedPreferences is initialized in main.dart
2. Verify backend endpoint returns 200
3. Check network connectivity
4. Look for errors in debug console

### Flags Not Refreshing
1. Refresh interval is 15 minutes by default
2. Force refresh: `ref.read(featureFlagsProvider.notifier).refresh()`
3. Clear cache: `ref.read(featureFlagsProvider.notifier).clearCache()`

### Feature Not Showing
1. Check mock data in `feature_flags_mock.dart`
2. Verify flag key matches backend
3. Check router redirect logic
4. Use `print(flags)` to debug current state

---

## Summary

Feature flags are fully integrated and ready to use:
- ✅ Cached locally with SharedPreferences
- ✅ Auto-refresh every 15 minutes
- ✅ Refresh on app resume
- ✅ Refresh on login
- ✅ Router guards implemented
- ✅ Widget gates available (FeatureGate, MultiFeatureGate, etc.)
- ✅ Extension methods for clean checks
- ✅ Mock data for development

Use feature flags to:
1. Roll out features gradually
2. A/B test features
3. Enable features per region/country
4. Disable broken features instantly
5. Control feature access by user tier
