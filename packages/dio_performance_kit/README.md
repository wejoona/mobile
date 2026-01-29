# Dio Performance Kit

Performance optimization interceptors for Dio HTTP client. Includes HTTP response caching with configurable TTL and request deduplication to prevent duplicate simultaneous requests.

## Features

- **HTTP Response Caching** - Cache GET responses with configurable TTL per endpoint
- **Request Deduplication** - Prevent duplicate simultaneous requests to the same endpoint
- **Cache Statistics** - Track hit rates and optimize cache configuration
- **Zero Dependencies** - Only requires Dio and Flutter

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  dio_performance_kit:
    path: packages/dio_performance_kit
```

Or if published:

```yaml
dependencies:
  dio_performance_kit: ^1.0.0
```

## Quick Start

```dart
import 'package:dio/dio.dart';
import 'package:dio_performance_kit/dio_performance_kit.dart';

final dio = Dio();

// Add deduplication first (prevents duplicate in-flight requests)
dio.interceptors.add(DeduplicationInterceptor());

// Add caching second (caches responses)
dio.interceptors.add(CacheInterceptor());

// Configure cache TTLs
CacheConfig.defaultTtl = Duration(seconds: 30);
CacheConfig.setTtl('/users', Duration(minutes: 5));
CacheConfig.setTtl('/config', Duration(hours: 1));
```

## Request Deduplication

When multiple widgets request the same data simultaneously (e.g., on mount), only one network request is made and the response is shared.

### Use Cases

- Multiple widgets loading the same data on mount
- Pull-to-refresh triggered multiple times quickly
- User double-tapping a button
- Parallel API calls to the same endpoint

### Usage

```dart
final dedupeInterceptor = DeduplicationInterceptor(
  enableLogging: true,           // Log in debug mode
  deduplicateMethods: {'GET'},   // Only dedupe GET requests
);

// Add as FIRST interceptor (before cache, auth, etc.)
dio.interceptors.insert(0, dedupeInterceptor);

// Check statistics
print(dedupeInterceptor.stats);
// DeduplicationStats(total: 100, deduplicated: 23, rate: 23.0%)

// Clear in-flight requests (e.g., on logout)
dedupeInterceptor.clear();
```

### How It Works

```
Request A: GET /users/123  →  Network Request  →  Response
Request B: GET /users/123  →  Wait for A      →  Same Response (deduplicated)
Request C: GET /users/123  →  Wait for A      →  Same Response (deduplicated)
```

### Statistics

```dart
final stats = dedupeInterceptor.stats;
print('Total requests: ${stats.total}');
print('Deduplicated: ${stats.deduplicated}');
print('Network requests: ${stats.networkRequests}');
print('Deduplication rate: ${stats.deduplicationRatePercent}');
```

## HTTP Response Caching

Cache successful GET responses with configurable TTL per endpoint.

### Usage

```dart
final cacheInterceptor = CacheInterceptor(
  enableLogging: true,   // Log in debug mode
  cacheGetOnly: true,    // Only cache GET requests
);

dio.interceptors.add(cacheInterceptor);
```

### Configure TTLs

```dart
// Set default TTL for all endpoints
CacheConfig.defaultTtl = Duration(seconds: 30);

// Set specific TTLs per endpoint
CacheConfig.setTtl('/users', Duration(minutes: 5));
CacheConfig.setTtl('/config', Duration(hours: 1));

// Use wildcards for path patterns
CacheConfig.setTtl('/api/*', Duration(minutes: 2));
CacheConfig.setTtl('/static/*', Duration(hours: 24));

// Disable caching for specific endpoints
CacheConfig.disableCache('/auth/token');

// Bulk configuration
CacheConfig.setTtls({
  '/users': Duration(minutes: 5),
  '/transactions': Duration(seconds: 30),
  '/balance': Duration(seconds: 10),
});
```

### TTL Presets

```dart
CacheConfig.setTtl('/volatile', CacheConfig.shortLived);  // 30 seconds
CacheConfig.setTtl('/normal', CacheConfig.medium);        // 5 minutes
CacheConfig.setTtl('/stable', CacheConfig.long);          // 30 minutes
CacheConfig.setTtl('/static', CacheConfig.extended);      // 1 hour
```

### Cache Management

```dart
// Clear all cache
cacheInterceptor.clearCache();

