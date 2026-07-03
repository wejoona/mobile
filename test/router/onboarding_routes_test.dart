import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/onboarding/widgets/onboarding_progress.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/state/app_state.dart' hide AuthStatus;
import 'package:usdc_wallet/state/fsm/app_fsm.dart' as app_fsm;
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

import '../helpers/test_theme.dart';
import '../helpers/test_utils.dart';

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _LockedAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.locked);
}

class _AuthenticatedAuthNotifier extends AuthNotifier {
  _AuthenticatedAuthNotifier(this.user);

  final User user;

  @override
  AuthState build() => AuthState(status: AuthStatus.authenticated, user: user);
}

class _TestAppFsmNotifier extends AppFsmNotifier {
  @override
  app_fsm.AppState build() => const app_fsm.AppState.initial();

  @override
  void handleEffects(List<FsmEffect> effects) {}
}

class _FixedSignupFlowNotifier extends SignupFlowNotifier {
  _FixedSignupFlowNotifier(this.initialState);

  final SignupFlowState initialState;

  @override
  SignupFlowState build() => initialState;
}

class _TestKycStateMachine extends KycStateMachine {
  @override
  KycStateMachineState build() => const KycStateMachineState();
}

class _TestUserStateMachine extends UserStateMachine {
  @override
  UserState build() => const UserState();
}

