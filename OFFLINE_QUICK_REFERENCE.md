# Offline Mode - Quick Reference Card

## Check Online Status

```dart
// Simple boolean check
final isOnline = ref.watch(isOnlineProvider);

// Full state
final offlineState = ref.watch(offlineProvider);
final isOnline = offlineState.isOnline;
final isSyncing = offlineState.isSyncing;
final pendingCount = offlineState.pendingTransferCount;
```

## Show Offline Banner

```dart
// In your screen widget tree
Column(
  children: [
    const OfflineStatusBanner(), // Shows offline or syncing
    Expanded(child: YourContent()),
  ],
)
```

## Queue Transfer When Offline

```dart
// Check if offline before processing
final offlineState = ref.watch(offlineProvider);

if (!offlineState.isOnline) {
  // Queue the transfer
  await OfflineQueueDialog.show(
    context,
    ref,
    recipientName: 'Amadou Diallo',
    recipientPhone: '+225XXXXXXXX',
    amount: 5000.0,
    description: 'Rent payment',
  );
  return;
}

// Normal online flow
await processTransfer();
```

## Access Cached Data

```dart
// Get cache service
final cacheService = await ref.read(
  offlineCacheServiceFutureProvider.future
);

// Get cached balance
final balance = cacheService.getCachedBalance();
if (balance != null) {
  // Show cached balance
}

// Get cached transactions
final transactions = cacheService.getCachedTransactions();

// Get cached beneficiaries
final beneficiaries = cacheService.getCachedBeneficiaries();
```

## Cache Fresh Data

```dart
// After fetching wallet data
final offlineNotifier = ref.read(offlineProvider.notifier);
await offlineNotifier.cacheWalletData(
  balance: walletData.balance,
  walletId: walletData.id,
);

// After fetching transactions
final cacheService = await ref.read(
  offlineCacheServiceFutureProvider.future
);
await cacheService.cacheTransactions(transactions);

// After fetching beneficiaries
await cacheService.cacheBeneficiaries(beneficiaries);
```

## Manual Sync

```dart
// Trigger manual sync
await ref.read(offlineProvider.notifier).manualSync();
```

## View Pending Transfers

```dart
// Navigate to pending screen
context.push('/offline/pending-transfers');

// Get pending transfers programmatically
final transfers = ref.read(offlineProvider.notifier).getPendingTransfers();
```

## Retry Failed Transfer

```dart
await ref.read(offlineProvider.notifier).retryFailedTransfer(transferId);
```

## Cancel Pending Transfer

```dart
await ref.read(offlineProvider.notifier).cancelPendingTransfer(transferId);
```

## Listen to Connectivity Changes

```dart
ref.listen(connectivityStatusProvider, (previous, next) {
  next.when(
    data: (status) {
      if (status == ConnectivityStatus.offline) {
        // Handle going offline
      } else {
        // Handle coming online
      }
    },
    loading: () {},
    error: (_, __) {},
  );
});
```

## Show Last Sync Time

```dart
final offlineState = ref.watch(offlineProvider);
final lastSync = offlineState.lastSync;

if (lastSync != null) {
  final timeAgo = DateTime.now().difference(lastSync);
  // Show "Last synced: X minutes ago"
}
```

## Display Pending Badge

```dart
final pendingCount = ref.watch(offlineProvider).pendingTransferCount;

if (pendingCount > 0) {
  Badge(
    label: Text('$pendingCount'),
    child: Icon(Icons.cloud_queue),
  )
}
```

## Conditional UI Based on Status

```dart
final offlineState = ref.watch(offlineProvider);

if (offlineState.isSyncing) {
  return CircularProgressIndicator();
}

if (!offlineState.isOnline) {
  return OfflineWarningWidget();
}

return NormalContent();
```

## Clear Cache on Logout

```dart
await ref.read(offlineProvider.notifier).clearCache();
```

## Get Transfer Status

```dart
final transfers = ref.read(offlineProvider.notifier).getPendingTransfers();

for (final transfer in transfers) {
  switch (transfer.status) {
    case TransferStatus.pending:
      // Show pending UI
      break;
    case TransferStatus.processing:
      // Show processing UI
      break;
    case TransferStatus.completed:
      // Show success UI
      break;
    case TransferStatus.failed:
      // Show error UI with transfer.errorMessage
      break;
  }
}
```

## Localizations

