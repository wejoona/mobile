import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('card block action is explicit and confirmed before cancellation', () {
    final listSource = File(
      'lib/features/cards/views/cards_list_view.dart',
    ).readAsStringSync();
    final serviceSource = File(
      'lib/services/cards/cards_service.dart',
    ).readAsStringSync();

    expect(listSource, contains('_confirmBlockCard'));
    expect(listSource, contains('cards_blockCardConfirmation'));
    expect(listSource, contains('PinConfirmationSheet.show'));
    expect(listSource, contains('verifyPinWithBackend'));
    expect(listSource, contains('cancelCard('));
    expect(listSource, contains('pinToken: pinToken'));
    expect(listSource, isNot(contains('actions.block')));
    expect(serviceSource, isNot(contains('Future<void> block(')));
  });
}
