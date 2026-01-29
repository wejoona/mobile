/// External Transfer Request Models

/// Network options for USDC transfers
enum NetworkOption {
  polygon('polygon', 'Polygon', 0.01, '1-2 minutes'),
  ethereum('ethereum', 'Ethereum', 2.5, '5-10 minutes');

  final String value;
  final String displayName;
  final double estimatedFee;
  final String estimatedTime;

  const NetworkOption(
    this.value,
    this.displayName,
    this.estimatedFee,
    this.estimatedTime,
  );

  static NetworkOption fromString(String value) {
    return NetworkOption.values.firstWhere(
      (e) => e.value == value,
      orElse: () => NetworkOption.polygon,
    );
  }
}

/// External Transfer Request
class ExternalTransferRequest {
  final String address;
  final double amount;
  final NetworkOption network;
  final String? note;

  const ExternalTransferRequest({
    required this.address,
    required this.amount,
    this.network = NetworkOption.polygon,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'address': address,
        'amount': amount,
        'network': network.value,
        if (note != null) 'note': note,
      };

  ExternalTransferRequest copyWith({
    String? address,
    double? amount,
    NetworkOption? network,
    String? note,
  }) {
    return ExternalTransferRequest(
      address: address ?? this.address,
      amount: amount ?? this.amount,
      network: network ?? this.network,
      note: note ?? this.note,
    );
  }
}

/// External Transfer Result
class ExternalTransferResult {
  final String transactionId;
  final String txHash;
  final String status;
  final double fee;
  final NetworkOption network;
  final DateTime timestamp;

  const ExternalTransferResult({
    required this.transactionId,
    required this.txHash,
    required this.status,
    required this.fee,
    required this.network,
    required this.timestamp,
  });

  factory ExternalTransferResult.fromJson(Map<String, dynamic> json) {
    return ExternalTransferResult(
      transactionId: json['transactionId'] as String? ?? json['id'] as String,
      txHash: json['txHash'] as String,
      status: json['status'] as String,
      fee: (json['fee'] as num).toDouble(),
      network: NetworkOption.fromString(json['network'] as String? ?? 'polygon'),
      timestamp: DateTime.parse(
        json['timestamp'] as String? ?? json['createdAt'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'txHash': txHash,
        'status': status,
        'fee': fee,
        'network': network.value,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Address Validation Result
class AddressValidationResult {
  final bool isValid;
  final String? error;

  const AddressValidationResult({
    required this.isValid,
    this.error,
  });

  factory AddressValidationResult.valid() => const AddressValidationResult(isValid: true);

  factory AddressValidationResult.invalid(String error) =>
      AddressValidationResult(isValid: false, error: error);
}