class _TestWalletStateMachine extends WalletStateMachine {
  @override
  WalletState build() => const WalletState();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProviderContainer buildContainer({
    SharedPreferences? sharedPreferences,
    bool locked = false,
    User? authenticatedUser,
    SignupFlowState? signupState,
  }) => ProviderContainer(
    overrides: [
      authProvider.overrideWith(
        locked
            ? _LockedAuthNotifier.new
            : authenticatedUser != null
            ? () => _AuthenticatedAuthNotifier(authenticatedUser)
            : _TestAuthNotifier.new,
      ),
      appFsmProvider.overrideWith(_TestAppFsmNotifier.new),
      kycStateMachineProvider.overrideWith(_TestKycStateMachine.new),
      userStateMachineProvider.overrideWith(_TestUserStateMachine.new),
      walletStateMachineProvider.overrideWith(_TestWalletStateMachine.new),
      signupFlowProvider.overrideWith(
        () => _FixedSignupFlowNotifier(
          signupState ?? const SignupFlowState(isLoading: false),
        ),
      ),
      secureStorageProvider.overrideWithValue(MockSecureStorage()),
      if (sharedPreferences != null)
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
  );

  User testUser({String? firstName, String? lastName, bool hasPin = false}) {
    final now = DateTime.parse('2026-06-20T08:00:00.000Z');
    return User(
      id: 'usr_signup_contract',
      phone: '+2250748805663',
      firstName: firstName,
      lastName: lastName,
      countryCode: 'CI',
      isPhoneVerified: true,
      role: UserRole.user,
      status: UserStatus.active,
      hasPin: hasPin,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('Onboarding routes', () {
    test('registers every explicit signup step path used by the flow', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      const expectedPaths = [
        '/setup/set-pin',
        '/signup',
        '/signup/legal-consent',
        '/legal/terms',
        '/legal/privacy',
        '/signup/verify-phone',
        '/signup/profile',
        '/signup/set-pin',
        '/signup/kyc-prompt',
        '/signup/success',
      ];

      final missingPaths = [
        for (final path in expectedPaths)
          if (router.configuration.findMatch(Uri.parse(path)).isError) path,
      ];

      expect(
        missingPaths,
        isEmpty,
        reason:
            'Every signup step path used by account creation should be registered in GoRouter',
      );
    });

    test('keeps legacy onboarding signup paths as redirects', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      const legacyPaths = [
        '/onboarding/phone',
        '/onboarding/legal-consent',
        '/onboarding/otp',
        '/onboarding/profile',
        '/onboarding/pin',
        '/onboarding/kyc-prompt',
        '/onboarding/success',
      ];

      final missingPaths = [
        for (final path in legacyPaths)
          if (router.configuration.findMatch(Uri.parse(path)).isError) path,
      ];

      expect(
        missingPaths,
        isEmpty,
        reason:
            'Legacy onboarding signup paths should redirect instead of breaking deep links',
      );
    });

    test('keeps the base onboarding route registered', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final match = router.configuration.findMatch(Uri.parse('/onboarding'));

      expect(match.isError, isFalse);
      expect(match.matches.last.route, isA<GoRoute>());
    });

    test('signup step routes render signup-owned screens', () {
      final source = File(
        'lib/router/routes/auth_state_routes.dart',
      ).readAsStringSync();

      expect(source, contains('SignupOtpVerificationView'));
      expect(source, contains('SignupProfileSetupView'));
      expect(source, contains('SignupPinSetupView'));
      expect(source, contains('SignupKycPromptView'));
      expect(source, contains('SignupSuccessView'));
      expect(
        source,
        isNot(contains('features/onboarding/views/otp_verification_view.dart')),
      );
      expect(
        source,
        isNot(contains('features/onboarding/views/profile_setup_view.dart')),
      );
      expect(
        source,
        isNot(contains('features/onboarding/views/onboarding_pin_view.dart')),
      );
      expect(
        source,
        isNot(contains('features/onboarding/views/kyc_prompt_view.dart')),
      );
      expect(
        source,
        isNot(
          contains('features/onboarding/views/onboarding_success_view.dart'),
        ),
      );

      for (final path in [
        'lib/features/signup/views/signup_otp_verification_view.dart',
        'lib/features/signup/views/signup_profile_setup_view.dart',
        'lib/features/signup/views/signup_pin_setup_view.dart',
      ]) {
        final signupSource = File(path).readAsStringSync();
        expect(signupSource, contains('FlowStepProgress'));
        expect(
          signupSource,
          isNot(
            contains('features/onboarding/widgets/onboarding_progress.dart'),
          ),
          reason: '$path should use generic flow progress, not onboarding UI',
        );
      }
    });

    test('signup consent opens legal documents through route contracts', () {
      final consentSource = File(
        'lib/features/signup/views/signup_legal_consent_view.dart',
      ).readAsStringSync();
      final documentSource = File(
        'lib/features/auth/views/legal_document_view.dart',
      ).readAsStringSync();
      final routeSource = File(
        'lib/router/routes/auth_state_routes.dart',
      ).readAsStringSync();

      expect(routeSource, contains("path: '/legal/terms'"));
      expect(routeSource, contains("path: '/legal/privacy'"));
      expect(routeSource, contains("state.uri.queryParameters['returnTo']"));
      expect(consentSource, contains('context.fsmPush<void>('));
      expect(consentSource, contains("'/legal/terms'"));
      expect(consentSource, contains("'/legal/privacy'"));
      expect(consentSource, contains('Uri.encodeComponent'));
      expect(
        consentSource,
        isNot(contains('Navigator.push')),
        reason:
            'Consent documents are screens; opening them must stay inside the FSM route contract.',
      );
      expect(documentSource, contains('context.fsmSafePop'));
      expect(documentSource, contains('_safeFallbackRoute(fallbackRoute)'));
    });

    test('signup KYC handoff completes signup before entering KYC', () {
      final promptSource = File(
        'lib/features/signup/views/signup_kyc_prompt_view.dart',
      ).readAsStringSync();
      final providerSource = File(
        'lib/features/signup/providers/signup_flow_provider.dart',
      ).readAsStringSync();

      expect(providerSource, contains('Future<void> startKyc() async'));
      expect(providerSource, contains('await completeSignupFlow();'));
      expect(
        promptSource,
        contains('await ref.read(signupFlowProvider.notifier).startKyc();'),
      );
      expect(promptSource, contains("context.fsmGo('/kyc/document-type')"));
      expect(
        promptSource,
        isNot(contains("context.fsmPush('/kyc/document-type')")),
        reason:
            'KYC is a setup handoff after signup completion, not a nested signup page.',
      );
    });

    testWidgets('stale signup context off signup routes cannot hijack setup', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      Future<String> initialRouteFor({
        required User user,
        required SignupFlowState signupState,
      }) async {
        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = buildContainer(
          sharedPreferences: sharedPreferences,
          authenticatedUser: user,
          signupState: signupState,
        );
        addTearDown(container.dispose);
        final router = container.read(routerProvider)..go('/home');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: TestTheme.darkTheme,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final path = router.routeInformationProvider.value.uri.path;
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        return path;
      }

      expect(
        await initialRouteFor(
          user: testUser(),
          signupState: const SignupFlowState(
            isLoading: false,
            phoneNumber: '0748805663',
          ),
        ),
        '/profile-complete',
      );

      expect(
        await initialRouteFor(
          user: testUser(firstName: 'Ben', lastName: 'Ouattara'),
          signupState: const SignupFlowState(
            isLoading: false,
            phoneNumber: '0748805663',
            firstName: 'Ben',
            lastName: 'Ouattara',
          ),
        ),
        '/setup/set-pin',
      );

      final staleCompleteSignupRoute = await initialRouteFor(
        user: testUser(firstName: 'Ben', lastName: 'Ouattara', hasPin: true),
        signupState: const SignupFlowState(
          isLoading: false,
          phoneNumber: '0748805663',
          firstName: 'Ben',
          lastName: 'Ouattara',
          pin: '123456',
        ),
      );

      expect(
        staleCompleteSignupRoute,
        isNot('/signup/kyc-prompt'),
        reason:
            'A stale signup provider must not reopen signup KYC after durable user setup is already complete.',
      );
      expect(
        staleCompleteSignupRoute.startsWith('/signup/'),
        isFalse,
        reason:
            'Signup-local form state is only authoritative while the current route is inside signup.',
      );
    });

    test('signup setup state is trusted only while inside signup routes', () {
      final source = File('lib/router/app_redirector.dart').readAsStringSync();
      final setupBody = _methodBody(source, 'String? _nextRequiredSetupRoute');

      expect(
        setupBody,
        contains('final trustSignupSetupState ='),
        reason:
            'Local signup form state must have an explicit trust boundary before it can satisfy setup guards.',
      );
      expect(
        setupBody,
        contains('inSignupRoute && _hasActiveSignupContext(signupState)'),
      );
      expect(
        setupBody,
        contains(
          '(trustSignupSetupState && _hasNonBlank(signupState.firstName))',
        ),
      );
      expect(
        setupBody,
        contains('(trustSignupSetupState && _hasNonBlank(signupState.pin))'),
      );
    });

    test('signup setup redirect runs before auth dead-end cleanup', () {
      final source = File('lib/router/app_redirector.dart').readAsStringSync();
      final setupIndex = source.indexOf(
        'final setupRedirect = _authenticatedSetupRedirect',
      );
      final deadEndIndex = source.indexOf('_isAuthenticatedDeadEndRoute');

      expect(setupIndex, greaterThanOrEqualTo(0));
      expect(deadEndIndex, greaterThanOrEqualTo(0));
      expect(
        setupIndex,
        lessThan(deadEndIndex),
        reason:
            'Signup OTP is an auth dead-end after tokens are issued, but setup/profile/PIN routing must win before generic home cleanup.',
      );
    });

    test('login OTP route survives accepted-code transition to PIN', () {
      final source = File('lib/router/app_redirector.dart').readAsStringSync();
      final otpContextBody = _methodBody(source, 'bool _hasLoginOtpContext');

      expect(source, contains('..listen(loginProvider'));
      expect(otpContextBody, contains('state.currentStep == LoginStep.otp'));
      expect(otpContextBody, contains('state.currentStep == LoginStep.pin'));
      expect(otpContextBody, contains('state.sessionToken?.isNotEmpty'));
    });

    test('KYC submitted route requires durable KYC flow state', () {
      final routeSource = File(
        'lib/router/routes/kyc_settings_routes.dart',
      ).readAsStringSync();
      final providerSource = File(
        'lib/features/kyc/providers/kyc_provider.dart',
      ).readAsStringSync();

      expect(routeSource, contains('redirect: _kycSubmittedRedirect'));
      expect(routeSource, contains('redirect: _kycWizardRedirect'));
      expect(routeSource, contains('_kycDurableStatusRedirect'));
      expect(routeSource, contains('kycStateMachineProvider'));
      expect(routeSource, contains('status.isSubmitted || status.isVerified'));
      expect(routeSource, contains("return currentPath == '/kyc/submitted'"));
      expect(routeSource, contains("return '/kyc/review';"));
      expect(providerSource, contains('_refreshBackendStatusAfterSubmission'));
      expect(
        providerSource,
        contains('service.getKycStatus(forceRefresh: true)'),
      );
      expect(providerSource, contains('updateFromAuthResponse'));
      expect(
        providerSource,
        isNot(contains('verificationStatus: KycStatus.submitted')),
        reason:
            'KYC submit paths must consume backend status so manual_review and in_review are preserved.',
      );
    });

    test('KYC status view does not mutate backend-owned FSM status', () {
      final source = File(
        'lib/features/kyc/views/kyc_status_view.dart',
      ).readAsStringSync();
      final continueBody = _methodBody(source, 'void _handleContinueToHome');

      expect(
        continueBody,
        isNot(contains('onKycStatusLoaded')),
        reason:
            'KYC status is backend-owned; view buttons may navigate but must not downgrade manual_review or verified state.',
      );
      expect(continueBody, contains("context.fsmGo('/home')"));
    });

    test('starts anonymous users on the animated splash before login', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      expect(router.routeInformationProvider.value.uri.path, '/');
    });

