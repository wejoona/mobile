import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

// NOTE: walletBalanceProvider is defined in balance_provider.dart (canonical).
// Do NOT re-declare it here. Import from balance_provider.dart instead.

/// Deposit Channels Provider with TTL-based caching
/// Cache duration: 30 minutes (channels rarely change)
final depositChannelsProvider =
    FutureProvider.family<List<DepositChannel>, String?>((ref, currency) async {
      final service = ref.watch(walletServiceProvider);
      final link = ref.keepAlive();

      // Auto-invalidate after 30 minutes — properly disposed
      final timer = Timer(const Duration(minutes: 30), () {
        link.close();
      });
      ref.onDispose(() => timer.cancel());

      return service.getDepositChannels(currency: currency);
    });

/// Exchange Rate Provider with TTL-based caching
/// Cache duration: 30 seconds (rates change frequently)
final exchangeRateProvider =
    FutureProvider.family<ExchangeRate, ExchangeRateParams>((
      ref,
      params,
    ) async {
      final service = ref.watch(walletServiceProvider);
      final link = ref.keepAlive();

      // Auto-invalidate after 30 seconds — properly disposed
      final timer = Timer(const Duration(seconds: 30), () {
        link.close();
      });
      ref.onDispose(() => timer.cancel());

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

/// KYC Status Provider with TTL-based caching
/// Cache duration: 5 minutes (KYC status doesn't change often)
final kycStatusProvider = FutureProvider<KycStatusResponse>((ref) async {
  final service = ref.watch(walletServiceProvider);
  final link = ref.keepAlive();

  // Auto-invalidate after 5 minutes — properly disposed
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());

  return service.getKycStatus();
});

/// Withdraw State
class WithdrawState {
  final bool isLoading;
  final WithdrawResponse? response;
  final String? error;

  const WithdrawState({this.isLoading = false, this.response, this.error});

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
    required String pinToken,
    required String idempotencyKey,
    String? stepUpToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _service.withdraw(
        amount: amount,
        destinationAddress: destinationAddress,
        network: network,
        method: method,
        pinToken: pinToken,
        idempotencyKey: idempotencyKey,
        stepUpToken: stepUpToken,
      );

      state = state.copyWith(isLoading: false, response: response);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: UserFacingErrors.message(e));
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
