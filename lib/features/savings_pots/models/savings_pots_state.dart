class SavingsPotsState {
  final bool isLoading;
  final String? error;
  final List<dynamic> pots;
  final dynamic selectedPot;
  final List<dynamic> selectedPotTransactions;
  final double totalSaved;

  const SavingsPotsState({this.isLoading = false, this.error, this.pots = const [], this.selectedPot, this.selectedPotTransactions = const [], this.totalSaved = 0});
}
