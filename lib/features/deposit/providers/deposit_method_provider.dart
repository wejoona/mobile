import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Run 363: Deposit method selection provider
enum DepositMethod {
  mobileMoney,
  bankTransfer,
  card,
  crypto,
}

class DepositMethodInfo {
  final DepositMethod method;
  final String name;
  final String description;
  final String iconAsset;
  final double? minAmount;
  final double? maxAmount;
  final Duration estimatedTime;
  final double feePercent;
  final bool isAvailable;

  const DepositMethodInfo({
    required this.method,
    required this.name,
    required this.description,
    this.iconAsset = '',
    this.minAmount,
    this.maxAmount,
    required this.estimatedTime,
    required this.feePercent,
    this.isAvailable = true,
  });
}

final depositMethodsProvider = Provider<List<DepositMethodInfo>>((ref) {
  return const [
    DepositMethodInfo(
      method: DepositMethod.mobileMoney,
      name: 'Mobile Money',
      description: 'Orange Money, MTN MoMo, Wave',
      estimatedTime: Duration(minutes: 5),
      feePercent: 1.5,
      minAmount: 1,
      maxAmount: 500,
    ),
    DepositMethodInfo(
      method: DepositMethod.bankTransfer,
      name: 'Virement bancaire',
      description: 'Depuis votre compte bancaire',
      estimatedTime: Duration(hours: 24),
      feePercent: 0.5,
      minAmount: 10,
      maxAmount: 5000,
    ),
    DepositMethodInfo(
      method: DepositMethod.card,
      name: 'Carte bancaire',
      description: 'Visa, Mastercard',
      estimatedTime: Duration(minutes: 1),
      feePercent: 2.5,
      minAmount: 5,
      maxAmount: 1000,
    ),
    DepositMethodInfo(
      method: DepositMethod.crypto,
      name: 'Crypto (USDC)',
      description: 'Transfert depuis un portefeuille externe',
      estimatedTime: Duration(minutes: 2),
      feePercent: 0,
      minAmount: 0.01,
    ),
  ];
});

final selectedDepositMethodProvider = StateProvider<DepositMethod?>((ref) => null);
