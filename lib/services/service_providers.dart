/// Centralized service provider registry.
///
/// All services are wired to Dio (which has mock interceptors when MockConfig.useMocks is true).
/// This means every service automatically falls back to mock data in dev mode.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/cards/cards_service.dart';
import 'package:usdc_wallet/services/recurring_transfers/recurring_transfers_service.dart';
import 'package:usdc_wallet/services/payment_links/payment_links_service.dart';
import 'package:usdc_wallet/services/bank_linking/bank_linking_service.dart';
import 'package:usdc_wallet/services/bulk_payments/bulk_payments_service.dart';
import 'package:usdc_wallet/services/kyc/kyc_service.dart';
import 'package:usdc_wallet/services/deposit/deposit_service.dart';
import 'package:usdc_wallet/services/user/user_service.dart';

// Note: SavingsPotsService, LimitsService, ReferralsService
// have providers defined in their own files.

// ── Cards ──
final cardsServiceProvider = Provider<CardsService>((ref) {
  return CardsService(ref.watch(dioProvider));
});

// ── Recurring Transfers ──
final recurringTransfersServiceProvider = Provider<RecurringTransfersService>((ref) {
  return RecurringTransfersService(ref.watch(dioProvider));
});

// ── Payment Links ──
final paymentLinksServiceProvider = Provider<PaymentLinksService>((ref) {
  return PaymentLinksService(ref.watch(dioProvider));
});

// ── Bank Linking ──
final bankLinkingServiceProvider = Provider<BankLinkingService>((ref) {
  return BankLinkingService(ref.watch(dioProvider));
});

// ── Bulk Payments ──
final bulkPaymentsServiceProvider = Provider<BulkPaymentsService>((ref) {
  return BulkPaymentsService(ref.watch(dioProvider));
});

// ── KYC ──
final kycServiceProvider = Provider<KycService>((ref) {
  return KycService(ref.watch(dioProvider));
});

// ── Deposit ──
// (Already has provider in deposit_service.dart, re-export here for consistency)

// ── User ──
final userServiceProvider = Provider<UserService>((ref) {
  return UserService(ref.watch(dioProvider));
});

// Note: SavingsPotsService, LimitsService, ReferralsService
// already have their own providers defined in their files.
// They are imported directly by feature providers.
