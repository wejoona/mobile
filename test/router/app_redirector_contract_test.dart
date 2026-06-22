import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appRedirect route contract guard', () {
    test('applies FSM route guards before legacy route-specific fallbacks', () {
      final source = File('lib/router/app_redirector.dart').readAsStringSync();

      final routeGuardCall = source.indexOf(
        'final routeGuardRedirect = _routeGuardRedirect',
      );
      final verifiedKycFallback = source.indexOf('_requiresVerifiedKycPath');
      final featureFlagFallback = source.indexOf(
        'return _featureFlagRedirect(location, flags);',
      );

      expect(routeGuardCall, greaterThanOrEqualTo(0));
      expect(verifiedKycFallback, greaterThanOrEqualTo(0));
      expect(featureFlagFallback, greaterThanOrEqualTo(0));
      expect(
        routeGuardCall,
        lessThan(verifiedKycFallback),
        reason:
            'Route contracts must own money/KYC denial before legacy route-specific KYC checks run.',
      );
      expect(
        routeGuardCall,
        lessThan(featureFlagFallback),
        reason:
            'Disabled-feature fallbacks must not allow gated money routes to bypass FSM guards.',
      );
      expect(
        source,
        contains('AppGuards(appFsmState).canAccessRoute(location)'),
      );
      expect(source, contains('guardResult is GuardDenied'));
      expect(source, contains('return guardResult.redirectTo;'));
    });
  });
}
