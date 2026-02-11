/// BCEAO (Banque Centrale des Etats de l'Afrique de l'Ouest) reporting models.
///
/// These models conform to BCEAO regulatory reporting requirements
/// for electronic money institutions operating in the UEMOA zone.

/// Transaction report entry for BCEAO daily reporting.
class BceaoTransactionReport {
  final String reportId;
  final DateTime reportDate;
  final String institutionCode;
  final List<BceaoTransactionEntry> entries;
  final double totalVolumeCfa;
  final int totalCount;
  final ReportStatus status;

  const BceaoTransactionReport({
    required this.reportId,
    required this.reportDate,
    required this.institutionCode,
    required this.entries,
    required this.totalVolumeCfa,
    required this.totalCount,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'reportDate': reportDate.toIso8601String(),
    'institutionCode': institutionCode,
    'entries': entries.map((e) => e.toJson()).toList(),
    'totalVolumeCfa': totalVolumeCfa,
    'totalCount': totalCount,
    'status': status.name,
  };
}

/// Individual transaction entry in BCEAO report.
class BceaoTransactionEntry {
  final String transactionId;
  final DateTime timestamp;
  final String senderAccount;
  final String receiverAccount;
  final double amountCfa;
  final String currency;
  final TransactionCategory category;
  final bool isCrossBorder;
  final String? originCountry;
  final String? destinationCountry;

  const BceaoTransactionEntry({
    required this.transactionId,
    required this.timestamp,
    required this.senderAccount,
    required this.receiverAccount,
    required this.amountCfa,
    this.currency = 'XOF',
    required this.category,
    this.isCrossBorder = false,
    this.originCountry,
    this.destinationCountry,
  });

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'timestamp': timestamp.toIso8601String(),
    'senderAccount': senderAccount,
    'receiverAccount': receiverAccount,
    'amountCfa': amountCfa,
    'currency': currency,
    'category': category.name,
    'isCrossBorder': isCrossBorder,
    if (originCountry != null) 'originCountry': originCountry,
    if (destinationCountry != null) 'destinationCountry': destinationCountry,
  };
}

enum TransactionCategory { transfer, withdrawal, deposit, payment, remittance }
enum ReportStatus { draft, submitted, accepted, rejected, amended }
