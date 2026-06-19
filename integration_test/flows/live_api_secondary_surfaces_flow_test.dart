import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.clearPersistentState();
  });

  testWidgets(
    'opens live API secondary surfaces without route or auth errors',
    (tester) async {
      final driver = KoridoFlowDriver(tester);
      final phone = _uniqueIvorianPhone();

      await driver.launchApp();
      await driver.startRegistrationFromIntro();
      await driver.submitPhone(phone);
      await driver.enterOtp(await _resolveOtp(phone));

      await driver.pumpUntil(
        () => driver.hasAnyText([
          'Tell us about yourself',
          'Parlez-nous de vous',
        ]),
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
        () =>
            driver.hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
        reason: 'onboarding success screen',
        timeout: const Duration(seconds: 25),
      );
      await driver.tapText([
        'Start Using Korido',
        'Commencer à utiliser Korido',
      ]);
      await driver.waitForHome();

      for (final surface in _surfaces) {
        await _openSurface(driver, tester, surface);
      }
    },
  );
}

const _surfaces = <_Surface>[
  _Surface('/cards', ['My Cards', 'Mes cartes', 'Cards', 'Cartes']),
  _Surface('/cards/request', [
    'Request Card',
    'Demander une carte',
  ], allowsKycGate: true),
  _Surface('/send', ['Select Recipient', 'Sélectionner le destinataire']),
  _Surface('/send-external', [
    'External Transfer',
    'Send External',
  ], allowsKycGate: true),
  _Surface('/withdraw', ['Withdraw', 'Retrait'], allowsKycGate: true),
  _Surface('/receive', ['Receive', 'Recevoir']),
  _Surface('/payment-links', ['Payment Links', 'Liens de Paiement']),
  _Surface('/payment-links/create', [
    'Create Payment Link',
  ], allowsKycGate: true),
  _Surface('/savings-pots', ['Savings Pots', "Pots d'épargne"]),
  _Surface('/savings-pots/create', ['Create Pot', 'Créer']),
  _Surface('/recurring-transfers', ['Recurring Transfers']),
  _Surface('/recurring-transfers/create', ['Create Recurring']),
  _Surface('/bill-payments', ['Bill Payments', 'Pay Bills']),
  _Surface('/bill-payments/history', ['Payment History', 'History']),
  _Surface('/bank-linking', ['Bank', 'Linked']),
  _Surface('/bank-linking/select', ['Select Bank', 'Bank']),
  _Surface('/beneficiaries', ['Beneficiaries']),
  _Surface('/beneficiaries/add', ['Add Beneficiary']),
  _Surface('/settings/security', ['Security']),
  _Surface('/settings/limits', ['Limits', 'Transaction Limits']),
  _Surface('/settings/theme', ['Theme']),
  _Surface('/settings/currency', ['Currency']),
  _Surface('/notifications/preferences', ['Notification Preferences']),
  _Surface('/settings/profile/edit', ['Edit Profile', 'Profile']),
  _Surface('/referrals', ['Referral', 'Referrals']),
];

Future<void> _openSurface(
  KoridoFlowDriver driver,
  WidgetTester tester,
  _Surface surface,
) async {
  await driver.goToRoute(surface.route);
  final expectedTitles = [
    ...surface.titleCandidates,
    if (surface.allowsKycGate) ..._kycGateTitles,
  ];
  await driver.pumpUntil(
    () => expectedTitles.any((candidate) => driver.hasAnyText([candidate])),
    reason: '${surface.route} surface title',
    timeout: const Duration(seconds: 25),
  );
  await tester.pump(const Duration(milliseconds: 800));

  driver.expectNoAuthOrUnexpectedError();
  final routeError = driver.routeErrorSnapshot();
  expect(
    routeError,
    '<none>',
    reason: 'Route error on ${surface.route}: $routeError',
  );
  expect(
    driver.visibleTextSnapshot().toLowerCase(),
    isNot(contains('page not found')),
    reason: 'Page not found on ${surface.route}',
  );
  expect(
    tester.takeException(),
    isNull,
    reason: 'Flutter exception on ${surface.route}',
  );
}

class _Surface {
  const _Surface(
    this.route,
    this.titleCandidates, {
    this.allowsKycGate = false,
  });

  final String route;
  final List<String> titleCandidates;
  final bool allowsKycGate;
}

const _kycGateTitles = [
  'Start Verification',
  'Identity Verification',
  'Verify your identity',
  'Vérifiez votre identité',
];

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
