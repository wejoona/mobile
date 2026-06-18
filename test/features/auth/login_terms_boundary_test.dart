import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/views/login_view.dart';
import 'package:usdc_wallet/features/onboarding/views/phone_input_view.dart';
import 'package:usdc_wallet/features/onboarding/widgets/onboarding_progress.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import '../../helpers/test_utils.dart';
import '../../helpers/test_wrapper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final contract in _authEntryChromeContracts) {
    testWidgets('${contract.route} obeys auth-entry chrome contract', (
      tester,
    ) async {
      await _usePhoneViewport(tester);

      await tester.pumpWidget(
        TestWrapper(
          overrides: [
            secureStorageProvider.overrideWithValue(MockSecureStorage()),
          ],
          child: contract.child,
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      for (final type in _authEntryForbiddenTypes) {
        expect(
          find.byType(type),
          findsNothing,
          reason: '${contract.route} must not render $type',
        );
      }

      for (final tooltip in contract.forbiddenTooltips) {
        expect(
          find.byTooltip(tooltip),
          findsNothing,
          reason: '${contract.route} must not expose $tooltip chrome',
        );
      }

      for (final text in _authEntryForbiddenTextFragments) {
        expect(
          find.textContaining(text),
          findsNothing,
          reason: '${contract.route} must not render "$text"',
        );
      }

      for (final text in contract.requiredTextFragments) {
        expect(
          find.textContaining(text),
          findsWidgets,
          reason: '${contract.route} should clearly identify its role',
        );
      }
    });
  }

  testWidgets('login phone screen does not ask for terms acceptance', (
    tester,
  ) async {
    await _usePhoneViewport(tester);

    await tester.pumpWidget(
      TestWrapper(
        overrides: [
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
        child: const LoginView(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(Checkbox), findsNothing);
    expect(find.textContaining('Terms of Service'), findsNothing);
    expect(find.textContaining('Privacy Policy'), findsNothing);
    expect(find.textContaining('agree'), findsNothing);
  });

  testWidgets('signup phone entry defers legal consent to a dedicated step', (
    tester,
  ) async {
    await _usePhoneViewport(tester);

    await tester.pumpWidget(
      TestWrapper(
        overrides: [
          secureStorageProvider.overrideWithValue(MockSecureStorage()),
        ],
        child: const PhoneInputView(),
      ),
    );

    await tester.pump();

    expect(find.byType(Checkbox), findsNothing);
    expect(find.byType(OnboardingProgress), findsNothing);
    expect(find.byTooltip('Back'), findsNothing);
    expect(find.textContaining('Terms of Service'), findsNothing);
    expect(find.textContaining('Privacy Policy'), findsNothing);
  });
}

Future<void> _usePhoneViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

const _authEntryChromeContracts = [
  _RouteChromeContract(
    route: '/login',
    child: LoginView(),
    requiredTextFragments: ['Welcome back', 'Sign up'],
  ),
  _RouteChromeContract(
    route: '/signup',
    child: PhoneInputView(),
    requiredTextFragments: ['Enter your phone number', 'Login'],
    forbiddenTooltips: ['Back'],
  ),
];

const _authEntryForbiddenTypes = [Checkbox, OnboardingProgress];

const _authEntryForbiddenTextFragments = [
  'Terms of Service',
  'Privacy Policy',
  'agree',
];

class _RouteChromeContract {
  const _RouteChromeContract({
    required this.route,
    required this.child,
    required this.requiredTextFragments,
    this.forbiddenTooltips = const [],
  });

  final String route;
  final Widget child;
  final List<String> forbiddenTooltips;
  final List<String> requiredTextFragments;
}
