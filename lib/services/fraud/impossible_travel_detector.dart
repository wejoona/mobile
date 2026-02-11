import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Résultat de détection de voyage impossible
class ImpossibleTravelResult {
  final bool isImpossible;
  final double distanceKm;
  final Duration timeBetween;
  final double requiredSpeedKmh;
  final String? fromLocation;
  final String? toLocation;

  const ImpossibleTravelResult({
    required this.isImpossible,
    required this.distanceKm,
    required this.timeBetween,
    required this.requiredSpeedKmh,
    this.fromLocation,
    this.toLocation,
  });
}

/// Détecteur de voyage impossible.
///
/// Identifie les connexions depuis des emplacements
/// géographiquement impossibles dans un laps de temps donné.
class ImpossibleTravelDetector {
  static const _tag = 'ImpossibleTravel';
  final AppLogger _log = AppLogger(_tag);
  static const double _maxReasonableSpeedKmh = 900.0; // Vitesse d'avion

  /// Vérifier si le déplacement est physiquement possible
  ImpossibleTravelResult check({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
    required DateTime fromTime,
    required DateTime toTime,
  }) {
    final distance = _haversineDistance(fromLat, fromLon, toLat, toLon);
    final duration = toTime.difference(fromTime);
    final hours = duration.inMinutes / 60.0;
    final requiredSpeed = hours > 0 ? distance / hours : double.infinity;

    return ImpossibleTravelResult(
      isImpossible: requiredSpeed > _maxReasonableSpeedKmh,
      distanceKm: distance,
      timeBetween: duration,
      requiredSpeedKmh: requiredSpeed,
    );
  }

  /// Formule de Haversine pour la distance entre deux points
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Rayon de la Terre en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

final impossibleTravelDetectorProvider = Provider<ImpossibleTravelDetector>((ref) {
  return ImpossibleTravelDetector();
});
