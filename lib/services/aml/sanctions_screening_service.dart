import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Type de liste de sanctions
enum SanctionsList {
  ofac,
  eu,
  un,
  uemoa,
  bceao,
  localCiv,
}

/// Résultat du filtrage des sanctions
class SanctionsScreeningResult {
  final String entityName;
  final bool isMatch;
  final double matchConfidence;
  final List<SanctionsList> matchedLists;
  final String? matchDetails;
  final DateTime screenedAt;

  const SanctionsScreeningResult({
    required this.entityName,
    required this.isMatch,
    this.matchConfidence = 0.0,
    this.matchedLists = const [],
    this.matchDetails,
    required this.screenedAt,
  });
}

/// Service de filtrage des sanctions.
///
/// Vérifie les contreparties contre les listes de sanctions
/// internationales et régionales (UEMOA, BCEAO, OFAC, UE, ONU).
class SanctionsScreeningService {
  static const _tag = 'SanctionsScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  SanctionsScreeningService({required Dio dio}) : _dio = dio;

  /// Filtrer une entité contre toutes les listes de sanctions
  Future<SanctionsScreeningResult> screenEntity({
    required String name,
    String? dateOfBirth,
    String? nationality,
    String? idNumber,
  }) async {
    try {
      final response = await _dio.post('/aml/sanctions/screen', data: {
        'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (nationality != null) 'nationality': nationality,
        if (idNumber != null) 'idNumber': idNumber,
      });
      final data = response.data as Map<String, dynamic>;
      return SanctionsScreeningResult(
        entityName: name,
        isMatch: data['isMatch'] as bool? ?? false,
        matchConfidence: (data['matchConfidence'] as num?)?.toDouble() ?? 0.0,
        matchedLists: (data['matchedLists'] as List?)
            ?.map((e) => SanctionsList.values.byName(e as String))
            .toList() ?? [],
        matchDetails: data['matchDetails'] as String?,
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Sanctions screening failed', e);
      // Fail-safe: flag for manual review
      return SanctionsScreeningResult(
        entityName: name,
        isMatch: true,
        matchConfidence: 0.3,
        matchDetails: 'Screening service unavailable - manual review required',
        screenedAt: DateTime.now(),
      );
    }
  }

  /// Filtrer une adresse de portefeuille
  Future<SanctionsScreeningResult> screenWalletAddress({
    required String walletAddress,
    required String blockchain,
  }) async {
    try {
      final response = await _dio.post('/aml/sanctions/screen-wallet', data: {
        'walletAddress': walletAddress,
        'blockchain': blockchain,
      });
      final data = response.data as Map<String, dynamic>;
      return SanctionsScreeningResult(
        entityName: walletAddress,
        isMatch: data['isMatch'] as bool? ?? false,
        matchConfidence: (data['matchConfidence'] as num?)?.toDouble() ?? 0.0,
        matchedLists: (data['matchedLists'] as List?)
            ?.map((e) => SanctionsList.values.byName(e as String))
            .toList() ?? [],
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Wallet sanctions screening failed', e);
      return SanctionsScreeningResult(
        entityName: walletAddress,
        isMatch: false,
        matchConfidence: 0.0,
        screenedAt: DateTime.now(),
      );
    }
  }
}

final sanctionsScreeningProvider = Provider<SanctionsScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
