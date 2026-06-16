import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/payment_links/models/create_link_request.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/create_recurring_transfer_request.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/recurring_transfer_status.dart';
import 'package:usdc_wallet/features/recurring_transfers/models/transfer_frequency.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/mocks/mock_registry.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/payment_links/payment_links_service.dart';
import 'package:usdc_wallet/services/recurring_transfers/recurring_transfers_service.dart';
import 'package:usdc_wallet/services/savings_pots/savings_pots_service.dart';

void main() {
  late bool previousUseMocks;
  late bool previousBlockUnmocked;
  late int previousDelay;
  late Dio dio;

  setUp(() async {
    previousUseMocks = MockConfig.useMocks;
    previousBlockUnmocked = MockConfig.blockUnmockedRequests;
    previousDelay = MockConfig.networkDelayMs;
    MockConfig.useMocks = true;
    MockConfig.blockUnmockedRequests = true;
    MockConfig.networkDelayMs = 0;

    MockRegistry.clear();
    MockRegistry.initialize();
    MockRegistry.reset();

    dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'));
    dio.interceptors.add(MockRegistry.interceptor);
    await _login(dio);
  });

  tearDown(() {
    MockRegistry.clear();
    MockConfig.useMocks = previousUseMocks;
    MockConfig.blockUnmockedRequests = previousBlockUnmocked;
    MockConfig.networkDelayMs = previousDelay;
  });

  test(
    'payment links support create, lookup, pay, and cancel contracts',
    () async {
      final service = PaymentLinksService(dio);

      final link = await service.createLink(
        const CreateLinkRequest(
          amount: 12000,
          currency: 'XOF',
          description: 'Market invoice',
        ),
      );
      expect(link.shortCode, hasLength(6));
      expect(link.currency, 'XOF');

      final links = await service.getLinks();
      expect(links.map((item) => item.id), contains(link.id));

      final publicLink = await service.getLinkByCode(link.shortCode);
      expect(publicLink.id, link.id);

      final payment = await service.payLink(
        link.shortCode,
        amount: 12000,
        pinToken: 'mock_pin_token_test',
        idempotencyKey: 'payment-link-contract',
      );
      expect(payment.status, 'completed');
      expect(payment.amount, 12000);

      final cancellable = await service.createLink(
        const CreateLinkRequest(amount: 1500, currency: 'XOF'),
      );
      await service.cancelLink(cancellable.id);
      final cancelled = await service.getLink(cancellable.id);
      expect(cancelled.isCancelled, isTrue);
    },
  );

  test(
    'bill payments validate provider, payment, receipt, and history',
    () async {
      final service = BillPaymentsService(dio);

      final providers = await service.getProviders(country: 'CI');
      expect(
        providers.providers.map((provider) => provider.id),
        contains('sodeci-ci'),
      );

      final categories = await service.getCategories(country: 'CI');
      expect(
        categories.categories.map((category) => category.category),
        contains(BillCategory.water),
      );

      final validation = await service.validateAccount(
        providerId: 'sodeci-ci',
        accountNumber: '123456789',
      );
      expect(validation.isValid, isTrue);
      expect(validation.accountNumber, '123456789');

      final payment = await service.payBill(
        providerId: 'sodeci-ci',
        accountNumber: validation.accountNumber,
        amount: 12500,
        customerName: validation.customerName,
        currency: 'XOF',
        pinToken: 'mock_pin_token_test',
        idempotencyKey: 'bill-pay-contract',
      );
      expect(payment.isCompleted, isTrue);
      expect(payment.receiptNumber, isNotEmpty);

      final receipt = await service.getReceipt(payment.paymentId);
      expect(receipt.paymentId, payment.paymentId);
      expect(receipt.receiptNumber, payment.receiptNumber);
      expect(receipt.providerName, contains('SODECI'));

      final history = await service.getHistory(category: 'water');
      expect(history.items.map((item) => item.id), contains(payment.paymentId));

      await expectLater(
        service.payBill(
          providerId: 'unknown-provider',
          accountNumber: '123456789',
          amount: 12500,
          pinToken: 'mock_pin_token_test',
        ),
        throwsA(isA<ApiException>()),
      );
    },
  );

  test(
    'savings pots support list, detail, update, movements, and delete',
    () async {
      final service = SavingsPotsService(dio);

      final existing = await service.getAll();
      expect(existing, isNotEmpty);

      final created = await service.create(
        name: 'School fees',
        targetAmount: 250000,
        currency: 'XOF',
      );
      expect(created.name, 'School fees');
      expect(created.currency, 'XOF');

      final loaded = await service.getById(created.id);
      expect(loaded.id, created.id);

      final updated = await service.update(
        id: created.id,
        name: 'School and books',
        targetAmount: 300000,
      );
      expect(updated.name, 'School and books');
      expect(updated.targetAmount, 300000);

      final afterDeposit = await service.deposit(
        created.id,
        50000,
        pinToken: 'mock_pin_token_test',
        idempotencyKey: 'savings-deposit-contract',
      );
      expect(afterDeposit.currentAmount, 50000);

      final afterWithdraw = await service.withdraw(
        created.id,
        12500,
        pinToken: 'mock_pin_token_test',
        idempotencyKey: 'savings-withdraw-contract',
      );
      expect(afterWithdraw.currentAmount, 37500);

      final emptied = await service.withdrawAll(
        created.id,
        pinToken: 'mock_pin_token_test',
        idempotencyKey: 'savings-withdraw-all-contract',
      );
      expect(emptied.currentAmount, 0);

      await service.delete(created.id);
      await expectLater(
        service.getById(created.id),
        throwsA(isA<DioException>()),
      );
    },
  );

  test('recurring transfers persist state across action routes', () async {
    final service = RecurringTransfersService(dio);

    final transfers = await service.getRecurringTransfers();
    expect(transfers, isNotEmpty);

    final created = await service.createRecurringTransfer(
      CreateRecurringTransferRequest(
        recipientPhone: '+2250701020304',
        recipientName: 'Aya Kone',
        amount: 18000,
        currency: 'XOF',
        frequency: TransferFrequency.weekly,
        startDate: DateTime.now().add(const Duration(days: 1)),
        dayOfWeek: 1,
      ),
      pinToken: 'mock_pin_token_test',
      idempotencyKey: 'recurring-create-contract',
    );
    expect(created.status, RecurringTransferStatus.active);

    final paused = await service.pauseRecurringTransfer(created.id);
    expect(paused.status, RecurringTransferStatus.paused);

    final resumed = await service.resumeRecurringTransfer(created.id);
    expect(resumed.status, RecurringTransferStatus.active);

    final history = await service.getExecutionHistory(created.id);
    expect(history, isA<List<dynamic>>());

    final upcoming = await service.getUpcomingExecutions();
    expect(upcoming, isNotEmpty);

    final nextDates = await service.getNextExecutionDates(created.id, count: 4);
    expect(nextDates, hasLength(4));

    await service.cancelRecurringTransfer(created.id);
    await expectLater(
      service.getRecurringTransfer(created.id),
      throwsA(isA<DioException>()),
    );
  });

  test(
    'cards support request, controls, transactions, and cancellation',
    () async {
      final service = CardsService(dio);

      final created = await service.requestCard({
        'cardholderName': 'Josue Kouakou',
        'spendingLimit': 500,
        'cardType': 'virtual',
      });
      expect(created['cardholderName'], 'Josue Kouakou');
      expect(created['spendingLimit'], 500);

      final cards = await service.getCards();
      final items = cards['data'] as List<dynamic>;
      expect(items, hasLength(1));

      final cardId = created['id'] as String;
      const pinToken = 'test-pin-token';
      final frozen = await service.freezeCard(cardId, pinToken: pinToken);
      expect(frozen['status'], 'frozen');

      final unfrozen = await service.unfreezeCard(cardId, pinToken: pinToken);
      expect(unfrozen['status'], 'active');

      final limited = await service.updateSpendingLimit(
        cardId,
        dailyLimit: 750,
        transactionLimit: 750,
        pinToken: pinToken,
      );
      expect(limited['spendingLimit'], 750);

      final transactions = await service.loadCardTransactions(cardId);
      expect(transactions, isNotEmpty);

      await service.cancelCard(cardId, pinToken: pinToken);
      final afterCancel = await service.getCards();
      expect(afterCancel['data'], isEmpty);
    },
  );
}

Future<void> _login(Dio dio) async {
  await dio.post('/auth/login', data: {'phone': '0748805663'});
  await dio.post(
    '/auth/verify-otp',
    data: {'phone': '0748805663', 'otp': '123456'},
  );
}
