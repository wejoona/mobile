/// PIN state model
enum PinStatus {
  /// PIN not set
  notSet,

  /// PIN active and available
  active,

  /// PIN locked due to failed attempts
  locked,
}

/// PIN state
class PinState {
  final PinStatus status;
  final bool isLoading;
  final String? error;
  final int remainingAttempts;
  final int lockoutSeconds;

  const PinState({
    this.status = PinStatus.notSet,
    this.isLoading = false,
    this.error,
    this.remainingAttempts = 5,
    this.lockoutSeconds = 0,
  });

  bool get isLocked => status == PinStatus.locked;
  bool get isPinSet => status != PinStatus.notSet;

  PinState copyWith({
    PinStatus? status,
    bool? isLoading,
    String? error,
    int? remainingAttempts,
    int? lockoutSeconds,
  }) {
    return PinState(
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      remainingAttempts: remainingAttempts ?? this.remainingAttempts,
      lockoutSeconds: lockoutSeconds ?? this.lockoutSeconds,
    );
  }
}
