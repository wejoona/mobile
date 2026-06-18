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
