import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'guard_base.dart';

/// Restricts actions based on geographic location.
class GeoRestrictionGuard extends GuardBase {
  static const _tag = 'GeoGuard';
  final AppLogger _log = AppLogger(_tag);

  /// UEMOA member countries
  static const allowedCountries = ['CI', 'BJ', 'BF', 'GW', 'ML', 'NE', 'SN', 'TG'];

  @override
  String get name => 'geo_restriction';

  @override
  Future<GuardResult> check(GuardContext context) async {
    final country = context.params['countryCode'] as String?;
    if (country == null) {
      return const GuardResult.deny('Impossible de déterminer votre localisation');
    }
    if (!allowedCountries.contains(country)) {
      _log.warn('Geo restriction: $country not in UEMOA zone');
      return const GuardResult.deny('Service non disponible dans votre pays');
    }
    return const GuardResult.allow();
  }
}

final geoRestrictionGuardProvider = Provider<GeoRestrictionGuard>((ref) {
  return GeoRestrictionGuard();
});
