import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/design/components/primitives/app_button.dart';
import 'package:usdc_wallet/main.dart' as app;
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/mock_registry.dart';
import 'package:usdc_wallet/mocks/services/auth/auth_mock.dart';
import 'package:usdc_wallet/mocks/services/kyc/kyc_mock.dart';
import 'package:usdc_wallet/mocks/services/wallet/wallet_mock.dart';

class KoridoFlowDriver {
  KoridoFlowDriver(this.tester);

  static const defaultPin = '739251';

  final WidgetTester tester;

  static Future<void> resetMocksAndStorage() async {
    MockConfig.enableAllMocks();
    MockConfig.networkDelayMs = 0;
    MockRegistry.reset();
    KycMockState.approve();
    await clearPersistentState();
  }

  static Future<void> clearPersistentState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    const storage = FlutterSecureStorage();
    try {
      await storage.deleteAll();
    } on Object catch (_) {
      // Keychain-backed storage is not always available on every test host.
    }
  }

  Future<void> launchApp() async {
    final originalOnError = FlutterError.onError;
    final originalErrorBuilder = ErrorWidget.builder;
    addTearDown(() {
      FlutterError.onError = originalOnError;
      ErrorWidget.builder = originalErrorBuilder;
    });

    await app.main();
    await tester.pump(const Duration(milliseconds: 750));
    FlutterError.onError = originalOnError;
    ErrorWidget.builder = originalErrorBuilder;
  }

  Future<void> completeOnboarding({String pin = defaultPin}) async {
    await startRegistrationFromIntro();
    await submitPhone(_uniqueIvorianPhone());
    await enterOtp('123456');

    await pumpUntil(
      () => hasAnyText(['Tell us about yourself', 'Parlez-nous de vous']),
      reason: 'profile setup screen',
    );
    ensureMockWalletHasBalance(minUsdc: 100);

    await submitProfile();

    await pumpUntil(
      () => hasAnyText(['Create your PIN', 'Créez votre PIN']),
      reason: 'PIN setup screen',
    );

    await enterPinTwice(pin);

    await pumpUntil(
      () => hasAnyText(['Verify your identity', 'Vérifiez votre identité']),
      reason: 'KYC prompt screen',
    );

    await tapText(['Maybe Later', 'Peut-être plus tard']);

    await pumpUntil(
      () => hasAnyText(['Welcome to Korido!', 'Bienvenue sur Korido!']),
      reason: 'onboarding success screen',
    );

    await tapText(['Start Using Korido', 'Commencer à utiliser Korido']);
    await waitForHome();
  }

  Future<void> startRegistrationFromIntro() async {
    await pumpUntil(
      () =>
          hasAnyText(['Welcome back', 'Bon retour']) ||
          hasAnyText(['Continue', 'Continuer']) ||
          hasAnyText(['Enter your phone number', 'Entrez votre numéro']),
      reason: 'login, intro, or phone screen',
      timeout: const Duration(seconds: 12),
    );

    if (hasAnyText(['Welcome back', 'Bon retour'])) {
      await tapText(['Sign up', "S'inscrire"]);
    }

    if (hasAnyText(['Enter your phone number', 'Entrez votre numéro'])) {
      return;
    }

    for (var i = 0; i < 4; i++) {
      if (hasAnyText(['Get Started', 'Commencer'])) {
        await tapText(['Get Started', 'Commencer']);
        break;
      }

      await tapText(['Continue', 'Continuer']);
      await tester.pump(const Duration(milliseconds: 650));
    }

    await pumpUntil(
      () => hasAnyText(['Enter your phone number', 'Entrez votre numéro']),
      reason: 'signup phone input screen',
    );
  }

  Future<void> submitPhone(String phone) async {
    await pumpUntil(
      () => find.byType(TextFormField).evaluate().isNotEmpty,
      reason: 'phone text field',
    );

    await tester.enterText(find.byType(TextFormField).first, phone);
    await tester.pump();
    await dismissKeyboard();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tapText(['Continue', 'Continuer']);

    await pumpUntil(
      () =>
          find
              .byKey(const ValueKey('security_code_input'))
              .evaluate()
              .isNotEmpty ||
          hasAnyText(['Verify your number', 'Vérifiez votre numéro']),
      reason: 'OTP input screen',
    );
  }

  Future<void> enterOtp(String otp) async {
    final unifiedCodeField = find.byKey(const ValueKey('security_code_input'));
    if (unifiedCodeField.evaluate().isNotEmpty) {
      await tester.tap(unifiedCodeField.first);
      await tester.enterText(unifiedCodeField.first, otp);
      await tester.pump(const Duration(milliseconds: 350));
    } else {
      final fields = find.byType(TextField);
      for (var i = 0; i < otp.length; i++) {
        await tester.tap(fields.at(i));
        await tester.enterText(fields.at(i), otp[i]);
        await tester.pump(const Duration(milliseconds: 120));
      }
    }
    await dismissKeyboard();
  }

  Future<void> submitProfile() async {
    await enterTextByKey('signup_profile_first_name_input', 'Awa');
    await enterTextByKey('signup_profile_last_name_input', 'Kone');
    await enterTextByKey('signup_profile_email_input', 'awa.kone@example.com');

    await tapText(['Continue', 'Continuer']);
  }

  Future<void> enterPinTwice(String pin) async {
    await enterPin(pin);
    await pumpUntil(
      () => hasAnyText(['Confirm your PIN', 'Confirmez votre PIN']),
      reason: 'PIN confirmation screen',
    );
    await enterPin(pin);
  }

  Future<void> enterPin(String pin) async {
    for (final digit in pin.split('')) {
      await tester.tap(find.text(digit).last);
      await tester.pump(const Duration(milliseconds: 90));
    }
  }

  Future<void> waitForHome() async {
    await pumpUntil(
      () =>
          hasAnyText([
            'Available Balance',
            'Total Balance',
            'Solde disponible',
            'Solde total',
          ]) &&
          hasAnyText(['USDC']) &&
          hasAnyText(['Send', 'Envoyer']) &&
          hasAnyText(['Deposit', 'Dépôt']),
      reason: 'home dashboard with balance and quick actions',
    );
  }

  Future<void> goToRoute(String route) async {
    await pumpUntil(
      () => find.byType(Scaffold).evaluate().isNotEmpty,
      reason: 'active route scaffold',
    );

    final context = tester.element(find.byType(Scaffold).last);
    GoRouter.of(context).go(route);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> pushRoute(String route) async {
    await pumpUntil(
      () => find.byType(Scaffold).evaluate().isNotEmpty,
      reason: 'active route scaffold',
    );

    final context = tester.element(find.byType(Scaffold).last);
    unawaited(GoRouter.of(context).push(route));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> exerciseDepositFromHome() async {
    await tapText(['Deposit', 'Dépôt']);

    await pumpUntil(
      () => hasAnyText(['Déposer des fonds', 'Deposit Funds']),
      reason: 'deposit screen',
    );

    await enterFirstTextFormField('5000');
    await tapText(['Continue', 'Continuer']);

    await pumpUntil(
      () =>
          hasAnyText(['Orange Money']) ||
          hasAnyText([
            'Account review needed',
            'Deposits for CI may need an account review',
            'Reason: no deposit channels available',
            'No Providers Available',
            'No deposit providers are currently available',
            'Aucun fournisseur disponible',
            'Aucun moyen de paiement disponible',
          ]),
      reason: 'deposit provider options or unavailable state',
    );

    if (hasAnyText([
      'Account review needed',
      'Deposits for CI may need an account review',
      'Reason: no deposit channels available',
      'No Providers Available',
      'No deposit providers are currently available',
      'Aucun fournisseur disponible',
      'Aucun moyen de paiement disponible',
    ])) {
      expectNoAuthOrUnexpectedError();
      return;
    }

    final orangeProvider = find.byKey(
      const ValueKey('deposit_provider_orange_money_ci'),
    );
    final legacyOrangeProvider = find.byKey(
      const ValueKey('deposit_provider_OMCI'),
    );
    final providerFinder = orangeProvider.evaluate().isNotEmpty
        ? orangeProvider
        : legacyOrangeProvider;
    await tester.ensureVisible(providerFinder);
    await tester.tap(providerFinder);
    await tester.pump(const Duration(milliseconds: 350));

    await pumpUntil(
      () =>
          hasAnyText(['Instructions de paiement', 'Payment Instructions']) ||
          hasAnyText(['Payment', 'Paiement']) ||
          hasAnyText(['Waiting for approval', 'En attente']) ||
          hasAnyText(['Enter OTP', 'Entrer OTP']) ||
          hasAnyText(['Deposit Successful', 'Dépôt réussi']),
      reason: 'deposit instructions, OTP prompt, or success status',
    );

    if (hasAnyText(['Enter OTP', 'Entrer OTP'])) {
      await pumpUntil(
        () => find.byType(TextField).evaluate().isNotEmpty,
        reason: 'deposit OTP input field',
      );
      final fields = find.byType(TextField);
      await tester.enterText(fields.last, '123456');
      await tester.pump(const Duration(milliseconds: 250));
      await dismissKeyboard();
      await tapText(['Submit OTP', 'Soumettre OTP']);

      await pumpUntil(
        () => hasAnyText(['Deposit Successful', 'Dépôt réussi']),
        reason: 'deposit success status after OTP',
      );
    }
  }

  Future<void> returnHomeFromDeposit() async {
    final doneButton = findText(['Done', 'Terminé']);
    if (doneButton != null) {
      await tester.ensureVisible(doneButton);
      await tester.tap(doneButton);
    } else {
      final closeButton = find.byIcon(Icons.close);
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton.first);
      } else {
        await goToRoute('/home');
      }
    }
    await tester.pump(const Duration(milliseconds: 350));
    await waitForHome();
  }

  Future<void> exerciseTransferFromHome({String pin = defaultPin}) async {
    await tapText(['Send', 'Envoyer']);

    await pumpUntil(
      () => hasAnyText(['Select Recipient', 'Sélectionner le destinataire']),
      reason: 'send recipient screen',
    );

    await enterFirstTextFormField('0711223344');
    await tapText(['Continue', 'Continuer']);

    await pumpUntil(
      () => hasAnyText(['Enter Amount', 'Entrer le montant']),
      reason: 'send amount screen',
    );

    await enterFirstTextFormField('1');
    await tapText(['Continue', 'Continuer']);

    await pumpUntil(
      () => hasAnyText(['Confirm Transfer', 'Confirmer le transfert']),
      reason: 'send confirmation screen',
    );

    await tapText([
      'Continue to PIN',
      'Continuer vers le PIN',
      'Confirm & Send',
      'Confirmer & Envoyer',
    ]);

    await pumpUntil(
      () => hasAnyText(['Verify PIN', 'Vérifier le code PIN']),
      reason: 'send PIN verification screen',
    );

    await enterPinTextFields(pin);

    await pumpUntil(
      () => hasAnyText(['Transfer Successful!', 'Transfert réussi!']),
      reason: 'transfer success result',
    );
  }

  Future<void> pullToRefreshHome() async {
    final scrollable = find.byType(CustomScrollView).evaluate().isNotEmpty
        ? find.byType(CustomScrollView).first
        : find.byType(Scrollable).first;
    await tester.fling(scrollable, const Offset(0, 300), 1000);
    await tester.pump(const Duration(seconds: 1));
    await waitForHome();
  }

  Future<void> enterFirstTextFormField(String value) async {
    Finder fields() {
      final formFields = find.byType(TextFormField);
      return formFields.evaluate().isNotEmpty
          ? formFields
          : find.byType(TextField);
    }

    await pumpUntil(
      () => fields().evaluate().isNotEmpty,
      reason: 'text input field',
    );
    await tester.enterText(fields().first, value);
    await tester.pump();
    await dismissKeyboard();
  }

  Future<void> enterTextByKey(String key, String value) async {
    final field = find.byKey(ValueKey(key));
    await pumpUntil(
      () => field.evaluate().isNotEmpty,
      reason: '$key input field',
    );
    await tester.ensureVisible(field);
    await tester.tap(field);
    await tester.enterText(field, value);
    await tester.pump();
    await dismissKeyboard();
  }

  Future<void> enterPinTextFields(String pin) async {
    await pumpUntil(
      () =>
          find.byKey(const ValueKey('pin_digit_0')).evaluate().isNotEmpty ||
          find
              .byKey(const ValueKey('security_code_input'))
              .evaluate()
              .isNotEmpty,
      reason: 'PIN input fields',
    );

    final securityCodeInput = find.byKey(const ValueKey('security_code_input'));
    if (securityCodeInput.evaluate().isNotEmpty) {
      await tester.ensureVisible(securityCodeInput);
      await tester.tap(securityCodeInput);
      await tester.enterText(securityCodeInput, pin);
      await tester.pump(const Duration(milliseconds: 250));
      await dismissKeyboard();
      return;
    }

    for (var i = 0; i < pin.length; i++) {
      final field = find.byKey(ValueKey('pin_digit_$i'));
      await tester.ensureVisible(field);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(field);
      await tester.enterText(field, pin[i]);
      await tester.pump(const Duration(milliseconds: 90));
    }
    await dismissKeyboard();
  }

  Future<void> tapText(List<String> candidates) async {
    Finder? button = findButton(candidates);
    Finder? finder = findText(candidates);

    if (button == null && finder == null) {
      await scrollUntilText(candidates, maxScrolls: 6);
      button = findButton(candidates);
      finder = findText(candidates);
    }

    if (button != null) {
      await tester.ensureVisible(button);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(button);
      await tester.pump(const Duration(milliseconds: 350));
      return;
    }

    if (finder == null) {
      throw TestFailure(
        'Could not find any text: ${candidates.join(', ')}. '
        'Visible text: ${visibleTextSnapshot()}',
      );
    }
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 150));
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 350));
  }

  Future<void> tapTextAfterScroll(
    List<String> candidates, {
    int maxScrolls = 10,
  }) async {
    await scrollUntilText(candidates, maxScrolls: maxScrolls);
    await tapText(candidates);
  }

  Future<void> scrollUntilText(
    List<String> candidates, {
    int maxScrolls = 10,
  }) async {
    for (var i = 0; i <= maxScrolls; i++) {
      if (findText(candidates) != null) {
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
      'Could not scroll to any text: ${candidates.join(', ')}. '
      'Visible text: ${visibleTextSnapshot()}',
    );
  }

  Finder? findText(List<String> candidates) {
    for (final candidate in candidates) {
      final exact = find.text(candidate);
      if (exact.evaluate().isNotEmpty) {
        return exact.first;
      }

      final containing = find.textContaining(candidate);
      if (containing.evaluate().isNotEmpty) {
        return containing.first;
      }
    }
    return null;
  }

  Finder? findButton(List<String> candidates) {
    final labels = candidates.toSet();
    final button = find.byWidgetPredicate(
      (widget) => widget is AppButton && labels.contains(widget.label),
    );
    if (button.evaluate().isNotEmpty) {
      return button.first;
    }
    return null;
  }

  bool hasAnyText(List<String> candidates) => findText(candidates) != null;

  void expectNoAuthOrUnexpectedError() {
    final visible = visibleTextSnapshot().toLowerCase();
    expect(visible.contains('401'), isFalse);
    expect(visible.contains('unauthorized'), isFalse);
    expect(visible.contains('non autorisé'), isFalse);
    expect(visible.contains('unexpected error'), isFalse);
    expect(visible.contains('erreur inattendue'), isFalse);
  }

  Future<void> pumpUntil(
    bool Function() condition, {
    required String reason,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 250));
      if (condition()) {
        return;
      }
    }
    throw TestFailure(
      'Timed out waiting for $reason. Visible text: ${visibleTextSnapshot()}',
    );
  }

  String visibleTextSnapshot() {
    final texts = <String>[];
    for (final element in find.byType(Text).evaluate()) {
      final widget = element.widget as Text;
      final value = widget.data ?? widget.textSpan?.toPlainText();
      if (value == null || value.trim().isEmpty) {
        continue;
      }
      texts.add(value.trim());
      if (texts.length >= 30) {
        break;
      }
    }
    return texts.join(' | ');
  }

  Future<void> dismissKeyboard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    try {
      tester.testTextInput.hide();
    } on Object catch (_) {
      // Integration tests on a real simulator do not always register TestTextInput.
    }
    await tester.pump(const Duration(milliseconds: 250));
  }

  void ensureMockWalletHasBalance({required double minUsdc}) {
    final userId = AuthMockState.currentUserId;
    if (userId == null) {
      return;
    }

    final wallet =
        WalletMockState.getWallet(userId) ??
        WalletMockState.createWallet(userId);
    if (wallet.balanceUsdc >= minUsdc) {
      return;
    }

    final delta = minUsdc - wallet.balanceUsdc;
    WalletMockState.updateBalance(userId, delta, delta * 655.957);
  }

  String _uniqueIvorianPhone() {
    final seed = DateTime.now().millisecondsSinceEpoch.toString();
    return '07${seed.substring(seed.length - 8)}';
  }
}
