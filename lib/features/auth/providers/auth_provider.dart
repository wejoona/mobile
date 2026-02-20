import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/device/device_registration_service.dart';
import 'package:usdc_wallet/services/session/user_session.dart';
import 'package:usdc_wallet/services/session/user_session_repository.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/state/fsm/index.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';
import 'package:usdc_wallet/services/analytics/analytics_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Auth State
enum AuthStatus {
  initial,
  loading,
  authenticated,
  locked, // Has session but needs PIN/biometric to unlock
  unauthenticated,
  otpSent,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? phone;
  final String? error;
  final int? otpExpiresIn;
  final UserSession? session; // Persisted session

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phone,
    this.error,
    this.otpExpiresIn,
    this.session,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phone,
    String? error,
    int? otpExpiresIn,
    UserSession? session,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      error: error,
      otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
      session: session ?? this.session,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLocked => status == AuthStatus.locked;
  bool get isLoading => status == AuthStatus.loading;
  bool get hasSession => session != null;
}

/// Auth Notifier — uses [UserSessionRepository] for persistent session.
class AuthNotifier extends Notifier<AuthState> {
  static final _log = AppLogger('AuthNotifier');

  @override
  AuthState build() {
    Future.microtask(() => checkAuth());
    return const AuthState();
  }

  AuthService get _authService => ref.read(authServiceProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  UserSessionRepository get _sessionRepo => ref.read(userSessionRepositoryProvider);
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  /// Check for a persisted session on startup.
  ///
  /// Flow:
  /// 1. Load UserSession from secure storage
  /// 2. If exists + session valid → locked (require PIN/biometric)
  ///    - Token refresh happens on unlock, NOT here
  /// 3. If no session → unauthenticated
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final session = await _sessionRepo.load();

      if (session != null) {
        _log.info('Restored session for user ${session.userId} (token expired: ${session.isTokenExpired})');

        // Session exists — show lock screen (PIN/biometric).
        // We do NOT check token validity here. Token refresh happens after unlock.
        state = state.copyWith(
          status: AuthStatus.locked,
          session: session,
          phone: session.phoneNumber,
        );

        // Sync FSM with restored session
        ref.read(appFsmProvider.notifier).restoreSession(
          userId: session.userId,
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
      } else {
        // No session — check for legacy token storage (migration path)
        final legacyToken = await _storage.read(key: 'access_token');
        if (legacyToken != null) {
          _log.info('Found legacy token, migrating to UserSession');
          // Can't create a full session without user data, go to login
          await _storage.delete(key: 'access_token');
        }

        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      _log.error('checkAuth failed', e);
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Lock the session (requires PIN/biometric to unlock)
  void setLocked() {
    if (state.status == AuthStatus.authenticated) {
      state = state.copyWith(status: AuthStatus.locked);
    }
  }

  /// Unlock the session after PIN/biometric verification.
  ///
  /// This triggers a token refresh if the token is expired.
  /// User sees home immediately with cached data while refresh happens in background.
  void unlock() {
    if (state.status != AuthStatus.locked) return;

    state = state.copyWith(status: AuthStatus.authenticated);

    // Proactively refresh token — but don't block unlock on it
    _refreshTokenOnUnlock();

    // Touch session lastActive
    _sessionRepo.touchLastActive();

    // Start real-time sync
    ref.read(realtimeServiceProvider).start();
  }

  Future<void> _refreshTokenOnUnlock() async {
    final session = state.session;
    if (session == null || !session.canRefresh) return;

    try {
      final response = await _authService.refreshToken(refreshToken: session.refreshToken);
      final expiresAt = DateTime.now().add(Duration(seconds: response.expiresIn));

      // Update persisted session with new tokens
      final updated = await _sessionRepo.updateTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: expiresAt,
      );

      if (updated != null) {
        state = state.copyWith(session: updated);
      }

      // Also update legacy storage keys for api_client interceptor
      await _storage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: response.refreshToken!);
      }

      _log.info('Token refreshed successfully on unlock');
    } catch (e) {
      _log.warn('Token refresh failed on unlock — will retry on next API call', e);
      // Don't logout! The 401 interceptor will handle this on next API call.
      // User can still see cached data.
    }
  }

