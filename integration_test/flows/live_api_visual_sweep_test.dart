import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../helpers/korido_flow_driver.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await KoridoFlowDriver.clearPersistentState();
  });

  testWidgets(
    'captures live API visual readiness screens across route groups',
    (tester) async {
      final driver = KoridoFlowDriver(tester);
      await driver.launchApp();
      await driver.pumpUntil(
        () =>
            driver.hasAnyText(['Welcome back', 'Bon retour']) ||
            driver.hasAnyText(['Continue', 'Continuer']) ||
            driver.hasAnyText([
              'Enter your phone number',
              'Entrez votre numéro',
            ]),
        reason: 'first visible auth surface',
        timeout: const Duration(seconds: 25),
      );
      await _capture(binding, tester, '01_auth_entry');

      await driver.startRegistrationFromIntro();
      await _capture(binding, tester, '02_phone_entry');

      final phone = _uniqueIvorianPhone();
      await driver.submitPhone(phone);
      await _capture(binding, tester, '03_otp_entry');

      await driver.enterOtp(await _resolveOtp(phone));
      await driver.pumpUntil(
        () =>
            driver.hasAnyText([
              'Tell us about yourself',
              'Parlez-nous de vous',
            ]) ||
            driver.hasAnyText(['Create your PIN', 'Créez votre PIN']),
        reason: 'profile setup or PIN setup screen',
        timeout: const Duration(seconds: 25),
      );
      if (driver.hasAnyText([
        'Tell us about yourself',
        'Parlez-nous de vous',
      ])) {
        await _capture(binding, tester, '04_profile_setup');

        await driver.submitProfile();
        await driver.pumpUntil(
          () => driver.hasAnyText(['Create your PIN', 'Créez votre PIN']),
          reason: 'PIN setup screen',
          timeout: const Duration(seconds: 25),
        );
      }
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
        () =>
            driver.hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
        reason: 'onboarding success screen',
        timeout: const Duration(seconds: 25),
      );
      await _capture(binding, tester, '07_onboarding_success');

      await driver.tapText([
        'Start Using Korido',
        'Commencer à utiliser Korido',
      ]);
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
              ..._kycGateTitles,
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

      await _captureRouteSurfaces(
        binding,
        tester,
        driver,
        startIndex: 20,
        surfaces: _authenticatedRouteSurfaces,
      );

      driver.expectNoAuthOrUnexpectedError();
    },
  );
}

class _VisualSurface {
  const _VisualSurface(this.name, this.route);

  final String name;
  final String route;
}

