import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Run 352: Fee calculation provider for send flow
class SendFee {
  final double networkFee;
  final double serviceFee;
  final double totalFee;
  final String feeCurrency;
  final bool isFeeWaived;
  final String? waiverReason;

  const SendFee({
    required this.networkFee,
    required this.serviceFee,
    required this.totalFee,
    this.feeCurrency = 'USDC',
    this.isFeeWaived = false,
    this.waiverReason,
  });

  static const zero = SendFee(
    networkFee: 0,
    serviceFee: 0,
    totalFee: 0,
  );
}

class SendFeeParams {
  final double amount;
  final String recipientType; // internal, external, bank
  final String? destinationCountry;

  const SendFeeParams({
    required this.amount,
    this.recipientType = 'internal',
    this.destinationCountry,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendFeeParams &&
          amount == other.amount &&
          recipientType == other.recipientType &&
          destinationCountry == other.destinationCountry;

  @override
  int get hashCode =>
      amount.hashCode ^ recipientType.hashCode ^ destinationCountry.hashCode;
}

final sendFeeProvider =
    FutureProvider.family<SendFee, SendFeeParams>((ref, params) async {
  if (params.amount <= 0) return SendFee.zero;

  await Future.delayed(const Duration(milliseconds: 300));

  // Internal transfers are free
  if (params.recipientType == 'internal') {
    return const SendFee(
      networkFee: 0,
      serviceFee: 0,
      totalFee: 0,
      isFeeWaived: true,
      waiverReason: 'Transfert interne gratuit',
    );
  }

  // External transfers have network fees
  final networkFee = params.recipientType == 'external' ? 0.50 : 0.0;
  final serviceFee = params.amount * 0.005; // 0.5%
  final total = networkFee + serviceFee;

  return SendFee(
    networkFee: networkFee,
    serviceFee: serviceFee,
    totalFee: total,
  );
});
