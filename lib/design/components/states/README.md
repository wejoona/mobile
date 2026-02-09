# State Components

Themed loading, empty, and error state components that automatically adapt to light and dark themes.

## Components

### 1. LoadingIndicator

Circular progress indicator with theme-aware colors.

```dart
// Default size (medium)
LoadingIndicator()

// Small size
LoadingIndicator.small()

// Large size
LoadingIndicator.large()

// Custom color
LoadingIndicator(color: AppColors.gold500)
```

### 2. SkeletonLoader

Animated shimmer loading effect that matches content shape.

```dart
// Rectangle
SkeletonLoader.rectangle(
  width: 200,
  height: 100,
  borderRadius: BorderRadius.circular(12),
)

// Circle (avatar)
SkeletonLoader.circle(size: 48)

// Pre-built patterns
SkeletonPattern.text(lines: 3)
SkeletonPattern.transaction()
SkeletonPattern.balanceCard()
SkeletonPattern.transactionList(count: 5)
```

**Theme behavior:**
- Dark mode: Dark gray shimmer (lighter on dark)
- Light mode: Light gray shimmer (darker on light)

### 3. EmptyState

Display when there's no data to show.

```dart
EmptyState(
  icon: Icons.inbox_outlined,
  title: 'No transactions',
  description: 'Your transaction history will appear here',
  action: EmptyStateAction(
    label: 'Send Money',
    onPressed: () => context.push('/send'),
  ),
)

// Pre-built variants
EmptyStateVariant.noTransactions(
  title: 'No Transactions',
  description: 'Send or receive money to get started',
  action: EmptyStateAction(
    label: 'Send Money',
    onPressed: _handleSend,
  ),
)

EmptyStateVariant.noSearchResults(
  title: 'No Results',
  description: 'Try adjusting your search',
  onClear: _handleClear,
)

EmptyStateVariant.noBeneficiaries(...)
EmptyStateVariant.noNotifications(...)
EmptyStateVariant.networkError(...)
```

### 4. ErrorState

Display errors with retry functionality.

```dart
// Basic error
ErrorState(
  title: 'Failed to load transactions',
  message: 'Please check your connection and try again',
  onRetry: () => ref.read(provider.notifier).reload(),
)

// With support option
ErrorState.withSupport(
  title: 'Something went wrong',
  message: error.toString(),
  onRetry: _handleRetry,
  onContactSupport: _handleContactSupport,
)

// Pre-built variants
ErrorState.network(onRetry: _handleRetry)
ErrorState.server(
  onRetry: _handleRetry,
  onContactSupport: _handleSupport,
)

// Inline error (for forms)
InlineError(
  message: 'Failed to save',
  onRetry: _handleSave,
)
```

## Usage Examples

### In a Feature View

```dart
class TransactionsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsProvider);

    return Scaffold(
      body: state.when(
        // Loading state
        loading: () => SkeletonPattern.transactionList(count: 10),

        // Error state
        error: (error, stack) => ErrorState(
          title: 'Failed to load transactions',
          message: error.toString(),
          onRetry: () => ref.refresh(transactionsProvider),
        ),

        // Success state
        data: (transactions) {
          if (transactions.isEmpty) {
            return EmptyStateVariant.noTransactions(
              title: 'No Transactions Yet',
              description: 'Send or receive money to get started',
              action: EmptyStateAction(
                label: 'Send Money',
                onPressed: () => context.push('/send'),
              ),
            );
          }

          return ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) => TransactionTile(
              transaction: transactions[index],
            ),
          );
        },
      ),
    );
  }
}
```

### With Manual State Management

```dart
class WalletView extends StatefulWidget {
  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  bool _isLoading = true;
  String? _error;
  WalletData? _data;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await walletService.getWallet();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SkeletonPattern.balanceCard();
    }

    if (_error != null) {
      return ErrorState(
        title: 'Failed to load wallet',
        message: _error,
        onRetry: _loadData,
      );
    }

    return WalletContent(data: _data!);
  }
}
```

### Loading Overlay

```dart
// Show full-screen loading
if (state.isLoading)
  Container(
    color: Colors.black54,
    child: const Center(
      child: LoadingIndicator.large(),
    ),
  )

// Inline loading
if (_isSaving)
  const Padding(
    padding: EdgeInsets.all(8.0),
    child: LoadingIndicator.small(),
  )
else
  IconButton(
    icon: const Icon(Icons.save),
    onPressed: _handleSave,
  )
```

## Accessibility

All components include proper semantics:

- **LoadingIndicator**: Announces "Loading"
- **EmptyState**: Reads title and description
- **ErrorState**: Announces "Error: [title]" with message
- Buttons have proper labels and hints

## Theme Support

All components automatically adapt to light/dark theme changes:

- **Dark mode**: Light text on dark backgrounds, lighter shimmer
- **Light mode**: Dark text on light backgrounds, darker shimmer
- Colors use `ThemeColors.of(context)` for automatic switching
- No hardcoded colors - all theme-aware

## Migration Guide

If you have existing loading/empty/error states:

```dart
// Before
Center(child: CircularProgressIndicator())

// After
LoadingIndicator()

// Before
Center(
  child: Column(
    children: [
      Icon(Icons.inbox),
      Text('No data'),
    ],
  ),
)

// After
EmptyState(
  icon: Icons.inbox,
  title: 'No data',
)

// Before
Text('Error: $message', style: TextStyle(color: Colors.red))

// After
ErrorState(
  title: 'Error',
  message: message,
  onRetry: _handleRetry,
)
```
