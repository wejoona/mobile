import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/service_providers.dart';

/// Create payment link flow state.
class CreatePaymentLinkState {
  final bool isLoading;
  final String? error;
  final double? amount;
  final String? description;
  final bool? oneTime;
  final CreatedPaymentLink? result;

  const CreatePaymentLinkState({this.isLoading = false, this.error, this.amount, this.description, this.oneTime, this.result});

  CreatePaymentLinkState copyWith({bool? isLoading, String? error, double? amount, String? description, bool? oneTime, CreatedPaymentLink? result}) => CreatePaymentLinkState(
    isLoading: isLoading ?? this.isLoading,
    error: error,
    amount: amount ?? this.amount,
    description: description ?? this.description,
    oneTime: oneTime ?? this.oneTime,
    result: result ?? this.result,
  );
}

/// Created payment link result.
class CreatedPaymentLink {
  final String id;
  final String url;
  final String shortCode;

  const CreatedPaymentLink({required this.id, required this.url, required this.shortCode});

  factory CreatedPaymentLink.fromJson(Map<String, dynamic> json) => CreatedPaymentLink(
    id: json['id'] as String,
    url: json['url'] as String? ?? 'https://korido.app/pay/${json['id']}',
    shortCode: json['shortCode'] as String? ?? json['id'] as String,
  );
}

/// Create payment link notifier.
class CreatePaymentLinkNotifier extends Notifier<CreatePaymentLinkState> {
  @override
  CreatePaymentLinkState build() => const CreatePaymentLinkState();

  void setAmount(double amount) => state = state.copyWith(amount: amount);
  void setDescription(String desc) => state = state.copyWith(description: desc);
  void setOneTime(bool oneTime) => state = state.copyWith(oneTime: oneTime);

  Future<void> create() async {
    if (state.amount == null || state.amount! <= 0) return;
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(paymentLinksServiceProvider);
      final response = await service.createPaymentLink(
        amount: state.amount!,
        currency: 'USDC',
        description: state.description,
      );
      final result = CreatedPaymentLink(id: response.id, url: response.url ?? '', shortCode: response.shortCode );
      state = state.copyWith(isLoading: false, result: result);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() => state = const CreatePaymentLinkState();
}

final createPaymentLinkProvider = NotifierProvider<CreatePaymentLinkNotifier, CreatePaymentLinkState>(CreatePaymentLinkNotifier.new);