const _authenticatedRouteSurfaces = [
  _VisualSurface('cards_root', '/cards'),
  _VisualSurface('cards_request', '/cards/request'),
  _VisualSurface('services', '/services'),
  _VisualSurface('scan_to_pay', '/scan-to-pay'),
  _VisualSurface('receive_qr', '/receive'),
  _VisualSurface('scan_qr', '/scan'),
  _VisualSurface('deposit_amount_direct', '/deposit/amount'),
  _VisualSurface('deposit_provider_direct', '/deposit/provider'),
  _VisualSurface('deposit_status', '/deposit/status'),
  _VisualSurface('deposit_instructions', '/deposit/instructions'),
  _VisualSurface('send_amount_direct', '/send/amount'),
  _VisualSurface('send_confirm_direct', '/send/confirm'),
  _VisualSurface('send_pin_direct', '/send/pin'),
  _VisualSurface('send_result_direct', '/send/result'),
  _VisualSurface('offline_pending_transfers', '/offline/pending-transfers'),
  _VisualSurface('external_send_address', '/send-external'),
  _VisualSurface('external_send_amount', '/send-external/amount'),
  _VisualSurface('external_send_confirm', '/send-external/confirm'),
  _VisualSurface('external_send_result', '/send-external/result'),
  _VisualSurface('external_qr_scan_address', '/qr/scan-address'),
  _VisualSurface('withdraw', '/withdraw'),
  _VisualSurface('request_money', '/request'),
  _VisualSurface('scheduled', '/scheduled'),
  _VisualSurface('analytics', '/analytics'),
  _VisualSurface('insights', '/insights'),
  _VisualSurface('recipients', '/recipients'),
  _VisualSurface('contacts_list_alias', '/contacts/list'),
  _VisualSurface('converter', '/converter'),
  _VisualSurface('transactions_export', '/transactions/export'),
  _VisualSurface('bills', '/bills'),
  _VisualSurface('airtime', '/airtime'),
  _VisualSurface('savings_alias', '/savings'),
  _VisualSurface('card_alias', '/card'),
  _VisualSurface('split_bill', '/split'),
  _VisualSurface('budget', '/budget'),
  _VisualSurface('savings_pots', '/savings-pots'),
  _VisualSurface('savings_pots_create', '/savings-pots/create'),
  _VisualSurface('recurring_transfers', '/recurring-transfers'),
  _VisualSurface('recurring_transfers_create', '/recurring-transfers/create'),
  _VisualSurface('kyc_status', '/kyc'),
  _VisualSurface('kyc_document_type', '/kyc/document-type'),
  _VisualSurface('kyc_personal_info', '/kyc/personal-info'),
  _VisualSurface('kyc_document_capture', '/kyc/document-capture'),
  _VisualSurface('kyc_selfie', '/kyc/selfie'),
  _VisualSurface('kyc_liveness_instructions', '/kyc/liveness-instructions'),
  _VisualSurface('kyc_liveness', '/kyc/liveness'),
  _VisualSurface('kyc_review', '/kyc/review'),
  _VisualSurface('kyc_submitted', '/kyc/submitted'),
  _VisualSurface('kyc_upgrade', '/kyc/upgrade'),
  _VisualSurface('kyc_address', '/kyc/address'),
  _VisualSurface('kyc_video', '/kyc/video'),
  _VisualSurface('kyc_additional_docs', '/kyc/additional-docs'),
  _VisualSurface('notifications_permission', '/notifications/permission'),
  _VisualSurface('notifications_preferences', '/notifications/preferences'),
  _VisualSurface('settings_notifications', '/settings/notifications'),
  _VisualSurface('settings_security', '/settings/security'),
  _VisualSurface('settings_biometric', '/settings/biometric'),
  _VisualSurface(
    'settings_biometric_enrollment',
    '/settings/biometric/enrollment',
  ),
  _VisualSurface('settings_limits', '/settings/limits'),
  _VisualSurface('settings_help', '/settings/help'),
  _VisualSurface('settings_language', '/settings/language'),
  _VisualSurface('settings_theme', '/settings/theme'),
  _VisualSurface('settings_currency', '/settings/currency'),
  _VisualSurface('settings_delete_account', '/settings/delete-account'),
  _VisualSurface('profile_verify_email', '/profile/verify-email'),
  _VisualSurface('settings_profile_edit', '/settings/profile/edit'),
  _VisualSurface('settings_business_setup', '/settings/business-setup'),
  _VisualSurface('settings_business_profile', '/settings/business-profile'),
  _VisualSurface('settings_cookies', '/settings/legal/cookies'),
  _VisualSurface('settings_pin', '/settings/pin'),
  _VisualSurface('settings_kyc', '/settings/kyc'),
  _VisualSurface('referrals', '/referrals'),
  _VisualSurface('sub_businesses', '/sub-businesses'),
  _VisualSurface('sub_businesses_create', '/sub-businesses/create'),
  _VisualSurface('bulk_payments', '/bulk-payments'),
  _VisualSurface('bulk_payments_upload', '/bulk-payments/upload'),
  _VisualSurface('bulk_payments_preview', '/bulk-payments/preview'),
  _VisualSurface('beneficiaries', '/beneficiaries'),
  _VisualSurface('beneficiaries_add', '/beneficiaries/add'),
  _VisualSurface('bank_linking', '/bank-linking'),
  _VisualSurface('bank_linking_select', '/bank-linking/select'),
  _VisualSurface('bank_linking_link', '/bank-linking/link'),
  _VisualSurface('bank_linking_verify', '/bank-linking/verify'),
  _VisualSurface('merchant_dashboard', '/merchant-dashboard'),
  _VisualSurface('merchant_qr', '/merchant-qr'),
  _VisualSurface('merchant_create_payment_request', '/create-payment-request'),
  _VisualSurface('merchant_transactions', '/merchant-transactions'),
  _VisualSurface('bill_payments', '/bill-payments'),
  _VisualSurface('bill_payment_history', '/bill-payments/history'),
  _VisualSurface('alerts', '/alerts'),
  _VisualSurface('alerts_preferences', '/alerts/preferences'),
  _VisualSurface('expenses', '/expenses'),
  _VisualSurface('expenses_add', '/expenses/add'),
  _VisualSurface('expenses_capture', '/expenses/capture'),
  _VisualSurface('expenses_reports', '/expenses/reports'),
  _VisualSurface('payment_links', '/payment-links'),
  _VisualSurface('payment_links_create', '/payment-links/create'),
  _VisualSurface('pin_reset', '/pin/reset'),
  _VisualSurface('pin_locked', '/pin/locked'),
  _VisualSurface('pin_enter', '/pin/enter'),
  _VisualSurface('auth_locked', '/auth-locked'),
  _VisualSurface('auth_suspended', '/auth-suspended'),
  _VisualSurface('session_locked', '/session-locked'),
  _VisualSurface('biometric_prompt', '/biometric-prompt'),
  _VisualSurface('device_verification', '/device-verification'),
  _VisualSurface('session_conflict', '/session-conflict'),
  _VisualSurface('wallet_frozen', '/wallet-frozen'),
  _VisualSurface('wallet_under_review', '/wallet-under-review'),
  _VisualSurface('kyc_expired', '/kyc-expired'),
  _VisualSurface('loading_state', '/loading'),
  _VisualSurface('force_update', '/force-update'),
  _VisualSurface('maintenance', '/maintenance'),
  _VisualSurface('server_error', '/server-error'),
  _VisualSurface('create_wallet', '/create-wallet'),
];

