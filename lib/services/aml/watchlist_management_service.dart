import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

enum WatchlistType { internal, sanctions, pep, adverseMedia }

class WatchlistEntry {
  final String entryId;
  final WatchlistType type;
  final String name;
  final String? reason;
  final DateTime addedAt;
  final DateTime? expiresAt;

  const WatchlistEntry({
    required this.entryId,
    required this.type,
    required this.name,
    this.reason,
    required this.addedAt,
    this.expiresAt,
  });

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    entryId: json['entryId'] as String,
    type: WatchlistType.values.byName(json['type'] as String),
    name: json['name'] as String,
    reason: json['reason'] as String?,
    addedAt: DateTime.parse(json['addedAt'] as String),
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
  );
}

/// Service de gestion des listes de surveillance.
class WatchlistManagementService {
  static const _tag = 'Watchlist';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  WatchlistManagementService({required Dio dio}) : _dio = dio;

  Future<bool> isOnWatchlist({required String name}) async {
    try {
      final response = await _dio.post('/aml/watchlist/check', data: {'name': name});
      return (response.data as Map<String, dynamic>)['onWatchlist'] as bool? ?? false;
    } catch (e) {
      _log.error('Watchlist check failed', e);
      return false;
    }
  }

  Future<List<WatchlistEntry>> getWatchlist() async {
    try {
      final response = await _dio.get('/aml/watchlist');
      return (response.data as List)
          .map((e) => WatchlistEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch watchlist', e);
      return [];
    }
  }
}

final watchlistManagementProvider = Provider<WatchlistManagementService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
