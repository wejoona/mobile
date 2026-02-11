import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

/// Steps in the deposit flow.
enum DepositFlowStep {
  selectProvider,
  enterAmount,
  instructions,
  processing,
  completed,
  failed,
}

/// Deposit flow state.
class DepositState {
  final bool isLoading;
  final String? error;
  final DepositMethod? selectedMethod;
  final double? amount;
  final DepositResult? result;
  final DepositFlowStep step;

  const DepositState({this.isLoading = false, this.error, this.selectedMethod, this.amount, this.result, this.step = DepositFlowStep.selectProvider});

  DepositState copyWith({bool? isLoading, String? error, DepositMethod? selectedMethod, double? amount, DepositResult? result, DepositFlowStep? step}) => DepositState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    selectedMethod: selectedMethod ?? this.selectedMethod,
    amount: amount ?? this.amount,
    result: result ?? this.result,
    step: step ?? this.step,
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

  const DepositResult({required this.id, required this.status, this.paymentUrl, this.instructions, this.reference});

  factory DepositResult.fromJson(Map<String, dynamic> json) => DepositResult(
    id: json['id'] as String,
    status: json['status'] as String,
    paymentUrl: json['paymentUrl'] as String?,
    instructions: json['instructions'] as String?,
    reference: json['reference'] as String?,
  );
}

/// Deposit notifier — wired to Dio (mock interceptor handles fallback).
class DepositNotifier extends Notifier<DepositState> {
  @override
  DepositState build() => const DepositState();

  void selectMethod(DepositMethod method) {
    state = state.copyWith(selectedMethod: method, step: DepositFlowStep.enterAmount);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount, step: DepositFlowStep.instructions);
  }

  void goBack() {
    switch (state.step) {
      case DepositFlowStep.enterAmount:
        state = state.copyWith(step: DepositFlowStep.selectProvider);
      case DepositFlowStep.instructions:
      case DepositFlowStep.processing:
        state = state.copyWith(step: DepositFlowStep.enterAmount);
      default:
        break;
    }
  }

  Future<void> initiate() async {
    if (state.selectedMethod == null || state.amount == null) return;
    state = state.copyWith(isLoading: true, step: DepositFlowStep.processing);
    try {
      final dio = ref.read(dioProvider);
      final response = await dio.post('/deposit/initiate', data: {
        'amount': state.amount,
        'method': state.selectedMethod!.name,
        'currency': 'USDC',
      });
      final result = DepositResult.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(isLoading: false, result: result, step: DepositFlowStep.completed);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString(), step: DepositFlowStep.failed);
    }
  }

  void reset() => state = const DepositState();
}

final depositProvider = NotifierProvider<DepositNotifier, DepositState>(DepositNotifier.new);
