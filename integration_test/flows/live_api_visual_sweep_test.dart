import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.clearPersistentState();
  });

  testWidgets('captures live API visual readiness screens', (tester) async {
    final driver = KoridoFlowDriver(tester);
    await driver.launchApp();
    await _capture(binding, tester, '01_onboarding_intro');

    await driver.startRegistrationFromIntro();
    await _capture(binding, tester, '02_phone_entry');

    final phone = _uniqueIvorianPhone();
    await driver.submitPhone(phone);
    await _capture(binding, tester, '03_otp_entry');

    await driver.enterOtp(await _resolveOtp(phone));
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
      reason: 'profile setup screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '04_profile_setup');

    await driver.submitProfile();
    await driver.pumpUntil(
      () => driver.hasAnyText(['Create your PIN', 'Créez votre PIN']),
      reason: 'PIN setup screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '05_pin_create');

    await driver.enterPinTwice(KoridoFlowDriver.defaultPin);
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Verify your identity',
        'Vérifiez votre identité',
      ]),
      reason: 'KYC prompt screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '06_kyc_prompt');

    await driver.tapText(['Maybe Later', 'Peut-être plus tard']);
    await driver.pumpUntil(
      () => driver.hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
      reason: 'onboarding success screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '07_onboarding_success');

    await driver.tapText(['Start Using Korido', 'Commencer à utiliser Korido']);
    await driver.waitForHome();
    await _capture(binding, tester, '08_home_balance');

    await driver.goToRoute('/send');
    await driver.pumpUntil(
      () => driver.hasAnyText([
        'Select Recipient',
        'Sélectionner le destinataire',
      ]),
      reason: 'send recipient screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '09_send_recipient');

    await driver.goToRoute('/deposit');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Déposer des fonds', 'Deposit Funds']),
      reason: 'deposit amount screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '10_deposit_amount');

    await driver.enterFirstTextFormField('5000');
    await driver.tapText(['Continue', 'Continuer']);
    await driver.pumpUntil(
      () =>
          driver.hasAnyText(['Orange Money', 'Wave', 'MTN']) ||
          driver.hasAnyText([
            'Account review needed',
            'Deposits for CI may need an account review',
            'Reason: no deposit channels available',
            'No Providers Available',
            'No deposit providers are currently available',
            'Aucun fournisseur disponible',
            'Aucun moyen de paiement disponible',
          ]),
      reason: 'deposit provider options or unavailable state',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '11_deposit_provider_state');

    await driver.goToRoute('/transactions');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Transactions']),
      reason: 'transactions screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '12_transactions');

    await driver.goToRoute('/notifications');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Notifications']),
      reason: 'notifications screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '13_notifications');

    await driver.goToRoute('/contacts/permission');
    await driver.pumpUntil(
      () => driver.hasAnyText(['contacts', 'Contacts', 'contact']),
      reason: 'contacts permission screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '14_contacts_permission');

    await driver.goToRoute('/contacts');
    await driver.pumpUntil(
      () => _hasContactsList(driver) || _hasContactsPermissionGate(driver),
      reason: 'contacts list or first-run permission gate',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '15_contacts_state');

    await driver.goToRoute('/settings');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Settings', 'Paramètres']),
      reason: 'settings screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '16_settings');

    await driver.goToRoute('/settings/profile');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Profile', 'Profil']),
      reason: 'profile screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '17_profile');

    await driver.goToRoute('/settings/devices');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Devices', 'Appareils']),
      reason: 'devices screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '18_devices');

    await driver.goToRoute('/settings/sessions');
    await driver.pumpUntil(
      () => driver.hasAnyText(['Active Sessions', 'Sessions actives']),
      reason: 'active sessions screen',
      timeout: const Duration(seconds: 25),
    );
    await _capture(binding, tester, '19_active_sessions');

    driver.expectNoAuthOrUnexpectedError();
  });
}

bool _hasContactsList(KoridoFlowDriver driver) =>
    driver.hasAnyText(['Search contacts', 'Rechercher des contacts']) &&
    driver.hasAnyText([
      'On Korido',
      'Sur Korido',
      'Invite to Korido',
      'Inviter sur Korido',
      'Connect your contacts',
      'Connectez vos contacts',
    ]);

bool _hasContactsPermissionGate(KoridoFlowDriver driver) =>
    driver.hasAnyText([
      'Find Your Friends',
      'Find your friends',
      'Trouvez Vos Amis',
    ]) &&
    driver.hasAnyText(['Allow Access', 'Allow access', "Autoriser l'Accès"]);

Future<void> _capture(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  String name,
) async {
  await tester.pump(const Duration(milliseconds: 500));
  await binding.takeScreenshot(name);
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
    // Some dev stacks use fixed OTP without exposing /dev/otp.
  }

  return '123456';
}
