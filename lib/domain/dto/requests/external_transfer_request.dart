/// Request DTO for sending an external (on-chain) transfer.
class ExternalTransferRequest {
  final String destinationAddress;
  final double amount;
  final String currency;
  final String network;
  final String? memo;

  const ExternalTransferRequest({
    required this.destinationAddress,
    required this.amount,
    this.currency = 'USDC',
    this.network = 'stellar',
    this.memo,
  });

  Map<String, dynamic> toJson() => {
        'destinationAddress': destinationAddress,
        'amount': amount,
        'currency': currency,
        'network': network,
        if (memo != null) 'memo': memo,
      };
}
