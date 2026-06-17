import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/services/session/user_session.dart';
import 'package:usdc_wallet/services/storage/secure_prefs.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Persists and retrieves [UserSession] from secure storage.
///
/// This is the single source of truth for "is there a logged-in user on this device?"
/// Independent of JWT validity — a session can exist with an expired token.
class UserSessionRepository {
  static const _sessionKey = 'user_session_v1';
  static const _rememberedPhoneKey = 'remembered_phone';
  static const _tag = 'UserSessionRepo';
  final FlutterSecureStorage _storage;
  final AppLogger _log = AppLogger(_tag);

  UserSessionRepository(this._storage);

  /// Load the persisted session. Returns null if no session exists.
  Future<UserSession?> load() async {
    try {
      final json = await _storage.read(key: _sessionKey);
      final session = UserSession.fromJsonString(json);
      if (session != null && !session.isSessionValid) {
        _log.info('Session expired (inactive >30 days), clearing');
        await clear();
        return null;
      }
      return session;
    } catch (e) {
      _log.error('Failed to load session', e);
      return null;
    }
  }

  /// Persist the session to secure storage.
  Future<void> save(UserSession session) async {
    try {
      final updated = session.copyWith(lastActive: DateTime.now());
      await _storage.write(key: _sessionKey, value: updated.toJsonString());
      // Also save phone for "remember me"
      await _storage.write(
        key: _rememberedPhoneKey,
        value: _rememberedPhoneValue(session),
      );
      _log.debug('Session saved for user ${session.userId}');
    } catch (e) {
      _log.error('Failed to save session', e);
    }
  }

  /// Update tokens in the persisted session (after refresh).
  Future<UserSession?> updateTokens({
    required String accessToken,
    String? refreshToken,
    required DateTime expiresAt,
  }) async {
    final session = await load();
    if (session == null) return null;
    final updated = session.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken ?? session.refreshToken,
      tokenExpiresAt: expiresAt,
      lastActive: DateTime.now(),
    );
    await save(updated);
    return updated;
  }

  /// Update user profile fields in the persisted session.
  Future<void> updateProfile({
    String? displayName,
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    String? walletId,
    String? kycStatus,
    bool? hasCompletedKyc,
    bool clearDisplayName = false,
    bool clearFirstName = false,
    bool clearLastName = false,
    bool clearEmail = false,
    bool clearAvatarUrl = false,
  }) async {
    final session = await load();
    if (session == null) return;
    final updated = session.copyWith(
      displayName: displayName,
      firstName: firstName,
      lastName: lastName,
      email: email,
      avatarUrl: avatarUrl,
      walletId: walletId,
      kycStatus: kycStatus,
      hasCompletedKyc: hasCompletedKyc,
      lastActive: DateTime.now(),
      clearDisplayName: clearDisplayName,
      clearFirstName: clearFirstName,
      clearLastName: clearLastName,
      clearEmail: clearEmail,
      clearAvatarUrl: clearAvatarUrl,
    );
    await save(updated);
  }

  /// Clear the session (full logout).
  Future<void> clear() async {
    try {
      await _storage.delete(key: _sessionKey);
      _log.debug('Session cleared');
    } catch (e) {
      _log.error('Failed to clear session', e);
    }
  }

  /// Get the remembered phone number for pre-filling the login screen.
  Future<String?> getRememberedPhone() async {
    try {
      return await _storage.read(key: _rememberedPhoneKey);
    } catch (_) {
      return null;
    }
  }

  /// Touch lastActive timestamp (call on app foreground, user interaction).
  Future<void> touchLastActive() async {
    final session = await load();
    if (session == null) return;
    await save(session.copyWith(lastActive: DateTime.now()));
  }

  String _rememberedPhoneValue(UserSession session) {
    final country =
        (session.countryCode == null
            ? null
            : SupportedCountries.findByCodeIncludingDisabled(
                session.countryCode!,
              )) ??
        SupportedCountries.findByPhone(session.phoneNumber) ??
        SupportedCountries.defaultCountry;
    final dialCode = country.fullPrefix;
    final localNumber = localPhoneDigits(
      dialCode: dialCode,
      phoneNumber: session.phoneNumber,
    );
    return '$dialCode|$localNumber';
  }
}

final userSessionRepositoryProvider = Provider<UserSessionRepository>((ref) {
  return UserSessionRepository(ref.watch(secureStorageProvider));
});
