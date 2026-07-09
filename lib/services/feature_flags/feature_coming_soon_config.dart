import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

typedef FeatureComingSoonTextResolver = String Function(AppLocalizations l10n);

class FeatureComingSoonSubscriptionFields {
  const FeatureComingSoonSubscriptionFields({
    required this.featureKey,
    required this.requestedFeature,
    required this.featureName,
  });

  final String featureKey;
  final String requestedFeature;
  final String featureName;
}

class FeatureComingSoonConfig {
  const FeatureComingSoonConfig({
    required this.icon,
    required this.title,
    required this.description,
    this.subscription,
  });

  final IconData icon;
  final FeatureComingSoonTextResolver title;
  final FeatureComingSoonTextResolver description;
  final FeatureComingSoonSubscriptionFields? subscription;
}

final Map<String, FeatureComingSoonConfig> featureComingSoonConfigs = {
  'withdraw': FeatureComingSoonConfig(
    icon: Icons.account_balance_wallet_outlined,
    title: (l10n) => l10n.navigation_withdraw,
    description: (l10n) => l10n.withdraw_comingSoon,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'withdrawals',
      requestedFeature: 'withdrawal_launch',
      featureName: 'Korido withdrawals',
    ),
  ),
  'external_transfers': FeatureComingSoonConfig(
    icon: Icons.send_outlined,
    title: (l10n) => l10n.sendExternal_title,
    description: (l10n) => l10n.sendExternal_info,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'external_transfers',
      requestedFeature: 'external_transfers_launch',
      featureName: 'External transfers',
    ),
  ),
  'airtime': FeatureComingSoonConfig(
    icon: Icons.phone_android_outlined,
    title: (l10n) => l10n.services_buyAirtime,
    description: (l10n) => l10n.services_buyAirtimeDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'airtime',
      requestedFeature: 'airtime_launch',
      featureName: 'Buy airtime',
    ),
  ),
  'bills': FeatureComingSoonConfig(
    icon: Icons.receipt_long_outlined,
    title: (l10n) => l10n.billPayments_title,
    description: (l10n) => l10n.services_billPaymentsDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'bill_payments',
      requestedFeature: 'bill_payments_launch',
      featureName: 'Bill payments',
    ),
  ),
  'savings': FeatureComingSoonConfig(
    icon: Icons.savings_outlined,
    title: (l10n) => l10n.services_savingsGoals,
    description: (l10n) => l10n.services_savingsGoalsDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'savings_goals',
      requestedFeature: 'savings_goals_launch',
      featureName: 'Savings goals',
    ),
  ),
  'savings_pots': FeatureComingSoonConfig(
    icon: Icons.savings_outlined,
    title: (l10n) => l10n.savingsPots_title,
    description: (l10n) => l10n.savingsPots_emptyMessage,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'savings_pots',
      requestedFeature: 'savings_pots_launch',
      featureName: 'Savings pots',
    ),
  ),
  'virtual_cards': FeatureComingSoonConfig(
    icon: Icons.credit_card_outlined,
    title: (l10n) => l10n.cards_comingSoon,
    description: (l10n) => l10n.cards_featureDisabled,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'virtual_card',
      requestedFeature: 'virtual_card_launch',
      featureName: 'Korido virtual card',
    ),
  ),
  'split_bills': FeatureComingSoonConfig(
    icon: Icons.people_outline,
    title: (l10n) => l10n.services_splitBills,
    description: (l10n) => l10n.services_splitBillsDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'split_bills',
      requestedFeature: 'split_bills_launch',
      featureName: 'Split bills',
    ),
  ),
  'budget': FeatureComingSoonConfig(
    icon: Icons.pie_chart_outline_rounded,
    title: (l10n) => l10n.services_budget,
    description: (l10n) => l10n.services_budgetDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'budget_controls',
      requestedFeature: 'budget_controls_launch',
      featureName: 'Budget controls',
    ),
  ),
  'recurring_transfers': FeatureComingSoonConfig(
    icon: Icons.event_repeat_outlined,
    title: (l10n) => l10n.recurringTransfers_title,
    description: (l10n) => l10n.recurringTransfers_emptyMessage,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'recurring_transfers',
      requestedFeature: 'recurring_transfers_launch',
      featureName: 'Recurring transfers',
    ),
  ),
  'analytics': FeatureComingSoonConfig(
    icon: Icons.insights_outlined,
    title: (l10n) => l10n.analytics_title,
    description: (l10n) => l10n.services_analyticsDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'analytics',
      requestedFeature: 'analytics_launch',
      featureName: 'Analytics',
    ),
  ),
  'currency_converter': FeatureComingSoonConfig(
    icon: Icons.currency_exchange_outlined,
    title: (l10n) => l10n.converter_title,
    description: (l10n) => l10n.services_currencyConverterDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'currency_converter',
      requestedFeature: 'currency_converter_launch',
      featureName: 'Currency converter',
    ),
  ),
  'request_money': FeatureComingSoonConfig(
    icon: Icons.request_quote_outlined,
    title: (l10n) => l10n.services_requestMoney,
    description: (l10n) => l10n.services_requestMoneyDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'request_money',
      requestedFeature: 'request_money_launch',
      featureName: 'Request money',
    ),
  ),
  'payment_links': FeatureComingSoonConfig(
    icon: Icons.link_outlined,
    title: (l10n) => l10n.paymentLinks_title,
    description: (l10n) => l10n.paymentLinks_createDescription,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'payment_links',
      requestedFeature: 'payment_links_launch',
      featureName: 'Payment links',
    ),
  ),
  'saved_recipients': FeatureComingSoonConfig(
    icon: Icons.contacts_outlined,
    title: (l10n) => l10n.services_recipients,
    description: (l10n) => l10n.services_recipientsDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'saved_recipients',
      requestedFeature: 'saved_recipients_launch',
      featureName: 'Saved recipients',
    ),
  ),
  'referrals': FeatureComingSoonConfig(
    icon: Icons.card_giftcard_outlined,
    title: (l10n) => l10n.referrals_title,
    description: (l10n) => l10n.referrals_subtitle,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'referrals',
      requestedFeature: 'referrals_launch',
      featureName: 'Refer & earn',
    ),
  ),
  'merchant_qr': FeatureComingSoonConfig(
    icon: Icons.qr_code_scanner_outlined,
    title: (l10n) => l10n.services_scanQr,
    description: (l10n) => l10n.services_scanQrDesc,
    subscription: FeatureComingSoonSubscriptionFields(
      featureKey: 'merchant_qr',
      requestedFeature: 'merchant_qr_launch',
      featureName: 'Merchant QR',
    ),
  ),
};

FeatureComingSoonConfig featureComingSoonConfigFor(
  String? slug,
  AppLocalizations l10n,
) {
  final normalized = slug?.trim();
  if (normalized != null && normalized.isNotEmpty) {
    final config = featureComingSoonConfigs[normalized];
    if (config != null) {
      return config;
    }
  }

  return FeatureComingSoonConfig(
    icon: Icons.hourglass_empty_outlined,
    title: (localizations) => localizations.cards_comingSoon,
    description: (localizations) => localizations.featureComingSoon_description,
  );
}