```dart
final l10n = AppLocalizations.of(context)!;

// English/French strings available:
l10n.offline_youreOffline              // "You're offline" / "Vous êtes hors ligne"
l10n.offline_syncing                   // "Syncing..." / "Synchronisation..."
l10n.offline_transferQueued            // "Transfer queued"
l10n.offline_transferQueuedDesc        // Description
l10n.offline_viewPending               // "View Pending"
l10n.offline_retryFailed               // "Retry Failed"
l10n.offline_cancelTransfer            // "Cancel Transfer"
l10n.offline_noConnection              // "No internet connection"
```

## Common Patterns

### Show Cached Data with Indicator
```dart
final isOnline = ref.watch(isOnlineProvider);
final balance = isOnline
  ? walletState.balance
  : cacheService.getCachedBalance() ?? 0.0;

Column(
  children: [
    Text('\$${balance.toStringAsFixed(2)}'),
    if (!isOnline)
      Text('Cached', style: TextStyle(fontSize: 12, color: Colors.grey)),
  ],
)
```

### Disable Actions When Offline
```dart
final isOnline = ref.watch(isOnlineProvider);

ElevatedButton(
  onPressed: isOnline ? _handleAction : null,
  child: Text('Send Money'),
)
```

### Show Different Messages
```dart
final offlineState = ref.watch(offlineProvider);

String getMessage() {
  if (offlineState.isSyncing) return 'Syncing your data...';
  if (!offlineState.isOnline) return 'You are offline';
  return 'All synced';
}
```

## Imports Needed

```dart
// Providers
import 'package:usdc_wallet/services/connectivity/connectivity_service.dart';
import 'package:usdc_wallet/features/offline/providers/offline_provider.dart';
import 'package:usdc_wallet/services/offline/offline_cache_service.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

// UI Components
import 'package:usdc_wallet/design/components/primitives/offline_banner.dart';
import 'package:usdc_wallet/features/offline/views/pending_transfers_screen.dart';
import 'package:usdc_wallet/features/send/views/offline_queue_dialog.dart';

// Localization
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
```

## Testing

```dart
// Mock offline mode in tests
testWidgets('should queue transfer when offline', (tester) async {
  // Setup
  final container = ProviderContainer();

  // Mock offline
  // ... set connectivity to offline

  // Test queuing
  final notifier = container.read(offlineProvider.notifier);
  await notifier.queueTransfer(
    recipientPhone: '+225XXXXXXXX',
    amount: 100.0,
  );

  // Verify
  final state = container.read(offlineProvider);
  expect(state.pendingTransferCount, 1);
});
```

## Routes

Add to `router/app_router.dart`:

```dart
GoRoute(
  path: '/offline/pending-transfers',
  pageBuilder: (context, state) => AppPageTransitions.fade(
    context, state, const PendingTransfersScreen(),
  ),
),
```

## Key Files

| File | Purpose |
|------|---------|
| `services/connectivity/connectivity_service.dart` | Network monitoring |
| `services/offline/offline_cache_service.dart` | Data caching |
| `services/offline/pending_transfer_queue.dart` | Queue management |
| `features/offline/providers/offline_provider.dart` | State orchestration |
| `design/components/primitives/offline_banner.dart` | Status banners |
| `features/offline/views/pending_transfers_screen.dart` | Queue screen |
| `features/send/views/offline_queue_dialog.dart` | Queue dialog |

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/offline/providers/offline_provider.dart';
import 'package:usdc_wallet/design/components/primitives/offline_banner.dart';

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineProvider);

    return Scaffold(
      body: Column(
        children: [
          // Offline banner
          const OfflineStatusBanner(),

          // Content
          Expanded(
            child: _buildContent(offlineState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: offlineState.isOnline
          ? () => _handleAction(ref)
          : null,
        child: Icon(Icons.send),
      ),
    );
  }

  Widget _buildContent(OfflineState state) {
    if (state.isSyncing) {
      return Center(child: CircularProgressIndicator());
    }

    if (!state.isOnline) {
      return _buildOfflineContent(state);
    }

    return _buildOnlineContent();
  }

  Widget _buildOfflineContent(OfflineState state) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_off, size: 64),
        SizedBox(height: 16),
        Text('You are offline'),
        if (state.pendingTransferCount > 0)
          Text('${state.pendingTransferCount} pending transfers'),
      ],
    );
  }

  Widget _buildOnlineContent() {
    return Center(child: Text('Online content'));
  }

  Future<void> _handleAction(WidgetRef ref) async {
    // Your action logic
  }
}
```
