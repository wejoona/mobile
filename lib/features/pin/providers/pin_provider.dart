import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/features/pin/models/pin_state.dart';

/// PIN state provider
final pinStateProvider = NotifierProvider<PinNotifier, PinState>(PinNotifier.new);

class PinNotifier extends Notifier<PinState> {
  Timer? _lockoutTimer;

  @override
  PinState build() {
    // Initialize state by checking if PIN is set
    _initializeState();
    return const PinState();
  }

  Future<void> _initializeState() async {
    final service = ref.read(pinServiceProvider);
    final hasPin = await service.hasPin();

    if (hasPin) {
      state = state.copyWith(
        status: PinStatus.active,
        remainingAttempts: 3,
      );
    } else {
      state = state.copyWith(status: PinStatus.notSet);
    }
  }

  /// Set PIN (initial setup)
  Future<bool> setPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(pinServiceProvider);
      final success = await service.setPin(pin);

      if (success) {
        state = state.copyWith(
          status: PinStatus.active,
          isLoading: false,
          remainingAttempts: 3,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Change PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = ref.read(pinServiceProvider);
      final success = await service.changePin(oldPin, newPin);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          remainingAttempts: 3,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to change PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    final service = ref.read(pinServiceProvider);
    final result = await service.verifyPinLocally(pin);

    if (result.success) {
      state = state.copyWith(remainingAttempts: 5);
      return true;
    } else {
      if (result.isLocked) {
        state = state.copyWith(
          status: PinStatus.locked,
          lockoutSeconds: result.lockRemainingSeconds ?? 0,
        );
        _startLockoutTimer();
      } else {
        state = state.copyWith(
          remainingAttempts: result.remainingAttempts ?? 0,
        );
      }
      return false;
    }
  }

  /// Start lockout countdown timer
  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (state.lockoutSeconds <= 0) {
        timer.cancel();
        state = state.copyWith(
          status: PinStatus.active,
          lockoutSeconds: 0,
          remainingAttempts: 5,
        );
      } else {
        state = state.copyWith(lockoutSeconds: state.lockoutSeconds - 1);
      }
    });
  }

  /// Cancel timer when provider is disposed
  void cancelTimer() {
    _lockoutTimer?.cancel();
  }
}
