/// Canonical route and navigation-event contracts for the app FSM.
///
/// Screens should emit domain events; the FSM and route contracts decide which
/// paths are valid from the resulting state. Keep route classification here so
/// router redirects, FSM guards, and tests do not drift into separate truths.
enum AppRouteRole {
  splash,
  introduction,
  authEntry,
  consentStep,
  verificationStep,
  setupStep,
  authenticatedShell,
  moneyStep,
  securityStep,
  securityRecovery,
  publicDeepLink,
  fsmState,
  settingsStep,
  unknown,
}

enum AppRouteCapability {
  publicEntry,
  explicitPublic,
  fsmOwned,
  authDeadEnd,
  signupFlow,
  legacySignupFlow,
  setupFlow,
  securityRecovery,
  allowWhenLocked,
  requiresAuth,
  requiresWallet,
  requiresKycTier1,
  requiresKycTier2,
  requiresVerifiedKyc,
  moneyMovement,
}

/// User/product events that should eventually be dispatched instead of direct
/// navigation calls from screens.
enum AppNavigationEvent {
  appLaunched,
  introductionStarted,
  loginSelected,
  signupSelected,
  consentAccepted,
  phoneSubmitted,
  otpRequested,
  otpSubmitted,
  otpVerified,
  pinRequired,
  pinAccepted,
  forgotPinSelected,
  recoveryOtpRequested,
  recoveryOtpSubmitted,
  recoveryRiskEvaluated,
  recoveryLivenessRequired,
  recoveryManualReviewRequired,
  recoveryPinSubmitted,
  recoveryCompleted,
  sessionLocked,
  sessionUnlocked,
  logoutRequested,
  profileRequired,
  kycStarted,
  moneyFlowStarted,
  moneyQuoteRequested,
  moneySubmitted,
  moneyCompleted,
  routeBlocked,
  legalDocumentOpened,
}

class AppRouteContract {
  const AppRouteContract({
    required this.pattern,
    required this.role,
    this.prefix = false,
    this.capabilities = const {},
    this.canonicalRoute,
    this.events = const {},
  });

  final String pattern;
  final bool prefix;
  final AppRouteRole role;
  final Set<AppRouteCapability> capabilities;
  final String? canonicalRoute;
  final Set<AppNavigationEvent> events;

  bool matches(String route) =>
      prefix ? route.startsWith(pattern) : route == pattern;

  bool get isPublic => capabilities.contains(AppRouteCapability.publicEntry);
  bool get isExplicitPublic =>
      capabilities.contains(AppRouteCapability.explicitPublic);
  bool get isFsmRoute => capabilities.contains(AppRouteCapability.fsmOwned);
  bool get isAuthDeadEnd =>
      capabilities.contains(AppRouteCapability.authDeadEnd);
  bool get isSignupRoute =>
      capabilities.contains(AppRouteCapability.signupFlow);
  bool get isLegacySignupRoute =>
      capabilities.contains(AppRouteCapability.legacySignupFlow);
  bool get isSetupRoute => capabilities.contains(AppRouteCapability.setupFlow);
  bool get isSecurityRecovery =>
      capabilities.contains(AppRouteCapability.securityRecovery);
  bool get isAllowedWhenLocked =>
      capabilities.contains(AppRouteCapability.allowWhenLocked);
  bool get requiresAuth =>
      capabilities.contains(AppRouteCapability.requiresAuth);
  bool get requiresWallet =>
      capabilities.contains(AppRouteCapability.requiresWallet);
  bool get requiresKycTier1 =>
      capabilities.contains(AppRouteCapability.requiresKycTier1);
  bool get requiresKycTier2 =>
      capabilities.contains(AppRouteCapability.requiresKycTier2);
  bool get requiresVerifiedKyc =>
      capabilities.contains(AppRouteCapability.requiresVerifiedKyc);
}

const _authEntryEvents = {
  AppNavigationEvent.loginSelected,
  AppNavigationEvent.phoneSubmitted,
  AppNavigationEvent.otpRequested,
};

const _signupEvents = {
  AppNavigationEvent.signupSelected,
  AppNavigationEvent.phoneSubmitted,
  AppNavigationEvent.consentAccepted,
  AppNavigationEvent.legalDocumentOpened,
  AppNavigationEvent.otpSubmitted,
  AppNavigationEvent.profileRequired,
  AppNavigationEvent.kycStarted,
};

const _recoveryEvents = {
  AppNavigationEvent.forgotPinSelected,
  AppNavigationEvent.recoveryOtpRequested,
  AppNavigationEvent.recoveryOtpSubmitted,
  AppNavigationEvent.recoveryRiskEvaluated,
  AppNavigationEvent.recoveryLivenessRequired,
  AppNavigationEvent.recoveryManualReviewRequired,
  AppNavigationEvent.recoveryPinSubmitted,
  AppNavigationEvent.recoveryCompleted,
};

