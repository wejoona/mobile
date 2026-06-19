import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/features/cards/views/card_detail_view.dart';
import 'package:usdc_wallet/features/cards/views/card_settings_view.dart';
import 'package:usdc_wallet/features/cards/views/card_transactions_view.dart';
import 'package:usdc_wallet/features/cards/views/request_card_view.dart';
import 'package:usdc_wallet/features/deposit/views/payment_instructions_screen.dart';
import 'package:usdc_wallet/features/kyc/views/kyc_status_view.dart';
import 'package:usdc_wallet/features/notifications/views/notifications_view.dart';
import 'package:usdc_wallet/features/pin/models/pin_reset_route_context.dart';
import 'package:usdc_wallet/features/pin/views/confirm_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/enter_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/pin_locked_view.dart';
import 'package:usdc_wallet/features/pin/views/reset_pin_view.dart';
import 'package:usdc_wallet/features/pin/views/set_pin_view.dart';
import 'package:usdc_wallet/features/qr_payment/views/receive_qr_screen.dart';
import 'package:usdc_wallet/features/qr_payment/views/scan_qr_screen.dart';
import 'package:usdc_wallet/features/settings/views/change_pin_view.dart';
import 'package:usdc_wallet/features/settings/views/profile_view.dart';
import 'package:usdc_wallet/features/transactions/views/transaction_detail_view.dart';
import 'package:usdc_wallet/features/wallet/views/transfer_success_view.dart';
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
      child: const ReceiveQrScreen(),
    ),
  ),
  GoRoute(
    path: '/transfer/success',
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      Widget child;
      if (extra != null) {
        child = TransferSuccessView(
          amount: extra['amount'] as double,
          recipient: extra['recipient'] as String,
          transactionId: extra['transactionId'] as String,
          note: extra['note'] as String?,
        );
      } else {
        // Fallback - go home
        child = const TransferSuccessView(
          amount: 0,
          recipient: 'Unknown',
          transactionId: 'N/A',
        );
      }
      // Scale and fade for success screens
      return createSuccessTransition(state: state, child: child);
    },
  ),
  GoRoute(
    path: '/transfer-success',
    pageBuilder: (context, state) {
      final extra = state.extra as Map<String, dynamic>?;
      return createSuccessTransition(
        state: state,
        child: TransferSuccessView(
          amount: extra?['amount'] as double? ?? 0,
          recipient: extra?['recipient'] as String? ?? 'Unknown',
          transactionId: extra?['transactionId'] as String? ?? 'N/A',
          note: extra?['note'] as String?,
        ),
      );
    },
  ),
  GoRoute(
    path: '/notifications',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const NotificationsView(),
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
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const PaymentInstructionsScreen(),
    ),
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
  // PIN Setup (post-registration)
  GoRoute(
    path: '/pin/setup',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const SetPinView(),
    ),
  ),
  GoRoute(
    path: '/pin/reset',
    pageBuilder: (context, state) {
      final resetContext = state.extra is PinResetRouteContext
          ? state.extra as PinResetRouteContext
          : null;
      return AppPageTransitions.verticalSlide(
        state: state,
        child: ResetPinView(initialContext: resetContext),
      );
    },
  ),
  GoRoute(
    path: '/pin/confirm',
    pageBuilder: (context, state) {
      final originalPin = state.extra as String? ?? '';
      return AppPageTransitions.horizontalSlide(
        state: state,
        child: ConfirmPinView(originalPin: originalPin),
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
      final query = state.uri.queryParameters;
      return AppPageTransitions.fade(
        state: state,
        child: EnterPinView(
          title: query['title'] ?? 'Enter PIN',
          subtitle: query['subtitle'],
          showBiometric: query['biometric'] == 'true',
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
