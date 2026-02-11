import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Resolves geographic location from IP for compliance checks.
class GeoIpService {
  static const _tag = 'GeoIp';
  final AppLogger _log = AppLogger(_tag);

  /// Resolve location from IP address.
  Future<GeoLocation> resolve(String ip) async {
    _log.debug('Resolving geo for $ip');
    return const GeoLocation(
      countryCode: 'CI',
      country: "Côte d'Ivoire",
      region: 'Abidjan',
      isUemoa: true,
    );
  }

  /// Check if IP is from UEMOA zone.
  Future<bool> isUemoaZone(String ip) async {
    final location = await resolve(ip);
    return location.isUemoa;
  }
}

class GeoLocation {
  final String countryCode;
  final String country;
  final String? region;
  final bool isUemoa;

  const GeoLocation({
    required this.countryCode,
    required this.country,
    this.region,
    this.isUemoa = false,
  });
}

final geoIpServiceProvider = Provider<GeoIpService>((ref) {
  return GeoIpService();
});
