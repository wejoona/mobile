/// Mock Configuration
///
/// Global configuration for the mocking framework.
/// Toggle between mock and real API at app level or per-service.
library;

import 'package:flutter/foundation.dart';

/// Mock mode configuration
class MockConfig {
  /// Master switch - when true, all mocks are enabled
  static bool useMocks = kDebugMode;

  /// Per-service mock toggles (only apply when useMocks is true)
  static bool mockAuth = true;
  static bool mockWallet = true;
  static bool mockTransactions = true;
  static bool mockKyc = true;
  static bool mockTransfers = true;
  static bool mockNotifications = true;
  static bool mockMerchant = true;
  static bool mockBillPayments = true;
  static bool mockRates = true;

  /// Simulated network delay (ms)
  static int networkDelayMs = 500;

  /// Simulate random failures (for testing error handling)
  static bool simulateRandomFailures = false;
  static double failureRate = 0.1; // 10% failure rate

  /// Check if a specific service should use mocks
  static bool shouldMock(String service) {
    if (!useMocks) return false;

    switch (service) {
      case 'auth':
        return mockAuth;
      case 'wallet':
        return mockWallet;
      case 'transactions':
        return mockTransactions;
      case 'kyc':
        return mockKyc;
      case 'transfers':
        return mockTransfers;
      case 'notifications':
        return mockNotifications;
      case 'merchant':
        return mockMerchant;
      case 'bill_payments':
        return mockBillPayments;
      case 'rates':
        return mockRates;
      default:
        return false;
    }
  }

  /// Enable all mocks
  static void enableAllMocks() {
    useMocks = true;
    mockAuth = true;
    mockWallet = true;
    mockTransactions = true;
    mockKyc = true;
    mockTransfers = true;
    mockNotifications = true;
    mockMerchant = true;
    mockBillPayments = true;
    mockRates = true;
  }

  /// Disable all mocks (use real API)
  static void disableAllMocks() {
    useMocks = false;
  }

  /// Reset to defaults
  static void reset() {
    useMocks = kDebugMode;
    mockAuth = true;
    mockWallet = true;
    mockTransactions = true;
    mockKyc = true;
    mockTransfers = true;
    mockNotifications = true;
    mockMerchant = true;
    mockBillPayments = true;
    mockRates = true;
    networkDelayMs = 500;
    simulateRandomFailures = false;
    failureRate = 0.1;
  }
}
