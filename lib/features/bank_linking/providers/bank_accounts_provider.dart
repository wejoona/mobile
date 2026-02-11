import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/bank_account.dart';
import '../../../services/api/api_client.dart';

/// Bank accounts list provider.
final bankAccountsProvider =
    FutureProvider<List<BankAccount>>((ref) async {
  final dio = ref.watch(dioProvider);
  final link = ref.keepAlive();

  Timer(const Duration(minutes: 2), () => link.close());

  final response = await dio.get('/bank-accounts');
  final data = response.data as Map<String, dynamic>;
  final items = data['data'] as List? ?? [];
  return items
      .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
      .toList();
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

/// Bank account actions.
class BankAccountActions {
  final Dio _dio;

  BankAccountActions(this._dio);

  Future<BankAccount> link({
    required String bankName,
    required String accountNumber,
    String? accountName,
    String? routingNumber,
    BankAccountType type = BankAccountType.checking,
  }) async {
    final response = await _dio.post('/bank-accounts', data: {
      'bankName': bankName,
      'accountNumber': accountNumber,
      if (accountName != null) 'accountName': accountName,
      if (routingNumber != null) 'routingNumber': routingNumber,
      'type': type.name,
    });
    return BankAccount.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> setDefault(String accountId) async {
    await _dio.patch('/bank-accounts/$accountId/default');
  }

  Future<void> remove(String accountId) async {
    await _dio.delete('/bank-accounts/$accountId');
  }
}

final bankAccountActionsProvider = Provider<BankAccountActions>((ref) {
  return BankAccountActions(ref.watch(dioProvider));
});
