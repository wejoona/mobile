/// Centralized service provider registry.
///
/// All services are wired to Dio (which has mock interceptors when MockConfig.useMocks is true).
/// This means every service automatically falls back to mock data in dev mode.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api/api_client.dart';
import 'cards/cards_service.dart';
import 'recurring_transfers/recurring_transfers_service.dart';
import 'payment_links/payment_links_service.dart';
import 'bank_linking/bank_linking_service.dart';
import 'bulk_payments/bulk_payments_service.dart';
import 'kyc/kyc_service.dart';
import 'deposit/deposit_service.dart';
import 'user/user_service.dart';

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
