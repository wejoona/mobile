import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/features/cards/views/card_detail_view.dart';
import 'package:usdc_wallet/features/cards/views/card_settings_view.dart';
import 'package:usdc_wallet/features/cards/views/card_transactions_view.dart';
import 'package:usdc_wallet/features/cards/views/request_card_view.dart';
import 'package:usdc_wallet/features/deposit/models/deposit_response.dart';
import 'package:usdc_wallet/features/deposit/views/payment_instructions_screen.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_status_view.dart';
import 'package:usdc_wallet/features/notifications/views/notifications_view.dart';
import 'package:usdc_wallet/features/pin/models/pin_reset_route_context.dart';
import 'package:usdc_wallet/features/pin/views/enter_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_locked_view.dart';
import 'package:usdc_wallet/features/pin/views/reset_pin_view.dart';
import 'package:usdc_wallet/features/qr_payment/views/scan_qr_screen.dart';
import 'package:usdc_wallet/features/settings/views/change_pin_view.dart';
import 'package:usdc_wallet/features/settings/views/profile_view.dart';
import 'package:usdc_wallet/features/transactions/views/export_transactions_view.dart';
import 'package:usdc_wallet/features/transactions/views/transaction_detail_view.dart';
import 'package:usdc_wallet/features/wallet/views/receive_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> cardAccountRoutes() => [
  // Virtual Cards Routes
  GoRoute(
    path: '/cards/request',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const RequestCardView(),
    ),
  ),
  GoRoute(
    path: '/cards/detail/:id',
    pageBuilder: (context, state) {
      final cardId = state.pathParameters['id']!;
      return AppPageTransitions.horizontalSlide(
        state: state,
        child: CardDetailView(cardId: cardId),
      );
    },
  ),
  GoRoute(
    path: '/cards/settings/:id',
    pageBuilder: (context, state) {
      final cardId = state.pathParameters['id']!;
      return AppPageTransitions.horizontalSlide(
        state: state,
        child: CardSettingsView(cardId: cardId),
      );
    },
  ),
  GoRoute(
    path: '/cards/transactions/:id',
    pageBuilder: (context, state) {
      final cardId = state.pathParameters['id']!;
      return AppPageTransitions.horizontalSlide(
        state: state,
        child: CardTransactionsView(cardId: cardId),
      );
    },
  ),

  GoRoute(
    path: '/scan',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const ScanQrScreen(),
    ),
  ),
  GoRoute(
    path: '/receive',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const ReceiveView(),
    ),
  ),
  GoRoute(path: '/transfer/success', redirect: (_, _) => '/send/result'),
  GoRoute(path: '/transfer-success', redirect: (_, _) => '/send/result'),
  GoRoute(
    path: '/notifications',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const NotificationsView(),
    ),
  ),
  GoRoute(
    path: '/transactions/export',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const ExportTransactionsView(),
    ),
  ),
  GoRoute(
    path: '/transactions/:id',
    pageBuilder: (context, state) {
      final transactionId = state.pathParameters['id']!;
      final transaction = state.extra as Transaction?;
      final child = TransactionDetailRouteView(
        transactionId: transactionId,
        initialTransaction: transaction,
      );
      return AppPageTransitions.verticalSlide(state: state, child: child);
    },
  ),
  GoRoute(
    path: '/deposit/instructions',
    pageBuilder: (context, state) {
      final extra = state.extra;
      final initialResponse = extra is DepositResponse ? extra : null;
      return AppPageTransitions.verticalSlide(
        state: state,
        child: PaymentInstructionsScreen(initialResponse: initialResponse),
      );
    },
  ),
  GoRoute(
    path: '/settings/profile',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ProfileView()),
  ),
  GoRoute(
    path: '/settings/pin',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ChangePinView()),
  ),
  GoRoute(
    path: '/pin/reset',
    pageBuilder: (context, state) {
      final extra = state.extra;
      final extraContext = extra is PinResetRouteContext ? extra : null;
      final resetContext = _pinResetRouteContext(
        extraContext,
        state.uri.queryParameters,
      );
      return AppPageTransitions.verticalSlide(
        state: state,
        child: ResetPinView(initialContext: resetContext),
      );
    },
  ),
  GoRoute(
    path: '/pin/locked',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const PinLockedView()),
  ),
  GoRoute(
    path: '/pin/enter',
    pageBuilder: (context, state) {
      final routeContext = state.extra is EnterPinRouteContext
          ? state.extra! as EnterPinRouteContext
          : const EnterPinRouteContext();
      return AppPageTransitions.fade(
        state: state,
        child: EnterPinView(
          title: routeContext.title,
          subtitle: routeContext.subtitle,
          showBiometric: routeContext.showBiometric,
        ),
      );
    },
  ),
  GoRoute(
    path: '/settings/kyc',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const KycStatusView()),
  ),
];

PinResetRouteContext? _pinResetRouteContext(
  PinResetRouteContext? extraContext,
  Map<String, String> query,
) {
  final context = PinResetRouteContext.fromRouteQuery(
    query,
    extraContext: extraContext,
  );
  return context.hasData ? context : null;
}
