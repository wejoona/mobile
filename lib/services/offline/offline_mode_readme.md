# Offline Mode Documentation

## Overview

The offline mode system provides a comprehensive solution for handling network connectivity issues in the JoonaPay mobile app. It includes:

1. **Connectivity Monitoring** - Real-time network status tracking
2. **Data Caching** - Automatic caching of critical data (balance, transactions, beneficiaries)
3. **Offline Queue** - Queue transfers when offline, auto-process when online
4. **UI Components** - Banner, indicators, and badges for offline status
5. **Offline-Capable Features** - View cached data, generate QR codes, queue transfers

## Quick Start

### 1. Add Offline Banner to Your Screen

```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  return Scaffold(
    body: Column(
      children: [
        const OfflineBanner(), // Shows when offline
        Expanded(child: YourContent()),
      ],
    ),
  );
}
```

### 2. Display Cached Data with Indicator

```dart
final offlineManager = ref.watch(offlineModeManagerFutureProvider);

return offlineManager.when(
  data: (manager) => FutureBuilder(
    future: manager.getBalance(),
    builder: (context, snapshot) {
      final data = snapshot.data;
      if (data?.isCached == true) {
        return Column(
          children: [
            OfflineIndicator(),
            BalanceCard(balance: data!.data),
          ],
        );
      }
      return BalanceCard(balance: data?.data ?? 0);
    },
  ),
);
```

### 3. Queue Transfers When Offline

```dart
final isOnline = ref.read(isOnlineProvider);
final manager = await ref.read(offlineModeManagerFutureProvider.future);

if (!isOnline) {
  await manager.queueTransfer(
    recipientPhone: '+225 XX XX XX XX',
    amount: 10000,
  );
  // Show success message
} else {
  // Send immediately via API
}
```

## UI Components

| Component | Usage | Description |
|-----------|-------|-------------|
| `OfflineBanner` | Top of screen | Full-width banner, dismissible |
| `OfflineIndicator` | Near cached data | "Showing cached data" badge |
| `SyncingIndicator` | During sync | "Syncing..." with spinner |
| `LastSyncIndicator` | Status bar | "Last synced: 5m ago" |
| `OfflineStatusBadge` | Navigation | Shows pending count |

## Files Created

```
lib/
├── services/
│   ├── connectivity/
│   │   └── connectivity_provider.dart          # Connectivity monitoring
│   └── offline/
│       ├── offline_cache_service.dart          # Already existed
│       ├── pending_transfer_queue.dart         # Already existed
│       └── offline_mode_manager.dart           # NEW: Unified API
├── design/components/composed/
│   └── offline_banner.dart                     # NEW: UI components
└── features/wallet/views/
    └── pending_transfers_view.dart             # NEW: Queue management
```

## Offline-Capable Features

| Feature | Offline | Notes |
|---------|---------|-------|
| View Balance | ✅ | Cached with timestamp |
| View Transactions | ✅ | Last 50 transactions |
| View Beneficiaries | ✅ | Full list |
| Generate QR Code | ✅ | Uses cached wallet ID |
| Queue Transfers | ✅ | Processed when online |
| Send Now | ❌ | Requires internet |

## API Reference

### ConnectivityProvider

```dart
// Watch connectivity state
final state = ref.watch(connectivityProvider);
print('Online: ${state.isOnline}');
print('Pending: ${state.pendingCount}');

// Convenience providers
final isOnline = ref.watch(isOnlineProvider);
final pendingCount = ref.watch(pendingCountProvider);

// Manual processing
await ref.read(connectivityProvider.notifier).processQueueManually();
```

### OfflineModeManager

```dart
final manager = await ref.read(offlineModeManagerFutureProvider.future);

// Get cached data
final balance = await manager.getBalance();
final txns = await manager.getTransactions();
final beneficiaries = await manager.getBeneficiaries();

// Update cache
await manager.updateBalance(1000.0);
await manager.updateTransactions([...]);

// Queue operations
final id = await manager.queueTransfer(...);
await manager.retryTransfer(id);
await manager.cancelTransfer(id);
final pending = manager.getPendingTransfers();

// Feature checks
if (manager.isFeatureAvailableOffline(OfflineFeature.viewBalance)) {
  // Show balance
}

// Cache management
final status = manager.getCacheStatus();
await manager.clearAllCache();
```

## Integration Example

See `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/features/wallet/views/pending_transfers_view.dart` for a complete example of:
- Offline banner integration
- Status indicators
- Pending transfer list
- Retry/cancel actions
- Error handling

## Required Packages

Already added to `pubspec.yaml`:
- `connectivity_plus: ^6.0.5` - Network monitoring
- `timeago: ^3.7.0` - Relative time formatting
- `uuid: ^4.5.1` - Transfer ID generation

Run: `flutter pub get`

## L10n Strings

All offline-related strings already exist in:
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_en.arb`
- `/Users/macbook/JoonaPay/USDC-Wallet/mobile/lib/l10n/app_fr.arb`

Keys:
- `offline_youreOffline`
- `offline_youreOfflineWithPending`
- `offline_syncing`
- `offline_cacheData`
- `offline_lastSynced`
- etc.

## Testing

1. **Enable offline mode**: Toggle airplane mode or disable network
2. **View cached data**: Navigate to wallet screen
3. **Queue transfer**: Try sending money while offline
4. **Go online**: Disable airplane mode
5. **Verify sync**: Check pending transfers are processed

## Next Steps

1. Integrate `OfflineBanner` in main app scaffold
2. Update wallet screens to use `OfflineModeManager`
3. Add route for `/pending-transfers` in `app_router.dart`
4. Update transfer flows to queue when offline
5. Cache data after every successful API call

## Performance Notes

- Cache stored in SharedPreferences (~5MB limit)
- Transactions limited to 50 items
- Queue processing is sequential
- Auto-syncs when connectivity restored
