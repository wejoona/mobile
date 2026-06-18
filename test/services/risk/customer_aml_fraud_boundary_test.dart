import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/risk/risk_profile_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('customer AML/fraud API boundary', () {
    test('customer UI and providers do not call dormant AML or fraud APIs', () {
      final roots = [
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/providers'),
      ];

      final offenders = <String>{};
      for (final root in roots) {
        if (!root.existsSync()) {
          continue;
        }
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }

          final content = entity.readAsStringSync();
          if (content.contains("'/aml/") ||
              content.contains('"/aml/') ||
              content.contains("'/fraud/") ||
              content.contains('"/fraud/') ||
              content.contains("'/risk/screen-address'") ||
              content.contains('"/risk/screen-address"') ||
              content.contains('services/aml/') ||
              content.contains('services/fraud/')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Customer UI/provider code must not depend on dormant AML, fraud, '
            'or address-screening API routes. Use backend-owned /step-up/*, '
            '/risk/session, /risk/profile, or /security/addresses routes only.',
      );
    });

    test(
      'risk profile service uses the current-user backend contract',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'success': true,
            'data': {
              'userId': 'usr_risk',
              'overallRiskScore': 50,
              'riskLevel': 'medium',
              'riskFactors': ['risk_profile_unavailable'],
              'screeningStatus': 'clear',
              'updatedAt': '2026-06-18T10:00:00.000Z',
            },
          });
        final service = RiskProfileService(dio: dio);

        final profile = await service.getProfile();

        expect(dio.requestHistory.single.method, 'GET');
        expect(dio.requestHistory.single.path, '/risk/profile');
        expect(profile, isNotNull);
        expect(profile!.userId, 'usr_risk');
        expect(profile.rating, CustomerRiskRating.medium);
        expect(profile.overallScore, 50);
        expect(profile.riskFactors, ['risk_profile_unavailable']);
        expect(profile.reviewNotes, 'clear');
      },
    );

    test(
      'risk profile refresh does not call a nonexistent API route',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'success': true,
            'data': {
              'userId': 'usr_risk',
              'overallRiskScore': 40,
              'riskLevel': 'low',
              'updatedAt': '2026-06-18T10:00:00.000Z',
            },
          });
        final service = RiskProfileService(dio: dio);

        final profile = await service.refreshProfile();

        expect(dio.requestHistory.single.method, 'GET');
        expect(dio.requestHistory.single.path, '/risk/profile');
        expect(profile!.rating, CustomerRiskRating.low);
      },
    );

    test(
      'active customer risk service remains tied to verified step-up routes',
      () {
        final riskService = File(
          'lib/services/security/risk_based_security_service.dart',
        ).readAsStringSync();

        expect(riskService, contains("'/step-up/transaction'"));
        expect(riskService, contains("'/step-up/operation'"));
        expect(riskService, contains("'/step-up/validate'"));
        expect(riskService, isNot(contains("'/aml/")));
        expect(riskService, isNot(contains("'/fraud/")));
      },
    );

    test('customer security code does not redirect to a dead step-up page', () {
      final roots = [
        Directory('lib/core'),
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/services/security'),
      ];

      final offenders = <String>{};
      for (final root in roots) {
        if (!root.existsSync()) {
          continue;
        }
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }

          final content = entity.readAsStringSync();
          if (content.contains('/step-up-auth')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Risk step-up must use the implemented backend-backed /step-up/* '
            'dialog flow, not a missing /step-up-auth route.',
      );
    });

    test('mobile risk clients expose only live customer API routes', () {
      final roots = [
        Directory('lib/services/risk'),
        Directory('lib/services/security'),
      ];

      final forbiddenFragments = [
        '/risk/device/bind',
        '/risk/device/binding',
        '/risk/device/bindings',
        '/risk/device/score',
        '/risk/geo/',
        '/risk/transaction/score',
        '/risk/sim-change',
        '/risk/sim-swap/verify',
        '/risk/screen-address',
      ];
      final offenders = <String>{};

      for (final root in roots) {
        if (!root.existsSync()) {
          continue;
        }
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }

          final content = entity.readAsStringSync();
          if (forbiddenFragments.any(content.contains)) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Mobile risk code must not call speculative or removed risk API '
            'routes. Use /risk/session, /risk/profile, and /step-up/*; final '
            'money/compliance screening stays backend-owned.',
      );
    });

    test('address pre-screening helper is not wired into customer screens', () {
      final roots = [
        Directory('lib/features'),
        Directory('lib/router'),
        Directory('lib/providers'),
        Directory('lib/services/transfers'),
      ];

      final offenders = <String>{};
      for (final root in roots) {
        if (!root.existsSync()) {
          continue;
        }
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) {
            continue;
          }

          final content = entity.readAsStringSync();
          if (content.contains('screenAddress(') ||
              content.contains('isAddressSafe(')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(
        offenders.toList()..sort(),
        isEmpty,
        reason:
            'Address pre-screening must stay inactive until the backend exposes '
            'a mobile-safe route. Final address screening stays server-side.',
      );
    });
  });
}
