import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.clearPersistentState();
  });

  testWidgets('taps through live API navigation and safe controls', (
    tester,
  ) async {
    final driver = KoridoFlowDriver(tester);
    final phone = _uniqueIvorianPhone();

    await driver.launchApp();
    await driver.startRegistrationFromIntro();
    await driver.submitPhone(phone);
    await driver.enterOtp(await _resolveOtp(phone));

    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
      reason: 'profile setup screen',
      timeout: const Duration(seconds: 25),
    );
    await driver.submitProfile();

    await driver.pumpUntil(
      () => driver.hasAnyText(['Create your PIN', 'Créez votre PIN']),
      reason: 'PIN setup screen',
      timeout: const Duration(seconds: 25),
    );
    await driver.enterPinTwice(KoridoFlowDriver.defaultPin);

    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Verify your identity',
        'Vérifiez votre identité',
      ]),
      reason: 'KYC prompt screen',
      timeout: const Duration(seconds: 25),
    );
    await driver.tapText(['Maybe Later', 'Peut-être plus tard']);

    await driver.pumpUntil(
      () => driver.hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
      reason: 'onboarding success screen',
      timeout: const Duration(seconds: 25),
    );
    await driver.tapText(['Start Using Korido', 'Commencer à utiliser Korido']);
    await driver.waitForHome();

    await _assertHealthy(driver, tester, 'home after onboarding');
    await driver.pullToRefreshHome();
    await _assertHealthy(driver, tester, 'home pull-to-refresh');

    await _openHomeAction(
      driver,
      tester,
      labels: ['Send', 'Envoyer'],
      expected: ['Select Recipient', 'Sélectionner le destinataire'],
      name: 'home send action',
    );
    await _openHomeAction(
      driver,
      tester,
      labels: ['Deposit', 'Dépôt'],
      expected: ['Deposit Funds', 'Déposer des fonds'],
      name: 'home deposit action',
    );
    await _openHomeAction(
      driver,
      tester,
      labels: ['Receive', 'Recevoir'],
      expected: ['Receive', 'Recevoir'],
      name: 'home receive action',
    );

    await _openBottomTab(
      driver,
      tester,
      labels: ['Cards', 'Cartes'],
      expected: ['My Cards', 'Mes cartes', 'Cards', 'Cartes'],
      name: 'cards tab',
    );
    await _openBottomTab(
      driver,
      tester,
      labels: ['History', 'Historique'],
      expected: ['Transactions'],
      name: 'history tab',
    );
    await _tapTransactionsFilterIfPresent(driver, tester);
    await _openBottomTab(
      driver,
      tester,
      labels: ['Settings', 'Paramètres'],
      expected: ['Settings', 'Paramètres'],
      name: 'settings tab',
    );

    await _openSettingsRow(
      driver,
      tester,
      labels: ['Profile', 'Profil'],
      expected: ['Profile', 'Profil'],
      name: 'settings profile row',
    );
    await _openSettingsRow(
      driver,
      tester,
      labels: ['Security', 'Sécurité'],
      expected: ['Security', 'Sécurité'],
      name: 'settings security row',
    );
    await _openSettingsRow(
      driver,
      tester,
      labels: ['Devices', 'Appareils'],
      expected: ['Devices', 'Appareils'],
      name: 'settings devices row',
    );
    await _openSettingsRow(
      driver,
      tester,
      labels: ['Active Sessions', 'Sessions actives'],
      expected: ['Active Sessions', 'Sessions actives'],
      name: 'settings sessions row',
    );
    await _openSettingsRow(
      driver,
      tester,
      labels: ['Limits', 'Transaction Limits', 'Limites'],
      expected: ['Limits', 'Transaction Limits', 'Limites'],
      name: 'settings limits row',
    );
    await _openSettingsRow(
      driver,
      tester,
      labels: ['Notifications'],
      expected: ['Notifications', 'Notification Preferences'],
      name: 'settings notification preferences row',
    );

    await driver.goToRoute('/home');
    await driver.waitForHome();
    await _openBottomTab(
      driver,
      tester,
      labels: ['Home', 'Accueil'],
      expected: ['Available Balance', 'Total Balance', 'Solde disponible'],
      name: 'home tab',
    );
  });
}

Future<void> _openHomeAction(
  KoridoFlowDriver driver,
  WidgetTester tester, {
  required List<String> labels,
  required List<String> expected,
  required String name,
}) async {
  await driver.goToRoute('/home');
  await driver.waitForHome();
  await driver.tapText(labels);
  await driver.pumpUntil(
    () => driver.hasAnyText(expected),
    reason: name,
    timeout: const Duration(seconds: 25),
  );
  await _assertHealthy(driver, tester, name);
  await driver.goToRoute('/home');
  await driver.waitForHome();
}

