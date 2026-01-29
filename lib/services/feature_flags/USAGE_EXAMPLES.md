# Feature Flags - Usage Examples

Real-world examples for implementing the requested features with feature flags.

## Table of Contents
- [Merchant QR Payments](#merchant-qr-payments)
- [Payment Links](#payment-links)
- [Referral Program](#referral-program)
- [Recurring Transfers](#recurring-transfers)
- [Savings Pots](#savings-pots)
- [External Transfers](#external-transfers)
- [Bill Payments](#bill-payments)

---

## Merchant QR Payments

### 1. Home Screen - Scan QR Button

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../services/feature_flags/feature_gate.dart';
import '../../../services/feature_flags/feature_flags_service.dart';

class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          // Merchant QR - only show if enabled
          FeatureGate(
            flag: FeatureFlagKeys.merchantQr,
            child: Card(
              child: ListTile(
                leading: Icon(Icons.qr_code_scanner),
                title: Text('Scan Merchant QR'),
                subtitle: Text('Pay at stores with QR'),
                trailing: Icon(Icons.chevron_right),
                onTap: () => context.push('/merchant/scan'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 2. App Bar - QR Scan Icon

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUseMerchantQr = ref.watch(merchantQrEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('JoonaPay'),
        actions: [
          if (canUseMerchantQr)
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () => context.push('/merchant/scan'),
              tooltip: 'Scan QR Code',
            ),
        ],
      ),
      body: ...,
    );
  }
}
```

### 3. Merchant Dashboard - Full Feature

```dart
class MerchantDashboardView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text('Merchant Tools')),
      body: ListView(
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.qr_code_scanner),
              title: Text('Scan Customer QR'),
              onTap: () => context.push('/merchant/scan'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.qr_code),
              title: Text('Show My QR Code'),
              onTap: () => context.push('/merchant/qr'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.receipt_long),
              title: Text('Transaction History'),
              onTap: () => context.push('/merchant/transactions'),
            ),
          ),
        ],
      ),
    );
  }
}
```

### 4. Before Processing Payment

```dart
class MerchantPaymentNotifier extends Notifier<PaymentState> {
  @override
  PaymentState build() => PaymentState.initial();

  Future<void> processQrPayment(String qrData) async {
    // Check if feature is enabled
    final flags = ref.read(featureFlagsProvider);
    if (!flags.canUseMerchantQr) {
      state = state.copyWith(
        error: 'Merchant QR payments are not available in your region',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final sdk = ref.read(sdkProvider);
      final result = await sdk.merchant.processQrPayment(qrData);
      state = state.copyWith(
        isLoading: false,
        success: true,
        transaction: result,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## Payment Links

### 1. Settings Screen - Payment Links Option

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return ListView(
      children: [
        // Conditionally show Payment Links section
        if (flags.canUsePaymentLinks)
          Card(
            child: ListTile(
              leading: Icon(Icons.link),
              title: Text('Payment Links'),
              subtitle: Text('Create shareable payment links'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => context.push('/payment-links'),
            ),
          ),
      ],
    );
  }
}
```

### 2. Payment Links List

```dart
class PaymentLinksListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linksState = ref.watch(paymentLinksProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Links'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => context.push('/payment-links/create'),
          ),
        ],
      ),
      body: linksState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (links) => ListView.builder(
          itemCount: links.length,
          itemBuilder: (context, index) {
            final link = links[index];
            return LinkCard(
              link: link,
              onTap: () => context.push('/payment-links/${link.id}'),
            );
          },
        ),
      ),
    );
  }
}
```

### 3. Create Payment Link - Guard in Provider

```dart
class PaymentLinksNotifier extends Notifier<PaymentLinksState> {
  @override
  PaymentLinksState build() => PaymentLinksState.initial();

