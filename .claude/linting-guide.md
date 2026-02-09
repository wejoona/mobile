# JoonaPay Mobile - Linting Guide

## Overview

The project uses strict Flutter linting rules to maintain code quality. All rules are configured in `/Users/macbook/JoonaPay/USDC-Wallet/mobile/analysis_options.yaml`.

## Key Enforced Rules

### Error-Level Rules

These will **block** your code:

| Rule | What It Does | Fix |
|------|-------------|-----|
| `avoid_print` | No `print()` statements | Use `debugPrint()` or logging service |
| `avoid_dynamic_calls` | No calls on `dynamic` types | Add proper type annotations |
| `always_use_package_imports` | Use `package:` imports in lib/ | Change to `package:joonapay/...` |
| `use_build_context_synchronously` | Catch async context usage | Check `mounted` before using context |

### Critical Style Rules

| Rule | Example Good | Example Bad |
|------|-------------|-------------|
| `prefer_const_constructors` | `const Text('Hi')` | `Text('Hi')` |
| `prefer_final_fields` | `final String name;` | `String name;` |
| `prefer_single_quotes` | `'hello'` | `"hello"` |
| `require_trailing_commas` | `Text('Hi',)` | `Text('Hi')` |
| `prefer_expression_function_bodies` | `int get x => 5;` | `int get x { return 5; }` |

## Riverpod Best Practices

While custom lint rules aren't available, follow these patterns:

### 1. Use NotifierProvider (not deprecated StateNotifierProvider)

```dart
// Good
final myProvider = NotifierProvider<MyNotifier, MyState>(MyNotifier.new);

class MyNotifier extends Notifier<MyState> {
  @override
  MyState build() => MyState.initial();
}

// Bad
final myProvider = StateNotifierProvider<MyNotifier, MyState>(...);
```

### 2. ref.watch() in build(), ref.read() in callbacks

```dart
// Good
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(myProvider);  // Reactive

  return AppButton(
    onPressed: () => ref.read(myProvider.notifier).doAction(),  // One-time
  );
}

// Bad
@override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.read(myProvider);  // Won't rebuild!
}
```

### 3. Use ConsumerWidget or ConsumerStatefulWidget

```dart
// Good
class MyView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) { ... }
}

// Bad
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) { ... }  // Can't access ref
}
```

### 4. Always use state = newState (never mutate)

```dart
// Good
state = state.copyWith(isLoading: true);

// Bad
state.isLoading = true;  // Won't notify listeners!
```

### 5. Dispose controllers in Notifier.dispose()

```dart
class MyNotifier extends Notifier<MyState> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

### 6. Use autoDispose for temporary state

```dart
// Good for screen-level state
final screenProvider = NotifierProvider.autoDispose<...>(...);

// Good for app-level state
final userProvider = NotifierProvider<...>(...);
```

## Running the Analyzer

```bash
# Analyze entire project
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile && flutter analyze

# Analyze specific file
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile && flutter analyze lib/features/auth/views/login_view.dart

# Fix auto-fixable issues
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile && dart fix --apply
```

## Common Fixes

### Fix: avoid_print

```dart
// Before
print('User logged in: $userId');

// After
debugPrint('User logged in: $userId');

// Or use logging service
final logger = ref.read(loggerProvider);
logger.info('User logged in', extra: {'userId': userId});
```

### Fix: always_use_package_imports

```dart
// Before (in lib/)
import '../../../design/tokens/colors.dart';

// After
import 'package:joonapay/design/tokens/colors.dart';
```

### Fix: use_build_context_synchronously

```dart
// Before
Future<void> submit() async {
  await api.login();
  context.go('/home');  // Error: context used after async gap
}

// After
Future<void> submit() async {
  await api.login();
  if (!mounted) return;
  context.go('/home');
}

// Or in ConsumerWidget
Future<void> submit(BuildContext context) async {
  await api.login();
  if (context.mounted) {
    context.go('/home');
  }
}
```

### Fix: prefer_const_constructors

```dart
// Before
return Padding(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
);

// After
return Padding(
  padding: const EdgeInsets.all(16),
  child: const Text('Hello'),
);
```

### Fix: require_trailing_commas

```dart
// Before
AppButton(
  label: 'Submit',
  onPressed: handleSubmit
)

// After
AppButton(
  label: 'Submit',
  onPressed: handleSubmit,
)
```

## Suppressing Rules

Only suppress rules when absolutely necessary:

```dart
// For a single line
// ignore: avoid_print
print('Debug info');

// For entire file
// ignore_for_file: avoid_print

// For specific analyzer rules
// ignore_for_file: prefer_const_constructors, prefer_final_fields
```

## Excluded Files

These are automatically excluded from analysis:

- `**/*.g.dart` - Generated code
- `**/*.freezed.dart` - Freezed models
- `**/*.mocks.dart` - Mock classes
- `**/generated/**` - All generated files
- `**/l10n/**` - Localization files
- `build/**` - Build output

## IDE Integration

### VS Code

Add to `.vscode/settings.json`:

```json
{
  "dart.lineLength": 120,
  "editor.rulers": [120],
  "dart.analysisExcludedFolders": [
    "build",
    ".dart_tool"
  ],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll": true
  }
}
```

### Android Studio / IntelliJ

1. Preferences → Editor → Code Style → Dart
2. Set line length to 120
3. Enable "Organize imports on save"
4. Enable "Format code on save"

## Performance Rules

| Rule | Why |
|------|-----|
| `prefer_const_constructors` | Const widgets are cached, reducing rebuilds |
| `prefer_const_literals_to_create_immutables` | Reduces memory allocation |
| `avoid_unnecessary_containers` | Removes widget tree bloat |
| `sized_box_for_whitespace` | SizedBox is more efficient than Container |
| `use_colored_box` | ColoredBox is lighter than Container |

## Security Rules

| Rule | Why |
|------|-----|
| `avoid_print` | Prevents leaking sensitive data to logs |
| `unsafe_html` | Prevents XSS vulnerabilities |
| `avoid_web_libraries_in_flutter` | Platform-specific code should be conditional |

## Quick Reference

```bash
# Check analysis
flutter analyze

# Auto-fix issues
dart fix --apply

# Format code
dart format .

# Run tests with analysis
flutter test

# Full cleanup
flutter clean && flutter pub get && flutter analyze
```

## Further Reading

- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [Flutter Lints Package](https://pub.dev/packages/flutter_lints)
- [Riverpod Best Practices](https://riverpod.dev/docs/concepts/providers)