Future<void> _openBottomTab(
  KoridoFlowDriver driver,
  WidgetTester tester, {
  required List<String> labels,
  required List<String> expected,
  required String name,
}) async {
  await driver.tapText(labels);
  await driver.pumpUntil(
    () => driver.hasAnyText(expected),
    reason: name,
    timeout: const Duration(seconds: 25),
  );
  await _assertHealthy(driver, tester, name);
}

Future<void> _openSettingsRow(
  KoridoFlowDriver driver,
  WidgetTester tester, {
  required List<String> labels,
  required List<String> expected,
  required String name,
}) async {
  await driver.goToRoute('/settings');
  await driver.pumpUntil(
    () => driver.hasAnyText(['Settings', 'Paramètres']),
    reason: 'settings root before $name',
  );
  await _tapVisibleRow(driver, tester, labels);
  await driver.pumpUntil(
    () => driver.hasAnyText(expected),
    reason: name,
    timeout: const Duration(seconds: 25),
  );
  await _assertHealthy(driver, tester, name);
}

Future<void> _tapVisibleRow(
  KoridoFlowDriver driver,
  WidgetTester tester,
  List<String> labels, {
  int maxScrolls = 8,
}) async {
  for (var i = 0; i <= maxScrolls; i++) {
    final text = _findAnyText(labels);
    if (text != null) {
      await tester.ensureVisible(text);
      await tester.pump(const Duration(milliseconds: 120));

      final target = _nearestTappableAncestor(text) ?? text;
      await tester.tap(target, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 450));
      return;
    }

    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isEmpty) {
      break;
    }
    await tester.drag(
      scrollables.last,
      const Offset(0, -360),
      warnIfMissed: false,
    );
    await tester.pump(const Duration(milliseconds: 250));
  }

  throw TestFailure(
    'Could not tap row text: ${labels.join(', ')}. '
    'Visible text: ${driver.visibleTextSnapshot()}',
  );
}

Finder? _findAnyText(List<String> labels) {
  for (final label in labels) {
    final exact = find.text(label);
    if (exact.evaluate().isNotEmpty) {
      return exact.first;
    }
    final containing = find.textContaining(label);
    if (containing.evaluate().isNotEmpty) {
      return containing.first;
    }
  }
  return null;
}

Finder? _nearestTappableAncestor(Finder child) {
  final ancestors = <Finder>[
    find.ancestor(of: child, matching: find.byType(ListTile)),
    find.ancestor(of: child, matching: find.byType(InkWell)),
    find.ancestor(of: child, matching: find.byType(GestureDetector)),
  ];

  for (final finder in ancestors) {
    final hitTestable = finder.hitTestable();
    if (hitTestable.evaluate().isNotEmpty) {
      return hitTestable.last;
    }
    if (finder.evaluate().isNotEmpty) {
      return finder.last;
    }
  }

  return null;
}

Future<void> _tapTransactionsFilterIfPresent(
  KoridoFlowDriver driver,
  WidgetTester tester,
) async {
  final filter = find.byIcon(Icons.filter_list_rounded).hitTestable();
  if (filter.evaluate().isEmpty) {
    return;
  }

  await tester.tap(filter.first, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 450));
  await _assertHealthy(driver, tester, 'transactions filter opened');

  final close = find.byIcon(Icons.close_rounded).hitTestable();
  if (close.evaluate().isNotEmpty) {
    await tester.tap(close.first, warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _assertHealthy(
  KoridoFlowDriver driver,
  WidgetTester tester,
  String step,
) async {
  driver.expectNoAuthOrUnexpectedError();
  expect(
    driver.routeErrorSnapshot(),
    '<none>',
    reason: 'Route error after $step',
  );
  expect(
    driver.visibleTextSnapshot().toLowerCase(),
    isNot(contains('page not found')),
    reason: 'Page not found after $step',
  );
  expect(
    tester.takeException(),
    isNull,
    reason: 'Flutter exception after $step',
  );
}

String _uniqueIvorianPhone() {
  final seed = DateTime.now().millisecondsSinceEpoch.toString();
  return '07${seed.substring(seed.length - 8)}';
}

Future<String> _resolveOtp(String localPhone) async {
  // ignore: do_not_use_environment
  const baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://korido-api.joonapay.com/api/v1',
  );
  final e164Phone = '+225${localPhone.replaceAll(RegExp(r'\D'), '')}';

  try {
    final response = await Dio(
      BaseOptions(
        baseUrl: baseUrl,
        validateStatus: (_) => true,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    ).get<Map<String, dynamic>>('/dev/otp/$e164Phone');
    final data = response.data?['data'];
    if (response.statusCode == 200 &&
        data is Map<String, dynamic> &&
        data['otp'] != null) {
      return data['otp'].toString();
    }
  } on Object {
    // VerifyHQ dev stacks can be configured with a fixed OTP and no /dev/otp.
  }

  return '123456';
}
