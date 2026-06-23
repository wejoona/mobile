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
    'walletId': id,
    'userId': userId,
    'address': address,
    'walletAddress': address,
    'network': network,
    'blockchain': network,
    'currency': 'USDC',
    'balance': balanceUsdc,
    'balanceUsdc': balanceUsdc,
    'balanceLocal': balanceLocal,
    'balances': [
      {
        'currency': 'USDC',
        'available': balanceUsdc,
        'pending': 0,
        'total': balanceUsdc,
      },
      {
        'currency': localCurrency,
        'available': balanceLocal,
        'pending': 0,
        'total': balanceLocal,
      },
    ],
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

/// Legacy deposit request retained for old wallet mock aliases.
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

/// Legacy deposit response retained for old wallet mock aliases.
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

/// Legacy withdraw request retained for old wallet mock aliases.
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

/// Legacy withdraw response retained for old wallet mock aliases.
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
    path: '/create',
    method: HttpMethod.post,
    description: 'Create a new wallet',
    requestType: CreateWalletRequest,
    responseType: WalletResponse,
    requiresAuth: true,
  );

  static const getRate = ApiEndpoint(
    path: '/rate',
    method: HttpMethod.get,
    description: 'Get exchange rate quote',
    requiresAuth: true,
    queryParams: {
      'sourceCurrency': 'Source currency, e.g. XOF',
      'targetCurrency': 'Target currency, e.g. USD',
      'amount': 'Source amount',
      'direction': 'deposit or withdrawal',
    },
  );

  static const getKycStatus = ApiEndpoint(
    path: '/kyc/status',
    method: HttpMethod.get,
    description: 'Get wallet KYC status',
    requiresAuth: true,
  );

  static const submitKyc = ApiEndpoint(
    path: '/kyc/submit',
    method: HttpMethod.post,
    description: 'Submit wallet KYC details',
    requiresAuth: true,
  );

  static const getLimits = ApiEndpoint(
    path: '/limits',
    method: HttpMethod.get,
    description: 'Get wallet transaction limits',
    requiresAuth: true,
  );

  @override
  List<ApiEndpoint> get endpoints => [
    getWallet,
    createWallet,
    getRate,
    getKycStatus,
    submitKyc,
    getLimits,
  ];
}
