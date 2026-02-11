import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/domain/entities/card.dart';

/// Repository for virtual card operations.
class CardsRepository {
  final CardsService _service;

  CardsRepository(this._service);

  /// Get all cards for the current user.
  Future<List<KoridoCard>> getCards() async {
    return _service.getCards();
  }

  /// Get a single card by ID.
  Future<KoridoCard> getCard(String id) async {
    return _service.getCard(id);
  }

  /// Create a new virtual card.
  Future<KoridoCard> createCard({
    String? nickname,
    double? spendingLimit,
  }) async {
    return _service.createCard(
      nickname: nickname,
      spendingLimit: spendingLimit,
    );
  }

  /// Freeze or unfreeze a card.
  Future<KoridoCard> toggleCardFreeze(String id, {required bool freeze}) async {
    return _service.toggleCardFreeze(id, freeze: freeze);
  }
}

final cardsRepositoryProvider = Provider<CardsRepository>((ref) {
  final service = ref.watch(cardsServiceProvider);
  return CardsRepository(service);
});
