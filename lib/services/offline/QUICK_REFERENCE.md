# Offline Mode Quick Reference

## Imports

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/connectivity/connectivity_provider.dart';
import '../services/offline/offline_mode_manager.dart';
import '../design/components/composed/offline_banner.dart';
```

## Check Connectivity

```dart
// Simple check
final isOnline = ref.watch(isOnlineProvider);

// Full state
final state = ref.watch(connectivityProvider);
print(state.isOnline);         // true/false
print(state.pendingCount);     // number of queued transfers
print(state.isProcessingQueue); // true when syncing
print(state.lastSync);          // DateTime of last sync
```

## UI Components

```dart
// Banner (dismissible, full-width)
const OfflineBanner()

// Small indicator
const OfflineIndicator()

// Syncing spinner
const SyncingIndicator()

// "Last synced: 5m ago"
const LastSyncIndicator()

// Pending count badge
const OfflineStatusBadge()
```

## Get Cached Data

```dart
final manager = await ref.read(offlineModeManagerFutureProvider.future);

// Balance
final balance = await manager.getBalance();
print(balance?.data);       // 10000.0
print(balance?.isCached);   // true if offline
print(balance?.isStale);    // true if > 5 min old

// Transactions
final txns = await manager.getTransactions();
print(txns?.data.length);   // List of transactions

// Beneficiaries
final beneficiaries = await manager.getBeneficiaries();
print(beneficiaries?.data); // List of beneficiaries
```

## Update Cache

```dart
// After successful API call
await manager.updateBalance(1000.0);
await manager.updateTransactions([...]);
await manager.updateBeneficiaries([...]);
await manager.updateWalletId('wallet-123');
```

## Queue Transfer

```dart
final isOnline = ref.read(isOnlineProvider);

if (!isOnline) {
  // Queue it
  final transferId = await manager.queueTransfer(
    recipientPhone: '+225 XX XX XX XX',
    recipientName: 'John Doe',    // optional
    amount: 10000,
    description: 'Payment',        // optional
  );

  // Show confirmation
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.offline_transferQueued),
      content: Text(l10n.offline_transferQueuedDesc),
    ),
  );
} else {
  // Send immediately
  await sdk.transfers.send(...);
}
```

## Manage Queue

```dart
// Get all pending
final pending = manager.getPendingTransfers();

// Get count
final count = pending.where((t) =>
  t.status == TransferStatus.pending
).length;

// Retry failed
await manager.retryTransfer(transferId);

// Cancel
await manager.cancelTransfer(transferId);

// Clear completed (older than 7 days)
await manager.clearCompleted();
```

## Manual Sync

```dart
// Trigger queue processing manually
await ref.read(connectivityProvider.notifier).processQueueManually();

// Refresh pending count
await ref.read(connectivityProvider.notifier).refreshPendingCount();
```

## Listen to Connectivity

```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.listen<ConnectivityState>(
      connectivityProvider,
      (previous, next) {
        // Went offline
        if (previous?.isOnline == true && next.isOnline == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are offline')),
          );
        }

        // Back online
        if (previous?.isOnline == false && next.isOnline == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Back online, syncing...')),
          );
        }

        // Queue finished processing
        if (previous?.isProcessingQueue == true &&
            next.isProcessingQueue == false) {
          print('Sync complete');
        }
      },
    );
  });
}
```

## Feature Checks

```dart
// Check if feature available offline
if (manager.isFeatureAvailableOffline(OfflineFeature.viewBalance)) {
  // Show balance screen
}

// Available features:
OfflineFeature.viewBalance
OfflineFeature.viewTransactions
OfflineFeature.viewBeneficiaries
OfflineFeature.generateReceiveQR
OfflineFeature.queueTransfer
```

## Cache Status

```dart
final status = manager.getCacheStatus();

print(status.hasBalance);        // bool
print(status.hasTransactions);   // bool
print(status.hasBeneficiaries);  // bool
print(status.hasWalletId);       // bool
print(status.lastSync);          // DateTime?
print(status.hasAnyCache);       // bool
```

## Clear Cache

```dart
// Clear everything
await manager.clearAllCache();

// Check if cache exists
if (manager.hasCachedData()) {
  print('Cache exists');
}
```

## Common Patterns

### Display Balance with Indicator

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final offlineManager = ref.watch(offlineModeManagerFutureProvider);

  return offlineManager.when(
    data: (manager) => FutureBuilder(
      future: manager.getBalance(),
      builder: (context, snapshot) {
        final data = snapshot.data;

        return Column(
          children: [
            if (data?.isCached == true) ...[
              const OfflineIndicator(),
              SizedBox(height: 8),
            ],

            Text('Balance: ${data?.data ?? 0}'),

            if (data?.isStale == true)
              Text('Data may be outdated',
                style: TextStyle(color: Colors.orange)),

            if (data?.lastSync != null)
              const LastSyncIndicator(),
          ],
        );
      },
    ),
    loading: () => CircularProgressIndicator(),
    error: (e, _) => Text('Error: $e'),
  );
}
```

