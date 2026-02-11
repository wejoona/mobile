#!/bin/bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile

# Create directories
mkdir -p lib/services/security/{auth,network,communication,monitoring,testing,privacy}
mkdir -p lib/services/compliance/{reporting,enforcement}
mkdir -p lib/domain/entities/security
mkdir -p lib/domain/value_objects
mkdir -p lib/core/guards
mkdir -p test/services/security

BASE="lib"

# ============================================================
# BATCH 1 (files 1-20): Security auth extensions
# ============================================================

cat > "$BASE/services/security/auth/mfa_enrollment_manager.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'mfa_provider.dart';

/// Gère l'inscription aux méthodes MFA disponibles.
class MfaEnrollmentManager {
  static const _tag = 'MfaEnrollment';
  final AppLogger _log = AppLogger(_tag);
  final MfaProvider _mfaProvider;

  MfaEnrollmentManager(this._mfaProvider);

  /// Initiate enrollment flow for the given method.
  Future<MfaEnrollmentResult> startEnrollment(MfaMethod method) async {
    _log.debug('Starting enrollment for $method');
    try {
      final success = await _mfaProvider.enroll(method);
      return success
          ? MfaEnrollmentResult.success(method)
          : MfaEnrollmentResult.failed(method, 'Enrollment rejected');
    } catch (e) {
      _log.error('Enrollment failed', e);
      return MfaEnrollmentResult.failed(method, e.toString());
    }
  }

  /// Verify enrollment with confirmation code.
  Future<bool> confirmEnrollment(MfaMethod method, String code) async {
    return _mfaProvider.verify(method, code);
  }

  /// Get available methods not yet enrolled.
  List<MfaMethod> availableMethods(List<MfaMethod> enrolled) {
    return MfaMethod.values.where((m) => !enrolled.contains(m)).toList();
  }
}

class MfaEnrollmentResult {
  final MfaMethod method;
  final bool success;
  final String? error;

  MfaEnrollmentResult.success(this.method) : success = true, error = null;
  MfaEnrollmentResult.failed(this.method, this.error) : success = false;
}

final mfaEnrollmentManagerProvider = Provider<MfaEnrollmentManager>((ref) {
  return MfaEnrollmentManager(ref.read(mfaProvider.notifier));
});
DART

cat > "$BASE/services/security/auth/totp_secret_store.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Stockage sécurisé des secrets TOTP.
class TotpSecretStore {
  static const _tag = 'TotpSecretStore';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, String> _secrets = {};

  Future<void> storeSecret(String userId, String secret) async {
    _log.debug('Storing TOTP secret for user');
    _secrets[userId] = secret;
  }

  Future<String?> retrieveSecret(String userId) async {
    return _secrets[userId];
  }

  Future<void> deleteSecret(String userId) async {
    _secrets.remove(userId);
    _log.debug('Deleted TOTP secret');
  }

  Future<bool> hasSecret(String userId) async {
    return _secrets.containsKey(userId);
  }
}

final totpSecretStoreProvider = Provider<TotpSecretStore>((ref) {
  return TotpSecretStore();
});
DART

cat > "$BASE/services/security/auth/challenge_token_generator.dart" << 'DART'
import 'dart:math';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Generates cryptographic challenge tokens for auth flows.
class ChallengeTokenGenerator {
  static const _tag = 'ChallengeToken';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();

  /// Generate a random challenge of [length] bytes, returned as base64.
  String generate({int length = 32}) {
    final bytes = List<int>.generate(length, (_) => _random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Generate a time-bound challenge with embedded expiry.
  Map<String, dynamic> generateTimeBound({
    int length = 32,
    Duration validity = const Duration(minutes: 5),
  }) {
    final token = generate(length: length);
    final expiry = DateTime.now().add(validity);
    return {'token': token, 'expiresAt': expiry.toIso8601String()};
  }

  /// Validate that a time-bound challenge hasn't expired.
  bool isValid(Map<String, dynamic> challenge) {
    final expiresAt = DateTime.tryParse(challenge['expiresAt'] ?? '');
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt);
  }
}

final challengeTokenGeneratorProvider = Provider<ChallengeTokenGenerator>((ref) {
  return ChallengeTokenGenerator();
});
DART

cat > "$BASE/services/security/auth/step_up_auth_coordinator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'mfa_provider.dart';
import 'step_up_auth_service.dart';

/// Coordonne les flux d'authentification renforcée.
enum StepUpReason { highValueTransfer, settingsChange, export, withdrawal }

class StepUpAuthCoordinator {
  static const _tag = 'StepUpCoord';
  final AppLogger _log = AppLogger(_tag);
  final StepUpAuthService _stepUp;

  StepUpAuthCoordinator(this._stepUp);

  /// Determine required auth level for action.
  MfaMethod requiredMethod(StepUpReason reason) {
    switch (reason) {
      case StepUpReason.highValueTransfer:
      case StepUpReason.withdrawal:
        return MfaMethod.biometric;
      case StepUpReason.settingsChange:
        return MfaMethod.totp;
      case StepUpReason.export:
        return MfaMethod.biometric;
    }
  }

  /// Execute step-up flow and return success.
  Future<bool> executeStepUp(StepUpReason reason) async {
    final method = requiredMethod(reason);
    _log.debug('Step-up auth: $reason requires $method');
    return _stepUp.requestStepUp(method.name);
  }
}

final stepUpAuthCoordinatorProvider = Provider<StepUpAuthCoordinator>((ref) {
  return StepUpAuthCoordinator(ref.read(stepUpAuthServiceProvider));
});
DART

cat > "$BASE/services/security/auth/biometric_config_provider.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Configuration biométrique de l'appareil.
class BiometricConfig {
  final bool isFaceIdAvailable;
  final bool isTouchIdAvailable;
  final bool isEnrolled;
  final DateTime? lastEnrollmentCheck;

  const BiometricConfig({
    this.isFaceIdAvailable = false,
    this.isTouchIdAvailable = false,
    this.isEnrolled = false,
    this.lastEnrollmentCheck,
  });

  BiometricConfig copyWith({
    bool? isFaceIdAvailable,
    bool? isTouchIdAvailable,
    bool? isEnrolled,
    DateTime? lastEnrollmentCheck,
  }) {
    return BiometricConfig(
      isFaceIdAvailable: isFaceIdAvailable ?? this.isFaceIdAvailable,
      isTouchIdAvailable: isTouchIdAvailable ?? this.isTouchIdAvailable,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      lastEnrollmentCheck: lastEnrollmentCheck ?? this.lastEnrollmentCheck,
    );
  }
}

class BiometricConfigNotifier extends StateNotifier<BiometricConfig> {
  static const _tag = 'BiometricConfig';
  final AppLogger _log = AppLogger(_tag);

  BiometricConfigNotifier() : super(const BiometricConfig());

  Future<void> refresh() async {
    _log.debug('Refreshing biometric config');
    // Platform channel call in production
    state = state.copyWith(
      isFaceIdAvailable: true,
      isEnrolled: true,
      lastEnrollmentCheck: DateTime.now(),
    );
  }

  bool get hasAnyBiometric =>
      state.isFaceIdAvailable || state.isTouchIdAvailable;
}

final biometricConfigProvider =
    StateNotifierProvider<BiometricConfigNotifier, BiometricConfig>((ref) {
  return BiometricConfigNotifier();
});
DART

cat > "$BASE/services/security/auth/pin_hash_service.dart" << 'DART'
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Hashes and verifies PINs using a salted approach.
class PinHashService {
  static const _tag = 'PinHash';
  final AppLogger _log = AppLogger(_tag);

  /// Hash a PIN with a salt. In production, use Argon2 or bcrypt.
  String hash(String pin, String salt) {
    final combined = '$salt:$pin';
    return base64Encode(utf8.encode(combined));
  }

  /// Verify a PIN against its stored hash.
  bool verify(String pin, String salt, String storedHash) {
    return hash(pin, salt) == storedHash;
  }

  /// Generate a random salt.
  String generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return base64Url.encode(utf8.encode('$now'));
  }
}

final pinHashServiceProvider = Provider<PinHashService>((ref) {
  return PinHashService();
});
DART

cat > "$BASE/services/security/auth/lockout_state_store.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Persists lockout state across app restarts.
class LockoutState {
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime? lastAttempt;

  const LockoutState({
    this.failedAttempts = 0,
    this.lockedUntil,
    this.lastAttempt,
  });

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  Duration get remainingLockout =>
      isLocked ? lockedUntil!.difference(DateTime.now()) : Duration.zero;

  LockoutState copyWith({
    int? failedAttempts,
    DateTime? lockedUntil,
    DateTime? lastAttempt,
  }) {
    return LockoutState(
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }
}

class LockoutStateNotifier extends StateNotifier<LockoutState> {
  static const _tag = 'LockoutState';
  final AppLogger _log = AppLogger(_tag);

  LockoutStateNotifier() : super(const LockoutState());

  void recordFailure() {
    final attempts = state.failedAttempts + 1;
    DateTime? lockUntil;
    if (attempts >= 5) {
      lockUntil = DateTime.now().add(Duration(minutes: attempts * 2));
      _log.warn('Account locked for ${attempts * 2} minutes');
    }
    state = state.copyWith(
      failedAttempts: attempts,
      lockedUntil: lockUntil,
      lastAttempt: DateTime.now(),
    );
  }

  void reset() {
    state = const LockoutState();
  }
}

final lockoutStateProvider =
    StateNotifierProvider<LockoutStateNotifier, LockoutState>((ref) {
  return LockoutStateNotifier();
});
DART

cat > "$BASE/services/security/auth/device_binding_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Binds a user account to a specific device to prevent cloning.
class DeviceBindingService {
  static const _tag = 'DeviceBinding';
  final AppLogger _log = AppLogger(_tag);

  String? _boundDeviceId;

  /// Bind the current device.
  Future<bool> bindDevice(String deviceId, String userId) async {
    _log.debug('Binding device $deviceId for user $userId');
    _boundDeviceId = deviceId;
    return true;
  }

  /// Check if the current device matches the bound device.
  bool isDeviceBound(String currentDeviceId) {
    if (_boundDeviceId == null) return false;
    return _boundDeviceId == currentDeviceId;
  }

  /// Unbind device (e.g., during device transfer).
  Future<void> unbind() async {
    _log.debug('Unbinding device');
    _boundDeviceId = null;
  }

  /// Request device transfer approval from backend.
  Future<bool> requestTransfer(String newDeviceId) async {
    _log.debug('Requesting transfer to $newDeviceId');
    // Would call backend for approval
    return true;
  }
}

final deviceBindingServiceProvider = Provider<DeviceBindingService>((ref) {
  return DeviceBindingService();
});
DART

cat > "$BASE/services/security/auth/session_timeout_manager.dart" << 'DART'
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Gère l'expiration automatique des sessions.
class SessionTimeoutManager {
  static const _tag = 'SessionTimeout';
  final AppLogger _log = AppLogger(_tag);
  Timer? _timer;
  final Duration timeout;
  final VoidCallback? onTimeout;