  /// Register new user
  Future<void> register(String phone, String countryCode) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);
    ref.read(appFsmProvider.notifier).login(phone, countryCode);

    try {
      final response = await _authService.register(
        phone: phone,
        countryCode: countryCode,
      );

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );

      _analytics.trackRegistration(country: countryCode);
      ref.read(appFsmProvider.notifier).onOtpReceived(expiresIn: response.expiresIn);
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
    }
  }

  /// Login existing user
  Future<void> login(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);
    ref.read(appFsmProvider.notifier).login(phone, '');

    try {
      final response = await _authService.login(phone: phone);

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );

      ref.read(appFsmProvider.notifier).onOtpReceived(expiresIn: response.expiresIn);
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (state.phone == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Phone number not found',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);
    ref.read(appFsmProvider.notifier).verifyOtp(otp);

    try {
      final response = await _authService.verifyOtp(
        phone: state.phone!,
        otp: otp,
      );

      // Create and persist UserSession
      final now = DateTime.now();
      final session = UserSession(
        userId: response.user.id,
        phoneNumber: state.phone!,
        displayName: '${response.user.firstName ?? ''} ${response.user.lastName ?? ''}'.trim(),
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        email: response.user.email,
        countryCode: response.user.countryCode,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken ?? '',
        tokenExpiresAt: now.add(Duration(seconds: response.expiresIn)),
        lastActive: now,
        sessionCreatedAt: now,
        kycStatus: response.kycStatus,
        hasCompletedKyc: response.kycStatus == 'verified',
        avatarUrl: response.user.avatarUrl,
      );

      await _sessionRepo.save(session);
      _log.info('Created new session for user ${session.userId}');

      // Also write to legacy storage for interceptor compatibility
      await _storage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: response.refreshToken!);
      }
      await _storage.write(key: 'user_id', value: response.user.id);

      // Start session service
      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        tokenValidity: Duration(seconds: response.expiresIn),
      );

      // Sync with FSM
      ref.read(appFsmProvider.notifier).onAuthVerified(
        userId: response.user.id,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      if (response.kycStatus != null) {
        ref.read(kycStateMachineProvider.notifier).updateFromAuthResponse(response.kycStatus);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        session: session,
      );

      _analytics.trackLogin(method: 'otp');
      _analytics.setUserProperties(userId: response.user.id);
      ref.read(deviceRegistrationServiceProvider).registerCurrentDevice();

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      ref.read(appFsmProvider.notifier).onAuthFailed(e.toString());
      return false;
    }
  }

  /// Login with biometric (refresh token)
  Future<bool> loginWithBiometric(String refreshToken) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.refreshToken(refreshToken: refreshToken);
      final now = DateTime.now();
      final expiresAt = now.add(Duration(seconds: response.expiresIn));

      // Update session tokens
      final updated = await _sessionRepo.updateTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresAt: expiresAt,
      );

      // Update legacy storage
      await _storage.write(key: 'access_token', value: response.accessToken);
      if (response.refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: response.refreshToken!);
      }

      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        tokenValidity: Duration(seconds: response.expiresIn),
      );

      ref.read(appFsmProvider.notifier).onAuthVerified(
        userId: response.user?.id ?? '',
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
        session: updated,
      );

      return true;
    } catch (e) {
      _log.error('Biometric login failed', e);
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Biometric login failed. Please log in again.',
      );
      return false;
    }
  }

  /// Logout — clears persisted session.
  Future<void> logout() async {
    ref.read(realtimeServiceProvider).stop();
    await _authService.logout();
    await ref.read(sessionServiceProvider.notifier).endSession();

    // Clear persisted session
    await _sessionRepo.clear();

    // Clear legacy storage
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user_id');

    state = const AuthState(status: AuthStatus.unauthenticated);
    ref.read(appFsmProvider.notifier).logout();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user data (called from profile updates)
  void updateUser(User user) {
    state = state.copyWith(user: user);
    // Also update persisted session
    _sessionRepo.updateProfile(
      firstName: user.firstName,
      lastName: user.lastName,
      email: user.email,
      avatarUrl: user.avatarUrl,
    );
  }

  /// Update session after wallet creation
  void updateWalletId(String walletId) {
    if (state.session != null) {
      final updated = state.session!.copyWith(walletId: walletId);
      state = state.copyWith(session: updated);
      _sessionRepo.save(updated);
    }
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
