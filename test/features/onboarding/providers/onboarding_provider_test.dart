import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/features/onboarding/providers/onboarding_provider.dart';
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

    test('onboardingProvider marks the same completion key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(onboardingProvider);
      await pumpEventQueue();

      await container.read(onboardingProvider.notifier).completeOnboarding();

      final isComplete = await container.refresh(
        tutorial_onboarding.onboardingCompletedProvider.future,
      );

      expect(isComplete, isTrue);
      expect(container.read(onboardingProvider).isComplete, isTrue);
    });

    test('onboardingProvider reset clears the same completion key', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tutorial_onboarding.completeOnboarding();

      container.read(onboardingProvider);
      await pumpEventQueue();

      await container.read(onboardingProvider.notifier).resetOnboarding();

      final isComplete = await container.refresh(
        tutorial_onboarding.onboardingCompletedProvider.future,
      );

      expect(isComplete, isFalse);
      expect(container.read(onboardingProvider).isComplete, isFalse);
    });
  });
}