const _moneyEvents = {
  AppNavigationEvent.moneyFlowStarted,
  AppNavigationEvent.moneyQuoteRequested,
  AppNavigationEvent.moneySubmitted,
  AppNavigationEvent.moneyCompleted,
};

const appRouteContracts = <AppRouteContract>[
  AppRouteContract(
    pattern: '/',
    role: AppRouteRole.splash,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
    },
    events: {AppNavigationEvent.appLaunched},
  ),
  AppRouteContract(
    pattern: '/onboarding',
    role: AppRouteRole.introduction,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {AppNavigationEvent.introductionStarted},
  ),
  AppRouteContract(
    pattern: '/login',
    role: AppRouteRole.authEntry,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: _authEntryEvents,
  ),
  AppRouteContract(
    pattern: '/login/otp',
    role: AppRouteRole.verificationStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {
      AppNavigationEvent.otpSubmitted,
      AppNavigationEvent.otpVerified,
      AppNavigationEvent.pinRequired,
    },
  ),
  AppRouteContract(
    pattern: '/login/pin',
    role: AppRouteRole.securityStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {
      AppNavigationEvent.pinRequired,
      AppNavigationEvent.pinAccepted,
      AppNavigationEvent.forgotPinSelected,
    },
  ),
  AppRouteContract(
    pattern: '/otp',
    role: AppRouteRole.verificationStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {
      AppNavigationEvent.otpSubmitted,
      AppNavigationEvent.otpVerified,
      AppNavigationEvent.pinRequired,
    },
  ),
  AppRouteContract(
    pattern: '/signup',
    role: AppRouteRole.authEntry,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.signupFlow,
      AppRouteCapability.authDeadEnd,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/signup/legal-consent',
    role: AppRouteRole.consentStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.signupFlow,
      AppRouteCapability.authDeadEnd,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/legal/terms',
    role: AppRouteRole.consentStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {AppNavigationEvent.legalDocumentOpened},
  ),
  AppRouteContract(
    pattern: '/legal/privacy',
    role: AppRouteRole.consentStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.authDeadEnd,
    },
    events: {AppNavigationEvent.legalDocumentOpened},
  ),
  AppRouteContract(
    pattern: '/signup/verify-phone',
    role: AppRouteRole.verificationStep,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.signupFlow,
      AppRouteCapability.authDeadEnd,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/signup/profile',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.signupFlow,
      AppRouteCapability.setupFlow,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/signup/set-pin',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.signupFlow,
      AppRouteCapability.setupFlow,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/signup/kyc-prompt',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.signupFlow,
      AppRouteCapability.setupFlow,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/signup/success',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.signupFlow,
      AppRouteCapability.setupFlow,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/onboarding/',
    role: AppRouteRole.setupStep,
    prefix: true,
    canonicalRoute: '/signup',
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
      AppRouteCapability.signupFlow,
      AppRouteCapability.legacySignupFlow,
      AppRouteCapability.authDeadEnd,
    },
    events: _signupEvents,
  ),
  AppRouteContract(
    pattern: '/pin/reset',
    role: AppRouteRole.securityRecovery,
    prefix: true,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.securityRecovery,
      AppRouteCapability.allowWhenLocked,
    },
    events: _recoveryEvents,
  ),
  AppRouteContract(
    pattern: '/session-locked',
    role: AppRouteRole.securityStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.fsmOwned,
      AppRouteCapability.allowWhenLocked,
    },
    events: {
      AppNavigationEvent.sessionLocked,
      AppNavigationEvent.sessionUnlocked,
      AppNavigationEvent.forgotPinSelected,
    },
  ),
  AppRouteContract(
    pattern: '/pay/',
    role: AppRouteRole.publicDeepLink,
    prefix: true,
    capabilities: {
      AppRouteCapability.publicEntry,
      AppRouteCapability.explicitPublic,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/force-update',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.publicEntry, AppRouteCapability.fsmOwned},
    events: {AppNavigationEvent.routeBlocked},
  ),
  AppRouteContract(
    pattern: '/otp-expired',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/auth-locked',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/auth-suspended',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/biometric-prompt',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/device-verification',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/session-conflict',
    role: AppRouteRole.fsmState,
    capabilities: {AppRouteCapability.fsmOwned},
  ),
  AppRouteContract(
    pattern: '/wallet-frozen',
    role: AppRouteRole.fsmState,
    capabilities: {
      AppRouteCapability.fsmOwned,
      AppRouteCapability.requiresAuth,
    },
  ),
  AppRouteContract(
    pattern: '/wallet-under-review',
    role: AppRouteRole.fsmState,
    capabilities: {
      AppRouteCapability.fsmOwned,
      AppRouteCapability.requiresAuth,
    },
  ),
  AppRouteContract(
    pattern: '/kyc-expired',
    role: AppRouteRole.fsmState,
    capabilities: {
      AppRouteCapability.fsmOwned,
      AppRouteCapability.requiresAuth,
    },
  ),
  AppRouteContract(
    pattern: '/loading',
    role: AppRouteRole.fsmState,
    capabilities: {
      AppRouteCapability.fsmOwned,
      AppRouteCapability.requiresAuth,
    },
  ),
  AppRouteContract(
    pattern: '/create-wallet',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.fsmOwned,
      AppRouteCapability.requiresAuth,
    },
  ),
  AppRouteContract(
    pattern: '/profile-complete',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.profileRequired},
  ),
  AppRouteContract(
    pattern: '/settings/profile',
    role: AppRouteRole.settingsStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
  ),
  AppRouteContract(
    pattern: '/settings/pin',
    role: AppRouteRole.settingsStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.allowWhenLocked,
    },
    events: {
      AppNavigationEvent.pinRequired,
      AppNavigationEvent.forgotPinSelected,
    },
  ),
  AppRouteContract(
    pattern: '/pin/setup',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.pinRequired, AppNavigationEvent.pinAccepted},
  ),
  AppRouteContract(
    pattern: '/kyc',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.kycStarted},
  ),
  AppRouteContract(
    pattern: '/kyc/',
    role: AppRouteRole.setupStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.kycStarted},
  ),
  AppRouteContract(
    pattern: '/settings/kyc',
    role: AppRouteRole.settingsStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.kycStarted},
  ),
  AppRouteContract(
    pattern: '/pin/confirm',
    role: AppRouteRole.setupStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.setupFlow,
    },
    events: {AppNavigationEvent.pinRequired, AppNavigationEvent.pinAccepted},
  ),
  AppRouteContract(
    pattern: '/pin/enter',
    role: AppRouteRole.securityStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.allowWhenLocked,
    },
    events: {
      AppNavigationEvent.pinRequired,
      AppNavigationEvent.pinAccepted,
      AppNavigationEvent.forgotPinSelected,
    },
  ),
  AppRouteContract(
    pattern: '/pin/locked',
    role: AppRouteRole.securityStep,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.allowWhenLocked,
    },
    events: {
      AppNavigationEvent.pinRequired,
      AppNavigationEvent.routeBlocked,
      AppNavigationEvent.forgotPinSelected,
    },
  ),
  AppRouteContract(
    pattern: '/home',
    role: AppRouteRole.authenticatedShell,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
    },
  ),
  AppRouteContract(
    pattern: '/cards/request',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.requiresVerifiedKyc,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/cards',
    role: AppRouteRole.authenticatedShell,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
    },
  ),
  AppRouteContract(
    pattern: '/transactions',
    role: AppRouteRole.authenticatedShell,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
    },
  ),
  AppRouteContract(
    pattern: '/settings',
    role: AppRouteRole.authenticatedShell,
    prefix: true,
    capabilities: {AppRouteCapability.requiresAuth},
  ),
  AppRouteContract(
    pattern: '/send-external',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.requiresVerifiedKyc,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/send',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/receive',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/deposit',
    role: AppRouteRole.moneyStep,
    prefix: true,
    canonicalRoute: '/deposit/amount',
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/withdraw',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.requiresKycTier1,
      AppRouteCapability.requiresVerifiedKyc,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/bulk-payments',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.requiresVerifiedKyc,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
  AppRouteContract(
    pattern: '/payment-links/create',
    role: AppRouteRole.moneyStep,
    prefix: true,
    capabilities: {
      AppRouteCapability.requiresAuth,
      AppRouteCapability.requiresWallet,
      AppRouteCapability.requiresVerifiedKyc,
      AppRouteCapability.moneyMovement,
    },
    events: _moneyEvents,
  ),
];