  Future<void> createPaymentLink({
    required double amount,
    required String description,
  }) async {
    // Check feature flag before API call
    final flags = ref.read(featureFlagsProvider);
    if (!flags.canUsePaymentLinks) {
      state = state.copyWith(
        error: 'Payment links are not available yet',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final sdk = ref.read(sdkProvider);
      final link = await sdk.paymentLinks.create(
        amount: amount,
        description: description,
      );

      state = state.copyWith(
        isLoading: false,
        createdLink: link,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## Referral Program

### 1. Home Screen - Referral Banner

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Balance card, etc.

        // Referral banner - only show if enabled
        FeatureGate(
          flag: FeatureFlagKeys.referralProgram,
          child: Card(
            color: Colors.green[100],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.card_giftcard, size: 48),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Refer & Earn',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text('Get 1000 XOF for each friend'),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right),
                    onPressed: () => context.push('/referral'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

### 2. Settings - Referral Option

```dart
class SettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Show referral option if enabled
        FeatureGate(
          flag: FeatureFlagKeys.referralProgram,
          child: ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Refer & Earn'),
            subtitle: Text('Invite friends and get rewards'),
            trailing: Icon(Icons.chevron_right),
            onTap: () => context.push('/referral'),
          ),
        ),
      ],
    );
  }
}
```

### 3. Referral Screen

```dart
class ReferralsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralState = ref.watch(referralProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Refer & Earn')),
      body: Column(
        children: [
          // Referral code
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Your Referral Code'),
                  SelectableText(
                    referralState.code,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: Icon(Icons.share),
                    label: Text('Share'),
                    onPressed: () => _shareReferralCode(ref),
                  ),
                ],
              ),
            ),
          ),

          // Stats
          Card(
            child: ListTile(
              title: Text('Total Referrals'),
              trailing: Text('${referralState.totalReferrals}'),
            ),
          ),
          Card(
            child: ListTile(
              title: Text('Total Earned'),
              trailing: Text('${referralState.totalEarned} XOF'),
            ),
          ),
        ],
      ),
    );
  }

  void _shareReferralCode(WidgetRef ref) async {
    final code = ref.read(referralProvider).code;
    // Share logic
  }
}
```

---

## Recurring Transfers

### 1. Send Screen - Schedule Option

```dart
class SendConfirmScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSchedule = ref.watch(recurringTransfersEnabledProvider);

    return Scaffold(
      body: Column(
        children: [
          // Transfer details

          // Schedule option - only if enabled
          if (canSchedule)
            SwitchListTile(
              title: Text('Schedule as recurring'),
              value: ref.watch(isRecurringProvider),
              onChanged: (value) {
                ref.read(isRecurringProvider.notifier).state = value;
              },
            ),

          if (canSchedule && ref.watch(isRecurringProvider))
            ListTile(
              title: Text('Frequency'),
              subtitle: Text('Every month'),
              trailing: Icon(Icons.chevron_right),
              onTap: () => _showFrequencyPicker(context),
            ),
        ],
      ),
    );
  }
}
```

### 2. Recurring Transfers List

```dart
class RecurringTransfersListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transfersState = ref.watch(recurringTransfersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Recurring Transfers'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => context.push('/recurring-transfers/create'),
          ),
        ],
      ),
      body: transfersState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (transfers) {
          if (transfers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.repeat, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No recurring transfers yet'),
                  SizedBox(height: 8),
                  ElevatedButton(
                    child: Text('Create One'),
                    onPressed: () => context.push('/recurring-transfers/create'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: transfers.length,
            itemBuilder: (context, index) {
              final transfer = transfers[index];
              return RecurringTransferCard(
                transfer: transfer,
                onTap: () => context.push('/recurring-transfers/${transfer.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
```

### 3. Create Recurring Transfer - Guard

```dart
class RecurringTransfersNotifier extends Notifier<RecurringTransfersState> {
  @override
  RecurringTransfersState build() => RecurringTransfersState.initial();

  Future<void> createRecurringTransfer({
    required String recipientId,
    required double amount,
    required String frequency,
  }) async {
    // Check feature flag
    final flags = ref.read(featureFlagsProvider);
    if (!flags.canScheduleTransfers) {
      state = state.copyWith(
        error: 'Recurring transfers are not available yet',
      );
      return;
    }

    state = state.copyWith(isLoading: true);
    try {
      final sdk = ref.read(sdkProvider);
      final transfer = await sdk.transfers.createRecurring(
        recipientId: recipientId,
        amount: amount,
        frequency: frequency,
      );

      state = state.copyWith(
        isLoading: false,
        transfers: [...state.transfers, transfer],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## Savings Pots

### 1. Home Screen - Savings Section

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        // Balance card

        // Savings Pots section - conditionally rendered
        FeatureGateBuilder(
          flag: FeatureFlagKeys.savingsPots,
          builder: (context, isEnabled) {
            if (!isEnabled) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.savings),
                  title: Text('Savings Pots'),
                  subtitle: Text('Coming soon!'),
                  trailing: Chip(label: Text('Soon')),
                ),
              );
            }

            return Card(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.savings),
                    title: Text('Savings Pots'),
                    trailing: TextButton(
                      child: Text('See All'),
                      onPressed: () => context.push('/savings-pots'),
                    ),
                  ),
                  // Show summary of pots
                  SavingsPotsPreview(),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
```

### 2. Savings Pots List

```dart
class PotsListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final potsState = ref.watch(savingsPotsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Savings Pots'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => context.push('/savings-pots/create'),
          ),
        ],
      ),
      body: potsState.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (pots) => GridView.builder(
          padding: EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: pots.length + 1,
          itemBuilder: (context, index) {
            if (index == pots.length) {
              return CreatePotCard(
                onTap: () => context.push('/savings-pots/create'),
              );
            }

            final pot = pots[index];
            return PotCard(
              pot: pot,
              onTap: () => context.push('/savings-pots/${pot.id}'),
            );
          },
        ),
      ),
    );
  }
}
```

---

## External Transfers

### 1. Send Screen - External Option

```dart
class SendScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      body: Column(
        children: [
          // Internal transfer option
          Card(
            child: ListTile(
              leading: Icon(Icons.person),
              title: Text('Send to JoonaPay User'),
              onTap: () => context.push('/send/recipient'),
            ),
          ),

          // External transfer - only if enabled
          if (flags.canUseExternalTransfers)
            Card(
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet),
                title: Text('Send to External Wallet'),
                subtitle: Text('Send to any crypto address'),
                onTap: () => context.push('/send-external'),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## Bill Payments

### 1. Services Screen

```dart
class ServicesView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 3,
      children: [
        // Always show
        ServiceCard(
          icon: Icons.phone_android,
          label: 'Airtime',
          onTap: () => context.push('/airtime'),
        ),

        // Bill payments - only if enabled
        FeatureGate(
          flag: FeatureFlagKeys.billPayments,
          child: ServiceCard(
            icon: Icons.receipt,
            label: 'Bills',
            onTap: () => context.push('/bill-payments'),
          ),
        ),
      ],
    );
  }
}
```

---

## Complete Example: Home Screen with All Features

```dart
class WalletHomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flags = ref.watch(featureFlagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('JoonaPay'),
        actions: [
          // Merchant QR scanner
          if (flags.canUseMerchantQr)
            IconButton(
              icon: Icon(Icons.qr_code_scanner),
              onPressed: () => context.push('/merchant/scan'),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Balance Card (always visible)
          BalanceCard(),
          SizedBox(height: 16),

          // Quick Actions
          Row(
            children: [
              Expanded(child: QuickActionButton(
                icon: Icons.add,
                label: 'Deposit',
                onTap: () => context.push('/deposit'),
              )),
              Expanded(child: QuickActionButton(
                icon: Icons.send,
                label: 'Send',
                onTap: () => context.push('/send'),
              )),
              Expanded(child: QuickActionButton(
                icon: Icons.call_received,
                label: 'Receive',
                onTap: () => context.push('/receive'),
              )),
            ],
          ),
          SizedBox(height: 24),

          // Referral Banner
          FeatureGate(
            flag: FeatureFlagKeys.referralProgram,
            child: ReferralBanner(
              onTap: () => context.push('/referral'),
            ),
          ),

          // Savings Pots Section
          FeatureGateBuilder(
            flag: FeatureFlagKeys.savingsPots,
            builder: (context, isEnabled) {
              if (!isEnabled) return SizedBox.shrink();
              return SavingsSection(
                onViewAll: () => context.push('/savings-pots'),
              );
            },
          ),

          // Features Grid
          Text('Features', style: Theme.of(context).textTheme.headline6),
          SizedBox(height: 8),

          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: [
              // Bill Payments
              if (flags.canUseBillPayments)
                FeatureCard(
                  icon: Icons.receipt,
                  label: 'Bills',
                  onTap: () => context.push('/bill-payments'),
                ),

              // Payment Links
              if (flags.canUsePaymentLinks)
                FeatureCard(
                  icon: Icons.link,
                  label: 'Links',
                  onTap: () => context.push('/payment-links'),
                ),

              // Recurring Transfers
              if (flags.canScheduleTransfers)
                FeatureCard(
                  icon: Icons.repeat,
                  label: 'Recurring',
                  onTap: () => context.push('/recurring-transfers'),
                ),
            ],
          ),

          // Transactions
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent', style: Theme.of(context).textTheme.headline6),
              TextButton(
                child: Text('View All'),
                onPressed: () => context.push('/transactions'),
              ),
            ],
          ),
          TransactionsList(limit: 5),
        ],
      ),
    );
  }
}
```

---

## Summary

All requested features are now guarded by feature flags:
- ✅ Merchant QR - `FeatureFlagKeys.merchantQr`
- ✅ Payment Links - `FeatureFlagKeys.paymentLinks`
- ✅ Referral Program - `FeatureFlagKeys.referralProgram`
- ✅ Recurring Transfers - `FeatureFlagKeys.recurringTransfers`

Use these examples as templates for your implementation.
