import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/router/routes/auth_state_routes.dart';
import 'package:usdc_wallet/router/routes/business_utility_routes.dart';
import 'package:usdc_wallet/router/routes/commerce_routes.dart';
import 'package:usdc_wallet/router/routes/feature_overview_routes.dart';
import 'package:usdc_wallet/router/routes/kyc_settings_routes.dart';
import 'package:usdc_wallet/router/routes/primary_wallet_routes.dart';
import 'package:usdc_wallet/router/routes/savings_recurring_routes.dart';

/// Top-level application routes in their matching order.
List<RouteBase> buildAppRoutes({bool? includeDevelopmentRoutes}) {
  final includeDevRoutes =
      includeDevelopmentRoutes ?? !EnvironmentConfig.isProduction;

  return [
    ...authStateRoutes(),
    ...primaryWalletRoutes(),
    ...kycSettingsRoutes(),
    ...featureOverviewRoutes(),
    ...savingsRecurringRoutes(),
    ...commerceRoutes(),
    ...businessUtilityRoutes(includeDevelopmentRoutes: includeDevRoutes),
  ];
}
