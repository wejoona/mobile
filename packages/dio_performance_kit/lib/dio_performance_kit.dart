/// Dio Performance Kit
///
/// Performance optimization interceptors for Dio HTTP client.
///
/// ## Features
/// - HTTP response caching with configurable TTL per endpoint
/// - Request deduplication (prevents duplicate simultaneous requests)
/// - Cache statistics and management utilities
///
/// ## Quick Start
///
/// ```dart
/// import 'package:dio_performance_kit/dio_performance_kit.dart';
///
/// final dio = Dio();
///
/// // Add deduplication (prevents duplicate requests)
/// dio.interceptors.add(DeduplicationInterceptor());
///
/// // Add caching (caches GET responses)
/// dio.interceptors.add(CacheInterceptor());
/// ```
library dio_performance_kit;

export 'package:dio_performance_kit/src/cache_interceptor.dart';
export 'package:dio_performance_kit/src/deduplication_interceptor.dart';
export 'package:dio_performance_kit/src/cache_config.dart';
