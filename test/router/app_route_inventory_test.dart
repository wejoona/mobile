import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  ProviderContainer buildContainer() => ProviderContainer(
    overrides: [
      authProvider.overrideWith(_TestAuthNotifier.new),
      appFsmProvider.overrideWith(_TestAppFsmNotifier.new),
      kycStateMachineProvider.overrideWith(_TestKycStateMachine.new),
      userStateMachineProvider.overrideWith(_TestUserStateMachine.new),
      walletStateMachineProvider.overrideWith(_TestWalletStateMachine.new),
      secureStorageProvider.overrideWithValue(MockSecureStorage()),
    ],
  );

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

    test('covers the full signup route sequence explicitly', () {
      final routePaths = _declaredRoutePaths();

      const signupFlow = [
        '/',
        '/onboarding',
        '/signup',
        '/signup/legal-consent',
        '/signup/verify-phone',
        '/signup/profile',
        '/signup/set-pin',
        '/signup/kyc-prompt',
        '/signup/success',
      ];

      expect(routePaths, containsAllInOrder(signupFlow));
    });

    test('keeps legacy onboarding signup route redirects declared', () {
      final routePaths = _declaredRoutePaths();

      const legacySignupPaths = [
        '/onboarding/phone',
        '/onboarding/legal-consent',
        '/onboarding/otp',
        '/onboarding/profile',
        '/onboarding/pin',
        '/onboarding/kyc-prompt',
        '/onboarding/success',
      ];

      expect(routePaths, containsAll(legacySignupPaths));
    });

    test('does not expose legacy PIN route aliases', () {
      final routePaths = _declaredRoutePaths();

      expect(routePaths, contains('/settings/pin'));
      expect(routePaths, contains('/pin/setup'));
      expect(routePaths, isNot(contains('/pin/change')));
      expect(routePaths, isNot(contains('/pin/set')));
    });

    test('legacy transfer success aliases cannot render fake success data', () {
      final source = File(
        'lib/router/routes/card_account_routes.dart',
      ).readAsStringSync();

      expect(source, contains("path: '/transfer/success'"));
      expect(source, contains("path: '/transfer-success'"));
      expect(source, contains("redirect: (_, _) => '/send/result'"));
      expect(source, isNot(contains('TransferSuccessView(')));
      expect(source, isNot(contains("transactionId: 'N/A'")));
      expect(source, isNot(contains("recipient: 'Unknown'")));
    });

    test(
      'production navigation literals resolve through the assembled router',
      () {
        final container = buildContainer();
        addTearDown(container.dispose);

        final router = container.read(routerProvider);
        final failures = <String>[];

        for (final literal in _productionNavigationLiterals()) {
          final samplePath = _sampleNavigationPath(literal.path);
          final match = router.configuration.findMatch(Uri.parse(samplePath));
          if (match.isError) {
            failures.add('${literal.source}: ${literal.path} -> $samplePath');
          }
        }

        expect(
          failures,
          isEmpty,
          reason:
              'Visible navigation calls should not point to missing routes. '
              'Failures are shown as source: literal -> sample path.',
        );
      },
    );
  });
}

List<String> _declaredRoutePaths() {
  final routeSources =
      Directory('lib/router/routes')
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  return routeSources.expand((file) {
    final source = file.readAsStringSync();
    return RegExp(
      r"path:\s*'([^']+)'",
    ).allMatches(source).map((match) => match.group(1)!);
  }).toList();
}

String _sampleConcretePath(String routePath) =>
    routePath.replaceAllMapped(RegExp(':([A-Za-z0-9_]+)'), (match) {
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

List<_NavigationLiteral> _productionNavigationLiterals() {
  final sourceRoot = Directory('lib');
  final files =
      sourceRoot
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => !file.path.contains('/l10n/'))
          .where((file) => !file.path.contains('/mocks/'))
          .where((file) => !file.path.contains('/test_utils/'))
          .where((file) => !file.path.endsWith('/ROUTES.dart'))
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  final literals = <_NavigationLiteral>[];
  for (final file in files) {
    final source = _stripDartComments(file.readAsStringSync());
    final relativePath = file.path.replaceFirst(
      '${Directory.current.path}/',
      '',
    );

    final patterns = [
      RegExp(
        r"(?:context|context\.mounted\s*\?\s*context|Navigator(?:\.of\([^)]*\))?)\.(?:push|go|replace|pushNamed|pushReplacementNamed)\(\s*'([^']+)'",
      ),
      RegExp(
        r"Navigator\.(?:pushNamed|pushReplacementNamed)\([^,]+,\s*'([^']+)'",
      ),
    ];

    for (final pattern in patterns) {
      for (final match in pattern.allMatches(source)) {
        final path = match.group(1)!;
        if (path.startsWith('/')) {
          literals.add(_NavigationLiteral(relativePath, path));
        }
      }
    }
  }

  return literals;
}

String _sampleNavigationPath(String path) {
  final withInterpolations = path
      .replaceAll(RegExp(r'\$\{[^}]+\}'), 'sample-id')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), 'sample-id');
  final uri = Uri.parse(withInterpolations);
  final sampledPath = _sampleConcretePath(uri.path);
  return uri.hasQuery ? '$sampledPath?${uri.query}' : sampledPath;
}

String _stripDartComments(String source) {
  final buffer = StringBuffer();
  var index = 0;
  var inSingle = false;
  var inDouble = false;
  var inLineComment = false;
  var inBlockComment = false;

  while (index < source.length) {
    final char = source[index];
    final next = index + 1 < source.length ? source[index + 1] : '';

    if (inLineComment) {
      if (char == '\n') {
        inLineComment = false;
        buffer.write(char);
      }
      index++;
      continue;
    }

    if (inBlockComment) {
      if (char == '*' && next == '/') {
        inBlockComment = false;
        index += 2;
      } else {
        if (char == '\n') {
          buffer.write(char);
        }
        index++;
      }
      continue;
    }

    if (!inSingle && !inDouble && char == '/' && next == '/') {
      inLineComment = true;
      index += 2;
      continue;
    }

    if (!inSingle && !inDouble && char == '/' && next == '*') {
      inBlockComment = true;
      index += 2;
      continue;
    }

    if (!inDouble && char == "'" && !_isEscaped(source, index)) {
      inSingle = !inSingle;
    } else if (!inSingle && char == '"' && !_isEscaped(source, index)) {
      inDouble = !inDouble;
    }

    buffer.write(char);
    index++;
  }

  return buffer.toString();
}

bool _isEscaped(String source, int index) {
  var slashCount = 0;
  var cursor = index - 1;
  while (cursor >= 0 && source[cursor] == r'\') {
    slashCount++;
    cursor--;
  }
  return slashCount.isOdd;
}

class _NavigationLiteral {
  const _NavigationLiteral(this.source, this.path);

  final String source;
  final String path;
}
