import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/features/deposit/views/deposit_amount_screen.dart';
import 'package:usdc_wallet/features/deposit/views/deposit_status_screen.dart';
import 'package:usdc_wallet/features/deposit/views/provider_selection_screen.dart';
import 'package:usdc_wallet/features/offline/views/pending_transfers_screen.dart';
import 'package:usdc_wallet/features/send/views/amount_screen.dart';
import 'package:usdc_wallet/features/send/views/confirm_screen.dart';
import 'package:usdc_wallet/features/send/views/pin_verification_screen.dart';
import 'package:usdc_wallet/features/send/views/recipient_screen.dart';
import 'package:usdc_wallet/features/send/views/result_screen.dart';
import 'package:usdc_wallet/features/send_external/views/address_input_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_amount_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_confirm_screen.dart';
import 'package:usdc_wallet/features/send_external/views/external_result_screen.dart';
import 'package:usdc_wallet/features/send_external/views/scan_address_qr_screen.dart';
import 'package:usdc_wallet/features/wallet/views/withdraw_view.dart';
import 'package:usdc_wallet/router/page_transitions.dart';

List<RouteBase> moneyMovementRoutes() => [
  // Mobile Money Deposit Flow
  GoRoute(
    path: '/deposit/amount',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const DepositAmountScreen(),
    ),
  ),
  GoRoute(
    path: '/deposit/provider',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ProviderSelectionScreen(),
    ),
  ),
  GoRoute(
    path: '/deposit/status',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const DepositStatusScreen(),
    ),
  ),
  GoRoute(
    path: '/send',
    pageBuilder: (context, state) {
      final query = state.uri.queryParameters;
      final extra = state.extra;
      var initialPhone = query['phone'] ?? query['to'];
      var initialUsername = query['username'] ?? query['recipientUsername'];
      var initialRecipientId = query['recipientId'];
      var initialName = query['name'];

      if (extra is Map) {
        final extraPhone =
            extra['phone'] ??
            extra['recipientPhone'] ??
            extra['recipient'] ??
            extra['to'];
        final extraUsername = extra['username'] ?? extra['recipientUsername'];
        final extraRecipientId = extra['recipientId'];
        final extraName = extra['name'] ?? extra['recipientName'];
        if (initialPhone == null && extraPhone is String) {
          initialPhone = extraPhone;
        }
        if (initialUsername == null && extraUsername is String) {
          initialUsername = extraUsername;
        }
        if (initialRecipientId == null && extraRecipientId is String) {
          initialRecipientId = extraRecipientId;
        }
        if (initialName == null && extraName is String) {
          initialName = extraName;
        }
      }

      return AppPageTransitions.verticalSlide(
        state: state,
        child: RecipientScreen(
          initialPhone: initialPhone,
          initialUsername: initialUsername,
          initialRecipientId: initialRecipientId,
          initialName: initialName,
        ),
      );
    },
  ),
  GoRoute(
    path: '/send/amount',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const AmountScreen(),
    ),
  ),
  GoRoute(
    path: '/send/confirm',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ConfirmScreen(),
    ),
  ),
  GoRoute(
    path: '/send/pin',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const PinVerificationScreen(),
    ),
  ),
  GoRoute(
    path: '/send/result',
    pageBuilder: (context, state) =>
        AppPageTransitions.fade(state: state, child: const ResultScreen()),
  ),
  GoRoute(
    path: '/offline/pending-transfers',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const PendingTransfersScreen(),
    ),
  ),
  // External transfer routes
  GoRoute(
    path: '/send-external',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const AddressInputScreen(),
    ),
  ),
  GoRoute(
    path: '/send-external/amount',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ExternalAmountScreen(),
    ),
  ),
  GoRoute(
    path: '/send-external/confirm',
    pageBuilder: (context, state) => AppPageTransitions.horizontalSlide(
      state: state,
      child: const ExternalConfirmScreen(),
    ),
  ),
  GoRoute(
    path: '/send-external/result',
    pageBuilder: (context, state) => AppPageTransitions.fade(
      state: state,
      child: const ExternalResultScreen(),
    ),
  ),
  GoRoute(
    path: '/qr/scan-address',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const ScanAddressQrScreen(),
    ),
  ),
  GoRoute(
    path: '/withdraw',
    pageBuilder: (context, state) => AppPageTransitions.verticalSlide(
      state: state,
      child: const WithdrawView(),
    ),
  ),
];
