# Offline Mode Implementation

## Overview

The offline mode feature enables the JoonaPay mobile app to function gracefully without internet connectivity, critical for West African markets with spotty connectivity.

## Architecture

### Core Components

1. **Connectivity Service** (`connectivity_service.dart`)
   - Monitors network state using `connectivity_plus`
   - Emits real-time connectivity status
   - Triggers sync when connection restored

2. **Offline Cache Service** (`offline_cache_service.dart`)
   - Caches last 50 transactions
   - Caches wallet balance
   - Caches beneficiaries list
   - Uses SharedPreferences for storage

3. **Pending Transfer Queue** (`pending_transfer_queue.dart`)
   - Queues P2P transfers when offline
   - Stores: recipient, amount, description, timestamp
   - Processes queue when connection restored
   - Tracks transfer status (pending, processing, completed, failed)

4. **Offline Provider** (`../features/offline/providers/offline_provider.dart`)
   - Orchestrates all offline functionality
   - Manages sync operations
   - Handles queue processing
   - Provides reactive state

### UI Components

5. **Offline Banner** (`../../design/components/primitives/offline_banner.dart`)
   - Shows "You're offline" message when disconnected
   - Displays pending transfer count
   - Shows syncing indicator during sync

6. **Pending Transfers Screen** (`../features/offline/views/pending_transfers_screen.dart`)
   - Lists all queued transfers
   - Shows transfer status
   - Allows retry/cancel actions

## Usage

### Setup

1. Add dependency to `pubspec.yaml`:
```yaml
dependencies:
  connectivity_plus: ^6.0.5
```

2. Initialize services in your app:
```dart
// Services are automatically initialized via Riverpod providers
final offlineState = ref.watch(offlineProvider);
```

### Displaying Offline Status

Add the banner to your main screen:
```dart
Column(
  children: [
    const OfflineStatusBanner(),
    Expanded(child: YourContent()),
  ],
)
```

### Queueing Transfers When Offline

```dart
final offlineNotifier = ref.read(offlineProvider.notifier);

if (!offlineState.isOnline) {
  // Queue transfer
  final transferId = await offlineNotifier.queueTransfer(
    recipientPhone: '+225XXXXXXXX',
    recipientName: 'Amadou Diallo',
    amount: 5000.0,
    description: 'Rent payment',
  );

  // Show confirmation
  showDialog(...);
} else {
  // Process normally
  await normalTransferFlow();
}
```

### Accessing Cached Data

```dart
final cacheService = await ref.read(offlineCacheServiceFutureProvider.future);

// Get cached balance
final balance = cacheService.getCachedBalance();

// Get cached transactions
final transactions = cacheService.getCachedTransactions();

// Get cached beneficiaries
final beneficiaries = cacheService.getCachedBeneficiaries();
```

### Manual Sync

```dart
await ref.read(offlineProvider.notifier).manualSync();
```

## Data Flow

### Going Offline
1. Connectivity service detects network loss
2. Offline provider updates state (`isOnline = false`)
3. UI shows offline banner
4. Transfer attempts are queued instead of processed

### Coming Back Online
1. Connectivity service detects network restoration
2. Offline provider updates state (`isOnline = true`)
3. Auto-sync triggered:
   - Process pending transfers
   - Refresh wallet data
   - Cache fresh data
4. UI hides offline banner

### Sync Process
1. Mark transfers as "processing"
2. Execute each transfer via SDK
3. Mark as "completed" or "failed"
4. Refresh wallet and transaction data
5. Cache the fresh data
6. Clean up old completed transfers (7+ days)

## Storage

All offline data is stored in SharedPreferences:

| Key | Description |
|-----|-------------|
| `offline_cache_balance` | Cached wallet balance (double) |
| `offline_cache_transactions` | Last 50 transactions (JSON array) |
| `offline_cache_beneficiaries` | Beneficiaries list (JSON array) |
| `offline_cache_wallet_id` | Wallet ID (string) |
| `offline_cache_last_sync` | Last sync timestamp (ISO8601) |
| `pending_transfer_queue` | Queued transfers (JSON array) |

## Limitations

- Maximum 50 transactions cached
- Pending transfers stored indefinitely until processed
- No support for complex operations (e.g., external transfers) when offline
- Cache doesn't expire (manually cleared on logout)

## Error Handling

Failed transfers remain in queue with error message. User can:
- Retry when back online
- Cancel the transfer
- View error details

## Testing

```dart
// Mock offline mode
ref.read(connectivityServiceProvider).updateStatus(
  ConnectivityStatus.offline
);

// Queue a transfer
await offlineNotifier.queueTransfer(...);

// Verify queue
final queue = offlineNotifier.getPendingTransfers();
expect(queue.length, 1);

// Mock back online
ref.read(connectivityServiceProvider).updateStatus(
  ConnectivityStatus.online
);

// Verify auto-sync triggered
expect(offlineState.isSyncing, true);
```

## Performance Considerations

- Transactions cached in memory after first load
- Queue checked on every connectivity change
- Sync is debounced (no rapid re-syncing)
- Cache size limited to prevent bloat

## Security

- All data encrypted by SharedPreferences default encryption (iOS)
- No sensitive data (PINs, passwords) cached
- Queue cleared on logout
- Transfer amounts not validated offline (validated on sync)

## Localization

All offline messages support French and English:
- `offline_youreOffline`
- `offline_youreOfflineWithPending`
- `offline_syncing`
- `offline_transferQueued`
- etc.

## Future Enhancements

- [ ] Offline deposit caching
- [ ] Periodic background sync
- [ ] Smart cache expiration
- [ ] Offline transaction search
- [ ] Network quality indicator
- [ ] Data usage optimization
