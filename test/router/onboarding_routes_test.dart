import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/onboarding/widgets/onboarding_progress.dart';
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

import '../helpers/test_utils.dart';
import '../helpers/test_theme.dart';

class _TestAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthState(status: AuthStatus.unauthenticated);
}

class _TestAppFsmNotifier extends AppFsmNotifier {
  @override
  app_fsm.AppState build() => const app_fsm.AppState.initial();

  @override
  void handleEffects(List<FsmEffect> effects) {}
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

  ProviderContainer buildContainer({SharedPreferences? sharedPreferences}) =>
      ProviderContainer(
        overrides: [
          authProvider.overrideWith(_TestAuthNotifier.new),
          appFsmProvider.overrideWith(_TestAppFsmNotifier.new),
          kycStateMachineProvider.overrideWith(_TestKycStateMachine.new),
          userStateMachineProvider.overrideWith(_TestUserStateMachine.new),
          walletStateMachineProvider.overrideWith(_TestWalletStateMachine.new),
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
          if (sharedPreferences != null)
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

  group('Onboarding routes', () {
    test('registers every explicit signup step path used by the flow', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      const expectedPaths = [
        '/signup',
        '/signup/legal-consent',
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
        isNot(contains("features/onboarding/views/otp_verification_view.dart")),
      );
      expect(
        source,
        isNot(contains("features/onboarding/views/profile_setup_view.dart")),
      );
      expect(
        source,
        isNot(contains("features/onboarding/views/onboarding_pin_view.dart")),
      );
      expect(
        source,
        isNot(contains("features/onboarding/views/kyc_prompt_view.dart")),
      );
      expect(
        source,
        isNot(
          contains("features/onboarding/views/onboarding_success_view.dart"),
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
            contains("features/onboarding/widgets/onboarding_progress.dart"),
          ),
          reason: '$path should use generic flow progress, not onboarding UI',
        );
      }
    });

    test('starts anonymous users on login instead of registration', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      expect(router.routeInformationProvider.value.uri.path, '/login');
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
        final router = container.read(routerProvider);

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
      'public recovery and verification routes are not hijacked by login FSM',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(430, 932));
        addTearDown(() => tester.binding.setSurfaceSize(null));

        SharedPreferences.setMockInitialValues({});
        final sharedPreferences = await SharedPreferences.getInstance();
        final container = buildContainer(sharedPreferences: sharedPreferences);
        addTearDown(container.dispose);
        final router = container.read(routerProvider);

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
        router.go('/pin/reset');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(router.routeInformationProvider.value.uri.path, '/pin/reset');
        expect(find.textContaining('Reset Your PIN'), findsWidgets);

        router.go('/otp');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(router.routeInformationProvider.value.uri.path, '/otp');
      },
    );
  });
}
