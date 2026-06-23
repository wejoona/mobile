import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/core/constants/preference_keys.dart';
import 'package:usdc_wallet/features/onboarding/views/onboarding_view.dart'
    as tutorial_onboarding;
import 'package:usdc_wallet/features/signup/providers/signup_flow_provider.dart';

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

    test(
      'signupFlowProvider marks only the signup setup completion key',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(signupFlowProvider);
        await pumpEventQueue();

        await container.read(signupFlowProvider.notifier).completeSignupFlow();

        final introComplete = await container.refresh(
          tutorial_onboarding.onboardingCompletedProvider.future,
        );
        final prefs = await SharedPreferences.getInstance();

        expect(introComplete, isFalse);
        expect(prefs.getBool(PreferenceKeys.signupSetupCompleted), isTrue);
        expect(prefs.getBool(PreferenceKeys.productIntroCompleted), isNull);
        expect(container.read(signupFlowProvider).isComplete, isTrue);
      },
    );

    test(
      'signupFlowProvider reset does not clear product intro completion',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        await tutorial_onboarding.completeOnboarding();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(PreferenceKeys.signupSetupCompleted, true);

        container.read(signupFlowProvider);
        await pumpEventQueue();

        await container.read(signupFlowProvider.notifier).resetSignupFlow();

        final introComplete = await container.refresh(
          tutorial_onboarding.onboardingCompletedProvider.future,
        );

        expect(introComplete, isTrue);
        expect(prefs.getBool(PreferenceKeys.signupSetupCompleted), isNull);
        expect(container.read(signupFlowProvider).isComplete, isFalse);
      },
    );

    test(
      'product intro completion does not imply signup setup completion',
      () async {
        await tutorial_onboarding.completeOnboarding();

        final container = ProviderContainer();
        addTearDown(container.dispose);

        container.read(signupFlowProvider);
        await pumpEventQueue();

        expect(container.read(signupFlowProvider).isComplete, isFalse);
      },
    );
  });
}
