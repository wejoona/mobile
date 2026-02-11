/// Stub state classes needed by generated views.
/// TODO: wire to real state management.

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
  final double totalAmount;
  final Map<String, double> categoryTotals;

  const ExpensesState({this.isLoading = false, this.error, this.expenses = const [], this.total = 0, this.totalAmount = 0, this.categoryTotals = const {}});
}

class FilteredPaginatedTransactionsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> transactions;
  final bool hasMore;
  final int page;

  const FilteredPaginatedTransactionsState({this.isLoading = false, this.error, this.transactions = const [], this.hasMore = false, this.page = 1});

  FilteredPaginatedTransactionsState copyWith({bool? isLoading, String? error, List<dynamic>? transactions, bool? hasMore, int? page}) =>
    FilteredPaginatedTransactionsState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, transactions: transactions ?? this.transactions, hasMore: hasMore ?? this.hasMore, page: page ?? this.page);
}

class RecurringTransferDetailState {
  final bool isLoading;
  final String? error;
  final dynamic transfer;
  final List<DateTime> nextDates;
  final List<dynamic> history;

  const RecurringTransferDetailState({this.isLoading = false, this.error, this.transfer, this.nextDates = const [], this.history = const []});
}

class SavingsPotsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> pots;
  final dynamic selectedPot;
  final List<dynamic> selectedPotTransactions;
  final double totalSaved;

  const SavingsPotsState({this.isLoading = false, this.error, this.pots = const [], this.selectedPot, this.selectedPotTransactions = const [], this.totalSaved = 0});
}

class WestAfricanBank {
  final String code;
  final String name;
  final String country;
  final String? swiftCode;

  const WestAfricanBank({required this.code, required this.name, this.country = 'CI', this.swiftCode});
}

class ProviderData {
  final String id;
  final String name;
  final String? logo;
  final double? minAmount;
  final double? maxAmount;
  final String? paymentMethodType;
  final String? enumProvider;

  const ProviderData({required this.id, required this.name, this.logo, this.minAmount, this.maxAmount, this.paymentMethodType, this.enumProvider});
}

/// Alias for card display purposes.
typedef WalletCard = Map<String, dynamic>;
