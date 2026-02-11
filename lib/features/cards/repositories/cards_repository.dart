import 'package:usdc_wallet/services/service_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';

class CardsRepository {
  final CardsService _service;
  CardsRepository(this._service);

  Future<dynamic> getCards() => _service.getCards();
  Future<dynamic> getCard(String id) => _service.getCard(id);
  Future<dynamic> createCard({String? cardType, String? currency, String? spendingLimit, String? nickname}) =>
    _service.createCard(cardType: cardType ?? 'virtual', currency: currency ?? 'USDC', nickname: nickname);
  Future<dynamic> toggleCardFreeze(String id, {bool? freeze}) => _service.freezeCard(id);
  Future<void> cancelCard(String id) => _service.cancelCard(id);
}

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  return CardsRepository(ref.watch(cardsServiceProvider));
});
