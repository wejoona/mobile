import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';

/// Deposit flow state.
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositMethod? selectedMethod;
  final double? amount;
  final DepositResult? result;

  const DepositState({
    this.isLoading = false,
    this.error,
    this.selectedMethod,
    this.amount,
    this.result,
  });

  DepositState copyWith({
    bool? isLoading,
    String? error,
    DepositMethod? selectedMethod,
    double? amount,
    DepositResult? result,
  }) => DepositState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedMethod: selectedMethod ?? this.selectedMethod,
    amount: amount ?? this.amount,
    result: result ?? this.result,
  );
}

/// Deposit method types.
enum DepositMethod {
  orangeMoney('Orange Money', '+225 07'),
  mtnMomo('MTN MoMo', '+225 05'),
  moovMoney('Moov Money', '+225 01'),
  wave('Wave', '+225'),
  bankTransfer('Bank Transfer', '');

  final String label;
  final String prefix;
  const DepositMethod(this.label, this.prefix);
}

/// Deposit result.
class DepositResult {
  final String id;
  final String status;
  final String? paymentUrl;
  final String? instructions;
  final String? reference;

  const DepositResult({
    required this.id,
    required this.status,
    this.paymentUrl,
    this.instructions,
    this.reference,
  });

  factory DepositResult.fromJson(Map<String, dynamic> json) {
    return DepositResult(
      id: json['id'] as String,
      status: json['status'] as String,
      paymentUrl: json['paymentUrl'] as String?,
      instructions: json['instructions'] as String?,
      reference: json['reference'] as String?,
    );
  }
}

/// Deposit notifier.
class DepositNotifier extends Notifier<DepositState> {
  @override
  DepositState build() => const DepositState();

  Dio get _dio => ref.read(dioProvider);

  void selectMethod(DepositMethod method) {
    state = state.copyWith(selectedMethod: method);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  Future<void> initiate() async {
    if (state.selectedMethod == null || state.amount == null) return;

    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.post('/deposit/initiate', data: {
        'amount': state.amount,
        'method': state.selectedMethod!.name,
      });
      final result =
          DepositResult.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const DepositState();
  }
}

final depositProvider =
    NotifierProvider<DepositNotifier, DepositState>(DepositNotifier.new);
