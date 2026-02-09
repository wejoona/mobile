# Offline-First Module

Comprehensive offline functionality for the JoonaPay mobile app.

## Features

### 1. Offline Banner
Visual indicator showing connectivity status at the top of screens.

**States:**
- **Offline**: Shows "You're offline" with last sync time
- **Syncing**: Shows progress when processing pending operations
- **Reconnected**: Shows success message for 3 seconds after reconnecting

**Components:**
- `OfflineBanner`: Full banner for main screens
- `OfflineIndicator`: Compact indicator for toolbars
- `OfflineBadge`: Small badge for list items

### 2. Retry Service
Automatic retry logic with multiple strategies for failed operations.

**Strategies:**
- **Exponential**: 1s, 2s, 4s, 8s, 16s (default)
- **Linear**: 1s, 2s, 3s, 4s, 5s
- **Fixed**: Same delay between retries
- **Immediate**: No delay

**Configurations:**
- `RetryConfig.api`: Standard API calls (3 attempts, exponential)
- `RetryConfig.critical`: Important operations (5 attempts, exponential)
- `RetryConfig.background`: Background sync (3 attempts, fixed)
- `RetryConfig.immediate`: Quick operations (2 attempts, no delay)

### 3. Auto Retry Queue
Manages a queue of operations that retry automatically when connection is restored.

## Usage

### Adding Offline Banner to Screens

```dart
import 'package:usdc_wallet/core/offline/index.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(), // Add at top
          Expanded(
            child: YourContent(),
          ),
        ],
      ),
    );
  }
}
```

### Using Retry Service

#### Method 1: Execute with Result
```dart
final retryService = ref.read(retryServiceProvider);

final result = await retryService.execute<WalletBalance>(
  operation: () => sdk.wallet.getBalance(),
  config: RetryConfig.api,
);

if (result.success) {
  final balance = result.data!;
  print('Balance: $balance (after ${result.attempts} attempts)');
} else {
  print('Failed: ${result.error}');
}
```

#### Method 2: Execute or Throw
```dart
try {
  final balance = await retryService.executeOrThrow(
    operation: () => sdk.wallet.getBalance(),
    config: RetryConfig.critical,
  );
  // Use balance
} catch (e) {
  // Handle error
}
```

#### Method 3: Extension Method (Easiest)
```dart
try {
  final balance = await sdk.wallet.getBalance().withRetry(
    ref,
    config: RetryConfig.api,
  );
  // Use balance
} catch (e) {
  // Handle error
}
```

### Custom Retry Configuration

```dart
final customConfig = RetryConfig(
  maxAttempts: 5,
  strategy: RetryStrategy.exponential,
  initialDelaySeconds: 2,
  maxDelaySeconds: 60,
  requiresOnline: true,
);

final data = await operation().withRetry(ref, config: customConfig);
```

### Using Auto Retry Queue

```dart
final queue = ref.read(autoRetryQueueProvider);

// Add operation to queue
queue.enqueue(
  id: 'send_transfer_${transferId}',
  operation: () => sdk.transfers.send(request),
  config: RetryConfig.critical,
  onSuccess: () {
    print('Transfer successful!');
    showSuccessMessage();
  },
  onFailure: (error) {
    print('Transfer failed: $error');
    showErrorMessage(error);
  },
);

// Check pending count
final pending = queue.pendingCount;

// Manually trigger processing
await queue.processNow();

// Remove specific operation
queue.remove('send_transfer_${transferId}');

// Clear all operations
queue.clear();
```

### Offline Indicators

#### Compact Indicator (for AppBar)
```dart
AppBar(
  title: Text('Wallet'),
  actions: [
    const OfflineIndicator(), // Shows "Offline" badge when offline
    IconButton(...),
  ],
)
```

#### Badge for List Items
```dart
ListTile(
  title: Row(
    children: [
      Text('Pending Transfer'),
      const SizedBox(width: 8),
      const OfflineBadge(), // Shows "Queued" badge
    ],
  ),
)
```

### Checking Connectivity Status

```dart
// Watch connectivity state
final state = ref.watch(connectivityProvider);

if (state.isOnline) {
  // Show online content
} else {
  // Show offline content or cached data
}

// Simple boolean check
final isOnline = ref.watch(isOnlineProvider);

// Check pending operations
final pendingCount = ref.watch(pendingCountProvider);
```