const unknownAppRouteContract = AppRouteContract(
  pattern: '*',
  role: AppRouteRole.unknown,
  capabilities: {AppRouteCapability.requiresAuth},
);

AppRouteContract appRouteContractFor(String route) {
  for (final contract in appRouteContracts) {
    if (contract.matches(route)) {
      return contract;
    }
  }
  return unknownAppRouteContract;
}

bool isPublicAppRoute(String route) => appRouteContractFor(route).isPublic;

bool isExplicitPublicAppRoute(String route) =>
    appRouteContractFor(route).isExplicitPublic;

bool isSecurityRecoveryAppRoute(String route) =>
    appRouteContractFor(route).isSecurityRecovery;

bool isFsmOwnedAppRoute(String route) => appRouteContractFor(route).isFsmRoute;

bool isSignupAppRoute(String route) => appRouteContractFor(route).isSignupRoute;

bool isLegacySignupAppRoute(String route) =>
    appRouteContractFor(route).isLegacySignupRoute;

bool isSetupAppRoute(String route) => appRouteContractFor(route).isSetupRoute;

bool isAuthDeadEndAppRoute(String route) =>
    appRouteContractFor(route).isAuthDeadEnd;

bool requiresVerifiedKycAppRoute(String route) =>
    appRouteContractFor(route).requiresVerifiedKyc;
