import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Pattern de transaction détecté
enum TransactionPattern {
  normal,
  structuring,
  layering,
  rapidMovement,
  roundTripping,
  fanOut,
  fanIn,
  dormantToActive,
}

class PatternAnalysisResult {
  final TransactionPattern pattern;
  final double confidence;
  final String description;
  final List<String> involvedTransactions;

  const PatternAnalysisResult({
    required this.pattern,
    required this.confidence,
    required this.description,
    this.involvedTransactions = const [],
  });
}

/// Analyseur de patterns de transactions.
///
/// Détecte les schémas de blanchiment d'argent courants:
/// structuration, superposition (layering), mouvement rapide.
class TransactionPatternAnalyzer {
  static const _tag = 'PatternAnalyzer';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);

  /// Analyser un ensemble de transactions
  List<PatternAnalysisResult> analyze(List<TransactionData> transactions) {
    final results = <PatternAnalysisResult>[];

    results.addAll(_detectStructuring(transactions));
    results.addAll(_detectRapidMovement(transactions));
    results.addAll(_detectFanOutFanIn(transactions));

    return results;
  }

  List<PatternAnalysisResult> _detectStructuring(List<TransactionData> txns) {
    // Structuration: multiples transactions juste en dessous du seuil
    final threshold = 4900000.0;
    final suspicious = txns.where((t) =>
      t.amount > threshold * 0.8 && t.amount < threshold).toList();
    if (suspicious.length >= 3) {
      return [PatternAnalysisResult(
        pattern: TransactionPattern.structuring,
        confidence: 0.8,
        description: '${suspicious.length} transactions proches du seuil CTR',
        involvedTransactions: suspicious.map((t) => t.id).toList(),
      )];
    }
    return [];
  }

  List<PatternAnalysisResult> _detectRapidMovement(List<TransactionData> txns) {
    // Mouvement rapide: fonds reçus et envoyés en moins d'1h
    final results = <PatternAnalysisResult>[];
    for (final txn in txns.where((t) => t.isIncoming)) {
      final quickSends = txns.where((t) =>
        !t.isIncoming &&
        t.timestamp.difference(txn.timestamp).inMinutes.abs() < 60 &&
        t.amount >= txn.amount * 0.8).toList();
      if (quickSends.isNotEmpty) {
        results.add(PatternAnalysisResult(
          pattern: TransactionPattern.rapidMovement,
          confidence: 0.7,
          description: 'Fonds reçus et transférés en moins d\'1 heure',
          involvedTransactions: [txn.id, ...quickSends.map((t) => t.id)],
        ));
      }
    }
    return results;
  }

  List<PatternAnalysisResult> _detectFanOutFanIn(List<TransactionData> txns) {
    // Fan-out: un envoi vers de nombreux destinataires
    final outgoing = txns.where((t) => !t.isIncoming).toList();
    final uniqueRecipients = outgoing.map((t) => t.counterpartyId).toSet();
    if (outgoing.length > 5 && uniqueRecipients.length >= outgoing.length * 0.8) {
      return [PatternAnalysisResult(
        pattern: TransactionPattern.fanOut,
        confidence: 0.6,
        description: 'Distribution vers ${uniqueRecipients.length} bénéficiaires uniques',
        involvedTransactions: outgoing.map((t) => t.id).toList(),
      )];
    }
    return [];
  }
}

class TransactionData {
  final String id;
  final double amount;
  final DateTime timestamp;
  final bool isIncoming;
  final String counterpartyId;

  const TransactionData({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.isIncoming,
    required this.counterpartyId,
  });
}

final transactionPatternAnalyzerProvider = Provider<TransactionPatternAnalyzer>((ref) {
  return TransactionPatternAnalyzer();
});
