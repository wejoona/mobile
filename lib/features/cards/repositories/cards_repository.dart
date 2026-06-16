import 'package:usdc_wallet/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';

class CardsRepository {
  final CardsService _service;
  CardsRepository(this._service);

  Future<dynamic> getCards() => _service.getCards();
  Future<dynamic> getCard(String id) => _service.getCard(id);
  Future<dynamic> createCard({
    String? cardType,
    String? currency,
    String? spendingLimit,
    String? nickname,
    required String cardholderName,
  }) => _service.createCard(
    cardType: cardType ?? 'virtual',
    currency: currency ?? 'USDC',
    nickname: nickname,
    cardholderName: cardholderName,
    spendingLimit: double.tryParse(spendingLimit ?? ''),
  );
  Future<dynamic> toggleCardFreeze(
    String id, {
    bool? freeze,
    required String pinToken,
  }) => freeze == false
      ? _service.unfreezeCard(id, pinToken: pinToken)
      : _service.freezeCard(id, pinToken: pinToken);
  Future<void> cancelCard(String id, {required String pinToken}) =>
      _service.cancelCard(id, pinToken: pinToken);
}

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepository(ref.watch(cardsServiceProvider));
});
