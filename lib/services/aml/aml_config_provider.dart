import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Configuration AML côté client
class AmlConfig {
  final double ctrThreshold;
  final int maxDailyTransactions;
  final double maxDailyAmount;
  final double maxSingleTransaction;
  final List<String> highRiskCountries;
  final bool enhancedMonitoringEnabled;
  final Duration screeningCacheTtl;

  const AmlConfig({
    this.ctrThreshold = 5000000.0,
    this.maxDailyTransactions = 50,
    this.maxDailyAmount = 10000000.0,
    this.maxSingleTransaction = 5000000.0,
    this.highRiskCountries = const [],
    this.enhancedMonitoringEnabled = true,
    this.screeningCacheTtl = const Duration(hours: 24),
  });

  factory AmlConfig.fromJson(Map<String, dynamic> json) => AmlConfig(
    ctrThreshold: (json['ctrThreshold'] as num?)?.toDouble() ?? 5000000.0,
    maxDailyTransactions: json['maxDailyTransactions'] as int? ?? 50,
    maxDailyAmount: (json['maxDailyAmount'] as num?)?.toDouble() ?? 10000000.0,
    maxSingleTransaction: (json['maxSingleTransaction'] as num?)?.toDouble() ?? 5000000.0,
    highRiskCountries: List<String>.from(json['highRiskCountries'] ?? []),
    enhancedMonitoringEnabled: json['enhancedMonitoringEnabled'] as bool? ?? true,
  );
}

/// Fournisseur de configuration AML
class AmlConfigProvider {
  static const _tag = 'AmlConfig';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  AmlConfig? _cachedConfig;

  AmlConfigProvider({required Dio dio}) : _dio = dio;

  Future<AmlConfig> getConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;
    try {
      final response = await _dio.get('/aml/config');
      _cachedConfig = AmlConfig.fromJson(response.data as Map<String, dynamic>);
      return _cachedConfig!;
    } catch (e) {
      _log.error('Failed to fetch AML config', e);
      return const AmlConfig();
    }
  }

  void invalidateCache() => _cachedConfig = null;
}

final amlConfigProvider = Provider<AmlConfigProvider>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
