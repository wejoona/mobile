/// Configuration for the PIN service.
///
/// ```dart
/// // Customize settings
/// PinConfig.pinLength = 6;
/// PinConfig.maxAttempts = 3;
/// PinConfig.lockoutDuration = Duration(minutes: 30);
/// PinConfig.pbkdf2Iterations = 200000;
/// ```
class PinConfig {
  PinConfig._();

  /// Expected PIN length.
  /// Default: 4 digits
  static int pinLength = 4;

  /// Maximum failed attempts before lockout.
  /// Default: 5 attempts
  static int maxAttempts = 5;

  /// Duration of lockout after max failed attempts.
  /// Default: 15 minutes
  static Duration lockoutDuration = const Duration(minutes: 15);

  /// Number of PBKDF2 iterations for local hashing.
  /// Higher = more secure but slower.
  /// Default: 100,000 iterations
  static int pbkdf2Iterations = 100000;

  /// Number of PBKDF2 iterations for transmission hashing.
  /// Lower than local since backend will re-hash.
  /// Default: 10,000 iterations
  static int pbkdf2TransmissionIterations = 10000;

  /// Salt length in bytes.
  /// Default: 32 bytes (256 bits)
  static int saltLength = 32;

  /// Derived key length in bytes.
  /// Default: 32 bytes (256 bits)
  static int keyLength = 32;

  /// Storage key prefix for namespacing.
  static String storageKeyPrefix = 'pin_service_';

  /// Client-side salt for transmission hashing.
  /// IMPORTANT: Change this for your app!
  static String transmissionSalt = 'change_this_salt_for_your_app_v1';

  /// Whether to reject weak PINs.
  /// Default: true
  static bool rejectWeakPins = true;

  /// Custom weak PIN patterns to reject.
  /// Add app-specific patterns here.
  static List<String> customWeakPins = [];

  /// Reset all settings to defaults.
  static void reset() {
    pinLength = 4;
    maxAttempts = 5;
    lockoutDuration = const Duration(minutes: 15);
    pbkdf2Iterations = 100000;
    pbkdf2TransmissionIterations = 10000;
    saltLength = 32;
    keyLength = 32;
    storageKeyPrefix = 'pin_service_';
    transmissionSalt = 'change_this_salt_for_your_app_v1';
    rejectWeakPins = true;
    customWeakPins = [];
  }
}

/// Storage keys used by the PIN service.
class PinStorageKeys {
  PinStorageKeys._();

  static String get pinHash => '${PinConfig.storageKeyPrefix}hash';
  static String get pinSalt => '${PinConfig.storageKeyPrefix}salt';
  static String get pinAttempts => '${PinConfig.storageKeyPrefix}attempts';
  static String get pinLockedUntil => '${PinConfig.storageKeyPrefix}locked_until';
  static String get pinToken => '${PinConfig.storageKeyPrefix}token';
  static String get pinTokenExpiry => '${PinConfig.storageKeyPrefix}token_expiry';
}
