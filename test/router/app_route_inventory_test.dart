import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/state/app_state.dart' hide AuthStatus;
import 'package:usdc_wallet/state/fsm/app_fsm.dart' as app_fsm;
import 'package:usdc_wallet/state/fsm/fsm_base.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';

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
      ],
    );
  }

  group('App route inventory', () {
    test('every GoRoute path declared in router modules is matchable', () {
      final container = buildContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      final routePaths = _declaredRoutePaths();

      expect(routePaths, hasLength(greaterThanOrEqualTo(140)));
      expect(
        routePaths.toSet(),
        hasLength(routePaths.length),
        reason: 'GoRoute paths should be unique',
      );

      final failures = <String>[];
      for (final routePath in routePaths) {
        final samplePath = _sampleConcretePath(routePath);
        final match = router.configuration.findMatch(Uri.parse(samplePath));
        if (match.isError) {
          failures.add('$routePath -> $samplePath');
        }
      }

      expect(
        failures,
        isEmpty,
        reason:
            'Every route path declared in router modules should resolve through GoRouter. '
            'Failures are shown as pattern -> sample path.',
      );
    });

    test('covers the full onboarding route sequence explicitly', () {
      final routePaths = _declaredRoutePaths();

      const onboardingFlow = [
        '/',
        '/onboarding',
        '/onboarding/phone',
        '/onboarding/otp',
        '/onboarding/profile',
        '/onboarding/pin',
        '/onboarding/kyc-prompt',
        '/onboarding/success',
      ];

      expect(routePaths, containsAllInOrder(onboardingFlow));
    });
  });
}

List<String> _declaredRoutePaths() {
  final routeSources = Directory('lib/router/routes')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((left, right) => left.path.compareTo(right.path));

  return routeSources
      .expand((file) {
        final source = file.readAsStringSync();
        return RegExp(
          r"path:\s*'([^']+)'",
        ).allMatches(source).map((match) => match.group(1)!);
      })
      .toList();
}

String _sampleConcretePath(String routePath) {
  return routePath.replaceAllMapped(RegExp(r':([A-Za-z0-9_]+)'), (match) {
    final name = match.group(1)!;
    return switch (name) {
      'accountId' => 'bank-account-123',
      'batchId' => 'batch-123',
      'code' => 'KORIDO123',
      'paymentId' => 'payment-123',
      'providerId' => 'orange-money',
      _ => 'sample-id',
    };
  });
}
