# Code Snippets - Micro Patterns

> Tiny patterns that don't need generation. Just copy.

## Imports

### Standard Screen Imports
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
```

### Service Imports
```dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
```

## Widget Patterns

### Scaffold with AppBar
```dart
Scaffold(
  backgroundColor: AppColors.obsidian,
  appBar: AppBar(
    title: AppText(l10n.title, style: AppTypography.headlineSmall),
    backgroundColor: Colors.transparent,
  ),
  body: SafeArea(child: content),
)
```

### Loading State
```dart
if (state.isLoading) {
  return const Center(child: CircularProgressIndicator());
}
```

### Error State
```dart
if (state.error != null) {
  return Center(child: AppText(state.error!, color: AppColors.error));
}
```

### Empty State
```dart
if (items.isEmpty) {
  return Center(child: AppText(l10n.noItems));
}
```

### Spacing
```dart
SizedBox(height: AppSpacing.sm)   // 8
SizedBox(height: AppSpacing.md)   // 16
SizedBox(height: AppSpacing.lg)   // 24
SizedBox(height: AppSpacing.xl)   // 32
```

### Padding
```dart
Padding(padding: EdgeInsets.all(AppSpacing.md), child: content)
Padding(padding: EdgeInsets.symmetric(horizontal: AppSpacing.md), child: content)
```

### Card
```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [...],
  ),
)
```

### Button Row
```dart
Row(
  children: [
    Expanded(
      child: AppButton(
        label: l10n.cancel,
        variant: ButtonVariant.outline,
        onPressed: () => context.pop(),
      ),
    ),
    SizedBox(width: AppSpacing.md),
    Expanded(
      child: AppButton(
        label: l10n.confirm,
        onPressed: _handleConfirm,
        isLoading: _isLoading,
      ),
    ),
  ],
)
```

### List Builder
```dart
ListView.separated(
  padding: EdgeInsets.all(AppSpacing.md),
  itemCount: items.length,
  separatorBuilder: (_, __) => SizedBox(height: AppSpacing.sm),
  itemBuilder: (context, index) => _buildItem(items[index]),
)
```

## State Patterns

### Loading + Error + Data
```dart
class MyState {
  final bool isLoading;
  final String? error;
  final List<Item> items;

  const MyState({this.isLoading = false, this.error, this.items = const []});

  MyState copyWith({bool? isLoading, String? error, List<Item>? items}) {
    return MyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      items: items ?? this.items,
    );
  }
}
```

### Async Action in Notifier
```dart
Future<void> loadData() async {
  state = state.copyWith(isLoading: true, error: null);
  try {
    final data = await ref.read(sdkProvider).feature.getData();
    state = state.copyWith(isLoading: false, items: data);
  } catch (e) {
    state = state.copyWith(isLoading: false, error: e.toString());
  }
}
```

### Form Submission
```dart
Future<void> _handleSubmit() async {
  if (!_formKey.currentState!.validate()) return;
  setState(() => _isLoading = true);
  try {
    await ref.read(sdkProvider).feature.submit(_controller.text);
    if (mounted) context.pop();
  } catch (e) {
    if (mounted) AppToast.showError(context, e.toString());
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
```

## Navigation

### Push
```dart
context.push('/path');
context.push('/path/$id');
```

### Go (replace stack)
```dart
context.go('/home');
```

### Pop
```dart
context.pop();
context.pop(result);
```

### Pop with result
```dart
final result = await context.push<bool>('/confirm');
if (result == true) { ... }
```

## Localization

### Get l10n
```dart
final l10n = AppLocalizations.of(context)!;
```

### Use string
```dart
l10n.common_continue
l10n.auth_loginTitle
l10n.error_invalidPhone
```

## Providers

### Read (one-time)
```dart
ref.read(myProvider);
ref.read(myProvider.notifier).doAction();
```

### Watch (reactive)
```dart
final state = ref.watch(myProvider);
```

### Listen (side effects)
```dart
ref.listen(myProvider, (prev, next) {
  if (next.error != null) showError(next.error!);
});
```

## Validation

### Required
```dart
validator: (v) => v?.isEmpty == true ? l10n.error_required : null
```

### Phone
```dart
validator: (v) => !RegExp(r'^\+?\d{10,15}$').hasMatch(v ?? '') ? l10n.error_invalidPhone : null
```

### Email
```dart
validator: (v) => !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v ?? '') ? l10n.error_invalidEmail : null
```

### PIN
```dart
validator: (v) => v?.length != 4 ? l10n.error_pinLength : null
```

## API Calls

### GET
```dart
final response = await _dio.get('/endpoint');
return Model.fromJson(response.data);
```

### POST
```dart
final response = await _dio.post('/endpoint', data: request.toJson());
return Model.fromJson(response.data);
```

### With error handling
```dart
try {
  final response = await _dio.get('/endpoint');
  return Model.fromJson(response.data);
} on DioException catch (e) {
  throw ApiException(e.response?.data['message'] ?? 'Unknown error');
}
```
