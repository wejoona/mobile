import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

void main() {
  group('PendingTransferQueue', () {
    late PendingTransferQueue queue;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      queue = PendingTransferQueue(prefs);
    });

    PendingTransfer transfer({
      String id = 'transfer-1',
      TransferStatus status = TransferStatus.pending,
      DateTime? timestamp,
      String? pinToken = 'pin-token',
      String? idempotencyKey = 'idem-key',
    }) {
      return PendingTransfer(
        id: id,
        recipientPhone: '+2250102030405',
        recipientName: 'Awa Kone',
        amount: 12.50,
        description: 'Lunch',
        timestamp: timestamp ?? DateTime.now(),
        status: status,
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
      );
    }

    test('does not persist PIN replay headers with queued transfer', () async {
      await queue.enqueue(transfer());

      final saved = queue.getQueue().single;

      expect(saved.pinToken, isNull);
      expect(saved.idempotencyKey, isNull);
    });

    test('persists recipient identity without PIN replay headers', () async {
      await queue.enqueue(
        PendingTransfer(
          id: 'transfer-username',
          recipientId: 'user-recipient-1',
          recipientPhone: '',
          recipientName: 'Awa Kone',
          recipientUsername: 'awa',
          amount: 12.50,
          description: 'Lunch',
          timestamp: DateTime.now(),
          status: TransferStatus.needsAuthorization,
          pinToken: 'pin-token',
          idempotencyKey: 'idem-key',
        ),
      );

      final saved = queue.getQueue().single;

      expect(saved.recipientId, 'user-recipient-1');
      expect(saved.recipientPhone, isEmpty);
      expect(saved.recipientUsername, 'awa');
      expect(saved.displayRecipientIdentifier, '@awa');
      expect(saved.hasRecipientIdentifier, isTrue);
      expect(saved.pinToken, isNull);
      expect(saved.idempotencyKey, isNull);
    });

    test(
      'does not replay stale processing transfers without fresh auth',
      () async {
        await queue.enqueue(
          transfer(
            status: TransferStatus.processing,
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
        );

        final processable = queue.getTransfersToProcess();

        expect(processable, isEmpty);
      },
    );

    test('does not replay recently processing transfers', () async {
      await queue.enqueue(
        transfer(status: TransferStatus.processing, timestamp: DateTime.now()),
      );

      expect(queue.getTransfersToProcess(), isEmpty);
    });

    test(
      'keeps legacy queued transfers readable without replay headers',
      () async {
        await queue.enqueue(transfer(pinToken: null, idempotencyKey: null));

        final saved = queue.getQueue().single;

        expect(saved.pinToken, isNull);
        expect(saved.idempotencyKey, isNull);
        expect(queue.getTransfersToProcess(), isEmpty);
      },
    );

    test(
      'counts offline drafts without making them auto-processable',
      () async {
        await queue.enqueue(
          transfer(
            status: TransferStatus.needsAuthorization,
            pinToken: null,
            idempotencyKey: null,
          ),
        );

        expect(queue.getPendingCount(), 1);
        expect(queue.getTransfersToProcess(), isEmpty);
      },
    );

    test('can move failed draft back to fresh authorization state', () async {
      await queue.enqueue(
        transfer(
          status: TransferStatus.failed,
          pinToken: null,
          idempotencyKey: null,
        ),
      );
      await queue.markFailed('transfer-1', 'Network timeout');

      await queue.updateTransferStatus(
        'transfer-1',
        TransferStatus.needsAuthorization,
        clearErrorMessage: true,
      );

      final saved = queue.getQueue().single;
      expect(saved.status, TransferStatus.needsAuthorization);
      expect(saved.errorMessage, isNull);
      expect(saved.canReplayWithAuthorization, isFalse);
      expect(queue.getTransfersToProcess(), isEmpty);
    });
  });
}
