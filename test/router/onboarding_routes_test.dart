import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/state/app_state.dart' hide AuthStatus;
import 'package:usdc_wallet/state/fsm/app_fsm.dart' as app_fsm;
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

import '../helpers/test_utils.dart';

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

  ProviderContainer buildContainer() {
    return ProviderContainer(
      overrides: [
        authProvider.overrideWith(_TestAuthNotifier.new),
        appFsmProvider.overrideWith(_TestAppFsmNotifier.new),
        kycStateMachineProvider.overrideWith(_TestKycStateMachine.new),
        userStateMachineProvider.overrideWith(_TestUserStateMachine.new),
        walletStateMachineProvider.overrideWith(_TestWalletStateMachine.new),
        secureStorageProvider.overrideWithValue(MockSecureStorage()),
      ],
    );
  }

  group('Onboarding routes', () {
    test('registers every onboarding step path used by the flow', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      const expectedPaths = [
        '/onboarding/phone',
        '/onboarding/otp',
        '/onboarding/profile',
        '/onboarding/pin',
        '/onboarding/kyc-prompt',
        '/onboarding/success',
      ];

      final missingPaths = [
        for (final path in expectedPaths)
          if (router.configuration.findMatch(Uri.parse(path)).isError) path,
      ];

      expect(
        missingPaths,
        isEmpty,
        reason:
            'Every onboarding step path used by the flow should be registered in GoRouter',
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

    test('starts anonymous users on login instead of registration', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);

      expect(router.routeInformationProvider.value.uri.path, '/login');
    });
  });
}
