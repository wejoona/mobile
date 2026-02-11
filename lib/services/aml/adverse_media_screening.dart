import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class AdverseMediaResult {
  final String entityName;
  final bool hasAdverseMedia;
  final List<AdverseMediaHit> hits;
  final DateTime screenedAt;

  const AdverseMediaResult({
    required this.entityName,
    required this.hasAdverseMedia,
    this.hits = const [],
    required this.screenedAt,
  });
}

class AdverseMediaHit {
  final String source;
  final String title;
  final String? summary;
  final String category;
  final DateTime publishedAt;
  final double relevanceScore;

  const AdverseMediaHit({
    required this.source,
    required this.title,
    this.summary,
    required this.category,
    required this.publishedAt,
    required this.relevanceScore,
  });

  factory AdverseMediaHit.fromJson(Map<String, dynamic> json) => AdverseMediaHit(
    source: json['source'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String?,
    category: json['category'] as String,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    relevanceScore: (json['relevanceScore'] as num).toDouble(),
  );
}

/// Service de filtrage des médias défavorables.
///
/// Recherche les mentions négatives d'un individu
/// dans les médias pour le processus EDD.
class AdverseMediaScreeningService {
  static const _tag = 'AdverseMedia';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AdverseMediaScreeningService({required Dio dio}) : _dio = dio;

  Future<AdverseMediaResult> screen({
    required String name,
    String? country,
  }) async {
    try {
      final response = await _dio.post('/aml/adverse-media/screen', data: {
        'name': name,
        if (country != null) 'country': country,
      });
      final data = response.data as Map<String, dynamic>;
      return AdverseMediaResult(
        entityName: name,
        hasAdverseMedia: data['hasAdverseMedia'] as bool? ?? false,
        hits: (data['hits'] as List?)
            ?.map((e) => AdverseMediaHit.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Adverse media screening failed', e);
      return AdverseMediaResult(
        entityName: name,
        hasAdverseMedia: false,
        screenedAt: DateTime.now(),
      );
    }
  }
}

final adverseMediaScreeningProvider = Provider<AdverseMediaScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
