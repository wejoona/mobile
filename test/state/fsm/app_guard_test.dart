import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/kyc/utils/kyc_return_route.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/auth_fsm.dart';
import 'package:usdc_wallet/state/fsm/kyc_fsm.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/wallet_fsm.dart';

void main() {
  group('AppGuards', () {
    test('deposit KYC block preserves money-flow intent and return route', () {
      final state = AppState(
        auth: const AuthAuthenticated(
          userId: 'user_123',
          phone: '+2250748805663',
          accessToken: 'token',
        ),
        wallet: WalletReady(
          walletId: 'wallet_123',
          usdcBalance: 0,
          lastUpdated: DateTime(2026),
        ),
        kyc: const KycNone(),
        session: SessionActive(
          startedAt: DateTime(2026),
          lastActivity: DateTime(2026),
          timeout: const Duration(minutes: 15),
        ),
      );

      final result = AppGuards(state).canAccessRoute('/deposit/amount');

      expect(result, isA<GuardDenied>());
      final denied = result as GuardDenied;
      expect(
        denied.redirectTo,
        '/kyc?intent=deposit&returnTo=%2Fdeposit%2Famount',
      );
      expect(denied.reason, 'KYC verification required for deposit');
    });

    test('deposit KYC return target accepts canonical deposit subroutes', () {
      expect(
        safeKycReturnRoute(
          raw: '/deposit/provider?amount=25',
          intent: 'deposit',
        ),
        '/deposit/provider?amount=25',
      );
      expect(
        safeKycReturnRoute(raw: '/deposit/status/abc', intent: 'deposit'),
        '/deposit/status/abc',
      );
      expect(
        safeKycReturnRoute(raw: '/send/amount', intent: 'deposit'),
        isNull,
      );
    });

    test(
      'authenticated unknown routes fall back before GoRouter not-found',
      () {
        final state = AppState(
          auth: const AuthAuthenticated(
            userId: 'user_123',
            phone: '+2250748805663',
            accessToken: 'token',
          ),
          wallet: WalletReady(
            walletId: 'wallet_123',
            usdcBalance: 0,
            lastUpdated: DateTime(2026),
          ),
          kyc: KycVerified(tier: KycTier.tier1, verifiedAt: DateTime(2026)),
          session: SessionActive(
            startedAt: DateTime(2026),
            lastActivity: DateTime(2026),
            timeout: const Duration(minutes: 15),
          ),
        );

        final result = AppGuards(state).canAccessRoute('/not-a-real-route');

        expect(result, isA<GuardDenied>());
        final denied = result as GuardDenied;
        expect(denied.redirectTo, '/home');
        expect(denied.reason, 'Unknown route');
      },
    );
  });
}
