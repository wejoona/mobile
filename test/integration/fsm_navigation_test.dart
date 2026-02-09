import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/index.dart';

/// Integration tests for FSM navigation flow
/// Tests that the correct screen is determined for each FSM state
void main() {
  group('FSM Navigation Integration Tests', () {
    test('Auth locked state should navigate to AuthLocked screen', () {
      // Arrange - Create AppState with AuthLocked
      final appState = AppState(
        auth: AuthLocked(
          phone: '+22512345678',
          lockedAt: DateTime.now(),
          lockDuration: const Duration(minutes: 15),
          reason: 'Too many failed login attempts',
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );

      // Act - Get the current screen from the FSM state
      final screen = appState.currentScreen;

      // Assert - Verify AuthLockedScreen is determined
      expect(screen, equals(AppScreen.authLocked));
      expect(screen.route, equals('/auth-locked'));
    });

    test('Auth suspended state should navigate to AuthSuspended screen', () {
      // Arrange
      final appState = AppState(
        auth: AuthSuspended(
          userId: 'user123',
          phone: '+22512345678',
          reason: 'Account under investigation',
          suspendedAt: DateTime.now(),
          suspendedUntil: DateTime.now().add(const Duration(days: 7)),
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.authSuspended));
      expect(screen.route, equals('/auth-suspended'));
    });

    test('OTP expired state should navigate to OtpExpired screen', () {
      // Arrange
      final appState = AppState(
        auth: const AuthOtpExpired(phone: '+22512345678'),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.otpExpired));
      expect(screen.route, equals('/otp-expired'));
    });

    test('Session locked state should navigate to SessionLocked screen', () {
      // Arrange
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: SessionLocked(
          lockedAt: DateTime.now(),
          reason: 'Session timed out',
        ),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.sessionLocked));
      expect(screen.route, equals('/session-locked'));
    });

    test('Wallet frozen state should navigate to WalletFrozen screen', () {
      // Arrange
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletFrozen(
          walletId: 'wallet123',
          frozenAt: DateTime.now(),
          reason: 'Suspicious activity detected',
        ),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.walletFrozen));
      expect(screen.route, equals('/wallet-frozen'));
    });

    test('KYC expired state should navigate to KycExpired screen', () {
      // Arrange
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletReady(
          walletId: 'wallet123',
          usdcBalance: 100.0,
          lastUpdated: DateTime.now(),
        ),
        kyc: KycExpired(
          previousTier: KycTier.tier1,
          expiredAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.kycExpired));
      expect(screen.route, equals('/kyc-expired'));
    });

    test('Screen precedence - Auth locked takes priority over wallet frozen',
        () {
      // Arrange - Multiple blocking states
      final appState = AppState(
        auth: AuthLocked(
          phone: '+22512345678',
          lockedAt: DateTime.now(),
          lockDuration: const Duration(minutes: 15),
          reason: 'Too many failed attempts',
        ),
        wallet: WalletFrozen(
          walletId: 'wallet123',
          frozenAt: DateTime.now(),
          reason: 'Suspicious activity',
        ),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert - AuthLocked should take precedence
      expect(screen, equals(AppScreen.authLocked));
    });

    test('Screen precedence - Session locked takes priority over wallet frozen',
        () {
      // Arrange
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletFrozen(
          walletId: 'wallet123',
          frozenAt: DateTime.now(),
          reason: 'Suspicious activity',
        ),
        kyc: const KycInitial(),
        session: SessionLocked(
          lockedAt: DateTime.now(),
          reason: 'Session timeout',
        ),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert - SessionLocked should take precedence
      expect(screen, equals(AppScreen.sessionLocked));
    });

    test('Screen precedence - Auth states take priority over session states',
        () {
      // Arrange
      final appState = AppState(
        auth: AuthSuspended(
          userId: 'user123',
          phone: '+22512345678',
          reason: 'Account suspended',
          suspendedAt: DateTime.now(),
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: SessionLocked(
          lockedAt: DateTime.now(),
          reason: 'Session locked',
        ),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert - AuthSuspended should take precedence over SessionLocked
      expect(screen, equals(AppScreen.authSuspended));
    });

    test('AppState correctly reports derived properties', () {
      // Arrange - Various states
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletReady(
          walletId: 'wallet123',
          usdcBalance: 100.0,
          lastUpdated: DateTime.now(),
        ),
        kyc: KycVerified(tier: KycTier.tier1, verifiedAt: DateTime.now()),
        session: const SessionNone(),
      );

      // Assert
      expect(appState.isAuthenticated, isTrue);
      expect(appState.hasWallet, isTrue);
      expect(appState.isKycVerified, isTrue);
      expect(appState.canDeposit, isTrue);
      expect(appState.canWithdraw, isTrue);
      expect(appState.canSend, isTrue);
      expect(appState.canReceive, isTrue);
    });

    test('AppState correctly identifies blocked states', () {
      // Auth locked
      final authLockedState = AppState(
        auth: AuthLocked(
          phone: '+22512345678',
          lockedAt: DateTime.now(),
          lockDuration: const Duration(minutes: 15),
          reason: 'Too many attempts',
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );
      expect(authLockedState.isAuthBlocked, isTrue);

      // Auth suspended
      final authSuspendedState = AppState(
        auth: AuthSuspended(
          userId: 'user123',
          phone: '+22512345678',
          reason: 'Suspended',
          suspendedAt: DateTime.now(),
        ),
        wallet: const WalletNone(),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );
      expect(authSuspendedState.isAuthBlocked, isTrue);

      // Wallet frozen
      final walletFrozenState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletFrozen(
          walletId: 'wallet123',
          frozenAt: DateTime.now(),
          reason: 'Frozen',
        ),
        kyc: const KycInitial(),
        session: const SessionNone(),
      );
      expect(walletFrozenState.isWalletBlocked, isTrue);

      // KYC expired
      final kycExpiredState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletReady(
          walletId: 'wallet123',
          usdcBalance: 100.0,
          lastUpdated: DateTime.now(),
        ),
        kyc: KycExpired(
          previousTier: KycTier.tier1,
          expiredAt: DateTime.now(),
        ),
        session: const SessionNone(),
      );
      expect(kycExpiredState.isKycExpired, isTrue);
    });

    test('Unauthenticated state navigates to login', () {
      // Arrange
      const appState = AppState(
        auth: AuthUnauthenticated(),
        wallet: WalletNone(),
        kyc: KycInitial(),
        session: SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.login));
      expect(screen.route, equals('/login'));
    });

    test('Authenticated with wallet navigates to home', () {
      // Arrange
      final appState = AppState(
        auth: const AuthAuthenticated(
          userId: 'user123',
          phone: '+22512345678',
          accessToken: 'token123',
        ),
        wallet: WalletReady(
          walletId: 'wallet123',
          usdcBalance: 100.0,
          lastUpdated: DateTime.now(),
        ),
        kyc: KycVerified(tier: KycTier.tier1, verifiedAt: DateTime.now()),
        session: const SessionNone(),
      );

      // Act
      final screen = appState.currentScreen;

      // Assert
      expect(screen, equals(AppScreen.home));
      expect(screen.route, equals('/home'));
    });
  });
}
