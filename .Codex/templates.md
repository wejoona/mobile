# Mobile Templates

Copy patterns from here before writing new boilerplate.

## API Service Method

```dart
Future<Response> example({required String id}) {
  return _dio.get('/example/$id');
}
```

## Repository Error Handling

```dart
try {
  final response = await _dio.get('/resource');
  return Model.fromJson(response.data as Map<String, dynamic>);
} on DioException catch (e) {
  throw ApiException.fromDioError(e);
}
```

## Riverpod Provider

```dart
final exampleServiceProvider = Provider<ExampleService>((ref) {
  return ExampleService(ref.watch(dioProvider));
});
```

## Existing UI Primitives

```dart
AppCard(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText.titleMedium('Title'),
      AppText.bodyMedium('Supporting value'),
      AppButton.primary(
        onPressed: onPressed,
        child: const Text('Continue'),
      ),
    ],
  ),
)
```

## Auth Local Smoke

```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter run --dart-define=API_URL=http://127.0.0.1:3401/api/v1
```

Then use:

- Phone: `+2250748805663` or a fresh neighboring test number.
- OTP: `123456`.
