import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/transfers/transfers_service.dart';
import '../../../services/wallet/wallet_service.dart';
import '../../../services/app_review/app_review_service.dart';
import '../models/transfer_request.dart';

/// Send Money State
class SendMoneyState {
  final bool isLoading;
  final String? error;
  final RecipientInfo? recipient;
  final double? amount;
  final String? note;
  final TransferResult? result;
  final List<RecentRecipient> recentRecipients;
  final double availableBalance;
  final double fee;

  const SendMoneyState({
    this.isLoading = false,
    this.error,
    this.recipient,
    this.amount,
    this.note,
    this.result,
    this.recentRecipients = const [],
    this.availableBalance = 0.0,
    this.fee = 0.0,
  });

  bool get canProceedToAmount => recipient != null;
  bool get canProceedToConfirm =>
      recipient != null && amount != null && amount! > 0;
  double get total => (amount ?? 0) + fee;
  bool get hasSufficientBalance => availableBalance >= total;

  SendMoneyState copyWith({
    bool? isLoading,
    String? error,
    RecipientInfo? recipient,
    double? amount,
    String? note,
    TransferResult? result,
    List<RecentRecipient>? recentRecipients,
    double? availableBalance,
    double? fee,
  }) {
    return SendMoneyState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      recipient: recipient ?? this.recipient,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      result: result ?? this.result,
      recentRecipients: recentRecipients ?? this.recentRecipients,
      availableBalance: availableBalance ?? this.availableBalance,
      fee: fee ?? this.fee,
    );
  }

  SendMoneyState clearError() => copyWith(error: null);

  SendMoneyState reset() => const SendMoneyState();
}

/// Send Money Notifier
class SendMoneyNotifier extends Notifier<SendMoneyState> {
  @override
  SendMoneyState build() => const SendMoneyState();

  /// Load available balance
  Future<void> loadBalance() async {
    try {
      final walletService = ref.read(walletServiceProvider);
      final balance = await walletService.getBalance();
      state = state.copyWith(availableBalance: balance.availableBalance);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Load recent recipients (from local storage or API)
  Future<void> loadRecentRecipients() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Load from local storage or API
      // For now, empty list
      state = state.copyWith(
        isLoading: false,
        recentRecipients: [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Validate and set recipient
  Future<void> setRecipient(String phoneNumber, {String? name}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // TODO: Validate phone number with API to check if JoonaPay user
      // For now, create recipient info
      final recipient = RecipientInfo(
        phoneNumber: phoneNumber,
        name: name,
        isJoonaPayUser: true, // TODO: Check with API
      );

      state = state.copyWith(
        isLoading: false,
        recipient: recipient,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Set transfer amount
  void setAmount(double amount) {
    // Calculate fee (currently 0 for internal transfers)
    const fee = 0.0;
    state = state.copyWith(amount: amount, fee: fee);
  }

  /// Set optional note
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// Execute transfer
  Future<bool> executeTransfer() async {
    if (!state.canProceedToConfirm) {
      state = state.copyWith(error: 'Invalid transfer details');
      return false;
    }

    if (!state.hasSufficientBalance) {
      state = state.copyWith(error: 'Insufficient balance');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      final transfersService = ref.read(transfersServiceProvider);
      final result = await transfersService.createInternalTransfer(
        recipientPhone: state.recipient!.phoneNumber,
        amount: state.amount!,
        note: state.note,
      );

      state = state.copyWith(
        isLoading: false,
        result: result,
      );

      // Track successful transaction for app review prompt
      final appReviewService = ref.read(appReviewServiceProvider);
      await appReviewService.trackSuccessfulTransaction();

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Reset state (e.g., when starting new transfer)
  void reset() {
    state = state.reset();
  }

  /// Clear error
  void clearError() {
    state = state.clearError();
  }
}

/// Send Money Provider
final sendMoneyProvider = NotifierProvider<SendMoneyNotifier, SendMoneyState>(
  SendMoneyNotifier.new,
);
