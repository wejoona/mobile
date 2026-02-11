/// Single API provider facade.
///
/// Usage:
///   final api = ref.read(apiProvider);
///   final res = await api.auth.login(phone: '+225...');
///   final balance = await api.wallet.getWallet();
///   final contacts = await api.contacts.list();
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

import 'auth_api.dart';
import 'user_api.dart';
import 'wallet_api.dart';
import 'transfers_api.dart';
import 'contacts_api.dart';
import 'cards_api.dart';
import 'payment_links_api.dart';
import 'savings_pots_api.dart';
import 'recurring_transfers_api.dart';
import 'bank_linking_api.dart';
import 'bill_payments_api.dart';
import 'beneficiaries_api.dart';
import 'devices_api.dart';
import 'notifications_api.dart';
import 'kyc_api.dart';
import 'referrals_api.dart';
import 'insights_api.dart';
import 'merchant_api.dart';
import 'bulk_payments_api.dart';
import 'expenses_api.dart';

/// Unified API interface — one import, all endpoints.
class ApiProvider {
  ApiProvider(Dio dio)
      : auth = AuthApi(dio),
        user = UserApi(dio),
        wallet = WalletApi(dio),
        transfers = TransfersApi(dio),
        contacts = ContactsApi(dio),
        cards = CardsApi(dio),
        paymentLinks = PaymentLinksApi(dio),
        savingsPots = SavingsPotsApi(dio),
        recurringTransfers = RecurringTransfersApi(dio),
        bankLinking = BankLinkingApi(dio),
        billPayments = BillPaymentsApi(dio),
        beneficiaries = BeneficiariesApi(dio),
        devices = DevicesApi(dio),
        notifications = NotificationsApi(dio),
        kyc = KycApi(dio),
        referrals = ReferralsApi(dio),
        insights = InsightsApi(dio),
        merchant = MerchantApi(dio),
        bulkPayments = BulkPaymentsApi(dio),
        expenses = ExpensesApi(dio);

  final AuthApi auth;
  final UserApi user;
  final WalletApi wallet;
  final TransfersApi transfers;
  final ContactsApi contacts;
  final CardsApi cards;
  final PaymentLinksApi paymentLinks;
  final SavingsPotsApi savingsPots;
  final RecurringTransfersApi recurringTransfers;
  final BankLinkingApi bankLinking;
  final BillPaymentsApi billPayments;
  final BeneficiariesApi beneficiaries;
  final DevicesApi devices;
  final NotificationsApi notifications;
  final KycApi kyc;
  final ReferralsApi referrals;
  final InsightsApi insights;
  final MerchantApi merchant;
  final BulkPaymentsApi bulkPayments;
  final ExpensesApi expenses;
}

/// Riverpod provider — inject everywhere via `ref.read(apiProvider)`.
final apiProvider = Provider<ApiProvider>((ref) {
  return ApiProvider(ref.read(dioProvider));
});
