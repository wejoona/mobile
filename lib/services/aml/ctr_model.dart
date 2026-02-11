/// Statut du rapport CTR
enum CtrStatus { draft, submitted, acknowledged, rejected }

/// Modèle de rapport de transaction en espèces (CTR).
///
/// Déclaration automatique des transactions dépassant le seuil
/// réglementaire BCEAO (typiquement 5 000 000 FCFA).
class CurrencyTransactionReport {
  final String reportId;
  final String transactionId;
  final String userId;
  final double amount;
  final String currency;
  final String transactionType;
  final DateTime transactionDate;
  final CtrStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? filingReference;
  final Map<String, dynamic> transactionDetails;
  final Map<String, dynamic> customerInfo;

  const CurrencyTransactionReport({
    required this.reportId,
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.transactionType,
    required this.transactionDate,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.filingReference,
    this.transactionDetails = const {},
    this.customerInfo = const {},
  });

  factory CurrencyTransactionReport.fromJson(Map<String, dynamic> json) {
    return CurrencyTransactionReport(
      reportId: json['reportId'] as String,
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionType: json['transactionType'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: CtrStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String) : null,
      filingReference: json['filingReference'] as String?,
      transactionDetails: Map<String, dynamic>.from(json['transactionDetails'] ?? {}),
      customerInfo: Map<String, dynamic>.from(json['customerInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'transactionId': transactionId,
    'userId': userId,
    'amount': amount,
    'currency': currency,
    'transactionType': transactionType,
    'transactionDate': transactionDate.toIso8601String(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
    if (filingReference != null) 'filingReference': filingReference,
    'transactionDetails': transactionDetails,
    'customerInfo': customerInfo,
  };

  /// Seuil BCEAO pour déclaration automatique (en FCFA)
  static const double bceaoThreshold = 5000000.0;

  /// Vérifier si le montant dépasse le seuil
  static bool exceedsThreshold(double amount) => amount >= bceaoThreshold;
}