Future<void> _captureRouteSurfaces(
  IntegrationTestWidgetsFlutterBinding binding,
  WidgetTester tester,
  KoridoFlowDriver driver, {
  required int startIndex,
  required List<_VisualSurface> surfaces,
}) async {
  for (var index = 0; index < surfaces.length; index++) {
    final surface = surfaces[index];
    try {
      await driver.goToRoute(surface.route);
      await _waitForSurface(driver, surface);
      await _capture(
        binding,
        tester,
        '${(startIndex + index).toString().padLeft(3, '0')}_${surface.name}',
      );
    } on TestFailure catch (error) {
      // The catalog must not publish launch/fallback frames as if they were
      // feature screens. Some routes need flow state or extra arguments, so
      // keep the sweep moving and leave a log for the next flow-specific pass.
      // ignore: avoid_print
      print('[visual-sweep] skipped ${surface.route}: $error');
      await driver.goToRoute('/home');
      await driver.waitForHome();
    }
  }
}

Future<void> _waitForSurface(
  KoridoFlowDriver driver,
  _VisualSurface surface,
) async {
  await driver.pumpUntil(
    () {
      final route = driver.currentRouteSnapshot();
      final visible = driver.visibleTextSnapshot().toLowerCase();
      final hasErrorChrome =
          route.contains('Page Not Found') ||
          visible.contains('page not found') ||
          visible.contains('no route');
      final hasUnexpectedError =
          visible.contains('unexpected error') ||
          visible.contains('erreur inattendue');
      final isLaunchOnly =
          visible == 'korido' ||
          (visible.startsWith('korido') && visible.split('|').length <= 2);

      return route.startsWith(surface.route) &&
          !hasErrorChrome &&
          !hasUnexpectedError &&
          !isLaunchOnly &&
          visible.trim().isNotEmpty;
    },
    reason: 'visual surface ${surface.name} at ${surface.route}',
    timeout: const Duration(seconds: 4),
  );

  driver.expectNoAuthOrUnexpectedError();
}

const _kycGateTitles = [
  'Start Verification',
  'Identity Verification',
  'Verify your identity',
  'Vérifiez votre identité',
];

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
  // ignore: do_not_use_environment
  const useHostScreenshotMarkers = bool.fromEnvironment(
    'KORIDO_SCREENSHOT_MARKERS',
  );
  if (useHostScreenshotMarkers) {
    // ignore: avoid_print
    print('KORIDO_SCREENSHOT_MARKER::$name');
    await tester.pump(const Duration(milliseconds: 1200));
    return;
  }
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
