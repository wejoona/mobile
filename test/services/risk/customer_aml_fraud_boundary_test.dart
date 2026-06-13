import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