### Integration with Existing Services

The retry service works seamlessly with existing connectivity and offline services:

```dart
class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => WalletState.initial();

  Future<void> loadBalance() async {
    state = state.copyWith(isLoading: true);

    try {
      final retryService = ref.read(retryServiceProvider);

      // Automatically retries on failure
      final balance = await retryService.executeOrThrow(
        operation: () => ref.read(sdkProvider).wallet.getBalance(),
        config: RetryConfig.api,
      );

      state = state.copyWith(
        balance: balance,
        isLoading: false,
      );
    } catch (e) {
      // Try loading from cache if offline
      final offlineManager = await ref.read(offlineModeManagerFutureProvider.future);
      final cached = await offlineManager.getBalance();

      if (cached != null) {
        state = state.copyWith(
          balance: cached.data,
          isLoading: false,
          isCached: cached.isCached,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: e.toString(),
        );
      }
    }
  }
}
```

## Best Practices

### 1. Add Banner to All Main Screens
Place `OfflineBanner` at the top of:
- Home/Wallet screen
- Transactions screen
- Send/Receive flows
- Settings screen

### 2. Use Appropriate Retry Configs
- **User-initiated actions**: `RetryConfig.api` (3 attempts)
- **Critical transfers**: `RetryConfig.critical` (5 attempts)
- **Background sync**: `RetryConfig.background` (fixed intervals)
- **Quick checks**: `RetryConfig.immediate` (no delay)

### 3. Handle Both Success and Failure
Always handle both success and error cases when using retry service:

```dart
final result = await retryService.execute(operation: () => apiCall());

if (result.success) {
  // Update UI with fresh data
  updateUI(result.data);
} else {
  // Try loading from cache or show error
  final cached = await loadFromCache();
  if (cached != null) {
    updateUI(cached);
    showCacheWarning();
  } else {
    showError(result.error);
  }
}
```

### 4. Queue Important Operations
For operations that must succeed (transfers, updates), use the auto retry queue:

```dart
queue.enqueue(
  id: 'critical_operation_${id}',
  operation: () => performOperation(),
  config: RetryConfig.critical,
  onSuccess: () => notifyUser('Success!'),
  onFailure: (error) => notifyUser('Failed: $error'),
);
```

### 5. Show Pending Count to User
Display the number of pending operations in UI:

```dart
final pendingCount = ref.watch(pendingCountProvider);

if (pendingCount > 0) {
  Badge(
    label: Text('$pendingCount pending'),
    child: Icon(Icons.sync),
  )
}
```

## Testing

### Simulating Offline Mode
```dart
// In your test or debug settings
ref.read(connectivityProvider.notifier).state = ConnectivityState(
  isOnline: false,
);
```

### Testing Retry Logic
```dart
test('retries operation on failure', () async {
  int attempts = 0;

  final result = await retryService.execute(
    operation: () async {
      attempts++;
      if (attempts < 3) {
        throw Exception('Simulated error');
      }
      return 'Success';
    },
    config: RetryConfig(
      maxAttempts: 3,
      strategy: RetryStrategy.immediate,
    ),
  );

  expect(result.success, true);
  expect(result.attempts, 3);
  expect(result.data, 'Success');
});
```

## Architecture

```
lib/core/offline/
├── offline_banner.dart       # Banner widget and indicators
├── retry_service.dart        # Retry logic and queue
├── index.dart               # Exports
└── README.md                # This file

Integration with:
├── services/connectivity/   # Connectivity monitoring
├── services/offline/        # Offline cache and queue
└── design/tokens/          # Colors, spacing
```

## Performance

- **Banner**: Lightweight, only renders when needed
- **Retry Service**: Non-blocking, uses exponential backoff
- **Queue**: Processes operations sequentially to avoid overwhelming API
- **Cache**: Uses SharedPreferences for fast access

## Accessibility

- Banner announces connectivity changes via semantics
- All states have clear visual and text indicators
- Supports screen readers
- High contrast colors for visibility

## Future Enhancements

- [ ] Push notifications when reconnected with pending operations
- [ ] Retry priority queue (critical operations first)
- [ ] Bandwidth-aware retry (reduce frequency on slow connections)
- [ ] Analytics for retry success rates
- [ ] User-configurable retry settings
