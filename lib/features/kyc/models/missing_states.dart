/// Stub state classes needed by generated views.
/// TODO: wire to real state management.

class CardsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> cards;
  final dynamic selectedCard;

  const CardsState({this.isLoading = false, this.error, this.cards = const [], this.selectedCard});

  CardsState copyWith({bool? isLoading, String? error, List<dynamic>? cards, dynamic selectedCard}) =>
    CardsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, cards: cards ?? this.cards, selectedCard: selectedCard ?? this.selectedCard);
}

class DevicesState {
  final bool isLoading;
  final String? error;
  final List<dynamic> devices;

  const DevicesState({this.isLoading = false, this.error, this.devices = const []});
}

class ExpensesState {
  final bool isLoading;
  final String? error;
  final List<dynamic> expenses;
  final double total;

  const ExpensesState({this.isLoading = false, this.error, this.expenses = const [], this.total = 0});
}

class FilteredPaginatedTransactionsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> transactions;
  final bool hasMore;
  final int page;

  const FilteredPaginatedTransactionsState({this.isLoading = false, this.error, this.transactions = const [], this.hasMore = false, this.page = 1});
}

class RecurringTransferDetailState {
  final bool isLoading;
  final String? error;
  final dynamic transfer;

  const RecurringTransferDetailState({this.isLoading = false, this.error, this.transfer});
}

class SavingsPotsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> pots;
  final dynamic selectedPot;

  const SavingsPotsState({this.isLoading = false, this.error, this.pots = const [], this.selectedPot});
}

class WestAfricanBank {
  final String code;
  final String name;
  final String country;

  const WestAfricanBank({required this.code, required this.name, this.country = 'CI'});
}

class ProviderData {
  final String id;
  final String name;
  final String? logo;
  final double? minAmount;
  final double? maxAmount;

  const ProviderData({required this.id, required this.name, this.logo, this.minAmount, this.maxAmount});
}

/// Alias for card display purposes.
typedef WalletCard = dynamic;

