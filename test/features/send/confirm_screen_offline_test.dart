import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/features/send/models/transfer_request.dart';
import 'package:usdc_wallet/features/send/providers/send_provider.dart';
import 'package:usdc_wallet/features/send/views/confirm_screen.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('queues draft transfer from confirm while offline before PIN', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final queue = PendingTransferQueue(prefs);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sendMoneyProvider.overrideWith(_OfflineReadySendNotifier.new),
          connectivityProvider.overrideWith(_OfflineConnectivityNotifier.new),
          pendingTransferQueueFutureProvider.overrideWith((ref) async => queue),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ConfirmScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue to PIN'));
    await tester.pumpAndSettle();

    expect(find.text('Transfer queued'), findsOneWidget);

    final saved = queue.getQueue().single;
    expect(saved.recipientPhone, '+2250711223344');
    expect(saved.amount, 3.25);
    expect(saved.description, 'Market');
    expect(saved.status, TransferStatus.needsAuthorization);
    expect(saved.pinToken, isNull);
    expect(saved.idempotencyKey, isNull);
  });
}

class _OfflineReadySendNotifier extends SendMoneyNotifier {
  @override
  SendMoneyState build() => const SendMoneyState(
    recipient: RecipientInfo(
      phoneNumber: '+2250711223344',
      name: 'Awa Kone',
      isKoridoUser: true,
    ),
    amount: 3.25,
    note: 'Market',
    availableBalance: 100,
  );
}

class _OfflineConnectivityNotifier extends ConnectivityNotifier {
  @override
  ConnectivityState build() => const ConnectivityState(isOnline: false);
}
