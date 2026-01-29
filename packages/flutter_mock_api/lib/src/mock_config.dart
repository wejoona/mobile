import 'package:flutter/foundation.dart';

/// Global configuration for the mocking framework.
///
/// Use this to enable/disable mocks and configure simulation settings.
///
/// ```dart
/// // Enable mocks globally
/// MockConfig.useMocks = true;
///
/// // Simulate slow network
/// MockConfig.networkDelayMs = 2000;
///
/// // Simulate random failures for resilience testing
/// MockConfig.simulateRandomFailures = true;
/// MockConfig.failureRate = 0.2; // 20% failure rate
/// ```
class MockConfig {
  MockConfig._();

  /// Master switch - when true, mock interceptor will handle requests.
  /// Defaults to true in debug mode, false in release.
  static bool useMocks = kDebugMode;

  /// Simulated network delay in milliseconds.
  /// Set to 0 for instant responses.
  static int networkDelayMs = 500;

  /// Whether to simulate random network failures.
  /// Useful for testing error handling and retry logic.
  static bool simulateRandomFailures = false;

  /// Failure rate when [simulateRandomFailures] is true.
  /// 0.0 = never fail, 1.0 = always fail.
  static double failureRate = 0.1;

  /// Enable verbose logging of mock responses.
  static bool verboseLogging = kDebugMode;

  /// Reset all configuration to defaults.
  static void reset() {
    useMocks = kDebugMode;
    networkDelayMs = 500;
    simulateRandomFailures = false;
    failureRate = 0.1;
    verboseLogging = kDebugMode;
  }

  /// Disable all mocks (use real API).
  static void disableMocks() {
    useMocks = false;
  }

  /// Enable mocks with default settings.
  static void enableMocks() {
    useMocks = true;
  }

  /// Configure for fast testing (no delays, no failures).
  static void configureForTesting() {
    useMocks = true;
    networkDelayMs = 0;
    simulateRandomFailures = false;
    verboseLogging = false;
  }

  /// Configure for realistic simulation.
  static void configureForRealisticSimulation() {
    useMocks = true;
    networkDelayMs = 800;
    simulateRandomFailures = true;
    failureRate = 0.05;
    verboseLogging = true;
  }
}