// Clear specific path
cacheInterceptor.clearCacheForPath('/users');
cacheInterceptor.clearCacheForPath('/api/*');

// Clear expired entries
cacheInterceptor.clearExpired();

// Get cached paths (for debugging)
print(cacheInterceptor.cachedPaths);
```

### Statistics

```dart
final stats = cacheInterceptor.stats;
print('Cache hits: ${stats.hits}');
print('Cache misses: ${stats.misses}');
print('Hit rate: ${stats.hitRatePercent}');
print('Entries: ${stats.entries}');
print('Expired: ${stats.expiredEntries}');
```

## Recommended Interceptor Order

Order matters! Add interceptors in this sequence:

```dart
final dio = Dio();

// 1. Deduplication (first - catches duplicate requests before anything else)
dio.interceptors.add(DeduplicationInterceptor());

// 2. Cache (second - returns cached responses before auth check)
dio.interceptors.add(CacheInterceptor());

// 3. Auth (third - adds tokens to requests that reach the network)
dio.interceptors.add(AuthInterceptor());

// 4. Logging (last - logs final request/response)
dio.interceptors.add(LogInterceptor());
```

## Best Practices

### 1. Clear Cache on Mutations

```dart
// After creating/updating/deleting a user
await dio.post('/users', data: newUser);
cacheInterceptor.clearCacheForPath('/users/*');
```

### 2. Clear on Authentication Changes

```dart
void onLogout() {
  dedupeInterceptor.clear();  // Cancel in-flight requests
  cacheInterceptor.clearCache();  // Clear all cached data
}
```

### 3. Monitor Performance

```dart
// Log stats periodically
Timer.periodic(Duration(minutes: 5), (_) {
  final dedupeStats = dedupeInterceptor.stats;
  final cacheStats = cacheInterceptor.stats;

  analytics.logPerformance({
    'deduplication_rate': dedupeStats.deduplicationRate,
    'cache_hit_rate': cacheStats.hitRate,
    'requests_saved': dedupeStats.requestsSaved,
  });
});
```

### 4. Conditional Caching

```dart
// Don't cache in development
if (kReleaseMode) {
  dio.interceptors.add(CacheInterceptor());
}

// Or configure per environment
CacheConfig.defaultTtl = kDebugMode
    ? Duration.zero  // No caching in debug
    : Duration(seconds: 30);
```

## API Reference

### DeduplicationInterceptor

| Property | Type | Description |
|----------|------|-------------|
| `enableLogging` | `bool` | Log activity in debug mode |
| `deduplicateMethods` | `Set<String>` | HTTP methods to deduplicate |
| `inFlightCount` | `int` | Current in-flight requests |
| `inFlightRequests` | `List<String>` | List of in-flight request keys |
| `stats` | `DeduplicationStats` | Statistics object |

| Method | Description |
|--------|-------------|
| `clear()` | Cancel all in-flight requests |
| `resetStats()` | Reset statistics counters |

### CacheInterceptor

| Property | Type | Description |
|----------|------|-------------|
| `enableLogging` | `bool` | Log activity in debug mode |
| `cacheGetOnly` | `bool` | Only cache GET requests |
| `cachedPaths` | `List<String>` | List of cached paths |
| `stats` | `CacheStats` | Statistics object |

| Method | Description |
|--------|-------------|
| `clearCache()` | Clear all cached responses |
| `clearCacheForPath(path)` | Clear cache for specific path |
| `clearExpired()` | Remove expired entries |
| `resetStats()` | Reset statistics counters |

### CacheConfig

| Property | Type | Description |
|----------|------|-------------|
| `defaultTtl` | `Duration` | Default TTL for unconfigured endpoints |
| `shortLived` | `Duration` | 30 seconds preset |
| `medium` | `Duration` | 5 minutes preset |
| `long` | `Duration` | 30 minutes preset |
| `extended` | `Duration` | 1 hour preset |

| Method | Description |
|--------|-------------|
| `setTtl(path, duration)` | Set TTL for endpoint |
| `setTtls(map)` | Bulk set TTLs |
| `getTtl(path)` | Get TTL for path |
| `disableCache(path)` | Disable caching for path |
| `isCacheEnabled(path)` | Check if caching enabled |
| `clearConfig()` | Reset all TTL configuration |

## License

MIT License - see LICENSE file for details.
