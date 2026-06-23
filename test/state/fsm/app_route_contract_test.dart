import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_route_contract.dart';

void main() {
  group('App route contracts', () {
    test('login routes are explicit public auth entry points', () {
      final login = appRouteContractFor('/login');
      final loginOtp = appRouteContractFor('/login/otp');
      final loginWithReturn = appRouteContractFor('/login?returnTo=/pay/abc');
      final otpWithReturn = appRouteContractFor('/login/otp?returnTo=/pay/abc');
      final pinWithReturn = appRouteContractFor('/login/pin?returnTo=/pay/abc');

      expect(login.role, AppRouteRole.authEntry);
      expect(login.isPublic, isTrue);
      expect(login.isExplicitPublic, isTrue);
      expect(login.isAuthDeadEnd, isTrue);
      expect(loginOtp.role, AppRouteRole.verificationStep);
      expect(loginOtp.isAuthDeadEnd, isTrue);
      expect(appRouteContractFor('/otp').role, AppRouteRole.verificationStep);
      expect(AppScreen.otp.route, '/login/otp');
      expect(loginWithReturn.role, AppRouteRole.authEntry);
      expect(loginWithReturn.isExplicitPublic, isTrue);
      expect(otpWithReturn.role, AppRouteRole.verificationStep);
      expect(otpWithReturn.isExplicitPublic, isTrue);
      expect(pinWithReturn.role, AppRouteRole.securityStep);
      expect(pinWithReturn.isExplicitPublic, isTrue);
      expect(appRoutePathForContract('/login?returnTo=/pay/abc'), '/login');
    });

    test('settings routes do not inherit setup flow ownership', () {
      final profile = appRouteContractFor('/settings/profile');
      final settingsKyc = appRouteContractFor('/settings/kyc');
      final setupKyc = appRouteContractFor('/kyc/status');

      expect(profile.role, AppRouteRole.settingsStep);
      expect(profile.isSetupRoute, isFalse);
      expect(settingsKyc.role, AppRouteRole.settingsStep);
      expect(settingsKyc.isSetupRoute, isFalse);
      expect(setupKyc.role, AppRouteRole.setupStep);
      expect(setupKyc.isSetupRoute, isTrue);
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
        '/signup/set-pin': AppRouteRole.setupStep,
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

      expect(appRouteContractFor('/settings/pin').isAllowedWhenLocked, isFalse);
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
      expect(deposit.requiresKycTier1, isTrue);
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

      expect(appRouteContractFor('/pin/setup').role, AppRouteRole.unknown);
      expect(appRouteContractFor('/pin/confirm').role, AppRouteRole.unknown);
    });

    test(
      'merchant, bill, and offline money routes are explicitly contracted',
      () {
        final scanToPay = appRouteContractFor('/scan-to-pay');
        final billList = appRouteContractFor('/bill-payments');
        final billHistory = appRouteContractFor('/bill-payments/history');
        final billForm = appRouteContractFor(
          '/bill-payments/form/orange-money',
        );
        final billSuccess = appRouteContractFor(
          '/bill-payments/success/payment-123',
        );
        final bankTransfer = appRouteContractFor(
          '/bank-linking/transfer/account-123',
        );
        final subBusinessTransfer = appRouteContractFor(
          '/sub-businesses/transfer/business-123',
        );
        final offlineTransfers = appRouteContractFor(
          '/offline/pending-transfers',
        );
        final merchantRequest = appRouteContractFor('/create-payment-request');

        for (final contract in [
          scanToPay,
          billList,
          billHistory,
          billForm,
          billSuccess,
          bankTransfer,
          subBusinessTransfer,
          merchantRequest,
        ]) {
          expect(contract.role, AppRouteRole.moneyStep);
          expect(contract.requiresAuth, isTrue);
          expect(contract.requiresWallet, isTrue);
          expect(contract.requiresVerifiedKyc, isTrue);
          expect(
            contract.capabilities,
            contains(AppRouteCapability.moneyMovement),
          );
        }

        expect(offlineTransfers.role, AppRouteRole.moneyStep);
        expect(offlineTransfers.requiresWallet, isTrue);
        expect(
          offlineTransfers.capabilities,
          contains(AppRouteCapability.moneyMovement),
        );
      },
    );

    test(
      'stored beneficiary and business routes are not generic unknown routes',
      () {
        final contacts = appRouteContractFor('/contacts/list');
        final beneficiaries = appRouteContractFor(
          '/beneficiaries/detail/ben-1',
        );
        final bankLinking = appRouteContractFor('/bank-linking/verify/bank-1');
        final subBusiness = appRouteContractFor('/sub-businesses/detail/sub-1');
        final merchantTransactions = appRouteContractFor(
          '/merchant-transactions',
        );

        for (final contract in [
          contacts,
          beneficiaries,
          bankLinking,
          subBusiness,
          merchantTransactions,
        ]) {
          expect(contract.role, isNot(AppRouteRole.unknown));
          expect(contract.requiresAuth, isTrue);
        }
      },
    );

    test(
      'KYC setup routes are explicit setup routes without swallowing FSM states',
      () {
        final kycStart = appRouteContractFor('/kyc/start');
        final kycDocumentType = appRouteContractFor('/kyc/document-type');
        final kycPersonalInfo = appRouteContractFor('/kyc/personal-info');
        final kycDocumentCapture = appRouteContractFor('/kyc/document-capture');
        final kycSelfie = appRouteContractFor('/kyc/selfie');
        final kycAddress = appRouteContractFor('/kyc/address');
        final kycVideo = appRouteContractFor('/kyc/video');
        final kycAdditionalDocs = appRouteContractFor('/kyc/additional-docs');
        final kycLivenessInstructions = appRouteContractFor(
          '/kyc/liveness-instructions',
        );
        final kycLiveness = appRouteContractFor('/kyc/liveness');
        final kycReview = appRouteContractFor('/kyc/review');
        final kycSubmitted = appRouteContractFor('/kyc/submitted');
        final kycExpired = appRouteContractFor('/kyc-expired');

        expect(kycStart.role, AppRouteRole.setupStep);
        expect(kycStart.requiresAuth, isTrue);
        expect(kycStart.isSetupRoute, isTrue);
        expect(kycStart.events, contains(AppNavigationEvent.kycStarted));

        expect(kycDocumentType.role, AppRouteRole.setupStep);
        expect(kycDocumentType.isSetupRoute, isTrue);
        expect(kycPersonalInfo.role, AppRouteRole.setupStep);
        expect(kycPersonalInfo.isSetupRoute, isTrue);
        expect(kycDocumentCapture.role, AppRouteRole.setupStep);
        expect(kycDocumentCapture.isSetupRoute, isTrue);

        expect(kycSelfie.role, AppRouteRole.verificationStep);
        expect(kycSelfie.isSetupRoute, isTrue);

        expect(kycAddress.role, AppRouteRole.setupStep);
        expect(kycAddress.isSetupRoute, isTrue);
        expect(kycVideo.role, AppRouteRole.verificationStep);
        expect(kycVideo.isSetupRoute, isTrue);
        expect(kycAdditionalDocs.role, AppRouteRole.setupStep);
        expect(kycAdditionalDocs.isSetupRoute, isTrue);

        expect(kycLivenessInstructions.role, AppRouteRole.verificationStep);
        expect(kycLivenessInstructions.requiresAuth, isTrue);
        expect(kycLivenessInstructions.isSetupRoute, isTrue);

        expect(kycLiveness.role, AppRouteRole.verificationStep);
        expect(kycLiveness.requiresAuth, isTrue);
        expect(kycLiveness.isSetupRoute, isTrue);

        expect(kycReview.role, AppRouteRole.setupStep);
        expect(kycReview.isSetupRoute, isTrue);
        expect(kycSubmitted.role, AppRouteRole.setupStep);
        expect(kycSubmitted.isSetupRoute, isTrue);

        expect(kycExpired.role, AppRouteRole.fsmState);
        expect(kycExpired.isFsmRoute, isTrue);
      },
    );
  });
}
