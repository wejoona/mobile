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
      final terms = appRouteContractFor('/legal/terms');
      final privacy = appRouteContractFor('/legal/privacy');

      expect(signup.role, AppRouteRole.authEntry);
      expect(signup.isSignupRoute, isTrue);
      expect(consent.role, AppRouteRole.consentStep);
      expect(consent.isSignupRoute, isTrue);
      expect(consent.isAuthDeadEnd, isTrue);
      expect(terms.role, AppRouteRole.consentStep);
      expect(terms.isPublic, isTrue);
      expect(terms.events, contains(AppNavigationEvent.legalDocumentOpened));
      expect(privacy.role, AppRouteRole.consentStep);
      expect(privacy.isPublic, isTrue);
      expect(privacy.events, contains(AppNavigationEvent.legalDocumentOpened));
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

    test('declared PIN and security routes are explicitly contracted', () {
      const routes = {
        '/settings/pin': AppRouteRole.settingsStep,
        '/pin/setup': AppRouteRole.setupStep,
        '/pin/confirm': AppRouteRole.setupStep,
        '/pin/enter': AppRouteRole.securityStep,
        '/pin/locked': AppRouteRole.securityStep,
      };

      for (final entry in routes.entries) {
        final contract = appRouteContractFor(entry.key);

        expect(contract.role, entry.value, reason: entry.key);
        expect(contract.role, isNot(AppRouteRole.unknown), reason: entry.key);
        expect(
          contract.events,
          contains(AppNavigationEvent.pinRequired),
          reason: entry.key,
        );
      }

      expect(appRouteContractFor('/pin/enter').isAllowedWhenLocked, isTrue);
      expect(
        appRouteContractFor('/pin/locked').events,
        contains(AppNavigationEvent.routeBlocked),
      );
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
      expect(deposit.canonicalRoute, '/deposit/amount');
      expect(deposit.requiresWallet, isTrue);
      expect(deposit.requiresKycTier1, isFalse);
      expect(deposit.requiresVerifiedKyc, isFalse);
    });

    test('payment-link routes have explicit public and wallet contracts', () {
      final publicPay = appRouteContractFor('/pay/test-code');
      final linksList = appRouteContractFor('/payment-links');
      final linkDetail = appRouteContractFor('/payment-links/link_123');
      final namedLinkDetail = appRouteContractFor(
        '/payment-links/detail/link_123',
      );
      final createLink = appRouteContractFor('/payment-links/create');
      final createdLink = appRouteContractFor(
        '/payment-links/created/link_123',
      );

      expect(publicPay.role, AppRouteRole.publicDeepLink);
      expect(publicPay.isPublic, isTrue);
      expect(publicPay.isExplicitPublic, isTrue);
      expect(publicPay.requiresAuth, isFalse);

      for (final contract in [linksList, linkDetail, namedLinkDetail]) {
        expect(contract.role, AppRouteRole.moneyStep);
        expect(contract.role, isNot(AppRouteRole.unknown));
        expect(contract.requiresAuth, isTrue);
        expect(contract.requiresWallet, isTrue);
        expect(contract.requiresVerifiedKyc, isFalse);
      }

      for (final contract in [createLink, createdLink]) {
        expect(contract.role, AppRouteRole.moneyStep);
        expect(contract.requiresAuth, isTrue);
        expect(contract.requiresWallet, isTrue);
        expect(contract.requiresVerifiedKyc, isTrue);
        expect(
          contract.capabilities,
          contains(AppRouteCapability.moneyMovement),
        );
      }
    });

    test(
      'KYC setup routes are explicit setup routes without swallowing FSM states',
      () {
        final kycStart = appRouteContractFor('/kyc/start');
        final kycDocumentType = appRouteContractFor('/kyc/document-type');
        final kycExpired = appRouteContractFor('/kyc-expired');

        expect(kycStart.role, AppRouteRole.setupStep);
        expect(kycStart.requiresAuth, isTrue);
        expect(kycStart.isSetupRoute, isTrue);
        expect(kycStart.events, contains(AppNavigationEvent.kycStarted));

        expect(kycDocumentType.role, AppRouteRole.setupStep);
        expect(kycDocumentType.isSetupRoute, isTrue);

        expect(kycExpired.role, AppRouteRole.fsmState);
        expect(kycExpired.isFsmRoute, isTrue);
      },
    );
  });
}
