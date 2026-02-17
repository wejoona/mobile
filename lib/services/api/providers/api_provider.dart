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

import 'package:usdc_wallet/services/api/providers/auth_api.dart';
import 'package:usdc_wallet/services/api/providers/user_api.dart';
import 'package:usdc_wallet/services/api/providers/wallet_api.dart';
import 'package:usdc_wallet/services/api/providers/transfers_api.dart';
import 'package:usdc_wallet/services/api/providers/contacts_api.dart';
import 'package:usdc_wallet/services/api/providers/cards_api.dart';
import 'package:usdc_wallet/services/api/providers/payment_links_api.dart';
import 'package:usdc_wallet/services/api/providers/savings_pots_api.dart';
import 'package:usdc_wallet/services/api/providers/recurring_transfers_api.dart';
import 'package:usdc_wallet/services/api/providers/bank_linking_api.dart';
import 'package:usdc_wallet/services/api/providers/bill_payments_api.dart';
import 'package:usdc_wallet/services/api/providers/beneficiaries_api.dart';
import 'package:usdc_wallet/services/api/providers/devices_api.dart';
import 'package:usdc_wallet/services/api/providers/notifications_api.dart';
import 'package:usdc_wallet/services/api/providers/kyc_api.dart';
import 'package:usdc_wallet/services/api/providers/referrals_api.dart';
import 'package:usdc_wallet/services/api/providers/insights_api.dart';
import 'package:usdc_wallet/services/api/providers/merchant_api.dart';
import 'package:usdc_wallet/services/api/providers/bulk_payments_api.dart';
import 'package:usdc_wallet/services/api/providers/expenses_api.dart';
import 'package:usdc_wallet/services/api/providers/config_api.dart';

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
        expenses = ExpensesApi(dio),
        config = ConfigApi(dio);

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
  final ConfigApi config;
}

/// Riverpod provider — inject everywhere via `ref.read(apiProvider)`.
final apiProvider = Provider<ApiProvider>((ref) {
  return ApiProvider(ref.read(dioProvider));
});
