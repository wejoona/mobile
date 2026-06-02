import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/router/routes/card_account_routes.dart';
import 'package:usdc_wallet/router/routes/money_movement_routes.dart';
import 'package:usdc_wallet/router/routes/primary_shell_routes.dart';

List<RouteBase> primaryWalletRoutes() => [
  ...primaryShellRoutes(),
  ...moneyMovementRoutes(),
  ...cardAccountRoutes(),
];