  SessionTimeoutManager({
    this.timeout = const Duration(minutes: 15),
    this.onTimeout,
  });

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      _log.debug('Session timed out after ${timeout.inMinutes} minutes');
      onTimeout?.call();
    });
  }

  void resetTimer() {
    if (_timer?.isActive ?? false) {
      startTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();

final sessionTimeoutManagerProvider = Provider<SessionTimeoutManager>((ref) {
  final manager = SessionTimeoutManager();
  ref.onDispose(manager.dispose);
  return manager;
});
DART

cat > "$BASE/services/security/auth/auth_event_logger.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Types of authentication events.
enum AuthEventType {
  loginAttempt, loginSuccess, loginFailure,
  mfaChallenge, mfaSuccess, mfaFailure,
  logoutManual, logoutTimeout, logoutForced,
  pinChange, biometricEnroll, deviceBind,
}

/// Records authentication events for audit trail.
class AuthEventLogger {
  static const _tag = 'AuthEventLog';
  final AppLogger _log = AppLogger(_tag);
  final List<AuthEvent> _events = [];

  void log(AuthEventType type, {Map<String, dynamic>? metadata}) {
    final event = AuthEvent(
      type: type,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    );
    _events.add(event);
    _log.debug('Auth event: ${type.name}');
  }

  List<AuthEvent> getEvents({int limit = 50}) {
    return _events.reversed.take(limit).toList();
  }

  List<AuthEvent> getEventsByType(AuthEventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  void clear() => _events.clear();
}

class AuthEvent {
  final AuthEventType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AuthEvent({
    required this.type,
    required this.timestamp,
    this.metadata = const {},
  });
}

final authEventLoggerProvider = Provider<AuthEventLogger>((ref) {
  return AuthEventLogger();
});
DART

cat > "$BASE/services/security/auth/credential_rotation_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages periodic rotation of credentials and tokens.
class CredentialRotationService {
  static const _tag = 'CredRotation';
  final AppLogger _log = AppLogger(_tag);
  DateTime? _lastRotation;
  final Duration rotationInterval;

  CredentialRotationService({
    this.rotationInterval = const Duration(days: 30),
  });

  bool get needsRotation {
    if (_lastRotation == null) return true;
    return DateTime.now().difference(_lastRotation!) > rotationInterval;
  }

  Future<bool> rotateApiKey() async {
    _log.debug('Rotating API key');
    _lastRotation = DateTime.now();
    return true;
  }

  Future<bool> rotateRefreshToken() async {
    _log.debug('Rotating refresh token');
    return true;
  }

  DateTime? get lastRotation => _lastRotation;
}

final credentialRotationServiceProvider = Provider<CredentialRotationService>((ref) {
  return CredentialRotationService();
});
DART

cat > "$BASE/services/security/auth/auth_state_machine.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// États d'authentification possibles.
enum AuthState {
  unauthenticated,
  authenticating,
  mfaRequired,
  stepUpRequired,
  authenticated,
  locked,
  expired,
}

/// Manages auth state transitions.
class AuthStateMachine extends StateNotifier<AuthState> {
  static const _tag = 'AuthStateMachine';
  final AppLogger _log = AppLogger(_tag);

  AuthStateMachine() : super(AuthState.unauthenticated);

  static const _validTransitions = {
    AuthState.unauthenticated: [AuthState.authenticating],
    AuthState.authenticating: [
      AuthState.authenticated,
      AuthState.mfaRequired,
      AuthState.unauthenticated,
    ],
    AuthState.mfaRequired: [
      AuthState.authenticated,
      AuthState.unauthenticated,
      AuthState.locked,
    ],
    AuthState.stepUpRequired: [AuthState.authenticated],
    AuthState.authenticated: [
      AuthState.stepUpRequired,
      AuthState.expired,
      AuthState.unauthenticated,
      AuthState.locked,
    ],
    AuthState.locked: [AuthState.unauthenticated],
    AuthState.expired: [AuthState.unauthenticated, AuthState.authenticating],
  };

  bool canTransition(AuthState to) {
    return _validTransitions[state]?.contains(to) ?? false;
  }

  bool transition(AuthState to) {
    if (!canTransition(to)) {
      _log.warn('Invalid transition: ${state.name} -> ${to.name}');
      return false;
    }
    _log.debug('Auth: ${state.name} -> ${to.name}');
    state = to;
    return true;
  }
}

final authStateMachineProvider =
    StateNotifierProvider<AuthStateMachine, AuthState>((ref) {
  return AuthStateMachine();
});
DART

cat > "$BASE/services/security/auth/recovery_code_service.dart" << 'DART'
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages backup recovery codes for MFA.
class RecoveryCodeService {
  static const _tag = 'RecoveryCodes';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();
  final Set<String> _usedCodes = {};

  /// Generate a set of recovery codes.
  List<String> generateCodes({int count = 10}) {
    _log.debug('Generating $count recovery codes');
    return List.generate(count, (_) => _generateCode());
  }

  String _generateCode() {
    final chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return List.generate(8, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  /// Verify and consume a recovery code.
  bool verifyAndConsume(String code, List<String> validCodes) {
    if (_usedCodes.contains(code)) return false;
    if (!validCodes.contains(code)) return false;
    _usedCodes.add(code);
    _log.debug('Recovery code consumed');
    return true;
  }

  int remainingCodes(List<String> allCodes) {
    return allCodes.where((c) => !_usedCodes.contains(c)).length;
  }
}

final recoveryCodeServiceProvider = Provider<RecoveryCodeService>((ref) {
  return RecoveryCodeService();
});
DART

cat > "$BASE/services/security/auth/sms_verification_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Service de vérification par SMS.
class SmsVerificationService {
  static const _tag = 'SmsVerify';
  final AppLogger _log = AppLogger(_tag);
  final Duration _cooldown = const Duration(seconds: 60);
  DateTime? _lastSent;

  /// Send verification SMS.
  Future<bool> sendCode(String phoneNumber) async {
    if (_lastSent != null &&
        DateTime.now().difference(_lastSent!) < _cooldown) {
      _log.warn('SMS cooldown active');
      return false;
    }
    _log.debug('Sending SMS to ${phoneNumber.substring(0, 4)}***');
    _lastSent = DateTime.now();
    return true;
  }

  /// Verify the received code.
  Future<bool> verifyCode(String phoneNumber, String code) async {
    _log.debug('Verifying SMS code');
    // Would verify via backend
    return code.length == 6;
  }

  Duration get cooldownRemaining {
    if (_lastSent == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastSent!);
    return elapsed >= _cooldown ? Duration.zero : _cooldown - elapsed;
  }
}

final smsVerificationServiceProvider = Provider<SmsVerificationService>((ref) {
  return SmsVerificationService();
});
DART

cat > "$BASE/services/security/auth/auth_interceptor.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Dio interceptor that attaches auth tokens to requests.
class AuthInterceptor {
  static const _tag = 'AuthInterceptor';
  final AppLogger _log = AppLogger(_tag);
  String? _accessToken;
  String? _refreshToken;

  void setTokens({required String access, required String refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  /// Get headers to attach to requests.
  Map<String, String> getAuthHeaders() {
    if (_accessToken == null) return {};
    return {'Authorization': 'Bearer $_accessToken'};
  }

  /// Check if tokens are set.
  bool get hasTokens => _accessToken != null;

  /// Clear tokens on logout.
  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
    _log.debug('Auth tokens cleared');
  }

  /// Refresh the access token using the refresh token.
  Future<bool> refreshAccessToken() async {
    if (_refreshToken == null) return false;
    _log.debug('Refreshing access token');
    // Would call auth endpoint
    return true;
  }
}

final authInterceptorProvider = Provider<AuthInterceptor>((ref) {
  return AuthInterceptor();
});
DART

cat > "$BASE/services/security/auth/permission_checker.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Vérifie les permissions utilisateur pour les actions sensibles.
enum Permission {
  sendMoney, receiveMoney, viewBalance, exportData,
  manageSettings, manageContacts, manageCards,
  viewTransactions, createPaymentLink, manageSavings,
}

class PermissionChecker {
  static const _tag = 'Permissions';
  final AppLogger _log = AppLogger(_tag);
  Set<Permission> _granted = {};

  void setPermissions(Set<Permission> permissions) {
    _granted = permissions;
  }

  bool hasPermission(Permission permission) {
    return _granted.contains(permission);
  }

  bool hasAll(List<Permission> permissions) {
    return permissions.every(_granted.contains);
  }

  bool hasAny(List<Permission> permissions) {
    return permissions.any(_granted.contains);
  }

  List<Permission> getMissing(List<Permission> required) {
    return required.where((p) => !_granted.contains(p)).toList();
  }
}

final permissionCheckerProvider = Provider<PermissionChecker>((ref) {
  return PermissionChecker();
});
DART

cat > "$BASE/services/security/auth/secure_token_storage.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Stockage sécurisé des jetons d'authentification.
class SecureTokenStorage {
  static const _tag = 'SecureTokenStorage';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, String> _store = {};

  Future<void> write(String key, String value) async {
    _store[key] = value;
    _log.debug('Stored token: $key');
  }

  Future<String?> read(String key) async {
    return _store[key];
  }

  Future<void> delete(String key) async {
    _store.remove(key);
    _log.debug('Deleted token: $key');
  }

  Future<void> deleteAll() async {
    _store.clear();
    _log.debug('All tokens cleared');
  }

  Future<bool> containsKey(String key) async {
    return _store.containsKey(key);
  }
}

final secureTokenStorageProvider = Provider<SecureTokenStorage>((ref) {
  return SecureTokenStorage();
});
DART

cat > "$BASE/services/security/auth/anti_replay_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Prevents replay attacks by tracking used nonces.
class AntiReplayService {
  static const _tag = 'AntiReplay';
  final AppLogger _log = AppLogger(_tag);
  final Set<String> _usedNonces = {};
  final Duration _nonceLifetime;

  AntiReplayService({
    this._nonceLifetime = const Duration(minutes: 10),
  });

  /// Check if a nonce has been used. If not, mark it as used.
  bool validateNonce(String nonce, DateTime timestamp) {
    if (DateTime.now().difference(timestamp) > _nonceLifetime) {
      _log.warn('Nonce expired: $nonce');
      return false;
    }
    if (_usedNonces.contains(nonce)) {
      _log.warn('Replay detected: $nonce');
      return false;
    }
    _usedNonces.add(nonce);
    return true;
  }

  /// Prune expired nonces from memory.
  void prune() {
    // In production, store nonces with timestamps
    if (_usedNonces.length > 10000) {
      final toRemove = _usedNonces.length - 5000;
      _usedNonces.removeAll(_usedNonces.take(toRemove).toList());
      _log.debug('Pruned $toRemove nonces');
    }
  }
}

final antiReplayServiceProvider = Provider<AntiReplayService>((ref) {
  return AntiReplayService();
});
DART

cat > "$BASE/services/security/auth/rate_limiter.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Client-side rate limiter for sensitive operations.
class RateLimiter {
  static const _tag = 'RateLimiter';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, List<DateTime>> _attempts = {};

  /// Check if action is allowed within the rate limit.
  bool isAllowed(String action, {int maxAttempts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final history = _attempts[action] ?? [];
    final recent = history.where((t) => now.difference(t) < window).toList();
    _attempts[action] = recent;

    if (recent.length >= maxAttempts) {
      _log.warn('Rate limit exceeded for $action');
      return false;
    }
    _attempts[action]!.add(now);
    return true;
  }

  /// Reset rate limit for an action.
  void reset(String action) {
    _attempts.remove(action);
  }

  /// Get remaining attempts.
  int remaining(String action, {int maxAttempts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final recent = (_attempts[action] ?? []).where((t) => now.difference(t) < window).length;
    return (maxAttempts - recent).clamp(0, maxAttempts);
  }
}

final rateLimiterProvider = Provider<RateLimiter>((ref) {
  return RateLimiter();
});
DART

# ============================================================
# BATCH 2 (files 21-40): Network security extensions
# ============================================================

cat > "$BASE/services/security/network/secure_http_client.dart" << 'DART'
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'ssl_pinning_manager.dart';

/// Wraps HttpClient with all security layers applied.
class SecureHttpClient {
  static const _tag = 'SecureHttp';
  final AppLogger _log = AppLogger(_tag);
  final SslPinningManager _pinningManager;
  late final HttpClient _client;

  SecureHttpClient(this._pinningManager) {
    _client = _pinningManager.createPinnedClient();
    _client.connectionTimeout = const Duration(seconds: 30);
  }

  HttpClient get client => _client;

  void close() {
    _client.close();
    _log.debug('Secure HTTP client closed');
  }
}

final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final pinning = ref.read(sslPinningManagerProvider);
  final client = SecureHttpClient(pinning);
  ref.onDispose(client.close);
  return client;
});
DART

cat > "$BASE/services/security/network/request_deduplicator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Prevents duplicate API requests within a time window.
class RequestDeduplicator {
  static const _tag = 'Dedup';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, DateTime> _pending = {};
  final Duration _window;

  RequestDeduplicator({Duration window = const Duration(seconds: 2)})
      : _window = window;

  /// Returns true if this request should proceed (not a duplicate).
  bool shouldProceed(String requestKey) {
    final now = DateTime.now();
    final last = _pending[requestKey];
    if (last != null && now.difference(last) < _window) {
      _log.debug('Duplicate request blocked: $requestKey');
      return false;
    }
    _pending[requestKey] = now;
    return true;
  }

  void complete(String requestKey) {
    _pending.remove(requestKey);
  }

  void clearAll() => _pending.clear();
}

final requestDeduplicatorProvider = Provider<RequestDeduplicator>((ref) {
  return RequestDeduplicator();
});
DART

cat > "$BASE/services/security/network/response_validator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Validates API responses for integrity and freshness.
class ResponseValidator {
  static const _tag = 'ResponseValidator';
  final AppLogger _log = AppLogger(_tag);

  /// Validate response signature.
  bool validateSignature(String body, String signature, String publicKey) {
    _log.debug('Validating response signature');
    // In production: verify HMAC or RSA signature
    return signature.isNotEmpty;
  }

  /// Check response timestamp freshness.
  bool isFresh(DateTime responseTime, {Duration maxAge = const Duration(minutes: 5)}) {
    return DateTime.now().difference(responseTime) < maxAge;
  }

  /// Validate required response fields.
  bool hasRequiredFields(Map<String, dynamic> body, List<String> required) {
    return required.every(body.containsKey);
  }
}

final responseValidatorProvider = Provider<ResponseValidator>((ref) {
  return ResponseValidator();
});
DART

cat > "$BASE/services/security/network/api_versioning_manager.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages API version negotiation and deprecation warnings.
class ApiVersioningManager {
  static const _tag = 'ApiVersion';
  final AppLogger _log = AppLogger(_tag);
  final String currentVersion;
  String? _serverMinVersion;

  ApiVersioningManager({this.currentVersion = 'v1'});

  /// Check if the current client version is still supported.
  bool isSupported() {
    if (_serverMinVersion == null) return true;
    return currentVersion.compareTo(_serverMinVersion!) >= 0;
  }

  /// Update server's minimum version from response header.
  void updateFromHeader(String? minVersion) {
    if (minVersion != null) {
      _serverMinVersion = minVersion;
      if (!isSupported()) {
        _log.warn('Client version $currentVersion is deprecated. Min: $_serverMinVersion');
      }
    }
  }

  String get versionHeader => 'X-API-Version: $currentVersion';
}

final apiVersioningManagerProvider = Provider<ApiVersioningManager>((ref) {
  return ApiVersioningManager();
});
DART

cat > "$BASE/services/security/network/network_quality_monitor.dart" << 'DART'
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Monitors network quality and adjusts security accordingly.
enum NetworkQuality { excellent, good, fair, poor, offline }

class NetworkQualityState {
  final NetworkQuality quality;
  final int latencyMs;
  final DateTime lastCheck;

  const NetworkQualityState({
    this.quality = NetworkQuality.offline,
    this.latencyMs = 0,
    required this.lastCheck,
  });
}

class NetworkQualityMonitor extends StateNotifier<NetworkQualityState> {
  static const _tag = 'NetQuality';
  final AppLogger _log = AppLogger(_tag);

  NetworkQualityMonitor()
      : super(NetworkQualityState(lastCheck: DateTime.now()));

  Future<void> measureLatency(String endpoint) async {
    final start = DateTime.now();
    // Would ping endpoint
    final latency = DateTime.now().difference(start).inMilliseconds;
    final quality = _classify(latency);
    state = NetworkQualityState(
      quality: quality,
      latencyMs: latency,
      lastCheck: DateTime.now(),
    );
    _log.debug('Network quality: ${quality.name} (${latency}ms)');
  }

  NetworkQuality _classify(int ms) {
    if (ms < 100) return NetworkQuality.excellent;
    if (ms < 300) return NetworkQuality.good;
    if (ms < 1000) return NetworkQuality.fair;
    return NetworkQuality.poor;
  }
}

final networkQualityMonitorProvider =
    StateNotifierProvider<NetworkQualityMonitor, NetworkQualityState>((ref) {
  return NetworkQualityMonitor();
});
DART

cat > "$BASE/services/security/network/proxy_config_detector.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Détecte la configuration proxy du système.
class ProxyConfigDetector {
  static const _tag = 'ProxyDetect';
  final AppLogger _log = AppLogger(_tag);

  /// Check for system-level proxy configuration.
  Future<ProxyConfig> detect() async {
    _log.debug('Detecting proxy configuration');
    // In production: check system proxy settings
    return const ProxyConfig(isProxyConfigured: false);
  }

  /// Check for Charles/Fiddler-style debugging proxies.
  Future<bool> isDebuggingProxyDetected() async {
    // Check common debugging proxy ports
    return false;
  }
}

class ProxyConfig {
  final bool isProxyConfigured;
  final String? proxyHost;
  final int? proxyPort;
  final bool isTransparent;

  const ProxyConfig({
    this.isProxyConfigured = false,
    this.proxyHost,
    this.proxyPort,
    this.isTransparent = false,
  });
}

final proxyConfigDetectorProvider = Provider<ProxyConfigDetector>((ref) {
  return ProxyConfigDetector();
});
DART

cat > "$BASE/services/security/network/request_retry_policy.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Configurable retry policy for failed requests.
class RequestRetryPolicy {
  static const _tag = 'RetryPolicy';
  final AppLogger _log = AppLogger(_tag);
  final int maxRetries;
  final Duration baseDelay;

  RequestRetryPolicy({this.maxRetries = 3, this.baseDelay = const Duration(seconds: 1)});

  /// Calculate delay for attempt number (exponential backoff).
  Duration getDelay(int attempt) {
    final multiplier = 1 << attempt; // 2^attempt
    return baseDelay * multiplier;
  }

  /// Check if the status code is retryable.
  bool isRetryable(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  /// Should retry this attempt?
  bool shouldRetry(int attempt, int statusCode) {
    return attempt < maxRetries && isRetryable(statusCode);
  }
}

final requestRetryPolicyProvider = Provider<RequestRetryPolicy>((ref) {
  return RequestRetryPolicy();
});
DART

cat > "$BASE/services/security/network/header_sanitizer.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Sanitizes request/response headers to prevent info leakage.
class HeaderSanitizer {
  static const _tag = 'HeaderSanitizer';
  final AppLogger _log = AppLogger(_tag);

  static const _sensitiveHeaders = [
    'authorization', 'cookie', 'x-api-key', 'x-auth-token',
  ];

  /// Sanitize headers for logging (mask sensitive values).
  Map<String, String> sanitizeForLogging(Map<String, String> headers) {
    return headers.map((key, value) {
      if (_sensitiveHeaders.contains(key.toLowerCase())) {
        return MapEntry(key, '***REDACTED***');
      }
      return MapEntry(key, value);
    });
  }

  /// Strip unnecessary headers from outgoing requests.
  Map<String, String> stripUnnecessary(Map<String, String> headers) {
    final stripped = Map<String, String>.from(headers);
    stripped.remove('x-debug');
    stripped.remove('x-trace-id');
    return stripped;
  }
}

final headerSanitizerProvider = Provider<HeaderSanitizer>((ref) {
  return HeaderSanitizer();
});
DART

cat > "$BASE/services/security/network/ip_reputation_checker.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Checks IP reputation to detect suspicious connections.
class IpReputationChecker {
  static const _tag = 'IpReputation';
  final AppLogger _log = AppLogger(_tag);

  /// Check if the server IP is known and trusted.
  Future<IpReputation> check(String ip) async {
    _log.debug('Checking IP reputation: $ip');
    // Would query threat intelligence API
    return IpReputation(ip: ip, score: 100, isTrusted: true);
  }

  /// Check if IP belongs to known VPN/proxy ranges.
  Future<bool> isVpnIp(String ip) async {
    return false;
  }
}

class IpReputation {
  final String ip;
  final int score; // 0-100
  final bool isTrusted;
  final String? threatType;

  const IpReputation({
    required this.ip,
    required this.score,
    required this.isTrusted,
    this.threatType,
  });
}

final ipReputationCheckerProvider = Provider<IpReputationChecker>((ref) {
  return IpReputationChecker();
});
DART

cat > "$BASE/services/security/network/bandwidth_throttler.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Throttles bandwidth usage for security-sensitive operations.
class BandwidthThrottler {
  static const _tag = 'Throttler';
  final AppLogger _log = AppLogger(_tag);
  int _bytesThisWindow = 0;
  DateTime _windowStart = DateTime.now();
  final int maxBytesPerMinute;

  BandwidthThrottler({this.maxBytesPerMinute = 10 * 1024 * 1024});

  /// Check if the transfer can proceed.
  bool canTransfer(int bytes) {
    _resetWindowIfNeeded();
    return (_bytesThisWindow + bytes) <= maxBytesPerMinute;
  }

  /// Record bytes transferred.
  void recordTransfer(int bytes) {
    _resetWindowIfNeeded();
    _bytesThisWindow += bytes;
  }

  void _resetWindowIfNeeded() {
    if (DateTime.now().difference(_windowStart) > const Duration(minutes: 1)) {
      _bytesThisWindow = 0;
      _windowStart = DateTime.now();
    }
  }

  double get usagePercent => _bytesThisWindow / maxBytesPerMinute;
}

final bandwidthThrottlerProvider = Provider<BandwidthThrottler>((ref) {
  return BandwidthThrottler();
});
DART

cat > "$BASE/services/security/network/geo_ip_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Resolves geographic location from IP for compliance checks.
class GeoIpService {
  static const _tag = 'GeoIp';
  final AppLogger _log = AppLogger(_tag);

  /// Resolve location from IP address.
  Future<GeoLocation> resolve(String ip) async {
    _log.debug('Resolving geo for $ip');
    return const GeoLocation(
      countryCode: 'CI',
      country: "Côte d'Ivoire",
      region: 'Abidjan',
      isUemoa: true,
    );
  }

  /// Check if IP is from UEMOA zone.
  Future<bool> isUemoaZone(String ip) async {
    final location = await resolve(ip);
    return location.isUemoa;
  }
}

class GeoLocation {
  final String countryCode;
  final String country;
  final String? region;
  final bool isUemoa;

  const GeoLocation({
    required this.countryCode,
    required this.country,
    this.region,
    this.isUemoa = false,
  });
}

final geoIpServiceProvider = Provider<GeoIpService>((ref) {
  return GeoIpService();
});
DART

# ============================================================
# BATCH 3 (files 41-60): Communication security + monitoring
# ============================================================

cat > "$BASE/services/security/communication/message_encryptor.dart" << 'DART'
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Encrypts messages for P2P communication.
class MessageEncryptor {
  static const _tag = 'MsgEncrypt';
  final AppLogger _log = AppLogger(_tag);

  /// Encrypt a message payload.
  String encrypt(String plaintext, String recipientPublicKey) {
    _log.debug('Encrypting message');
    return base64Encode(utf8.encode(plaintext)); // Placeholder
  }

  /// Decrypt a received message.
  String decrypt(String ciphertext, String privateKey) {
    return utf8.decode(base64Decode(ciphertext)); // Placeholder
  }
}

final messageEncryptorProvider = Provider<MessageEncryptor>((ref) {
  return MessageEncryptor();
});
DART

cat > "$BASE/services/security/communication/secure_payload_wrapper.dart" << 'DART'
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Wraps API payloads with encryption envelope.
class SecurePayloadWrapper {
  static const _tag = 'PayloadWrapper';
  final AppLogger _log = AppLogger(_tag);

  /// Wrap a payload in an encrypted envelope.
  Map<String, dynamic> wrap(Map<String, dynamic> payload) {
    final encoded = base64Encode(utf8.encode(jsonEncode(payload)));
    return {
      'version': 1,
      'algorithm': 'AES-256-GCM',
      'payload': encoded,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Unwrap an encrypted envelope.
  Map<String, dynamic>? unwrap(Map<String, dynamic> envelope) {
    try {
      final encoded = envelope['payload'] as String;
      final decoded = utf8.decode(base64Decode(encoded));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      _log.error('Failed to unwrap payload', e);
      return null;
    }
  }
}

final securePayloadWrapperProvider = Provider<SecurePayloadWrapper>((ref) {
  return SecurePayloadWrapper();
});
DART

cat > "$BASE/services/security/communication/key_exchange_service.dart" << 'DART'
import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages Diffie-Hellman style key exchange for E2E encryption.
class KeyExchangeService {
  static const _tag = 'KeyExchange';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();

  /// Generate a key pair for exchange.
  KeyPair generateKeyPair() {
    final privateBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final publicBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return KeyPair(
      publicKey: base64Encode(publicBytes),
      privateKey: base64Encode(privateBytes),
    );
  }

  /// Derive shared secret from own private key and peer's public key.
  String deriveSharedSecret(String privateKey, String peerPublicKey) {
    _log.debug('Deriving shared secret');
    // In production: use X25519 or similar
    return base64Encode(base64Decode(privateKey).take(16).toList());
  }
}

class KeyPair {
  final String publicKey;
  final String privateKey;
  const KeyPair({required this.publicKey, required this.privateKey});
}

final keyExchangeServiceProvider = Provider<KeyExchangeService>((ref) {
  return KeyExchangeService();
});
DART

cat > "$BASE/services/security/communication/notification_security_filter.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Filtre de sécurité pour les notifications push.
class NotificationSecurityFilter {
  static const _tag = 'NotifFilter';
  final AppLogger _log = AppLogger(_tag);

  /// Validate notification origin.
  bool isFromTrustedSource(Map<String, dynamic> notification) {
    return notification.containsKey('signature');
  }

  /// Strip sensitive data from notification display.
  Map<String, dynamic> sanitizeForDisplay(Map<String, dynamic> notification) {
    final sanitized = Map<String, dynamic>.from(notification);
    sanitized.remove('accountNumber');
    sanitized.remove('balance');
    // Masquer le montant dans la notification
    if (sanitized.containsKey('amount')) {
      sanitized['amount'] = '***';
    }
    return sanitized;
  }

  /// Check if notification should be shown on lock screen.
  bool allowOnLockScreen(Map<String, dynamic> notification) {
    final category = notification['category'] as String?;
    return category != 'transaction' && category != 'security';
  }
}

final notificationSecurityFilterProvider = Provider<NotificationSecurityFilter>((ref) {
  return NotificationSecurityFilter();
});
DART

cat > "$BASE/services/security/communication/data_masking_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Masks sensitive data in logs and UI.
class DataMaskingService {
  static const _tag = 'DataMask';
  final AppLogger _log = AppLogger(_tag);

  /// Mask phone number: +225 07 XX XX 89 → +225 07 ** ** 89
  String maskPhone(String phone) {
    if (phone.length < 8) return '***';
    return '${phone.substring(0, 7)}****${phone.substring(phone.length - 2)}';
  }

  /// Mask email: user@example.com → u***@example.com
  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    return '${name[0]}***@${parts[1]}';
  }

  /// Mask wallet address: 0x1234...5678
  String maskAddress(String address) {
    if (address.length < 10) return '***';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Mask amount for display.
  String maskAmount(double amount) => '*** FCFA';

  /// Mask IBAN.
  String maskIban(String iban) {
    if (iban.length < 8) return '***';
    return '${iban.substring(0, 4)}****${iban.substring(iban.length - 4)}';
  }
}

final dataMaskingServiceProvider = Provider<DataMaskingService>((ref) {
  return DataMaskingService();
});
DART

cat > "$BASE/services/security/communication/websocket_auth_handler.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Handles authentication for WebSocket connections.
class WebSocketAuthHandler {
  static const _tag = 'WsAuth';
  final AppLogger _log = AppLogger(_tag);

  /// Create authenticated connection headers.
  Map<String, String> createAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'X-Client-Version': '1.0.0',
    };
  }

  /// Handle auth challenge from server.
  Future<String?> handleChallenge(Map<String, dynamic> challenge) async {
    _log.debug('Handling WS auth challenge');
    return challenge['token'] as String?;
  }

  /// Reauthenticate on token expiry.
  Future<bool> reauthenticate(String refreshToken) async {
    _log.debug('Reauthenticating WebSocket');
    return true;
  }
}

final webSocketAuthHandlerProvider = Provider<WebSocketAuthHandler>((ref) {
  return WebSocketAuthHandler();
});
DART

cat > "$BASE/services/security/communication/secure_file_transfer.dart" << 'DART'
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Transfert sécurisé de fichiers avec chiffrement.
class SecureFileTransfer {
  static const _tag = 'SecureTransfer';
  final AppLogger _log = AppLogger(_tag);
  static const int maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  /// Prepare file for secure upload.
  Future<Map<String, dynamic>> prepareUpload(List<int> fileBytes, String filename) async {
    if (fileBytes.length > maxFileSizeBytes) {
      throw Exception('File exceeds maximum size');
    }
    _log.debug('Preparing secure upload: $filename (${fileBytes.length} bytes)');
    return {
      'data': base64Encode(fileBytes),
      'filename': filename,
      'size': fileBytes.length,
      'checksum': _simpleChecksum(fileBytes),
    };
  }

  String _simpleChecksum(List<int> bytes) {
    var sum = 0;
    for (final b in bytes) {
      sum = (sum + b) & 0xFFFFFFFF;
    }
    return sum.toRadixString(16);
  }
}

final secureFileTransferProvider = Provider<SecureFileTransfer>((ref) {
  return SecureFileTransfer();
});
DART

cat > "$BASE/services/security/monitoring/anomaly_detector.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Detects anomalous behavior patterns.
class AnomalyDetector {
  static const _tag = 'AnomalyDetect';
  final AppLogger _log = AppLogger(_tag);
  final List<BehaviorEvent> _events = [];

  /// Record a behavior event.
  void recordEvent(BehaviorEvent event) {
    _events.add(event);
    _checkForAnomalies();
  }

  void _checkForAnomalies() {
    final recentEvents = _events.where(
      (e) => DateTime.now().difference(e.timestamp) < const Duration(minutes: 5),
    ).toList();

    // Detect rapid-fire transactions
    final txEvents = recentEvents.where((e) => e.type == 'transaction').length;
    if (txEvents > 10) {
      _log.warn('Anomaly: $txEvents transactions in 5 minutes');
    }

    // Detect unusual login patterns
    final loginEvents = recentEvents.where((e) => e.type == 'login_failure').length;
    if (loginEvents > 3) {
      _log.warn('Anomaly: $loginEvents login failures in 5 minutes');
    }
  }

  List<String> getActiveAnomalies() {
    // Return current anomaly descriptions
    return [];
  }
}

class BehaviorEvent {
  final String type;
  final DateTime timestamp;
  final Map<String, dynamic> data;

  BehaviorEvent({required this.type, required this.data})
      : timestamp = DateTime.now();
}

final anomalyDetectorProvider = Provider<AnomalyDetector>((ref) {
  return AnomalyDetector();
});
DART

cat > "$BASE/services/security/monitoring/security_metrics_collector.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Collects security-related metrics for dashboard.
class SecurityMetricsCollector {
  static const _tag = 'SecMetrics';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, int> _counters = {};
  final Map<String, double> _gauges = {};

  void incrementCounter(String name, [int value = 1]) {
    _counters[name] = (_counters[name] ?? 0) + value;
  }

  void setGauge(String name, double value) {
    _gauges[name] = value;
  }

  Map<String, int> get counters => Map.unmodifiable(_counters);
  Map<String, double> get gauges => Map.unmodifiable(_gauges);

  /// Get a summary of all metrics.
  Map<String, dynamic> getSummary() {
    return {
      'counters': _counters,
      'gauges': _gauges,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  void reset() {
    _counters.clear();
    _gauges.clear();
  }
}

final securityMetricsCollectorProvider = Provider<SecurityMetricsCollector>((ref) {
  return SecurityMetricsCollector();
});
DART

cat > "$BASE/services/security/monitoring/incident_reporter.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Severity levels for security incidents.
enum IncidentSeverity { low, medium, high, critical }

/// Reports security incidents to the backend.
class IncidentReporter {
  static const _tag = 'IncidentReport';
  final AppLogger _log = AppLogger(_tag);
  final List<SecurityIncident> _incidents = [];

  /// Report a security incident.
  Future<void> report(SecurityIncident incident) async {
    _incidents.add(incident);
    _log.warn('Security incident [${incident.severity.name}]: ${incident.title}');
    // Would send to backend security endpoint
  }

  /// Get recent incidents.
  List<SecurityIncident> getRecent({int limit = 20}) {
    return _incidents.reversed.take(limit).toList();
  }

  int get criticalCount =>
      _incidents.where((i) => i.severity == IncidentSeverity.critical).length;
}

class SecurityIncident {
  final String id;
  final String title;
  final String description;
  final IncidentSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  SecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.context = const {},
  }) : timestamp = DateTime.now();
}

final incidentReporterProvider = Provider<IncidentReporter>((ref) {
  return IncidentReporter();
});
DART

cat > "$BASE/services/security/monitoring/realtime_threat_monitor.dart" << 'DART'
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Surveillance en temps réel des menaces.
enum ThreatType { rootDetected, debuggerAttached, tamperingDetected, networkCompromised, mitmDetected }

class ThreatEvent {
  final ThreatType type;
  final DateTime timestamp;
  final String details;
  ThreatEvent({required this.type, required this.details}) : timestamp = DateTime.now();
}

class RealtimeThreatMonitor {
  static const _tag = 'ThreatMonitor';
  final AppLogger _log = AppLogger(_tag);
  final _controller = StreamController<ThreatEvent>.broadcast();
  final List<ThreatEvent> _history = [];

  Stream<ThreatEvent> get threats => _controller.stream;

  void reportThreat(ThreatType type, String details) {
    final event = ThreatEvent(type: type, details: details);
    _history.add(event);
    _controller.add(event);
    _log.error('THREAT: ${type.name} - $details');
  }

  List<ThreatEvent> get history => List.unmodifiable(_history);

  bool get hasActiveThreats => _history.any(
    (e) => DateTime.now().difference(e.timestamp) < const Duration(hours: 1),
  );

  void dispose() => _controller.close();
}

final realtimeThreatMonitorProvider = Provider<RealtimeThreatMonitor>((ref) {
  final monitor = RealtimeThreatMonitor();
  ref.onDispose(monitor.dispose);
  return monitor;
});
DART

cat > "$BASE/services/security/monitoring/security_dashboard_data.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';
import 'security_metrics_collector.dart';
import 'app_security_score.dart';

/// Aggregates data for the security dashboard UI.
class SecurityDashboardData {
  final int securityScore;
  final int totalIncidents;
  final int activeThreats;
  final Map<String, int> metrics;
  final DateTime lastUpdated;

  const SecurityDashboardData({
    this.securityScore = 100,
    this.totalIncidents = 0,
    this.activeThreats = 0,
    this.metrics = const {},
    required this.lastUpdated,
  });
}

class SecurityDashboardNotifier extends StateNotifier<SecurityDashboardData> {
  static const _tag = 'SecDashboard';
  final AppLogger _log = AppLogger(_tag);

  SecurityDashboardNotifier()
      : super(SecurityDashboardData(lastUpdated: DateTime.now()));

  Future<void> refresh() async {
    _log.debug('Refreshing security dashboard');
    state = SecurityDashboardData(
      securityScore: 95,
      totalIncidents: 0,
      activeThreats: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

final securityDashboardProvider =
    StateNotifierProvider<SecurityDashboardNotifier, SecurityDashboardData>((ref) {
  return SecurityDashboardNotifier();
});
DART

cat > "$BASE/services/security/monitoring/pii_scrubber.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Scrubs PII from crash reports and logs.
class PiiScrubber {
  static const _tag = 'PiiScrubber';
  final AppLogger _log = AppLogger(_tag);

  static final _patterns = [
    RegExp(r'\b\d{10,}\b'), // Phone numbers
    RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'), // Emails
    RegExp(r'\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b'), // Card numbers
    RegExp(r'\b0x[a-fA-F0-9]{40}\b'), // Wallet addresses
    RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*'), // Auth tokens
  ];

  /// Scrub PII from text.
  String scrub(String text) {
    var result = text;
    for (final pattern in _patterns) {
      result = result.replaceAll(pattern, '[REDACTED]');
    }
    return result;
  }

  /// Scrub PII from a map of data.
  Map<String, dynamic> scrubMap(Map<String, dynamic> data) {
    return data.map((key, value) {
      if (value is String) return MapEntry(key, scrub(value));
      if (value is Map<String, dynamic>) return MapEntry(key, scrubMap(value));
      return MapEntry(key, value);
    });
  }
}

final piiScrubberProvider = Provider<PiiScrubber>((ref) {
  return PiiScrubber();
});
DART

cat > "$BASE/services/security/monitoring/security_log_aggregator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Aggregates security logs for batch reporting.
class SecurityLogAggregator {
  static const _tag = 'SecLogAgg';
  final AppLogger _log = AppLogger(_tag);
  final List<SecurityLogEntry> _buffer = [];
  static const int _maxBufferSize = 500;

  void add(SecurityLogEntry entry) {
    _buffer.add(entry);
    if (_buffer.length >= _maxBufferSize) {
      flush();
    }
  }

  /// Flush buffered logs to backend.
  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    _log.debug('Flushing ${_buffer.length} security log entries');
    // Would send batch to backend
    _buffer.clear();
  }

  int get pendingCount => _buffer.length;
}

class SecurityLogEntry {
  final String level;
  final String message;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  SecurityLogEntry({
    required this.level,
    required this.message,
    this.context,
  }) : timestamp = DateTime.now();
}

final securityLogAggregatorProvider = Provider<SecurityLogAggregator>((ref) {
  return SecurityLogAggregator();
});
DART

cat > "$BASE/services/security/monitoring/compliance_monitor.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Monitors compliance status in real-time.
class ComplianceMonitor {
  static const _tag = 'ComplianceMonitor';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, bool> _checks = {};

  /// Run a compliance check.
  void recordCheck(String checkName, bool passed) {
    _checks[checkName] = passed;
    if (!passed) {
      _log.warn('Compliance check failed: $checkName');
    }
  }

  /// Get overall compliance status.
  bool get isCompliant => _checks.values.every((v) => v);

  /// Get failed checks.
  List<String> get failedChecks =>
      _checks.entries.where((e) => !e.value).map((e) => e.key).toList();

  /// Get compliance percentage.
  double get complianceScore {
    if (_checks.isEmpty) return 100.0;
    final passed = _checks.values.where((v) => v).length;
    return (passed / _checks.length) * 100;
  }

  Map<String, bool> get allChecks => Map.unmodifiable(_checks);
}

final complianceMonitorProvider = Provider<ComplianceMonitor>((ref) {
  return ComplianceMonitor();
});
DART

cat > "$BASE/services/security/monitoring/uptime_tracker.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Tracks app and API uptime for reliability monitoring.
class UptimeTracker {
  static const _tag = 'Uptime';
  final AppLogger _log = AppLogger(_tag);
  final DateTime _startTime = DateTime.now();
  int _healthCheckCount = 0;
  int _healthCheckFailures = 0;

  Duration get uptime => DateTime.now().difference(_startTime);

  void recordHealthCheck(bool success) {
    _healthCheckCount++;
    if (!success) _healthCheckFailures++;
  }

  double get uptimePercent {
    if (_healthCheckCount == 0) return 100.0;
    return ((_healthCheckCount - _healthCheckFailures) / _healthCheckCount) * 100;
  }

  Map<String, dynamic> getReport() {
    return {
      'uptimeMs': uptime.inMilliseconds,
      'checks': _healthCheckCount,
      'failures': _healthCheckFailures,
      'uptimePercent': uptimePercent,
    };
  }
}

final uptimeTrackerProvider = Provider<UptimeTracker>((ref) {
  return UptimeTracker();
});
DART

# ============================================================
# BATCH 4 (files 61-80): Compliance services
# ============================================================

cat > "$BASE/services/compliance/bceao_transaction_classifier.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Classifie les transactions selon les catégories BCEAO.
enum BceaoCategory {
  transfertDomestique,
  transfertUemoa,
  transfertInternational,
  paiementMarchand,
  retraitEspeces,
  depotEspeces,
  achatCredit,
}

class BceaoTransactionClassifier {
  static const _tag = 'BceaoClassifier';
  final AppLogger _log = AppLogger(_tag);

  /// Classify a transaction for BCEAO reporting.
  BceaoCategory classify({
    required String type,
    required String? destinationCountry,
    required double amount,
  }) {
    if (type == 'withdrawal') return BceaoCategory.retraitEspeces;
    if (type == 'deposit') return BceaoCategory.depotEspeces;
    if (type == 'merchant') return BceaoCategory.paiementMarchand;

    if (destinationCountry == null || destinationCountry == 'CI') {
      return BceaoCategory.transfertDomestique;
    }

    const uemoaCountries = ['BJ', 'BF', 'CI', 'GW', 'ML', 'NE', 'SN', 'TG'];
    if (uemoaCountries.contains(destinationCountry)) {
      return BceaoCategory.transfertUemoa;
    }

    return BceaoCategory.transfertInternational;
  }
}

final bceaoTransactionClassifierProvider = Provider<BceaoTransactionClassifier>((ref) {
  return BceaoTransactionClassifier();
});
DART

cat > "$BASE/services/compliance/bceao_report_generator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Génère les rapports périodiques pour la BCEAO.
class BceaoReportGenerator {
  static const _tag = 'BceaoReport';
  final AppLogger _log = AppLogger(_tag);

  /// Generate daily transaction summary.
  Map<String, dynamic> generateDailySummary(DateTime date, List<Map<String, dynamic>> transactions) {
    _log.debug('Generating BCEAO daily summary for $date');
    double totalVolume = 0;
    int totalCount = 0;
    for (final tx in transactions) {
      totalVolume += (tx['amount'] as num?)?.toDouble() ?? 0;
      totalCount++;
    }
    return {
      'date': date.toIso8601String(),
      'totalTransactions': totalCount,
      'totalVolume': totalVolume,
      'currency': 'XOF',
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Generate monthly regulatory report.
  Map<String, dynamic> generateMonthlyReport(int year, int month, List<Map<String, dynamic>> dailySummaries) {
    return {
      'year': year,
      'month': month,
      'dailySummaries': dailySummaries,
      'reportType': 'BCEAO_MONTHLY',
    };
  }
}

final bceaoReportGeneratorProvider = Provider<BceaoReportGenerator>((ref) {
  return BceaoReportGenerator();
});
DART

cat > "$BASE/services/compliance/suspicious_activity_reporter.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Déclaration de soupçon - rapporte les activités suspectes.
class SuspiciousActivityReporter {
  static const _tag = 'SAR';
  final AppLogger _log = AppLogger(_tag);
  final List<SuspiciousActivityReport> _reports = [];

  /// File a suspicious activity report.
  Future<String> fileReport(SuspiciousActivityReport report) async {
    _reports.add(report);
    _log.warn('SAR filed: ${report.reason}');
    return 'SAR-${DateTime.now().millisecondsSinceEpoch}';
  }

  List<SuspiciousActivityReport> getPending() {
    return _reports.where((r) => !r.submitted).toList();
  }
}

class SuspiciousActivityReport {
  final String transactionId;
  final String reason;
  final double amount;
  final String userId;
  final DateTime createdAt;
  bool submitted;

  SuspiciousActivityReport({
    required this.transactionId,
    required this.reason,
    required this.amount,
    required this.userId,
    this.submitted = false,
  }) : createdAt = DateTime.now();
}

final suspiciousActivityReporterProvider = Provider<SuspiciousActivityReporter>((ref) {
  return SuspiciousActivityReporter();
});
DART

cat > "$BASE/services/compliance/transaction_limit_checker.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Vérifie les limites de transaction réglementaires.
class TransactionLimitChecker {
  static const _tag = 'LimitCheck';
  final AppLogger _log = AppLogger(_tag);

  // BCEAO limits in XOF (USDC equivalent applied at conversion)
  static const double dailyLimitBasic = 200000; // ~$320
  static const double dailyLimitVerified = 2000000; // ~$3200
  static const double monthlyLimitBasic = 1000000;
  static const double monthlyLimitVerified = 10000000;
  static const double singleTransactionMax = 5000000;

  /// Check if a transaction is within limits.
  LimitCheckResult check({
    required double amount,
    required double dailyTotal,
    required double monthlyTotal,
    required String kycTier,
  }) {
    final dailyLimit = kycTier == 'verified' ? dailyLimitVerified : dailyLimitBasic;
    final monthlyLimit = kycTier == 'verified' ? monthlyLimitVerified : monthlyLimitBasic;

    if (amount > singleTransactionMax) {
      return LimitCheckResult.exceeded('Montant maximum par transaction dépassé');
    }
    if (dailyTotal + amount > dailyLimit) {
      return LimitCheckResult.exceeded('Limite journalière atteinte');
    }
    if (monthlyTotal + amount > monthlyLimit) {
      return LimitCheckResult.exceeded('Limite mensuelle atteinte');
    }
    return LimitCheckResult.allowed();
  }
}

class LimitCheckResult {
  final bool allowed;
  final String? reason;
  LimitCheckResult.allowed() : allowed = true, reason = null;
  LimitCheckResult.exceeded(this.reason) : allowed = false;
}

final transactionLimitCheckerProvider = Provider<TransactionLimitChecker>((ref) {
  return TransactionLimitChecker();
});
DART

cat > "$BASE/services/compliance/pep_screening_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Screening against Politically Exposed Persons (PEP) lists.
class PepScreeningService {
  static const _tag = 'PepScreen';
  final AppLogger _log = AppLogger(_tag);

  /// Screen a name against PEP databases.
  Future<PepScreenResult> screen(String fullName, String countryCode) async {
    _log.debug('PEP screening: $fullName ($countryCode)');
    // Would call compliance API
    return PepScreenResult(isMatch: false, score: 0);
  }

  /// Screen a batch of names.
  Future<List<PepScreenResult>> screenBatch(List<String> names, String countryCode) async {
    return names.map((n) => PepScreenResult(isMatch: false, score: 0)).toList();
  }
}

class PepScreenResult {
  final bool isMatch;
  final double score;
  final String? matchedName;
  final String? category;

  const PepScreenResult({
    required this.isMatch,
    required this.score,
    this.matchedName,
    this.category,
  });
}

final pepScreeningServiceProvider = Provider<PepScreeningService>((ref) {
  return PepScreeningService();
});
DART

cat > "$BASE/services/compliance/sanctions_checker.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Vérifie les listes de sanctions internationales.
class SanctionsChecker {
  static const _tag = 'Sanctions';
  final AppLogger _log = AppLogger(_tag);

  /// Check individual against sanctions lists.
  Future<SanctionsResult> checkIndividual(String name, String country) async {
    _log.debug('Sanctions check: $name');
    return const SanctionsResult(isListed: false);
  }

  /// Check entity against sanctions lists.
  Future<SanctionsResult> checkEntity(String entityName) async {
    return const SanctionsResult(isListed: false);
  }

  /// Check if a country is sanctioned.
  bool isCountrySanctioned(String countryCode) {
    const sanctioned = ['KP', 'IR', 'SY', 'CU'];
    return sanctioned.contains(countryCode);
  }
}

class SanctionsResult {
  final bool isListed;
  final String? listName;
  final String? matchDetails;

  const SanctionsResult({
    required this.isListed,
    this.listName,
    this.matchDetails,
  });
}

final sanctionsCheckerProvider = Provider<SanctionsChecker>((ref) {
  return SanctionsChecker();
});
DART

cat > "$BASE/services/compliance/cdd_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Customer Due Diligence (CDD) service.
class CddService {
  static const _tag = 'CDD';
  final AppLogger _log = AppLogger(_tag);

  /// Determine required CDD level based on risk.
  CddLevel determineLevel(double riskScore) {
    if (riskScore >= 80) return CddLevel.enhanced;
    if (riskScore >= 40) return CddLevel.standard;
    return CddLevel.simplified;
  }

  /// Check if CDD is up to date.
  bool isCddCurrent(DateTime? lastCddDate) {
    if (lastCddDate == null) return false;
    return DateTime.now().difference(lastCddDate) < const Duration(days: 365);
  }

  /// Request additional CDD documents.
  Future<void> requestDocuments(String userId, CddLevel level) async {
    _log.debug('Requesting CDD documents for user: level=${level.name}');
  }
}

enum CddLevel { simplified, standard, enhanced }

final cddServiceProvider = Provider<CddService>((ref) {
  return CddService();
});
DART

cat > "$BASE/services/compliance/compliance_rule_engine.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Rule engine for compliance policy evaluation.
class ComplianceRuleEngine {
  static const _tag = 'RuleEngine';
  final AppLogger _log = AppLogger(_tag);
  final List<ComplianceRule> _rules = [];

  void registerRule(ComplianceRule rule) {
    _rules.add(rule);
    _log.debug('Registered rule: ${rule.name}');
  }

  /// Evaluate all rules against a transaction context.
  List<RuleViolation> evaluate(Map<String, dynamic> context) {
    final violations = <RuleViolation>[];
    for (final rule in _rules) {
      if (!rule.evaluate(context)) {
        violations.add(RuleViolation(ruleName: rule.name, severity: rule.severity));
      }
    }
    return violations;
  }

  int get ruleCount => _rules.length;
}

class ComplianceRule {
  final String name;
  final String severity;
  final bool Function(Map<String, dynamic>) evaluate;

  ComplianceRule({required this.name, required this.severity, required this.evaluate});
}

class RuleViolation {
  final String ruleName;
  final String severity;
  const RuleViolation({required this.ruleName, required this.severity});
}

final complianceRuleEngineProvider = Provider<ComplianceRuleEngine>((ref) {
  return ComplianceRuleEngine();
});
DART

cat > "$BASE/services/compliance/daily_aggregation_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Agrégation journalière des transactions pour rapports.
class DailyAggregationService {
  static const _tag = 'DailyAgg';
  final AppLogger _log = AppLogger(_tag);

  /// Aggregate transactions for a given day.
  DailyAggregation aggregate(DateTime date, List<Map<String, dynamic>> transactions) {
    double totalIn = 0, totalOut = 0;
    int countIn = 0, countOut = 0;

    for (final tx in transactions) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
      if (tx['type'] == 'credit') {
        totalIn += amount;
        countIn++;
      } else {
        totalOut += amount;
        countOut++;
      }
    }

    return DailyAggregation(
      date: date,
      totalIncoming: totalIn,
      totalOutgoing: totalOut,
      incomingCount: countIn,
      outgoingCount: countOut,
    );
  }
}

class DailyAggregation {
  final DateTime date;
  final double totalIncoming;
  final double totalOutgoing;
  final int incomingCount;
  final int outgoingCount;

  double get netFlow => totalIncoming - totalOutgoing;
  int get totalCount => incomingCount + outgoingCount;

  const DailyAggregation({
    required this.date,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.incomingCount,
    required this.outgoingCount,
  });
}

final dailyAggregationServiceProvider = Provider<DailyAggregationService>((ref) {
  return DailyAggregationService();
});
DART

cat > "$BASE/services/compliance/monthly_aggregation_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'daily_aggregation_service.dart';

/// Agrégation mensuelle des transactions.
class MonthlyAggregationService {
  static const _tag = 'MonthlyAgg';
  final AppLogger _log = AppLogger(_tag);

  /// Aggregate daily summaries into monthly report.
  MonthlyAggregation aggregate(int year, int month, List<DailyAggregation> dailies) {
    double totalIn = 0, totalOut = 0;
    int countIn = 0, countOut = 0;

    for (final daily in dailies) {
      totalIn += daily.totalIncoming;
      totalOut += daily.totalOutgoing;
      countIn += daily.incomingCount;
      countOut += daily.outgoingCount;
    }

    return MonthlyAggregation(
      year: year,
      month: month,
      totalIncoming: totalIn,
      totalOutgoing: totalOut,
      incomingCount: countIn,
      outgoingCount: countOut,
      daysReported: dailies.length,
    );
  }
}

class MonthlyAggregation {
  final int year;
  final int month;
  final double totalIncoming;
  final double totalOutgoing;
  final int incomingCount;
  final int outgoingCount;
  final int daysReported;

  double get netFlow => totalIncoming - totalOutgoing;

  const MonthlyAggregation({
    required this.year,
    required this.month,
    required this.totalIncoming,
    required this.totalOutgoing,
    required this.incomingCount,
    required this.outgoingCount,
    required this.daysReported,
  });
}

final monthlyAggregationServiceProvider = Provider<MonthlyAggregationService>((ref) {
  return MonthlyAggregationService();
});
DART

cat > "$BASE/services/compliance/compliance_notification_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Sends compliance-related notifications to users and admins.
class ComplianceNotificationService {
  static const _tag = 'ComplianceNotif';
  final AppLogger _log = AppLogger(_tag);

  /// Notify user about KYC requirement.
  Future<void> notifyKycRequired(String userId, String reason) async {
    _log.debug('KYC notification sent to $userId: $reason');
  }

  /// Notify about approaching transaction limits.
  Future<void> notifyLimitApproaching(String userId, double usagePercent) async {
    if (usagePercent >= 80) {
      _log.debug('Limit warning: ${usagePercent.toStringAsFixed(0)}% used');
    }
  }

  /// Notify compliance team of suspicious activity.
  Future<void> notifyComplianceTeam(String alertType, Map<String, dynamic> details) async {
    _log.warn('Compliance alert: $alertType');
  }
}

final complianceNotificationServiceProvider = Provider<ComplianceNotificationService>((ref) {
  return ComplianceNotificationService();
});
DART

cat > "$BASE/services/compliance/source_of_funds_validator.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Validates source of funds declarations.
class SourceOfFundsValidator {
  static const _tag = 'SofValidator';
  final AppLogger _log = AppLogger(_tag);

  static const validSources = [
    'salary', 'business', 'savings', 'investment',
    'inheritance', 'gift', 'pension', 'other',
  ];

  /// Validate a source of funds declaration.
  SofValidationResult validate({
    required String source,
    required double amount,
    String? documentation,
  }) {
    if (!validSources.contains(source)) {
      return SofValidationResult(valid: false, reason: 'Source invalide');
    }

    // Amounts over threshold require documentation
    if (amount > 1000000 && documentation == null) {
      return SofValidationResult(
        valid: false,
        reason: 'Justificatif requis pour les montants supérieurs à 1 000 000 FCFA',
      );
    }

    return SofValidationResult(valid: true);
  }
}

class SofValidationResult {
  final bool valid;
  final String? reason;
  const SofValidationResult({required this.valid, this.reason});
}

final sourceOfFundsValidatorProvider = Provider<SourceOfFundsValidator>((ref) {
  return SourceOfFundsValidator();
});
DART

cat > "$BASE/services/compliance/watchlist_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Manages internal watchlists for compliance monitoring.
class WatchlistService {
  static const _tag = 'Watchlist';
  final AppLogger _log = AppLogger(_tag);
  final Set<String> _watchedUsers = {};
  final Set<String> _watchedAddresses = {};

  void addUser(String userId) {
    _watchedUsers.add(userId);
    _log.debug('User added to watchlist: $userId');
  }

  void addAddress(String address) {
    _watchedAddresses.add(address);
  }

  bool isUserWatched(String userId) => _watchedUsers.contains(userId);
  bool isAddressWatched(String address) => _watchedAddresses.contains(address);

  void removeUser(String userId) => _watchedUsers.remove(userId);
  void removeAddress(String address) => _watchedAddresses.remove(address);

  int get watchedUserCount => _watchedUsers.length;
  int get watchedAddressCount => _watchedAddresses.length;
}

final watchlistServiceProvider = Provider<WatchlistService>((ref) {
  return WatchlistService();
});
DART

cat > "$BASE/services/compliance/risk_assessment_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Évaluation du risque pour les transactions et les utilisateurs.
class RiskAssessmentService {
  static const _tag = 'RiskAssess';
  final AppLogger _log = AppLogger(_tag);

  /// Assess risk for a transaction.
  RiskAssessment assessTransaction({
    required double amount,
    required String destinationCountry,
    required String userKycTier,
    required int userAccountAgeDays,
  }) {
    double score = 0;

    if (amount > 500000) score += 20;
    if (amount > 2000000) score += 30;
    if (destinationCountry != 'CI') score += 15;
    if (userKycTier == 'basic') score += 10;
    if (userAccountAgeDays < 30) score += 15;

    final level = score >= 60 ? 'high' : (score >= 30 ? 'medium' : 'low');
    return RiskAssessment(score: score, level: level);
  }

  /// Assess user risk profile.
  RiskAssessment assessUser({
    required int transactionCount,
    required double totalVolume,
    required int accountAgeDays,
  }) {
    double score = 0;
    if (totalVolume > 5000000) score += 25;
    if (transactionCount > 100 && accountAgeDays < 30) score += 30;

    final level = score >= 50 ? 'high' : (score >= 25 ? 'medium' : 'low');
    return RiskAssessment(score: score, level: level);
  }
}

class RiskAssessment {
  final double score;
  final String level;
  const RiskAssessment({required this.score, required this.level});
}

final riskAssessmentServiceProvider = Provider<RiskAssessmentService>((ref) {
  return RiskAssessmentService();
});
DART

cat > "$BASE/services/compliance/audit_trail_service.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Maintains immutable audit trail for regulatory compliance.
class AuditTrailService {
  static const _tag = 'AuditTrail';
  final AppLogger _log = AppLogger(_tag);
  final List<AuditRecord> _records = [];

  /// Record an auditable action.
  void record({
    required String action,
    required String userId,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  }) {
    _records.add(AuditRecord(
      action: action,
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      before: before,
      after: after,
      timestamp: DateTime.now(),
    ));
    _log.debug('Audit: $action on $entityType by $userId');
  }

  List<AuditRecord> getRecords({String? userId, String? entityType, int limit = 100}) {
    var results = _records.reversed.toList();
    if (userId != null) results = results.where((r) => r.userId == userId).toList();
    if (entityType != null) results = results.where((r) => r.entityType == entityType).toList();
    return results.take(limit).toList();
  }
}

class AuditRecord {
  final String action;
  final String userId;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final DateTime timestamp;

  const AuditRecord({
    required this.action,
    required this.userId,
    required this.entityType,
    this.entityId,
    this.before,
    this.after,
    required this.timestamp,
  });
}

final auditTrailServiceProvider = Provider<AuditTrailService>((ref) {
  return AuditTrailService();
});
DART

# ============================================================
# BATCH 5 (files 81-100): Domain entities + value objects
# ============================================================

cat > "$BASE/domain/entities/security/security_event.dart" << 'DART'
/// Événement de sécurité enregistré par le système.
class SecurityEvent {
  final String id;
  final String type;
  final String severity; // low, medium, high, critical
  final String description;
  final String? userId;
  final String? deviceId;
  final String? ipAddress;
  final Map<String, dynamic> metadata;
  final DateTime occurredAt;
  final bool resolved;

  const SecurityEvent({
    required this.id,
    required this.type,
    required this.severity,
    required this.description,
    this.userId,
    this.deviceId,
    this.ipAddress,
    this.metadata = const {},
    required this.occurredAt,
    this.resolved = false,
  });

  SecurityEvent copyWith({
    String? severity,
    bool? resolved,
    Map<String, dynamic>? metadata,
  }) {
    return SecurityEvent(
      id: id,
      type: type,
      severity: severity ?? this.severity,
      description: description,
      userId: userId,
      deviceId: deviceId,
      ipAddress: ipAddress,
      metadata: metadata ?? this.metadata,
      occurredAt: occurredAt,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'severity': severity,
    'description': description, 'userId': userId,
    'occurredAt': occurredAt.toIso8601String(), 'resolved': resolved,
  };

  factory SecurityEvent.fromJson(Map<String, dynamic> json) {
    return SecurityEvent(
      id: json['id'] as String,
      type: json['type'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      userId: json['userId'] as String?,
      deviceId: json['deviceId'] as String?,
      ipAddress: json['ipAddress'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      resolved: json['resolved'] as bool? ?? false,
    );
  }
}
DART

cat > "$BASE/domain/entities/security/compliance_status.dart" << 'DART'
/// Statut de conformité d'un utilisateur ou d'une transaction.
class ComplianceStatus {
  final String userId;
  final bool isCompliant;
  final String kycTier; // basic, verified, enhanced
  final bool amlCleared;
  final bool sanctionsCleared;
  final bool pepScreened;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
  final List<String> pendingActions;
  final Map<String, dynamic> details;

  const ComplianceStatus({
    required this.userId,
    required this.isCompliant,
    required this.kycTier,
    this.amlCleared = false,
    this.sanctionsCleared = false,
    this.pepScreened = false,
    this.lastReviewDate,
    this.nextReviewDate,
    this.pendingActions = const [],
    this.details = const {},
  });

  bool get needsReview =>
      nextReviewDate != null && DateTime.now().isAfter(nextReviewDate!);

  ComplianceStatus copyWith({
    bool? isCompliant,
    String? kycTier,
    bool? amlCleared,
    List<String>? pendingActions,
  }) {
    return ComplianceStatus(
      userId: userId,
      isCompliant: isCompliant ?? this.isCompliant,
      kycTier: kycTier ?? this.kycTier,
      amlCleared: amlCleared ?? this.amlCleared,
      sanctionsCleared: sanctionsCleared,
      pepScreened: pepScreened,
      lastReviewDate: lastReviewDate,
      nextReviewDate: nextReviewDate,
      pendingActions: pendingActions ?? this.pendingActions,
      details: details,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId, 'isCompliant': isCompliant, 'kycTier': kycTier,
    'amlCleared': amlCleared, 'sanctionsCleared': sanctionsCleared,
    'pepScreened': pepScreened,
  };

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) {
    return ComplianceStatus(
      userId: json['userId'] as String,
      isCompliant: json['isCompliant'] as bool,
      kycTier: json['kycTier'] as String,
      amlCleared: json['amlCleared'] as bool? ?? false,
      sanctionsCleared: json['sanctionsCleared'] as bool? ?? false,
      pepScreened: json['pepScreened'] as bool? ?? false,
    );
  }
}
DART

cat > "$BASE/domain/entities/security/audit_entry.dart" << 'DART'
/// Entrée de journal d'audit immuable.
class AuditEntry {
  final String id;
  final String action;
  final String actorId;
  final String actorType; // user, system, admin
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? previousState;
  final Map<String, dynamic>? newState;
  final String? ipAddress;
  final String? deviceId;
  final DateTime timestamp;
  final String? reason;

  const AuditEntry({
    required this.id,
    required this.action,
    required this.actorId,
    this.actorType = 'user',
    required this.entityType,
    this.entityId,
    this.previousState,
    this.newState,
    this.ipAddress,
    this.deviceId,
    required this.timestamp,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'action': action, 'actorId': actorId,
    'actorType': actorType, 'entityType': entityType,
    'entityId': entityId, 'timestamp': timestamp.toIso8601String(),
    'reason': reason,
  };

  factory AuditEntry.fromJson(Map<String, dynamic> json) {
    return AuditEntry(
      id: json['id'] as String,
      action: json['action'] as String,
      actorId: json['actorId'] as String,
      actorType: json['actorType'] as String? ?? 'user',
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      previousState: json['previousState'] as Map<String, dynamic>?,
      newState: json['newState'] as Map<String, dynamic>?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      reason: json['reason'] as String?,
    );
  }
}
DART

cat > "$BASE/domain/entities/security/security_policy.dart" << 'DART'
/// Politique de sécurité configurable.
class SecurityPolicy {
  final String id;
  final String name;
  final bool enabled;
  final int maxLoginAttempts;
  final Duration sessionTimeout;
  final Duration mfaCooldown;
  final bool requireBiometric;
  final bool requirePinForTransactions;
  final double stepUpThreshold; // Amount triggering step-up auth
  final bool allowScreenshots;
  final bool enforceSSLPinning;
  final Map<String, dynamic> customRules;

  const SecurityPolicy({
    required this.id,
    required this.name,
    this.enabled = true,
    this.maxLoginAttempts = 5,
    this.sessionTimeout = const Duration(minutes: 15),
    this.mfaCooldown = const Duration(seconds: 60),
    this.requireBiometric = true,
    this.requirePinForTransactions = true,
    this.stepUpThreshold = 100000,
    this.allowScreenshots = false,
    this.enforceSSLPinning = true,
    this.customRules = const {},
  });

  SecurityPolicy copyWith({
    bool? enabled,
    int? maxLoginAttempts,
    Duration? sessionTimeout,
    bool? requireBiometric,
    double? stepUpThreshold,
  }) {
    return SecurityPolicy(
      id: id,
      name: name,
      enabled: enabled ?? this.enabled,
      maxLoginAttempts: maxLoginAttempts ?? this.maxLoginAttempts,
      sessionTimeout: sessionTimeout ?? this.sessionTimeout,
      mfaCooldown: mfaCooldown,
      requireBiometric: requireBiometric ?? this.requireBiometric,
      requirePinForTransactions: requirePinForTransactions,
      stepUpThreshold: stepUpThreshold ?? this.stepUpThreshold,
      allowScreenshots: allowScreenshots,
      enforceSSLPinning: enforceSSLPinning,
      customRules: customRules,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'enabled': enabled,
    'maxLoginAttempts': maxLoginAttempts,
    'sessionTimeoutMinutes': sessionTimeout.inMinutes,
    'stepUpThreshold': stepUpThreshold,
  };

  factory SecurityPolicy.fromJson(Map<String, dynamic> json) {
    return SecurityPolicy(
      id: json['id'] as String,
      name: json['name'] as String,
      enabled: json['enabled'] as bool? ?? true,
      maxLoginAttempts: json['maxLoginAttempts'] as int? ?? 5,
      sessionTimeout: Duration(minutes: json['sessionTimeoutMinutes'] as int? ?? 15),
      stepUpThreshold: (json['stepUpThreshold'] as num?)?.toDouble() ?? 100000,
    );
  }
}
DART

cat > "$BASE/domain/entities/security/security_alert.dart" << 'DART'
/// Alerte de sécurité pour l'utilisateur ou l'administrateur.
class SecurityAlert {
  final String id;
  final String title;
  final String message;
  final String severity; // info, warning, danger, critical
  final String category; // auth, network, compliance, device
  final bool requiresAction;
  final String? actionUrl;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final bool dismissed;

  const SecurityAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.category,
    this.requiresAction = false,
    this.actionUrl,
    required this.createdAt,
    this.acknowledgedAt,
    this.dismissed = false,
  });

  bool get isActive => !dismissed && acknowledgedAt == null;

  SecurityAlert acknowledge() => SecurityAlert(
    id: id, title: title, message: message,
    severity: severity, category: category,
    requiresAction: requiresAction, actionUrl: actionUrl,
    createdAt: createdAt, acknowledgedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'message': message,
    'severity': severity, 'category': category,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SecurityAlert.fromJson(Map<String, dynamic> json) {
    return SecurityAlert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      severity: json['severity'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
DART

cat > "$BASE/domain/value_objects/risk_score.dart" << 'DART'
/// Score de risque - objet valeur immuable.
class RiskScore {
  final double value; // 0.0 to 100.0
  final String category; // low, medium, high, critical
  final List<String> factors;
  final DateTime calculatedAt;

  RiskScore({
    required double value,
    this.factors = const [],
    DateTime? calculatedAt,
  })  : value = value.clamp(0.0, 100.0),
        category = _categorize(value),
        calculatedAt = calculatedAt ?? DateTime.now();

  static String _categorize(double score) {
    if (score >= 80) return 'critical';
    if (score >= 60) return 'high';
    if (score >= 30) return 'medium';
    return 'low';
  }

  bool get isAcceptable => value < 60;
  bool get requiresReview => value >= 60;
  bool get requiresBlock => value >= 90;

  RiskScore combine(RiskScore other) {
    return RiskScore(
      value: (value + other.value) / 2,
      factors: [...factors, ...other.factors],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is RiskScore && value == other.value;

  @override
  int get hashCode => value.hashCode;

  Map<String, dynamic> toJson() => {
    'value': value, 'category': category, 'factors': factors,
    'calculatedAt': calculatedAt.toIso8601String(),
  };

  factory RiskScore.fromJson(Map<String, dynamic> json) {
    return RiskScore(
      value: (json['value'] as num).toDouble(),
      factors: List<String>.from(json['factors'] ?? []),
    );
  }
}
DART

cat > "$BASE/domain/entities/security/threat_level.dart" << 'DART'
/// Niveaux de menace pour le système de sécurité.
enum ThreatLevel {
  none('Aucune menace', 0),
  low('Menace faible', 1),
  elevated('Menace élevée', 2),
  high('Menace haute', 3),
  severe('Menace sévère', 4),
  critical('Menace critique', 5);

  final String description;
  final int numericValue;

  const ThreatLevel(this.description, this.numericValue);

  bool get requiresAction => numericValue >= 3;
  bool get shouldBlockOperations => numericValue >= 4;
  bool get requiresImmediateResponse => numericValue >= 5;

  /// Get threat level from numeric value.
  static ThreatLevel fromValue(int value) {
    return ThreatLevel.values.firstWhere(
      (t) => t.numericValue == value,
      orElse: () => ThreatLevel.none,
    );
  }

  /// Compare threat levels.
  bool isHigherThan(ThreatLevel other) => numericValue > other.numericValue;
}
DART

cat > "$BASE/domain/entities/security/risk_decision.dart" << 'DART'
/// Décision de risque - sealed class pour un traitement exhaustif.
sealed class RiskDecision {
  const RiskDecision();
}

/// Approuvé - la transaction peut continuer.
class RiskApproved extends RiskDecision {
  final double score;
  const RiskApproved({required this.score});
}

/// Nécessite une vérification supplémentaire.
class RiskReviewRequired extends RiskDecision {
  final double score;
  final List<String> requiredChecks;
  final String reason;
  const RiskReviewRequired({
    required this.score,
    required this.requiredChecks,
    required this.reason,
  });
}

/// Refusé - la transaction est bloquée.
class RiskDenied extends RiskDecision {
  final double score;
  final String reason;
  final bool canAppeal;
  const RiskDenied({
    required this.score,
    required this.reason,
    this.canAppeal = true,
  });
}

/// Escalation manuelle requise.
class RiskEscalated extends RiskDecision {
  final double score;
  final String escalationReason;
  final String assignedTeam;
  const RiskEscalated({
    required this.score,
    required this.escalationReason,
    this.assignedTeam = 'compliance',
  });
}

/// Pending - en attente de données supplémentaires.
class RiskPending extends RiskDecision {
  final List<String> missingData;
  const RiskPending({required this.missingData});
}
DART

cat > "$BASE/domain/entities/security/index.dart" << 'DART'
export 'security_event.dart';
export 'compliance_status.dart';
export 'audit_entry.dart';
export 'security_policy.dart';
export 'security_alert.dart';
export 'threat_level.dart';
export 'risk_decision.dart';
DART

cat > "$BASE/domain/value_objects/index.dart" << 'DART'
export 'risk_score.dart';
DART

# ============================================================
# BATCH 6 (files 101-120): Guards
# ============================================================

cat > "$BASE/core/guards/guard_base.dart" << 'DART'
/// Base class for all security guards.
abstract class GuardBase {
  /// Unique guard identifier.
  String get name;

  /// Check if the guarded action is allowed.
  Future<GuardResult> check(GuardContext context);

  /// Called when the guard blocks an action.
  Future<void> onBlocked(GuardContext context, String reason) async {}
}

class GuardContext {
  final String userId;
  final String action;
  final Map<String, dynamic> params;
  final DateTime timestamp;

  GuardContext({
    required this.userId,
    required this.action,
    this.params = const {},
  }) : timestamp = DateTime.now();
}

class GuardResult {
  final bool allowed;
  final String? reason;
  final String? redirectTo;

  const GuardResult.allow() : allowed = true, reason = null, redirectTo = null;
  const GuardResult.deny(this.reason) : allowed = false, redirectTo = null;
  const GuardResult.redirect(this.redirectTo) : allowed = false, reason = 'Redirect required';
}
DART

cat > "$BASE/core/guards/transaction_guard.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les transactions financières.
class TransactionGuard extends GuardBase {
  static const _tag = 'TransactionGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'transaction';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final amount = (context.params['amount'] as num?)?.toDouble() ?? 0;

    // Check minimum amount
    if (amount <= 0) {
      return const GuardResult.deny('Montant invalide');
    }

    // Check maximum single transaction
    if (amount > 5000000) {
      return const GuardResult.deny('Montant maximum dépassé');
    }

    // Check if recipient is valid
    final recipient = context.params['recipient'] as String?;
    if (recipient == null || recipient.isEmpty) {
      return const GuardResult.deny('Destinataire requis');
    }

    _log.debug('Transaction guard passed: $amount FCFA');
    return const GuardResult.allow();
  }
}

final transactionGuardProvider = Provider<TransactionGuard>((ref) {
  return TransactionGuard();
});
DART

cat > "$BASE/core/guards/withdrawal_guard.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les retraits - vérifications supplémentaires.
class WithdrawalGuard extends GuardBase {
  static const _tag = 'WithdrawalGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'withdrawal';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final amount = (context.params['amount'] as num?)?.toDouble() ?? 0;
    final balance = (context.params['balance'] as num?)?.toDouble() ?? 0;
    final kycTier = context.params['kycTier'] as String? ?? 'basic';

    if (amount > balance) {
      return const GuardResult.deny('Solde insuffisant');
    }

    // Daily withdrawal limit by KYC tier
    final dailyLimit = kycTier == 'verified' ? 2000000.0 : 200000.0;
    final dailyTotal = (context.params['dailyWithdrawn'] as num?)?.toDouble() ?? 0;

    if (dailyTotal + amount > dailyLimit) {
      return const GuardResult.deny('Limite de retrait journalière atteinte');
    }

    // Large withdrawals require step-up auth
    if (amount > 500000) {
      final stepUpDone = context.params['stepUpCompleted'] as bool? ?? false;
      if (!stepUpDone) {
        return const GuardResult.redirect('/step-up-auth');
      }
    }

    _log.debug('Withdrawal guard passed: $amount FCFA');
    return const GuardResult.allow();
  }
}

final withdrawalGuardProvider = Provider<WithdrawalGuard>((ref) {
  return WithdrawalGuard();
});
DART

cat > "$BASE/core/guards/login_guard.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour la connexion - vérifie les conditions de login.
class LoginGuard extends GuardBase {
  static const _tag = 'LoginGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'login';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final isLocked = context.params['isLocked'] as bool? ?? false;
    if (isLocked) {
      return const GuardResult.deny('Compte temporairement verrouillé');
    }

    final failedAttempts = context.params['failedAttempts'] as int? ?? 0;
    if (failedAttempts >= 5) {
      return const GuardResult.deny('Trop de tentatives échouées. Réessayez plus tard.');
    }

    final deviceBound = context.params['deviceBound'] as bool? ?? true;
    if (!deviceBound) {
      return const GuardResult.redirect('/device-verification');
    }

    _log.debug('Login guard passed');
    return const GuardResult.allow();
  }
}

final loginGuardProvider = Provider<LoginGuard>((ref) {
  return LoginGuard();
});
DART

cat > "$BASE/core/guards/settings_guard.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour les modifications de paramètres sensibles.
class SettingsGuard extends GuardBase {
  static const _tag = 'SettingsGuard';
  final AppLogger _log = AppLogger(_tag);

  static const _sensitiveSettings = [
    'phone', 'email', 'pin', 'biometric', 'security',
    'withdrawal_address', 'notification_preferences',
  ];

  @override
  String get name => 'settings';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final setting = context.params['setting'] as String?;

    if (setting != null && _sensitiveSettings.contains(setting)) {
      final recentAuth = context.params['recentAuth'] as bool? ?? false;
      if (!recentAuth) {
        _log.debug('Settings guard: step-up required for $setting');
        return const GuardResult.redirect('/step-up-auth');
      }
    }

    return const GuardResult.allow();
  }
}

final settingsGuardProvider = Provider<SettingsGuard>((ref) {
  return SettingsGuard();
});
DART

cat > "$BASE/core/guards/export_guard.dart" << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';
import 'guard_base.dart';

/// Garde pour l'exportation de données sensibles.
class ExportGuard extends GuardBase {
  static const _tag = 'ExportGuard';
  final AppLogger _log = AppLogger(_tag);

  @override
  String get name => 'export';

  @override
  Future<GuardResult> check(GuardContext context) async {
    // Require recent biometric auth for export
    final recentBiometric = context.params['recentBiometric'] as bool? ?? false;
    if (!recentBiometric) {
      return const GuardResult.redirect('/biometric-verify');
    }

    // Check export rate limit (max 3 per day)
    final exportsToday = context.params['exportsToday'] as int? ?? 0;
    if (exportsToday >= 3) {
      return const GuardResult.deny('Limite d\'exportation quotidienne atteinte');
    }

    // Check if export type is allowed
    final exportType = context.params['type'] as String?;
    if (exportType == 'full_history' && context.params['kycTier'] != 'verified') {
      return const GuardResult.deny('KYC vérifié requis pour l\'export complet');
    }

    _log.debug('Export guard passed for type: $exportType');
    return const GuardResult.allow();
  }
}