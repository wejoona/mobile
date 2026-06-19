import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/app_route_contract.dart';

void main() {
  group('App route contracts', () {
    test('login routes are explicit public auth entry points', () {
      final login = appRouteContractFor('/login');
      final loginOtp = appRouteContractFor('/login/otp');

      expect(login.role, AppRouteRole.authEntry);
      expect(login.isPublic, isTrue);
      expect(login.isExplicitPublic, isTrue);
      expect(login.isAuthDeadEnd, isTrue);
      expect(loginOtp.role, AppRouteRole.verificationStep);
      expect(loginOtp.isAuthDeadEnd, isTrue);
    });

    test('signup consent is separate from the phone entry screen', () {
      final signup = appRouteContractFor('/signup');
      final consent = appRouteContractFor('/signup/legal-consent');

      expect(signup.role, AppRouteRole.authEntry);
      expect(signup.isSignupRoute, isTrue);
      expect(consent.role, AppRouteRole.consentStep);
      expect(consent.isSignupRoute, isTrue);
      expect(consent.isAuthDeadEnd, isTrue);
    });

    test('legacy onboarding routes remain classified but point to signup', () {
      final legacyProfile = appRouteContractFor('/onboarding/profile');

      expect(legacyProfile.isLegacySignupRoute, isTrue);
      expect(legacyProfile.canonicalRoute, '/signup');
    });

    test('PIN reset stays available during locked recovery', () {
      final reset = appRouteContractFor('/pin/reset');

      expect(reset.role, AppRouteRole.securityRecovery);
      expect(reset.isPublic, isTrue);
      expect(reset.isSecurityRecovery, isTrue);
      expect(reset.isAllowedWhenLocked, isTrue);
      expect(reset.events, contains(AppNavigationEvent.forgotPinSelected));
    });

    test('money movement routes carry wallet and compliance requirements', () {
      final sendExternal = appRouteContractFor('/send-external/address');
      final deposit = appRouteContractFor('/deposit/amount');

      expect(sendExternal.role, AppRouteRole.moneyStep);
      expect(sendExternal.requiresAuth, isTrue);
      expect(sendExternal.requiresWallet, isTrue);
      expect(sendExternal.requiresVerifiedKyc, isTrue);
      expect(
        sendExternal.capabilities,
        contains(AppRouteCapability.moneyMovement),
      );

      expect(deposit.role, AppRouteRole.moneyStep);
      expect(deposit.requiresWallet, isTrue);
      expect(deposit.requiresKycTier1, isTrue);
      expect(deposit.requiresVerifiedKyc, isFalse);
    });
  });
}
