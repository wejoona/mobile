/// Wallet API Contract
///
/// Defines the interface for wallet endpoints.
library;

import 'package:usdc_wallet/mocks/base/api_contract.dart';

// ==================== REQUEST/RESPONSE TYPES ====================

/// Wallet response
class WalletResponse {
  final String id;
  final String userId;
  final String address;
  final String network;
  final double balanceUsdc;
  final double balanceLocal;
  final String localCurrency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WalletResponse({
    required this.id,
    required this.userId,
    required this.address,
    required this.network,
    required this.balanceUsdc,
    required this.balanceLocal,
    required this.localCurrency,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'address': address,
    'network': network,
    'balanceUsdc': balanceUsdc,
    'balanceLocal': balanceLocal,
    'localCurrency': localCurrency,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// Create wallet request
class CreateWalletRequest {
  final String network;

  const CreateWalletRequest({this.network = 'polygon'});

  Map<String, dynamic> toJson() => {'network': network};
}

/// Deposit request
class DepositRequest {
  final double amount;
  final String provider;
  final String phoneNumber;

  const DepositRequest({
    required this.amount,
    required this.provider,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'provider': provider,
    'phoneNumber': phoneNumber,
  };
}

/// Deposit response
class DepositResponse {
  final String id;
  final String status;
  final double amount;
  final String provider;
  final String? instructions;
  final String? reference;
  final DateTime expiresAt;

  const DepositResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.provider,
    this.instructions,
    this.reference,
    required this.expiresAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'amount': amount,
    'provider': provider,
    'instructions': instructions,
    'reference': reference,
    'expiresAt': expiresAt.toIso8601String(),
  };
}

/// Withdraw request
class WithdrawRequest {
  final double amount;
  final String provider;
  final String phoneNumber;

  const WithdrawRequest({
    required this.amount,
    required this.provider,
    required this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'provider': provider,
    'phoneNumber': phoneNumber,
  };
}

/// Withdraw response
class WithdrawResponse {
  final String id;
  final String status;
  final double amount;
  final double fee;
  final String provider;

  const WithdrawResponse({
    required this.id,
    required this.status,
    required this.amount,
    required this.fee,
    required this.provider,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'status': status,
    'amount': amount,
    'fee': fee,
    'provider': provider,
  };
}

// ==================== CONTRACT ====================

/// Wallet API Contract
class WalletContract extends ApiContract {
  @override
  String get serviceName => 'Wallet';

  @override
  String get basePath => '/wallet';

  static const getWallet = ApiEndpoint(
    path: '',
    method: HttpMethod.get,
    description: 'Get user wallet',
    responseType: WalletResponse,
    requiresAuth: true,
  );

  static const createWallet = ApiEndpoint(
    path: '',
    method: HttpMethod.post,
    description: 'Create a new wallet',
    requestType: CreateWalletRequest,
    responseType: WalletResponse,
    requiresAuth: true,
  );

  static const getBalance = ApiEndpoint(
    path: '/balance',
    method: HttpMethod.get,
    description: 'Get wallet balance',
    requiresAuth: true,
  );

  static const deposit = ApiEndpoint(
    path: '/deposit',
    method: HttpMethod.post,
    description: 'Initiate a deposit',
    requestType: DepositRequest,
    responseType: DepositResponse,
    requiresAuth: true,
  );

  static const withdraw = ApiEndpoint(
    path: '/withdraw',
    method: HttpMethod.post,
    description: 'Initiate a withdrawal',
    requestType: WithdrawRequest,
    responseType: WithdrawResponse,
    requiresAuth: true,
  );

  static const getDepositProviders = ApiEndpoint(
    path: '/deposit/providers',
    method: HttpMethod.get,
    description: 'Get available deposit providers',
    requiresAuth: true,
  );

  static const getWithdrawProviders = ApiEndpoint(
    path: '/withdraw/providers',
    method: HttpMethod.get,
    description: 'Get available withdrawal providers',
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [
    getWallet,
    createWallet,
    getBalance,
    deposit,
    withdraw,
    getDepositProviders,
    getWithdrawProviders,
  ];
}
