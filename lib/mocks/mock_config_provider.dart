/// Mock Configuration Provider
///
/// Provider-based mock configuration that automatically detects
/// simulator vs physical device and only enables mocks on simulator.
library;

import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock configuration state
class MockConfigState {
  final bool isSimulator;
  final bool useMocks;
  final bool mockCamera;
  final bool mockApi;
  final int networkDelayMs;

  const MockConfigState({
    required this.isSimulator,
    required this.useMocks,
    required this.mockCamera,
    required this.mockApi,
    this.networkDelayMs = 500,
  });

  /// Default state before device detection
  factory MockConfigState.initial() => const MockConfigState(
        isSimulator: false,
        useMocks: false,
        mockCamera: false,
        mockApi: false,
      );

  /// State for simulator
  factory MockConfigState.simulator() => const MockConfigState(
        isSimulator: true,
        useMocks: true,
        mockCamera: true,
        mockApi: true,
      );

  /// State for physical device
  factory MockConfigState.physicalDevice() => const MockConfigState(
        isSimulator: false,
        useMocks: false,
        mockCamera: false,
        mockApi: false,
      );

  MockConfigState copyWith({
    bool? isSimulator,
    bool? useMocks,
    bool? mockCamera,
    bool? mockApi,
    int? networkDelayMs,
  }) {
    return MockConfigState(
      isSimulator: isSimulator ?? this.isSimulator,
      useMocks: useMocks ?? this.useMocks,
      mockCamera: mockCamera ?? this.mockCamera,
      mockApi: mockApi ?? this.mockApi,
      networkDelayMs: networkDelayMs ?? this.networkDelayMs,
    );
  }
}

/// Mock configuration notifier
class MockConfigNotifier extends Notifier<MockConfigState> {
  @override
  MockConfigState build() {
    // Start with initial state, then detect device
    _detectDevice();
    return MockConfigState.initial();
  }

  Future<void> _detectDevice() async {
    final isSimulator = await _isRunningOnSimulator();

    if (isSimulator) {
      debugPrint('[MockConfig] Running on SIMULATOR - mocks enabled');
      state = MockConfigState.simulator();
    } else {
      debugPrint('[MockConfig] Running on PHYSICAL DEVICE - mocks disabled');
      state = MockConfigState.physicalDevice();
    }
  }

  /// Detect if running on iOS Simulator or Android Emulator
  Future<bool> _isRunningOnSimulator() async {
    // In release mode, never use mocks
    if (kReleaseMode) {
      return false;
    }

    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        final isPhysical = iosInfo.isPhysicalDevice;
        debugPrint('[MockConfig] iOS isPhysicalDevice: $isPhysical');
        return !isPhysical;
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        final isPhysical = androidInfo.isPhysicalDevice;
        debugPrint('[MockConfig] Android isPhysicalDevice: $isPhysical');
        return !isPhysical;
      }

      return false;
    } catch (e) {
      debugPrint('[MockConfig] Error detecting device type: $e');
      // On error, assume physical device (safer)
      return false;
    }
  }

  /// Force refresh device detection
  Future<void> refresh() async {
    await _detectDevice();
  }

  /// Manually override mock settings (for debugging)
  void setMockCamera(bool enabled) {
    state = state.copyWith(mockCamera: enabled);
  }

  void setMockApi(bool enabled) {
    state = state.copyWith(mockApi: enabled);
  }

  void setUseMocks(bool enabled) {
    state = state.copyWith(
      useMocks: enabled,
      mockCamera: enabled,
      mockApi: enabled,
    );
  }
}

/// Provider for mock configuration
final mockConfigProvider =
    NotifierProvider<MockConfigNotifier, MockConfigState>(MockConfigNotifier.new);

/// Convenience providers for specific mock settings
final isSimulatorProvider = Provider<bool>((ref) {
  return ref.watch(mockConfigProvider).isSimulator;
});

final mockCameraProvider = Provider<bool>((ref) {
  return ref.watch(mockConfigProvider).mockCamera;
});

final mockApiProvider = Provider<bool>((ref) {
  return ref.watch(mockConfigProvider).mockApi;
});
