import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/bank_account.dart';
import '../../../services/service_providers.dart';

/// Bank accounts list provider — wired to BankLinkingService.
final bankAccountsProvider = FutureProvider<List<BankAccount>>((ref) async {
  final service = ref.watch(bankLinkingServiceProvider);
  final link = ref.keepAlive();
  Timer(const Duration(minutes: 2), () => link.close());

  final data = await service.getBankAccounts();
  final items = (data['data'] as List?) ?? [];
  return items.map((e) => BankAccount.fromJson(e as Map<String, dynamic>)).toList();
});

/// Default bank account.
final defaultBankAccountProvider = Provider<BankAccount?>((ref) {
  final accounts = ref.watch(bankAccountsProvider).valueOrNull ?? [];
  try {
    return accounts.firstWhere((a) => a.isDefault);
  } catch (_) {
    return accounts.isNotEmpty ? accounts.first : null;
  }
});

/// Bank account actions delegate.
final bankAccountActionsProvider = Provider((ref) => ref.watch(bankLinkingServiceProvider));
