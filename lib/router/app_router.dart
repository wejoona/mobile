import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/router/app_redirector.dart';
import 'package:usdc_wallet/router/app_routes.dart';

/// App Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: EnvironmentConfig.verboseLogs,
    refreshListenable: refreshNotifier,
    observers: [SentryNavigatorObserver()],
    redirect: appRedirect,
    routes: buildAppRoutes(),
  );
});
