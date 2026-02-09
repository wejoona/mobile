# Migration Examples

## Example 1: Update a Transaction List View

### Before (Old Pattern)

```dart
class TransactionsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsProvider);

    return Scaffold(
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.gold500,
              ),
            )
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(height: 16),
                      Text('Error: ${state.error}'),
                      ElevatedButton(
                        onPressed: () => ref.refresh(transactionsProvider),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox),
                          Text('No transactions'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(
                          transaction: state.transactions[index],
                        );
                      },
                    ),
    );
  }
}
```

### After (With New State Components)

```dart
import 'package:usdc_wallet/design/components/states/index.dart';

class TransactionsView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transactionsProvider);

    return Scaffold(
      body: state.isLoading
          ? SkeletonPattern.transactionList(count: 10)
          : state.error != null
              ? ErrorState(
                  title: 'Failed to Load Transactions',
                  message: state.error,
                  onRetry: () => ref.refresh(transactionsProvider),
                )
              : state.transactions.isEmpty
                  ? EmptyStateVariant.noTransactions(
                      title: 'No Transactions Yet',
                      description: 'Send or receive money to get started',
                      action: EmptyStateAction(
                        label: 'Send Money',
                        onPressed: () => context.push('/send'),
                      ),
                    )
                  : ListView.builder(
                      itemCount: state.transactions.length,
                      itemBuilder: (context, index) {
                        return TransactionTile(
                          transaction: state.transactions[index],
                        );
                      },
                    ),
    );
  }
}
```

## Example 2: Balance Card with Loading

### Before

```dart
class BalanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    if (wallet.isLoading) {
      return Container(
        height: 150,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.goldGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Balance', style: AppTypography.bodySmall),
          SizedBox(height: 8),
          Text('\$${wallet.balance}', style: AppTypography.displayMedium),
        ],
      ),
    );
  }
}
```

### After

```dart
import 'package:usdc_wallet/design/components/states/index.dart';

class BalanceCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    if (wallet.isLoading) {
      return SkeletonPattern.balanceCard();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: AppColors.goldGradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Balance', style: AppTypography.bodySmall),
          const SizedBox(height: 8),
          Text('\$${wallet.balance}', style: AppTypography.displayMedium),
        ],
      ),
    );
  }
}
```

## Example 3: Form with Inline Error

### Before

```dart
class ProfileForm extends StatefulWidget {
  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  bool _isLoading = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await profileService.update(data);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppInput(label: 'Name', controller: _nameController),
        if (_error != null)
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red.withOpacity(0.1),
            child: Text(_error!, style: TextStyle(color: Colors.red)),
          ),
        AppButton(
          label: 'Save',
          onPressed: _save,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
```

### After

```dart
import 'package:usdc_wallet/design/components/states/index.dart';

class ProfileForm extends StatefulWidget {
  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  bool _isLoading = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await profileService.update(data);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppInput(label: 'Name', controller: _nameController),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          InlineError(
            message: _error!,
            onRetry: _save,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        AppButton(
          label: 'Save',
          onPressed: _save,
          isLoading: _isLoading,
        ),
      ],
    );
  }
}
```

## Example 4: Search Results

### Before

```dart
class SearchResults extends ConsumerWidget {
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchProvider(query));

    return results.when(
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Column(
              children: [
                Icon(Icons.search_off),
                Text('No results for "$query"'),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ItemTile(items[index]),
        );
      },
    );
  }
}
```

### After

```dart
import 'package:usdc_wallet/design/components/states/index.dart';

class SearchResults extends ConsumerWidget {
  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchProvider(query));

    return results.when(
      loading: () => SkeletonPattern.transactionList(count: 5),
      error: (error, stack) => ErrorState(
        title: 'Search Failed',
        message: error.toString(),
        onRetry: () => ref.refresh(searchProvider(query)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return EmptyStateVariant.noSearchResults(
            title: 'No Results Found',
            description: 'Try searching with different keywords',
            onClear: () {
              // Clear search
            },
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ItemTile(items[index]),
        );
      },
    );
  }
}
```

## Example 5: Button Loading State

### Before

```dart
AppButton(
  label: _isLoading ? '' : 'Continue',
  onPressed: _isLoading ? null : _handleContinue,
  child: _isLoading
    ? SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
    : null,
)
```

### After

```dart
// AppButton already handles loading internally!
AppButton(
  label: 'Continue',
  onPressed: _handleContinue,
  isLoading: _isLoading, // Built-in support
)
```

## Quick Reference

| Old Pattern | New Component |
|------------|---------------|
| `CircularProgressIndicator()` | `LoadingIndicator()` |
| Empty container while loading | `SkeletonPattern.*()` |
| Custom empty message | `EmptyState()` |
| Custom error display | `ErrorState()` |
| Form error text | `InlineError()` |

## Benefits

1. **Consistency**: All loading/empty/error states look the same across the app
2. **Theme Support**: Automatically adapts to light/dark theme
3. **Accessibility**: Built-in semantic labels
4. **Less Code**: Pre-built patterns reduce boilerplate
5. **Better UX**: Skeleton loaders show content shape while loading
