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
    'registers a fresh user against the live local API and reaches home',
    (tester) async {
      final driver = KoridoFlowDriver(tester);
      await driver.launchApp();
      await driver.startRegistrationFromIntro();
      final phone = _uniqueIvorianPhone();
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
      await driver.expectDepositBlockedByKycFromHome();
      await _openLiveSecondarySurfaces(driver);
      await _logoutFromLiveSession(driver);

      await driver.loginReturningUser(
        phone: phone,
        resolveOtp: () => _resolveOtp(phone),
      );
      await driver.pullToRefreshHome();
      await _logoutFromLiveSession(driver);
    },
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

Future<void> _openLiveSecondarySurfaces(KoridoFlowDriver driver) async {
  await driver.goToRoute('/transactions');
  await driver.pumpUntil(
    () =>
        driver.hasAnyText(['Transactions']) &&
        driver.hasAnyText([
          'Deposit',
          'Dépôt',
          'Mobile Money Deposit',
          'No Transactions Yet',
          'No Transactions',
          'Aucune Transaction',
          'Aucune transaction pour le moment',
        ]),
    reason: 'live transactions screen without mock data',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);

  await driver.goToRoute('/notifications');
  await driver.pumpUntil(
    () =>
        driver.hasAnyText(['Notifications']) &&
        driver.hasAnyText([
          'PIN Changed',
          'Identity Documents Needed',
          'Upload your identity documents to continue verification.',
          'No Notifications',
          "You're all caught up",
          'Aucune notification',
        ]),
    reason: 'live notifications screen',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);

  await driver.goToRoute('/settings/devices');
  await driver.pumpUntil(
    () =>
        driver.hasAnyText(['Devices', 'Appareils']) &&
        driver.hasAnyText(['This device', 'Cet appareil', 'Apple', 'iPhone']),
    reason: 'live devices screen',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);

  await driver.goToRoute('/settings/sessions');
  await driver.pumpUntil(
    () =>
        driver.hasAnyText(['Active Sessions', 'Sessions actives']) &&
        driver.hasAnyText([
          'Current session',
          'Session actuelle',
          'Unknown Device',
        ]),
    reason: 'live active sessions screen',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);

  await driver.goToRoute('/settings/notifications');
  await driver.pumpUntil(
    () =>
        driver.hasAnyText(['Notifications']) &&
        driver.hasAnyText([
          'Transactions',
          'Transaction Alerts',
          'Alertes transaction',
          'Toutes les alertes de transaction',
          'Alertes de transaction',
        ]),
    reason: 'live notification preferences screen',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);
}

Future<void> _logoutFromLiveSession(KoridoFlowDriver driver) async {
  await driver.goToRoute('/settings');
  await driver.tapKeyAfterScroll('settings_logout_button', maxScrolls: 20);

  await driver.pumpUntil(
    () => driver.hasAnyText([
      'Are you sure you want to logout?',
      'Êtes-vous sûr de vouloir vous déconnecter?',
    ]),
    reason: 'logout confirmation dialog',
    timeout: const Duration(seconds: 10),
  );

  await driver.tapKeyAfterScroll('settings_logout_confirm_button');

  await driver.pumpUntil(
    () => driver.hasAnyText([
      'Enter your phone number',
      'Entrez votre numéro',
      'Welcome back',
      'Bon retour',
    ]),
    reason: 'login screen after logout',
    timeout: const Duration(seconds: 25),
  );
  _expectNoAuthError(driver);
}

void _expectNoAuthError(KoridoFlowDriver driver) {
  final visible = driver.visibleTextSnapshot().toLowerCase();
  expect(visible.contains('401'), isFalse);
  expect(visible.contains('unauthorized'), isFalse);
  expect(visible.contains('non autorisé'), isFalse);
}
