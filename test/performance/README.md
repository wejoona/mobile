# Performance Regression Tests

Comprehensive performance testing suite for the JoonaPay mobile app.

## Overview

This directory contains performance regression tests that measure and validate:
- App startup time
- Screen transition performance
- List scroll smoothness
- Memory usage during common flows

## Test Files

### 1. `app_startup_performance_test.dart`
Tests app initialization and cold start performance.

**Metrics Measured:**
- Cold start time (target: < 2 seconds)
- First frame render (target: < 500ms)
- Provider initialization (target: < 100ms each)
- Splash screen transition (target: < 1 second)
- Concurrent provider loading
- Router initialization and caching

**Key Tests:**
- `Cold start should complete within 2 seconds`
- `First frame render should complete within 500ms`
- `Provider initialization should be lazy and fast`
- `Splash screen should transition within 1 second`

### 2. `screen_transition_performance_test.dart`
Tests navigation and screen rendering performance.

**Metrics Measured:**
- Navigation push time (target: < 300ms)
- Screen build time (target: < 100ms)
- Animation frame rate (target: 60fps = ~16ms/frame)
- Back navigation (target: < 200ms)
- Deep navigation stack handling

**Key Tests:**
- `Navigation push should complete within 300ms`
- `Screen build time should be under 100ms`
- `Multiple rapid navigations should not lag`
- `Animation frame rate should be consistent`
- `Deep navigation stack should not degrade performance`

### 3. `list_scroll_performance_test.dart`
Tests list rendering and scrolling performance.

**Metrics Measured:**
- ListView rendering (100 items: < 500ms, 1000 items tested)
- Scroll smoothness (target: 60fps)
- Fling scroll responsiveness (target: < 2 seconds)
- Complex list items rendering
- GridView performance
- CustomScrollView with multiple slivers

**Key Tests:**
- `ListView with 100 items should render quickly`
- `Scrolling through 1000 items should be smooth`
- `Scroll frame rate should maintain 60fps`
- `Fling scroll should be responsive`
- `ListView with complex items should not drop frames`
- `Transaction history list should scroll smoothly` (real-world simulation)

### 4. `memory_usage_performance_test.dart`
Tests memory management and leak prevention.

**Areas Tested:**
- Provider container lifecycle
- Widget disposal and cleanup
- Large list memory management
- Navigation memory leaks
- Image loading and caching
- Form controller cleanup
- Animation controller disposal

**Key Tests:**
- `Provider container should not leak memory`
- `Large list should not accumulate memory`
- `Navigating back and forth should not leak widgets`
- `Rapid provider state updates should not leak`
- `Image widgets should release memory when disposed`
- `Form controllers should not leak memory`
- `Login flow should not leak memory` (user flow simulation)

## Running the Tests

### Run All Performance Tests
```bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
flutter test test/performance/
```

### Run Individual Test Files
```bash
# App startup tests
flutter test test/performance/app_startup_performance_test.dart

# Screen transition tests
flutter test test/performance/screen_transition_performance_test.dart

# List scroll tests
flutter test test/performance/list_scroll_performance_test.dart

# Memory usage tests
flutter test test/performance/memory_usage_performance_test.dart
```

### Run with Verbose Output
```bash
flutter test test/performance/ --verbose
```

### Run with Coverage
```bash
flutter test test/performance/ --coverage
```

## Performance Benchmarks

### Target Metrics

| Metric | Target | Critical Threshold |
|--------|--------|-------------------|
| Cold start | < 2s | < 3s |
| First frame | < 500ms | < 1s |
| Screen transition | < 300ms | < 500ms |
| Screen build | < 100ms | < 200ms |
| Scroll frame rate | 60fps (16.67ms) | 30fps (33.33ms) |
| List render (100 items) | < 500ms | < 1s |
| Navigation back | < 200ms | < 400ms |

### Interpreting Results

**Success:** All assertions pass within target thresholds
**Warning:** Tests pass but approaching critical thresholds
**Failure:** Performance degradation detected, investigation required

## Continuous Integration

### CI/CD Integration

Add to your CI pipeline to catch performance regressions:

```yaml
# .github/workflows/performance.yml
name: Performance Tests

on: [pull_request]

jobs:
  performance:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test test/performance/ --reporter json > performance-results.json
      - uses: actions/upload-artifact@v2
        with:
          name: performance-results
          path: performance-results.json
```

### Baseline Tracking

Each test file includes a "benchmark - baseline metrics" test that prints performance metrics. Use these for regression tracking:

```dart
// Metrics are printed to console
debugPrint('=== App Startup Performance Metrics ===');
debugPrint('auth_init_ms: 45');
debugPrint('router_init_ms: 120');
debugPrint('total_startup_ms: 450');
```

## Best Practices

### When to Run These Tests

1. **Before每release:** Run full suite to catch regressions
2. **PR reviews:** Run affected tests based on code changes
3. **Performance optimization:** Use as baseline and validation
4. **After dependency updates:** Ensure no performance degradation

### Adding New Performance Tests

When adding new tests:

1. **Set realistic targets** based on device capabilities
2. **Include baseline metrics** for regression tracking
3. **Test edge cases** (empty lists, large datasets, slow networks)
4. **Document assumptions** in test comments
5. **Use descriptive test names** that explain what's being measured

Example:
```dart
test('Feature X should complete within Yms', () async {
  final stopwatch = Stopwatch()..start();

  // Perform operation
  await performOperation();

  stopwatch.stop();

  expect(
    stopwatch.elapsedMilliseconds,
    lessThan(targetMs),
    reason: 'Operation took ${stopwatch.elapsedMilliseconds}ms, expected < ${targetMs}ms',
  );
});
```

### Profiling Tools

For deeper analysis beyond these tests:

```bash
# Flutter DevTools
flutter run --profile
# Then open DevTools for CPU/Memory profiling

# Timeline trace
flutter run --profile --trace-startup
```

## Troubleshooting

### Tests Failing on CI but Passing Locally

- CI environments may be slower; adjust thresholds if needed
- Use `skip: true` for flaky tests and investigate separately
- Consider separate thresholds for CI vs local

### Memory Tests Inconclusive

- Memory tests validate cleanup, not exact memory usage
- Use Flutter DevTools Memory profiler for detailed analysis
- Tests prevent leaks, not measure total memory footprint

### Frame Rate Tests Inconsistent

- Frame timing tests are sensitive to CPU load
- Run on emulator with consistent specs
- Consider averaging multiple runs

## Related Documentation

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Flutter Performance Profiling](https://flutter.dev/docs/perf/ui-performance)
- [Riverpod Performance](https://riverpod.dev/docs/concepts/performance)

## Metrics Dashboard

For tracking performance over time, consider:

1. Export test metrics to JSON
2. Upload to monitoring service (e.g., Firebase Performance, Datadog)
3. Create dashboards showing trends
4. Set up alerts for regressions

---

**Maintained by:** JoonaPay Engineering Team
**Last Updated:** 2026-01-30
