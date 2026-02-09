// Golden tests for additional Settings screens
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/views/profile_view.dart';
import 'package:usdc_wallet/features/settings/views/profile_edit_screen.dart';
import 'package:usdc_wallet/features/settings/views/security_view.dart';
import 'package:usdc_wallet/features/settings/views/devices_screen.dart';
import 'package:usdc_wallet/features/settings/views/sessions_screen.dart';
import 'package:usdc_wallet/features/settings/views/language_view.dart';
import 'package:usdc_wallet/features/settings/views/currency_view.dart';
import 'package:usdc_wallet/features/settings/views/theme_settings_view.dart';
import 'package:usdc_wallet/features/settings/views/notification_settings_view.dart';
import 'package:usdc_wallet/features/settings/views/help_view.dart';
import 'package:usdc_wallet/features/settings/views/kyc_view.dart';
import 'package:usdc_wallet/features/settings/views/limits_view.dart';

import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await GoldenTestUtils.init();
  });

  group('ProfileView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ProfileView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/profile_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ProfileView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/profile_view/default_dark.png'),
      );
    });
  });

  group('ProfileEditScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ProfileEditScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/profile_edit/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ProfileEditScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/profile_edit/default_dark.png'),
      );
    });
  });

  group('SecurityView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: SecurityView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/security_view/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: SecurityView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/security_view/default_dark.png'),
      );
    });
  });

  group('DevicesScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: DevicesScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/devices/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: DevicesScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/devices/default_dark.png'),
      );
    });
  });

  group('SessionsScreen Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: SessionsScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/sessions/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: SessionsScreen(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/sessions/default_dark.png'),
      );
    });
  });

  group('LanguageView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: LanguageView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/language/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: LanguageView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/language/default_dark.png'),
      );
    });
  });

  group('CurrencyView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: CurrencyView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/currency/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: CurrencyView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/currency/default_dark.png'),
      );
    });
  });

  group('ThemeSettingsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: ThemeSettingsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/theme/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: ThemeSettingsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/theme/default_dark.png'),
      );
    });
  });

  group('NotificationSettingsView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: NotificationSettingsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/notifications/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: NotificationSettingsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/notifications/default_dark.png'),
      );
    });
  });

  group('HelpView Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: HelpView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/help/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: HelpView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/help/default_dark.png'),
      );
    });
  });

  group('KycView (Settings) Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: KycView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/kyc/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: KycView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/kyc/default_dark.png'),
      );
    });
  });

  group('LimitsView (Settings) Golden Tests', () {
    testWidgets('light mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: false,
          child: LimitsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/limits/default_light.png'),
      );
    });

    testWidgets('dark mode', (tester) async {
      await tester.binding.setSurfaceSize(GoldenTestConfig.defaultSize);
      await pumpGoldenTolerant(
        tester,
        GoldenTestWrapper(
          isDarkMode: true,
          child: LimitsView(),
        ),
        pumpDuration: const Duration(milliseconds: 100),
      );

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/settings/limits/default_dark.png'),
      );
    });
  });
}
