import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';

/// Wallet Balance Provider
final walletBalanceProvider =
    FutureProvider.autoDispose<WalletBalanceResponse>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getBalance();
});

/// Deposit Channels Provider
final depositChannelsProvider =
    FutureProvider.autoDispose.family<List<DepositChannel>, String?>((
  ref,
  currency,
) async {
  final service = ref.watch(walletServiceProvider);
  return service.getDepositChannels(currency: currency);
});

/// Exchange Rate Provider
final exchangeRateProvider = FutureProvider.autoDispose
    .family<ExchangeRate, ExchangeRateParams>((ref, params) async {
  final service = ref.watch(walletServiceProvider);
  return service.getRate(
    sourceCurrency: params.sourceCurrency,
    targetCurrency: params.targetCurrency,
    amount: params.amount,
    direction: params.direction,
  );
});

class ExchangeRateParams {
  final String sourceCurrency;
  final String targetCurrency;
  final double amount;
  final String direction;

  const ExchangeRateParams({
    required this.sourceCurrency,
    required this.targetCurrency,
    required this.amount,
    this.direction = 'deposit',
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExchangeRateParams &&
        other.sourceCurrency == sourceCurrency &&
        other.targetCurrency == targetCurrency &&
        other.amount == amount &&
        other.direction == direction;
  }

  @override
  int get hashCode =>
      sourceCurrency.hashCode ^
      targetCurrency.hashCode ^
      amount.hashCode ^
      direction.hashCode;
}

/// KYC Status Provider
final kycStatusProvider =
    FutureProvider.autoDispose<KycStatusResponse>((ref) async {
  final service = ref.watch(walletServiceProvider);
  return service.getKycStatus();
});

/// Deposit State
class DepositState {
  final bool isLoading;
  final DepositResponse? response;
  final String? error;

  const DepositState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  DepositState copyWith({
    bool? isLoading,
    DepositResponse? response,
    String? error,
  }) {
    return DepositState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error,
    );
  }
}

/// Deposit Notifier
class DepositNotifier extends Notifier<DepositState> {
  @override
  DepositState build() {
    return const DepositState();
  }

  WalletService get _service => ref.read(walletServiceProvider);

  Future<bool> initiateDeposit({
    required double amount,
    required String sourceCurrency,
    required String channelId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.initiateDeposit(
        amount: amount,
        sourceCurrency: sourceCurrency,
        channelId: channelId,
      );

      state = state.copyWith(isLoading: false, response: response);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const DepositState();
  }
}

final depositProvider =
    NotifierProvider.autoDispose<DepositNotifier, DepositState>(
  DepositNotifier.new,
);

/// Transfer State
class TransferState {
  final bool isLoading;
  final TransferResponse? response;
  final String? error;

  const TransferState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  TransferState copyWith({
    bool? isLoading,
    TransferResponse? response,
    String? error,
  }) {
    return TransferState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error,
    );
  }
}

/// Transfer Notifier
class TransferNotifier extends Notifier<TransferState> {
  @override
  TransferState build() {
    return const TransferState();
  }

  WalletService get _service => ref.read(walletServiceProvider);

  Future<bool> internalTransfer({
    required String toPhone,
    required double amount,
    required String currency,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.internalTransfer(
        toPhone: toPhone,
        amount: amount,
        currency: currency,
      );

      state = state.copyWith(isLoading: false, response: response);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  Future<bool> externalTransfer({
    required String toAddress,
    required double amount,
    required String currency,
    String? network,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.externalTransfer(
        toAddress: toAddress,
        amount: amount,
        currency: currency,
        network: network,
      );

      state = state.copyWith(isLoading: false, response: response);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const TransferState();
  }
}

final transferProvider =
    NotifierProvider.autoDispose<TransferNotifier, TransferState>(
  TransferNotifier.new,
);

/// Withdraw State
class WithdrawState {
  final bool isLoading;
  final WithdrawResponse? response;
  final String? error;

  const WithdrawState({
    this.isLoading = false,
    this.response,
    this.error,
  });

  WithdrawState copyWith({
    bool? isLoading,
    WithdrawResponse? response,
    String? error,
  }) {
    return WithdrawState(
      isLoading: isLoading ?? this.isLoading,
      response: response ?? this.response,
      error: error,
    );
  }
}

/// Withdraw Notifier
class WithdrawNotifier extends Notifier<WithdrawState> {
  @override
  WithdrawState build() {
    return const WithdrawState();
  }

  WalletService get _service => ref.read(walletServiceProvider);

  Future<bool> withdraw({
    required double amount,
    required String destinationAddress,
    String? network,
    String? method,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.withdraw(
        amount: amount,
        destinationAddress: destinationAddress,
        network: network,
        method: method,
      );

      state = state.copyWith(isLoading: false, response: response);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    }
  }

  void reset() {
    state = const WithdrawState();
  }
}

final withdrawProvider =
    NotifierProvider.autoDispose<WithdrawNotifier, WithdrawState>(
  WithdrawNotifier.new,
);