    testWidgets(
      'login sign-up link opens signup auth entry without onboarding chrome',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = buildContainer(sharedPreferences: sharedPreferences);
        addTearDown(container.dispose);
        final router = container.read(routerProvider)..go('/login');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: TestTheme.darkTheme,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 700));

        expect(router.routeInformationProvider.value.uri.path, '/login');
        expect(find.textContaining('Welcome back'), findsWidgets);

        await tester.tap(find.text('Sign up'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));

        expect(router.routeInformationProvider.value.uri.path, '/signup');
        expect(find.textContaining('Enter your phone number'), findsWidgets);
        expect(find.byType(Checkbox), findsNothing);
        expect(find.byType(OnboardingProgress), findsNothing);
        expect(find.byTooltip('Back'), findsNothing);
        expect(find.textContaining('Terms of Service'), findsNothing);
        expect(find.textContaining('Privacy Policy'), findsNothing);
      },
    );

    testWidgets(
      'public recovery route is not hijacked while OTP routes need context',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = buildContainer(sharedPreferences: sharedPreferences);
        addTearDown(container.dispose);
        final router = container.read(routerProvider)..go('/pin/reset');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: TestTheme.darkTheme,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(router.routeInformationProvider.value.uri.path, '/pin/reset');
        expect(find.textContaining('Reset Your PIN'), findsWidgets);

        await tester.tap(find.byTooltip('Back'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(router.routeInformationProvider.value.uri.path, '/login');

        router.go('/login/otp');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(router.routeInformationProvider.value.uri.path, '/login');

        router.go('/signup/verify-phone');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(router.routeInformationProvider.value.uri.path, '/signup');

        router.go('/otp');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(router.routeInformationProvider.value.uri.path, '/login');
      },
    );

    testWidgets(
      'signup OTP success advances into signup setup instead of home',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = buildContainer(
          sharedPreferences: sharedPreferences,
          authenticatedUser: testUser(),
          signupState: const SignupFlowState(
            isLoading: false,
            phoneNumber: '0748805663',
            countryCode: 'CI',
            dialCode: '+225',
            otp: '123456',
          ),
        );
        addTearDown(container.dispose);
        final router = container.read(routerProvider)
          ..go('/signup/verify-phone');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: TestTheme.darkTheme,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          router.routeInformationProvider.value.uri.path,
          '/signup/profile',
        );
      },
    );

    testWidgets('locked route guard follows route contract allowWhenLocked', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final container = buildContainer(
        sharedPreferences: sharedPreferences,
        locked: true,
      );
      addTearDown(container.dispose);
      final router = container.read(routerProvider)..go('/pin/enter');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            theme: TestTheme.darkTheme,
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routeInformationProvider.value.uri.path, '/pin/enter');

      router.go('/settings/pin');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routeInformationProvider.value.uri.path, '/session-locked');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['returnTo'],
        '/settings/pin',
      );

      router.go('/home');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routeInformationProvider.value.uri.path, '/session-locked');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['returnTo'],
        '/home',
      );

      router.go('/pay/test-code?source=qr');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(router.routeInformationProvider.value.uri.path, '/session-locked');
      expect(
        router.routeInformationProvider.value.uri.queryParameters['returnTo'],
        '/pay/test-code?source=qr',
      );
    });

    test(
      '/pin/enter cannot enable security behavior from query parameters',
      () {
        final source = File(
          'lib/router/routes/card_account_routes.dart',
        ).readAsStringSync();

        expect(source, contains('EnterPinRouteContext'));
        expect(source, isNot(contains("query['biometric']")));
        expect(source, isNot(contains("query['title']")));
        expect(source, isNot(contains("query['subtitle']")));
      },
    );
  });
}

String _methodBody(String source, String methodName) {
  final signatureIndex = source.indexOf(methodName);
  expect(signatureIndex, greaterThanOrEqualTo(0));

  var bodyStart = -1;
  var parenDepth = 0;
  var sawOpenParen = false;
  for (var index = signatureIndex; index < source.length; index += 1) {
    final char = source[index];
    if (char == '(') {
      parenDepth += 1;
      sawOpenParen = true;
    } else if (char == ')' && sawOpenParen) {
      parenDepth -= 1;
    } else if (char == '{' && (!sawOpenParen || parenDepth == 0)) {
      bodyStart = index;
      break;
    }
  }
  expect(bodyStart, greaterThanOrEqualTo(0));

  var depth = 0;
  for (var index = bodyStart; index < source.length; index += 1) {
    if (source[index] == '{') {
      depth += 1;
    } else if (source[index] == '}') {
      depth -= 1;
      if (depth == 0) {
        return source.substring(bodyStart, index + 1);
      }
    }
  }

  throw StateError('Could not read body for $methodName');
}
