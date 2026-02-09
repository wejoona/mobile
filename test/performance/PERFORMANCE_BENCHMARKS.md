# Performance Benchmarks and Regression Tracking

## Overview

This document tracks performance benchmarks for the JoonaPay mobile app to detect regressions over time.

## Benchmark Targets

### App Startup
| Metric | Target | Critical | Current | Status |
|--------|--------|----------|---------|--------|
| Cold start | < 2s | < 3s | TBD | ⏳ |
| First frame | < 500ms | < 1s | TBD | ⏳ |
| Provider init (each) | < 100ms | < 200ms | TBD | ⏳ |
| Splash transition | < 1s | < 2s | TBD | ⏳ |

### Navigation
| Metric | Target | Critical | Current | Status |
|--------|--------|----------|---------|--------|
| Push navigation | < 300ms | < 500ms | TBD | ⏳ |
| Pop navigation | < 200ms | < 400ms | TBD | ⏳ |
| Screen build | < 100ms | < 200ms | TBD | ⏳ |
| Frame rate | 60fps | 30fps | TBD | ⏳ |

### List Scrolling
| Metric | Target | Critical | Current | Status |
|--------|--------|----------|---------|--------|
| 100 items render | < 500ms | < 1s | ~100ms | ✅ |
| Scroll smoothness | 60fps | 30fps | ~60fps | ✅ |
| Fling responsiveness | < 2s | < 3s | ~500ms | ✅ |
| Complex items | < 800ms | < 1.5s | ~300ms | ✅ |

### Memory Management
| Metric | Target | Critical | Current | Status |
|--------|--------|----------|---------|--------|
| Provider lifecycle | No leaks | - | Clean | ✅ |
| Widget disposal | No leaks | - | Clean | ✅ |
| Large lists | No accumulation | - | Clean | ✅ |
| Navigation stack | No leaks | - | Clean | ✅ |

## Test Results History

### 2026-01-30 - Initial Baseline

**List Scroll Performance:**
- ✅ ListView with 100 items: ~100-200ms (Target: < 500ms)
- ✅ Scrolling through 1000 items: ~500-800ms (Target: < 1s)
- ✅ Scroll frame rate: ~16-20ms per frame (60fps)
- ✅ Fling scroll: ~500-1000ms (Target: < 2s)
- ✅ Complex items: ~300-500ms (Target: < 800ms)
- ✅ GridView: ~400-500ms (Target: < 600ms)
- ✅ CustomScrollView: ~1000-1300ms (Target: < 1.5s)
- ✅ ListView.separated: ~300-400ms (Target: < 500ms)

**Memory Usage:**
- ✅ Provider containers: No leaks detected
- ✅ Large lists: No memory accumulation
- ✅ Navigation: No widget leaks
- ✅ Image disposal: Proper cleanup
- ✅ Form controllers: Proper disposal
- ✅ Animation controllers: Proper disposal

**Known Issues:**
- Some tests require fixing compilation errors in main codebase
- App startup tests pending clean build
- Screen transition tests pending clean build

## Performance Regression Checklist

Before each release, verify:

- [ ] All performance tests pass
- [ ] No test exceeds critical thresholds
- [ ] New features haven't degraded existing metrics
- [ ] Memory leak tests pass
- [ ] Frame rate maintained at 60fps for common flows
- [ ] App startup time within limits
- [ ] Large dataset handling is efficient

## Running Performance Tests

### Quick Test
```bash
cd mobile
flutter test test/performance/
```

### Individual Tests
```bash
# List scrolling (fastest, most stable)
flutter test test/performance/list_scroll_performance_test.dart

# App startup
flutter test test/performance/app_startup_performance_test.dart

# Screen transitions
flutter test test/performance/screen_transition_performance_test.dart

# Memory usage
flutter test test/performance/memory_usage_performance_test.dart
```

### With Test Runner
```bash
cd mobile/test/performance
./run_performance_tests.sh
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Performance Tests

on:
  pull_request:
    paths:
      - 'mobile/lib/**'
      - 'mobile/test/performance/**'

jobs:
  performance:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Install dependencies
        run: cd mobile && flutter pub get
      - name: Run performance tests
        run: cd mobile && flutter test test/performance/
      - name: Upload results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: performance-results
          path: mobile/test/performance/*.json
```

## Profiling Tools

For deeper analysis beyond automated tests:

### Flutter DevTools
```bash
flutter run --profile
# Open DevTools URL for:
# - CPU profiler
# - Memory profiler
# - Performance overlay
# - Timeline
```

### Performance Overlay
```dart
// Add to MaterialApp
debugShowPerformanceOverlay: true,
```

### Timeline Trace
```bash
flutter run --profile --trace-startup --trace-systrace
```

## Optimization Tips

### App Startup
- Lazy load providers
- Defer non-critical initialization
- Use const constructors
- Minimize synchronous operations

### Navigation
- Use const widgets where possible
- Avoid rebuilding entire trees
- Cache complex computations
- Use RepaintBoundary for expensive widgets

### List Scrolling
- Use ListView.builder for long lists
- Implement lazy loading/pagination
- Keep item widgets simple
- Use const constructors for list items
- Add RepaintBoundary for complex items

### Memory Management
- Dispose controllers in dispose()
- Cancel streams/subscriptions
- Clear large data structures
- Use WeakReference where appropriate
- Implement object pooling for frequently created objects

## Monitoring in Production

Consider adding:

1. **Firebase Performance Monitoring**
   - Screen rendering times
   - Network request durations
   - Custom traces for critical paths

2. **Analytics Events**
   - App startup time
   - Screen load times
   - Transaction completion times

3. **Crash Reporting**
   - Out of memory errors
   - ANR (Application Not Responding)
   - Performance-related crashes

## Performance Budget

Set performance budgets for critical paths:

| Flow | Budget | Critical |
|------|--------|----------|
| Login → Home | < 3s | < 5s |
| Send Money | < 2s | < 3s |
| Transaction List | < 1s | < 2s |
| QR Scan → Payment | < 2s | < 4s |

## Contact

For performance issues or questions:
- Engineering Team: engineering@joonapay.com
- Performance Lead: [TBD]

---

**Last Updated:** 2026-01-30
**Next Review:** 2026-02-15
