import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/fsm_states/views/force_update_view.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';

import '../../helpers/test_wrapper.dart';

class _ForcedUpgradeVersionPolicyController
    extends MobileVersionPolicyController {
  @override
  MobileVersionPolicyState build() => MobileVersionPolicyState(
    policy: MobileVersionPolicy(
      platform: 'ios',
      currentVersion: '1.0.0',
      currentBuildNumber: '8',
      latestVersion: '2.0.0',
      minimumSupportedVersion: '1.2.0',
      latestBuildNumber: '120',
      minimumSupportedBuildNumber: '40',
      forceUpgrade: true,
      upgradeRecommended: true,
      breakingApiChange: true,
      message: 'Please update Korido to continue.',
      apiUrl: 'https://staging-korido-api.joonapay.com/api/v1',
      checkedAt: DateTime.utc(2026, 6, 17),
    ),
  );

  @override
  Future<MobileVersionPolicy?> check({
    String reason = 'startup',
    bool force = false,
  }) async => state.policy;
}

void main() {
  testWidgets('force update copy shows the minimum required version', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestWrapper(
        overrides: [
          mobileVersionPolicyProvider.overrideWith(
            _ForcedUpgradeVersionPolicyController.new,
          ),
        ],
        child: const ForceUpdateView(),
      ),
    );

    expect(find.text('Mise à jour requise'), findsOneWidget);
    expect(find.text('Please update Korido to continue.'), findsOneWidget);
    expect(find.text('Version requise: 1.2.0'), findsOneWidget);
    expect(find.text('Version requise: 2.0.0'), findsNothing);
  });
}