### Send Money with Queue

```dart
Future<void> _handleSend() async {
  final isOnline = ref.read(isOnlineProvider);
  final manager = await ref.read(offlineModeManagerFutureProvider.future);
  final l10n = AppLocalizations.of(context)!;

  if (!isOnline) {
    // Queue
    await manager.queueTransfer(
      recipientPhone: _phoneController.text,
      amount: double.parse(_amountController.text),
    );

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.offline_transferQueued),
          content: Text(l10n.offline_transferQueuedDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.action_done),
            ),
          ],
        ),
      );
    }
  } else {
    // Send immediately
    try {
      final sdk = ref.read(sdkProvider);
      await sdk.transfers.send(...);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Transfer sent')),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
}
```

### Refresh with Offline Check

```dart
Future<void> _onRefresh() async {
  final isOnline = ref.read(isOnlineProvider);

  if (!isOnline) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Refresh requires internet connection')),
    );
    return;
  }

  // Fetch fresh data
  final sdk = ref.read(sdkProvider);
  final balance = await sdk.wallet.getBalance();

  // Update cache
  final manager = await ref.read(offlineModeManagerFutureProvider.future);
  await manager.updateBalance(balance);

  setState(() {}); // Rebuild
}
```

### Conditional Button

```dart
AppButton(
  label: ref.watch(isOnlineProvider)
    ? 'Send Now'
    : 'Queue Transfer',
  onPressed: _handleSend,
)
```

### Pending Count Badge

```dart
InkWell(
  onTap: () => context.push('/pending-transfers'),
  child: Row(
    children: [
      Text('Pending Transfers'),
      SizedBox(width: 8),
      const OfflineStatusBadge(), // Shows count automatically
    ],
  ),
)
```

## L10n Keys

```dart
l10n.offline_youreOffline
l10n.offline_youreOfflineWithPending(count)
l10n.offline_syncing
l10n.offline_cacheData
l10n.offline_lastSynced(time)
l10n.offline_pendingTransfer
l10n.offline_transferQueued
l10n.offline_transferQueuedDesc
l10n.offline_viewPending
l10n.offline_retryFailed
l10n.offline_cancelTransfer
l10n.offline_noConnection
l10n.offline_checkConnection
```

## Routes

```dart
// Add to app_router.dart
GoRoute(
  path: '/pending-transfers',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const PendingTransfersView(),
  ),
),
```

## Transfer Status

```dart
enum TransferStatus {
  pending,      // Waiting to process
  processing,   // Currently processing
  completed,    // Success
  failed,       // Failed (can retry)
}

// Check status
if (transfer.status == TransferStatus.failed) {
  // Show retry button
}
```

## Debugging

```dart
// Check current state
final state = ref.read(connectivityProvider);
print('Online: ${state.isOnline}');
print('Processing: ${state.isProcessingQueue}');
print('Pending: ${state.pendingCount}');
print('Last sync: ${state.lastSync}');

// Check cache
final manager = await ref.read(offlineModeManagerFutureProvider.future);
print('Has cache: ${manager.hasCachedData()}');

final status = manager.getCacheStatus();
print('Cache: $status');

// List queue
final pending = manager.getPendingTransfers();
for (final transfer in pending) {
  print('${transfer.id}: ${transfer.status} - ${transfer.amount}');
}
```

## File Locations

```
lib/
├── services/
│   ├── connectivity/
│   │   └── connectivity_provider.dart
│   └── offline/
│       ├── offline_cache_service.dart
│       ├── pending_transfer_queue.dart
│       ├── offline_mode_manager.dart
│       ├── integration_example.dart
│       ├── offline_mode_readme.md
│       ├── IMPLEMENTATION_SUMMARY.md
│       ├── INTEGRATION_CHECKLIST.md
│       └── QUICK_REFERENCE.md (this file)
├── design/components/composed/
│   └── offline_banner.dart
└── features/wallet/views/
    └── pending_transfers_view.dart
```

## Need Help?

1. See `integration_example.dart` for complete examples
2. Check `offline_mode_readme.md` for detailed docs
3. Review `INTEGRATION_CHECKLIST.md` for step-by-step
4. Look at `pending_transfers_view.dart` for full screen example

## Common Issues

**Banner not showing?**
```dart
// Ensure it's in widget tree
Column(
  children: [
    const OfflineBanner(), // ← Add this
    Expanded(child: Content()),
  ],
)
```

**Queue not processing?**
```dart
// Check connectivity
final isOnline = ref.read(isOnlineProvider);
print('Online: $isOnline');

// Manually trigger
await ref.read(connectivityProvider.notifier).processQueueManually();
```

**Cache not updating?**
```dart
// Call update after API response
final balance = await sdk.wallet.getBalance();
await manager.updateBalance(balance); // ← Don't forget this
```

**Indicator not appearing?**
```dart
// Check if data is actually cached
final data = await manager.getBalance();
print('Is cached: ${data?.isCached}'); // Should be true when offline
```
