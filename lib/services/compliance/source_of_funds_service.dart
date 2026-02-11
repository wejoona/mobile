import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Source of funds categories per BCEAO requirements.
enum FundsSource {
  salary,
  business,
  investment,
  savings,
  gift,
  inheritance,
  sale,
  other,
}

/// Source of funds declaration.
class FundsDeclaration {
  final String id;
  final FundsSource source;
  final String description;
  final double amountCfa;
  final String? documentUrl;
  final DateTime declaredAt;
  final bool verified;

  const FundsDeclaration({
    required this.id,
    required this.source,
    required this.description,
    required this.amountCfa,
    this.documentUrl,
    required this.declaredAt,
    this.verified = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'source': source.name,
    'description': description,
    'amountCfa': amountCfa,
    'documentUrl': documentUrl,
    'declaredAt': declaredAt.toIso8601String(),
    'verified': verified,
  };
}

/// Manages source of funds declarations for large transactions.
///
/// Required by BCEAO for transactions above reporting thresholds
/// and for KYC tier upgrades.
class SourceOfFundsService {
  static const _tag = 'SourceOfFunds';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  /// Threshold above which source of funds is required (XOF).
  static const double _declarationThreshold = 2000000;

  SourceOfFundsService({required Dio dio}) : _dio = dio;

  /// Check if a declaration is required for the given amount.
  bool isDeclarationRequired(double amountCfa) {
    return amountCfa >= _declarationThreshold;
  }

  /// Submit a source of funds declaration.
  Future<bool> submitDeclaration(FundsDeclaration declaration) async {
    try {
      await _dio.post('/compliance/source-of-funds', data: declaration.toJson());
      _log.debug('Source of funds declaration submitted: ${declaration.id}');
      return true;
    } catch (e) {
      _log.error('Failed to submit source of funds declaration', e);
      return false;
    }
  }

  /// Get existing declarations for the user.
  Future<List<FundsDeclaration>> getDeclarations() async {
    try {
      final response = await _dio.get('/compliance/source-of-funds');
      // Would parse response into FundsDeclaration objects
      return [];
    } catch (e) {
      _log.error('Failed to fetch declarations', e);
      return [];
    }
  }
}

final sourceOfFundsServiceProvider =
    Provider<SourceOfFundsService>((ref) {
  return SourceOfFundsService(dio: Dio());
});
