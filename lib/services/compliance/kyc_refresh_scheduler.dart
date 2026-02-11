import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

class KycRefreshSchedule {
  final String userId;
  final DateTime nextRefreshDate;
  final String riskRating;
  final int daysUntilRefresh;
  final bool isOverdue;

  const KycRefreshSchedule({
    required this.userId,
    required this.nextRefreshDate,
    required this.riskRating,
    required this.daysUntilRefresh,
    required this.isOverdue,
  });

  factory KycRefreshSchedule.fromJson(Map<String, dynamic> json) => KycRefreshSchedule(
    userId: json['userId'] as String,
    nextRefreshDate: DateTime.parse(json['nextRefreshDate'] as String),
    riskRating: json['riskRating'] as String,
    daysUntilRefresh: json['daysUntilRefresh'] as int,
    isOverdue: json['isOverdue'] as bool? ?? false,
  );
}

/// Planificateur de renouvellement KYC.
///
/// Suit les dates de renouvellement KYC selon le profil
/// de risque: haut risque = 1 an, moyen = 2 ans, faible = 3 ans.
class KycRefreshScheduler {
  static const _tag = 'KycRefresh';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  KycRefreshScheduler({required Dio dio}) : _dio = dio;

  Future<KycRefreshSchedule?> getSchedule() async {
    try {
      final response = await _dio.get('/compliance/kyc/refresh-schedule');
      return KycRefreshSchedule.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to get KYC refresh schedule', e);
      return null;
    }
  }

  /// Durée de validité KYC par niveau de risque
  static Duration getRefreshPeriod(String riskRating) {
    switch (riskRating) {
      case 'high': return const Duration(days: 365);
      case 'medium': return const Duration(days: 730);
      case 'low': return const Duration(days: 1095);
      default: return const Duration(days: 365);
    }
  }
}

final kycRefreshSchedulerProvider = Provider<KycRefreshScheduler>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
