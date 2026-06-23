import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/router/app_routes.dart';

void main() {
  test('buildAppRoutes exposes critical Korido routes once', () {
    final paths = _flattenPaths(buildAppRoutes());

    expect(paths, contains('/'));
    expect(paths, contains('/login'));
    expect(paths, contains('/signup'));
    expect(paths, contains('/signup/legal-consent'));
    expect(paths, contains('/legal/terms'));
    expect(paths, contains('/legal/privacy'));
    expect(paths, contains('/signup/verify-phone'));
    expect(paths, contains('/onboarding'));
    expect(paths, contains('/onboarding/phone'));
    expect(paths, contains('/home'));
    expect(paths, contains('/send'));
    expect(paths, contains('/deposit'));
    expect(paths, contains('/kyc'));
    expect(paths, contains('/contacts'));
    expect(paths, contains('/payment-links'));
    expect(paths, contains('/savings-pots'));
    expect(paths, contains('/recurring-transfers'));
    expect(paths, contains('/bill-payments'));
    expect(paths, contains('/beneficiaries'));
    expect(paths, contains('/bank-linking'));

    expect(paths.length, paths.toSet().length);
  });

  test('top-level route groups stay in the expected order', () {
    final topLevelPaths = buildAppRoutes()
        .map(
          (route) => switch (route) {
            GoRoute(:final path) => path,
            ShellRoute() => '<shell>',
            _ => '<unknown>',
          },
        )
        .toList();

    expect(topLevelPaths.take(5), [
      '/',
      '/profile-complete',
      '/onboarding',
      '/signup',
      '/signup/legal-consent',
    ]);
    expect(topLevelPaths.skip(5).take(4), [
      '/legal/terms',
      '/legal/privacy',
      '/signup/verify-phone',
      '/signup/profile',
    ]);
    expect(
      topLevelPaths,
      containsAll(['/onboarding/phone', '/onboarding/otp']),
    );
    expect(
      topLevelPaths.indexOf('<shell>'),
      lessThan(topLevelPaths.indexOf('/services')),
    );
    expect(
      topLevelPaths.indexOf('/kyc'),
      lessThan(topLevelPaths.indexOf('/request')),
    );
    expect(
      topLevelPaths.indexOf('/savings-pots'),
      lessThan(topLevelPaths.indexOf('/scan-to-pay')),
    );
  });

  test('development-only catalog route is excluded from production routes', () {
    final productionPaths = _flattenPaths(
      buildAppRoutes(includeDevelopmentRoutes: false),
    );
    final developmentPaths = _flattenPaths(
      buildAppRoutes(includeDevelopmentRoutes: true),
    );

    expect(productionPaths, isNot(contains('/catalog')));
    expect(developmentPaths, contains('/catalog'));
  });

  test('default route assembly follows the configured environment', () {
    final paths = _flattenPaths(buildAppRoutes());

    if (EnvironmentConfig.isProduction) {
      expect(paths, isNot(contains('/catalog')));
    } else {
      expect(paths, contains('/catalog'));
    }
  });
}

List<String> _flattenPaths(List<RouteBase> routes) {
  final paths = <String>[];
  for (final route in routes) {
    switch (route) {
      case GoRoute(:final path, :final routes):
        paths.add(path);
        paths.addAll(_flattenPaths(routes));
      case ShellRoute(:final routes):
        paths.addAll(_flattenPaths(routes));
      default:
        throw StateError('Unsupported route type: ${route.runtimeType}');
    }
  }
  return paths;
}
