class CardsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> cards;
  final dynamic selectedCard;
  final List<dynamic> transactions;
  final String? requestError;

  const CardsState({this.isLoading = false, this.error, this.cards = const [], this.selectedCard, this.transactions = const [], this.requestError});

  CardsState copyWith({bool? isLoading, String? error, List<dynamic>? cards, dynamic selectedCard, List<dynamic>? transactions, String? requestError}) =>
    CardsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, cards: cards ?? this.cards, selectedCard: selectedCard ?? this.selectedCard, transactions: transactions ?? this.transactions, requestError: requestError ?? this.requestError);
}

/// Alias for card display purposes.
typedef WalletCard = Map<String, dynamic>;
