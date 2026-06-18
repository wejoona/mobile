import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart'
    as tutorial_onboarding;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Onboarding completion persistence', () {
    test(
      'tutorial helper writes the key read by onboardingCompletedProvider',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tutorial_onboarding.completeOnboarding();

        final isComplete = await container.read(
          tutorial_onboarding.onboardingCompletedProvider.future,
        );

        expect(isComplete, isTrue);
      },
    );

    test('signupFlowProvider marks the same completion key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(signupFlowProvider);
      await pumpEventQueue();

      await container.read(signupFlowProvider.notifier).completeSignupFlow();

      final isComplete = await container.refresh(
        tutorial_onboarding.onboardingCompletedProvider.future,
      );

      expect(isComplete, isTrue);
      expect(container.read(signupFlowProvider).isComplete, isTrue);
    });

    test('signupFlowProvider reset clears the same completion key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tutorial_onboarding.completeOnboarding();

      container.read(signupFlowProvider);
      await pumpEventQueue();

      await container.read(signupFlowProvider.notifier).resetSignupFlow();

      final isComplete = await container.refresh(
        tutorial_onboarding.onboardingCompletedProvider.future,
      );

      expect(isComplete, isFalse);
      expect(container.read(signupFlowProvider).isComplete, isFalse);
    });
  });
}
